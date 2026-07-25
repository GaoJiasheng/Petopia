import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/log_port.dart';

class _MemoryPort implements AuditLogPort {
  final List<ExpLogEntry> exp = [];
  final List<CurrencyLog> currency = [];

  @override
  Future<void> insertExp(ExpLogEntry entry) async => exp.add(entry);

  @override
  Future<void> insertCurrency(CurrencyLog entry) async => currency.add(entry);

  @override
  Future<int> sumExp(String petId) async => exp
      .where((entry) => entry.petId == petId)
      .fold<int>(0, (total, entry) => total + entry.delta);

  @override
  Future<int> sumCurrency() async =>
      currency.fold<int>(0, (total, entry) => total + entry.delta);
}

class _MutableClock implements ClockService {
  DateTime value;

  _MutableClock(this.value);

  @override
  DateTime now() => value;

  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      value.difference(lastOnlineAt);

  @override
  void markHeartbeat() {}
}

class _Harness {
  final AssetContentRepository content;
  final GameSession session;
  final _MutableClock clock;
  final GameServices services;

  const _Harness({
    required this.content,
    required this.session,
    required this.clock,
    required this.services,
  });
}

Future<_Harness> _buildHarness({Pet? current, DateTime? now}) async {
  final content = AssetContentRepository();
  await content.loadAll();
  final session = GameSession(current: current);
  final clock = _MutableClock(now ?? DateTime(2026, 7, 10, 12));
  var id = 0;
  final services = GameServices.wire(
    session: session,
    port: _MemoryPort(),
    content: content,
    clock: clock,
    rng: () => 0.25,
    idGen: () => 'achievement-${id++}',
    ownerName: '小明',
  );
  return _Harness(
    content: content,
    session: session,
    clock: clock,
    services: services,
  );
}

Pet _pet({
  required String id,
  required String speciesId,
  required String name,
  List<String> pastNames = const [],
  String? journeyId,
  DateTime? graduatedAt,
  String? wishId,
  PetState state = PetState.raising,
}) {
  final now = DateTime(2026, 7, 1, 12);
  return Pet(
    id: id,
    speciesId: speciesId,
    variantId: '${speciesId}_v1',
    name: name,
    personality: const ['p_gentle', 'p_curious'],
    bornAt: now,
    lastOnlineAt: now,
    offlineDayKey: '2026-07-01',
    pastNames: pastNames,
    journeyId: journeyId,
    graduatedAt: graduatedAt,
    wishId: wishId,
    state: state,
  );
}

int _progress(GameSession session, String achievementId) =>
    session.achievements[achievementId]?.progress ?? 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('午夜、黎明和雨天照料按自然日去重', () async {
    final harness = await _buildHarness();
    for (var day = 1; day <= 7; day++) {
      final at = DateTime(2026, 7, day, 0, 30);
      harness.services.recordCareAchievementFacts(
        at: at,
        action: 'pat',
        fullCareDay: false,
      );
      harness.services.recordCareAchievementFacts(
        at: at,
        action: 'pat',
        fullCareDay: false,
      );
    }
    expect(harness.session.achievementSignals['custom:night_care'], 7);

    var rainyDays = 0;
    var cursor = DateTime(2026, 1, 1, 12);
    while (rainyDays < 10) {
      final weather = harness.services.weatherAt(cursor);
      if (weather == Weather.rain || weather == Weather.thunder) {
        harness.services.recordCareAchievementFacts(
          at: cursor,
          action: 'feed',
          fullCareDay: false,
        );
        harness.services.recordCareAchievementFacts(
          at: cursor,
          action: 'feed',
          fullCareDay: false,
        );
        rainyDays++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_midnight'), 7);
    expect(_progress(harness.session, 'ach_rain_care_10'), 10);
  });

  test('安静日、唯一名字和满额照料使用真实语义', () async {
    final current = _pet(
      id: 'pet-a',
      speciesId: 'pet_cat',
      name: '阿橘',
      pastNames: const ['橘一'],
    );
    final harness = await _buildHarness(current: current);
    harness.session.roaming.addAll([
      _pet(
        id: 'pet-b',
        speciesId: 'pet_shiba',
        name: '阿橘',
        pastNames: const ['小柴', '柴二'],
        state: PetState.roaming,
      ),
      _pet(
        id: 'pet-c',
        speciesId: 'pet_rabbit',
        name: '雪团',
        state: PetState.roaming,
      ),
    ]);
    harness.session.achievementSignals.addAll({
      'fact:care-day:2026-07-01': 1,
      'fact:care-day:2026-07-02': 1,
      'fact:care-day:2026-07-03': 1,
      'fact:event-day:2026-07-02': 1,
    });
    harness.services.recordCareAchievementFacts(
      at: DateTime(2026, 7, 9, 12),
      action: 'bath',
      fullCareDay: true,
    );

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_quietday'), 3);
    expect(_progress(harness.session, 'ach_h_allnames'), 5);
    expect(_progress(harness.session, 'ach_h_fullcare'), 4);
  });

  test('猫头鹰与星星虫、休憩宠物与白粉蝶均可触发', () async {
    final pet = _pet(id: 'pet-starbug', speciesId: 'pet_starbug', name: '星点');
    final harness = await _buildHarness(current: pet);
    final owlInteraction = harness.content.visitorInteractions.firstWhere(
      (item) =>
          item.visitorId == 'visitor_owl' &&
          item.petSpeciesId == 'pet_starbug' &&
          item.personalityBias == null,
    );
    harness.session.activeVisitor = ActiveVisitor(
      visitorId: 'visitor_owl',
      arrivedAt: harness.clock.now(),
      leavesAt: harness.clock.now().add(const Duration(days: 1)),
      interactionId: owlInteraction.id,
      withPetId: pet.id,
    );
    expect(harness.services.interactActiveVisitor('visitor_owl'), isNotNull);

    pet.speciesId = 'pet_cat';
    pet.variantId = 'pet_cat_v1';
    final butterflyInteraction = harness.content.visitorInteractions.firstWhere(
      (item) =>
          item.visitorId == 'visitor_butterfly' &&
          item.petSpeciesId == 'pet_cat' &&
          item.personalityBias == null,
    );
    harness.session.activeVisitor = ActiveVisitor(
      visitorId: 'visitor_butterfly',
      arrivedAt: harness.clock.now(),
      leavesAt: harness.clock.now().add(const Duration(days: 1)),
      interactionId: butterflyInteraction.id,
      withPetId: pet.id,
    );
    expect(
      harness.services.interactActiveVisitor('visitor_butterfly'),
      isNotNull,
    );

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_owlnight'), 1);
    expect(_progress(harness.session, 'ach_h_butterfly'), 1);
  });

  test('一只宠物收到四十个唯一地点后只记一次完整旅程', () async {
    final harness = await _buildHarness();
    expect(harness.content.locations, hasLength(40));
    final journeyId = 'journey-complete';
    final pet = _pet(
      id: 'pet-roaming',
      speciesId: 'pet_cat',
      name: '阿橘',
      journeyId: journeyId,
      state: PetState.roaming,
    )..nextRevisitAt = DateTime(2030);
    harness.session.roaming.add(pet);
    harness.session.journeys.add(
      Journey(
        id: journeyId,
        petId: pet.id,
        stops: harness.content.locations
            .take(25)
            .map((item) => item.id)
            .toList(),
        wanderStops: harness.content.locations
            .skip(25)
            .map((item) => item.id)
            .toList(),
        currentIdx: 25,
        wanderIdx: 15,
        nextPostcardAt: DateTime(2030),
        state: JourneyState.wandering,
      ),
    );
    for (var index = 0; index < harness.content.locations.length; index++) {
      final location = harness.content.locations[index];
      harness.session.postcards.add(
        Postcard(
          id: 'postcard-$index',
          petId: pet.id,
          journeyId: journeyId,
          locationId: location.id,
          seq: index + 1,
          sentAt: DateTime(2026, 7, 1).add(Duration(days: index)),
          season: location.allowedSeasons.first,
          timeOfDay: location.allowedTimesOfDay.first,
          weather: location.allowedWeather.first,
          bodyText: '旅途来信',
          photoAssetId: location.photoStyle,
          stampId: location.stampId,
        ),
      );
    }

    await harness.services.processRoaming(harness.clock.now());
    await harness.services.processRoaming(harness.clock.now());
    expect(harness.session.achievementSignals['action:journey_complete'], 1);
    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_journey_5'), 1);
  });

  test('参数化收集成就严格按物种、地区、来客、季节和回访事实计算', () async {
    final harness = await _buildHarness();
    harness.session.roaming.addAll([
      _pet(
        id: 'cat-spring',
        speciesId: 'pet_cat',
        name: '春团',
        graduatedAt: DateTime(2026, 3, 12),
        state: PetState.roaming,
      ),
      _pet(
        id: 'cat-summer',
        speciesId: 'pet_cat',
        name: '夏团',
        graduatedAt: DateTime(2026, 6, 12),
        state: PetState.roaming,
      ),
      _pet(
        id: 'cat-autumn',
        speciesId: 'pet_cat',
        name: '秋团',
        graduatedAt: DateTime(2026, 9, 12),
        state: PetState.roaming,
      ),
      _pet(
        id: 'shiba-winter',
        speciesId: 'pet_shiba',
        name: '冬团',
        graduatedAt: DateTime(2026, 12, 12),
        state: PetState.roaming,
      ),
    ]);
    harness.session.yard.gradCount = 4;
    harness.session.ownedSpecies.addAll(['pet_cat', 'pet_shiba']);

    final locationsByCategory = <String, Location>{};
    for (final location in harness.content.locations) {
      locationsByCategory.putIfAbsent(location.category, () => location);
    }
    expect(locationsByCategory, hasLength(8));
    var postcardIndex = 0;
    for (final location in locationsByCategory.values) {
      harness.session.postcards.add(
        Postcard(
          id: 'category-${postcardIndex++}',
          petId: 'cat-spring',
          journeyId: 'category-journey',
          locationId: location.id,
          seq: postcardIndex,
          sentAt: DateTime(2026, 7, postcardIndex),
          season: location.allowedSeasons.first,
          timeOfDay: location.allowedTimesOfDay.first,
          weather: location.allowedWeather.first,
          bodyText: '八方来信',
          photoAssetId: location.photoStyle,
          stampId: location.stampId,
        ),
      );
    }

    final legendary = harness.content.visitors
        .where((visitor) => visitor.rarity == VisitorRarity.legendary)
        .toList();
    expect(legendary, hasLength(4));
    for (var index = 0; index < legendary.length; index++) {
      harness.session.visitorLog.add(
        VisitorLogEntry(
          id: 'legend-$index',
          visitorId: legendary[index].id,
          date: DateTime(2026, 7, index + 1),
        ),
      );
    }
    harness.session.achievementSignals.addAll({
      'count:revisit-pet:cat-spring': 5,
      'fact:revisit-week:2026-07-20:pet:cat-spring': 1,
      'fact:revisit-week:2026-07-20:pet:shiba-winter': 1,
    });

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_species_repeat_3'), 3);
    expect(_progress(harness.session, 'ach_postcard_8cat'), 8);
    expect(_progress(harness.session, 'ach_h_legend_all'), 4);
    expect(_progress(harness.session, 'ach_h_fourfarewell'), 4);
    expect(_progress(harness.session, 'ach_h_reunion'), 5);
    expect(_progress(harness.session, 'ach_h_classmates'), 2);
  });

  test('完美旅程要求四十个地点均在到达当天阅读，愿望回信要求流星事实', () async {
    final harness = await _buildHarness();
    final pet = _pet(
      id: 'wish-pet',
      speciesId: 'pet_cat',
      name: '许愿团',
      journeyId: 'perfect-journey',
      wishId: 'ev_s03',
      state: PetState.roaming,
    );
    harness.session.roaming.add(pet);
    harness.session.journeys.add(
      Journey(
        id: 'perfect-journey',
        petId: pet.id,
        stops: harness.content.locations
            .take(25)
            .map((location) => location.id)
            .toList(),
        wanderStops: harness.content.locations
            .skip(25)
            .map((location) => location.id)
            .toList(),
        currentIdx: 25,
        wanderIdx: 15,
        nextPostcardAt: DateTime(2030),
        state: JourneyState.wandering,
      ),
    );
    for (var index = 0; index < harness.content.locations.length; index++) {
      final location = harness.content.locations[index];
      final sentAt = DateTime(2026, 1, 1).add(Duration(days: index));
      final postcard = Postcard(
        id: 'perfect-$index',
        petId: pet.id,
        journeyId: 'perfect-journey',
        locationId: location.id,
        seq: index + 1,
        sentAt: sentAt,
        season: location.allowedSeasons.first,
        timeOfDay: location.allowedTimesOfDay.first,
        weather: location.allowedWeather.first,
        bodyText: '按时拆开的信',
        photoAssetId: location.photoStyle,
        stampId: location.stampId,
      );
      harness.session.postcards.add(postcard);
      if (index < harness.content.locations.length - 1) {
        harness.services.recordPostcardRead(postcard.id, at: sentAt);
      }
    }

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_perfectjourney'), 0);
    expect(_progress(harness.session, 'ach_h_wish'), 1);

    final finalPostcard = harness.session.postcards.last;
    harness.services.recordPostcardRead(
      finalPostcard.id,
      at: finalPostcard.sentAt,
    );
    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_perfectjourney'), 1);
  });

  test('特殊事件限定和雨雪在线时长使用各自事实，不退化为总数', () async {
    final harness = await _buildHarness();
    DateTime? rainy;
    DateTime? snowy;
    var cursor = DateTime(2026, 1, 1, 10);
    for (var day = 0; day < 730 && (rainy == null || snowy == null); day++) {
      final weather = harness.services.weatherAt(cursor);
      if (rainy == null &&
          (weather == Weather.rain || weather == Weather.thunder)) {
        rainy = cursor;
      }
      if (snowy == null && weather == Weather.snow) snowy = cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
    expect(rainy, isNotNull);
    expect(snowy, isNotNull);
    harness.services.recordActivePresence(
      from: rainy!,
      to: rainy.add(const Duration(hours: 3, minutes: 1)),
    );
    harness.services.recordActivePresence(
      from: snowy!,
      to: snowy.add(const Duration(hours: 2, minutes: 1)),
    );
    harness.session.achievementSignals.addAll({
      'fact:visitor-day:2026-07-23': 1,
      'fact:revisit-day:2026-07-23': 1,
      'fact:special-day:2026-07-23': 1,
      'fact:event:ev_s01:pet:snow-a': 1,
      'fact:event:ev_s01:pet:snow-b': 1,
      'fact:event:ev_s01:pet:snow-c': 1,
      'count:event:ev_s10': 2,
      'custom:thunder_companion': 3,
      'custom:companion_joined': 5,
    });

    harness.services.syncAchievements();
    expect(_progress(harness.session, 'ach_h_rain'), 3);
    expect(_progress(harness.session, 'ach_h_snowhours'), 2);
    expect(_progress(harness.session, 'ach_h_fullhouse'), 1);
    expect(_progress(harness.session, 'ach_h_snowprint'), 3);
    expect(_progress(harness.session, 'ach_h_fullmoon'), 2);
    expect(_progress(harness.session, 'ach_h_thunder'), 3);
    expect(_progress(harness.session, 'ach_h_plusone'), 5);
  });

  test('事件结算写入指定事件、愿望和陪伴分支事实', () async {
    final pet = _pet(id: 'event-pet', speciesId: 'pet_cat', name: '事件团');
    final harness = await _buildHarness(current: pet);
    harness.session.pendingEvents.add(
      PendingGameEvent(
        id: 'meteor-pending',
        eventId: 'ev_s03',
        petId: pet.id,
        title: '流星雨之夜',
        script: '许下一个愿望。',
        type: EventType.special,
        expReward: 8,
        currencyReward: 0,
        createdAt: harness.clock.now(),
      ),
    );
    expect(harness.services.resolveEvent('meteor-pending'), isNotNull);
    expect(pet.wishId, 'ev_s03');
    expect(harness.session.achievementSignals['count:event:ev_s03'], 1);

    harness.session.pendingEvents.add(
      PendingGameEvent(
        id: 'thunder-pending',
        eventId: 'ev_d16',
        petId: pet.id,
        title: '躲雷',
        script: '雷声靠近了。',
        type: EventType.daily,
        expReward: 3,
        currencyReward: 0,
        createdAt: harness.clock.now(),
        choices: [
          PendingEventChoice(
            text: '坐到纸箱旁边陪它',
            resultScript: '一起听雨。',
            expDelta: 0,
          ),
          PendingEventChoice(
            text: '把纸箱盖轻轻掩上一半',
            resultScript: '留下一点安静。',
            expDelta: 0,
          ),
        ],
      ),
    );
    expect(
      harness.services.resolveEvent('thunder-pending', choiceIndex: 0),
      isNotNull,
    );
    expect(harness.session.achievementSignals['custom:thunder_companion'], 1);
    expect(harness.session.achievementSignals['count:event:ev_d16'], 1);
  });

  test('成就内容参数必须落在求值器明确支持的契约内', () async {
    final harness = await _buildHarness();
    const supported = <AchievementCondType, Set<String>>{
      AchievementCondType.gradCount: {'seasons'},
      AchievementCondType.speciesCollected: {
        'regularOnly',
        'fantasyOnly',
        'sameSpecies',
      },
      AchievementCondType.postcardCount: {'categories', 'allReadSameDay'},
      AchievementCondType.visitorDexCount: {'rarity', 'types'},
      AchievementCondType.actionCount: {'action', 'actions', 'dailyMax'},
      AchievementCondType.revisitCount: {
        'samePet',
        'interaction',
        'differentPets',
        'withinWeek',
      },
      AchievementCondType.loginStreak: {},
      AchievementCondType.specialEventCount: {
        'eventType',
        'totalHours',
        'eventTypes',
        'eventId',
        'differentPets',
        'eventIds',
        'branch',
      },
      AchievementCondType.yardStage: {},
      AchievementCondType.themeCount: {},
      AchievementCondType.stampCount: {},
      AchievementCondType.seasonPostcard: {'eventId', 'wishResponse'},
      AchievementCondType.unlockPet: {'regularOnly', 'petId'},
      AchievementCondType.custom: {
        'action',
        'event',
        'timeRange',
        'days',
        'noEvent',
        'loginCount',
        'noDuplicate',
        'date',
        'petState',
        'afterRain',
        'graduatedPet',
        'petPersonality',
        'animation',
      },
    };
    for (final achievement in harness.content.achievements) {
      expect(
        achievement.condition.params.keys.toSet().difference(
          supported[achievement.condition.type]!,
        ),
        isEmpty,
        reason: '${achievement.id} contains an unimplemented condition field',
      );
    }
  });

  test('所有动作与自定义成就都有明确的生产语义', () async {
    final harness = await _buildHarness();
    const actionSignals = {
      'evolve_lv5',
      'reach_lv8',
      'daily_care',
      'journey_complete',
      'pat',
      'feed',
      'bath',
      'play_toy',
    };
    const customSignals = {
      'collect_all_variants',
      'companion_joined',
      'revisit_gift_received',
      'weather_postcard',
      'rainy_day_care',
      'branch_choice',
      'night_care',
      'care_only',
      'name_pet',
      'dawn_care',
      'owl_and_starbug_same_night',
      'graduation',
      'care',
      'wait_rainbow',
      'view_album',
      'read_postcard',
      'pat',
    };

    for (final achievement in harness.content.achievements) {
      final params = achievement.condition.params;
      if (achievement.condition.type == AchievementCondType.actionCount) {
        final action = params['action'] as String?;
        if (action != null) {
          expect(
            actionSignals,
            contains(action),
            reason: '${achievement.id} has no action producer',
          );
        }
      }
      if (achievement.condition.type == AchievementCondType.custom) {
        final action = params['action'] as String?;
        if (action != null) {
          expect(
            customSignals,
            contains(action),
            reason: '${achievement.id} has no custom producer',
          );
        } else {
          expect(
            params['event'],
            'white_butterfly',
            reason: '${achievement.id} has no custom event producer',
          );
        }
      }
    }
  });
}
