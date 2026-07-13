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
  static String themeBg(String themeId) {
    final slug = _themeSlug[themeId] ?? 'meadow';
    return 'assets/art/world/themes/yard_theme_${slug}_bg.jpg';
  }

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
}
