import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/services/audit_service_impl.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/economy_service_impl.dart';
import 'package:petopia/services/exp_engine_impl.dart';
import 'package:petopia/services/graduation_service_impl.dart';
import 'package:petopia/services/log_port.dart';

/// 内存流水端口：exp/currency 同一账本，供 INV-1/INV-4 校验。
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
  DateTime t;
  FixedClock(this.t);
  @override
  DateTime now() => t;
  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) => Duration.zero;
  @override
  void markHeartbeat() {}
}

Location _loc(String id) => Location(
    id: id, name: id, category: 'x', climate: 'x', vibeTags: const [],
    photoStyle: 'x', encounterPoolId: 'x', personalityWeight: const {}, stampId: 'x');

void main() {
  test('全链路冒烟：领养→照料→离线→升级换档→毕业，INV-1/INV-4 恒成立', () async {
    // ── 装配（真实服务实现 + 内存桩）──
    final t0 = DateTime.utc(2026, 7, 3, 8);
    final clock = FixedClock(t0);
    final port = MemPort();
    var idc = 0;
    String id() => 'id${idc++}';

    final pet = Pet(
      id: 'pet1', speciesId: 'pet_cat', variantId: 'pet_cat_v1', name: '阿橘',
      personality: const ['p_glutton', 'p_curious'],
      bornAt: t0, lastOnlineAt: t0, offlineDayKey: '2026-07-03',
    );
    final pets = [pet];
    final wallet = CurrencyWallet();
    final yard = YardState();

    final audit = AuditServiceImpl(port, () => pets, () => wallet);
    final exp = ExpEngineImpl(
      audit, clock,
      (tag, src) => tag == 'p_glutton' && src == ExpSource.feed ? 0.10 : 0.0,
      id,
    );
    final economy = EconomyServiceImpl(
      port, wallet, yard, clock, id,
      (_) => 10, (_) => 5, (_) => false, // 事件10/访客5/非彩蛋
    );
    Journey? journey;
    final grad = GraduationServiceImpl(
      economy, [_loc('a'), _loc('b'), _loc('c'), _loc('d'), _loc('e')],
      yard, id, () => clock.now(), () => 0.0, (j) => journey = j,
    );

    Future<void> checkInv() async {
      expect(pet.exp, await port.sumExp('pet1'), reason: 'INV-1');
      expect(wallet.balance, await port.sumCurrency(), reason: 'INV-4');
    }

    // ── 一局 ──
    // 每日首次照料给暖绒
    economy.earn(5, CurrencyReason.dailyFirstCare, ref: 'daily:2026-07-03');
    // 喂食几次（贪吃 +10%，但小值 floor 无加成）
    exp.addExp(pet: pet, baseDelta: 3, source: ExpSource.feed);
    exp.addExp(pet: pet, baseDelta: 3, source: ExpSource.feed);
    await checkInv();

    // 事件推到 Lv5（换档 B）
    final r5 = exp.addExp(pet: pet, baseDelta: 204, source: ExpSource.eventDaily);
    expect(pet.level, 5);
    expect(pet.stage, PetStage.b);
    expect(r5.evolved, true);

    // 离线 12h（+12，renew）
    exp.grantOffline(pet: pet, elapsed: const Duration(hours: 12));
    expect(pet.offlineExpGrantedToday, 12);
    await checkInv();

    // 补到 Lv10 毕业
    final need = 800 - pet.exp;
    final rGrad = exp.addExp(pet: pet, baseDelta: need, source: ExpSource.eventDaily);
    expect(pet.level, 10);
    expect(pet.stage, PetStage.d);
    expect(rGrad.graduated, true);

    // 毕业编排
    final jid = await grad.graduate(pet);
    expect(pet.state, PetState.traveling);
    expect(pet.journeyId, jid);
    expect(journey!.stops.length, 5);
    expect(yard.gradCount, 1);
    expect(yard.luxuryStage, 2);
    // 毕业结算：base200 + min(10*2,100)=20 + min(5*3,60)=15 = 235
    expect(wallet.balance, 5 + 235);
    await checkInv();

    // 启动审计校验（无损坏）通过
    final report = await audit.verifyOnStartup();
    expect(report.ok, true);
  });
}
