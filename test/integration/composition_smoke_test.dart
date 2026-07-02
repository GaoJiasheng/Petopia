import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/log_port.dart';

class MemPort implements AuditLogPort {
  final List<ExpLogEntry> exp = [];
  final List<CurrencyLog> cur = [];
  @override
  Future<void> insertExp(ExpLogEntry e) async => exp.add(e);
  @override
  Future<void> insertCurrency(CurrencyLog e) async => cur.add(e);
  @override
  Future<int> sumExp(String petId) async =>
      exp.where((e) => e.petId == petId).fold<int>(0, (a, e) => a + e.delta);
  @override
  Future<int> sumCurrency() async => cur.fold<int>(0, (a, e) => a + e.delta);
}

class FixedClock implements ClockService {
  final DateTime t;
  FixedClock(this.t);
  @override
  DateTime now() => t;
  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) => Duration.zero;
  @override
  void markHeartbeat() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('组合根装配 + 一日 tick 跑通，INV-1 恒成立', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    expect(content.species.length, 12); // 内容加载 sanity
    expect(content.visitorInteractions.isNotEmpty, true); // 访客互动已入库

    final session = GameSession();
    session.current = Pet(
      id: 'pet1', speciesId: 'pet_cat', variantId: 'pet_cat_v1', name: '阿橘',
      personality: const ['p_glutton', 'p_curious'],
      bornAt: DateTime.utc(2026, 7, 3), lastOnlineAt: DateTime.utc(2026, 7, 3),
      offlineDayKey: '2026-07-03',
    );

    final port = MemPort();
    final t0 = DateTime.utc(2026, 7, 3, 8);
    var i = 0;
    final svc = GameServices.wire(
      session: session,
      port: port,
      content: content,
      clock: FixedClock(t0),
      rng: () => 0.3,
      idGen: () => 'id${i++}',
      ownerName: '小明',
    );

    await svc.scheduler.onDailyTick(t0);
    expect(session.jobs.isNotEmpty, true); // 有 job 被补种
    await svc.scheduler.onResume(t0);
    expect(session.jobs.every((j) => j.consumed), true); // 全处理

    // 至此可能通过日常事件/访客给了经验；INV-1 必须恒成立
    expect(session.current!.exp, await port.sumExp('pet1'), reason: 'INV-1');
  });
}
