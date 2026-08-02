import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/yard_art.dart';

void main() {
  test('theme backgrounds select day, night, portrait, and wide masters', () {
    expect(
      YardArt.themeBg('sakura'),
      'assets/art/world/themes/yard_theme_sakura_bg.webp',
    );
    expect(
      YardArt.themeBg('sakura', night: true),
      'assets/art/world/themes/yard_theme_sakura_bg_night.webp',
    );
    expect(
      YardArt.themeBg('sakura', wide: true),
      'assets/runtime/yard/themes/wide/yard_theme_sakura_bg_wide.webp',
    );
    expect(
      YardArt.themeBg('sakura', wide: true, night: true),
      'assets/runtime/yard/themes/wide/yard_theme_sakura_bg_night_wide.webp',
    );
  });

  test('unknown themes fall back to meadow in the requested period', () {
    expect(
      YardArt.themeBg('unknown', night: true),
      'assets/art/world/themes/yard_theme_meadow_bg_night.webp',
    );
  });

  test('night follows the local six-to-six yard boundary', () {
    expect(YardArt.isNight(0), isTrue);
    expect(YardArt.isNight(5), isTrue);
    expect(YardArt.isNight(6), isFalse);
    expect(YardArt.isNight(17), isFalse);
    expect(YardArt.isNight(18), isTrue);
    expect(YardArt.isNight(23), isTrue);
  });
}
