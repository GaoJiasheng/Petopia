import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/data/save/session_store.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('petopia_session_store_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('save/load round trips a rich GameSession', () async {
    final session = _richSession();
    final store = SessionStore(tempDir);

    await store.save(session);
    final loaded = await store.load();

    expect(loaded, isNotNull);
    _expectSessionEquals(loaded!, session);
  });

  test(
    'concurrent saves are serialized and keep the newest snapshot',
    () async {
      final session = _richSession();
      final store = SessionStore(tempDir);

      final first = store.save(session);
      session.wallet.balance = 2048;
      final second = store.save(session);
      await Future.wait([first, second]);

      final loaded = await store.load();
      expect(loaded?.wallet.balance, 2048);
    },
  );
}

GameSession _richSession() {
  final createdAt = DateTime.utc(2026, 7, 1, 8);
  final current = Pet(
    id: 'pet-current',
    speciesId: 'pet_cat',
    variantId: 'pet_cat_v3',
    name: '阿橘',
    personality: const <String>['p_glutton', 'p_curious'],
    bornAt: DateTime.utc(2026, 7, 1, 9),
    lastOnlineAt: DateTime.utc(2026, 7, 3, 11),
    offlineDayKey: '2026-07-03',
    level: 8,
    exp: 860,
    stage: PetStage.c,
    state: PetState.raising,
    offlineExpGrantedToday: 12,
    wishId: 'wish-meteor',
    pastNames: const <String>['橘一', '橘二'],
  );

  final session = GameSession(
    current: current,
    wallet: CurrencyWallet(balance: 1280),
    yard: YardState(
      luxuryStage: 3,
      gradCount: 4,
      activeThemeId: 'theme_rainbow',
      ownedThemeIds: const <String>['theme_default', 'theme_rainbow'],
      slots: <YardSlot>[
        YardSlot(pos: 0, itemId: 'deco_night_lamp'),
        YardSlot(pos: 1),
      ],
      foodTray: FoodTray(
        foodType: 'grain',
        placedAt: DateTime.utc(2026, 7, 3, 7, 30),
        probabilityScope: 'bird',
        probabilityDelta: 0.8,
        remaining: 2,
      ),
      ownedPerks: const <String>['toy_yarn_perm'],
      ownedDecorIds: const <String>['deco_night_lamp', 'deco_blue_bowl'],
    ),
    settings: Settings(
      createdAt: createdAt,
      lastWallClockAt: DateTime.utc(2026, 7, 3, 12),
      notifications: true,
      sound: false,
      schemaVersion: 1,
      lastMonotonicRef: 123456,
      loginStreakCurrent: 3,
      loginStreakMax: 5,
      lastLoginDay: '2026-07-03',
    ),
    shopInventory: ShopInventory(
      consumables: <String, int>{'shop_food_grain_bag': 2},
      ownedAlbumSkinIds: <String>{'default', 'paper'},
      activeAlbumSkinId: 'paper',
      activeVisitorFoodItemId: 'shop_food_grain_bag',
    ),
  );

  session.careLedger = CareLedger(
    dayKey: '2026-07-03',
    counts: <String, int>{'feed': 2, 'pat': 1},
    lastAt: <String, DateTime>{'feed': DateTime.utc(2026, 7, 3, 11)},
    firstCareRewarded: true,
  );
  session.achievementSignals.addAll(<String, int>{
    'action:feed': 2,
    'care:days': 1,
  });
  session.ownedVariants.addAll(<String>{'pet_cat_v3', 'pet_shiba_v2'});
  session.pendingEvents.add(
    PendingGameEvent(
      id: 'pending-1',
      eventId: 'ev_d01',
      title: '追落叶',
      script: '叼来一片落叶。',
      type: EventType.daily,
      expReward: 5,
      currencyReward: 0,
      createdAt: DateTime.utc(2026, 7, 3, 12),
    ),
  );

  session.clues.addAll(<String, ClueCounter>{
    'clue_ember': ClueCounter(
      clueId: 'clue_ember',
      threshold: 3,
      count: 2,
      visitorSeen: true,
    ),
    'clue_starbug': ClueCounter(clueId: 'clue_starbug', threshold: 5, count: 1),
  });
  session.achievements.addAll(<String, AchievementProgress>{
    'ach_first_grad': AchievementProgress(
      achievementId: 'ach_first_grad',
      progress: 1,
      unlockedAt: DateTime.utc(2026, 7, 2, 10),
      rewardClaimed: true,
    ),
    'ach_postcards': AchievementProgress(
      achievementId: 'ach_postcards',
      progress: 4,
    ),
  });
  session.eventCounts.addAll(<String, int>{'pet-current': 7, 'pet-roaming': 2});
  session.eventLastFiredAt['pet-current:ev_d01'] = DateTime.utc(2026, 7, 3, 12);
  session.visitorCounts.addAll(<String, int>{
    'pet-current': 3,
    'pet-roaming': 1,
  });
  session.roaming.add(
    Pet(
      id: 'pet-roaming',
      speciesId: 'pet_shiba',
      variantId: 'pet_shiba_v2',
      name: '柴柴',
      personality: const <String>['p_gentle', 'p_lazy'],
      bornAt: DateTime.utc(2026, 6, 1),
      lastOnlineAt: DateTime.utc(2026, 7, 2),
      offlineDayKey: '2026-07-02',
      level: 10,
      exp: 1000,
      stage: PetStage.d,
      state: PetState.roaming,
      graduatedAt: DateTime.utc(2026, 7, 2, 9),
      journeyId: 'journey-1',
      nextRevisitAt: DateTime.utc(2026, 7, 10),
      pastNames: const <String>['小柴'],
    ),
  );
  session.journeys.add(
    Journey(
      id: 'journey-1',
      petId: 'pet-roaming',
      stops: const <String>['loc_lighthouse', 'loc_forest', 'loc_city'],
      wanderStops: const <String>['loc_cloud', 'loc_library'],
      currentIdx: 1,
      wanderIdx: 1,
      longTermSeq: 2,
      nextPostcardAt: DateTime.utc(2026, 7, 4, 9),
      state: JourneyState.active,
    ),
  );
  session.jobs.add(
    ScheduledJob(
      id: 'job-1',
      type: JobType.visitorCheck,
      dueAt: DateTime.utc(2026, 7, 3, 18),
      priority: 3,
      payloadRef: 'night',
      consumed: true,
    ),
  );
  session.generatedDays.addAll(<String>{'2026-07-02', '2026-07-03'});
  session.firedSpecials.addAll(<String>{'pet-current:ev_s03'});
  session.visitorLog.addAll(<VisitorLogEntry>[
    VisitorLogEntry(
      id: 'visit-1',
      visitorId: 'vis_sparrow',
      date: DateTime.utc(2026, 7, 3, 8),
      interactionId: 'int_sparrow_cat',
      withPetId: 'pet-current',
    ),
    VisitorLogEntry(
      id: 'visit-2',
      visitorId: 'vis_fox',
      date: DateTime.utc(2026, 7, 3, 20),
    ),
  ]);
  session.activeVisitor = ActiveVisitor(
    visitorId: 'vis_fox',
    arrivedAt: DateTime.utc(2099, 7, 3, 20),
    leavesAt: DateTime.utc(2099, 7, 4, 20),
    interactionId: 'int_fox_cat',
    withPetId: 'pet-current',
    arrivalSeen: true,
  );
  session.ownedSpecies.addAll(<String>{'pet_cat', 'pet_shiba'});
  session.postcards.add(
    Postcard(
      id: 'postcard-1',
      petId: 'pet-roaming',
      journeyId: 'journey-1',
      locationId: 'loc_lighthouse',
      seq: 1,
      sentAt: DateTime.utc(2026, 7, 3, 9),
      receivedAt: DateTime.utc(2026, 7, 3, 10),
      season: Season.summer,
      timeOfDay: TimeOfDayOfDay.morning,
      weather: Weather.rainbow,
      encounterId: 'enc_sailor',
      incidentId: 'inc_shell',
      bodyText: '灯塔边有彩虹。',
      photoAssetId: 'pc_bg_lighthouse',
      stampId: 'stamp_lighthouse',
      clueToPet: 'clue_ember',
      clueToVisitor: 'clue_fox',
    ),
  );
  session.revisitor = Pet(
    id: 'pet-revisitor',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v1',
    name: '团子',
    personality: const <String>['p_clingy', 'p_dreamy'],
    bornAt: DateTime.utc(2026, 5, 1),
    lastOnlineAt: DateTime.utc(2026, 7, 1),
    offlineDayKey: '2026-07-01',
    level: 10,
    exp: 1100,
    stage: PetStage.d,
    state: PetState.revisiting,
    graduatedAt: DateTime.utc(2026, 6, 20),
    journeyId: 'journey-2',
    nextRevisitAt: DateTime.utc(2026, 7, 3),
  );
  session.revisitorArrivedAt = DateTime.utc(2026, 7, 3, 12);
  session.revisitorLeavesAt = DateTime.utc(2026, 7, 5, 12);
  session.revisitorArrivalSeen = true;
  session.revisitorInteracted = true;
  return session;
}

void _expectSessionEquals(GameSession actual, GameSession expected) {
  _expectNullablePetEquals(actual.current, expected.current);
  _expectWalletEquals(actual.wallet, expected.wallet);
  _expectYardEquals(actual.yard, expected.yard);
  _expectSettingsEquals(actual.settings, expected.settings);
  _expectClueMapEquals(actual.clues, expected.clues);
  _expectAchievementMapEquals(actual.achievements, expected.achievements);
  expect(actual.eventCounts, expected.eventCounts);
  expect(actual.eventLastFiredAt, expected.eventLastFiredAt);
  expect(actual.visitorCounts, expected.visitorCounts);
  expect(actual.achievementSignals, expected.achievementSignals);
  expect(actual.ownedVariants, unorderedEquals(expected.ownedVariants));
  expect(actual.careLedger.dayKey, expected.careLedger.dayKey);
  expect(actual.careLedger.counts, expected.careLedger.counts);
  expect(actual.careLedger.lastAt, expected.careLedger.lastAt);
  expect(
    actual.careLedger.firstCareRewarded,
    expected.careLedger.firstCareRewarded,
  );
  expect(actual.shopInventory.consumables, expected.shopInventory.consumables);
  expect(
    actual.shopInventory.ownedAlbumSkinIds,
    unorderedEquals(expected.shopInventory.ownedAlbumSkinIds),
  );
  expect(
    actual.shopInventory.activeAlbumSkinId,
    expected.shopInventory.activeAlbumSkinId,
  );
  expect(
    actual.shopInventory.activeVisitorFoodItemId,
    expected.shopInventory.activeVisitorFoodItemId,
  );
  expect(actual.pendingEvents, hasLength(expected.pendingEvents.length));
  expect(
    actual.pendingEvents.single.title,
    expected.pendingEvents.single.title,
  );
  _expectPetListEquals(actual.roaming, expected.roaming);
  _expectJourneyListEquals(actual.journeys, expected.journeys);
  _expectJobListEquals(actual.jobs, expected.jobs);
  expect(actual.generatedDays, unorderedEquals(expected.generatedDays));
  expect(actual.firedSpecials, unorderedEquals(expected.firedSpecials));
  _expectVisitorLogListEquals(actual.visitorLog, expected.visitorLog);
  _expectNullableActiveVisitorEquals(
    actual.activeVisitor,
    expected.activeVisitor,
  );
  expect(actual.ownedSpecies, unorderedEquals(expected.ownedSpecies));
  _expectPostcardListEquals(actual.postcards, expected.postcards);
  _expectNullablePetEquals(actual.revisitor, expected.revisitor);
  expect(actual.revisitorArrivedAt, expected.revisitorArrivedAt);
  expect(actual.revisitorLeavesAt, expected.revisitorLeavesAt);
  expect(actual.revisitorArrivalSeen, expected.revisitorArrivalSeen);
  expect(actual.revisitorInteracted, expected.revisitorInteracted);
}

void _expectNullablePetEquals(Pet? actual, Pet? expected) {
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isNotNull);
  _expectPetEquals(actual!, expected);
}

void _expectPetListEquals(List<Pet> actual, List<Pet> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    _expectPetEquals(actual[i], expected[i]);
  }
}

void _expectPetEquals(Pet actual, Pet expected) {
  expect(actual.id, expected.id);
  expect(actual.speciesId, expected.speciesId);
  expect(actual.variantId, expected.variantId);
  expect(actual.name, expected.name);
  expect(actual.personality, expected.personality);
  expect(actual.bornAt, expected.bornAt);
  expect(actual.level, expected.level);
  expect(actual.exp, expected.exp);
  expect(actual.stage, expected.stage);
  expect(actual.state, expected.state);
  expect(actual.lastOnlineAt, expected.lastOnlineAt);
  expect(actual.offlineExpGrantedToday, expected.offlineExpGrantedToday);
  expect(actual.offlineDayKey, expected.offlineDayKey);
  expect(actual.wishId, expected.wishId);
  expect(actual.graduatedAt, expected.graduatedAt);
  expect(actual.journeyId, expected.journeyId);
  expect(actual.nextRevisitAt, expected.nextRevisitAt);
  expect(actual.pastNames, expected.pastNames);
}

void _expectWalletEquals(CurrencyWallet actual, CurrencyWallet expected) {
  expect(actual.balance, expected.balance);
}

void _expectYardEquals(YardState actual, YardState expected) {
  expect(actual.luxuryStage, expected.luxuryStage);
  expect(actual.gradCount, expected.gradCount);
  expect(actual.activeThemeId, expected.activeThemeId);
  expect(actual.ownedThemeIds, expected.ownedThemeIds);
  expect(actual.slots, hasLength(expected.slots.length));
  for (var i = 0; i < expected.slots.length; i++) {
    expect(actual.slots[i].pos, expected.slots[i].pos);
    expect(actual.slots[i].itemId, expected.slots[i].itemId);
  }
  expect(actual.foodTray.foodType, expected.foodTray.foodType);
  expect(actual.foodTray.placedAt, expected.foodTray.placedAt);
  expect(actual.foodTray.probabilityScope, expected.foodTray.probabilityScope);
  expect(actual.foodTray.probabilityDelta, expected.foodTray.probabilityDelta);
  expect(actual.foodTray.remaining, expected.foodTray.remaining);
  expect(actual.ownedPerks, expected.ownedPerks);
  expect(actual.ownedDecorIds, expected.ownedDecorIds);
}

void _expectSettingsEquals(Settings actual, Settings expected) {
  expect(actual.notifications, expected.notifications);
  expect(actual.sound, expected.sound);
  expect(actual.schemaVersion, expected.schemaVersion);
  expect(actual.createdAt, expected.createdAt);
  expect(actual.lastMonotonicRef, expected.lastMonotonicRef);
  expect(actual.lastWallClockAt, expected.lastWallClockAt);
  expect(actual.loginStreakCurrent, expected.loginStreakCurrent);
  expect(actual.loginStreakMax, expected.loginStreakMax);
  expect(actual.lastLoginDay, expected.lastLoginDay);
}

void _expectClueMapEquals(
  Map<String, ClueCounter> actual,
  Map<String, ClueCounter> expected,
) {
  expect(actual.keys, unorderedEquals(expected.keys));
  for (final key in expected.keys) {
    expect(actual[key]!.clueId, expected[key]!.clueId);
    expect(actual[key]!.count, expected[key]!.count);
    expect(actual[key]!.threshold, expected[key]!.threshold);
    expect(actual[key]!.visitorSeen, expected[key]!.visitorSeen);
  }
}

void _expectAchievementMapEquals(
  Map<String, AchievementProgress> actual,
  Map<String, AchievementProgress> expected,
) {
  expect(actual.keys, unorderedEquals(expected.keys));
  for (final key in expected.keys) {
    expect(actual[key]!.achievementId, expected[key]!.achievementId);
    expect(actual[key]!.progress, expected[key]!.progress);
    expect(actual[key]!.unlockedAt, expected[key]!.unlockedAt);
    expect(actual[key]!.rewardClaimed, expected[key]!.rewardClaimed);
  }
}

void _expectJourneyListEquals(List<Journey> actual, List<Journey> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i].id, expected[i].id);
    expect(actual[i].petId, expected[i].petId);
    expect(actual[i].stops, expected[i].stops);
    expect(actual[i].wanderStops, expected[i].wanderStops);
    expect(actual[i].currentIdx, expected[i].currentIdx);
    expect(actual[i].wanderIdx, expected[i].wanderIdx);
    expect(actual[i].longTermSeq, expected[i].longTermSeq);
    expect(actual[i].nextPostcardAt, expected[i].nextPostcardAt);
    expect(actual[i].state, expected[i].state);
  }
}

void _expectJobListEquals(
  List<ScheduledJob> actual,
  List<ScheduledJob> expected,
) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i].id, expected[i].id);
    expect(actual[i].type, expected[i].type);
    expect(actual[i].dueAt, expected[i].dueAt);
    expect(actual[i].priority, expected[i].priority);
    expect(actual[i].payloadRef, expected[i].payloadRef);
    expect(actual[i].consumed, expected[i].consumed);
  }
}

void _expectVisitorLogListEquals(
  List<VisitorLogEntry> actual,
  List<VisitorLogEntry> expected,
) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i].id, expected[i].id);
    expect(actual[i].visitorId, expected[i].visitorId);
    expect(actual[i].date, expected[i].date);
    expect(actual[i].interactionId, expected[i].interactionId);
    expect(actual[i].withPetId, expected[i].withPetId);
  }
}

void _expectNullableActiveVisitorEquals(
  ActiveVisitor? actual,
  ActiveVisitor? expected,
) {
  if (expected == null) {
    expect(actual, isNull);
    return;
  }
  expect(actual, isNotNull);
  expect(actual!.visitorId, expected.visitorId);
  expect(actual.arrivedAt, expected.arrivedAt);
  expect(actual.leavesAt, expected.leavesAt);
  expect(actual.interactionId, expected.interactionId);
  expect(actual.withPetId, expected.withPetId);
  expect(actual.arrivalSeen, expected.arrivalSeen);
}

void _expectPostcardListEquals(List<Postcard> actual, List<Postcard> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i].id, expected[i].id);
    expect(actual[i].petId, expected[i].petId);
    expect(actual[i].journeyId, expected[i].journeyId);
    expect(actual[i].locationId, expected[i].locationId);
    expect(actual[i].seq, expected[i].seq);
    expect(actual[i].sentAt, expected[i].sentAt);
    expect(actual[i].receivedAt, expected[i].receivedAt);
    expect(actual[i].season, expected[i].season);
    expect(actual[i].timeOfDay, expected[i].timeOfDay);
    expect(actual[i].weather, expected[i].weather);
    expect(actual[i].encounterId, expected[i].encounterId);
    expect(actual[i].incidentId, expected[i].incidentId);
    expect(actual[i].bodyText, expected[i].bodyText);
    expect(actual[i].photoAssetId, expected[i].photoAssetId);
    expect(actual[i].stampId, expected[i].stampId);
    expect(actual[i].clueToPet, expected[i].clueToPet);
    expect(actual[i].clueToVisitor, expected[i].clueToVisitor);
  }
}
