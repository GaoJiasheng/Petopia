import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/distribution_environment.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/app/notification_service.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/data/save/session_store.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/log_port.dart';

class _PendingGameController extends GameController {
  final Completer<GameView> ready = Completer<GameView>();

  @override
  Future<GameView> build() => ready.future;
}

class _MemoryPort implements AuditLogPort {
  final List<ExpLogEntry> exp = <ExpLogEntry>[];
  final List<CurrencyLog> currency = <CurrencyLog>[];

  @override
  Future<void> insertCurrency(CurrencyLog entry) async {
    currency.add(entry);
  }

  @override
  Future<void> insertExp(ExpLogEntry entry) async {
    exp.add(entry);
  }

  @override
  Future<int> sumCurrency() async =>
      currency.fold<int>(0, (sum, item) => sum + item.delta);

  @override
  Future<int> sumExp(String petId) async => exp
      .where((item) => item.petId == petId)
      .fold<int>(0, (sum, item) => sum + item.delta);
}

class _MutableClock implements ClockService {
  _MutableClock(this.value);

  DateTime value;
  int heartbeatCount = 0;

  @override
  void markHeartbeat() {
    heartbeatCount++;
  }

  @override
  DateTime now() => value;

  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      value.difference(lastOnlineAt);
}

class _FixedDistributionEnvironment implements DistributionEnvironment {
  _FixedDistributionEnvironment(this.testFlight);

  final bool testFlight;
  int checkCount = 0;

  @override
  Future<bool> isTestFlight() async {
    checkCount++;
    return testFlight;
  }
}

class _RecordingAudio implements AudioService {
  int pauseCount = 0;
  int resumeCount = 0;

  @override
  bool get effectsEnabled => true;

  @override
  bool get musicEnabled => true;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pauseForInterruption() async {
    pauseCount++;
  }

  @override
  Future<void> playBgm(Bgm bgm) async {}

  @override
  Future<void> playYardAmbience(YardAmbience ambience) async {}

  @override
  Future<void> resumeAfterInterruption() async {
    resumeCount++;
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) async {}

  @override
  Future<void> setMusicEnabled(bool enabled) async {}

  @override
  Future<void> sfx(Sfx s) async {}

  @override
  Future<void> sting(Sting s) async {}

  @override
  Future<void> visitorVoice(String visitorId) async {}
}

class _RecordingNotifications extends NotificationService {
  _RecordingNotifications() : super(onOpen: (_) {});

  int syncCount = 0;
  Completer<void>? gate;

  @override
  Future<bool?> sync({
    required List<PetopiaNotificationCandidate> candidates,
    required PetopiaNotificationPreferences preferences,
    bool requestPermission = false,
  }) async {
    syncCount++;
    final currentGate = gate;
    if (currentGate != null) await currentGate.future;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetContentRepository content;

  setUpAll(() async {
    content = AssetContentRepository();
    await content.loadAll();
  });

  test('resume before bootstrap completes is a safe no-op', () async {
    late _PendingGameController controller;
    final container = ProviderContainer(
      overrides: [
        gameControllerProvider.overrideWith(() {
          controller = _PendingGameController();
          return controller;
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(gameControllerProvider).isLoading, isTrue);
    await expectLater(controller.onAppResumed(), completes);
    expect(container.read(gameControllerProvider).isLoading, isTrue);
  });

  test(
    'pause received during bootstrap is applied before startup completes',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'petopia_lifecycle_bootstrap_pause_',
      );
      final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
      final audio = _RecordingAudio();
      final notifications = _RecordingNotifications();
      final services = _services(content: content, saveDir: root, clock: clock);
      final bootstrap = Completer<GameServices>();
      final container = ProviderContainer(
        overrides: <Override>[
          gameBootstrapProvider.overrideWithValue(() => bootstrap.future),
          audioServiceProvider.overrideWithValue(audio),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await root.delete(recursive: true);
      });

      final ready = container.read(gameControllerProvider.future);
      final controller = container.read(gameControllerProvider.notifier);
      await controller.onAppPaused();
      bootstrap.complete(services);
      await ready;

      expect(audio.pauseCount, 1);
      expect(audio.resumeCount, 0);
      expect(File('${root.path}/session.json').existsSync(), isTrue);
      expect(services.session.current?.lastOnlineAt, clock.value);
    },
  );

  test(
    'successful care returns only after its primary save is durable',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'petopia_care_durable_',
      );
      final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
      final services = _services(content: content, saveDir: root, clock: clock);
      final container = _container(
        services: services,
        audio: _RecordingAudio(),
        notifications: _RecordingNotifications(),
      );
      addTearDown(() async {
        container.dispose();
        await root.delete(recursive: true);
      });

      await container.read(gameControllerProvider.future);
      final controller = container.read(gameControllerProvider.notifier);
      expect(await controller.feed(), isTrue);

      final restored = await SessionStore(root).load();
      expect(restored, isNotNull);
      expect(restored!.careActionCount, 1);
      expect(restored.careLedger.counts[CareAction.feed.name], 1);
    },
  );

  test(
    'rapid duplicate lifecycle callbacks are coalesced and serialized',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'petopia_lifecycle_serial_',
      );
      final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
      final audio = _RecordingAudio();
      final notifications = _RecordingNotifications();
      final services = _services(content: content, saveDir: root, clock: clock);
      final container = _container(
        services: services,
        audio: audio,
        notifications: notifications,
      );
      addTearDown(() async {
        container.dispose();
        await root.delete(recursive: true);
      });

      await container.read(gameControllerProvider.future);
      await Future<void>.delayed(Duration.zero);
      final initialNotificationCount = notifications.syncCount;
      final controller = container.read(gameControllerProvider.notifier);

      notifications.gate = Completer<void>();
      final firstPause = controller.onAppPaused();
      final duplicatePause = controller.onAppPaused();
      await _waitUntil(
        () => notifications.syncCount == initialNotificationCount + 1,
      );

      clock.value = DateTime.utc(2026, 7, 26, 12);
      final firstResume = controller.onAppResumed();
      final duplicateResume = controller.onAppResumed();
      await Future<void>.delayed(Duration.zero);
      expect(audio.pauseCount, 1);
      expect(audio.resumeCount, 0);

      notifications.gate!.complete();
      notifications.gate = null;
      await Future.wait<void>([
        firstPause,
        duplicatePause,
        firstResume,
        duplicateResume,
      ]);

      expect(audio.pauseCount, 1);
      expect(audio.resumeCount, 1);
      expect(
        notifications.syncCount,
        initialNotificationCount + 2,
        reason: 'inactive/paused and duplicate resumed callbacks must coalesce',
      );
      expect(clock.heartbeatCount, 2);
      expect(
        File('${root.path}/session.json').existsSync(),
        isTrue,
        reason: 'the serialized pause/resume chain must finish its save',
      );
    },
  );

  test(
    'a lifecycle save failure recovers without breaking later resumes',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'petopia_lifecycle_recovery_',
      );
      final blockedPath = '${root.path}/blocked';
      await File(blockedPath).writeAsString('not a directory');
      final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
      final audio = _RecordingAudio();
      final notifications = _RecordingNotifications();
      final services = _services(
        content: content,
        saveDir: Directory(blockedPath),
        clock: clock,
      );
      final container = _container(
        services: services,
        audio: audio,
        notifications: notifications,
      );
      addTearDown(() async {
        container.dispose();
        await root.delete(recursive: true);
      });

      await container.read(gameControllerProvider.future);
      final controller = container.read(gameControllerProvider.notifier);
      await expectLater(controller.onAppPaused(), completes);
      expect(
        container.read(saveWriteCueProvider)?.status,
        SaveWriteStatus.failed,
      );

      await File(blockedPath).delete();
      clock.value = DateTime.utc(2026, 7, 26, 12);
      await expectLater(controller.onAppResumed(), completes);

      expect(
        container.read(saveWriteCueProvider)?.status,
        SaveWriteStatus.recovered,
      );
      expect(File('$blockedPath/session.json').existsSync(), isTrue);
      expect(audio.pauseCount, 1);
      expect(audio.resumeCount, 1);
    },
  );

  test('production distribution cannot advance the game day', () async {
    final root = await Directory.systemTemp.createTemp(
      'petopia_production_day_guard_',
    );
    final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
    final services = _services(content: content, saveDir: root, clock: clock);
    final environment = _FixedDistributionEnvironment(false);
    final container = _container(
      services: services,
      audio: _RecordingAudio(),
      notifications: _RecordingNotifications(),
      distribution: environment,
    );
    addTearDown(() async {
      container.dispose();
      await root.delete(recursive: true);
    });

    await container.read(gameControllerProvider.future);
    final bornAt = services.session.current!.bornAt;
    final advanced = await container
        .read(gameControllerProvider.notifier)
        .advanceOneDayForTesting();

    expect(advanced, isFalse);
    expect(environment.checkCount, testFlightToolsCompiled ? 1 : 0);
    expect(services.session.current!.bornAt, bornAt);
    expect(services.session.current!.exp, 0);
  });

  test(
    'TestFlight day advance runs a complete persisted daily step',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'petopia_testflight_day_advance_',
      );
      final clock = _MutableClock(DateTime.utc(2026, 7, 26, 10));
      final services = _services(content: content, saveDir: root, clock: clock);
      services.session.careLedger.counts[CareAction.feed.name] = 1;
      final environment = _FixedDistributionEnvironment(true);
      final container = _container(
        services: services,
        audio: _RecordingAudio(),
        notifications: _RecordingNotifications(),
        distribution: environment,
      );
      addTearDown(() async {
        container.dispose();
        await root.delete(recursive: true);
      });

      await container.read(gameControllerProvider.future);
      final bornAt = services.session.current!.bornAt;
      final advanced = await container
          .read(gameControllerProvider.notifier)
          .advanceOneDayForTesting();

      expect(advanced, isTrue);
      expect(environment.checkCount, 1);
      expect(
        services.session.current!.bornAt,
        bornAt.subtract(const Duration(days: 1)),
      );
      expect(services.session.current!.exp, greaterThan(0));
      expect(services.session.careLedger.counts, isEmpty);
      expect(services.session.settings.loginStreakCurrent, 1);

      final restored = await SessionStore(root).load();
      expect(restored, isNotNull);
      expect(restored!.current!.bornAt, services.session.current!.bornAt);
      expect(restored.current!.exp, services.session.current!.exp);
    },
    skip: !testFlightToolsCompiled,
  );
}

GameServices _services({
  required AssetContentRepository content,
  required Directory saveDir,
  required _MutableClock clock,
}) {
  final session = GameSession(
    current: Pet(
      id: 'pet-lifecycle',
      speciesId: 'pet_cat',
      variantId: 'pet_cat_v1',
      name: '橘团',
      personality: const <String>['p_glutton', 'p_curious'],
      bornAt: clock.now(),
      lastOnlineAt: clock.now(),
      offlineDayKey: '2026-07-26',
    ),
  );
  session.settings
    ..onboardingComplete = true
    ..careTutorialStep = 3;
  var nextId = 0;
  return GameServices.wire(
    session: session,
    port: _MemoryPort(),
    content: content,
    clock: clock,
    rng: () => 0.5,
    idGen: () => 'lifecycle-${nextId++}',
    ownerName: '主人',
    store: SessionStore(saveDir),
  );
}

ProviderContainer _container({
  required GameServices services,
  required AudioService audio,
  required NotificationService notifications,
  DistributionEnvironment? distribution,
}) {
  return ProviderContainer(
    overrides: <Override>[
      gameBootstrapProvider.overrideWithValue(() async => services),
      audioServiceProvider.overrideWithValue(audio),
      notificationServiceProvider.overrideWithValue(notifications),
      distributionEnvironmentProvider.overrideWithValue(
        distribution ?? _FixedDistributionEnvironment(false),
      ),
    ],
  );
}

Future<void> _waitUntil(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(predicate(), isTrue);
}
