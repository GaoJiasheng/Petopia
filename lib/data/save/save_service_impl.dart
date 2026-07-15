import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config/game_config.dart';
import '../../domain/enums.dart';
import '../../domain/models/logs.dart';
import '../../app/game_state.dart';
import '../../services/audit_service.dart';
import '../../services/clock_service.dart';
import '../../services/save_service.dart';
import '../sqlite/petopia_sqlite_dao.dart';
import 'session_store.dart';

typedef NowProvider = DateTime Function();
typedef MigrationStep =
    FutureOr<SaveDataSnapshot> Function(SaveDataSnapshot snapshot);

const String _slotFormat = 'petopia-slot-v1';
const String _exportFormat = 'petopia-export-v1';
const String _checksumType = 'crc32';

/// 单步存档迁移：fromVersion -> fromVersion + 1。
class Migration {
  const Migration({required this.fromVersion, required this.up});

  final int fromVersion;
  final MigrationStep up;
}

/// 可替换的数据快照端口，便于 SaveService 用 fake 做纯单测。
abstract interface class SaveSnapshotStore {
  Future<SaveDataSnapshot> exportSnapshot();
  Future<void> replaceAll(SaveDataSnapshot snapshot);
}

class SaveDataSnapshot {
  SaveDataSnapshot({
    required this.schemaVersion,
    required Map<String, Object?> isar,
    required Map<String, Object?> sqlite,
  }) : isar = Map.unmodifiable(_copyJsonMap(isar)),
       sqlite = Map.unmodifiable(_copyJsonMap(sqlite));

  final int schemaVersion;

  /// The `isar` archive key is retained for compatibility with v1 backups.
  /// Production payloads now store the JSON game session beneath `session`.
  final Map<String, Object?> isar;
  final Map<String, Object?> sqlite;

  factory SaveDataSnapshot.fromJson(Map<String, Object?> json) {
    return SaveDataSnapshot(
      schemaVersion: _readInt(json['schemaVersion'], 'payload.schemaVersion'),
      isar: _readJsonMap(json['isar'], 'payload.isar'),
      sqlite: _readJsonMap(json['sqlite'], 'payload.sqlite'),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'isar': isar,
      'sqlite': sqlite,
    };
  }

  SaveDataSnapshot withSchemaVersion(int version) {
    final nextIsar = _copyJsonMap(isar);
    final settings = nextIsar['settings'];
    if (settings is Map<String, Object?>) {
      settings['schemaVersion'] = version;
    }
    return SaveDataSnapshot(
      schemaVersion: version,
      isar: nextIsar,
      sqlite: sqlite,
    );
  }
}

/// Production snapshot adapter for the JSON game session and append-only logs.
/// It keeps an imported session staged so the audit service validates imported
/// data rather than the still-running controller instance.
class SessionSaveSnapshotStore implements SaveSnapshotStore {
  factory SessionSaveSnapshotStore({
    required SessionStore sessionStore,
    required PetopiaSqliteDao dao,
    required GameSession Function() currentSession,
  }) => SessionSaveSnapshotStore._(sessionStore, dao, currentSession);

  SessionSaveSnapshotStore._(
    this._sessionStore,
    this._dao,
    this._currentSession,
  );

  final SessionStore _sessionStore;
  final PetopiaSqliteDao _dao;
  final GameSession Function() _currentSession;
  GameSession? _stagedSession;

  GameSession get activeSession => _stagedSession ?? _currentSession();

  @override
  Future<SaveDataSnapshot> exportSnapshot() async {
    return SaveDataSnapshot(
      schemaVersion: GameConfig.currentSchemaVersion,
      isar: <String, Object?>{
        'session': _sessionStore.encodeSnapshot(activeSession),
      },
      sqlite: _sqliteSnapshotToJson(await _dao.exportSnapshot()),
    );
  }

  @override
  Future<void> replaceAll(SaveDataSnapshot snapshot) async {
    final sessionJson = _readJsonMap(snapshot.isar['session'], 'state.session');
    final nextSession = _sessionStore.decodeSnapshot(sessionJson);
    final nextSqlite = _sqliteSnapshotFromJson(snapshot.sqlite);
    final originalSession = _currentSession();
    final originalSqlite = await _dao.exportSnapshot();

    try {
      await _dao.replaceAll(nextSqlite);
      await _sessionStore.save(nextSession);
      _stagedSession = nextSession;
    } catch (_) {
      await _dao.replaceAll(originalSqlite);
      await _sessionStore.save(originalSession);
      _stagedSession = null;
      rethrow;
    }
  }
}

class LocalSaveService implements SaveService {
  LocalSaveService({
    required SaveSnapshotStore snapshotStore,
    required AuditService auditService,
    required Directory saveDirectory,
    ClockService? clock,
    NowProvider? now,
    Duration? autoSaveDebounce,
    List<Migration> migrations = const <Migration>[],
  }) : _store = snapshotStore,
       // ignore: prefer_initializing_formals
       _auditService = auditService,
       // ignore: prefer_initializing_formals
       _saveDirectory = saveDirectory,
       _now = now ?? clock?.now ?? (() => DateTime.now().toUtc()),
       _autoSaveDebounce =
           autoSaveDebounce ??
           const Duration(milliseconds: GameConfig.autoSaveDebounceMs),
       _migrations = <int, Migration>{
         for (final migration in migrations) migration.fromVersion: migration,
       };

  static Future<LocalSaveService> create({
    required SaveSnapshotStore snapshotStore,
    required AuditService auditService,
    ClockService? clock,
    NowProvider? now,
    Duration? autoSaveDebounce,
    List<Migration> migrations = const <Migration>[],
  }) async {
    final documents = await getApplicationDocumentsDirectory();
    return LocalSaveService(
      snapshotStore: snapshotStore,
      auditService: auditService,
      saveDirectory: Directory(p.join(documents.path, 'save')),
      clock: clock,
      now: now,
      autoSaveDebounce: autoSaveDebounce,
      migrations: migrations,
    );
  }

  final SaveSnapshotStore _store;
  final AuditService _auditService;
  final Directory _saveDirectory;
  final NowProvider _now;
  final Duration _autoSaveDebounce;
  final Map<int, Migration> _migrations;

  Timer? _debounceTimer;
  Completer<void>? _pendingAutoSave;
  Future<void> _operationTail = Future<void>.value();
  int _nextSlot = 0;

  @override
  Future<void> autoSave() {
    _debounceTimer?.cancel();
    final completer = _pendingAutoSave ??= Completer<void>();
    _debounceTimer = Timer(_autoSaveDebounce, () {
      final pending = _pendingAutoSave;
      _pendingAutoSave = null;
      _debounceTimer = null;
      _enqueue<void>(_writeCurrentSlot).then(
        (_) => pending?.complete(),
        onError: (Object error, StackTrace stackTrace) {
          pending?.completeError(error, stackTrace);
        },
      );
    });
    return completer.future;
  }

  @override
  Future<void> load() => _enqueue(_loadNow);

  @override
  Future<int> migrateIfNeeded(int fromVersion) {
    return _enqueue<int>(() async {
      final original = await _store.exportSnapshot();
      try {
        final migrated = await _migrateSnapshot(original, fromVersion);
        if (migrated.schemaVersion != original.schemaVersion) {
          await _store.replaceAll(migrated);
          await _writeCurrentSlot(snapshot: migrated);
        }
        return migrated.schemaVersion;
      } catch (_) {
        await _store.replaceAll(original);
        rethrow;
      }
    });
  }

  @override
  Future<File> export() => _enqueue(_exportNow);

  @override
  Future<ImportResult> import(File f) => _enqueue(() => _importNow(f));

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final next = _operationTail.then((_) => operation());
    _operationTail = next.then<void>((_) {}, onError: (_, _) {});
    return next;
  }

  Future<void> _loadNow() async {
    final candidates = <_SlotCandidate>[];
    for (var slot = 0; slot < GameConfig.backupSlots; slot++) {
      final file = _slotFile(slot);
      if (!await file.exists()) {
        continue;
      }
      candidates.add(await _slotCandidate(slot, file));
    }
    if (candidates.isEmpty) {
      return;
    }

    candidates.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
    final failures = <String>[];
    for (final candidate in candidates) {
      try {
        final envelope = await _readEnvelopeFile(
          candidate.file,
          expectedFormat: _slotFormat,
        );
        await _store.replaceAll(envelope.snapshot);
        _nextSlot = (candidate.slot + 1) % GameConfig.backupSlots;
        return;
      } on Object catch (error) {
        failures.add('slot ${candidate.name}: $error');
      }
    }

    throw SaveArchiveException('所有存档 slot 均不可用：${failures.join('；')}');
  }

  Future<File> _exportNow() async {
    final snapshot = await _store.exportSnapshot();
    final directory = Directory(p.join(_saveDirectory.path, 'exports'));
    await directory.create(recursive: true);
    final stamp = _fileStamp(_now().toUtc());
    final file = File(p.join(directory.path, 'petopia-$stamp.petopia-save'));
    await _writeEnvelopeFile(file, _exportFormat, snapshot);
    return file;
  }

  Future<ImportResult> _importNow(File file) async {
    late final SaveDataSnapshot original;
    try {
      original = await _store.exportSnapshot();
    } on Object catch (error) {
      return ImportResult(success: false, failReason: '读取当前存档失败：$error');
    }

    var replaced = false;
    try {
      final envelope = await _readEnvelopeFile(
        file,
        expectedFormat: _exportFormat,
      );
      final migrated = await _migrateSnapshot(
        envelope.snapshot,
        envelope.snapshot.schemaVersion,
      );

      await _store.replaceAll(migrated);
      replaced = true;

      final audit = await _auditService.verifyOnStartup();
      if (!audit.ok) {
        await _store.replaceAll(original);
        return ImportResult(
          success: false,
          failReason: 'audit 失败：${audit.discrepancies.join('；')}',
        );
      }

      await _writeCurrentSlot(snapshot: await _store.exportSnapshot());
      return const ImportResult(success: true);
    } on Object catch (error) {
      if (replaced) {
        try {
          await _store.replaceAll(original);
        } on Object catch (restoreError) {
          return ImportResult(
            success: false,
            failReason: '$error；恢复原档失败：$restoreError',
          );
        }
      }
      return ImportResult(success: false, failReason: error.toString());
    }
  }

  Future<SaveDataSnapshot> _migrateSnapshot(
    SaveDataSnapshot snapshot,
    int fromVersion,
  ) async {
    if (fromVersion > GameConfig.currentSchemaVersion) {
      throw SaveArchiveException(
        'schemaVersion $fromVersion 高于当前支持的 '
        '${GameConfig.currentSchemaVersion}',
      );
    }

    var version = fromVersion;
    var current = snapshot.withSchemaVersion(version);
    while (version < GameConfig.currentSchemaVersion) {
      final migration = _migrations[version];
      if (migration == null) {
        throw SaveArchiveException('缺少 $version -> ${version + 1} 迁移');
      }
      current = await migration.up(current);
      version += 1;
      current = current.withSchemaVersion(version);
    }
    return current.withSchemaVersion(GameConfig.currentSchemaVersion);
  }

  Future<void> _writeCurrentSlot({SaveDataSnapshot? snapshot}) async {
    final data = snapshot ?? await _store.exportSnapshot();
    final slot = _nextSlot;
    await _writeEnvelopeFile(_slotFile(slot), _slotFormat, data, slot: slot);
    _nextSlot = (slot + 1) % GameConfig.backupSlots;
  }

  Future<void> _writeEnvelopeFile(
    File file,
    String format,
    SaveDataSnapshot snapshot, {
    int? slot,
  }) async {
    final payload = snapshot.toJson();
    final envelope = <String, Object?>{
      'format': format,
      'schemaVersion': snapshot.schemaVersion,
      'writtenAt': _dateToJson(_now()),
      if (slot != null) 'slot': _slotName(slot),
      'checksumType': _checksumType,
      'checksum': _payloadChecksum(payload),
      'payload': payload,
    };
    await file.parent.create(recursive: true);
    await _writeTextAtomically(file, jsonEncode(envelope));
  }

  Future<_SaveEnvelope> _readEnvelopeFile(
    File file, {
    required String expectedFormat,
  }) async {
    final text = await file.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?>) {
      throw SaveArchiveException('存档根节点不是对象');
    }

    final format = _readString(decoded['format'], 'format');
    if (format != expectedFormat) {
      throw SaveArchiveException('存档格式不匹配：$format');
    }
    final schemaVersion = _readInt(decoded['schemaVersion'], 'schemaVersion');
    if (schemaVersion > GameConfig.currentSchemaVersion) {
      throw SaveArchiveException(
        'schemaVersion $schemaVersion 高于当前支持的 '
        '${GameConfig.currentSchemaVersion}',
      );
    }
    final checksumType = _readString(decoded['checksumType'], 'checksumType');
    if (checksumType != _checksumType) {
      throw SaveArchiveException('不支持的 checksumType：$checksumType');
    }

    final payload = _readJsonMap(decoded['payload'], 'payload');
    final expectedChecksum = _readString(decoded['checksum'], 'checksum');
    final actualChecksum = _payloadChecksum(payload);
    if (actualChecksum != expectedChecksum) {
      throw SaveArchiveException('checksum 校验失败');
    }

    final snapshot = SaveDataSnapshot.fromJson(payload);
    if (snapshot.schemaVersion != schemaVersion) {
      throw SaveArchiveException('header 与 payload schemaVersion 不一致');
    }

    return _SaveEnvelope(
      writtenAt: _readDate(decoded['writtenAt'], 'writtenAt'),
      snapshot: snapshot,
    );
  }

  Future<_SlotCandidate> _slotCandidate(int slot, File file) async {
    var writtenAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, Object?>) {
        writtenAt = _readDate(decoded['writtenAt'], 'writtenAt');
      }
    } on Object {
      // 只用于排序；真正错误由 load 的完整校验路径记录。
    }
    return _SlotCandidate(slot: slot, file: file, writtenAt: writtenAt);
  }

  File _slotFile(int slot) {
    return File(p.join(_saveDirectory.path, 'slot_${_slotName(slot)}.json'));
  }
}

class SaveArchiveException implements Exception {
  const SaveArchiveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _SaveEnvelope {
  const _SaveEnvelope({required this.writtenAt, required this.snapshot});

  final DateTime writtenAt;
  final SaveDataSnapshot snapshot;
}

class _SlotCandidate {
  const _SlotCandidate({
    required this.slot,
    required this.file,
    required this.writtenAt,
  });

  final int slot;
  final File file;
  final DateTime writtenAt;

  String get name => _slotName(slot);
}

String _slotName(int slot) => slot == 0 ? 'A' : 'B';

Future<void> _writeTextAtomically(File file, String text) async {
  final tmp = File('${file.path}.tmp');
  await tmp.writeAsString(text, flush: true);
  if (await file.exists()) {
    await file.delete();
  }
  await tmp.rename(file.path);
}

String _fileStamp(DateTime value) {
  return value
      .toUtc()
      .toIso8601String()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .replaceAll('.', '');
}

String _dateToJson(DateTime value) => value.toUtc().toIso8601String();

String _payloadChecksum(Map<String, Object?> payload) {
  final canonical = jsonEncode(_canonicalizeJson(payload));
  return _crc32(utf8.encode(canonical)).toRadixString(16).padLeft(8, '0');
}

Object? _canonicalizeJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalizeJson(value[key]),
    };
  }
  if (value is List) {
    return value.map(_canonicalizeJson).toList();
  }
  return value;
}

final List<int> _crc32Table = List<int>.generate(256, (index) {
  var crc = index;
  for (var bit = 0; bit < 8; bit++) {
    if ((crc & 1) == 1) {
      crc = 0xedb88320 ^ (crc >> 1);
    } else {
      crc >>= 1;
    }
  }
  return crc;
}, growable: false);

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc = _crc32Table[(crc ^ byte) & 0xff] ^ (crc >> 8);
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

Map<String, Object?> _sqliteSnapshotToJson(PetopiaSqliteSnapshot snapshot) {
  return <String, Object?>{
    'expLogs': snapshot.expLogs.map(_expLogToJson).toList(),
    'currencyLogs': snapshot.currencyLogs.map(_currencyLogToJson).toList(),
    'postcards': snapshot.postcards.map(_postcardToJson).toList(),
    'eventLogs': snapshot.eventLogs.map(_eventLogToJson).toList(),
  };
}

PetopiaSqliteSnapshot _sqliteSnapshotFromJson(Map<String, Object?> json) {
  return PetopiaSqliteSnapshot(
    expLogs: _readMapList(
      json['expLogs'],
      'sqlite.expLogs',
    ).map(_expLogFromJson).toList(),
    currencyLogs: _readMapList(
      json['currencyLogs'],
      'sqlite.currencyLogs',
    ).map(_currencyLogFromJson).toList(),
    postcards: _readMapList(
      json['postcards'],
      'sqlite.postcards',
    ).map(_postcardFromJson).toList(),
    eventLogs: _readMapList(
      json['eventLogs'],
      'sqlite.eventLogs',
    ).map(_eventLogFromJson).toList(),
  );
}

Map<String, Object?> _expLogToJson(ExpLogEntry entry) {
  return <String, Object?>{
    'id': entry.id,
    'petId': entry.petId,
    'timestamp': _dateToJson(entry.timestamp),
    'sourceType': entry.sourceType.name,
    'sourceRef': entry.sourceRef,
    'delta': entry.delta,
    'levelAt': entry.levelAt,
    'expAfter': entry.expAfter,
    'note': entry.note,
  };
}

ExpLogEntry _expLogFromJson(Map<String, Object?> json) {
  return ExpLogEntry(
    id: _readString(json['id'], 'expLog.id'),
    petId: _readString(json['petId'], 'expLog.petId'),
    timestamp: _readDate(json['timestamp'], 'expLog.timestamp'),
    sourceType: _readEnum(
      ExpSource.values,
      json['sourceType'],
      'expLog.sourceType',
    ),
    delta: _readInt(json['delta'], 'expLog.delta'),
    levelAt: _readInt(json['levelAt'], 'expLog.levelAt'),
    expAfter: _readInt(json['expAfter'], 'expLog.expAfter'),
    sourceRef: json['sourceRef'] as String?,
    note: json['note'] as String?,
  );
}

Map<String, Object?> _currencyLogToJson(CurrencyLog entry) {
  return <String, Object?>{
    'id': entry.id,
    'timestamp': _dateToJson(entry.timestamp),
    'delta': entry.delta,
    'reason': entry.reason.name,
    'ref': entry.ref,
    'balanceAfter': entry.balanceAfter,
  };
}

CurrencyLog _currencyLogFromJson(Map<String, Object?> json) {
  return CurrencyLog(
    id: _readString(json['id'], 'currencyLog.id'),
    timestamp: _readDate(json['timestamp'], 'currencyLog.timestamp'),
    delta: _readInt(json['delta'], 'currencyLog.delta'),
    reason: _readEnum(
      CurrencyReason.values,
      json['reason'],
      'currencyLog.reason',
    ),
    balanceAfter: _readInt(json['balanceAfter'], 'currencyLog.balanceAfter'),
    ref: json['ref'] as String?,
  );
}

Map<String, Object?> _postcardToJson(Postcard postcard) {
  return <String, Object?>{
    'id': postcard.id,
    'petId': postcard.petId,
    'journeyId': postcard.journeyId,
    'locationId': postcard.locationId,
    'seq': postcard.seq,
    'sentAt': _dateToJson(postcard.sentAt),
    'receivedAt': _nullableDateToJson(postcard.receivedAt),
    'season': postcard.season.name,
    'timeOfDay': postcard.timeOfDay.name,
    'weather': postcard.weather.name,
    'encounterId': postcard.encounterId,
    'incidentId': postcard.incidentId,
    'bodyText': postcard.bodyText,
    'photoAssetId': postcard.photoAssetId,
    'stampId': postcard.stampId,
    'clueToPet': postcard.clueToPet,
    'clueToVisitor': postcard.clueToVisitor,
  };
}

Postcard _postcardFromJson(Map<String, Object?> json) {
  return Postcard(
    id: _readString(json['id'], 'postcard.id'),
    petId: _readString(json['petId'], 'postcard.petId'),
    journeyId: _readString(json['journeyId'], 'postcard.journeyId'),
    locationId: _readString(json['locationId'], 'postcard.locationId'),
    seq: _readInt(json['seq'], 'postcard.seq'),
    sentAt: _readDate(json['sentAt'], 'postcard.sentAt'),
    receivedAt: _readNullableDate(json['receivedAt'], 'postcard.receivedAt'),
    season: _readEnum(Season.values, json['season'], 'postcard.season'),
    timeOfDay: _readEnum(
      TimeOfDayOfDay.values,
      json['timeOfDay'],
      'postcard.timeOfDay',
    ),
    weather: _readEnum(Weather.values, json['weather'], 'postcard.weather'),
    bodyText: _readString(json['bodyText'], 'postcard.bodyText'),
    photoAssetId: _readString(json['photoAssetId'], 'postcard.photoAssetId'),
    stampId: _readString(json['stampId'], 'postcard.stampId'),
    encounterId: json['encounterId'] as String?,
    incidentId: json['incidentId'] as String?,
    clueToPet: json['clueToPet'] as String?,
    clueToVisitor: json['clueToVisitor'] as String?,
  );
}

Map<String, Object?> _eventLogToJson(EventLogEntry entry) {
  return <String, Object?>{
    'id': entry.id,
    'eventId': entry.eventId,
    'petId': entry.petId,
    'date': _dateToJson(entry.date),
    'choiceIdx': entry.choiceIdx,
    'expGranted': entry.expGranted,
  };
}

EventLogEntry _eventLogFromJson(Map<String, Object?> json) {
  return EventLogEntry(
    id: _readString(json['id'], 'eventLog.id'),
    eventId: _readString(json['eventId'], 'eventLog.eventId'),
    date: _readDate(json['date'], 'eventLog.date'),
    expGranted: _readInt(json['expGranted'], 'eventLog.expGranted'),
    petId: json['petId'] as String?,
    choiceIdx: json['choiceIdx'] as int?,
  );
}

String? _nullableDateToJson(DateTime? value) {
  return value == null ? null : _dateToJson(value);
}

DateTime _readDate(Object? value, String field) {
  if (value is! String) {
    throw SaveArchiveException('$field 不是字符串时间');
  }
  return DateTime.parse(value).toUtc();
}

DateTime? _readNullableDate(Object? value, String field) {
  if (value == null) {
    return null;
  }
  return _readDate(value, field);
}

String _readString(Object? value, String field) {
  if (value is String) {
    return value;
  }
  throw SaveArchiveException('$field 不是字符串');
}

int _readInt(Object? value, String field) {
  if (value is int) {
    return value;
  }
  throw SaveArchiveException('$field 不是整数');
}

T _readEnum<T extends Enum>(List<T> values, Object? value, String field) {
  final name = _readString(value, field);
  try {
    return values.byName(name);
  } on ArgumentError {
    throw SaveArchiveException('$field 枚举值未知：$name');
  }
}

List<Map<String, Object?>> _readMapList(Object? value, String field) {
  if (value == null) {
    return <Map<String, Object?>>[];
  }
  if (value is! List) {
    throw SaveArchiveException('$field 不是数组');
  }
  return value.map((item) => _readJsonMap(item, field)).toList(growable: false);
}

Map<String, Object?> _readJsonMap(Object? value, String field) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
  throw SaveArchiveException('$field 不是对象');
}

Map<String, Object?> _copyJsonMap(Map<String, Object?> source) {
  return <String, Object?>{
    for (final entry in source.entries) entry.key: _copyJsonValue(entry.value),
  };
}

Object? _copyJsonValue(Object? value) {
  if (value is Map) {
    return _copyJsonMap(_readJsonMap(value, 'json'));
  }
  if (value is List) {
    return value.map(_copyJsonValue).toList();
  }
  return value;
}
