import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/widgets/sprite_sheet_player.dart';

void main() {
  testWidgets('replaces a loaded frame strip when the asset path changes', (
    tester,
  ) async {
    const frog = 'assets/art/world/visitors/visitor_frog_yard.png';
    await tester.pumpWidget(_host(frog));
    await _finishImageLoad(tester);
    expect(find.byKey(const ValueKey<String>('sprite_fallback')), findsNothing);
    final frogPixels = await _pixels(tester);

    const deer = 'assets/art/world/visitors/visitor_deer_yard.png';
    await tester.pumpWidget(_host(deer));
    await _finishImageLoad(tester);
    final deerPixels = await _pixels(tester);

    expect(find.byKey(const ValueKey<String>('sprite_fallback')), findsNothing);
    expect(listEquals(frogPixels, deerPixels), isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _host(String assetPath) {
  return MaterialApp(
    home: Scaffold(
      body: RepaintBoundary(
        key: const ValueKey<String>('sprite_boundary'),
        child: SpriteSheetPlayer(
          assetPath: assetPath,
          size: 120,
          frameCount: 8,
          animate: false,
          fallback: const SizedBox(key: ValueKey<String>('sprite_fallback')),
        ),
      ),
    ),
  );
}

Future<void> _finishImageLoad(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await tester.pump();
}

Future<Uint8List> _pixels(WidgetTester tester) async {
  final result = await tester.runAsync<Uint8List>(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey<String>('sprite_boundary')),
    );
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return result!;
}
