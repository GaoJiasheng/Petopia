import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum PetopiaSizeClass { compact, medium, expanded, wide }

class PetopiaAdaptive {
  const PetopiaAdaptive._();

  static PetopiaSizeClass sizeClassFor(double width) {
    if (width >= 1200) return PetopiaSizeClass.wide;
    if (width >= 840) return PetopiaSizeClass.expanded;
    if (width >= 600) return PetopiaSizeClass.medium;
    return PetopiaSizeClass.compact;
  }

  static PetopiaSizeClass sizeClassOf(BuildContext context) =>
      sizeClassFor(MediaQuery.sizeOf(context).width);

  static bool isMediumUp(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool isExpandedUp(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1200;

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
    if (width >= 1200) return 5;
    if (width >= 840) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static int travelColumns(double width) => width >= 840 ? 2 : 1;

  static double postcardMaxWidth(double width) =>
      (width * 0.72).clamp(560.0, 860.0);

  static double dialogMaxWidth(double width) =>
      (width - 32).clamp(320.0, 720.0);

  static double petStageWidth(Size size) =>
      (math.min(size.width, size.height) * 0.34).clamp(220.0, 340.0);

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
    final petRect = alignedSquareRect(
      sceneSize: sceneSize,
      squareSize: petWidth,
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
    final top =
        ((sceneSize.height - actorSize) * (preferredAlignment.y + 1) / 2)
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
