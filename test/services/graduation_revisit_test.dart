import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/services/economy_service.dart';
import 'package:petopia/services/exp_engine.dart';
import 'package:petopia/services/graduation_service_impl.dart';
import 'package:petopia/services/revisit_service_impl.dart';

class FakeEconomy implements EconomyService {
  int settleCalls = 0;
  @override
  int get balance => 0;
  @override
  void earn(int a, CurrencyReason r, {String? ref}) {}
  @override
  bool spend(int a, CurrencyReason r, {String? ref}) => true;
  @override
  int settleGraduation(Pet pet) {
    settleCalls++;
    return 300;
  }
  @override
  PurchaseResult purchase(item) => const PurchaseResult(success: true);
}

class FakeExp implements ExpEngine {
  final List<(String, int, ExpSource)> calls = [];
  @override
  ExpResult addExp({required Pet pet, required int baseDelta, required ExpSource source, String? sourceRef, String? note, bool applyPersonalityBonus = true}) {
    calls.add((pet.id, baseDelta, source));
    return ExpResult.noop;
  }
  @override
  ExpResult grantOffline({required Pet pet, required Duration elapsed}) => ExpResult.noop;
}

Pet _pet(String id) => Pet(
      id: id, speciesId: 'pet_cat', variantId: 'v1', name: id,
      personality: const ['p_dreamy', 'p_curious'],
      bornAt: DateTime.utc(2026, 7, 2), lastOnlineAt: DateTime.utc(2026, 7, 2),
      offlineDayKey: '2026-07-02', level: 10);

Location _loc(String id, {Map<String, double> w = const {}}) => Location(
      id: id, name: id, category: 'x', climate: 'x', vibeTags: const [],
      photoStyle: 'x', encounterPoolId: 'x', personalityWeight: w, stampId: 'x');

void main() {
  final now = DateTime.utc(2026, 7, 2, 12);

  group('GraduationService', () {
    test('毕业编排：结算/建Journey/转TRAVELING/gradCount++/豪华度', () async {
      final eco = FakeEconomy();
      final yard = YardState(); // gradCount 0
      Journey? saved;
      final locs = [
        _loc('loc_a', w: {'p_dreamy': 2.0}), // 高权重（爱幻想）
        _loc('loc_b'), _loc('loc_c'), _loc('loc_d'), _loc('loc_e'), _loc('loc_f'),
      ];
      final svc = GraduationServiceImpl(eco, locs, yard, () => 'j1', () => now, () => 0.0, (j) => saved = j);
      final pet = _pet('pet1');
      final jid = await svc.graduate(pet);

      expect(jid, 'j1');
      expect(eco.settleCalls, 1);
      expect(pet.state, PetState.traveling);
      expect(pet.graduatedAt, now);
      expect(pet.journeyId, 'j1');
      expect(yard.gradCount, 1);
      expect(yard.luxuryStage, 2); // gradCount1 → ②
      expect(saved, isNotNull);
      expect(saved!.stops.length, 5); // rng=0 → 5 站
      expect(saved!.stops.first, 'loc_a'); // 爱幻想加权最高
    });

    test('luxuryStageFor 阈值', () {
      expect(GraduationServiceImpl.luxuryStageFor(0), 1);
      expect(GraduationServiceImpl.luxuryStageFor(1), 2);
      expect(GraduationServiceImpl.luxuryStageFor(3), 3);
      expect(GraduationServiceImpl.luxuryStageFor(5), 4);
      expect(GraduationServiceImpl.luxuryStageFor(8), 5);
      expect(GraduationServiceImpl.luxuryStageFor(12), 6);
    });
  });

  group('RevisitService', () {
    test('scheduleNextRevisit：nextRevisitAt 落在 now+7..14', () {
      final s = RevisitServiceImpl(FakeExp(), () => 0.0, () => now);
      final p = _pet('p')..state = PetState.roaming;
      s.scheduleNextRevisit(p);
      expect(p.nextRevisitAt, now.add(const Duration(days: 7))); // rng0 → 7
      final s2 = RevisitServiceImpl(FakeExp(), () => 0.99, () => now);
      s2.scheduleNextRevisit(p);
      expect(p.nextRevisitAt, now.add(const Duration(days: 14))); // rng0.99 → 14
    });

    test('isDue + pickRevisitor（INV-2：已有在访→null；否则取最早）', () {
      final s = RevisitServiceImpl(FakeExp(), () => 0.0, () => now);
      final a = _pet('a')..state = PetState.roaming..nextRevisitAt = now.subtract(const Duration(days: 1));
      final b = _pet('b')..state = PetState.roaming..nextRevisitAt = now.subtract(const Duration(days: 3));
      final c = _pet('c')..state = PetState.roaming..nextRevisitAt = now.add(const Duration(days: 5)); // 未到
      expect(s.isDue(a, now), true);
      expect(s.isDue(c, now), false);
      expect(s.pickRevisitor([a, b, c], now, hasCurrentRevisitor: true), isNull);
      expect(s.pickRevisitor([a, b, c], now)?.id, 'b'); // b 最早
    });

    test('onRevisitInteract：在养宠获 +5 REVISIT 经验 + 带旅伴概率', () {
      final exp = FakeExp();
      final s = RevisitServiceImpl(exp, () => 0.1, () => now); // 0.1<0.2 → 带旅伴
      final revisitor = _pet('old');
      final current = _pet('cur');
      final brought = s.onRevisitInteract(revisitor, current);
      expect(exp.calls.single, ('cur', 5, ExpSource.revisit));
      expect(brought, true);
      // rng 0.5 → 不带
      expect(RevisitServiceImpl(FakeExp(), () => 0.5, () => now).onRevisitInteract(revisitor, current), false);
    });
  });
}
