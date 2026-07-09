// 私有构造用私有字段，无法用 this._x 初始化形参，故豁免该 lint。
// ignore_for_file: prefer_initializing_formals
import 'dart:io';

import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/postcard_content.dart';
import '../data/content/content_repository.dart';
import '../data/save/session_store.dart';
import '../services/audit_service.dart';
import '../services/audit_service_impl.dart';
import '../services/clock_service.dart';
import '../services/economy_service.dart';
import '../services/economy_service_impl.dart';
import '../services/event_scheduler.dart';
import '../services/event_scheduler_impl.dart';
import '../services/exp_engine.dart';
import '../services/exp_engine_impl.dart';
import '../services/graduation_service.dart';
import '../services/graduation_service_impl.dart';
import '../services/log_port.dart';
import '../services/postcard_generator.dart';
import '../services/postcard_generator_impl.dart';
import '../services/revisit_service.dart';
import '../services/revisit_service_impl.dart';
import '../services/unlock_service.dart';
import '../services/unlock_service_impl.dart';
import '../services/visitor_service.dart';
import '../services/visitor_service_impl.dart';
import 'game_state.dart';

/// 组合根：按依赖顺序装配全部 Service，并把 EventScheduler.dispatch 路由到各服务。
/// 通过注入 [AuditLogPort]（运行期=DAO适配器，单测=内存）与 [ContentRepository] 解耦。
class GameServices {
  final ClockService clock;
  final AuditService audit;
  final ExpEngine exp;
  final EconomyService economy;
  final UnlockService unlock;
  final VisitorService visitor;
  final GraduationService graduation;
  final RevisitService revisit;
  final PostcardGenerator postcard;
  final EventScheduler scheduler;

  final GameSession _session;
  final SessionStore _store;
  final ContentRepository _content;
  final double Function() _rng;
  final String Function() _idGen;
  final Future<List<ExpLogEntry>> Function(String petId)? _expLogReader;

  /// 当前游戏状态（UI 读取）。
  GameSession get session => _session;
  SessionStore get store => _store;
  ContentRepository get content => _content;

  /// 读某只宠物的经验流水（成长手账）；未接持久化时返回空。
  Future<List<ExpLogEntry>> readExpLog(String petId) async =>
      (await _expLogReader?.call(petId)) ?? const [];

  GameServices._({
    required this.clock,
    required this.audit,
    required this.exp,
    required this.economy,
    required this.unlock,
    required this.visitor,
    required this.graduation,
    required this.revisit,
    required this.postcard,
    required this.scheduler,
    required GameSession session,
    required SessionStore store,
    required ContentRepository content,
    required double Function() rng,
    required String Function() idGen,
    Future<List<ExpLogEntry>> Function(String petId)? expLogReader,
  }) : _session = session,
       _store = store,
       _content = content,
       _rng = rng,
       _idGen = idGen,
       _expLogReader = expLogReader;

  factory GameServices.wire({
    required GameSession session,
    required AuditLogPort port,
    required ContentRepository content,
    required ClockService clock,
    required double Function() rng,
    required String Function() idGen,
    required String ownerName,
    List<PostcardTemplate> postcardTemplates = const [],
    List<Encounter> encounters = const [],
    List<Incident> incidents = const [],
    Future<List<ExpLogEntry>> Function(String petId)? expLogReader,
    SessionStore? store,
  }) {
    final audit = AuditServiceImpl(
      port,
      () => session.allPets,
      () => session.wallet,
    );

    final exp = ExpEngineImpl(
      audit,
      clock,
      (tag, src) => content.personalityById(tag)?.actionExpBonus[src] ?? 0.0,
      idGen,
    );

    final economy = EconomyServiceImpl(
      port,
      session.wallet,
      session.yard,
      clock,
      idGen,
      (petId) => session.eventCounts[petId] ?? 0,
      (petId) => session.visitorCounts[petId] ?? 0,
      (sp) => content.speciesById(sp)?.category == PetCategory.fantasy,
    );

    final unlock = UnlockServiceImpl(
      content.achievements,
      session.yard,
      session.clues,
      session.achievements,
      session.ownedSpecies.contains,
      economy,
      () => clock.now(),
    );

    final visitor = VisitorServiceImpl(
      content.visitors,
      content.visitorInteractions,
      rng,
      idGen,
      () => clock.now(),
      (log) {
        session.visitorLog.add(log);
        final id = log.withPetId;
        if (id != null) {
          session.visitorCounts[id] = (session.visitorCounts[id] ?? 0) + 1;
        }
      },
      (clueId) => unlock.bumpClue(clueId),
    );

    final graduation = GraduationServiceImpl(
      economy,
      content.locations,
      session.yard,
      idGen,
      () => clock.now(),
      rng,
      (j) => session.journeys.add(j),
    );

    final revisit = RevisitServiceImpl(exp, rng, () => clock.now());

    final postcard = PostcardGeneratorImpl(
      locations: {for (final l in content.locations) l.id: l},
      templates: postcardTemplates,
      encounters: encounters,
      incidents: incidents,
      rng: rng,
      now: () => clock.now(),
      idGen: idGen,
      ownerName: ownerName,
      onPostcard: (pc) => session.postcards.add(pc), // 旅行相册数据源；DAO 持久化 [待细化]
    );

    late GameServices svc;
    final scheduler = EventSchedulerImpl(
      session.jobs,
      session.generatedDays,
      idGen,
      rng,
      (job) => svc._dispatch(job),
    );

    svc = GameServices._(
      clock: clock,
      audit: audit,
      exp: exp,
      economy: economy,
      unlock: unlock,
      visitor: visitor,
      graduation: graduation,
      revisit: revisit,
      postcard: postcard,
      scheduler: scheduler,
      session: session,
      content: content,
      rng: rng,
      idGen: idGen,
      expLogReader: expLogReader,
      store: store ?? _NoopSessionStore.instance,
    );
    return svc;
  }

  // ── 领养 / 毕业编排（UI 动作入口）─────────────────────

  /// 可领养物种：图鉴已解锁（当前可得 / 曾拥有）的真实或彩蛋宠。
  List<PetSpecies> adoptableSpecies() => _content.species.where((sp) {
    final st = unlock.dexStateOf(sp);
    return st == DexState.available || st == DexState.ownedBefore;
  }).toList();

  /// 领养一只新宠为当前在养宠（INV-2：调用前需确保无在养宠）。
  /// 随机 2 个不重复性格、变体随机；写入 ownedSpecies。
  Pet adopt({required String speciesId, required String name}) {
    final sp = _content.speciesById(speciesId);
    final now = clock.now();
    final variants = sp?.variantIds ?? const <String>[];
    final variantId = variants.isEmpty
        ? '${speciesId}_v1'
        : variants[(_rng() * variants.length).floor().clamp(
            0,
            variants.length - 1,
          )];
    final trimmed = name.trim();
    final pet = Pet(
      id: _idGen(),
      speciesId: speciesId,
      variantId: variantId,
      name: trimmed.isEmpty ? (sp?.name ?? '宝贝') : trimmed,
      personality: _pickTwoPersonalities(),
      bornAt: now,
      lastOnlineAt: now,
      offlineDayKey: _dayKey(now),
    );
    _session.current = pet;
    _session.ownedSpecies.add(speciesId);
    return pet;
  }

  /// 毕业当前在养宠：暖绒结算 + 生成旅程 → 转漫游、清空在养位。
  /// 返回旅程站点数（供典礼展示）；无在养宠或经验未达标返回 null。
  Future<int?> graduateCurrent() async {
    final pet = _session.current;
    if (pet == null || pet.exp < GameConfig.graduationExp) return null;
    final journeyId = await graduation.graduate(pet);
    _session.roaming.add(pet);
    _session.current = null;
    revisit.scheduleNextRevisit(pet); // 漫游开始即排下次回访
    final match = _session.journeys.where((e) => e.id == journeyId);
    return match.isEmpty ? null : match.first.stops.length;
  }

  /// 成就同步：从 session 现状重算所有可派生的累计计数，逐类型推进成就。
  /// 幂等（UnlockService 只取更大值），每次游戏动作后调用。返回本次新解锁的成就。
  List<Achievement> syncAchievements() {
    final s = _session;
    final distinctVisitors = s.visitorLog
        .map((e) => e.visitorId)
        .toSet()
        .length;
    final distinctStamps = s.postcards.map((p) => p.stampId).toSet().length;
    final distinctPostcardSeasons = s.postcards
        .map((p) => p.season)
        .toSet()
        .length;
    final counts = <String, int>{
      'actionCount': s.careActionCount,
      'gradCount': s.yard.gradCount,
      'postcardCount': s.postcards.length,
      'visitorDexCount': distinctVisitors,
      'speciesCollected': s.ownedSpecies.length,
      'revisitCount': s.revisitCount,
      'yardStage': s.yard.luxuryStage,
      'themeCount': s.yard.ownedThemeIds.length,
      'specialEventCount': s.specialEventCount,
      'loginStreak': s.settings.loginStreakCurrent,
      'stampCount': distinctStamps,
      'seasonPostcard': distinctPostcardSeasons,
    };
    final newly = <Achievement>[];
    counts.forEach((type, value) {
      newly.addAll(
        unlock.checkAchievements(GameSignal(type, params: {'progress': value})),
      );
    });
    return newly;
  }

  /// 处理漫游宠（每次日切/恢复调用）：按期寄明信片 + 到点回访串门。
  /// 明信片/回访不走 scheduler job（那是院子在养宠的事），按 roaming 逐只驱动。
  Future<void> processRoaming(DateTime now) async {
    // 明信片：每只漫游宠的活跃旅程按 nextPostcardAt 寄片（内部判定到点）。
    for (final pet in _session.roaming) {
      final jid = pet.journeyId;
      if (jid == null) continue;
      final matches = _session.journeys.where((j) => j.id == jid);
      if (matches.isEmpty) continue;
      await postcard.dailyTick(pet: pet, journey: matches.first);
    }
    // 回访：上一位串门结束（1 个 tick 窗口）→ 再从到期漫游宠里挑新的（INV-2）。
    final prev = _session.revisitor;
    if (prev != null) {
      revisit.onRevisitEnd(prev);
      _session.revisitor = null;
    }
    final next = revisit.pickRevisitor(
      _session.roaming,
      now,
      hasCurrentRevisitor: false,
    );
    if (next != null) {
      _session.revisitor = next;
      revisit.onRevisitInteract(next, _session.current);
      _session.revisitCount++; // 成就：回访累计
    }
  }

  List<String> _pickTwoPersonalities() {
    final ids = _content.personalities.map((p) => p.id).toList();
    if (ids.length < 2) return ids;
    final i = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    var j = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    if (j == i) j = (i + 1) % ids.length;
    return [ids[i], ids[j]];
  }

  static String _dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  /// EventScheduler 单个 job 的执行路由（§3.4）。
  Future<void> _dispatch(ScheduledJob job) async {
    final pet = _session.current;
    final now = clock.now();
    _clearExpiredActiveVisitor(now);
    switch (job.type) {
      case JobType.visitorCheck:
        if (_session.activeVisitor != null) break;
        final window = job.payloadRef == 'night'
            ? TimeWindow.night
            : TimeWindow.day;
        const weather = Weather.clear; // [待细化] 天气系统
        final season = _seasonOf(now);
        var v = visitor.rollWindow(
          window: window,
          yard: _session.yard,
          weather: weather,
          season: season,
          now: now,
        );
        v ??= (window == TimeWindow.night)
            ? visitor.rollLegendary(
                yard: _session.yard,
                weather: weather,
                season: season,
                now: now,
              )
            : null;
        if (v != null) {
          final it = visitor.pickInteraction(v, pet);
          if (pet != null) {
            exp.addExp(
              pet: pet,
              baseDelta: it.expReward,
              source: ExpSource.visitor,
              sourceRef: v.id,
              note: it.script,
            );
          }
          visitor.recordVisit(v, pet, it);
          _session.activeVisitor = ActiveVisitor(
            visitorId: v.id,
            arrivedAt: now,
            leavesAt: now.add(const Duration(hours: 24)),
            interactionId: it.id,
            withPetId: pet?.id,
          );
        }
      case JobType.dailyEventGen:
        if (pet == null) break;
        final dailies = _content.events
            .where((e) => e.type == EventType.daily)
            .toList();
        if (dailies.isNotEmpty) {
          final ev = dailies[(_rng() * dailies.length).floor()];
          exp.addExp(
            pet: pet,
            baseDelta: ev.expReward,
            source: ExpSource.eventDaily,
            sourceRef: ev.id,
          );
          _session.eventCounts[pet.id] =
              (_session.eventCounts[pet.id] ?? 0) + 1;
        }
      case JobType.specialEventEval:
        if (pet == null) break;
        // 眷顾资格的彩蛋事件：满足等级/豪华度门槛，oncePerPet 未触发过。
        final eligible = _content.events.where((e) {
          if (e.type != EventType.special) return false;
          final w = e.weights;
          if (w.minLevel != null && pet.level < w.minLevel!) return false;
          if (w.minLuxuryStage != null &&
              _session.yard.luxuryStage < w.minLuxuryStage!) {
            return false;
          }
          if (e.oncePerPet &&
              _session.firedSpecials.contains('${pet.id}:${e.id}')) {
            return false;
          }
          return true;
        }).toList();
        if (eligible.isEmpty) break;
        if (_rng() >= _specialEventChance) break; // 低频彩蛋（日 cap=1）
        final ev = eligible[(_rng() * eligible.length).floor()];
        exp.addExp(
          pet: pet,
          baseDelta: ev.expReward,
          source: ExpSource.eventSpecial,
          sourceRef: ev.id,
        );
        if (ev.currencyReward != null) {
          economy.earn(
            ev.currencyReward!,
            CurrencyReason.eventReward,
            ref: 'evt:${pet.id}:${ev.id}',
          );
        }
        if (ev.oncePerPet) _session.firedSpecials.add('${pet.id}:${ev.id}');
        _session.eventCounts[pet.id] = (_session.eventCounts[pet.id] ?? 0) + 1;
        _session.specialEventCount++; // 成就：彩蛋事件累计
      case JobType.revisitDue:
      case JobType.postcardDue:
        break; // 漫游宠的明信片/回访不走 scheduler，由 processRoaming 驱动
    }
  }

  /// 彩蛋事件单次评估触发概率（日 cap=1，见 GameConfig.specialEventDailyCap）。
  static const double _specialEventChance = 0.25;

  Season _seasonOf(DateTime t) {
    final m = t.month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }

  void _clearExpiredActiveVisitor(DateTime now) {
    final active = _session.activeVisitor;
    if (active != null && !active.leavesAt.isAfter(now)) {
      _session.activeVisitor = null;
    }
  }
}

class _NoopSessionStore extends SessionStore {
  _NoopSessionStore._() : super(Directory.systemTemp);

  static final instance = _NoopSessionStore._();

  @override
  Future<GameSession?> load() async => null;

  @override
  Future<void> save(GameSession session) async {}
}
