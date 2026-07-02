/// 可注入时钟（便于单测假时钟）。
abstract interface class Clock {
  /// 真实时钟（wall clock）UTC。
  DateTime wallNow();

  /// 单调时钟（毫秒）；进程/开机周期内单调递增，用于防调表交叉校验。
  int monotonicMillis();
}

/// ClockService（spec-technical §3.1 / §4）。
///
/// 权威「现在」+ 离线时长结算 + 防调表。所有时间相关逻辑的唯一时间源。
/// 原则：宁可少给、绝不误伤、绝不倒扣、绝不惩罚离线。
abstract interface class ClockService {
  /// 可信 now（UTC）。
  DateTime now();

  /// 从后台恢复/冷启动时调用。返回本次可结算的离线时长（钳制后，永不为负）。
  ///
  /// 算法（§4.2）：wallElapsed = wallNow - lastOnlineAt；若单调时钟仍有效
  /// 取 min(wallElapsed, monoElapsed)（宁可少给）；elapsed<0 → 0（回拨不倒扣）。
  /// 上限钳制交给 ExpEngine（offlineSingleCap）。
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt});

  /// 记录心跳锚点（写 Settings.lastMonotonicRef / lastWallClockAt）。
  void markHeartbeat();
}
