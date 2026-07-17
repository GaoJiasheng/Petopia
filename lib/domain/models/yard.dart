// 院子与钱包运行期实体（spec-technical §1.3）。

/// 院子格位。
class YardSlot {
  int pos;
  String? itemId;
  YardSlot({required this.pos, this.itemId});
}

/// 食盆。foodType: grain / fishdry / nuts / apple / null（空盘）。
class FoodTray {
  String? foodType;
  DateTime? placedAt;
  String? probabilityScope;
  double probabilityDelta;
  int remaining;
  FoodTray({
    this.foodType,
    this.placedAt,
    this.probabilityScope,
    this.probabilityDelta = 0,
    this.remaining = 0,
  });
}

/// 院子状态（单例）。
/// 两条独立成长轴：luxuryStage（随累计毕业自动进化，不可自定义）+ activeThemeId（暖绒兑换自定义）。
class YardState {
  int luxuryStage; // 1..6；由 gradCount 派生（0→①,1→②,3→③,5→④,8→⑤,12→⑥）
  int gradCount; // 累计毕业数（驱动 luxuryStage + GradCountUnlock）
  String activeThemeId;
  List<String> ownedThemeIds;
  List<YardSlot> slots; // 格位数随 luxuryStage：4/6/8/10/12/14
  FoodTray foodTray;
  List<String> ownedPerks; // 永久强化（如 toy_yarn_perm）
  List<String> ownedDecorIds; // 已购装饰（驱动访客加成）

  YardState({
    this.luxuryStage = 1,
    this.gradCount = 0,
    this.activeThemeId = 'theme_default',
    List<String>? ownedThemeIds,
    List<YardSlot>? slots,
    FoodTray? foodTray,
    List<String>? ownedPerks,
    List<String>? ownedDecorIds,
  }) : ownedThemeIds = ownedThemeIds ?? <String>['theme_default'],
       slots = slots ?? <YardSlot>[],
       foodTray = foodTray ?? FoodTray(),
       ownedPerks = ownedPerks ?? <String>[],
       ownedDecorIds = ownedDecorIds ?? <String>[];

  int get slotCapacity => switch (luxuryStage.clamp(1, 6)) {
    1 => 4,
    2 => 6,
    3 => 8,
    4 => 10,
    5 => 12,
    _ => 14,
  };

  Set<String> get placedDecorIds => slots
      .map((slot) => slot.itemId)
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet();

  Set<String> get activeDecorIds {
    final active = placedDecorIds;
    for (final id in placedDecorIds) {
      final requirementAlias = switch (id) {
        'night_light' => 'deco_night_lamp',
        'fireplace' => 'deco_stove',
        'wind_chime' => 'deco_shiny_bells',
        _ => null,
      };
      if (requirementAlias != null) active.add(requirementAlias);
    }
    if (luxuryStage >= 3) active.add('deco_tree');
    if (luxuryStage >= 4) active.add('deco_pond');
    return active;
  }
}

/// 暖绒钱包（单例）。balance≥0；INV-4（==Σcurrency_log.delta）。
class CurrencyWallet {
  int balance;
  CurrencyWallet({this.balance = 0});
}
