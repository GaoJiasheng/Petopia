import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/game_state.dart';
import 'event_scheduler.dart';

/// EventScheduler 实现（spec-technical §3.4）。
///
/// 事件/访客/回访/明信片统一日程队列（ScheduledJob）+ 优先级仲裁。
/// 每日 tick 补种当日 job；上线按优先级、dueAt 升序处理。
/// 单个 job 的实际执行委派给注入的 [_dispatch]（由装配层接各 Service）。
class EventSchedulerImpl implements EventScheduler {
  final List<ScheduledJob> _queue; // 生产由 JobRepository 持久化
  final Set<String> _generatedDays; // 已补种的自然日 yyyy-MM-dd
  final String Function() _idGen;
  final double Function() _rng;
  final Future<void> Function(ScheduledJob) _dispatch;

  EventSchedulerImpl(
    this._queue,
    this._generatedDays,
    this._idGen,
    this._rng,
    this._dispatch,
  );

  /// 优先级（小=先）：REVISIT_DUE(1) > SPECIAL(2) > VISITOR(3) > DAILY_GEN(4) > POSTCARD(5)。
  static int priorityOf(JobType t) => switch (t) {
    JobType.revisitDue => 1,
    JobType.specialEventEval => 2,
    JobType.visitorCheck => 3,
    JobType.dailyEventGen => 4,
    JobType.postcardDue => 5,
  };

  @override
  Future<void> onDailyTick(DateTime today) async {
    final key = _dayKey(today);
    if (_generatedDays.contains(key)) return; // 幂等：当日只补种一次
    _generatedDays.add(key);

    final range = GameConfig.dailyEventMax - GameConfig.dailyEventMin + 1;
    final n = GameConfig.dailyEventMin + (_rng() * range).floor(); // 1..3
    const dailyHours = <int>[10, 14, 17];
    for (var i = 0; i < n; i++) {
      _enqueue(JobType.dailyEventGen, _localTime(today, dailyHours[i], 15));
    }
    _enqueue(JobType.visitorCheck, _localTime(today, 7, 30), ref: 'day');
    _enqueue(JobType.visitorCheck, _localTime(today, 19, 30), ref: 'night');
    _enqueue(JobType.specialEventEval, _localTime(today, 20, 45));
    // REVISIT_DUE / POSTCARD_DUE 由各自服务在需要时 enqueue（见 enqueue）。
  }

  @override
  Future<void> onResume(DateTime now) async {
    final due =
        _queue.where((j) => !j.consumed && !j.dueAt.isAfter(now)).toList()
          ..sort((a, b) {
            final p = a.priority.compareTo(b.priority);
            return p != 0 ? p : a.dueAt.compareTo(b.dueAt);
          });
    for (final job in due) {
      await _dispatch(job);
      job.consumed = true; // 保留不删，便于审计
    }
  }

  /// 供其他服务补充 job（如回访到期、明信片到点）。
  void enqueue(JobType type, DateTime dueAt, {String? ref}) =>
      _enqueue(type, dueAt, ref: ref);

  void _enqueue(JobType type, DateTime dueAt, {String? ref}) {
    _queue.add(
      ScheduledJob(
        id: _idGen(),
        type: type,
        dueAt: dueAt,
        priority: priorityOf(type),
        payloadRef: ref,
      ),
    );
  }

  String _dayKey(DateTime t) {
    final local = t.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  DateTime _localTime(DateTime day, int hour, int minute) {
    final local = day.toLocal();
    return DateTime(local.year, local.month, local.day, hour, minute).toUtc();
  }
}
