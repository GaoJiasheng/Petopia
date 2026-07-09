import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/game_state.dart';
import '../../domain/enums.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/logs.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/yard.dart';

const int _schemaVersion = 1;

class SessionStore {
  SessionStore(this.saveDir);

  final Directory saveDir;

  File get _sessionFile => File(p.join(saveDir.path, 'session.json'));
  File get _backupFile => File(p.join(saveDir.path, 'session.bak'));
  File get _tempFile => File(p.join(saveDir.path, 'session.tmp'));

  static Future<SessionStore> create() async {
    final documents = await getApplicationDocumentsDirectory();
    return SessionStore(Directory(p.join(documents.path, 'save')));
  }

  Future<void> save(GameSession session) async {
    try {
      await saveDir.create(recursive: true);
      final encoded = const JsonEncoder.withIndent(
        '  ',
      ).convert(_sessionToJson(session));
      final temp = _tempFile;
      await temp.writeAsString(encoded, flush: true);

      final sessionFile = _sessionFile;
      if (await sessionFile.exists()) {
        await sessionFile.copy(_backupFile.path);
      }
      await temp.rename(sessionFile.path);
    } catch (error, stackTrace) {
      debugPrint('SessionStore.save failed: $error\n$stackTrace');
    }
  }

  Future<GameSession?> load() async {
    try {
      try {
        final primary = await _loadFile(_sessionFile);
        if (primary != null) {
          return primary;
        }
      } on _UnsupportedSessionSchema {
        return null;
      }
      try {
        return await _loadFile(_backupFile);
      } on _UnsupportedSessionSchema {
        return null;
      }
    } catch (error, stackTrace) {
      debugPrint('SessionStore.load failed: $error\n$stackTrace');
      return null;
    }
  }

  Future<GameSession?> _loadFile(File file) async {
    if (!await file.exists()) {
      return null;
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      final json = _jsonMapOrNull(decoded);
      if (json == null) {
        throw const FormatException('session archive root is not an object');
      }
      final version = _intOrNull(json['schemaVersion']);
      if (version != _schemaVersion) {
        debugPrint(
          'SessionStore.load ignored ${p.basename(file.path)}: '
          'unsupported schemaVersion $version',
        );
        throw const _UnsupportedSessionSchema();
      }
      return _sessionFromJson(json, DateTime.now().toUtc());
    } on _UnsupportedSessionSchema {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        'SessionStore.load could not read ${p.basename(file.path)}: '
        '$error\n$stackTrace',
      );
      return null;
    }
  }
}

class _UnsupportedSessionSchema implements Exception {
  const _UnsupportedSessionSchema();
}

Map<String, Object?> _sessionToJson(GameSession session) {
  return <String, Object?>{
    'schemaVersion': _schemaVersion,
    'current': _nullablePetToJson(session.current),
    'wallet': _walletToJson(session.wallet),
    'yard': _yardToJson(session.yard),
    'settings': _settingsToJson(session.settings),
    'clues': session.clues.map(
      (key, value) => MapEntry(key, _clueToJson(value)),
    ),
    'achievements': session.achievements.map(
      (key, value) => MapEntry(key, _achievementToJson(value)),
    ),
    'eventCounts': Map<String, int>.from(session.eventCounts),
    'visitorCounts': Map<String, int>.from(session.visitorCounts),
    'careActionCount': session.careActionCount,
    'revisitCount': session.revisitCount,
    'specialEventCount': session.specialEventCount,
    'roaming': session.roaming.map(_petToJson).toList(),
    'journeys': session.journeys.map(_journeyToJson).toList(),
    'jobs': session.jobs.map(_jobToJson).toList(),
    'generatedDays': session.generatedDays.toList(),
    'firedSpecials': session.firedSpecials.toList(),
    'visitorLog': session.visitorLog.map(_visitorLogToJson).toList(),
    'activeVisitor': _nullableActiveVisitorToJson(session.activeVisitor),
    'ownedSpecies': session.ownedSpecies.toList(),
    'postcards': session.postcards.map(_postcardToJson).toList(),
    'revisitor': _nullablePetToJson(session.revisitor),
  };
}

GameSession _sessionFromJson(Map<String, Object?> json, DateTime now) {
  final settings = _settingsFromJson(_jsonMapOrNull(json['settings']), now);
  final session = GameSession(
    current: _nullablePetFromJson(json['current'], now),
    wallet: _walletFromJson(_jsonMapOrNull(json['wallet'])),
    yard: _yardFromJson(_jsonMapOrNull(json['yard']), now),
    settings: settings,
  );
  session.clues.addAll(_cluesFromJson(json['clues']));
  session.achievements.addAll(_achievementsFromJson(json['achievements']));
  session.eventCounts.addAll(_intMapFromJson(json['eventCounts']));
  session.visitorCounts.addAll(_intMapFromJson(json['visitorCounts']));
  session.careActionCount = _readInt(json['careActionCount'], 0);
  session.revisitCount = _readInt(json['revisitCount'], 0);
  session.specialEventCount = _readInt(json['specialEventCount'], 0);
  session.roaming.addAll(_petListFromJson(json['roaming'], now));
  session.journeys.addAll(_journeyListFromJson(json['journeys'], now));
  session.jobs.addAll(_jobListFromJson(json['jobs'], now));
  session.generatedDays.addAll(_stringListFromJson(json['generatedDays']));
  session.firedSpecials.addAll(_stringListFromJson(json['firedSpecials']));
  session.visitorLog.addAll(_visitorLogListFromJson(json['visitorLog'], now));
  session.activeVisitor = _nullableActiveVisitorFromJson(
    json['activeVisitor'],
    now,
  );
  session.ownedSpecies.addAll(_stringListFromJson(json['ownedSpecies']));
  session.postcards.addAll(_postcardListFromJson(json['postcards'], now));
  session.revisitor = _nullablePetFromJson(json['revisitor'], now);
  return session;
}

Map<String, Object?>? _nullablePetToJson(Pet? pet) {
  return pet == null ? null : _petToJson(pet);
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

Pet? _nullablePetFromJson(Object? value, DateTime now) {
  final json = _jsonMapOrNull(value);
  return json == null ? null : _petFromJson(json, now);
}

Pet _petFromJson(Map<String, Object?> json, DateTime now) {
  final bornAt = _readDate(json['bornAt'], now);
  final lastOnlineAt = _readDate(json['lastOnlineAt'], bornAt);
  return Pet(
    id: _readString(json['id'], ''),
    speciesId: _readString(json['speciesId'], ''),
    variantId: _readString(json['variantId'], ''),
    name: _readString(json['name'], '宝贝'),
    personality: _stringListFromJson(json['personality']),
    bornAt: bornAt,
    lastOnlineAt: lastOnlineAt,
    offlineDayKey: _readString(json['offlineDayKey'], _dayKey(lastOnlineAt)),
    level: _readInt(json['level'], 1),
    exp: _readInt(json['exp'], 0),
    stage: _readEnum(PetStage.values, json['stage'], PetStage.a),
    state: _readEnum(PetState.values, json['state'], PetState.raising),
    offlineExpGrantedToday: _readInt(json['offlineExpGrantedToday'], 0),
    wishId: _readNullableString(json['wishId']),
    graduatedAt: _readNullableDate(json['graduatedAt']),
    journeyId: _readNullableString(json['journeyId']),
    nextRevisitAt: _readNullableDate(json['nextRevisitAt']),
    pastNames: _stringListFromJson(json['pastNames']),
  );
}

List<Pet> _petListFromJson(Object? value, DateTime now) {
  return _jsonMapListFromJson(
    value,
  ).map((json) => _petFromJson(json, now)).toList();
}

Map<String, Object?> _walletToJson(CurrencyWallet wallet) {
  return <String, Object?>{'balance': wallet.balance};
}

CurrencyWallet _walletFromJson(Map<String, Object?>? json) {
  return CurrencyWallet(balance: _readInt(json?['balance'], 0));
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

YardState _yardFromJson(Map<String, Object?>? json, DateTime now) {
  final fallback = YardState();
  if (json == null) {
    return fallback;
  }
  return YardState(
    luxuryStage: _readInt(json['luxuryStage'], fallback.luxuryStage),
    gradCount: _readInt(json['gradCount'], fallback.gradCount),
    activeThemeId: _readString(json['activeThemeId'], fallback.activeThemeId),
    ownedThemeIds: _stringListFromJson(
      json['ownedThemeIds'],
      fallback: fallback.ownedThemeIds,
    ),
    slots: _yardSlotListFromJson(json['slots']),
    foodTray: _foodTrayFromJson(_jsonMapOrNull(json['foodTray']), now),
    ownedPerks: _stringListFromJson(
      json['ownedPerks'],
      fallback: fallback.ownedPerks,
    ),
    ownedDecorIds: _stringListFromJson(
      json['ownedDecorIds'],
      fallback: fallback.ownedDecorIds,
    ),
  );
}

Map<String, Object?> _yardSlotToJson(YardSlot slot) {
  return <String, Object?>{'pos': slot.pos, 'itemId': slot.itemId};
}

YardSlot _yardSlotFromJson(Map<String, Object?> json) {
  return YardSlot(
    pos: _readInt(json['pos'], 0),
    itemId: _readNullableString(json['itemId']),
  );
}

List<YardSlot> _yardSlotListFromJson(Object? value) {
  return _jsonMapListFromJson(value).map(_yardSlotFromJson).toList();
}

Map<String, Object?> _foodTrayToJson(FoodTray tray) {
  return <String, Object?>{
    'foodType': tray.foodType,
    'placedAt': _nullableDateToJson(tray.placedAt),
  };
}

FoodTray _foodTrayFromJson(Map<String, Object?>? json, DateTime now) {
  if (json == null) {
    return FoodTray();
  }
  return FoodTray(
    foodType: _readNullableString(json['foodType']),
    placedAt: _readNullableDate(json['placedAt'], fallback: now),
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

Settings _settingsFromJson(Map<String, Object?>? json, DateTime now) {
  if (json == null) {
    return Settings(createdAt: now, lastWallClockAt: now);
  }
  return Settings(
    createdAt: _readDate(json['createdAt'], now),
    lastWallClockAt: _readDate(json['lastWallClockAt'], now),
    notifications: _readBool(json['notifications'], true),
    sound: _readBool(json['sound'], true),
    schemaVersion: _readInt(json['schemaVersion'], 1),
    lastMonotonicRef: _readInt(json['lastMonotonicRef'], 0),
    loginStreakCurrent: _readInt(json['loginStreakCurrent'], 0),
    loginStreakMax: _readInt(json['loginStreakMax'], 0),
    lastLoginDay: _readString(json['lastLoginDay'], ''),
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

ClueCounter _clueFromJson(Map<String, Object?> json, String defaultId) {
  return ClueCounter(
    clueId: _readString(json['clueId'], defaultId),
    threshold: _readInt(json['threshold'], 0),
    count: _readInt(json['count'], 0),
    visitorSeen: _readBool(json['visitorSeen'], false),
  );
}

Map<String, ClueCounter> _cluesFromJson(Object? value) {
  final json = _jsonMapOrNull(value);
  if (json == null) {
    return <String, ClueCounter>{};
  }
  final result = <String, ClueCounter>{};
  for (final entry in json.entries) {
    final clue = _jsonMapOrNull(entry.value);
    if (clue != null) {
      result[entry.key] = _clueFromJson(clue, entry.key);
    }
  }
  return result;
}

Map<String, Object?> _achievementToJson(AchievementProgress achievement) {
  return <String, Object?>{
    'achievementId': achievement.achievementId,
    'progress': achievement.progress,
    'unlockedAt': _nullableDateToJson(achievement.unlockedAt),
    'rewardClaimed': achievement.rewardClaimed,
  };
}

AchievementProgress _achievementFromJson(
  Map<String, Object?> json,
  String defaultId,
) {
  return AchievementProgress(
    achievementId: _readString(json['achievementId'], defaultId),
    progress: _readInt(json['progress'], 0),
    unlockedAt: _readNullableDate(json['unlockedAt']),
    rewardClaimed: _readBool(json['rewardClaimed'], false),
  );
}

Map<String, AchievementProgress> _achievementsFromJson(Object? value) {
  final json = _jsonMapOrNull(value);
  if (json == null) {
    return <String, AchievementProgress>{};
  }
  final result = <String, AchievementProgress>{};
  for (final entry in json.entries) {
    final achievement = _jsonMapOrNull(entry.value);
    if (achievement != null) {
      result[entry.key] = _achievementFromJson(achievement, entry.key);
    }
  }
  return result;
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

Journey _journeyFromJson(Map<String, Object?> json, DateTime now) {
  return Journey(
    id: _readString(json['id'], ''),
    petId: _readString(json['petId'], ''),
    stops: _stringListFromJson(json['stops']),
    wanderStops: _stringListFromJson(json['wanderStops']),
    nextPostcardAt: _readDate(json['nextPostcardAt'], now),
    currentIdx: _readInt(json['currentIdx'], 0),
    wanderIdx: _readInt(json['wanderIdx'], 0),
    longTermSeq: _readInt(json['longTermSeq'], 0),
    state: _readEnum(JourneyState.values, json['state'], JourneyState.active),
  );
}

List<Journey> _journeyListFromJson(Object? value, DateTime now) {
  return _jsonMapListFromJson(
    value,
  ).map((json) => _journeyFromJson(json, now)).toList();
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

ScheduledJob _jobFromJson(Map<String, Object?> json, DateTime now) {
  return ScheduledJob(
    id: _readString(json['id'], ''),
    type: _readEnum(JobType.values, json['type'], JobType.dailyEventGen),
    dueAt: _readDate(json['dueAt'], now),
    priority: _readInt(json['priority'], 0),
    payloadRef: _readNullableString(json['payloadRef']),
    consumed: _readBool(json['consumed'], false),
  );
}

List<ScheduledJob> _jobListFromJson(Object? value, DateTime now) {
  return _jsonMapListFromJson(
    value,
  ).map((json) => _jobFromJson(json, now)).toList();
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

VisitorLogEntry _visitorLogFromJson(Map<String, Object?> json, DateTime now) {
  return VisitorLogEntry(
    id: _readString(json['id'], ''),
    visitorId: _readString(json['visitorId'], ''),
    date: _readDate(json['date'], now),
    interactionId: _readNullableString(json['interactionId']),
    withPetId: _readNullableString(json['withPetId']),
  );
}

List<VisitorLogEntry> _visitorLogListFromJson(Object? value, DateTime now) {
  return _jsonMapListFromJson(
    value,
  ).map((json) => _visitorLogFromJson(json, now)).toList();
}

Map<String, Object?>? _nullableActiveVisitorToJson(ActiveVisitor? visitor) {
  if (visitor == null) {
    return null;
  }
  return <String, Object?>{
    'visitorId': visitor.visitorId,
    'arrivedAt': _dateToJson(visitor.arrivedAt),
    'leavesAt': _dateToJson(visitor.leavesAt),
    'interactionId': visitor.interactionId,
    'withPetId': visitor.withPetId,
    'arrivalSeen': visitor.arrivalSeen,
  };
}

ActiveVisitor? _nullableActiveVisitorFromJson(Object? value, DateTime now) {
  final json = _jsonMapOrNull(value);
  if (json == null) {
    return null;
  }
  final leavesAt = _readDate(json['leavesAt'], now);
  if (!leavesAt.isAfter(now)) {
    return null;
  }
  return ActiveVisitor(
    visitorId: _readString(json['visitorId'], ''),
    arrivedAt: _readDate(json['arrivedAt'], now),
    leavesAt: leavesAt,
    interactionId: _readNullableString(json['interactionId']),
    withPetId: _readNullableString(json['withPetId']),
    arrivalSeen: _readBool(json['arrivalSeen'], false),
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

Postcard _postcardFromJson(Map<String, Object?> json, DateTime now) {
  return Postcard(
    id: _readString(json['id'], ''),
    petId: _readString(json['petId'], ''),
    journeyId: _readString(json['journeyId'], ''),
    locationId: _readString(json['locationId'], ''),
    seq: _readInt(json['seq'], 0),
    sentAt: _readDate(json['sentAt'], now),
    receivedAt: _readNullableDate(json['receivedAt']),
    season: _readEnum(Season.values, json['season'], Season.spring),
    timeOfDay: _readEnum(
      TimeOfDayOfDay.values,
      json['timeOfDay'],
      TimeOfDayOfDay.dawn,
    ),
    weather: _readEnum(Weather.values, json['weather'], Weather.clear),
    bodyText: _readString(json['bodyText'], ''),
    photoAssetId: _readString(json['photoAssetId'], ''),
    stampId: _readString(json['stampId'], ''),
    encounterId: _readNullableString(json['encounterId']),
    incidentId: _readNullableString(json['incidentId']),
    clueToPet: _readNullableString(json['clueToPet']),
    clueToVisitor: _readNullableString(json['clueToVisitor']),
  );
}

List<Postcard> _postcardListFromJson(Object? value, DateTime now) {
  return _jsonMapListFromJson(
    value,
  ).map((json) => _postcardFromJson(json, now)).toList();
}

Map<String, int> _intMapFromJson(Object? value) {
  final json = _jsonMapOrNull(value);
  if (json == null) {
    return <String, int>{};
  }
  return json.map((key, value) => MapEntry(key, _readInt(value, 0)));
}

List<Map<String, Object?>> _jsonMapListFromJson(Object? value) {
  if (value is! List) {
    return <Map<String, Object?>>[];
  }
  return value.map(_jsonMapOrNull).whereType<Map<String, Object?>>().toList();
}

List<String> _stringListFromJson(
  Object? value, {
  List<String> fallback = const <String>[],
}) {
  if (value is! List) {
    return List<String>.from(fallback);
  }
  return value.whereType<String>().toList();
}

Map<String, Object?>? _jsonMapOrNull(Object? value) {
  if (value is! Map) {
    return null;
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is String) {
      result[key] = entry.value;
    }
  }
  return result;
}

String _dateToJson(DateTime value) {
  return value.toUtc().toIso8601String();
}

String? _nullableDateToJson(DateTime? value) {
  return value == null ? null : _dateToJson(value);
}

DateTime _readDate(Object? value, DateTime fallback) {
  final parsed = _readNullableDate(value);
  return parsed ?? fallback.toUtc();
}

DateTime? _readNullableDate(Object? value, {DateTime? fallback}) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return fallback?.toUtc();
    }
  }
  return fallback?.toUtc();
}

E _readEnum<E extends Enum>(List<E> values, Object? value, E fallback) {
  if (value is! String) {
    return fallback;
  }
  try {
    return values.byName(value);
  } catch (_) {
    return fallback;
  }
}

int _readInt(Object? value, int fallback) {
  return _intOrNull(value) ?? fallback;
}

int? _intOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool _readBool(Object? value, bool fallback) {
  if (value is bool) {
    return value;
  }
  return fallback;
}

String _readString(Object? value, String fallback) {
  if (value is String) {
    return value;
  }
  return fallback;
}

String? _readNullableString(Object? value) {
  return value is String ? value : null;
}

String _dayKey(DateTime value) {
  final local = value.toUtc();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
