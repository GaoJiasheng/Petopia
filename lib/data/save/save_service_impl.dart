import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config/game_config.dart';
import '../../domain/enums.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/logs.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/yard.dart';
import '../../services/audit_service.dart';
import '../../services/clock_service.dart';
import '../../services/save_service.dart';
import '../repositories/runtime_repositories.dart';
import '../sqlite/petopia_sqlite_dao.dart';

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

class RepositorySaveSnapshotStore implements SaveSnapshotStore {
  RepositorySaveSnapshotStore(this._repositories, this._dao, {NowProvider? now})
    : _now = now ?? (() => DateTime.now().toUtc());

  final PetopiaRepositories _repositories;
  final PetopiaSqliteDao _dao;
  final NowProvider _now;

  @override
  Future<SaveDataSnapshot> exportSnapshot() async {
    final runtime = await _repositories.exportSnapshot();
    final sqlite = await _dao.exportSnapshot();
    return SaveDataSnapshot(
      schemaVersion:
          runtime.settings?.schemaVersion ?? GameConfig.currentSchemaVersion,
      isar: _runtimeSnapshotToJson(runtime),
      sqlite: _sqliteSnapshotToJson(sqlite),
    );
  }

  @override
  Future<void> replaceAll(SaveDataSnapshot snapshot) async {
    final original = await exportSnapshot();
    try {
      await _repositories.replaceAll(
        _runtimeSnapshotFromJson(snapshot.isar, _now()),
      );
      await _dao.replaceAll(_sqliteSnapshotFromJson(snapshot.sqlite));
    } catch (_) {
      await _repositories.replaceAll(
        _runtimeSnapshotFromJson(original.isar, _now()),
      );
      await _dao.replaceAll(_sqliteSnapshotFromJson(original.sqlite));
      rethrow;
    }
  }
}

class LocalSaveService implements SaveService {
  LocalSaveService({
    PetopiaRepositories? repositories,
    PetopiaSqliteDao? dao,
    SaveSnapshotStore? snapshotStore,
    required AuditService auditService,
    required Directory saveDirectory,
    ClockService? clock,
    NowProvider? now,
    Duration? autoSaveDebounce,
    List<Migration> migrations = const <Migration>[],
  }) : assert(
         snapshotStore != null || (repositories != null && dao != null),
         'snapshotStore 或 repositories+dao 必须注入其一',
       ),
       _store =
           snapshotStore ??
           RepositorySaveSnapshotStore(
             repositories!,
             dao!,
             now: now ?? clock?.now,
           ),
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
    required PetopiaRepositories repositories,
    required PetopiaSqliteDao dao,
    required AuditService auditService,
    ClockService? clock,
    NowProvider? now,
    Duration? autoSaveDebounce,
    List<Migration> migrations = const <Migration>[],
  }) async {
    final documents = await getApplicationDocumentsDirectory();
    return LocalSaveService(
      repositories: repositories,
      dao: dao,
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

Map<String, Object?> _runtimeSnapshotToJson(
  RuntimeRepositorySnapshot snapshot,
) {
  final pets = List<Pet>.of(snapshot.pets)
    ..sort((a, b) => a.id.compareTo(b.id));
  final journeys = List<Journey>.of(snapshot.journeys)
    ..sort((a, b) => a.id.compareTo(b.id));
  final clues = List<ClueCounter>.of(snapshot.clues)
    ..sort((a, b) => a.clueId.compareTo(b.clueId));
  final achievements = List<AchievementProgress>.of(snapshot.achievements)
    ..sort((a, b) => a.achievementId.compareTo(b.achievementId));
  final visitorLogs = List<VisitorLogEntry>.of(snapshot.visitorLogs)
    ..sort((a, b) => a.id.compareTo(b.id));
  final jobs = List<ScheduledJob>.of(snapshot.jobs)
    ..sort((a, b) => a.id.compareTo(b.id));

  return <String, Object?>{
    'pets': pets.map(_petToJson).toList(),
    'wallet': snapshot.wallet == null ? null : _walletToJson(snapshot.wallet!),
    'yard': snapshot.yard == null ? null : _yardToJson(snapshot.yard!),
    'journeys': journeys.map(_journeyToJson).toList(),
    'clues': clues.map(_clueToJson).toList(),
    'achievements': achievements.map(_achievementToJson).toList(),
    'visitorLogs': visitorLogs.map(_visitorLogToJson).toList(),
    'jobs': jobs.map(_jobToJson).toList(),
    'settings': snapshot.settings == null
        ? null
        : _settingsToJson(snapshot.settings!),
  };
}

RuntimeRepositorySnapshot _runtimeSnapshotFromJson(
  Map<String, Object?> json,
  DateTime fallbackNow,
) {
  return RuntimeRepositorySnapshot(
    pets: _readMapList(json['pets'], 'isar.pets').map(_petFromJson).toList(),
    wallet: _readNullableJsonMap(json['wallet'], 'isar.wallet') == null
        ? null
        : _walletFromJson(_readJsonMap(json['wallet'], 'isar.wallet')),
    yard: _readNullableJsonMap(json['yard'], 'isar.yard') == null
        ? null
        : _yardFromJson(_readJsonMap(json['yard'], 'isar.yard')),
    journeys: _readMapList(
      json['journeys'],
      'isar.journeys',
    ).map(_journeyFromJson).toList(),
    clues: _readMapList(
      json['clues'],
      'isar.clues',
    ).map(_clueFromJson).toList(),
    achievements: _readMapList(
      json['achievements'],
      'isar.achievements',
    ).map(_achievementFromJson).toList(),
    visitorLogs: _readMapList(
      json['visitorLogs'],
      'isar.visitorLogs',
    ).map(_visitorLogFromJson).toList(),
    jobs: _readMapList(json['jobs'], 'isar.jobs').map(_jobFromJson).toList(),
    settings: _readNullableJsonMap(json['settings'], 'isar.settings') == null
        ? null
        : _settingsFromJson(
            _readJsonMap(json['settings'], 'isar.settings'),
            fallbackNow,
          ),
  );
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

Map<String, Object?> _petToJson(Pet pet) {
  return <String, Object?>{
    'id': pet.id,
    'speciesId': pet.speciesId,
    'variantId': pet.variantId,
    'name': pet.name,
    'personality': pet.personality,
    'bornAt': _dateToJson(pet.bornAt),
    'level': pet.level,
    'exp': pet.exp,
    'stage': pet.stage.name,
    'state': pet.state.name,
    'lastOnlineAt': _dateToJson(pet.lastOnlineAt),
    'offlineExpGrantedToday': pet.offlineExpGrantedToday,
    'offlineDayKey': pet.offlineDayKey,
    'wishId': pet.wishId,
    'graduatedAt': _nullableDateToJson(pet.graduatedAt),
    'journeyId': pet.journeyId,
    'nextRevisitAt': _nullableDateToJson(pet.nextRevisitAt),
    'pastNames': pet.pastNames,
  };
}

Pet _petFromJson(Map<String, Object?> json) {
  return Pet(
    id: _readString(json['id'], 'pet.id'),
    speciesId: _readString(json['speciesId'], 'pet.speciesId'),
    variantId: _readString(json['variantId'], 'pet.variantId'),
    name: _readString(json['name'], 'pet.name'),
    personality: _readStringList(json['personality'], 'pet.personality'),
    bornAt: _readDate(json['bornAt'], 'pet.bornAt'),
    lastOnlineAt: _readDate(json['lastOnlineAt'], 'pet.lastOnlineAt'),
    offlineDayKey: _readString(json['offlineDayKey'], 'pet.offlineDayKey'),
    level: _readInt(json['level'], 'pet.level'),
    exp: _readInt(json['exp'], 'pet.exp'),
    stage: _readEnum(PetStage.values, json['stage'], 'pet.stage'),
    state: _readEnum(PetState.values, json['state'], 'pet.state'),
    offlineExpGrantedToday: _readInt(
      json['offlineExpGrantedToday'],
      'pet.offlineExpGrantedToday',
    ),
    wishId: json['wishId'] as String?,
    graduatedAt: _readNullableDate(json['graduatedAt'], 'pet.graduatedAt'),
    journeyId: json['journeyId'] as String?,
    nextRevisitAt: _readNullableDate(
      json['nextRevisitAt'],
      'pet.nextRevisitAt',
    ),
    pastNames: _readStringList(json['pastNames'], 'pet.pastNames'),
  );
}

Map<String, Object?> _walletToJson(CurrencyWallet wallet) {
  return <String, Object?>{'balance': wallet.balance};
}

CurrencyWallet _walletFromJson(Map<String, Object?> json) {
  return CurrencyWallet(balance: _readInt(json['balance'], 'wallet.balance'));
}

Map<String, Object?> _yardToJson(YardState yard) {
  return <String, Object?>{
    'luxuryStage': yard.luxuryStage,
    'gradCount': yard.gradCount,
    'activeThemeId': yard.activeThemeId,
    'ownedThemeIds': yard.ownedThemeIds,
    'slots': yard.slots.map(_yardSlotToJson).toList(),
    'foodTray': _foodTrayToJson(yard.foodTray),
    'ownedPerks': yard.ownedPerks,
    'ownedDecorIds': yard.ownedDecorIds,
  };
}

YardState _yardFromJson(Map<String, Object?> json) {
  return YardState(
    luxuryStage: _readInt(json['luxuryStage'], 'yard.luxuryStage'),
    gradCount: _readInt(json['gradCount'], 'yard.gradCount'),
    activeThemeId: _readString(json['activeThemeId'], 'yard.activeThemeId'),
    ownedThemeIds: _readStringList(json['ownedThemeIds'], 'yard.ownedThemeIds'),
    slots: _readMapList(
      json['slots'],
      'yard.slots',
    ).map(_yardSlotFromJson).toList(),
    foodTray: _foodTrayFromJson(
      _readJsonMap(json['foodTray'], 'yard.foodTray'),
    ),
    ownedPerks: _readStringList(json['ownedPerks'], 'yard.ownedPerks'),
    ownedDecorIds: _readStringList(json['ownedDecorIds'], 'yard.ownedDecorIds'),
  );
}

Map<String, Object?> _yardSlotToJson(YardSlot slot) {
  return <String, Object?>{'pos': slot.pos, 'itemId': slot.itemId};
}

YardSlot _yardSlotFromJson(Map<String, Object?> json) {
  return YardSlot(
    pos: _readInt(json['pos'], 'yard.slot.pos'),
    itemId: json['itemId'] as String?,
  );
}

Map<String, Object?> _foodTrayToJson(FoodTray tray) {
  return <String, Object?>{
    'foodType': tray.foodType,
    'placedAt': _nullableDateToJson(tray.placedAt),
  };
}

FoodTray _foodTrayFromJson(Map<String, Object?> json) {
  return FoodTray(
    foodType: json['foodType'] as String?,
    placedAt: _readNullableDate(json['placedAt'], 'yard.foodTray.placedAt'),
  );
}

Map<String, Object?> _journeyToJson(Journey journey) {
  return <String, Object?>{
    'id': journey.id,
    'petId': journey.petId,
    'stops': journey.stops,
    'wanderStops': journey.wanderStops,
    'currentIdx': journey.currentIdx,
    'wanderIdx': journey.wanderIdx,
    'longTermSeq': journey.longTermSeq,
    'nextPostcardAt': _dateToJson(journey.nextPostcardAt),
    'state': journey.state.name,
  };
}

Journey _journeyFromJson(Map<String, Object?> json) {
  return Journey(
    id: _readString(json['id'], 'journey.id'),
    petId: _readString(json['petId'], 'journey.petId'),
    stops: _readStringList(json['stops'], 'journey.stops'),
    wanderStops: json.containsKey('wanderStops')
        ? _readStringList(json['wanderStops'], 'journey.wanderStops')
        : <String>[],
    currentIdx: _readInt(json['currentIdx'], 'journey.currentIdx'),
    wanderIdx: json.containsKey('wanderIdx')
        ? _readInt(json['wanderIdx'], 'journey.wanderIdx')
        : 0,
    longTermSeq: json.containsKey('longTermSeq')
        ? _readInt(json['longTermSeq'], 'journey.longTermSeq')
        : 0,
    nextPostcardAt: _readDate(json['nextPostcardAt'], 'journey.nextPostcardAt'),
    state: _readEnum(JourneyState.values, json['state'], 'journey.state'),
  );
}

Map<String, Object?> _clueToJson(ClueCounter clue) {
  return <String, Object?>{
    'clueId': clue.clueId,
    'count': clue.count,
    'threshold': clue.threshold,
    'visitorSeen': clue.visitorSeen,
  };
}

ClueCounter _clueFromJson(Map<String, Object?> json) {
  return ClueCounter(
    clueId: _readString(json['clueId'], 'clue.clueId'),
    threshold: _readInt(json['threshold'], 'clue.threshold'),
    count: _readInt(json['count'], 'clue.count'),
    visitorSeen: _readBool(json['visitorSeen'], 'clue.visitorSeen'),
  );
}

Map<String, Object?> _achievementToJson(AchievementProgress achievement) {
  return <String, Object?>{
    'achievementId': achievement.achievementId,
    'progress': achievement.progress,
    'unlockedAt': _nullableDateToJson(achievement.unlockedAt),
    'rewardClaimed': achievement.rewardClaimed,
  };
}

AchievementProgress _achievementFromJson(Map<String, Object?> json) {
  return AchievementProgress(
    achievementId: _readString(
      json['achievementId'],
      'achievement.achievementId',
    ),
    progress: _readInt(json['progress'], 'achievement.progress'),
    unlockedAt: _readNullableDate(json['unlockedAt'], 'achievement.unlockedAt'),
    rewardClaimed: _readBool(
      json['rewardClaimed'],
      'achievement.rewardClaimed',
    ),
  );
}

Map<String, Object?> _visitorLogToJson(VisitorLogEntry entry) {
  return <String, Object?>{
    'id': entry.id,
    'visitorId': entry.visitorId,
    'date': _dateToJson(entry.date),
    'interactionId': entry.interactionId,
    'withPetId': entry.withPetId,
  };
}

VisitorLogEntry _visitorLogFromJson(Map<String, Object?> json) {
  return VisitorLogEntry(
    id: _readString(json['id'], 'visitorLog.id'),
    visitorId: _readString(json['visitorId'], 'visitorLog.visitorId'),
    date: _readDate(json['date'], 'visitorLog.date'),
    interactionId: json['interactionId'] as String?,
    withPetId: json['withPetId'] as String?,
  );
}

Map<String, Object?> _jobToJson(ScheduledJob job) {
  return <String, Object?>{
    'id': job.id,
    'type': job.type.name,
    'dueAt': _dateToJson(job.dueAt),
    'priority': job.priority,
    'payloadRef': job.payloadRef,
    'consumed': job.consumed,
  };
}

ScheduledJob _jobFromJson(Map<String, Object?> json) {
  return ScheduledJob(
    id: _readString(json['id'], 'job.id'),
    type: _readEnum(JobType.values, json['type'], 'job.type'),
    dueAt: _readDate(json['dueAt'], 'job.dueAt'),
    priority: _readInt(json['priority'], 'job.priority'),
    payloadRef: json['payloadRef'] as String?,
    consumed: _readBool(json['consumed'], 'job.consumed'),
  );
}

Map<String, Object?> _settingsToJson(Settings settings) {
  return <String, Object?>{
    'notifications': settings.notifications,
    'sound': settings.sound,
    'schemaVersion': settings.schemaVersion,
    'createdAt': _dateToJson(settings.createdAt),
    'lastMonotonicRef': settings.lastMonotonicRef,
    'lastWallClockAt': _dateToJson(settings.lastWallClockAt),
    'loginStreakCurrent': settings.loginStreakCurrent,
    'loginStreakMax': settings.loginStreakMax,
    'lastLoginDay': settings.lastLoginDay,
  };
}

Settings _settingsFromJson(Map<String, Object?> json, DateTime fallbackNow) {
  return Settings(
    createdAt: _readOptionalDate(json['createdAt']) ?? fallbackNow.toUtc(),
    lastWallClockAt:
        _readOptionalDate(json['lastWallClockAt']) ?? fallbackNow.toUtc(),
    notifications: _readBool(json['notifications'], 'settings.notifications'),
    sound: _readBool(json['sound'], 'settings.sound'),
    schemaVersion: _readInt(json['schemaVersion'], 'settings.schemaVersion'),
    lastMonotonicRef: _readInt(
      json['lastMonotonicRef'],
      'settings.lastMonotonicRef',
    ),
    loginStreakCurrent: _readInt(
      json['loginStreakCurrent'],
      'settings.loginStreakCurrent',
    ),
    loginStreakMax: _readInt(json['loginStreakMax'], 'settings.loginStreakMax'),
    lastLoginDay: _readString(json['lastLoginDay'], 'settings.lastLoginDay'),
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

DateTime? _readOptionalDate(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return DateTime.parse(value).toUtc();
  }
  return null;
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

bool _readBool(Object? value, String field) {
  if (value is bool) {
    return value;
  }
  throw SaveArchiveException('$field 不是布尔值');
}

T _readEnum<T extends Enum>(List<T> values, Object? value, String field) {
  final name = _readString(value, field);
  try {
    return values.byName(name);
  } on ArgumentError {
    throw SaveArchiveException('$field 枚举值未知：$name');
  }
}

List<String> _readStringList(Object? value, String field) {
  if (value is! List) {
    throw SaveArchiveException('$field 不是数组');
  }
  return value.map((item) => _readString(item, field)).toList();
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

Map<String, Object?>? _readNullableJsonMap(Object? value, String field) {
  if (value == null) {
    return null;
  }
  return _readJsonMap(value, field);
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
