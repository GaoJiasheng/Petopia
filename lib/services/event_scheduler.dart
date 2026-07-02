/// EventScheduler（spec-technical §3.4）。
///
/// 事件 / 访客 / 回访 / 明信片统一日程队列（ScheduledJob）的调度与优先级仲裁。
/// 优先级（小=先）：GRADUATION(0) > REVISIT_DUE(1) > SPECIAL_EVENT(2) >
///   VISITOR_CHECK(3) > DAILY_EVENT_GEN(4) > POSTCARD_DUE(5)。
/// 演出串行：同一次上线最多演出 1 组（避免弹窗轰炸，§11.2），其余标「待演出」下次补。
abstract interface class EventScheduler {
  /// 每日 tick：补种当日 job（DAILY_EVENT_GEN×n / VISITOR_CHECK×2 / SPECIAL_EVENT_EVAL），
  /// 并驱动回访、明信片子调度。
  Future<void> onDailyTick(DateTime today);

  /// 上线补处理：对 dueAt<=now 且未 consumed 的 job 按 priority、dueAt 升序处理。
  Future<void> onResume(DateTime now);
}
