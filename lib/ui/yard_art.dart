/// Visible painted footprint inside a decor asset's transparent canvas.
class DecorCrop {
  final double canvasAspectRatio;
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Ground contact within the painted height. Standing props use their
  /// bottom edge; a flat pond uses the centre of its water footprint.
  final double groundAnchorFraction;

  const DecorCrop({
    this.canvasAspectRatio = 1,
    this.left = 0,
    this.top = 0,
    this.right = 1,
    this.bottom = 1,
    this.groundAnchorFraction = 1,
  });

  double get widthFraction => right - left;
  double get heightFraction => bottom - top;
}

/// 院子美术路径工具：主题 id → 背景图（themeId 与文件 slug 不完全一致，显式映射）。
class YardArt {
  const YardArt._();

  // shop_items 的 effect.params.themeId → yard_theme_<slug>_bg.png 的 slug
  static const Map<String, String> _themeSlug = {
    'sakura': 'sakura',
    'starry_camp': 'starcamp',
    'sea_breeze': 'seaside',
    'autumn_jam': 'autumnjam',
    'snow_house': 'snowhut',
    'rain_moss': 'mossrain',
    'candy_bakery': 'candybake',
    'four_seasons': 'fourseasons',
    'bamboo_tea': 'bambootea',
    'moonlight': 'moongreen',
    'wheat_kite': 'wheatkite',
  };

  /// 当前主题背景图。未知/默认主题回落到 meadow。
  ///
  /// iPad 使用单独重绘的 4:3 母图，避免裁掉竖版画面的顶部标志物。
  static String themeBg(
    String themeId, {
    bool wide = false,
    bool night = false,
  }) {
    final slug = _themeSlug[themeId] ?? 'meadow';
    if (wide) {
      return 'assets/runtime/yard/themes/wide/'
          'yard_theme_${slug}_bg${night ? '_night' : ''}_wide.webp';
    }
    return 'assets/art/world/themes/'
        'yard_theme_${slug}_bg${night ? '_night' : ''}.webp';
  }

  static bool isNight(int hour) => hour >= 18 || hour < 6;

  static String weatherFx(String weather) => switch (weather) {
    'rain' || 'thunder' => 'assets/art/world/fx/yard_fx_rain_overlay.webp',
    'snow' => 'assets/art/world/fx/yard_fx_snow_overlay.webp',
    _ => '',
  };

  static const Map<String, String> _decorFile = {
    'pond_small': 'deco_pond_small_ground_v2.webp',
    'tree_seasonal_spring': 'deco_tree_seasonal_spring.webp',
    'tree_seasonal_summer': 'deco_tree_seasonal_summer.webp',
    'tree_seasonal_autumn': 'deco_tree_seasonal_autumn.webp',
    'tree_seasonal_winter': 'deco_tree_seasonal_winter.webp',
    'water_bowl': 'deco_water_bowl.png',
    'night_light': 'deco_night_lamp.png',
    'fireplace': 'deco_heater_stove.png',
    'wind_chime': 'deco_windchime_shiny.png',
    'flower_box': 'deco_flowerbox_wild.png',
    'mushroom_bench': 'deco_mushroom_stool.png',
    'scarecrow': 'deco_scarecrow_postman.png',
    'wind_vane': 'deco_star_vane.png',
    'wood_sign': 'deco_signpost_journal.png',
    'mailbox_wood': 'deco_mailbox_wood.png',
    'food_bowl_full': 'deco_food_bowl_full.png',
    'flowerbed_small': 'deco_flowerbed_small.png',
  };

  /// VoiceOver 用的摆件名称（中文源串，界面按当前语言翻译）。商店摆件与商品名
  /// 一致；豪华阶段、饭盆等非商品摆件单独命名。未知 id 返回 null（按装饰处理）。
  static String? decorName(String decorId) {
    if (decorId.startsWith('tree_seasonal')) return '四季树';
    return const <String, String>{
      'water_bowl': '陶瓷小水碗',
      'night_light': '夜灯',
      'fireplace': '暖炉',
      'wind_chime': '亮闪闪风铃',
      'flower_box': '野花花坛箱',
      'mushroom_bench': '蘑菇石凳',
      'scarecrow': '稻草人邮差',
      'wind_vane': '星星风向标',
      'wood_sign': '木牌门号「1号院」',
      'mailbox_wood': '木头信箱',
      'food_bowl_full': '饭盆',
      'flowerbed_small': '小花坛',
      'pond_small': '小池塘',
      'album_shelf': '相册书架',
      'welcome_bell': '迎客铃',
    }[decorId];
  }

  /// 院子摆件图。shop_items 里 decorId 不一定等于文件名，统一在这里映射。
  static String decor(String decorId) {
    final file = _decorFile[decorId] ?? 'deco_$decorId.png';
    return 'assets/art/world/decor/$file';
  }

  /// The source PNGs carry transparent safety margins. This crop describes
  /// the painted footprint so previews and the yard share one visual scale.
  static DecorCrop decorCrop(String decorId) => switch (decorId) {
    'mailbox_wood' => const DecorCrop(
      left: 18 / 256,
      top: 18 / 256,
      right: 237 / 256,
      bottom: 248 / 256,
    ),
    'food_bowl_full' => const DecorCrop(
      left: 19 / 256,
      top: 69 / 256,
      right: 237 / 256,
      bottom: 248 / 256,
    ),
    'flowerbed_small' => const DecorCrop(
      left: 13 / 256,
      top: 114 / 256,
      right: 243 / 256,
      bottom: 248 / 256,
    ),
    'water_bowl' => const DecorCrop(
      left: 20 / 256,
      top: 81 / 256,
      right: 236 / 256,
      bottom: 248 / 256,
    ),
    'night_light' => const DecorCrop(
      left: 40 / 256,
      top: 18 / 256,
      right: 215 / 256,
      bottom: 248 / 256,
    ),
    'fireplace' => const DecorCrop(
      left: 65 / 256,
      top: 18 / 256,
      right: 187 / 256,
      bottom: 210 / 256,
    ),
    'wind_chime' => const DecorCrop(
      canvasAspectRatio: 2,
      left: 10 / 256,
      top: 12 / 512,
      right: 246 / 256,
      bottom: 499 / 512,
    ),
    'flower_box' => const DecorCrop(top: 35 / 256, right: 226 / 256),
    'mushroom_bench' => const DecorCrop(top: 46 / 256),
    'scarecrow' => const DecorCrop(
      canvasAspectRatio: 2,
      left: 13 / 256,
      top: 100 / 512,
      right: 243 / 256,
      bottom: 385 / 512,
    ),
    'wind_vane' => const DecorCrop(
      canvasAspectRatio: 2,
      left: 18 / 256,
      top: 48 / 512,
      right: 238 / 256,
      bottom: 462 / 512,
    ),
    'wood_sign' => const DecorCrop(
      canvasAspectRatio: 2,
      left: 13 / 256,
      top: 261 / 512,
      right: 243 / 256,
      bottom: 504 / 512,
    ),
    'pond_small' => const DecorCrop(
      canvasAspectRatio: 887 / 1774,
      left: 73 / 1774,
      top: 114 / 887,
      right: 1715 / 1774,
      bottom: 816 / 887,
      groundAnchorFraction: (570 - 114) / (816 - 114),
    ),
    'tree_seasonal_spring' => const DecorCrop(
      canvasAspectRatio: 768 / 512,
      left: 115 / 512,
      top: 486 / 768,
      right: 396 / 512,
      bottom: 760 / 768,
    ),
    'tree_seasonal_summer' => const DecorCrop(
      canvasAspectRatio: 768 / 512,
      left: 115 / 512,
      top: 476 / 768,
      right: 396 / 512,
      bottom: 760 / 768,
    ),
    'tree_seasonal_autumn' => const DecorCrop(
      canvasAspectRatio: 768 / 512,
      left: 116 / 512,
      top: 476 / 768,
      right: 396 / 512,
      bottom: 760 / 768,
    ),
    'tree_seasonal_winter' => const DecorCrop(
      canvasAspectRatio: 768 / 512,
      left: 123 / 512,
      top: 483 / 768,
      right: 389 / 512,
      bottom: 760 / 768,
    ),
    'album_shelf' => const DecorCrop(
      left: 13 / 256,
      top: 21 / 256,
      right: 243 / 256,
      bottom: 248 / 256,
    ),
    _ => const DecorCrop(),
  };
}
