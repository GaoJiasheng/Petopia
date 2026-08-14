import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/adaptive_layout.dart';

void main() {
  group('PetopiaAdaptive', () {
    test('size classes match iPad adaptive breakpoints', () {
      expect(PetopiaAdaptive.sizeClassFor(390), PetopiaSizeClass.compact);
      expect(PetopiaAdaptive.sizeClassFor(599.9), PetopiaSizeClass.compact);
      expect(PetopiaAdaptive.sizeClassFor(600), PetopiaSizeClass.medium);
      expect(PetopiaAdaptive.sizeClassFor(819.9), PetopiaSizeClass.medium);
      expect(PetopiaAdaptive.sizeClassFor(820), PetopiaSizeClass.expanded);
      expect(PetopiaAdaptive.sizeClassFor(834), PetopiaSizeClass.expanded);
      expect(PetopiaAdaptive.sizeClassFor(840), PetopiaSizeClass.expanded);
      expect(PetopiaAdaptive.sizeClassFor(1179.9), PetopiaSizeClass.expanded);
      expect(PetopiaAdaptive.sizeClassFor(1180), PetopiaSizeClass.wide);
      expect(PetopiaAdaptive.sizeClassFor(1194), PetopiaSizeClass.wide);
      expect(PetopiaAdaptive.sizeClassFor(1200), PetopiaSizeClass.wide);
    });

    test('postcard and travel grids expand predictably', () {
      expect(PetopiaAdaptive.postcardGridColumns(430), 2);
      expect(PetopiaAdaptive.postcardGridColumns(700), 3);
      expect(PetopiaAdaptive.postcardGridColumns(834), 4);
      expect(PetopiaAdaptive.postcardGridColumns(900), 4);
      expect(PetopiaAdaptive.postcardGridColumns(1194), 5);
      expect(PetopiaAdaptive.postcardGridColumns(1366), 5);

      expect(PetopiaAdaptive.travelColumns(700), 1);
      expect(PetopiaAdaptive.travelColumns(834), 2);
      expect(PetopiaAdaptive.travelColumns(900), 2);
    });

    test('large iPad values are capped instead of scaling forever', () {
      expect(PetopiaAdaptive.postcardMaxWidth(390), 560);
      expect(PetopiaAdaptive.postcardMaxWidth(1024), closeTo(737.28, 0.01));
      expect(PetopiaAdaptive.postcardMaxWidth(1600), 860);

      expect(PetopiaAdaptive.petStageWidth(const Size(390, 844)), closeTo(181.35, 0.01));
      expect(PetopiaAdaptive.petStageWidth(const Size(1024, 1366)), 288);
      expect(
        PetopiaAdaptive.petStageWidth(const Size(1194, 834)),
        closeTo(268.97, 0.01),
      );
    });

    test('yard visitors never overlap the centered pet on supported sizes', () {
      const scenes = [
        Size(320, 568),
        Size(393, 852),
        Size(430, 932),
        Size(768, 1024),
        Size(819, 700),
        Size(820, 700),
        Size(899, 700),
        Size(900, 700),
        Size(834, 1194),
        Size(1194, 834),
        Size(1024, 1366),
        Size(1366, 1024),
      ];

      for (final scene in scenes) {
        final petWidth = PetopiaAdaptive.petStageWidth(scene);
        final petAlignment = PetopiaAdaptive.yardPetAlignment(scene);
        final petRect = PetopiaAdaptive.alignedSquareRect(
          sceneSize: scene,
          squareSize: petWidth * 0.80,
          alignment: petAlignment,
        );
        for (final preferred in const [
          Alignment(-0.50, 0.43),
          Alignment(0.47, 0.24),
          Alignment(0.56, 0.46),
        ]) {
          final actorRect = PetopiaAdaptive.yardSideActorRect(
            sceneSize: scene,
            petWidth: petWidth,
            petAlignment: petAlignment,
            preferredAlignment: preferred,
            preferredSize: 108,
          );
          expect(
            actorRect.overlaps(petRect),
            isFalse,
            reason: '$scene $preferred: $actorRect overlaps $petRect',
          );
        }
      }
    });

    test('iPad Pro 11/13 仅横屏启用院子双侧工作区', () {
      expect(PetopiaAdaptive.useYardSidePanels(const Size(834, 1194)), isFalse);
      expect(PetopiaAdaptive.useYardSidePanels(const Size(1194, 834)), isTrue);
      expect(
        PetopiaAdaptive.useYardSidePanels(const Size(1024, 1366)),
        isFalse,
      );
      expect(PetopiaAdaptive.useYardSidePanels(const Size(1366, 1024)), isTrue);
    });

    test('yard side panels switch only after both width conditions pass', () {
      expect(PetopiaAdaptive.useYardSidePanels(const Size(899, 700)), isFalse);
      expect(PetopiaAdaptive.useYardSidePanels(const Size(900, 900)), isFalse);
      expect(PetopiaAdaptive.useYardSidePanels(const Size(900, 858)), isFalse);
      expect(PetopiaAdaptive.useYardSidePanels(const Size(900, 857)), isTrue);
    });

    test('opposite yard side lanes keep two visitors separated', () {
      const scene = Size(393, 852);
      final petWidth = PetopiaAdaptive.petStageWidth(scene);
      final petAlignment = PetopiaAdaptive.yardPetAlignment(scene);
      final left = PetopiaAdaptive.yardSideActorRect(
        sceneSize: scene,
        petWidth: petWidth,
        petAlignment: petAlignment,
        preferredAlignment: const Alignment(-0.5, 0.43),
        preferredSize: 92,
      );
      final right = PetopiaAdaptive.yardSideActorRect(
        sceneSize: scene,
        petWidth: petWidth,
        petAlignment: petAlignment,
        preferredAlignment: const Alignment(0.56, 0.46),
        preferredSize: petWidth * 0.48,
      );

      expect(left.overlaps(right), isFalse);
    });

    test('yard pet remains above the lower interaction controls', () {
      expect(
        PetopiaAdaptive.yardPetAlignment(const Size(393, 852)),
        const Alignment(0, 0.36),
      );
      expect(
        PetopiaAdaptive.yardPetAlignment(const Size(1194, 834)),
        const Alignment(0, 0.26),
      );
    });

    test('yard scene art keeps a stable visual proportion across devices', () {
      expect(PetopiaAdaptive.yardSceneScale(const Size(402, 874)), 1);
      expect(
        PetopiaAdaptive.yardSceneScale(const Size(834, 1194)),
        closeTo(1.986, 0.001),
      );
      expect(PetopiaAdaptive.yardSceneScale(const Size(1024, 1366)), 2.35);
      expect(
        PetopiaAdaptive.yardSceneScale(const Size(1366, 1024)),
        closeTo(1.797, 0.001),
      );
    });
  });
}
