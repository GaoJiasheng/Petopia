import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/audit_log_port_adapter.dart';
import '../data/content/content_repository_impl.dart';
import '../data/sqlite/petopia_sqlite_dao.dart';
import '../domain/models/pet.dart';
import '../services/clock_service_impl.dart';
import 'game_services.dart';
import 'game_state.dart';

const _personalityIds = [
  'p_glutton', 'p_lazy', 'p_curious', 'p_timid', 'p_energetic',
  'p_clingy', 'p_aloof', 'p_naughty', 'p_gentle', 'p_dreamy',
];

/// 启动编排：开库 → 加载内容 → 装配服务 → 首日调度。
/// 首启暂领养一只默认橘猫（正式领养流程 UI 后续做）；存档 load/save 为 `[待细化]`。
Future<GameServices> bootstrapGame() async {
  final content = AssetContentRepository();
  await content.loadAll();

  final dao = await PetopiaSqliteDao.open();

  final session = GameSession();
  final now = DateTime.now().toUtc();
  final rng = Random();
  final uuid = const Uuid();

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
  );

  clock.markHeartbeat();
  await svc.scheduler.onDailyTick(clock.now());
  await svc.scheduler.onResume(clock.now());
  await svc.processRoaming(clock.now()); // 漫游宠寄明信片 + 回访
  return svc;
}

String _dayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// 全局：启动后的 GameServices（异步）。
final gameProvider = FutureProvider<GameServices>((ref) => bootstrapGame());
