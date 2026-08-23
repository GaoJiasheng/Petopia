import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/adopt_screen.dart';

class _AdoptNameGameController extends GameController {
  final Completer<GameView> _never = Completer<GameView>();

  @override
  Future<GameView> build() => _never.future;

  @override
  List<AdoptChoiceView> adoptChoices() => const <AdoptChoiceView>[
    AdoptChoiceView(
      speciesId: 'pet_cat',
      name: '橘猫',
      category: PetCategory.real,
      baseTone: '慵懒、贪吃、晒太阳',
    ),
    AdoptChoiceView(
      speciesId: 'pet_shiba',
      name: '柴犬',
      category: PetCategory.real,
      baseTone: '忠诚、傻乐、拆家未遂',
    ),
  ];
}

void main() {
  Future<void> pumpAdoptScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameControllerProvider.overrideWith(_AdoptNameGameController.new),
        ],
        child: const MaterialApp(home: AdoptScreen()),
      ),
    );
    await tester.pump();
  }

  String currentName(WidgetTester tester) {
    return tester
        .widget<TextField>(find.byKey(const ValueKey<String>('adopt_name')))
        .controller!
        .text;
  }

  testWidgets('default name follows the selected species', (tester) async {
    await pumpAdoptScreen(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('adopt_choice_pet_cat')),
    );
    await tester.pump();
    expect(currentName(tester), '橘猫');

    await tester.tap(
      find.byKey(const ValueKey<String>('adopt_choice_pet_shiba')),
    );
    await tester.pump();
    expect(currentName(tester), '柴犬');
  });

  testWidgets('custom name survives species changes', (tester) async {
    await pumpAdoptScreen(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('adopt_choice_pet_cat')),
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey<String>('adopt_name')),
      '团子',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('adopt_choice_pet_shiba')),
    );
    await tester.pump();
    expect(currentName(tester), '团子');
  });
}
