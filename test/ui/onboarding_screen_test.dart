import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/onboarding_screen.dart';

void main() {
  testWidgets('onboarding remains readable on a compact large-text device', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.6),
            ),
            child: OnboardingScreen(needsAdoption: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('院子醒来了'), findsOneWidget);
    expect(find.text('继续'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(PageView), const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(find.text('陪它慢慢长大'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const <Size>[
    Size(834, 1194),
    Size(1194, 834),
    Size(1024, 1366),
    Size(1366, 1024),
  ]) {
    testWidgets(
      'onboarding composes on iPad Pro ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(size: size),
                child: const OnboardingScreen(needsAdoption: true),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('院子醒来了'), findsOneWidget);
        expect(find.text('继续'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
