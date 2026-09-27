import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/adaptive_layout.dart';
import 'package:petopia/ui/yard_visitor_geometry.dart';

void main() {
  const scenes = [
    Size(390, 844),
    Size(440, 956),
    Size(744, 1133),
    Size(1032, 1376),
    Size(1133, 744),
    Size(1376, 1032),
  ];
  test('the pet and a same-height object share one ground projection', () {
    for (final scene in scenes) {
      final width = PetopiaAdaptive.yardPetWidth(scene);
      final pet = PetopiaAdaptive.alignedSquareRect(
        sceneSize: scene,
        squareSize: width,
        alignment: PetopiaAdaptive.yardPetAlignment(scene),
      );
      final scale = PetopiaAdaptive.yardMetreScale(
        scene,
        pet.bottom * 2 / scene.height - 1,
      );
      expect(scale * .60, closeTo(width * .80, .001));
    }
  });
  test(
    'narrow lanes move a deer back without changing its physical height',
    () {
      final crop = yardVisitorFrameBounds(
        'assets/art/world/visitors/visitor_deer_yard.png',
      );
      for (final scene in scenes) {
        final width = PetopiaAdaptive.yardPetWidth(scene);
        final alignment = PetopiaAdaptive.yardPetAlignment(scene);
        final pet = PetopiaAdaptive.alignedSquareRect(
          sceneSize: scene,
          squareSize: width,
          alignment: alignment,
        );
        final foot = pet.bottom + width * .12;
        final metres = PetopiaAdaptive.yardMetreScale(
          scene,
          foot * 2 / scene.height - 1,
        );
        final deer = PetopiaAdaptive.yardSideActorRect(
          sceneSize: scene,
          petWidth: width,
          petAlignment: alignment,
          preferredAlignment: const Alignment(-.54, .20),
          preferredSize: metres * .80,
          preferredFoot: foot,
          aspectRatio: crop.width / crop.height,
        );
        final actualScale = PetopiaAdaptive.yardMetreScale(
          scene,
          deer.bottom * 2 / scene.height - 1,
        );
        expect(deer.height / actualScale, closeTo(.80, .001));
        expect(
          deer.width / deer.height,
          closeTo(crop.width / crop.height, .001),
        );
        expect(deer.overlaps(pet.deflate(width * .1)), isFalse);
      }
    },
  );
}
