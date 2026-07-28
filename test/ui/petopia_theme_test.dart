import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/petopia_theme.dart';

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance();
  final dark = background.computeLuminance();
  final brighter = light > dark ? light : dark;
  final dimmer = light > dark ? dark : light;
  return (brighter + 0.05) / (dimmer + 0.05);
}

void main() {
  test('shared text and action colors keep accessible contrast', () {
    expect(
      _contrast(PetopiaColors.ink, PetopiaColors.paper),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(PetopiaColors.mutedText, PetopiaColors.paper),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(Colors.white, PetopiaColors.actionAccent),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('Reduce Motion removes shared transition duration', (
    tester,
  ) async {
    late Duration resolved;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              resolved = PetopiaMotion.duration(
                context,
                const Duration(milliseconds: 300),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(resolved, Duration.zero);
  });

  test('shared motion tiers stay ordered and restrained', () {
    expect(PetopiaMotion.micro, lessThan(PetopiaMotion.quick));
    expect(PetopiaMotion.quick, lessThan(PetopiaMotion.standard));
    expect(PetopiaMotion.standard, lessThan(PetopiaMotion.modal));
    expect(PetopiaMotion.reveal, lessThan(const Duration(seconds: 1)));
  });

  test('night yard uses light system chrome and day yard uses dark chrome', () {
    expect(
      PetopiaSystemUi.yard(hour: 23).statusBarIconBrightness,
      Brightness.light,
    );
    expect(
      PetopiaSystemUi.yard(hour: 12).statusBarIconBrightness,
      Brightness.dark,
    );
  });
}
