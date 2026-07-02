import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/services/audit_service.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/exp_engine_impl.dart';

/// 记录型假审计：存所有 ExpLogEntry，便于校验 INV-1。
class FakeAudit implements AuditService {
  final List<ExpLogEntry> expLogs = [];
  @override
  Future<void> appendExpLog(ExpLogEntry e) async => expLogs.add(e);
  @override
  Future<void> appendCurrencyLog(e) async {}
  @override
  Future<AuditReport> verifyOnStartup() async => const AuditReport(ok: true);
  int sumFor(String petId) =>
      expLogs.where((e) => e.petId == petId).fold(0, (a, e) => a + e.delta);
}

class FakeClockService implements ClockService {
  DateTime nowValue;
  FakeClockService(this.nowValue);
  @override
  DateTime now() => nowValue;
  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) => Duration.zero;
  @override
  void markHeartbeat() {}
}

double _bonus(String tag, ExpSource src) {
  if (tag == 'p_glutton' && src == ExpSource.feed) return 0.10;
  if (tag == 'p_energetic' && src == ExpSource.toy) return 0.10;
  return 0;
}

void main() {
  final t0 = DateTime.utc(2026, 7, 2, 12);
  late FakeAudit audit;
  late FakeClockService clock;
  late ExpEngineImpl engine;
  int idc = 0;

  Pet newPet({List<String> personality = const ['p_glutton', 'p_curious']}) => Pet(
        id: 'pet1',
        speciesId: 'pet_cat',
        variantId: 'v1',
        name: '阿橘',
        personality: personality,
        bornAt: t0,
        lastOnlineAt: t0,
        offlineDayKey: '2026-07-02',
      );

  setUp(() {
    audit = FakeAudit();
    clock = FakeClockService(t0);
    idc = 0;
    engine = ExpEngineImpl(audit, clock, _bonus, () => 'log${idc++}');
  });

  group('派生', () {
    test('deriveLevel 关键阈值', () {
      expect(deriveLevel(0), 1);
      expect(deriveLevel(29), 1);
      expect(deriveLevel(30), 2);
      expect(deriveLevel(210), 5);
      expect(deriveLevel(799), 9);
      expect(deriveLevel(800), 10);
      expect(deriveLevel(9999), 10); // 封顶
    });
    test('deriveStage 换档', () {
      expect(deriveStage(4), PetStage.a);
      expect(deriveStage(5), PetStage.b);
      expect(deriveStage(8), PetStage.c);
      expect(deriveStage(10), PetStage.d);
    });
  });

  group('addExp 性格加成（floor 防通胀）', () {
    test('贪吃 feed baseDelta=20 → +floor(2.0)=2 → 22', () {
      final pet = newPet();
      final r = engine.addExp(pet: pet, baseDelta: 20, source: ExpSource.feed);
      expect(r.deltaApplied, 22);
    });
    test('贪吃 feed baseDelta=3 → floor(0.3)=0 → 3（小值无加成）', () {
      final pet = newPet();
      final r = engine.addExp(pet: pet, baseDelta: 3, source: ExpSource.feed);
      expect(r.deltaApplied, 3);
    });
    test('applyPersonalityBonus=false 不加成', () {
      final pet = newPet();
      final r = engine.addExp(
          pet: pet, baseDelta: 20, source: ExpSource.feed, applyPersonalityBonus: false);
      expect(r.deltaApplied, 20);
    });
  });

  group('升级 / 换档 / 毕业', () {
    test('跨 30 → Lv2 leveledUp', () {
      final pet = newPet();
      final r = engine.addExp(pet: pet, baseDelta: 30, source: ExpSource.eventDaily);
      expect(pet.level, 2);
      expect(r.leveledUp, true);
    });
    test('到 210 → Lv5 换档 B evolved', () {
      final pet = newPet();
      final r = engine.addExp(pet: pet, baseDelta: 210, source: ExpSource.eventDaily);
      expect(pet.level, 5);
      expect(pet.stage, PetStage.b);
      expect(r.evolved, true);
    });
    test('到 800 → Lv10 graduated；再加不重复 graduated', () {
      final pet = newPet();
      final r1 = engine.addExp(pet: pet, baseDelta: 800, source: ExpSource.eventDaily);
      expect(pet.level, 10);
      expect(pet.stage, PetStage.d);
      expect(r1.graduated, true);
      final r2 = engine.addExp(pet: pet, baseDelta: 5, source: ExpSource.pat);
      expect(r2.graduated, false);
    });
  });

  test('INV-1：pet.exp == Σ流水delta', () {
    final pet = newPet();
    engine.addExp(pet: pet, baseDelta: 3, source: ExpSource.feed); // +3
    engine.addExp(pet: pet, baseDelta: 20, source: ExpSource.feed); // +22
    engine.addExp(pet: pet, baseDelta: 4, source: ExpSource.toy); // +4 (curious 无 toy 加成)
    engine.addExp(pet: pet, baseDelta: 5, source: ExpSource.eventDaily); // +5
    expect(pet.exp, audit.sumFor('pet1'));
    // 每条 expAfter 冗余应等于累计
    expect(audit.expLogs.last.expAfter, pet.exp);
  });

  group('grantOffline 双上限 + renew', () {
    test('3h → +3；lastOnlineAt renew 到 now', () {
      final pet = newPet();
      clock.nowValue = t0.add(const Duration(hours: 6));
      final r = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 3));
      expect(r.deltaApplied, 3);
      expect(pet.offlineExpGrantedToday, 3);
      expect(pet.lastOnlineAt, clock.nowValue);
    });
    test('单段封顶 12 + 自然日累计 12', () {
      final pet = newPet();
      engine.grantOffline(pet: pet, elapsed: const Duration(hours: 3)); // +3 → 3
      final r2 = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 20)); // 单段封12,余9 → +9
      expect(r2.deltaApplied, 9);
      expect(pet.offlineExpGrantedToday, 12);
      final r3 = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 5)); // 余0 → 0
      expect(r3.deltaApplied, 0);
      expect(pet.offlineExpGrantedToday, 12);
    });
    test('跨自然日归零重计', () {
      final pet = newPet();
      engine.grantOffline(pet: pet, elapsed: const Duration(hours: 12)); // 满 12
      expect(pet.offlineExpGrantedToday, 12);
      clock.nowValue = t0.add(const Duration(days: 1)); // 次日
      final r = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 3));
      expect(r.deltaApplied, 3); // 归零后重新计
      expect(pet.offlineExpGrantedToday, 3);
    });
    test('慵懒离线上限 13', () {
      final pet = newPet(personality: ['p_lazy', 'p_gentle']);
      final r = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 30));
      // 单段封 12 → +12（不到 13，因单段上限 12）
      expect(r.deltaApplied, 12);
      // 再来一段：日上限 13，余 1 → +1
      final r2 = engine.grantOffline(pet: pet, elapsed: const Duration(hours: 5));
      expect(r2.deltaApplied, 1);
      expect(pet.offlineExpGrantedToday, 13);
    });
  });
}
