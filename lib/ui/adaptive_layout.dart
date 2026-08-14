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
      return (math.min(size.width, size.height) * 0.30).clamp(225.0, 288.0);
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
    return (size.width / 420).clamp(1.0, 2.35);
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
    final left = placeOnRight ? sceneSize.width - inset - actorSize : inset;
    // Secondary characters belong beside the pet, not in the decor field.
    // Their horizontal lane still follows the preferred side, while the
    // vertical center tracks the current pet so the lower lawn remains usable.
    final preferredTop =
        (sceneSize.height - actorSize) * (preferredAlignment.y + 1) / 2;
    // Secondary animals are smaller and read as one depth step behind the
    // current pet. Their visible feet therefore sit slightly higher in the
    // lawn perspective instead of sharing an implausibly flat baseline.
    final companionTop = petRect.bottom - actorSize * 2.30;
    final groundedTop = sceneSize.height * 0.58 - actorSize;
    final top = math
        .max(math.min(preferredTop, companionTop), groundedTop)
        .clamp(0.0, sceneSize.height - actorSize)
        .toDouble();
    return Rect.fromLTWH(left, top, actorSize, actorSize);
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
