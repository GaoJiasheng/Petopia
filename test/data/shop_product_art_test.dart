import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/ui/yard_art.dart';

void main() {
  const productIds = <String>{
    'shop_food_grain_bag',
    'shop_food_dried_fish',
    'shop_food_nut_jar',
    'shop_food_apple_slices',
    'shop_feed_salmon_cookie',
    'shop_feed_rainbow_jelly',
    'shop_feed_honey_oat',
    'shop_feed_bubble_soap',
    'shop_toy_yarn_ball',
    'shop_toy_wind_up_duck',
    'shop_toy_cat_wand',
    'shop_toy_wooden_disc',
    'shop_album_paper',
    'shop_album_picnic',
    'shop_album_dried_flower',
    'shop_album_star_chart',
  };

  test('every non-scenery shop product has unique production artwork', () {
    final payload =
        jsonDecode(File('assets/data/shop_items.json').readAsStringSync())
            as Map<String, dynamic>;
    final products = (payload['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((item) => productIds.contains(item['id']))
        .toList(growable: false);

    expect(products, hasLength(productIds.length));
    final artRefs = products
        .map((item) => item['artRef'] as String)
        .toList(growable: false);
    expect(artRefs.toSet(), hasLength(productIds.length));

    for (final product in products) {
      final id = product['id'] as String;
      final artRef = product['artRef'] as String;
      expect(
        artRef,
        'assets/runtime/shop/products/$id.webp',
        reason: '$id must use its own rendered product art',
      );
      final runtime = File(artRef);
      final source = File('assets/art/shop/products/source/$id.png');
      expect(runtime.existsSync(), isTrue, reason: 'missing $artRef');
      expect(source.existsSync(), isTrue, reason: 'missing ${source.path}');
      expect(runtime.lengthSync(), greaterThan(20 * 1024));
      expect(source.lengthSync(), greaterThan(100 * 1024));
    }
  });

  test('shop UI no longer selects legacy geometric product placeholders', () {
    final source = File('lib/ui/shop_screen.dart').readAsStringSync();
    for (final legacy in <String>[
      'ui_icon_food_grain.png',
      'ui_icon_food_fish.png',
      'ui_icon_food_nut.png',
      'ui_icon_food_apple.png',
      'ui_icon_shop_food.png',
      'ui_icon_shop_toy.png',
      'ui_icon_shop_albumskin.png',
    ]) {
      expect(source, isNot(contains(legacy)), reason: 'legacy asset: $legacy');
    }
  });

  test('every decor product thumbnail resolves to its rendered yard asset', () {
    final payload =
        jsonDecode(File('assets/data/shop_items.json').readAsStringSync())
            as Map<String, dynamic>;
    final decorProducts = (payload['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((item) => item['category'] == '装饰小物')
        .toList(growable: false);

    expect(decorProducts, hasLength(9));
    final decorIds = <String>{};
    for (final product in decorProducts) {
      final effect = product['effect'] as Map<String, dynamic>;
      final params = effect['params'] as Map<String, dynamic>;
      final decorId = params['decorId'] as String;
      expect(decorIds.add(decorId), isTrue, reason: 'duplicate $decorId');

      final artwork = File(YardArt.decor(decorId));
      expect(
        artwork.existsSync(),
        isTrue,
        reason: '${product['id']} is missing ${artwork.path}',
      );
      expect(
        artwork.lengthSync(),
        greaterThan(20 * 1024),
        reason: '${product['id']} must use production artwork',
      );
    }
  });
}
