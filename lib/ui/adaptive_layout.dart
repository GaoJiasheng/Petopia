import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum PetopiaSizeClass { compact, medium, expanded, wide }

class PetopiaAdaptive {
  const PetopiaAdaptive._();

  static PetopiaSizeClass sizeClassFor(double width) {
    if (width >= 1180) return PetopiaSizeClass.wide;
    if (width >= 820) return PetopiaSizeClass.expanded;
    if (width >= 600) return PetopiaSizeClass.medium;
    return PetopiaSizeClass.compact;
  }

  static PetopiaSizeClass sizeClassOf(BuildContext context) =>
      sizeClassFor(MediaQuery.sizeOf(context).width);

  static bool isMediumUp(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool isExpandedUp(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 820;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1180;

  static bool useYardSidePanels(Size size) =>
      size.width >= 900 && size.width > size.height * 1.05;

  static double sideMargin(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.045).clamp(16.0, 40.0);
  }

  static double constrainedWidth(
    BuildContext context, {
    double max = 1040,
    double minHorizontalPadding = 0,
  }) {
    final width = MediaQuery.sizeOf(context).width - minHorizontalPadding;
    return math.max(0, math.min(width, max));
  }

  static int postcardGridColumns(double width) {
    if (width >= 1180) return 5;
    if (width >= 820) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static int travelColumns(double width) => width >= 760 ? 2 : 1;

  static double postcardMaxWidth(double width) =>
      (width * 0.72).clamp(560.0, 860.0);

  static double dialogMaxWidth(double width) =>
      (width - 32).clamp(320.0, 720.0);

  static double petStageWidth(Size size) {
    if (useYardSidePanels(size)) {
      return (math.min(size.width, size.height) * 0.3225).clamp(240.0, 285.0);
    }
    if (size.width >= 600) {
      return (math.min(size.width, size.height) * 0.36).clamp(270.0, 340.0);
    }
    return (size.width * 0.465).clamp(156.0, 189.0);
  }

  /// Keeps hand-painted yard actors at a consistent visual proportion instead
  /// of applying one tablet multiplier to every iPad width. Portrait tablets
  /// track the phone composition closely; landscape uses the wider anchor map
  /// and a gentler multiplier so the side panels retain breathing room.
  static double yardSceneScale(Size size) {
    if (useYardSidePanels(size)) {
      return (size.width / 760).clamp(1.55, 1.85);
    }
    return math.min(size.width / 420, size.height / 900).clamp(1.0, 1.8);
  }

  /// Keeps the current pet visually central in the open lawn, above the care
  /// controls and clear of the secondary character lanes.
  static Alignment yardPetAlignment(Size size) {
    // Landscape keeps the animal in command of the composition while leaving
    // a shallow foreground for bowls and other low, grounded props.
    if (useYardSidePanels(size)) return const Alignment(0, 0.26);
    return const Alignment(0, 0.36);
  }

  /// Places a secondary yard character inside a side lane that cannot overlap
  /// the centered pet's layout box. Small phones reduce the secondary actor
  /// before allowing it to intrude into the pet silhouette.
  static Rect yardSideActorRect({
    required Size sceneSize,
    required double petWidth,
    required Alignment petAlignment,
    required Alignment preferredAlignment,
    required double preferredSize,
    Iterable<Rect> decorRects = const [],
    Rect? actionBarRect,
  }) {
    // Pet PNGs keep generous transparent safety margins so ears and tails are
    // never clipped. Secondary actors should avoid the painted silhouette,
    // not that full transparent canvas, otherwise they become unnecessarily
    // tiny on phones.
    final petCollisionWidth = petWidth * 0.80;
    final petRect = alignedSquareRect(
      sceneSize: sceneSize,
      squareSize: petCollisionWidth,
      alignment: petAlignment,
    );
    final placeOnRight = preferredAlignment.x > 0;
    final laneWidth = placeOnRight
        ? sceneSize.width - petRect.right
        : petRect.left;
    final inset = sceneSize.width < 360 ? 6.0 : 12.0;
    final gap = sceneSize.width < 360 ? 6.0 : 8.0;
    final actorSize = math.min(
      preferredSize,
      math.max(1.0, laneWidth - inset - gap),
    );
    final left = placeOnRight
        ? petRect.right + gap
        : petRect.left - gap - actorSize;
    final fullPetRect = alignedSquareRect(
      sceneSize: sceneSize,
      squareSize: petWidth,
      alignment: petAlignment,
    );
    // Companions occupy the lawn beside and just behind the current pet.
    // Their foreground limit follows the pet's feet as well as the real bar.
    final maxBottom = math.min(
      (actionBarRect?.top ?? sceneSize.height) - 9,
      fullPetRect.bottom - petWidth * 0.10,
    );
    final maxTop = maxBottom - actorSize;
    final top = math
        .max(
          sceneSize.height * 0.56 - actorSize,
          fullPetRect.bottom - petWidth * 0.25 - actorSize,
        )
        .clamp(0.0, maxTop)
        .toDouble();
    final preferredRect = Rect.fromLTWH(left, top, actorSize, actorSize);
    if (decorRects.isEmpty && top <= maxTop) return preferredRect;

    // Leave the painted bases in place. Transparent sprite margins can share
    // space, but the animal itself must clear every visible prop and the pet.
    final actorInset = actorSize * 0.10;
    final obstacles = [
      alignedSquareRect(
        sceneSize: sceneSize,
        squareSize: petWidth,
        alignment: petAlignment,
      ).deflate(petWidth * 0.10),
      for (final rect in decorRects)
        rect.deflate(math.min(rect.width, rect.height) * 0.10),
    ];
    bool isClear(Rect rect) =>
        rect.top <= maxTop &&
        obstacles.every(
          (obstacle) => !rect.deflate(actorInset).overlaps(obstacle.inflate(4)),
        );
    if (isClear(preferredRect)) return preferredRect;

    // Start beside the pet, then try the outer lawn without crossing its feet.
    // The opposite half remains available to a returning companion.
    final tops = <double>{
      top,
      for (final obstacle in obstacles)
        if (obstacle.bottom + 4 - actorInset >= top &&
            obstacle.bottom + 4 - actorInset <= maxTop)
          obstacle.bottom + 4 - actorInset,
    }.toList()..sort();
    final outerLeft = placeOnRight
        ? sceneSize.width - inset - actorSize
        : inset;
    final lefts =
        <double>{
              left,
              outerLeft,
              for (final obstacle in obstacles)
                placeOnRight
                    ? obstacle.right + 4 - actorInset
                    : obstacle.left - 4 - actorSize + actorInset,
            }
            .where(
              (x) => placeOnRight
                  ? x >= left && x <= outerLeft
                  : x >= outerLeft && x <= left,
            )
            .toList()
          ..sort((a, b) => (a - left).abs().compareTo((b - left).abs()));
    for (final x in lefts) {
      for (final y in tops) {
        final candidate = Rect.fromLTWH(x, y, actorSize, actorSize);
        if (isClear(candidate)) return candidate;
      }
    }
    // On the smallest lawn, tall props can leave no full-size opening. Fit the
    // temporary actor to that gap only after trying both movement directions;
    // the player's arrangement and the minimum touch target stay intact.
    if (actorSize > 48) {
      return yardSideActorRect(
        sceneSize: sceneSize,
        petWidth: petWidth,
        petAlignment: petAlignment,
        preferredAlignment: preferredAlignment,
        preferredSize: math.max(48, actorSize - 2),
        decorRects: decorRects,
        actionBarRect: actionBarRect,
      );
    }
    return preferredRect;
  }

  static Rect alignedSquareRect({
    required Size sceneSize,
    required double squareSize,
    required Alignment alignment,
  }) {
    final left = (sceneSize.width - squareSize) * (alignment.x + 1) / 2;
    final top = (sceneSize.height - squareSize) * (alignment.y + 1) / 2;
    return Rect.fromLTWH(left, top, squareSize, squareSize);
  }

  static double panelWidth(double width) => width >= 1200 ? 318 : 300;
}

class AdaptiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const AdaptiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1040,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final margin = PetopiaAdaptive.sideMargin(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: margin),
          child: child,
        ),
      ),
    );
  }
}
