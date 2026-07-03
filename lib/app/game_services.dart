// 私有构造用私有字段，无法用 this._x 初始化形参，故豁免该 lint。
// ignore_for_file: prefer_initializing_formals
import '../domain/enums.dart';
import '../domain/models/game_state.dart';
import '../domain/models/postcard_content.dart';
import '../data/content/content_repository.dart';
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
  final ContentRepository _content;
  final double Function() _rng;

  /// 当前游戏状态（UI 读取）。
  GameSession get session => _session;
  ContentRepository get content => _content;

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
    required ContentRepository content,
    required double Function() rng,
  })  : _session = session,
        _content = content,
        _rng = rng;

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
  }) {
    final audit = AuditServiceImpl(port, () => session.allPets, () => session.wallet);

    final exp = ExpEngineImpl(
      audit,
      clock,
      (tag, src) => content.personalityById(tag)?.actionExpBonus[src] ?? 0.0,
      idGen,
    );

    final economy = EconomyServiceImpl(
      port, session.wallet, session.yard, clock, idGen,
      (petId) => session.eventCounts[petId] ?? 0,
      (petId) => session.visitorCounts[petId] ?? 0,
      (sp) => content.speciesById(sp)?.category == PetCategory.fantasy,
    );

    final unlock = UnlockServiceImpl(
      content.achievements, session.yard, session.clues, session.achievements,
      session.ownedSpecies.contains, economy, () => clock.now(),
    );

    final visitor = VisitorServiceImpl(
      content.visitors, content.visitorInteractions, rng, idGen, () => clock.now(),
      (log) {
        session.visitorLog.add(log);
        final id = log.withPetId;
        if (id != null) session.visitorCounts[id] = (session.visitorCounts[id] ?? 0) + 1;
      },
      (clueId) => unlock.bumpClue(clueId),
    );

    final graduation = GraduationServiceImpl(
      economy, content.locations, session.yard, idGen, () => clock.now(), rng,
      (j) => session.journeys.add(j),
    );

    final revisit = RevisitServiceImpl(exp, rng, () => clock.now());

    final postcard = PostcardGeneratorImpl(
      locations: {for (final l in content.locations) l.id: l},
      templates: postcardTemplates, encounters: encounters, incidents: incidents,
      rng: rng, now: () => clock.now(), idGen: idGen, ownerName: ownerName,
      onPostcard: (_) {}, // [待细化] 持久化到 DAO postcard 表
    );

    late GameServices svc;
    final scheduler = EventSchedulerImpl(
      session.jobs, session.generatedDays, idGen, rng, (job) => svc._dispatch(job),
    );

    svc = GameServices._(
      clock: clock, audit: audit, exp: exp, economy: economy, unlock: unlock,
      visitor: visitor, graduation: graduation, revisit: revisit, postcard: postcard,
      scheduler: scheduler, session: session, content: content, rng: rng,
    );
    return svc;
  }

  /// EventScheduler 单个 job 的执行路由（§3.4）。
  Future<void> _dispatch(ScheduledJob job) async {
    final pet = _session.current;
    final now = clock.now();
    switch (job.type) {
      case JobType.visitorCheck:
        final window = job.payloadRef == 'night' ? TimeWindow.night : TimeWindow.day;
        const weather = Weather.clear; // [待细化] 天气系统
        final season = _seasonOf(now);
        var v = visitor.rollWindow(
            window: window, yard: _session.yard, weather: weather, season: season, now: now);
        v ??= (window == TimeWindow.night)
            ? visitor.rollLegendary(
                yard: _session.yard, weather: weather, season: season, now: now)
            : null;
        if (v != null) {
          final it = visitor.pickInteraction(v, pet);
          if (pet != null) {
            exp.addExp(
                pet: pet, baseDelta: it.expReward, source: ExpSource.visitor,
                sourceRef: v.id, note: it.script);
          }
          visitor.recordVisit(v, pet, it);
        }
      case JobType.dailyEventGen:
        if (pet == null) break;
        final dailies =
            _content.events.where((e) => e.type == EventType.daily).toList();
        if (dailies.isNotEmpty) {
          final ev = dailies[(_rng() * dailies.length).floor()];
          exp.addExp(
              pet: pet, baseDelta: ev.expReward, source: ExpSource.eventDaily,
              sourceRef: ev.id);
          _session.eventCounts[pet.id] = (_session.eventCounts[pet.id] ?? 0) + 1;
        }
      case JobType.specialEventEval:
      case JobType.revisitDue:
      case JobType.postcardDue:
        break; // [待细化] 特殊事件 / 回访 / 明信片 调度接线
    }
  }

  Season _seasonOf(DateTime t) {
    final m = t.month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }
}
