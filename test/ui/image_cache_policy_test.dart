import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/image_cache_policy.dart';

void main() {
  test('keeps phone image cache below the tablet budget', () {
    expect(ImageCachePolicy.maximumBytes(390), 72 << 20);
    expect(ImageCachePolicy.maximumEntries(390), 240);
  });

  test('preserves the larger cache for iPad-sized windows', () {
    expect(ImageCachePolicy.maximumBytes(600), 96 << 20);
    expect(ImageCachePolicy.maximumBytes(1024), 96 << 20);
    expect(ImageCachePolicy.maximumEntries(600), 320);
  });
}
