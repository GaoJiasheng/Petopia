import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/pet_action_cue.dart';
import 'package:petopia/ui/widgets/pet_sprite.dart';
import 'package:petopia/ui/widgets/sprite_sheet_player.dart';

void main() {
  testWidgets(
    'non-anchor pets keep their exact identity for the full interaction',
    (tester) async {
      await tester.pumpWidget(_app(cue: null));
      await tester.pumpWidget(_app(cue: const PetActionCue('eat', 1)));

      expect(
        find.byKey(const ValueKey<String>('pet_action_eat')),
        findsOneWidget,
      );
      expect(find.byType(SpriteSheetPlayer), findsNothing);
      expect(find.byKey(const ValueKey<String>('pose_1')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/runtime/pets/cat/pet_cat_var05_stageA.png',
        ),
        findsWidgets,
      );

      await tester.pump(const Duration(milliseconds: 5500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey<String>('pet_action_eat')),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('exact anchor pet keeps the hand-painted frame strip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        cue: null,
        variantId: 'pet_cat_v1',
        stage: PetStage.c,
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.png',
      ),
    );
    await tester.pumpWidget(
      _app(
        cue: const PetActionCue('eat', 1),
        variantId: 'pet_cat_v1',
        stage: PetStage.c,
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.png',
      ),
    );

    final player = tester.widget<SpriteSheetPlayer>(
      find.byType(SpriteSheetPlayer),
    );
    expect(
      player.assetPath,
      'assets/runtime/pets/cat/actions/pet_cat_var01_stageC_eat.webp',
    );
    expect(player.duration, const Duration(seconds: 5));
    expect(player.cycles, 2);
    expect(player.holdTailFraction, 0.16);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reduce Motion keeps one gentle five-second interaction', (
    tester,
  ) async {
    await tester.pumpWidget(_app(cue: null, reduceMotion: true));
    await tester.pumpWidget(
      _app(cue: const PetActionCue('bath', 1), reduceMotion: true),
    );

    expect(
      find.byKey(const ValueKey<String>('pet_action_bath')),
      findsOneWidget,
    );
    expect(find.byType(SpriteSheetPlayer), findsNothing);
    expect(find.byKey(const ValueKey<String>('pose_1')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _app({
  required PetActionCue? cue,
  bool reduceMotion = false,
  String variantId = 'pet_cat_v5',
  PetStage stage = PetStage.a,
  String assetPath = 'assets/runtime/pets/cat/pet_cat_var05_stageA.png',
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: PetSprite(
          assetPath: assetPath,
          speciesId: 'pet_cat',
          variantId: variantId,
          stage: stage,
          cue: cue,
        ),
      ),
    ),
  );
}
