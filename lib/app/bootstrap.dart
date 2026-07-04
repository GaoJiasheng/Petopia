import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/audit_log_port_adapter.dart';
import '../data/content/content_repository_impl.dart';
import '../data/save/session_store.dart';
import '../data/sqlite/petopia_sqlite_dao.dart';
import '../domain/models/pet.dart';
import '../services/clock_service_impl.dart';
import 'game_services.dart';
import 'game_state.dart';

const _personalityIds = [
  'p_glutton',
  'p_lazy',
  'p_curious',
  'p_timid',
  'p_energetic',
  'p_clingy',
  'p_aloof',
  'p_naughty',
  'p_gentle',
  'p_dreamy',
];

/// 启动编排：加载存档 → 开库 → 加载内容 → 装配服务 → 首日调度。
/// 首启暂领养一只默认橘猫（正式领养流程 UI 后续做）。
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

  if (restored == null) {
    final tags = List<String>.from(_personalityIds)..shuffle(rng);
    session.current = Pet(
      id: uuid.v4(),
      speciesId: 'pet_cat',
      variantId: 'pet_cat_v1',
      name: '阿橘',
      personality: tags.take(2).toList(),
      bornAt: now,
      lastOnlineAt: now,
      offlineDayKey: _dayKey(now),
    );
    session.ownedSpecies.add('pet_cat');
  }
  _advanceLoginStreak(session, now);

  final clock = ClockServiceImpl(SystemClock(), session.settings);
  final svc = GameServices.wire(
    session: session,
    port: DaoAuditLogPort(dao),
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
  );

  clock.markHeartbeat();
  await svc.scheduler.onDailyTick(clock.now());
  await svc.scheduler.onResume(clock.now());
  await svc.processRoaming(clock.now()); // 漫游宠寄明信片 + 回访
  svc.syncAchievements(); // 后台日切进度并入成就
  await store.save(session);
  return svc;
}

String _dayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

void _advanceLoginStreak(GameSession session, DateTime now) {
  final today = _dayKey(now);
  final settings = session.settings;
  if (settings.lastLoginDay == today) return;

  var nextStreak = 1;
  final lastDay = DateTime.tryParse('${settings.lastLoginDay}T00:00:00Z');
  if (lastDay != null) {
    final currentDay = DateTime.utc(now.year, now.month, now.day);
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
