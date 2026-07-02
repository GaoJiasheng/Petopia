import 'package:isar/isar.dart';

import '../../domain/enums.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/yard.dart';
import '../isar/isar_documents.dart';

class PetopiaRepositories {
  PetopiaRepositories(Isar isar)
    : _isar = isar,
      pets = PetRepository(isar),
      wallet = CurrencyWalletRepository(isar),
      yard = YardStateRepository(isar),
      journeys = JourneyRepository(isar),
      clues = ClueCounterRepository(isar),
      achievements = AchievementProgressRepository(isar),
      visitorLogs = VisitorLogRepository(isar),
      jobs = ScheduledJobRepository(isar),
      settings = SettingsRepository(isar);

  final Isar _isar;
  final PetRepository pets;
  final CurrencyWalletRepository wallet;
  final YardStateRepository yard;
  final JourneyRepository journeys;
  final ClueCounterRepository clues;
  final AchievementProgressRepository achievements;
  final VisitorLogRepository visitorLogs;
  final ScheduledJobRepository jobs;
  final SettingsRepository settings;

  Future<RuntimeRepositorySnapshot> exportSnapshot() async {
    return RuntimeRepositorySnapshot(
      pets: await pets.getAll(),
      wallet: await wallet.get(),
      yard: await yard.get(),
      journeys: await journeys.getAll(),
      clues: await clues.getAll(),
      achievements: await achievements.getAll(),
      visitorLogs: await visitorLogs.getAll(),
      jobs: await jobs.getAll(),
      settings: await settings.get(),
    );
  }

  Future<void> replaceAll(RuntimeRepositorySnapshot snapshot) {
    return _isar.writeTxn(() async {
      await _isar.petDocs.clear();
      await _isar.currencyWalletDocs.clear();
      await _isar.yardStateDocs.clear();
      await _isar.journeyDocs.clear();
      await _isar.clueCounterDocs.clear();
      await _isar.achievementProgressDocs.clear();
      await _isar.visitorLogEntryDocs.clear();
      await _isar.scheduledJobDocs.clear();
      await _isar.settingsDocs.clear();

      await _isar.petDocs.putAll(snapshot.pets.map(PetDoc.fromDomain).toList());
      if (snapshot.wallet != null) {
        await _isar.currencyWalletDocs.put(
          CurrencyWalletDoc.fromDomain(snapshot.wallet!),
        );
      }
      if (snapshot.yard != null) {
        await _isar.yardStateDocs.put(YardStateDoc.fromDomain(snapshot.yard!));
      }
      await _isar.journeyDocs.putAll(
        snapshot.journeys.map(JourneyDoc.fromDomain).toList(),
      );
      await _isar.clueCounterDocs.putAll(
        snapshot.clues.map(ClueCounterDoc.fromDomain).toList(),
      );
      await _isar.achievementProgressDocs.putAll(
        snapshot.achievements.map(AchievementProgressDoc.fromDomain).toList(),
      );
      await _isar.visitorLogEntryDocs.putAll(
        snapshot.visitorLogs.map(VisitorLogEntryDoc.fromDomain).toList(),
      );
      await _isar.scheduledJobDocs.putAll(
        snapshot.jobs.map(ScheduledJobDoc.fromDomain).toList(),
      );
      if (snapshot.settings != null) {
        await _isar.settingsDocs.put(
          SettingsDoc.fromDomain(snapshot.settings!),
        );
      }
    });
  }
}

class RuntimeRepositorySnapshot {
  const RuntimeRepositorySnapshot({
    required this.pets,
    required this.wallet,
    required this.yard,
    required this.journeys,
    required this.clues,
    required this.achievements,
    required this.visitorLogs,
    required this.jobs,
    required this.settings,
  });

  final List<Pet> pets;
  final CurrencyWallet? wallet;
  final YardState? yard;
  final List<Journey> journeys;
  final List<ClueCounter> clues;
  final List<AchievementProgress> achievements;
  final List<VisitorLogEntry> visitorLogs;
  final List<ScheduledJob> jobs;
  final Settings? settings;
}

class PetRepository {
  PetRepository(this._isar);

  final Isar _isar;

  Future<Pet?> get(String id) async {
    final doc = await _isar.petDocs.filter().domainIdEqualTo(id).findFirst();
    return doc?.toDomain();
  }

  Future<List<Pet>> getAll() async {
    final docs = await _isar.petDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<Pet>> byState(PetState state) async {
    final docs = await _isar.petDocs.filter().stateEqualTo(state).findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<Pet?> activeRaising() async {
    final doc = await _isar.petDocs
        .filter()
        .stateEqualTo(PetState.raising)
        .findFirst();
    return doc?.toDomain();
  }

  Future<Pet?> activeRevisiting() async {
    final doc = await _isar.petDocs
        .filter()
        .stateEqualTo(PetState.revisiting)
        .findFirst();
    return doc?.toDomain();
  }

  Future<void> save(Pet pet) => _save(PetDoc.fromDomain(pet));

  Future<void> saveAll(Iterable<Pet> pets) async {
    for (final pet in pets) {
      await save(pet);
    }
  }

  Future<bool> delete(String id) async {
    final doc = await _isar.petDocs.filter().domainIdEqualTo(id).findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(() => _isar.petDocs.delete(doc.isarId));
  }

  Future<void> _save(PetDoc doc) async {
    final existing = await _isar.petDocs
        .filter()
        .domainIdEqualTo(doc.domainId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.petDocs.put(doc);
    });
  }
}

class CurrencyWalletRepository {
  CurrencyWalletRepository(this._isar);

  final Isar _isar;

  Future<CurrencyWallet?> get() async {
    final doc = await _isar.currencyWalletDocs.get(singletonDocId);
    return doc?.toDomain();
  }

  Future<CurrencyWallet> getOrCreate() async {
    final existing = await get();
    if (existing != null) {
      return existing;
    }
    final wallet = CurrencyWallet();
    await save(wallet);
    return wallet;
  }

  Future<void> save(CurrencyWallet wallet) {
    return _isar.writeTxn(() async {
      await _isar.currencyWalletDocs.put(CurrencyWalletDoc.fromDomain(wallet));
    });
  }

  Future<bool> delete() {
    return _isar.writeTxn(
      () => _isar.currencyWalletDocs.delete(singletonDocId),
    );
  }
}

class YardStateRepository {
  YardStateRepository(this._isar);

  final Isar _isar;

  Future<YardState?> get() async {
    final doc = await _isar.yardStateDocs.get(singletonDocId);
    return doc?.toDomain();
  }

  Future<YardState> getOrCreate() async {
    final existing = await get();
    if (existing != null) {
      return existing;
    }
    final yard = YardState();
    await save(yard);
    return yard;
  }

  Future<void> save(YardState yard) {
    return _isar.writeTxn(() async {
      await _isar.yardStateDocs.put(YardStateDoc.fromDomain(yard));
    });
  }

  Future<bool> delete() {
    return _isar.writeTxn(() => _isar.yardStateDocs.delete(singletonDocId));
  }
}

class JourneyRepository {
  JourneyRepository(this._isar);

  final Isar _isar;

  Future<Journey?> get(String id) async {
    final doc = await _isar.journeyDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    return doc?.toDomain();
  }

  Future<List<Journey>> getAll() async {
    final docs = await _isar.journeyDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<Journey>> forPet(String petId) async {
    final docs = await _isar.journeyDocs.filter().petIdEqualTo(petId).findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<Journey?> activeForPet(String petId) async {
    final doc = await _isar.journeyDocs
        .filter()
        .petIdEqualTo(petId)
        .and()
        .stateEqualTo(JourneyState.active)
        .findFirst();
    return doc?.toDomain();
  }

  Future<void> save(Journey journey) => _save(JourneyDoc.fromDomain(journey));

  Future<bool> delete(String id) async {
    final doc = await _isar.journeyDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(() => _isar.journeyDocs.delete(doc.isarId));
  }

  Future<void> _save(JourneyDoc doc) async {
    final existing = await _isar.journeyDocs
        .filter()
        .domainIdEqualTo(doc.domainId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.journeyDocs.put(doc);
    });
  }
}

class ClueCounterRepository {
  ClueCounterRepository(this._isar);

  final Isar _isar;

  Future<ClueCounter?> get(String clueId) async {
    final doc = await _isar.clueCounterDocs
        .filter()
        .clueIdEqualTo(clueId)
        .findFirst();
    return doc?.toDomain();
  }

  Future<List<ClueCounter>> getAll() async {
    final docs = await _isar.clueCounterDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<void> save(ClueCounter counter) {
    return _save(ClueCounterDoc.fromDomain(counter));
  }

  Future<bool> delete(String clueId) async {
    final doc = await _isar.clueCounterDocs
        .filter()
        .clueIdEqualTo(clueId)
        .findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(() => _isar.clueCounterDocs.delete(doc.isarId));
  }

  Future<void> _save(ClueCounterDoc doc) async {
    final existing = await _isar.clueCounterDocs
        .filter()
        .clueIdEqualTo(doc.clueId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.clueCounterDocs.put(doc);
    });
  }
}

class AchievementProgressRepository {
  AchievementProgressRepository(this._isar);

  final Isar _isar;

  Future<AchievementProgress?> get(String achievementId) async {
    final doc = await _isar.achievementProgressDocs
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    return doc?.toDomain();
  }

  Future<List<AchievementProgress>> getAll() async {
    final docs = await _isar.achievementProgressDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<AchievementProgress>> unlockedUnclaimed() async {
    final docs = await _isar.achievementProgressDocs
        .filter()
        .unlockedAtIsNotNull()
        .and()
        .rewardClaimedEqualTo(false)
        .findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<void> save(AchievementProgress progress) {
    return _save(AchievementProgressDoc.fromDomain(progress));
  }

  Future<bool> delete(String achievementId) async {
    final doc = await _isar.achievementProgressDocs
        .filter()
        .achievementIdEqualTo(achievementId)
        .findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(
      () => _isar.achievementProgressDocs.delete(doc.isarId),
    );
  }

  Future<void> _save(AchievementProgressDoc doc) async {
    final existing = await _isar.achievementProgressDocs
        .filter()
        .achievementIdEqualTo(doc.achievementId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.achievementProgressDocs.put(doc);
    });
  }
}

class VisitorLogRepository {
  VisitorLogRepository(this._isar);

  final Isar _isar;

  Future<VisitorLogEntry?> get(String id) async {
    final doc = await _isar.visitorLogEntryDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    return doc?.toDomain();
  }

  Future<List<VisitorLogEntry>> getAll() async {
    final docs = await _isar.visitorLogEntryDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<VisitorLogEntry>> forVisitor(String visitorId) async {
    final docs = await _isar.visitorLogEntryDocs
        .filter()
        .visitorIdEqualTo(visitorId)
        .findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<VisitorLogEntry>> forPet(String petId) async {
    final docs = await _isar.visitorLogEntryDocs
        .filter()
        .withPetIdEqualTo(petId)
        .findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<void> save(VisitorLogEntry entry) {
    return _save(VisitorLogEntryDoc.fromDomain(entry));
  }

  Future<bool> delete(String id) async {
    final doc = await _isar.visitorLogEntryDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(() => _isar.visitorLogEntryDocs.delete(doc.isarId));
  }

  Future<void> _save(VisitorLogEntryDoc doc) async {
    final existing = await _isar.visitorLogEntryDocs
        .filter()
        .domainIdEqualTo(doc.domainId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.visitorLogEntryDocs.put(doc);
    });
  }
}

class ScheduledJobRepository {
  ScheduledJobRepository(this._isar);

  final Isar _isar;

  Future<ScheduledJob?> get(String id) async {
    final doc = await _isar.scheduledJobDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    return doc?.toDomain();
  }

  Future<List<ScheduledJob>> getAll() async {
    final docs = await _isar.scheduledJobDocs.where().findAll();
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<List<ScheduledJob>> dueUnconsumed(DateTime now) async {
    final docs = await _isar.scheduledJobDocs
        .filter()
        .consumedEqualTo(false)
        .and()
        .dueAtLessThan(now.toUtc(), include: true)
        .findAll();
    docs.sort((a, b) {
      final priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.dueAt.compareTo(b.dueAt);
    });
    return docs.map((doc) => doc.toDomain()).toList();
  }

  Future<void> save(ScheduledJob job) {
    return _save(ScheduledJobDoc.fromDomain(job));
  }

  Future<void> markConsumed(String id) async {
    final doc = await _isar.scheduledJobDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    if (doc == null) {
      return;
    }
    doc.consumed = true;
    await _isar.writeTxn(() async {
      await _isar.scheduledJobDocs.put(doc);
    });
  }

  Future<bool> delete(String id) async {
    final doc = await _isar.scheduledJobDocs
        .filter()
        .domainIdEqualTo(id)
        .findFirst();
    if (doc == null) {
      return false;
    }
    return _isar.writeTxn(() => _isar.scheduledJobDocs.delete(doc.isarId));
  }

  Future<void> _save(ScheduledJobDoc doc) async {
    final existing = await _isar.scheduledJobDocs
        .filter()
        .domainIdEqualTo(doc.domainId)
        .findFirst();
    if (existing != null) {
      doc.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.scheduledJobDocs.put(doc);
    });
  }
}

class SettingsRepository {
  SettingsRepository(this._isar);

  final Isar _isar;

  Future<Settings?> get() async {
    final doc = await _isar.settingsDocs.get(singletonDocId);
    return doc?.toDomain();
  }

  Future<Settings> getOrCreate({DateTime? now}) async {
    final existing = await get();
    if (existing != null) {
      return existing;
    }
    final createdAt = (now ?? DateTime.now()).toUtc();
    final settings = Settings(createdAt: createdAt, lastWallClockAt: createdAt);
    await save(settings);
    return settings;
  }

  Future<void> save(Settings settings) {
    return _isar.writeTxn(() async {
      await _isar.settingsDocs.put(SettingsDoc.fromDomain(settings));
    });
  }

  Future<bool> delete() {
    return _isar.writeTxn(() => _isar.settingsDocs.delete(singletonDocId));
  }
}
