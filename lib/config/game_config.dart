/// Petopia · 游戏配置常量（Game Config）
///
/// 对应 spec-technical.md §2（初值钉死）。
/// 「锁定」= 改动会破坏节奏/审计承诺，需评审；「可调」= playtest 可校准。
///
/// 承载方式：本版用 `static const` 常量类（编译期常量、可单测、零加载成本）。
/// 若后续需策划改数不改码，可切换为从 `assets/data/game_config.json` 解析并保持同名字段。
library;

abstract final class GameConfig {
  // ── 2.1 经验与动作 ─────────────────────────────
  static const int feedExp = 3; // 可调
  static const int feedCooldownMin = 15; // 锁定
  static const int feedDailyCap = 12; // 锁定
  static const int patExp = 1; // 可调
  static const int patCooldownMin = 10; // 锁定
  static const int patDailyCap = 16; // 锁定
  static const int toyExp = 4; // 可调
  static const int toyCooldownMin = 20; // 锁定
  static const int toyDailyCap = 8; // 锁定
  static const int bathExp = 6; // 可调
  static const int bathDailyCap = 1; // 锁定（按自然日，无分钟冷却）
  static const double gluttonFeedBonus = 0.10; // 可调：贪吃喂食 +10%
  static const double energeticToyBonus = 0.10; // 可调：活力玩具 +10%
  // 加成取整规则：向下取整（避免通胀）。锁定。见 ExpEngine。
  static const String bonusRounding = 'floor';

  // ── 2.2 离线 ───────────────────────────────────
  static const int offlineExpPerHour = 1; // 锁定
  static const int offlineSingleCap = 12; // 锁定：单段结算封顶
  static const int offlineDailyCap = 12; // 锁定：自然日累计上限
  static const int lazyOfflineDailyCap = 13; // 可调：慵懒标签特例
  static const int clockDriftForgiveSec = 120; // 锁定：真实时钟回拨容忍窗

  // ── 2.3 经验曲线（锁定；累计 800）─────────────────
  /// 升到「下一级」所需经验；索引 = 当前等级(1..9)，[0] 占位不用。
  static const List<int> levelUpCost = [
    0, // idx0 占位
    30, 45, 60, 75, 90, 105, 120, 130, 145,
  ];

  /// 进入该级的累计门槛（冗余，便于二分 deriveLevel）；索引 = level-1（Lv1..Lv10）。
  static const List<int> cumExpAtLevel = [
    0, 30, 75, 135, 210, 300, 405, 525, 655, 800,
  ];

  static const int maxLevel = 10;
  static const int graduationExp = 800; // Lv10 毕业门槛
  static const int stageBLevel = 5; // Lv5 → 少年（换模）
  static const int stageCLevel = 8; // Lv8 → 成年（换模）
  static const int stageDLevel = 10; // Lv10 → 旅装（换模+毕业）

  // ── 2.4 经济 / 暖绒 ────────────────────────────
  static const int gradBaseFluff = 200; // 锁定
  static const int gradPerEventFluff = 2; // 可调
  static const int gradEventCapFluff = 100; // 可调
  static const int gradPerVisitorFluff = 3; // 可调
  static const int gradVisitorCapFluff = 60; // 可调
  static const int gradEasterEggBonus = 80; // 可调（彩蛋宠）
  static const int dailyFirstCareFluff = 5; // 可调
  static const int levelUpFluff = 10; // 可调：每升 1 级
  static const int revisitGiftMin = 10; // 可调
  static const int revisitGiftMax = 20; // 可调

  // ── 2.5 访客 ───────────────────────────────────
  static const double baseProbCommon = 0.35; // 可调
  static const double baseProbUncommon = 0.15; // 可调
  static const double baseProbRare = 0.06; // 可调
  static const double baseProbLegendary = 0.015; // 可调
  static const int dayWindowStartHour = 6; // 锁定：白天访客窗 06:00–09:00
  static const int dayWindowEndHour = 9;
  static const int nightWindowStartHour = 18; // 锁定：夜间访客窗 18:00–21:00
  static const int nightWindowEndHour = 21;
  static const double emptyTrayMult = 0.8; // 可调：空盘全体 ×0.8（不惩罚）
  static const double luxuryStage2AllBonus = 0.05; // 可调：阶段②起全体绝对值
  static const double luxuryStage5LegendaryBonus = 0.02; // 可调：阶段⑤起传说绝对值
  static const double revisitBringFriendProb = 0.20; // 可调：回访带旅伴

  // ── 2.6 事件 ───────────────────────────────────
  static const int dailyEventMin = 1; // 可调
  static const int dailyEventMax = 3; // 可调
  static const int specialEventDailyCap = 1; // 锁定
  static const int defaultCooldownDays = 0; // 可调

  // ── 2.7 明信片 / 旅行 ──────────────────────────
  static const int journeyStopsMin = 5; // 可调
  static const int journeyStopsMax = 8; // 可调
  static const int postcardIntervalMinDays = 1; // 可调：旅程中寄片间隔
  static const int postcardIntervalMaxDays = 3;
  static const int wanderPostcardMinDays = 10; // 可调：漫游期低频寄片
  static const int wanderPostcardMaxDays = 15;

  // ── 2.8 回访 ───────────────────────────────────
  static const int revisitWindowMinDays = 7; // 锁定
  static const int revisitWindowMaxDays = 14; // 锁定
  static const int revisitStayMinDays = 1; // 可调
  static const int revisitStayMaxDays = 2; // 可调
  static const int revisitPatPerDay = 1; // 锁定
  static const int revisitPetExp = 5; // 可调（source=REVISIT）
  static const int maxConcurrentRevisit = 1; // 锁定（INV-2）

  // ── 2.9 彩蛋 ClueCounter 阈值 ───────────────────
  static const Map<String, int> clueThresholds = {
    'clue_ember': 3, // 火光访客遇见 3 次（+暖炉+冬夜前置）
    'clue_uni': 2, // 雨后点击彩虹 2 次
    'clue_boo': 5, // 深夜(23:00–02:00)上线且院子无食物累计 5 次
    'clue_starbug': 3, // 星星虫访客 3 次（+夜灯）
  };

  // ── 2.10 存档 ──────────────────────────────────
  static const int autoSaveDebounceMs = 1500; // 可调
  static const int backupSlots = 2; // 锁定：双备份（A/B 轮换）
  static const int currentSchemaVersion = 1; // 锁定
}
