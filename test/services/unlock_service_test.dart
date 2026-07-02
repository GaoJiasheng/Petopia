import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/unlock_rule.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/services/economy_service.dart';
import 'package:petopia/services/unlock_service.dart';
import 'package:petopia/services/unlock_service_impl.dart';

class FakeEconomy implements EconomyService {
  final List<(int, CurrencyReason, String?)> earns = [];
  @override
  int get balance => 0;
  @override
  void earn(int amount, CurrencyReason reason, {String? ref}) =>
      earns.add((amount, reason, ref));
  @override
  bool spend(int amount, CurrencyReason reason, {String? ref}) => true;
  @override
  int settleGraduation(pet) => 0;
  @override
  PurchaseResult purchase(item) => const PurchaseResult(success: true);
}

PetSpecies _sp(String id, UnlockRule rule) => PetSpecies(
      id: id, name: id, category: PetCategory.real, baseTone: '',
      unlockRule: rule, variantIds: const [],
      dexArtRef: '', dexSilhouetteRef: '');

Achievement _ach(String id, AchievementCondType t, int target, int fluff) =>
    Achievement(
      id: id, name: id, hidden: false,
      condition: AchievementCond(type: t, target: target),
      reward: RewardSpec(fluff: fluff),
    );

void main() {
  final now = DateTime.utc(2026, 7, 2);

  group('dexStateOf 四态', () {
    UnlockServiceImpl build({
      int gradCount = 0,
      Map<String, ClueCounter>? clues,
      Set<String> owned = const {},
    }) =>
        UnlockServiceImpl(
          const [], YardState(gradCount: gradCount), clues ?? {}, {},
          owned.contains, FakeEconomy(), () => now);

    test('初始可养 → available', () {
      expect(build().dexStateOf(_sp('pet_cat', const InitialUnlock())),
          DexState.available);
    });
    test('gradCount 未达/达标 → lockedKnown/available', () {
      expect(build(gradCount: 1).dexStateOf(_sp('pet_hamster', const GradCountUnlock(2))),
          DexState.lockedKnown);
      expect(build(gradCount: 2).dexStateOf(_sp('pet_hamster', const GradCountUnlock(2))),
          DexState.available);
    });
    test('hiddenClue 未达 → lockedHidden；达阈 → available', () {
      final ember = _sp('pet_ember', const HiddenClueUnlock(
          clueId: 'clue_ember', threshold: 3, clueText: '…', visitorPrereqId: 'v', hiddenSteps: []));
      expect(build().dexStateOf(ember), DexState.lockedHidden);
      expect(build(clues: {'clue_ember': ClueCounter(clueId: 'clue_ember', threshold: 3, count: 3)}).dexStateOf(ember),
          DexState.available);
    });
    test('曾养过 → ownedBefore（覆盖规则）', () {
      expect(build(owned: {'pet_cat'}).dexStateOf(_sp('pet_cat', const InitialUnlock())),
          DexState.ownedBefore);
    });
  });

  test('bumpClue 累加 + 达阈翻转图鉴为 available', () {
    final clues = <String, ClueCounter>{};
    final s = UnlockServiceImpl(const [], YardState(), clues, {}, (_) => false, FakeEconomy(), () => now);
    final ember = _sp('pet_ember', const HiddenClueUnlock(
        clueId: 'clue_ember', threshold: 3, clueText: '…', visitorPrereqId: 'v', hiddenSteps: []));
    s.bumpClue('clue_ember');
    s.bumpClue('clue_ember');
    expect(s.dexStateOf(ember), DexState.lockedHidden); // 2<3
    s.bumpClue('clue_ember');
    expect(s.dexStateOf(ember), DexState.available); // 3>=3
  });

  test('checkAchievements：达 target 返回并置 unlockedAt', () {
    final progress = <String, AchievementProgress>{};
    final ach = _ach('ach_grad_3', AchievementCondType.gradCount, 3, 100);
    final s = UnlockServiceImpl([ach], YardState(), {}, progress, (_) => false, FakeEconomy(), () => now);
    expect(s.checkAchievements(const GameSignal('gradCount', params: {'progress': 2})), isEmpty);
    final got = s.checkAchievements(const GameSignal('gradCount', params: {'progress': 3}));
    expect(got.single.id, 'ach_grad_3');
    expect(progress['ach_grad_3']!.unlockedAt, now);
  });

  test('claimReward：发奖幂等（第二次不重复 earn）', () {
    final progress = <String, AchievementProgress>{};
    final eco = FakeEconomy();
    final ach = _ach('ach_grad_3', AchievementCondType.gradCount, 3, 100);
    final s = UnlockServiceImpl([ach], YardState(), {}, progress, (_) => false, eco, () => now);
    s.checkAchievements(const GameSignal('gradCount', params: {'progress': 3})); // 解锁
    s.claimReward('ach_grad_3');
    s.claimReward('ach_grad_3'); // 幂等
    expect(eco.earns.length, 1);
    expect(eco.earns.single, (100, CurrencyReason.achievement, 'ach:ach_grad_3'));
  });
}
