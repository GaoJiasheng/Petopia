/// Visible painted footprint inside a decor asset's transparent canvas.
class DecorCrop {
  final double canvasAspectRatio;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const DecorCrop({
    this.canvasAspectRatio = 1,
    this.left = 0,
    this.top = 0,
    this.right = 1,
    this.bottom = 1,
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
  /// iPad 横屏使用单独重绘的 4:3 母图，避免把竖屏背景裁切或拉伸。
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
      canvasAspectRatio: 384 / 512,
      left: 110 / 512,
      top: 94 / 384,
      right: 401 / 512,
      bottom: 330 / 384,
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
