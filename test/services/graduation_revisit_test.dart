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
  ExpResult addExp({
    required Pet pet,
    required int baseDelta,
    required ExpSource source,
    String? sourceRef,
    String? note,
    bool applyPersonalityBonus = true,
  }) {
    calls.add((pet.id, baseDelta, source));
    return ExpResult.noop;
  }

  @override
  ExpResult grantOffline({required Pet pet, required Duration elapsed}) =>
      ExpResult.noop;
}

Pet _pet(String id) => Pet(
  id: id,
  speciesId: 'pet_cat',
  variantId: 'v1',
  name: id,
  personality: const ['p_dreamy', 'p_curious'],
  bornAt: DateTime.utc(2026, 7, 2),
  lastOnlineAt: DateTime.utc(2026, 7, 2),
  offlineDayKey: '2026-07-02',
  level: 10,
);

Location _loc(String id, {Map<String, double> w = const {}}) => Location(
  id: id,
  name: id,
  category: 'x',
  climate: 'x',
  vibeTags: const [],
  photoStyle: 'x',
  encounterPoolId: 'x',
  personalityWeight: w,
  stampId: 'x',
);

List<Location> _numberedLocs(
  int count, {
  Map<String, double> firstWeight = const {},
}) {
  return List<Location>.generate(
    count,
    (index) => _loc(
      'loc_${index.toString().padLeft(2, '0')}',
      w: index == 0 ? firstWeight : const {},
    ),
  );
}

double Function() _rngSeq(List<double> values) {
  var index = 0;
  return () {
    final value = values[index < values.length ? index : values.length - 1];
    index++;
    return value;
  };
}

void main() {
  final now = DateTime.utc(2026, 7, 2, 12);

  group('GraduationService', () {
    test('毕业编排：结算/建Journey/转TRAVELING/gradCount++/豪华度', () async {
      final eco = FakeEconomy();
      final yard = YardState(); // gradCount 0
      Journey? saved;
      final locs = _numberedLocs(
        40,
        firstWeight: {'p_dreamy': 2.0}, // 高权重（爱幻想）
      );
      final svc = GraduationServiceImpl(
        eco,
        locs,
        yard,
        () => 'j1',
        () => now,
        () => 0.0,
        (j) => saved = j,
      );
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
      expect(saved!.stops.length, 25);
      expect(saved!.wanderStops.length, 15);
      expect(saved!.nextPostcardAt, now.add(const Duration(days: 1)));
      expect(saved!.stops.first, 'loc_00'); // rng=0 时从加权轮盘最左侧命中
      expect(saved!.stops.toSet(), hasLength(saved!.stops.length));
      expect(saved!.wanderStops.toSet(), hasLength(saved!.wanderStops.length));
      expect({...saved!.stops, ...saved!.wanderStops}, hasLength(40));
    });

    test('旅程站点使用随机顺序，且不放回去重', () async {
      final eco = FakeEconomy();
      final yard = YardState();
      Journey? saved;
      final locs = _numberedLocs(40);
      final svc = GraduationServiceImpl(
        eco,
        locs,
        yard,
        () => 'j-random',
        () => now,
        _rngSeq([0.99, 0.0, 0.50, 0.25, 0.75]),
        (j) => saved = j,
      );

      await svc.graduate(_pet('pet-random'));

      expect(saved, isNotNull);
      expect(saved!.stops.length, 25);
      expect(saved!.wanderStops.length, 15);
      expect(saved!.stops.first, 'loc_39');
      expect(saved!.stops.toSet(), hasLength(saved!.stops.length));
      expect({...saved!.stops, ...saved!.wanderStops}, hasLength(40));
    });

    test('旅程候选地点 id 重复时只保留一个', () async {
      final eco = FakeEconomy();
      final yard = YardState();
      Journey? saved;
      final locs = [
        _loc('loc_a'),
        _loc('loc_a'),
        _loc('loc_b'),
        _loc('loc_b'),
        _loc('loc_c'),
      ];
      final svc = GraduationServiceImpl(
        eco,
        locs,
        yard,
        () => 'j-dedup',
        () => now,
        () => 0.0,
        (j) => saved = j,
      );

      await svc.graduate(_pet('pet-dedup'));

      expect(saved, isNotNull);
      expect(saved!.stops, hasLength(3));
      expect(saved!.stops.toSet(), {'loc_a', 'loc_b', 'loc_c'});
      expect(saved!.wanderStops, isEmpty);
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
      expect(
        p.nextRevisitAt,
        now.add(const Duration(days: 14)),
      ); // rng0.99 → 14
    });

    test('isDue + pickRevisitor（INV-2：已有在访→null；否则取最早）', () {
      final s = RevisitServiceImpl(FakeExp(), () => 0.0, () => now);
      final a = _pet('a')
        ..state = PetState.roaming
        ..nextRevisitAt = now.subtract(const Duration(days: 1));
      final b = _pet('b')
        ..state = PetState.roaming
        ..nextRevisitAt = now.subtract(const Duration(days: 3));
      final c = _pet('c')
        ..state = PetState.roaming
        ..nextRevisitAt = now.add(const Duration(days: 5)); // 未到
      expect(s.isDue(a, now), true);
      expect(s.isDue(c, now), false);
      expect(
        s.pickRevisitor([a, b, c], now, hasCurrentRevisitor: true),
        isNull,
      );
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
      expect(
        RevisitServiceImpl(
          FakeExp(),
          () => 0.5,
          () => now,
        ).onRevisitInteract(revisitor, current),
        false,
      );
    });
  });
}
