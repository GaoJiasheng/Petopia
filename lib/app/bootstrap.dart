import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../config/game_config.dart';
import '../data/audit_log_port_adapter.dart';
import '../data/content/content_repository_impl.dart';
import '../data/save/save_service_impl.dart';
import '../data/save/session_store.dart';
import '../data/sqlite/petopia_sqlite_dao.dart';
import '../domain/enums.dart';
import '../services/clock_service_impl.dart';
import '../services/audit_service_impl.dart';
import 'game_services.dart';
import 'game_state.dart';

/// 启动编排：加载存档 → 开库 → 加载内容 → 装配服务 → 首日调度。
/// 首次启动保持空宠位，由院子 CTA 进入正式领养和命名流程。
Future<GameServices> bootstrapGame() async {
  final store = await SessionStore.create();
  final restored = await store.load();

  final content = AssetContentRepository();
  await content.loadAll();

  final dao = await PetopiaSqliteDao.open();

  final session = restored ?? GameSession();
  final now = DateTime.now().toUtc();
  final rng = Random();
  final uuid = const Uuid();

  _advanceLoginStreak(session, now);

  final clock = ClockServiceImpl(SystemClock(), session.settings);
  final logPort = DaoAuditLogPort(dao);
  final snapshotStore = SessionSaveSnapshotStore(
    sessionStore: store,
    dao: dao,
    currentSession: () => session,
  );
  final auditService = AuditServiceImpl(
    logPort,
    () => snapshotStore.activeSession.allPets,
    () => snapshotStore.activeSession.wallet,
  );
  final startupAudit = await auditService.verifyOnStartup();
  if (!startupAudit.ok) {
    await store.save(session);
  }
  final portableSave = await LocalSaveService.create(
    snapshotStore: snapshotStore,
    auditService: auditService,
    clock: clock,
  );
  final svc = GameServices.wire(
    session: session,
    port: logPort,
    content: content,
    clock: clock,
    rng: rng.nextDouble,
    idGen: uuid.v4,
    ownerName: '主人',
    postcardTemplates: content.postcardTemplates,
    encounters: content.encounters,
    incidents: content.incidents,
    expLogReader: dao.expLogsForPet,
    store: store,
    portableSave: portableSave,
    dispose: dao.close,
  );

  final current = session.current;
  if (current != null) {
    final elapsed = clock.resolveOfflineElapsed(
      lastOnlineAt: current.lastOnlineAt,
    );
    final before = current.level;
    final offline = svc.exp.grantOffline(pet: current, elapsed: elapsed);
    svc.startupOfflineElapsed = elapsed;
    svc.startupOfflineExp = offline.deltaApplied;
    for (var level = before + 1; level <= current.level; level++) {
      svc.economy.earn(
        GameConfig.levelUpFluff,
        CurrencyReason.levelUp,
        ref: 'levelup:${current.id}:$level',
      );
    }
  }
  clock.markHeartbeat();
  await svc.scheduler.onDailyTick(clock.now());
  await svc.scheduler.onResume(clock.now());
  await svc.processRoaming(clock.now()); // 漫游宠寄明信片 + 回访
  final newlyUnlocked = svc.syncAchievements();
  for (final achievement in newlyUnlocked) {
    svc.unlock.claimReward(achievement.id);
  }
  await store.save(session);
  return svc;
}

String _dayKey(DateTime t) {
  final local = t.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

void _advanceLoginStreak(GameSession session, DateTime now) {
  final today = _dayKey(now);
  final settings = session.settings;
  if (settings.lastLoginDay == today) return;

  var nextStreak = 1;
  final lastDay = DateTime.tryParse(settings.lastLoginDay);
  if (lastDay != null) {
    final localNow = now.toLocal();
    final currentDay = DateTime(localNow.year, localNow.month, localNow.day);
    if (currentDay.difference(lastDay).inDays == 1) {
      nextStreak = settings.loginStreakCurrent + 1;
    }
  }
  settings.loginStreakCurrent = nextStreak;
  if (nextStreak > settings.loginStreakMax) {
    settings.loginStreakMax = nextStreak;
  }
  settings.lastLoginDay = today;
}

/// 全局：启动后的 GameServices（异步）。
final gameProvider = FutureProvider<GameServices>((ref) => bootstrapGame());
