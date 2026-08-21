import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class StartupMetrics {
  StartupMetrics._();

  static Stopwatch? _clock;
  static bool _reported = false;

  static void start() {
    _clock ??= Stopwatch()..start();
  }

  static void markFirstInteractiveFrame() {
    final clock = _clock;
    if (_reported || clock == null) return;
    _reported = true;
    final elapsedMs = clock.elapsedMilliseconds;
    developer.Timeline.instantSync(
      'Petopia.firstInteractiveFrame',
      arguments: <String, Object?>{'elapsedMs': elapsedMs},
    );
    debugPrint('Hearth & Tails first interactive frame: ${elapsedMs}ms');
  }
}
