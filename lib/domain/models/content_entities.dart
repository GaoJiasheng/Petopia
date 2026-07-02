import '../enums.dart';
import '../unlock_rule.dart';
import '../item_effect.dart';

/// 静态只读内容实体（spec-technical §1.2）。
///
/// 由 assets/data/*.json 加载，运行期常驻内存（ContentRepository）。
/// 全部为不可变值对象（final 字段）。

/// 宠物物种（12 种）。
class PetSpecies {
  final String id; // pet_cat 等
  final String name;
  final PetCategory category;
  final String baseTone; // 基调关键词（展示）
  final UnlockRule unlockRule;
  final List<String> variantIds; // 长度=5
  final String dexArtRef; // 彩色插画
  final String dexSilhouetteRef; // 铅笔剪影
  final String? dexMysteryRef; // 问号渍（仅彩蛋宠）

  const PetSpecies({
    required this.id,
    required this.name,
    required this.category,
    required this.baseTone,
    required this.unlockRule,
    required this.variantIds,
    required this.dexArtRef,
    required this.dexSilhouetteRef,
    this.dexMysteryRef,
  });
}

/// 性格标签（10 个）。
class PersonalityTag {
  final String id; // p_glutton 等
  final String name;
  final String persona; // 一句话人设
  final Map<String, double> eventWeightMap; // 事件 tag -> 乘数
  final Map<ExpSource, double> actionExpBonus; // 如 {FEED:0.10}
  final String actionSetId; // 专属动作库引用
  final String postcardStyleId; // 文风模板库引用
  final List<String> specialFlags; // 如 lazy_offline_cap / aloof_pat_reject

  const PersonalityTag({
    required this.id,
    required this.name,
    required this.persona,
    required this.eventWeightMap,
    required this.actionExpBonus,
    required this.actionSetId,
    required this.postcardStyleId,
    required this.specialFlags,
  });
}

/// 旅行目的地（~40 个）。
class Location {
  final String id;
  final String name;
  final String category; // 海滨/山地/城市/乡野/森林/沙漠异域/极地水域/奇幻
  final String climate;
  final List<String> vibeTags; // 用于 incidentPool 选择
  final String photoStyle; // 背景板资产键
  final String encounterPoolId; // 遭遇池引用
  final Map<String, double> personalityWeight; // 性格→抽取权重
  final String stampId; // 邮戳徽章

  const Location({
    required this.id,
    required this.name,
    required this.category,
    required this.climate,
    required this.vibeTags,
    required this.photoStyle,
    required this.encounterPoolId,
    required this.personalityWeight,
    required this.stampId,
  });
}

/// 野生访客（20 种）。
class Visitor {
  final String id;
  final String name;
  final VisitorRarity rarity;
  final List<TimeOfDayOfDay> activeTime; // 空=不限
  final Map<Weather, double> weatherPref; // M_weather，缺省 1.0
  final Map<String, double> foodPref; // key=foodType，M_food
  final Map<Season, double> seasonPref; // 缺省 1.0
  final List<String> decorReq; // 必要装饰；空=无
  final String? clueRole; // 关联 clueId（传说访客）
  final String artRef; // 肖像

  const Visitor({
    required this.id,
    required this.name,
    required this.rarity,
    required this.activeTime,
    required this.weatherPref,
    required this.foodPref,
    required this.seasonPref,
    required this.decorReq,
    required this.artRef,
    this.clueRole,
  });
}

/// 访客 × 宠物专属互动（§8.4）。
/// 选取优先级：exact(visitor,species,personality) > exact(visitor,species) > fallback(visitor,"*")。
class VisitorPetInteraction {
  final String id;
  final String visitorId;
  final String petSpeciesId; // "*" = 兜底
  final List<String>? personalityBias; // 命中某性格替换
  final String script;
  final String animRef;
  final int expReward; // 3..6
  final String? unlockClue; // clueId+1

  const VisitorPetInteraction({
    required this.id,
    required this.visitorId,
    required this.petSpeciesId,
    required this.script,
    required this.animRef,
    required this.expReward,
    this.personalityBias,
    this.unlockClue,
  });
}

/// 事件触发权重（§9.1）。
class EventWeights {
  final Map<String, double> personality; // tagId -> mult
  final Map<Weather, double> weather;
  final Map<TimeOfDayOfDay, double> timeOfDay;
  final Map<Season, double> season;
  final String? requiresVisitor; // visitorId 在场
  final String? requiresDecor; // decorId 存在
  final int? minLevel;
  final int? minLuxuryStage;

  const EventWeights({
    this.personality = const {},
    this.weather = const {},
    this.timeOfDay = const {},
    this.season = const {},
    this.requiresVisitor,
    this.requiresDecor,
    this.minLevel,
    this.minLuxuryStage,
  });
}

/// 事件二选一分支。
class EventChoice {
  final String text;
  final String resultScript;
  final int expDelta;
  const EventChoice({
    required this.text,
    required this.resultScript,
    required this.expDelta,
  });
}

/// 事件定义（§9.1）。DAILY exp 2..8 / SPECIAL 8..20。
class Event {
  final String id; // ev_dNN / ev_sNN
  final EventType type;
  final String title;
  final String script;
  final String? animRef;
  final String? illustrationRef; // 特殊事件插画
  final int expReward;
  final int? currencyReward;
  final EventWeights weights;
  final int cooldownDays; // 默认 0
  final bool oncePerPet; // 默认 false
  final List<EventChoice>? choices;

  const Event({
    required this.id,
    required this.type,
    required this.title,
    required this.script,
    required this.expReward,
    required this.weights,
    this.animRef,
    this.illustrationRef,
    this.currencyReward,
    this.cooldownDays = 0,
    this.oncePerPet = false,
    this.choices,
  });
}

/// 成就条件（§1.5）。
class AchievementCond {
  final AchievementCondType type;
  final int target;
  final Map<String, dynamic> params;
  const AchievementCond({
    required this.type,
    required this.target,
    this.params = const {},
  });
}

/// 成就奖励。隐藏成就统一 fluff:40 + stickerId。
class RewardSpec {
  final int fluff;
  final String? decorItemId;
  final String? couponId;
  final String? stickerId;
  const RewardSpec({
    this.fluff = 0,
    this.decorItemId,
    this.couponId,
    this.stickerId,
  });
}

/// 成就定义（§1.5）。
class Achievement {
  final String id;
  final String name; // 达成后可见名
  final bool hidden;
  final String? clueText; // 隐藏成就未达成时显示谜语
  final AchievementCond condition;
  final RewardSpec reward;

  const Achievement({
    required this.id,
    required this.name,
    required this.hidden,
    required this.condition,
    required this.reward,
    this.clueText,
  });
}

/// 商店商品（§4.3）。
class ShopItem {
  final String id;
  final String category; // 院子主题/装饰小物/特殊食粮/特殊玩具/明信片
  final String name;
  final int price; // 暖绒
  final ItemEffect effect;
  final String artRef;
  final bool consumable; // 食粮=true
  final int? stackCount; // 如「×5」

  const ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.effect,
    required this.artRef,
    this.consumable = false,
    this.stackCount,
  });
}
