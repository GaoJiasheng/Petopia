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
    return 'assets/art/world/themes/yard_theme_${slug}_bg.png';
  }
}
