import 'enums.dart';

/// 宠物解锁规则（spec-technical §1.2；补全 §10 待细化）。
/// 三 variant，判别字段 [type]。
sealed class UnlockRule {
  UnlockRuleType get type;
  const UnlockRule();
}

/// 初始可养。
class InitialUnlock extends UnlockRule {
  const InitialUnlock();
  @override
  UnlockRuleType get type => UnlockRuleType.initial;
}

/// 累计毕业数 ≥ [threshold] 解锁。
class GradCountUnlock extends UnlockRule {
  final int threshold;
  const GradCountUnlock(this.threshold);
  @override
  UnlockRuleType get type => UnlockRuleType.gradCount;
}

/// 彩蛋：先以 [visitorPrereqId] 访客形态出现过（两段式线索开关），
/// 再由 [hiddenSteps] 累计达成使 clueCounter[clueId] 达 [threshold] 解锁。
class HiddenClueUnlock extends UnlockRule {
  final String clueId; // 关联 ClueCounter，如 clue_ember
  final int threshold;
  final String clueText; // LOCKED_HIDDEN 状态显示的谜语句
  final String visitorPrereqId; // 访客前置 ID（§8.1 传说访客）
  final List<HiddenStep> hiddenSteps;

  const HiddenClueUnlock({
    required this.clueId,
    required this.threshold,
    required this.clueText,
    required this.visitorPrereqId,
    required this.hiddenSteps,
  });

  @override
  UnlockRuleType get type => UnlockRuleType.hiddenClue;
}

/// 单条隐藏条件（供 UnlockService 逐条累计）。
class HiddenStep {
  final String stepId;
  final AchievementCondType condType; // 复用条件类型枚举
  final Map<String, dynamic> params; // 如 {timeWindow:"23:00-02:00", requireEmptyFood:true, count:5}

  const HiddenStep({
    required this.stepId,
    required this.condType,
    required this.params,
  });
}
