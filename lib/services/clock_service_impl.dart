import '../domain/models/game_state.dart' show Settings;
import 'clock_service.dart';

/// 系统时钟：真实时钟 + 进程内单调时钟（Stopwatch）。
///
/// 单调时钟仅在**同一进程存活期内**单调有效（杀进程/重启即失效）。
class SystemClock implements Clock {
  final Stopwatch _sw = Stopwatch()..start();

  @override
  DateTime wallNow() => DateTime.now().toUtc();

  @override
  int monotonicMillis() => _sw.elapsedMilliseconds;
}

/// ClockService 实现（spec-technical §3.1 / §4）。
///
/// 防调表核心：离线时长取 min(wallElapsed, monoElapsed)（宁可少给）；
/// 回拨 → 0（绝不倒扣）。单调锚点仅进程内有效——冷启动无锚点时只信 wall，
/// 由 ExpEngine 的 offlineSingleCap/dailyCap 兜底封顶，无套利空间。
class ClockServiceImpl implements ClockService {
  final Clock _clock;
  final Settings _settings;

  /// 上次 markHeartbeat 记录的单调值（进程内内存）。null = 单调不可用（冷启动/重启）。
  int? _monoRefAtLastOnline;

  ClockServiceImpl(this._clock, this._settings);

  @override
  DateTime now() => _clock.wallNow();

  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) {
    final wallElapsed = _clock.wallNow().difference(lastOnlineAt);
    Duration elapsed;
    final ref = _monoRefAtLastOnline;
    if (ref != null) {
      // 单调时钟自上次在线起仍连续有效：取二者较小（改表往前时 mono 更小 → 少给）。
      final monoElapsed = Duration(milliseconds: _clock.monotonicMillis() - ref);
      elapsed = wallElapsed <= monoElapsed ? wallElapsed : monoElapsed;
    } else {
      // 进程重启/冷启动，单调失效，只能信 wall（上限钳制交给 ExpEngine）。
      elapsed = wallElapsed;
    }
    // 时钟回拨 → 归零，绝不倒扣。
    if (elapsed.isNegative) elapsed = Duration.zero;
    return elapsed;
  }

  @override
  void markHeartbeat() {
    final mono = _clock.monotonicMillis();
    _monoRefAtLastOnline = mono;
    _settings.lastMonotonicRef = mono;
    _settings.lastWallClockAt = _clock.wallNow();
  }
}
