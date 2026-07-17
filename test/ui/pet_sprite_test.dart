import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/pet_action_cue.dart';
import 'package:petopia/ui/widgets/pet_sprite.dart';
import 'package:petopia/ui/widgets/sprite_sheet_player.dart';

void main() {
  testWidgets(
    'interaction animation plays for every variant and growth stage',
    (tester) async {
      await tester.pumpWidget(_app(cue: null));
      await tester.pumpWidget(_app(cue: const PetActionCue('eat', 1)));

      expect(
        find.byKey(const ValueKey<String>('pet_action_eat')),
        findsOneWidget,
      );
      final player = tester.widget<SpriteSheetPlayer>(
        find.byType(SpriteSheetPlayer),
      );
      expect(
        player.assetPath,
        'assets/runtime/pets/cat/actions/pet_cat_var01_stageC_eat.png',
      );
      expect(player.duration, const Duration(seconds: 5));
      expect(player.playDuration, isNull);
      expect(player.cycles, 2);
      expect(player.holdTailFraction, 0.16);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

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
    final player = tester.widget<SpriteSheetPlayer>(
      find.byType(SpriteSheetPlayer),
    );
    expect(player.duration, const Duration(seconds: 5));
    expect(player.playDuration, isNull);
    expect(player.cycles, 1);
    expect(player.holdTailFraction, 0.48);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _app({required PetActionCue? cue, bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: PetSprite(
          assetPath: 'assets/runtime/pets/cat/pet_cat_var05_stageA.png',
          speciesId: 'pet_cat',
          variantId: 'pet_cat_v5',
          stage: PetStage.a,
          cue: cue,
        ),
      ),
    ),
  );
}
