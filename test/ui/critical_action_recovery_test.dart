import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/adopt_screen.dart';
import 'package:petopia/ui/graduation_ceremony_screen.dart';
import 'package:petopia/ui/onboarding_screen.dart';

class _FailingGameController extends GameController {
  final Completer<GameView> _never = Completer<GameView>();
  final Completer<int?> graduation = Completer<int?>();
  int graduationCalls = 0;
  int onboardingCalls = 0;
  int adoptionCalls = 0;

  @override
  Future<GameView> build() => _never.future;

  @override
  Future<int?> graduate({String? routeTheme}) {
    graduationCalls += 1;
    return graduation.future;
  }

  @override
  Future<void> completeOnboarding() async {
    onboardingCalls += 1;
    throw StateError('save failed');
  }

  @override
  List<AdoptChoiceView> adoptChoices() => const <AdoptChoiceView>[
    AdoptChoiceView(
      speciesId: 'pet_cat',
      name: '橘猫',
      category: PetCategory.real,
      baseTone: '奶油橘',
    ),
  ];

  @override
  Future<void> adopt(String speciesId, String name) async {
    adoptionCalls += 1;
    throw StateError('save failed');
  }
}

void main() {
  testWidgets('graduation ignores double taps and recovers after failure', (
    tester,
  ) async {
    final controller = _FailingGameController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(
          home: GraduationCeremonyScreen(
            petName: '小橘',
            speciesId: 'pet_cat',
            variantId: 'pet_cat_var01',
          ),
        ),
      ),
    );
    await tester.pump();

    final send = find.text('送它去旅行  🎒');
    await tester.tap(send);
    await tester.tap(send);
    expect(controller.graduationCalls, 1);

    controller.graduation.completeError(StateError('save failed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('这次没有顺利出发，旅程还没有开始。请稍后再试。'), findsOneWidget);
    expect(find.text('送它去旅行  🎒'), findsOneWidget);
    expect(find.text('再陪它一会儿'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding failure restores navigation controls', (
    tester,
  ) async {
    final controller = _FailingGameController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: OnboardingScreen(needsAdoption: false)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('跳过'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.onboardingCalls, 1);
    expect(find.text('小院暂时没能记下这一步，请再试一次。'), findsOneWidget);
    expect(find.text('跳过'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adoption failure restores the confirm button', (tester) async {
    final controller = _FailingGameController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: AdoptScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('橘猫'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('adopt_confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.adoptionCalls, 1);
    expect(find.text('这次没能迎接它进院子，请再试一次。'), findsOneWidget);
    expect(find.text('领养'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
