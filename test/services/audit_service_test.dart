import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/services/audit_service_impl.dart';
import 'package:petopia/services/log_port.dart';

/// 内存假端口：流水存 list，sum 现算。
class FakeLogPort implements AuditLogPort {
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

Pet _pet(String id, int exp) => Pet(
      id: id,
      speciesId: 'pet_cat',
      variantId: 'v1',
      name: 'x',
      personality: const ['p_curious', 'p_gentle'],
      bornAt: DateTime.utc(2026, 7, 2),
      lastOnlineAt: DateTime.utc(2026, 7, 2),
      offlineDayKey: '2026-07-02',
    )..exp = exp;

ExpLogEntry _exp(String petId, int delta) => ExpLogEntry(
      id: 'e', petId: petId, timestamp: DateTime.utc(2026, 7, 2),
      sourceType: ExpSource.feed, delta: delta, levelAt: 1, expAfter: delta);

CurrencyLog _cur(int delta) => CurrencyLog(
      id: 'c', timestamp: DateTime.utc(2026, 7, 2), delta: delta,
      reason: CurrencyReason.graduation, balanceAfter: delta);

void main() {
  test('一致时 ok=true，不改动', () async {
    final port = FakeLogPort()..exp.addAll([_exp('p1', 30), _exp('p1', 45)]);
    final pet = _pet('p1', 75);
    final wallet = CurrencyWallet(balance: 0);
    final svc = AuditServiceImpl(port, () => [pet], () => wallet);
    final r = await svc.verifyOnStartup();
    expect(r.ok, true);
    expect(pet.exp, 75);
  });

  test('exp 与流水不一致 → 以流水回正 + 重算等级', () async {
    // 流水和=210（→Lv5），但 pet.exp 被污染为 999
    final port = FakeLogPort()..exp.addAll([_exp('p1', 210)]);
    final pet = _pet('p1', 999)
      ..level = 10
      ..stage = PetStage.d;
    final svc = AuditServiceImpl(port, () => [pet], () => CurrencyWallet());
    final r = await svc.verifyOnStartup();
    expect(r.ok, false);
    expect(pet.exp, 210); // 回正为流水和
    expect(pet.level, 5); // 重算
    expect(pet.stage, PetStage.b);
  });

  test('wallet 与流水不一致 → 回正', () async {
    final port = FakeLogPort()..cur.addAll([_cur(200), _cur(-80)]); // Σ=120
    final wallet = CurrencyWallet(balance: 500);
    final svc = AuditServiceImpl(port, () => <Pet>[], () => wallet);
    final r = await svc.verifyOnStartup();
    expect(r.ok, false);
    expect(wallet.balance, 120);
  });

  test('append 只追加，不改已有', () async {
    final port = FakeLogPort();
    final svc = AuditServiceImpl(port, () => <Pet>[], () => CurrencyWallet());
    await svc.appendExpLog(_exp('p1', 5));
    await svc.appendCurrencyLog(_cur(10));
    expect(port.exp.length, 1);
    expect(port.cur.length, 1);
  });
}
