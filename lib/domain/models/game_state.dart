import '../enums.dart';

/// 其余运行期实体（spec-technical §1.3）：旅程 / 彩蛋计数 / 成就进度 /
/// 来客记录 / 日程作业 / 全局设置。

/// 旅程。stops 为 25 个主旅程 locationId；wanderStops 为剩余地点。
class Journey {
  String id;
  String petId;
  List<String> stops;
  List<String> wanderStops;
  int currentIdx; // 0..stops.length
  int wanderIdx; // 0..wanderStops.length
  int longTermSeq; // 40 张完成后的长期循环寄片序号
  DateTime nextPostcardAt;
  JourneyState state; // ACTIVE→WANDERING（补完剩余地点）→ 永久 WANDERING

  Journey({
    required this.id,
    required this.petId,
    required this.stops,
    required this.nextPostcardAt,
    List<String>? wanderStops,
    this.currentIdx = 0,
    this.wanderIdx = 0,
    this.longTermSeq = 0,
    this.state = JourneyState.active,
  }) : wanderStops = wanderStops ?? <String>[];
}

/// 彩蛋线索计数。count 单调递增；visitorSeen 控制线索两段式显示。
class ClueCounter {
  String clueId; // 主键，如 clue_ember
  int count;
  int threshold; // 达标值（源 §2 clueThresholds）
  bool visitorSeen; // 访客前置是否已达成

  ClueCounter({
    required this.clueId,
    required this.threshold,
    this.count = 0,
    this.visitorSeen = false,
  });
}

/// 成就进度。unlockedAt 非空=已解锁；rewardClaimed 防重复发奖。
class AchievementProgress {
  String achievementId; // 主键
  int progress;
  DateTime? unlockedAt;
  bool rewardClaimed;

  AchievementProgress({
    required this.achievementId,
    this.progress = 0,
    this.unlockedAt,
    this.rewardClaimed = false,
  });
}

/// 来客图鉴数据源：每次到访一条。
class VisitorLogEntry {
  String id;
  String visitorId;
  DateTime date;
  String? interactionId; // 命中的互动
  String? withPetId; // 当时在养宠

  VisitorLogEntry({
    required this.id,
    required this.visitorId,
    required this.date,
    this.interactionId,
    this.withPetId,
  });
}

/// 当前正在院子里停留的访客。到访会进入图鉴日志；这里负责首页驻留和弹框状态。
class ActiveVisitor {
  String visitorId;
  DateTime arrivedAt;
  DateTime leavesAt;
  String? interactionId;
  String? withPetId;
  bool arrivalSeen;

  ActiveVisitor({
    required this.visitorId,
    required this.arrivedAt,
    required this.leavesAt,
    this.interactionId,
    this.withPetId,
    this.arrivalSeen = false,
  });
}

/// 统一日程队列作业（EventScheduler，§3.4）。priority 小=优先。
class ScheduledJob {
  String id;
  JobType type;
  DateTime dueAt;
  int priority;
  String? payloadRef; // petId/visitorId/eventId
  bool consumed; // 处理后置 true（保留便于审计）

  ScheduledJob({
    required this.id,
    required this.type,
    required this.dueAt,
    required this.priority,
    this.payloadRef,
    this.consumed = false,
  });
}

/// 全局设置（单例）。含时钟锚点（§4 防调表）与连续登录状态。
class Settings {
  bool notifications;
  bool sound;
  int schemaVersion; // 迁移用
  DateTime createdAt;
  int lastMonotonicRef; // 单调时钟基准（毫秒，§4）
  DateTime lastWallClockAt; // 上次记录的真实时钟（§4 交叉校验）
  int loginStreakCurrent;
  int loginStreakMax;
  String lastLoginDay; // yyyy-MM-dd

  Settings({
    required this.createdAt,
    required this.lastWallClockAt,
    this.notifications = true,
    this.sound = true,
    this.schemaVersion = 1,
    this.lastMonotonicRef = 0,
    this.loginStreakCurrent = 0,
    this.loginStreakMax = 0,
    this.lastLoginDay = '',
  });
}
