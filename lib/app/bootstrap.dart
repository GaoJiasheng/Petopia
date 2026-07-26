import 'dart:math';

import 'package:flutter/foundation.dart';
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
import '../services/local_calendar.dart';
import '../services/postcard_content_alignment.dart';
import 'game_services.dart';
import 'game_state.dart';

/// 启动编排：加载存档 → 开库 → 加载内容 → 装配服务 → 首日调度。
/// 首次启动保持空宠位，由院子 CTA 进入正式领养和命名流程。
Future<GameServices> bootstrapGame() async {
  final content = AssetContentRepository();
  final storeFuture = SessionStore.create();
  final contentFuture = content.loadAll();
  final daoFuture = PetopiaSqliteDao.open();
  final store = await storeFuture;
  final restoredFuture = store.load();
  final restored = await restoredFuture;
  await contentFuture;
  final dao = await daoFuture;

  var session = restored ?? GameSession();
  String? startupRecoveryReason =
      store.lastLoadSource == SessionLoadSource.backup
      ? '主存档无法读取，已从本地安全备份恢复。'
      : null;
  final now = DateTime.now().toUtc();
  final rng = Random();
  final uuid = const Uuid();

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
  final portableSave = await LocalSaveService.create(
    snapshotStore: snapshotStore,
    auditService: auditService,
    now: () => DateTime.now().toUtc(),
  );

  Future<bool> tryPortableRecovery(String reason) async {
    try {
      await portableSave.load();
      final recovered = snapshotStore.recoveredSession;
      if (recovered == null) return false;
      session = recovered;
      startupRecoveryReason = reason == 'primary audit mismatch'
          ? '存档校验发现异常，已从最近的完整快照恢复。'
          : '主存档缺失，已从最近的完整快照恢复。';
      return true;
    } on Object catch (error, stackTrace) {
      debugPrint(
        'Portable startup recovery unavailable ($reason): '
        '$error\n$stackTrace',
      );
      return false;
    }
  }

  // The primary JSON and its .bak remain authoritative. If neither exists,
  // restore the newest checksummed A/B snapshot before creating a new yard.
  if (restored == null) {
    await tryPortableRecovery('primary session missing');
  }

  var startupAudit = await auditService.verifyOnStartup();
  if (!startupAudit.ok &&
      restored != null &&
      await tryPortableRecovery('primary audit mismatch')) {
    startupAudit = await auditService.verifyOnStartup();
  }
  if (!startupAudit.ok) {
    await store.save(session);
  }

  const ownerName = '主人';
  final repairedPostcards = repairMisalignedPostcards(
    postcards: session.postcards,
    pets: session.allPets,
    locations: {
      for (final location in content.locations) location.id: location,
    },
    templates: content.postcardTemplates,
    encounters: content.encounters,
    incidents: content.incidents,
    ownerName: ownerName,
  );
  if (repairedPostcards > 0) {
    debugPrint(
      'Repaired $repairedPostcards postcard content alignment issue(s).',
    );
  }

  _advanceLoginStreak(session, now);
  final clock = ClockServiceImpl(SystemClock(), session.settings);
  final svc = GameServices.wire(
    session: session,
    port: logPort,
    content: content,
    clock: clock,
    rng: rng.nextDouble,
    idGen: uuid.v4,
    ownerName: ownerName,
    postcardTemplates: content.postcardTemplates,
    encounters: content.encounters,
    incidents: content.incidents,
    expLogReader: dao.expLogsForPet,
    store: store,
    portableSave: portableSave,
    dispose: dao.close,
  );
  svc.startupRecoveryReason = startupRecoveryReason;

  final current = session.current;
  if (current != null) {
    final elapsed = clock.resolveOfflineElapsed(
      lastOnlineAt: current.lastOnlineAt,
    );
    final before = current.level;
    final offline = svc.exp.grantOffline(pet: current, elapsed: elapsed);
    svc.recordGrowthMemories(current, before, current.level);
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

void _advanceLoginStreak(GameSession session, DateTime now) {
  final today = LocalCalendar.dayKey(now);
  final settings = session.settings;
  if (settings.lastLoginDay == today) return;

  var nextStreak = 1;
  final lastDay = DateTime.tryParse(settings.lastLoginDay);
  if (lastDay != null) {
    final currentDay = LocalCalendar.date(now);
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
