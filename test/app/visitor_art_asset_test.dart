import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';

void main() {
  test('regular visitor ids map directly to all art variants', () {
    expect(
      visitorArtAsset('visitor_sparrow', 'portrait'),
      'assets/art/world/visitors/visitor_sparrow_portrait.png',
    );
    expect(
      visitorArtAsset('visitor_sparrow', 'yard_base'),
      'assets/art/world/visitors/visitor_sparrow_yard_base.png',
    );
  });

  test('hidden visitor ids map to their historical file slugs', () {
    const mappings = <String, String>{
      'visitor_campfire_light': 'visitor_emberlight',
      'visitor_rainbow_shade': 'visitor_rainbowshade',
      'visitor_night_blob': 'visitor_ghostpuff',
    };

    for (final entry in mappings.entries) {
      for (final suffix in <String>['portrait', 'yard', 'yard_base']) {
        expect(
          visitorArtAsset(entry.key, suffix),
          'assets/art/world/visitors/${entry.value}_$suffix.png',
        );
      }
    }
  });
}
