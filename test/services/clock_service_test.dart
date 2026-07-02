import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/clock_service_impl.dart';

/// 可控假时钟：wall 与 mono 独立设置，模拟改表/进程连续性。
class FakeClock implements Clock {
  DateTime wall;
  int mono; // 毫秒
  FakeClock(this.wall, this.mono);
  @override
  DateTime wallNow() => wall;
  @override
  int monotonicMillis() => mono;
}

Settings _newSettings(DateTime t) => Settings(createdAt: t, lastWallClockAt: t);

void main() {
  final t0 = DateTime.utc(2026, 7, 2, 12);

  group('ClockService.resolveOfflineElapsed', () {
    test('正常离线：wall 与 mono 同步推进 3 小时 → 3 小时', () {
      final clock = FakeClock(t0, 1000);
      final svc = ClockServiceImpl(clock, _newSettings(t0));
      svc.markHeartbeat(); // 记录 mono=1000 @ t0
      // 推进 3 小时
      clock.wall = t0.add(const Duration(hours: 3));
      clock.mono = 1000 + const Duration(hours: 3).inMilliseconds;
      final e = svc.resolveOfflineElapsed(lastOnlineAt: t0);
      expect(e, const Duration(hours: 3));
    });

    test('改表往未来：wall 跳 +10h 但 mono 仅 +2h → 取 min = 2h（少给）', () {
      final clock = FakeClock(t0, 1000);
      final svc = ClockServiceImpl(clock, _newSettings(t0));
      svc.markHeartbeat();
      clock.wall = t0.add(const Duration(hours: 10)); // 用户改表
      clock.mono = 1000 + const Duration(hours: 2).inMilliseconds; // 真实只过了 2h
      final e = svc.resolveOfflineElapsed(lastOnlineAt: t0);
      expect(e, const Duration(hours: 2));
    });

    test('改表回拨：wall 早于 lastOnlineAt → 0（绝不倒扣）', () {
      final clock = FakeClock(t0, 1000);
      final svc = ClockServiceImpl(clock, _newSettings(t0));
      svc.markHeartbeat();
      clock.wall = t0.subtract(const Duration(hours: 5)); // 往回拨
      clock.mono = 1000 + const Duration(hours: 1).inMilliseconds;
      final e = svc.resolveOfflineElapsed(lastOnlineAt: t0);
      expect(e, Duration.zero);
    });

    test('冷启动（无心跳锚点）：单调失效，只信 wall', () {
      final clock = FakeClock(t0.add(const Duration(hours: 5)), 500);
      final svc = ClockServiceImpl(clock, _newSettings(t0));
      // 不调用 markHeartbeat → _monoRefAtLastOnline 为 null
      final e = svc.resolveOfflineElapsed(lastOnlineAt: t0);
      expect(e, const Duration(hours: 5));
    });

    test('markHeartbeat 写入 Settings 锚点', () {
      final clock = FakeClock(t0, 4242);
      final settings = _newSettings(t0.subtract(const Duration(days: 1)));
      final svc = ClockServiceImpl(clock, settings);
      svc.markHeartbeat();
      expect(settings.lastMonotonicRef, 4242);
      expect(settings.lastWallClockAt, t0);
    });
  });
}
