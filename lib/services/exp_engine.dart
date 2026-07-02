import '../domain/enums.dart';
import '../domain/models/pet.dart';

/// 加经验结果。
class ExpResult {
  final int deltaApplied; // 实际加的经验（加成/取整后）
  final int levelBefore;
  final int levelAfter;
  final bool leveledUp;
  final bool evolved; // 是否跨 stage 阈值
  final bool graduated; // 是否达 Lv10

  const ExpResult({
    required this.deltaApplied,
    required this.levelBefore,
    required this.levelAfter,
    required this.leveledUp,
    required this.evolved,
    required this.graduated,
  });

  static const ExpResult noop = ExpResult(
    deltaApplied: 0,
    levelBefore: 0,
    levelAfter: 0,
    leveledUp: false,
    evolved: false,
    graduated: false,
  );
}

/// ExpEngine（spec-technical §3.2）。
///
/// 唯一加经验入口：负责性格加成(floor)、升级、换档、写审计流水。
/// 任何经验变动必须经此。不变量 INV-1（exp==Σ流水）、INV-5（delta≥0）。
abstract interface class ExpEngine {
  /// 统一加经验。写 ExpLogEntry；触发升级/换档/毕业。
  /// OFFLINE/EVENT 等不吃动作加成时传 applyPersonalityBonus=false。
  ExpResult addExp({
    required Pet pet,
    required int baseDelta,
    required ExpSource source,
    String? sourceRef,
    String? note,
    bool applyPersonalityBonus,
  });

  /// 结算离线经验（供 ClockService 结果调用）。内部含单段+自然日双上限 + renew。
  ExpResult grantOffline({required Pet pet, required Duration elapsed});
}
