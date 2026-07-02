import 'enums.dart';

/// 商品效果（spec-technical §1.2；补全 §10 effect{type,params}）。
///
/// 各 EffectType 的 params 结构（钉死）：
/// - THEME_SKIN: {themeId:String} (+可选 visitorProbBonus:{scope,delta})
/// - DECOR: {decorId:String}
/// - FEED_BONUS: {expFrom:3, expTo:6}（该次喂食经验改写；消耗品）
/// - TOY_PERMANENT_BONUS: {expFrom:4, expTo:6}（永久，写 ownedPerks）
/// - ALBUM_SKIN: {skinId:String}
/// - VISITOR_PROB: {scope:"night"|"legendary"|"birds"|..., delta:0.05}
class ItemEffect {
  final EffectType type;
  final Map<String, dynamic> params;
  const ItemEffect({required this.type, required this.params});
}
