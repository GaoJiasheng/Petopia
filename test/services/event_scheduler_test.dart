import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/services/event_scheduler_impl.dart';

void main() {
  final today = DateTime.utc(2026, 7, 2);
  late List<ScheduledJob> queue;
  late Set<String> gen;
  late List<ScheduledJob> dispatched;
  var idc = 0;

  EventSchedulerImpl build({double rng = 0.0}) {
    return EventSchedulerImpl(
      queue,
      gen,
      () => 'j${idc++}',
      () => rng,
      (j) async => dispatched.add(j),
    );
  }

  setUp(() {
    queue = [];
    gen = {};
    dispatched = [];
    idc = 0;
  });

  test('优先级映射', () {
    expect(EventSchedulerImpl.priorityOf(JobType.revisitDue), 1);
    expect(EventSchedulerImpl.priorityOf(JobType.specialEventEval), 2);
    expect(EventSchedulerImpl.priorityOf(JobType.visitorCheck), 3);
    expect(EventSchedulerImpl.priorityOf(JobType.dailyEventGen), 4);
    expect(EventSchedulerImpl.priorityOf(JobType.postcardDue), 5);
  });

  test('onDailyTick 补种：rng0 → 1日常+2访客+1特殊 = 4 job', () async {
    await build(rng: 0.0).onDailyTick(today);
    expect(queue.length, 4);
    expect(queue.where((j) => j.type == JobType.dailyEventGen).length, 1);
    expect(queue.where((j) => j.type == JobType.visitorCheck).length, 2);
    expect(queue.where((j) => j.type == JobType.specialEventEval).length, 1);
  });

  test('onDailyTick 幂等：同一天二次 tick 不重复补种', () async {
    final s = build(rng: 0.99); // n = 1 + floor(0.99*3)=1+2=3 日常
    await s.onDailyTick(today);
    final after1 = queue.length; // 3+2+1=6
    await s.onDailyTick(today);
    expect(queue.length, after1); // 不变
    expect(after1, 6);
  });

  test('onDailyTick 将来客与事件分布到真实日夜时窗', () async {
    await build(rng: 0.0).onDailyTick(today);
    final dayVisitor = queue.singleWhere(
      (job) => job.type == JobType.visitorCheck && job.payloadRef == 'day',
    );
    final nightVisitor = queue.singleWhere(
      (job) => job.type == JobType.visitorCheck && job.payloadRef == 'night',
    );
    final daily = queue.singleWhere((job) => job.type == JobType.dailyEventGen);
    final special = queue.singleWhere(
      (job) => job.type == JobType.specialEventEval,
    );

    expect(
      (dayVisitor.dueAt.toLocal().hour, dayVisitor.dueAt.toLocal().minute),
      (7, 30),
    );
    expect(
      (nightVisitor.dueAt.toLocal().hour, nightVisitor.dueAt.toLocal().minute),
      (19, 30),
    );
    expect(
      (daily.dueAt.toLocal().hour, daily.dueAt.toLocal().minute),
      (10, 15),
    );
    expect(
      (special.dueAt.toLocal().hour, special.dueAt.toLocal().minute),
      (21, 15),
    );
  });

  test('onResume 按优先级、dueAt 升序处理并置 consumed', () async {
    final s = build();
    // 手动塞入乱序 job（同 today 到期）
    s.enqueue(JobType.postcardDue, today); // pri5
    s.enqueue(JobType.revisitDue, today); // pri1
    s.enqueue(JobType.visitorCheck, today); // pri3
    await s.onResume(today);
    expect(dispatched.map((j) => j.type).toList(), [
      JobType.revisitDue,
      JobType.visitorCheck,
      JobType.postcardDue,
    ]);
    expect(queue.every((j) => j.consumed), true);
  });

  test('onResume 不处理未来到期的 job', () async {
    final s = build();
    s.enqueue(JobType.dailyEventGen, today.add(const Duration(days: 1))); // 明天
    await s.onResume(today);
    expect(dispatched, isEmpty);
    expect(queue.single.consumed, false);
  });

  test('日切只清理超出窗口的已完成历史，未完成任务始终保留', () async {
    queue.addAll([
      ScheduledJob(
        id: 'old-consumed',
        type: JobType.dailyEventGen,
        dueAt: today.subtract(const Duration(days: 91)),
        priority: 4,
        consumed: true,
      ),
      ScheduledJob(
        id: 'old-pending',
        type: JobType.revisitDue,
        dueAt: today.subtract(const Duration(days: 180)),
        priority: 1,
      ),
      ScheduledJob(
        id: 'recent-consumed',
        type: JobType.visitorCheck,
        dueAt: today.subtract(const Duration(days: 20)),
        priority: 3,
        consumed: true,
      ),
    ]);
    gen.addAll({'2026-02-01', '2026-07-01'});

    await build().onDailyTick(today);

    expect(queue.any((job) => job.id == 'old-consumed'), isFalse);
    expect(queue.any((job) => job.id == 'old-pending'), isTrue);
    expect(queue.any((job) => job.id == 'recent-consumed'), isTrue);
    expect(gen, isNot(contains('2026-02-01')));
    expect(gen, containsAll(<String>['2026-07-01', '2026-07-02']));
  });
}
