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
import '../services/save_service.dart';
import '../services/unlock_service.dart';
import '../services/unlock_service_impl.dart';
import '../services/visitor_service.dart';
import '../services/visitor_service_impl.dart';
import 'game_state.dart';

class EventResolution {
  final int expApplied;
  final int currencyApplied;
  final String? resultScript;

  const EventResolution({
    required this.expApplied,
    required this.currencyApplied,
    this.resultScript,
  });
}

class VisitorInteractionOutcome {
  final String message;
  final int expApplied;
  final String animRef;

  const VisitorInteractionOutcome({
    required this.message,
    required this.expApplied,
    required this.animRef,
  });
}

class RevisitInteractionOutcome {
  final int gift;
  final bool broughtCompanion;
  final int currentPetExp;

  const RevisitInteractionOutcome({
    required this.gift,
    required this.broughtCompanion,
    required this.currentPetExp,
  });
}

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
  final SaveService? _portableSave;
  final Future<void> Function()? _dispose;

  /// One-shot startup context consumed by the presentation layer. These stay
  /// out of the save file because the underlying EXP grant is already audited.
  Duration startupOfflineElapsed = Duration.zero;
  int startupOfflineExp = 0;

  /// 当前游戏状态（UI 读取）。
  GameSession get session => _session;
  SessionStore get store => _store;
  ContentRepository get content => _content;
  SaveService? get portableSave => _portableSave;

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
    SaveService? portableSave,
    Future<void> Function()? dispose,
  }) : _session = session,
       _store = store,
       _content = content,
       _rng = rng,
       _idGen = idGen,
       _expLogReader = expLogReader,
       _portableSave = portableSave,
       _dispose = dispose;

  Future<void> dispose() async => _dispose?.call();

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
    SaveService? portableSave,
    Future<void> Function()? dispose,
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
      session.shopInventory,
    );

    final unlock = UnlockServiceImpl(
      content.achievements,
      session.yard,
      session.clues,
      session.achievements,
      session.ownedSpecies.contains,
      economy,
      () => clock.now(),
      session.shopInventory,
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
      themeBonus: (yard, candidate, season, window, weather) {
        for (final item in content.shopItems) {
          if (item.effect.type != EffectType.themeSkin ||
              item.effect.params['themeId'] != yard.activeThemeId) {
            continue;
          }
          final raw = item.effect.params['visitorProbBonus'];
          if (raw is! Map) return 0;
          final scope = raw['scope'] as String?;
          final delta = (raw['delta'] as num?)?.toDouble() ?? 0;
          final matches = switch (scope) {
            'night' || 'nocturnal' => window == TimeWindow.night,
            'morning' => window == TimeWindow.day,
            'autumn' => season == Season.autumn,
            'rainy' => weather == Weather.rain,
            'snow_rabbit' => candidate.id == 'visitor_snowhare',
            'bird' => _isBirdVisitor(candidate.id),
            'seasonal' => true,
            _ => false,
          };
          return matches ? delta : 0;
        }
        return 0;
      },
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
      portableSave: portableSave,
      dispose: dispose,
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
  /// 随机 2 个不重复性格；变体优先从该物种未拥有集合中抽取。
  Pet adopt({required String speciesId, required String name}) {
    final sp = _content.speciesById(speciesId);
    final now = clock.now();
    final variants = sp?.variantIds ?? const <String>[];
    final unseenVariants = variants
        .where((variant) => !_session.ownedVariants.contains(variant))
        .toList(growable: false);
    final variantPool = unseenVariants.isNotEmpty ? unseenVariants : variants;
    final variantId = variantPool.isEmpty
        ? '${speciesId}_v1'
        : variantPool[(_rng() * variantPool.length).floor().clamp(
            0,
            variantPool.length - 1,
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
    _session.ownedVariants.add(variantId);
    _bumpSignal('custom:name_pet');
    final collectedVariants = variants
        .where(_session.ownedVariants.contains)
        .length;
    _setSignalMax('custom:collect_all_variants', collectedVariants);
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
    final newly = <Achievement>[];
    for (final achievement in _content.achievements) {
      final value = _achievementValue(achievement);
      newly.addAll(
        unlock.checkAchievements(
          GameSignal(
            achievement.condition.type.name,
            params: {'progress': value, 'achievementId': achievement.id},
          ),
        ),
      );
    }
    return newly;
  }

  int _achievementValue(Achievement achievement) {
    final s = _session;
    final params = achievement.condition.params;
    return switch (achievement.condition.type) {
      AchievementCondType.gradCount => s.yard.gradCount,
      AchievementCondType.speciesCollected => _speciesAchievementValue(params),
      AchievementCondType.postcardCount => s.postcards.length,
      AchievementCondType.visitorDexCount => _visitorAchievementValue(params),
      AchievementCondType.actionCount => _actionAchievementValue(params),
      AchievementCondType.revisitCount => s.revisitCount,
      AchievementCondType.loginStreak => s.settings.loginStreakCurrent,
      AchievementCondType.specialEventCount => s.specialEventCount,
      AchievementCondType.yardStage => s.yard.luxuryStage,
      AchievementCondType.themeCount => s.yard.ownedThemeIds.length,
      AchievementCondType.stampCount =>
        s.postcards.map((postcard) => postcard.stampId).toSet().length,
      AchievementCondType.seasonPostcard =>
        s.postcards.map((postcard) => postcard.season).toSet().length,
      AchievementCondType.unlockPet => _unlockPetAchievementValue(params),
      AchievementCondType.custom => _customAchievementValue(params),
    };
  }

  int _speciesAchievementValue(Map<String, dynamic> params) {
    final species = _session.ownedSpecies
        .map(_content.speciesById)
        .whereType<PetSpecies>();
    if (params['regularOnly'] == true) {
      return species.where((item) => item.category == PetCategory.real).length;
    }
    if (params['fantasyOnly'] == true) {
      return species
          .where((item) => item.category == PetCategory.fantasy)
          .length;
    }
    return species.length;
  }

  int _visitorAchievementValue(Map<String, dynamic> params) {
    final seen = _session.visitorLog.map((entry) => entry.visitorId).toSet();
    final rarityName = params['rarity'] as String?;
    if (rarityName != null) {
      return _content.visitors
          .where(
            (visitor) =>
                seen.contains(visitor.id) && visitor.rarity.name == rarityName,
          )
          .length;
    }
    return seen.length;
  }

  int _actionAchievementValue(Map<String, dynamic> params) {
    final actions = params['actions'];
    if (actions is List) {
      return actions.whereType<String>().where((action) {
        final key = action == 'play' ? 'play_toy' : action;
        return (_session.achievementSignals['action:$key'] ?? 0) > 0;
      }).length;
    }
    final action = params['action'] as String?;
    if (action == null) return _session.careActionCount;
    if (action == 'daily_care') {
      return _session.achievementSignals['care:days'] ?? 0;
    }
    return _session.achievementSignals['action:$action'] ?? 0;
  }

  int _customAchievementValue(Map<String, dynamic> params) {
    final action = params['action'] as String?;
    if (action == 'weather_postcard') {
      return _session.postcards
          .map((postcard) => postcard.weather)
          .toSet()
          .length;
    }
    return _session.achievementSignals['custom:$action'] ?? 0;
  }

  int _unlockPetAchievementValue(Map<String, dynamic> params) {
    if (params['regularOnly'] == true) {
      return _content.species
          .where((species) => species.category == PetCategory.real)
          .where(
            (species) => unlock.dexStateOf(species) != DexState.lockedKnown,
          )
          .length;
    }
    final name = params['petId'] as String?;
    if (name == null) return _session.ownedSpecies.length;
    final matches = _content.species.where((species) => species.name == name);
    return matches.any((species) => _session.ownedSpecies.contains(species.id))
        ? 1
        : 0;
  }

  void bumpAchievementSignal(String key, {int by = 1}) =>
      _bumpSignal(key, by: by);

  void _bumpSignal(String key, {int by = 1}) {
    _session.achievementSignals[key] =
        (_session.achievementSignals[key] ?? 0) + by;
  }

  void _setSignalMax(String key, int value) {
    final current = _session.achievementSignals[key] ?? 0;
    if (value > current) _session.achievementSignals[key] = value;
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
    // 回访：在院子驻留 1–2 天；到期后再安排下一次。
    final prev = _session.revisitor;
    final leavesAt = _session.revisitorLeavesAt;
    if (prev != null && leavesAt != null && !leavesAt.isAfter(now)) {
      revisit.onRevisitEnd(prev);
      _session.revisitor = null;
      _session.revisitorArrivedAt = null;
      _session.revisitorLeavesAt = null;
      _session.revisitorArrivalSeen = false;
      _session.revisitorInteracted = false;
    }
    if (_session.revisitor != null) return;
    final next = revisit.pickRevisitor(
      _session.roaming,
      now,
      hasCurrentRevisitor: _session.revisitor != null,
    );
    if (next != null) {
      _session.revisitor = next;
      _session.revisitorArrivedAt = now;
      final span =
          GameConfig.revisitStayMaxDays - GameConfig.revisitStayMinDays + 1;
      final stayDays = GameConfig.revisitStayMinDays + (_rng() * span).floor();
      _session.revisitorLeavesAt = now.add(Duration(days: stayDays));
      _session.revisitorArrivalSeen = false;
      _session.revisitorInteracted = false;
    }
  }

  RevisitInteractionOutcome? interactRevisitor(String petId) {
    final pet = _session.revisitor;
    if (pet == null || pet.id != petId || _session.revisitorInteracted) {
      return null;
    }
    final broughtCompanion = revisit.onRevisitInteract(pet, _session.current);
    if (broughtCompanion) _bumpSignal('custom:companion_joined');
    final giftSpan = GameConfig.revisitGiftMax - GameConfig.revisitGiftMin + 1;
    final gift = GameConfig.revisitGiftMin + (_rng() * giftSpan).floor();
    economy.earn(
      gift,
      CurrencyReason.revisitGift,
      ref: 'revisit:${pet.id}:${_dayKey(clock.now())}',
    );
    _bumpSignal('custom:revisit_gift_received');
    _session.revisitCount++;
    _session.revisitorInteracted = true;
    return RevisitInteractionOutcome(
      gift: gift,
      broughtCompanion: broughtCompanion,
      currentPetExp: _session.current == null ? 0 : GameConfig.revisitPetExp,
    );
  }

  List<String> _pickTwoPersonalities() {
    final ids = _content.personalities.map((p) => p.id).toList();
    if (ids.length < 2) return ids;
    final i = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    var j = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    if (j == i) j = (i + 1) % ids.length;
    return [ids[i], ids[j]];
  }

  static String _dayKey(DateTime t) {
    final local = t.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

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
        final weather = weatherAt(job.dueAt);
        final season = _seasonOf(job.dueAt);
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
        final dailies = _eligibleEvents(EventType.daily, pet, now);
        if (dailies.isNotEmpty) {
          final ev = _pickWeightedEvent(dailies, pet, job.dueAt);
          _session.eventLastFiredAt['${pet.id}:${ev.id}'] = now;
          _queueEvent(ev, pet, now);
        }
      case JobType.specialEventEval:
        if (pet == null) break;
        // 眷顾资格的彩蛋事件：满足等级/豪华度门槛，oncePerPet 未触发过。
        final eligible = _eligibleEvents(EventType.special, pet, now).where((
          e,
        ) {
          if (e.oncePerPet &&
              _session.firedSpecials.contains('${pet.id}:${e.id}')) {
            return false;
          }
          return true;
        }).toList();
        if (eligible.isEmpty) break;
        if (_rng() >= _specialEventChance) break; // 低频彩蛋（日 cap=1）
        final ev = _pickWeightedEvent(eligible, pet, job.dueAt);
        if (ev.oncePerPet) _session.firedSpecials.add('${pet.id}:${ev.id}');
        _session.eventLastFiredAt['${pet.id}:${ev.id}'] = now;
        _queueEvent(ev, pet, now);
      case JobType.revisitDue:
      case JobType.postcardDue:
        break; // 漫游宠的明信片/回访不走 scheduler，由 processRoaming 驱动
    }
  }

  /// 彩蛋事件单次评估触发概率（日 cap=1，见 GameConfig.specialEventDailyCap）。
  static const double _specialEventChance = 0.25;

  List<Event> _eligibleEvents(EventType type, Pet pet, DateTime now) {
    final weather = weatherAt(now);
    final timeOfDay = _timeOfDay(now.toLocal().hour);
    final season = _seasonOf(now);
    final ageDays = now.difference(pet.bornAt).inDays;
    return _content.events.where((event) {
      if (event.type != type) return false;
      final weights = event.weights;
      if (weights.minLevel != null && pet.level < weights.minLevel!) {
        return false;
      }
      if (weights.minLuxuryStage != null &&
          _session.yard.luxuryStage < weights.minLuxuryStage!) {
        return false;
      }
      if (weights.minAgeDays != null && ageDays < weights.minAgeDays!) {
        return false;
      }
      if (weights.requiredWeather.isNotEmpty &&
          !weights.requiredWeather.contains(weather)) {
        return false;
      }
      if (weights.requiredTimeOfDay.isNotEmpty &&
          !weights.requiredTimeOfDay.contains(timeOfDay)) {
        return false;
      }
      if (weights.requiredSeason.isNotEmpty &&
          !weights.requiredSeason.contains(season)) {
        return false;
      }
      if (weights.requiresVisitor != null &&
          _session.activeVisitor?.visitorId != weights.requiresVisitor) {
        return false;
      }
      if (weights.requiresDecor != null &&
          !_session.yard.activeDecorIds.contains(weights.requiresDecor)) {
        return false;
      }
      final last = _session.eventLastFiredAt['${pet.id}:${event.id}'];
      if (last != null) {
        final localNow = now.toLocal();
        final localLast = last.toLocal();
        final today = DateTime(localNow.year, localNow.month, localNow.day);
        final lastDay = DateTime(
          localLast.year,
          localLast.month,
          localLast.day,
        );
        if (today.difference(lastDay).inDays <= event.cooldownDays) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Event _pickWeightedEvent(List<Event> events, Pet pet, DateTime now) {
    final season = _seasonOf(now);
    final time = _timeOfDay(now.hour);
    final weather = weatherAt(now);
    final weighted = <MapEntry<Event, double>>[];
    var total = 0.0;
    for (final event in events) {
      var weight = 1.0;
      for (final personality in pet.personality) {
        weight *= event.weights.personality[personality] ?? 1.0;
      }
      weight *= event.weights.weather[weather] ?? 1.0;
      weight *= event.weights.timeOfDay[time] ?? 1.0;
      weight *= event.weights.season[season] ?? 1.0;
      if (weight <= 0) continue;
      total += weight;
      weighted.add(MapEntry(event, weight));
    }
    if (weighted.isEmpty || total <= 0) return events.first;
    final roll = _rng() * total;
    var cursor = 0.0;
    for (final entry in weighted) {
      cursor += entry.value;
      if (roll < cursor) return entry.key;
    }
    return weighted.last.key;
  }

  void _queueEvent(Event event, Pet pet, DateTime now) {
    _session.pendingEvents.add(
      PendingGameEvent(
        id: _idGen(),
        eventId: event.id,
        petId: pet.id,
        title: event.title,
        script: event.script,
        type: event.type,
        expReward: event.expReward,
        currencyReward: event.currencyReward ?? 0,
        animRef: event.animRef,
        illustrationRef: event.illustrationRef,
        choices: event.choices
            ?.map(
              (choice) => PendingEventChoice(
                text: choice.text,
                resultScript: choice.resultScript,
                expDelta: choice.expDelta,
              ),
            )
            .toList(growable: false),
        createdAt: now,
      ),
    );
    if (_session.pendingEvents.length > 6) {
      _session.pendingEvents.removeRange(0, _session.pendingEvents.length - 6);
    }
  }

  EventResolution? resolveEvent(String pendingId, {int? choiceIndex}) {
    final matches = _session.pendingEvents.where(
      (item) => item.id == pendingId,
    );
    if (matches.isEmpty) return null;
    final pending = matches.first;
    PendingEventChoice? choice;
    if (choiceIndex != null &&
        choiceIndex >= 0 &&
        choiceIndex < pending.choices.length) {
      choice = pending.choices[choiceIndex];
    }
    var expApplied = 0;
    if (!pending.rewardSettled) {
      Pet? pet;
      for (final candidate in _session.allPets) {
        if (candidate.id == pending.petId) {
          pet = candidate;
          break;
        }
      }
      pet ??= _session.current;
      if (pet != null) {
        final amount = pending.expReward + (choice?.expDelta ?? 0);
        final result = exp.addExp(
          pet: pet,
          baseDelta: amount,
          source: pending.type == EventType.special
              ? ExpSource.eventSpecial
              : ExpSource.eventDaily,
          sourceRef: pending.eventId,
          note: choice?.resultScript ?? pending.script,
          applyPersonalityBonus: false,
        );
        expApplied = result.deltaApplied;
        _session.eventCounts[pet.id] = (_session.eventCounts[pet.id] ?? 0) + 1;
      }
      if (pending.currencyReward > 0) {
        economy.earn(
          pending.currencyReward,
          CurrencyReason.eventReward,
          ref: 'evt:${pending.petId}:${pending.eventId}',
        );
      }
      if (pending.type == EventType.special) _session.specialEventCount++;
      if (choice != null) _bumpSignal('custom:branch_choice');
      pending.rewardSettled = true;
    }
    _session.pendingEvents.remove(pending);
    return EventResolution(
      expApplied: expApplied,
      currencyApplied: pending.currencyReward,
      resultScript: choice?.resultScript,
    );
  }

  VisitorInteractionOutcome? interactActiveVisitor(String visitorId) {
    final active = _session.activeVisitor;
    if (active == null || active.visitorId != visitorId || active.interacted) {
      return null;
    }
    final candidate = _content.visitorById(visitorId);
    if (candidate == null) return null;
    final pet = _session.current;
    final interaction =
        _interactionById(active.interactionId) ??
        visitor.pickInteraction(candidate, pet);
    var expApplied = 0;
    if (pet != null) {
      expApplied = exp
          .addExp(
            pet: pet,
            baseDelta: interaction.expReward,
            source: ExpSource.visitor,
            sourceRef: candidate.id,
            note: interaction.script,
            applyPersonalityBonus: false,
          )
          .deltaApplied;
    }
    visitor.recordVisit(candidate, pet, interaction);
    active
      ..interactionId = interaction.id
      ..withPetId = pet?.id
      ..interacted = true;
    _consumeVisitorFood();
    return VisitorInteractionOutcome(
      message: interaction.script,
      expApplied: expApplied,
      animRef: interaction.animRef,
    );
  }

  VisitorPetInteraction? _interactionById(String? id) {
    if (id == null) return null;
    for (final interaction in _content.visitorInteractions) {
      if (interaction.id == id) return interaction;
    }
    return null;
  }

  Weather weatherAt(DateTime time) {
    final local = time.toLocal();
    final seed = local.year * 372 + local.month * 31 + local.day;
    final roll = seed.abs() % 100;
    return switch (_seasonOf(time)) {
      Season.spring =>
        roll < 18
            ? Weather.rain
            : roll < 23
            ? Weather.rainbow
            : roll < 43
            ? Weather.cloudy
            : Weather.clear,
      Season.summer =>
        roll < 10
            ? Weather.thunder
            : roll < 24
            ? Weather.rain
            : roll < 39
            ? Weather.cloudy
            : Weather.clear,
      Season.autumn =>
        roll < 15
            ? Weather.fog
            : roll < 31
            ? Weather.rain
            : roll < 51
            ? Weather.cloudy
            : Weather.clear,
      Season.winter =>
        roll < 21
            ? Weather.snow
            : roll < 34
            ? Weather.fog
            : roll < 57
            ? Weather.cloudy
            : Weather.clear,
    };
  }

  TimeOfDayOfDay _timeOfDay(int hour) {
    if (hour < 6) return TimeOfDayOfDay.night;
    if (hour < 9) return TimeOfDayOfDay.dawn;
    if (hour < 12) return TimeOfDayOfDay.morning;
    if (hour < 14) return TimeOfDayOfDay.noon;
    if (hour < 18) return TimeOfDayOfDay.afternoon;
    if (hour < 21) return TimeOfDayOfDay.evening;
    return TimeOfDayOfDay.night;
  }

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

  void _consumeVisitorFood() {
    final inventory = _session.shopInventory;
    final itemId = inventory.activeVisitorFoodItemId;
    if (itemId == null) return;
    final remaining = (inventory.consumables[itemId] ?? 0) - 1;
    if (remaining > 0) {
      inventory.consumables[itemId] = remaining;
      _session.yard.foodTray.remaining = remaining;
      return;
    }
    inventory.consumables.remove(itemId);
    inventory.activeVisitorFoodItemId = null;
    _session.yard.foodTray
      ..foodType = null
      ..placedAt = null
      ..probabilityScope = null
      ..probabilityDelta = 0
      ..remaining = 0;
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

bool _isBirdVisitor(String visitorId) => const {
  'visitor_sparrow',
  'visitor_pigeon',
  'visitor_crow',
  'visitor_owl',
  'visitor_egret',
}.contains(visitorId);
