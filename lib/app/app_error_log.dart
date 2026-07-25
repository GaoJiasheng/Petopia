import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Privacy-safe, local-only runtime error history for support diagnostics.
///
/// Exception messages are deliberately excluded because framework and plugin
/// errors can contain file paths or user-authored values.
class AppErrorLog {
  AppErrorLog._();

  static final AppErrorLog instance = AppErrorLog._();
  static const int _maxEntries = 24;

  final List<_AppErrorEntry> _entries = <_AppErrorEntry>[];
  Future<void> _writeTail = Future<void>.value();
  File? _file;

  Future<void> initialize() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, 'runtime-errors.json'));
      _file = file;
      if (!await file.exists()) {
        await _persist();
        return;
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return;
      final restored = decoded
          .whereType<Map>()
          .map((item) => _AppErrorEntry.fromJson(item.cast<String, Object?>()))
          .whereType<_AppErrorEntry>()
          .toList();
      final pending = List<_AppErrorEntry>.from(_entries);
      _entries
        ..clear()
        ..addAll([...restored, ...pending].takeLast(_maxEntries));
    } catch (_) {
      // Diagnostics must never interfere with the game starting.
    }
  }

  void record(Object error, StackTrace stackTrace, {required String source}) {
    final frames = stackTrace
        .toString()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.contains('package:petopia/'))
        .take(3)
        .map(_safeFrame)
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    _entries.add(
      _AppErrorEntry(
        at: DateTime.now().toUtc(),
        source: _safeToken(source, fallback: 'runtime'),
        type: _safeToken(error.runtimeType.toString(), fallback: 'Error'),
        frames: frames,
      ),
    );
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    _writeTail = _writeTail.then((_) => _persist()).catchError((_) {});
  }

  List<String> diagnosticLines() {
    if (_entries.isEmpty) return const <String>['appErrors=0'];
    final last = _entries.last;
    return <String>[
      'appErrors=${_entries.length}',
      'lastAppErrorAtUtc=${last.at.toIso8601String()}',
      'lastAppErrorSource=${last.source}',
      'lastAppErrorType=${last.type}',
      if (last.frames.isNotEmpty) 'lastAppErrorFrames=${last.frames.join('|')}',
    ];
  }

  Future<void> _persist() async {
    final file = _file;
    if (file == null) return;
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(_entries.map((entry) => entry.toJson()).toList()),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}

class _AppErrorEntry {
  const _AppErrorEntry({
    required this.at,
    required this.source,
    required this.type,
    required this.frames,
  });

  final DateTime at;
  final String source;
  final String type;
  final List<String> frames;

  Map<String, Object?> toJson() => <String, Object?>{
    'at': at.toIso8601String(),
    'source': source,
    'type': type,
    'frames': frames,
  };

  static _AppErrorEntry? fromJson(Map<String, Object?> json) {
    final at = DateTime.tryParse(json['at']?.toString() ?? '');
    if (at == null) return null;
    return _AppErrorEntry(
      at: at.toUtc(),
      source: _safeToken(json['source']?.toString() ?? '', fallback: 'runtime'),
      type: _safeToken(json['type']?.toString() ?? '', fallback: 'Error'),
      frames: (json['frames'] is List ? json['frames']! as List : const [])
          .map((item) => _safeFrame(item.toString()))
          .where((item) => item.isNotEmpty)
          .take(3)
          .toList(growable: false),
    );
  }
}

String _safeToken(String value, {required String fallback}) {
  final safe = value.replaceAll(RegExp(r'[^a-zA-Z0-9 _.:/-]'), '').trim();
  if (safe.isEmpty) return fallback;
  return safe.length <= 48 ? safe : safe.substring(0, 48);
}

String _safeFrame(String value) {
  final packageAt = value.indexOf('package:petopia/');
  if (packageAt < 0) return '';
  final safe = value
      .substring(packageAt)
      .replaceAll(RegExp(r'[^a-zA-Z0-9 _.:/()-]'), '')
      .trim();
  return safe.length <= 120 ? safe : safe.substring(0, 120);
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final values = toList(growable: false);
    return values.skip(values.length > count ? values.length - count : 0);
  }
}
