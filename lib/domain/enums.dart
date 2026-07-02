/// Petopia · 全局枚举全集
///
/// 对应 spec-technical.md §1.1（钉死）。所有枚举值序列化时用「名称字符串」，
/// 与 assets/data/*.json 的字符串枚举一一对应。
///
/// 注意：`TimeOfDayOfDay` 刻意避开 Flutter Material 的 `TimeOfDay`。
library;

enum PetCategory { real, fantasy }

/// 成长档：幼崽 / 少年 / 成年 / 旅装（Lv5→B、Lv8→C、Lv10→D 换模）。
enum PetStage { a, b, c, d }

enum PetState { raising, traveling, roaming, revisiting, graduated }

/// 经验来源 —— 所有加经验必须带来源，写入 ExpLogEntry（审计）。
enum ExpSource {
  feed,
  pat,
  toy,
  bath,
  offline,
  eventDaily,
  eventSpecial,
  visitor,
  revisit,
  itemBonus,
}

/// 暖绒收支原因 —— 所有收支写入 CurrencyLog（审计）。
enum CurrencyReason {
  graduation,
  dailyFirstCare,
  levelUp,
  achievement,
  revisitGift,
  shopPurchase,
  eventReward,
  importAdjust,
}

enum EventType { daily, special, revisit, graduation }

enum VisitorRarity { common, uncommon, rare, legendary }

enum Season { spring, summer, autumn, winter }

/// 时段 —— 名称避开 Flutter 的 `TimeOfDay`。
enum TimeOfDayOfDay { dawn, morning, noon, afternoon, evening, night }

enum Weather { clear, cloudy, rain, thunder, snow, fog, rainbow }

/// 图鉴四态（spec-technical §1.2）。
enum DexState { ownedBefore, available, lockedKnown, lockedHidden }

enum UnlockRuleType { initial, gradCount, hiddenClue }

enum EffectType {
  themeSkin,
  decor,
  feedBonus,
  toyPermanentBonus,
  albumSkin,
  visitorProb,
}

/// 成就条件类型；`custom` = 需专用判定器的隐藏成就。
enum AchievementCondType {
  gradCount,
  speciesCollected,
  postcardCount,
  visitorDexCount,
  actionCount,
  revisitCount,
  loginStreak,
  specialEventCount,
  yardStage,
  themeCount,
  stampCount,
  seasonPostcard,
  unlockPet,
  custom,
}

/// 统一日程队列的作业类型（EventScheduler）。
enum JobType {
  dailyEventGen,
  visitorCheck,
  revisitDue,
  postcardDue,
  specialEventEval,
}

enum JourneyState { active, wandering, done }
