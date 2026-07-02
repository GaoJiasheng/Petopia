import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/enums.dart';
import '../../domain/models/logs.dart';

int _ms(DateTime value) => value.toUtc().millisecondsSinceEpoch;

DateTime _utcDate(Object? millis) {
  return DateTime.fromMillisecondsSinceEpoch(millis! as int, isUtc: true);
}

abstract final class PetopiaSqliteSchema {
  static const int version = 1;

  static Future<void> migrate(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS exp_log (
  id TEXT PRIMARY KEY NOT NULL,
  pet_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  source_type TEXT NOT NULL,
  source_ref TEXT,
  delta INTEGER NOT NULL,
  level_at INTEGER NOT NULL,
  exp_after INTEGER NOT NULL,
  note TEXT
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_explog_pet '
      'ON exp_log (pet_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_explog_pet_ts '
      'ON exp_log (pet_id, timestamp)',
    );

    await db.execute('''
CREATE TABLE IF NOT EXISTS currency_log (
  id TEXT PRIMARY KEY NOT NULL,
  timestamp INTEGER NOT NULL,
  delta INTEGER NOT NULL,
  reason TEXT NOT NULL,
  ref TEXT,
  balance_after INTEGER NOT NULL
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_curlog_ts '
      'ON currency_log (timestamp)',
    );

    await db.execute('''
CREATE TABLE IF NOT EXISTS postcard (
  id TEXT PRIMARY KEY NOT NULL,
  pet_id TEXT NOT NULL,
  journey_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  seq INTEGER NOT NULL,
  sent_at INTEGER NOT NULL,
  received_at INTEGER,
  season TEXT NOT NULL,
  time_of_day TEXT NOT NULL,
  weather TEXT NOT NULL,
  encounter_id TEXT,
  incident_id TEXT,
  body_text TEXT NOT NULL,
  photo_asset_id TEXT NOT NULL,
  stamp_id TEXT NOT NULL,
  clue_to_pet TEXT,
  clue_to_visitor TEXT
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_postcard_pet '
      'ON postcard (pet_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_postcard_recv '
      'ON postcard (received_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_postcard_loc '
      'ON postcard (location_id)',
    );

    await db.execute('''
CREATE TABLE IF NOT EXISTS event_log (
  id TEXT PRIMARY KEY NOT NULL,
  event_id TEXT NOT NULL,
  pet_id TEXT,
  date INTEGER NOT NULL,
  choice_idx INTEGER,
  exp_granted INTEGER NOT NULL
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_eventlog_event_date '
      'ON event_log (event_id, date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_eventlog_pet '
      'ON event_log (pet_id)',
    );
  }
}

class PetopiaSqliteDao {
  PetopiaSqliteDao(this._db);

  final Database _db;

  static Future<PetopiaSqliteDao> open({String? databasePath}) async {
    final path =
        databasePath ?? p.join(await getDatabasesPath(), 'petopia_logs.db');
    final db = await openDatabase(
      path,
      version: PetopiaSqliteSchema.version,
      onCreate: (db, _) => PetopiaSqliteSchema.migrate(db),
      onUpgrade: (db, _, _) => PetopiaSqliteSchema.migrate(db),
    );
    return PetopiaSqliteDao(db);
  }

  Future<void> migrate() => PetopiaSqliteSchema.migrate(_db);

  Future<PetopiaSqliteSnapshot> exportSnapshot() async {
    final expRows = await _db.query(
      'exp_log',
      orderBy: 'timestamp ASC, id ASC',
    );
    final currencyRows = await _db.query(
      'currency_log',
      orderBy: 'timestamp ASC, id ASC',
    );
    final postcardRows = await _db.query(
      'postcard',
      orderBy: 'sent_at ASC, id ASC',
    );
    final eventRows = await _db.query('event_log', orderBy: 'date ASC, id ASC');

    return PetopiaSqliteSnapshot(
      expLogs: expRows.map(_expLogFromRow).toList(),
      currencyLogs: currencyRows.map(_currencyLogFromRow).toList(),
      postcards: postcardRows.map(_postcardFromRow).toList(),
      eventLogs: eventRows.map(_eventLogFromRow).toList(),
    );
  }

  Future<void> replaceAll(PetopiaSqliteSnapshot snapshot) {
    return _db.transaction((txn) async {
      await txn.delete('exp_log');
      await txn.delete('currency_log');
      await txn.delete('postcard');
      await txn.delete('event_log');

      for (final entry in snapshot.expLogs) {
        await _insertExpLog(txn, entry);
      }
      for (final entry in snapshot.currencyLogs) {
        await _insertCurrencyLog(txn, entry);
      }
      for (final postcard in snapshot.postcards) {
        await _insertPostcard(txn, postcard);
      }
      for (final entry in snapshot.eventLogs) {
        await _insertEventLog(txn, entry);
      }
    });
  }

  Future<void> insertExpLog(ExpLogEntry entry) {
    return _insertExpLog(_db, entry);
  }

  Future<void> insertCurrencyLog(CurrencyLog entry) {
    return _insertCurrencyLog(_db, entry);
  }

  Future<void> insertPostcard(Postcard postcard) {
    return _insertPostcard(_db, postcard);
  }

  Future<void> insertEventLog(EventLogEntry entry) {
    return _insertEventLog(_db, entry);
  }

  Future<List<ExpLogEntry>> expLogsForPet(
    String petId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _petRangeWhere('pet_id', petId, 'timestamp', from, to);
    final rows = await _db.query(
      'exp_log',
      where: query.where,
      whereArgs: query.args,
      orderBy: 'timestamp ASC',
    );
    return rows.map(_expLogFromRow).toList();
  }

  Future<List<CurrencyLog>> currencyLogs({DateTime? from, DateTime? to}) async {
    final query = _rangeWhere('timestamp', from, to);
    final rows = await _db.query(
      'currency_log',
      where: query.where,
      whereArgs: query.args,
      orderBy: 'timestamp ASC',
    );
    return rows.map(_currencyLogFromRow).toList();
  }

  Future<List<Postcard>> postcardsForPet(
    String petId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _petRangeWhere('pet_id', petId, 'sent_at', from, to);
    final rows = await _db.query(
      'postcard',
      where: query.where,
      whereArgs: query.args,
      orderBy: 'sent_at ASC',
    );
    return rows.map(_postcardFromRow).toList();
  }

  Future<List<EventLogEntry>> eventLogsForPet(
    String petId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _petRangeWhere('pet_id', petId, 'date', from, to);
    final rows = await _db.query(
      'event_log',
      where: query.where,
      whereArgs: query.args,
      orderBy: 'date ASC',
    );
    return rows.map(_eventLogFromRow).toList();
  }

  Future<int> sumDelta(String petId) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(delta), 0) AS total '
      'FROM exp_log WHERE pet_id = ?',
      <Object?>[petId],
    );
    return rows.first['total']! as int;
  }

  Future<int> sumCurrencyDelta() async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(delta), 0) AS total FROM currency_log',
    );
    return rows.first['total']! as int;
  }

  Future<bool> hasEventOnDate({
    required String eventId,
    required DateTime date,
  }) async {
    final rows = await _db.query(
      'event_log',
      columns: <String>['id'],
      where: 'event_id = ? AND date = ?',
      whereArgs: <Object?>[eventId, _ms(date)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> hasEventSince({
    required String eventId,
    required DateTime since,
  }) async {
    final rows = await _db.query(
      'event_log',
      columns: <String>['id'],
      where: 'event_id = ? AND date >= ?',
      whereArgs: <Object?>[eventId, _ms(since)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> hasEventForPet({
    required String eventId,
    required String petId,
  }) async {
    final rows = await _db.query(
      'event_log',
      columns: <String>['id'],
      where: 'event_id = ? AND pet_id = ?',
      whereArgs: <Object?>[eventId, petId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> close() => _db.close();
}

class PetopiaSqliteSnapshot {
  const PetopiaSqliteSnapshot({
    required this.expLogs,
    required this.currencyLogs,
    required this.postcards,
    required this.eventLogs,
  });

  final List<ExpLogEntry> expLogs;
  final List<CurrencyLog> currencyLogs;
  final List<Postcard> postcards;
  final List<EventLogEntry> eventLogs;
}

Future<void> _insertExpLog(DatabaseExecutor db, ExpLogEntry entry) {
  return db.insert('exp_log', <String, Object?>{
    'id': entry.id,
    'pet_id': entry.petId,
    'timestamp': _ms(entry.timestamp),
    'source_type': entry.sourceType.name,
    'source_ref': entry.sourceRef,
    'delta': entry.delta,
    'level_at': entry.levelAt,
    'exp_after': entry.expAfter,
    'note': entry.note,
  }, conflictAlgorithm: ConflictAlgorithm.abort);
}

Future<void> _insertCurrencyLog(DatabaseExecutor db, CurrencyLog entry) {
  return db.insert('currency_log', <String, Object?>{
    'id': entry.id,
    'timestamp': _ms(entry.timestamp),
    'delta': entry.delta,
    'reason': entry.reason.name,
    'ref': entry.ref,
    'balance_after': entry.balanceAfter,
  }, conflictAlgorithm: ConflictAlgorithm.abort);
}

Future<void> _insertPostcard(DatabaseExecutor db, Postcard postcard) {
  return db.insert('postcard', <String, Object?>{
    'id': postcard.id,
    'pet_id': postcard.petId,
    'journey_id': postcard.journeyId,
    'location_id': postcard.locationId,
    'seq': postcard.seq,
    'sent_at': _ms(postcard.sentAt),
    'received_at': postcard.receivedAt == null
        ? null
        : _ms(postcard.receivedAt!),
    'season': postcard.season.name,
    'time_of_day': postcard.timeOfDay.name,
    'weather': postcard.weather.name,
    'encounter_id': postcard.encounterId,
    'incident_id': postcard.incidentId,
    'body_text': postcard.bodyText,
    'photo_asset_id': postcard.photoAssetId,
    'stamp_id': postcard.stampId,
    'clue_to_pet': postcard.clueToPet,
    'clue_to_visitor': postcard.clueToVisitor,
  }, conflictAlgorithm: ConflictAlgorithm.abort);
}

Future<void> _insertEventLog(DatabaseExecutor db, EventLogEntry entry) {
  return db.insert('event_log', <String, Object?>{
    'id': entry.id,
    'event_id': entry.eventId,
    'pet_id': entry.petId,
    'date': _ms(entry.date),
    'choice_idx': entry.choiceIdx,
    'exp_granted': entry.expGranted,
  }, conflictAlgorithm: ConflictAlgorithm.abort);
}

_QueryParts _rangeWhere(String column, DateTime? from, DateTime? to) {
  final clauses = <String>[];
  final args = <Object?>[];
  if (from != null) {
    clauses.add('$column >= ?');
    args.add(_ms(from));
  }
  if (to != null) {
    clauses.add('$column <= ?');
    args.add(_ms(to));
  }
  return _QueryParts(clauses.join(' AND '), args);
}

_QueryParts _petRangeWhere(
  String petColumn,
  String petId,
  String timeColumn,
  DateTime? from,
  DateTime? to,
) {
  final range = _rangeWhere(timeColumn, from, to);
  final clauses = <String>['$petColumn = ?'];
  if (range.where.isNotEmpty) {
    clauses.add(range.where);
  }
  return _QueryParts(clauses.join(' AND '), <Object?>[petId, ...range.args]);
}

class _QueryParts {
  const _QueryParts(this.where, this.args);

  final String where;
  final List<Object?> args;
}

ExpLogEntry _expLogFromRow(Map<String, Object?> row) {
  return ExpLogEntry(
    id: row['id']! as String,
    petId: row['pet_id']! as String,
    timestamp: _utcDate(row['timestamp']),
    sourceType: ExpSource.values.byName(row['source_type']! as String),
    delta: row['delta']! as int,
    levelAt: row['level_at']! as int,
    expAfter: row['exp_after']! as int,
    sourceRef: row['source_ref'] as String?,
    note: row['note'] as String?,
  );
}

CurrencyLog _currencyLogFromRow(Map<String, Object?> row) {
  return CurrencyLog(
    id: row['id']! as String,
    timestamp: _utcDate(row['timestamp']),
    delta: row['delta']! as int,
    reason: CurrencyReason.values.byName(row['reason']! as String),
    balanceAfter: row['balance_after']! as int,
    ref: row['ref'] as String?,
  );
}

Postcard _postcardFromRow(Map<String, Object?> row) {
  final receivedAt = row['received_at'];
  return Postcard(
    id: row['id']! as String,
    petId: row['pet_id']! as String,
    journeyId: row['journey_id']! as String,
    locationId: row['location_id']! as String,
    seq: row['seq']! as int,
    sentAt: _utcDate(row['sent_at']),
    receivedAt: receivedAt == null ? null : _utcDate(receivedAt),
    season: Season.values.byName(row['season']! as String),
    timeOfDay: TimeOfDayOfDay.values.byName(row['time_of_day']! as String),
    weather: Weather.values.byName(row['weather']! as String),
    bodyText: row['body_text']! as String,
    photoAssetId: row['photo_asset_id']! as String,
    stampId: row['stamp_id']! as String,
    encounterId: row['encounter_id'] as String?,
    incidentId: row['incident_id'] as String?,
    clueToPet: row['clue_to_pet'] as String?,
    clueToVisitor: row['clue_to_visitor'] as String?,
  );
}

EventLogEntry _eventLogFromRow(Map<String, Object?> row) {
  return EventLogEntry(
    id: row['id']! as String,
    eventId: row['event_id']! as String,
    date: _utcDate(row['date']),
    expGranted: row['exp_granted']! as int,
    petId: row['pet_id'] as String?,
    choiceIdx: row['choice_idx'] as int?,
  );
}
