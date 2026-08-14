import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/pet_action_cue.dart';
import 'package:petopia/ui/pet_art.dart';
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
        find.byKey(const ValueKey<String>('pet_action_prop_eat')),
        findsOneWidget,
      );
      final feedImage = tester.widget<Image>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('pet_action_prop_eat')),
          matching: find.byType(Image),
        ),
      );
      expect(
        (feedImage.image as AssetImage).assetName,
        'assets/art/pets/action_props/pet_action_prop_feed.png',
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/runtime/pets/cat/pet_cat_var05_stageA.webp',
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
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.webp',
      ),
    );
    await tester.pumpWidget(
      _app(
        cue: const PetActionCue('eat', 1),
        variantId: 'pet_cat_v1',
        stage: PetStage.c,
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.webp',
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
    expect(player.evictOnDispose, isFalse);

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

  testWidgets('Reduce Motion never launches floating heart particles', (
    tester,
  ) async {
    await tester.pumpWidget(_app(cue: null, reduceMotion: true));
    await tester.pumpWidget(
      _app(cue: const PetActionCue('pat', 1), reduceMotion: true),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('pet_heart_'),
      ),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('constrained rendering avoids decoding the large frame strip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        cue: null,
        variantId: 'pet_cat_v1',
        stage: PetStage.c,
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.webp',
        reduceEffects: true,
      ),
    );
    await tester.pumpWidget(
      _app(
        cue: const PetActionCue('play', 1),
        variantId: 'pet_cat_v1',
        stage: PetStage.c,
        assetPath: 'assets/runtime/pets/cat/pet_cat_var01_stageC.webp',
        reduceEffects: true,
      ),
    );

    expect(find.byType(SpriteSheetPlayer), findsNothing);
    expect(find.byKey(const ValueKey<String>('pose_1')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('every identity interaction uses a rendered scene prop', (
    tester,
  ) async {
    var seq = 0;
    await tester.pumpWidget(_app(cue: null));

    for (final action in PetArt.interactionNames) {
      seq += 1;
      await tester.pumpWidget(_app(cue: PetActionCue(action, seq)));
      await tester.pump(const Duration(milliseconds: 120));

      final assetName = action == 'eat' ? 'feed' : action;
      expect(
        find.byKey(ValueKey<String>('pet_action_$action')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey<String>('pet_action_prop_$action')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/art/pets/action_props/'
                      'pet_action_prop_$assetName.png',
        ),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('every species and stage has visible identity-preserving motion', (
    tester,
  ) async {
    const species = <String>[
      'boo',
      'cat',
      'chameleon',
      'ember',
      'hamster',
      'parrot',
      'rabbit',
      'shiba',
      'snake',
      'starbug',
      'turtle',
      'uni',
    ];
    var seq = 0;

    for (final speciesId in species) {
      for (final stage in PetStage.values) {
        for (final action in PetArt.interactionNames) {
          seq += 1;
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            _app(
              cue: null,
              variantId: 'pet_${speciesId}_v5',
              stage: stage,
              assetPath:
                  'assets/runtime/pets/$speciesId/'
                  'pet_${speciesId}_var05_stage${stage.name.toUpperCase()}.webp',
              speciesId: 'pet_$speciesId',
            ),
          );
          await tester.pumpWidget(
            _app(
              cue: PetActionCue(action, seq),
              variantId: 'pet_${speciesId}_v5',
              stage: stage,
              assetPath:
                  'assets/runtime/pets/$speciesId/'
                  'pet_${speciesId}_var05_stage${stage.name.toUpperCase()}.webp',
              speciesId: 'pet_$speciesId',
            ),
          );

          await tester.pump(const Duration(milliseconds: 450));
          final first = tester
              .widget<Transform>(
                find.byKey(ValueKey<String>('pet_action_actor_$action')),
              )
              .transform
              .storage
              .toList();
          await tester.pump(const Duration(milliseconds: 650));
          final second = tester
              .widget<Transform>(
                find.byKey(ValueKey<String>('pet_action_actor_$action')),
              )
              .transform
              .storage
              .toList();

          expect(
            second,
            isNot(orderedEquals(first)),
            reason: '$speciesId ${stage.name} $action stayed static',
          );
          expect(
            find.byKey(ValueKey<String>('pet_action_prop_$action')),
            findsOneWidget,
            reason: '$speciesId ${stage.name} $action lost its rendered prop',
          );
        }
      }
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}

Widget _app({
  required PetActionCue? cue,
  bool reduceMotion = false,
  String variantId = 'pet_cat_v5',
  PetStage stage = PetStage.a,
  String assetPath = 'assets/runtime/pets/cat/pet_cat_var05_stageA.webp',
  bool reduceEffects = false,
  String speciesId = 'pet_cat',
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: PetSprite(
          assetPath: assetPath,
          speciesId: speciesId,
          variantId: variantId,
          stage: stage,
          reduceEffects: reduceEffects,
          cue: cue,
        ),
      ),
    ),
  );
}
