import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/data/sqlite/petopia_sqlite_dao.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late PetopiaSqliteDao dao;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('petopia-sqlite-');
    dao = await PetopiaSqliteDao.open(
      databasePath: '${tempDir.path}/petopia.db',
    );
  });

  tearDown(() async {
    await dao.close();
    await tempDir.delete(recursive: true);
  });

  test('append-only logs support sums and inclusive UTC ranges', () async {
    final t0 = DateTime.utc(2026, 7, 1, 8);
    await dao.insertExpLog(_exp('exp-1', 'pet-a', t0, 3, 3));
    await dao.insertExpLog(
      _exp('exp-2', 'pet-a', t0.add(const Duration(hours: 1)), 5, 8),
    );
    await dao.insertExpLog(
      _exp('exp-3', 'pet-b', t0.add(const Duration(hours: 1)), 7, 7),
    );
    await dao.insertCurrencyLog(
      CurrencyLog(
        id: 'currency-1',
        timestamp: t0,
        delta: 20,
        reason: CurrencyReason.dailyFirstCare,
        balanceAfter: 20,
      ),
    );
    await dao.insertCurrencyLog(
      CurrencyLog(
        id: 'currency-2',
        timestamp: t0.add(const Duration(hours: 2)),
        delta: -6,
        reason: CurrencyReason.shopPurchase,
        balanceAfter: 14,
      ),
    );

    expect(await dao.sumDelta('pet-a'), 8);
    expect(await dao.sumDelta('pet-b'), 7);
    expect(await dao.sumCurrencyDelta(), 14);
    final exactHour = await dao.expLogsForPet(
      'pet-a',
      from: t0.add(const Duration(hours: 1)),
      to: t0.add(const Duration(hours: 1)),
    );
    expect(exactHour.map((entry) => entry.id), <String>['exp-2']);
    expect(await dao.currencyLogs(), hasLength(2));
    expect(
      await dao.currencyLogs(to: t0.add(const Duration(hours: 1))),
      hasLength(1),
    );
  });

  test('postcard and event indexes preserve complete domain records', () async {
    final sentAt = DateTime.utc(2026, 7, 4, 9);
    final postcard = Postcard(
      id: 'postcard-1',
      petId: 'pet-a',
      journeyId: 'journey-a',
      locationId: 'loc-lighthouse',
      seq: 3,
      sentAt: sentAt,
      receivedAt: sentAt.add(const Duration(minutes: 5)),
      season: Season.summer,
      timeOfDay: TimeOfDayOfDay.morning,
      weather: Weather.rainbow,
      encounterId: 'enc-sailor',
      incidentId: 'inc-shell',
      bodyText: '灯塔边的风很轻。',
      photoAssetId: 'pc_bg_lighthouse',
      stampId: 'stamp_lighthouse',
      clueToPet: 'clue-ember',
      clueToVisitor: 'clue-fox',
    );
    final event = EventLogEntry(
      id: 'event-1',
      eventId: 'ev-special',
      petId: 'pet-a',
      date: sentAt,
      choiceIdx: 1,
      expGranted: 8,
    );
    await dao.insertPostcard(postcard);
    await dao.insertEventLog(event);

    final cards = await dao.postcardsForPet('pet-a');
    expect(cards, hasLength(1));
    expect(cards.single.bodyText, postcard.bodyText);
    expect(cards.single.weather, Weather.rainbow);
    expect(cards.single.clueToVisitor, 'clue-fox');
    expect(
      await dao.hasEventOnDate(eventId: event.eventId, date: sentAt),
      isTrue,
    );
    expect(
      await dao.hasEventSince(
        eventId: event.eventId,
        since: sentAt.subtract(const Duration(minutes: 1)),
      ),
      isTrue,
    );
    expect(
      await dao.hasEventForPet(eventId: event.eventId, petId: 'pet-a'),
      isTrue,
    );
    expect(
      await dao.hasEventForPet(eventId: event.eventId, petId: 'pet-b'),
      isFalse,
    );
  });

  test(
    'snapshot replacement is transactional and removes stale rows',
    () async {
      final t0 = DateTime.utc(2026, 7, 1);
      await dao.insertExpLog(_exp('old', 'pet-old', t0, 9, 9));
      final snapshot = PetopiaSqliteSnapshot(
        expLogs: <ExpLogEntry>[_exp('new', 'pet-new', t0, 4, 4)],
        currencyLogs: <CurrencyLog>[
          CurrencyLog(
            id: 'new-currency',
            timestamp: t0,
            delta: 12,
            reason: CurrencyReason.dailyFirstCare,
            balanceAfter: 12,
          ),
        ],
        postcards: const <Postcard>[],
        eventLogs: const <EventLogEntry>[],
      );

      await dao.replaceAll(snapshot);
      final exported = await dao.exportSnapshot();

      expect(exported.expLogs.map((entry) => entry.id), <String>['new']);
      expect(exported.currencyLogs.single.id, 'new-currency');
      expect(await dao.sumDelta('pet-old'), 0);
      expect(await dao.sumDelta('pet-new'), 4);
    },
  );
}

ExpLogEntry _exp(
  String id,
  String petId,
  DateTime timestamp,
  int delta,
  int expAfter,
) {
  return ExpLogEntry(
    id: id,
    petId: petId,
    timestamp: timestamp,
    sourceType: ExpSource.feed,
    sourceRef: 'test:$id',
    delta: delta,
    levelAt: 1,
    expAfter: expAfter,
    note: '测试流水',
  );
}
