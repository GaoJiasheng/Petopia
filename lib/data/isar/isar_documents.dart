import 'package:isar/isar.dart';

import '../../domain/enums.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/yard.dart';

part 'isar_documents.g.dart';

const Id singletonDocId = 1;

DateTime _utc(DateTime value) => value.isUtc ? value : value.toUtc();

@collection
class PetDoc {
  Id isarId = Isar.autoIncrement;

  @Name('id')
  @Index()
  late String domainId;

  late String speciesId;
  late String variantId;
  late String name;
  List<String> personality = <String>[];
  late DateTime bornAt;
  int level = 1;
  int exp = 0;

  @Enumerated(EnumType.name)
  PetStage stage = PetStage.a;

  @Enumerated(EnumType.name)
  @Index()
  PetState state = PetState.raising;

  late DateTime lastOnlineAt;
  int offlineExpGrantedToday = 0;
  late String offlineDayKey;
  String? wishId;
  DateTime? graduatedAt;
  String? journeyId;
  DateTime? nextRevisitAt;
  List<String> pastNames = <String>[];

  Pet toDomain() {
    return Pet(
      id: domainId,
      speciesId: speciesId,
      variantId: variantId,
      name: name,
      personality: List<String>.of(personality),
      bornAt: _utc(bornAt),
      lastOnlineAt: _utc(lastOnlineAt),
      offlineDayKey: offlineDayKey,
      level: level,
      exp: exp,
      stage: stage,
      state: state,
      offlineExpGrantedToday: offlineExpGrantedToday,
      wishId: wishId,
      graduatedAt: graduatedAt == null ? null : _utc(graduatedAt!),
      journeyId: journeyId,
      nextRevisitAt: nextRevisitAt == null ? null : _utc(nextRevisitAt!),
      pastNames: List<String>.of(pastNames),
    );
  }

  static PetDoc fromDomain(Pet pet) {
    return PetDoc()
      ..domainId = pet.id
      ..speciesId = pet.speciesId
      ..variantId = pet.variantId
      ..name = pet.name
      ..personality = List<String>.of(pet.personality)
      ..bornAt = _utc(pet.bornAt)
      ..level = pet.level
      ..exp = pet.exp
      ..stage = pet.stage
      ..state = pet.state
      ..lastOnlineAt = _utc(pet.lastOnlineAt)
      ..offlineExpGrantedToday = pet.offlineExpGrantedToday
      ..offlineDayKey = pet.offlineDayKey
      ..wishId = pet.wishId
      ..graduatedAt = pet.graduatedAt == null ? null : _utc(pet.graduatedAt!)
      ..journeyId = pet.journeyId
      ..nextRevisitAt = pet.nextRevisitAt == null
          ? null
          : _utc(pet.nextRevisitAt!)
      ..pastNames = List<String>.of(pet.pastNames);
  }
}

@collection
class CurrencyWalletDoc {
  Id isarId = singletonDocId;

  int balance = 0;

  CurrencyWallet toDomain() => CurrencyWallet(balance: balance);

  static CurrencyWalletDoc fromDomain(CurrencyWallet wallet) {
    return CurrencyWalletDoc()
      ..isarId = singletonDocId
      ..balance = wallet.balance;
  }
}

@embedded
class YardSlotDoc {
  int pos = 0;
  String? itemId;

  YardSlot toDomain() => YardSlot(pos: pos, itemId: itemId);

  static YardSlotDoc fromDomain(YardSlot slot) {
    return YardSlotDoc()
      ..pos = slot.pos
      ..itemId = slot.itemId;
  }
}

@embedded
class FoodTrayDoc {
  String? foodType;
  DateTime? placedAt;

  FoodTray toDomain() {
    return FoodTray(
      foodType: foodType,
      placedAt: placedAt == null ? null : _utc(placedAt!),
    );
  }

  static FoodTrayDoc fromDomain(FoodTray tray) {
    return FoodTrayDoc()
      ..foodType = tray.foodType
      ..placedAt = tray.placedAt == null ? null : _utc(tray.placedAt!);
  }
}

@collection
class YardStateDoc {
  Id isarId = singletonDocId;

  int luxuryStage = 1;
  int gradCount = 0;
  String activeThemeId = 'theme_default';
  List<String> ownedThemeIds = <String>['theme_default'];
  List<YardSlotDoc> slots = <YardSlotDoc>[];
  FoodTrayDoc? foodTray;
  List<String> ownedPerks = <String>[];
  List<String> ownedDecorIds = <String>[];

  YardState toDomain() {
    return YardState(
      luxuryStage: luxuryStage,
      gradCount: gradCount,
      activeThemeId: activeThemeId,
      ownedThemeIds: List<String>.of(ownedThemeIds),
      slots: slots.map((slot) => slot.toDomain()).toList(),
      foodTray: foodTray?.toDomain() ?? FoodTray(),
      ownedPerks: List<String>.of(ownedPerks),
      ownedDecorIds: List<String>.of(ownedDecorIds),
    );
  }

  static YardStateDoc fromDomain(YardState yard) {
    return YardStateDoc()
      ..isarId = singletonDocId
      ..luxuryStage = yard.luxuryStage
      ..gradCount = yard.gradCount
      ..activeThemeId = yard.activeThemeId
      ..ownedThemeIds = List<String>.of(yard.ownedThemeIds)
      ..slots = yard.slots.map(YardSlotDoc.fromDomain).toList()
      ..foodTray = FoodTrayDoc.fromDomain(yard.foodTray)
      ..ownedPerks = List<String>.of(yard.ownedPerks)
      ..ownedDecorIds = List<String>.of(yard.ownedDecorIds);
  }
}

@collection
class JourneyDoc {
  Id isarId = Isar.autoIncrement;

  @Name('id')
  @Index()
  late String domainId;

  @Index()
  late String petId;

  List<String> stops = <String>[];
  List<String> wanderStops = <String>[];
  int currentIdx = 0;
  int wanderIdx = 0;
  int longTermSeq = 0;
  late DateTime nextPostcardAt;

  @Enumerated(EnumType.name)
  @Index()
  JourneyState state = JourneyState.active;

  Journey toDomain() {
    return Journey(
      id: domainId,
      petId: petId,
      stops: List<String>.of(stops),
      wanderStops: List<String>.of(wanderStops),
      nextPostcardAt: _utc(nextPostcardAt),
      currentIdx: currentIdx,
      wanderIdx: wanderIdx,
      longTermSeq: longTermSeq,
      state: state,
    );
  }

  static JourneyDoc fromDomain(Journey journey) {
    return JourneyDoc()
      ..domainId = journey.id
      ..petId = journey.petId
      ..stops = List<String>.of(journey.stops)
      ..wanderStops = List<String>.of(journey.wanderStops)
      ..currentIdx = journey.currentIdx
      ..wanderIdx = journey.wanderIdx
      ..longTermSeq = journey.longTermSeq
      ..nextPostcardAt = _utc(journey.nextPostcardAt)
      ..state = journey.state;
  }
}

@collection
class ClueCounterDoc {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String clueId;

  int count = 0;
  int threshold = 0;
  bool visitorSeen = false;

  ClueCounter toDomain() {
    return ClueCounter(
      clueId: clueId,
      threshold: threshold,
      count: count,
      visitorSeen: visitorSeen,
    );
  }

  static ClueCounterDoc fromDomain(ClueCounter counter) {
    return ClueCounterDoc()
      ..clueId = counter.clueId
      ..count = counter.count
      ..threshold = counter.threshold
      ..visitorSeen = counter.visitorSeen;
  }
}

@collection
class AchievementProgressDoc {
  Id isarId = Isar.autoIncrement;

  @Index()
  late String achievementId;

  int progress = 0;
  DateTime? unlockedAt;
  bool rewardClaimed = false;

  AchievementProgress toDomain() {
    return AchievementProgress(
      achievementId: achievementId,
      progress: progress,
      unlockedAt: unlockedAt == null ? null : _utc(unlockedAt!),
      rewardClaimed: rewardClaimed,
    );
  }

  static AchievementProgressDoc fromDomain(AchievementProgress progress) {
    return AchievementProgressDoc()
      ..achievementId = progress.achievementId
      ..progress = progress.progress
      ..unlockedAt = progress.unlockedAt == null
          ? null
          : _utc(progress.unlockedAt!)
      ..rewardClaimed = progress.rewardClaimed;
  }
}

@collection
class VisitorLogEntryDoc {
  Id isarId = Isar.autoIncrement;

  @Name('id')
  @Index()
  late String domainId;

  @Index()
  late String visitorId;

  @Index()
  late DateTime date;

  String? interactionId;

  @Index()
  String? withPetId;

  VisitorLogEntry toDomain() {
    return VisitorLogEntry(
      id: domainId,
      visitorId: visitorId,
      date: _utc(date),
      interactionId: interactionId,
      withPetId: withPetId,
    );
  }

  static VisitorLogEntryDoc fromDomain(VisitorLogEntry entry) {
    return VisitorLogEntryDoc()
      ..domainId = entry.id
      ..visitorId = entry.visitorId
      ..date = _utc(entry.date)
      ..interactionId = entry.interactionId
      ..withPetId = entry.withPetId;
  }
}

@collection
class ScheduledJobDoc {
  Id isarId = Isar.autoIncrement;

  @Name('id')
  @Index()
  late String domainId;

  @Enumerated(EnumType.name)
  @Index()
  JobType type = JobType.dailyEventGen;

  @Index()
  late DateTime dueAt;

  int priority = 0;
  String? payloadRef;

  @Index()
  bool consumed = false;

  ScheduledJob toDomain() {
    return ScheduledJob(
      id: domainId,
      type: type,
      dueAt: _utc(dueAt),
      priority: priority,
      payloadRef: payloadRef,
      consumed: consumed,
    );
  }

  static ScheduledJobDoc fromDomain(ScheduledJob job) {
    return ScheduledJobDoc()
      ..domainId = job.id
      ..type = job.type
      ..dueAt = _utc(job.dueAt)
      ..priority = job.priority
      ..payloadRef = job.payloadRef
      ..consumed = job.consumed;
  }
}

@collection
class SettingsDoc {
  Id isarId = singletonDocId;

  bool notifications = true;
  bool sound = true;
  int schemaVersion = 1;
  late DateTime createdAt;
  int lastMonotonicRef = 0;
  late DateTime lastWallClockAt;
  int loginStreakCurrent = 0;
  int loginStreakMax = 0;
  String lastLoginDay = '';

  Settings toDomain() {
    return Settings(
      createdAt: _utc(createdAt),
      lastWallClockAt: _utc(lastWallClockAt),
      notifications: notifications,
      sound: sound,
      schemaVersion: schemaVersion,
      lastMonotonicRef: lastMonotonicRef,
      loginStreakCurrent: loginStreakCurrent,
      loginStreakMax: loginStreakMax,
      lastLoginDay: lastLoginDay,
    );
  }

  static SettingsDoc fromDomain(Settings settings) {
    return SettingsDoc()
      ..isarId = singletonDocId
      ..notifications = settings.notifications
      ..sound = settings.sound
      ..schemaVersion = settings.schemaVersion
      ..createdAt = _utc(settings.createdAt)
      ..lastMonotonicRef = settings.lastMonotonicRef
      ..lastWallClockAt = _utc(settings.lastWallClockAt)
      ..loginStreakCurrent = settings.loginStreakCurrent
      ..loginStreakMax = settings.loginStreakMax
      ..lastLoginDay = settings.lastLoginDay;
  }
}
