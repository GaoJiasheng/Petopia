import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/content_entities.dart';

/// 到访检定窗口。
enum TimeWindow { day, night }

/// VisitorService（spec-technical §3.6 / §8）。
///
/// 到访判定（概率轮盘）+ 互动选取 + 来客图鉴收录。
/// P(v) = Base(rarity) × M_time × M_weather × M_food × M_decor × M_luxury × M_season；
/// 每窗口最多命中 1 只（加权轮盘）；传说访客单独伯努利判定，可与普通同日。
abstract interface class VisitorService {
  /// 普通访客窗口轮盘；miss 返回 null。
  Visitor? rollWindow({
    required TimeWindow window,
    required YardState yard,
    required Weather weather,
    required Season season,
    required DateTime now,
  });

  /// 传说访客独立判定。
  Visitor? rollLegendary({
    required YardState yard,
    required Weather weather,
    required Season season,
    required DateTime now,
  });

  /// 选互动：exact(visitor,species,personality) > exact(visitor,species) > fallback(visitor,"*")。
  VisitorPetInteraction pickInteraction(Visitor v, Pet? pet);

  /// 记录到访：写 VisitorLogEntry + 推进彩蛋 ClueCounter。
  void recordVisit(Visitor v, Pet? pet, VisitorPetInteraction? it);
}
