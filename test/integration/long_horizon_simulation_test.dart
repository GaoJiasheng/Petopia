import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/config/game_config.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/data/save/session_store.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/local_calendar.dart';
import 'package:petopia/services/log_port.dart';

class _SimulationClock implements ClockService {
  DateTime value;

  _SimulationClock(this.value);

  @override
  DateTime now() => value;

  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      value.difference(lastOnlineAt);

  @override
  void markHeartbeat() {}
}

class _SimulationRng {
  int _state;

  _SimulationRng(this._state);

  double next() {
    _state = (1664525 * _state + 1013904223) & 0x7fffffff;
    return _state / 0x80000000;
  }
}

class _SimulationPort implements AuditLogPort {
  final List<ExpLogEntry> exp = <ExpLogEntry>[];
  final List<CurrencyLog> currency = <CurrencyLog>[];

  @override
  Future<void> insertExp(ExpLogEntry entry) async => exp.add(entry);

  @override
  Future<void> insertCurrency(CurrencyLog entry) async => currency.add(entry);

  @override
  Future<int> sumExp(String petId) async => exp
      .where((entry) => entry.petId == petId)
      .fold<int>(0, (sum, entry) => sum + entry.delta);

  @override
  Future<int> sumCurrency() async =>
      currency.fold<int>(0, (sum, entry) => sum + entry.delta);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '365-day deterministic lifecycle survives daily save reloads without drift',
    () async {
      final content = AssetContentRepository();
      await content.loadAll();
      final root = await Directory.systemTemp.createTemp(
        'petopia-long-horizon-',
      );
      addTearDown(() => root.delete(recursive: true));
      final store = SessionStore(root);
      final port = _SimulationPort();
      final rng = _SimulationRng(0x504554);
      final clock = _SimulationClock(DateTime.utc(2026, 1, 1, 22));
      var id = 0;
      var session = GameSession();

      GameServices wire() => GameServices.wire(
        session: session,
        port: port,
        content: content,
        clock: clock,
        rng: rng.next,
        idGen: () => 'sim-${id++}',
        ownerName: '长期测试',
        postcardTemplates: content.postcardTemplates,
        encounters: content.encounters,
        incidents: content.incidents,
        store: store,
      );

      var services = wire();
      var nextSpecies = 0;
      final checkpoints = <int, Map<String, int>>{};

      for (var day = 0; day < 365; day++) {
        clock.value = DateTime.utc(2026, 1, 1, 22).add(Duration(days: day));
        final dayKey = LocalCalendar.dayKey(clock.value);

        if (session.current == null && nextSpecies < content.species.length) {
          final species = content.species[nextSpecies++];
          services.adopt(
            speciesId: species.id,
            name: '${species.name}$nextSpecies',
          );
        }

        await services.scheduler.onDailyTick(clock.value);
        await services.scheduler.onResume(clock.value);
        await services.processRoaming(clock.value);

        while (session.pendingEvents.isNotEmpty) {
          final pending = session.pendingEvents.first;
          services.resolveEvent(
            pending.id,
            choiceIndex: pending.choices.isEmpty ? null : 0,
          );
        }
        final visitor = session.activeVisitor;
        if (visitor != null && !visitor.interacted) {
          services.interactActiveVisitor(visitor.visitorId);
        }
        final revisitor = session.revisitor;
        if (revisitor != null && !session.revisitorInteracted) {
          services.interactRevisitor(revisitor.id);
        }

        final current = session.current;
        if (current != null) {
          services.exp.addExp(
            pet: current,
            baseDelta: 55,
            source: ExpSource.eventDaily,
            sourceRef: 'sim-care:$dayKey',
            applyPersonalityBonus: false,
          );
          session.careActionCount += 4;
          for (final action in const ['feed', 'pat', 'play_toy', 'bath']) {
            services.bumpAchievementSignal('action:$action');
          }
          services.bumpAchievementSignal('care:days');
          services.recordCareAchievementFacts(
            at: clock.value,
            action: 'bath',
            fullCareDay: true,
          );
          services.economy.earn(
            GameConfig.dailyFirstCareFluff,
            CurrencyReason.dailyFirstCare,
            ref: 'sim-care:$dayKey',
          );
          if (current.exp >= GameConfig.graduationExp) {
            await services.graduateCurrent();
          }
        }

        services.recordActivePresence(
          from: clock.value.subtract(const Duration(hours: 1)),
          to: clock.value,
        );
        final newly = services.syncAchievements();
        for (final achievement in newly) {
          services.unlock.claimReward(achievement.id);
        }

        final audit = await services.audit.verifyOnStartup();
        expect(audit.ok, isTrue, reason: 'audit drift on simulated day $day');
        expect(session.current == null ? 0 : 1, lessThanOrEqualTo(1));
        expect(
          session.pendingEvents.length,
          lessThanOrEqualTo(12),
          reason: 'pending event queue escaped its safety bound',
        );
        expect(
          session.jobs.length,
          lessThanOrEqualTo(640),
          reason: 'scheduler history grows without a retention bound',
        );

        await store.save(session);
        session = (await store.load())!;
        services = wire();
        final restoredAudit = await services.audit.verifyOnStartup();
        expect(
          restoredAudit.ok,
          isTrue,
          reason: 'save reload drift on simulated day $day',
        );

        if (const {29, 179, 364}.contains(day)) {
          checkpoints[day + 1] = <String, int>{
            'graduations': session.yard.gradCount,
            'postcards': session.postcards.length,
            'visitors': session.visitorLog.length,
            'achievements': session.achievements.values
                .where((progress) => progress.unlockedAt != null)
                .length,
          };
        }
      }

      expect(nextSpecies, content.species.length);
      expect(session.yard.gradCount, content.species.length);
      expect(session.roaming, hasLength(content.species.length));
      expect(session.journeys, hasLength(content.species.length));
      expect(session.ownedSpecies, hasLength(content.species.length));
      expect(
        session.journeys.every(
          (journey) =>
              <String>{...journey.stops, ...journey.wanderStops}.length ==
              content.locations.length,
        ),
        isTrue,
      );

      final cardsByJourney = <String, List<Postcard>>{};
      for (final postcard in session.postcards) {
        (cardsByJourney[postcard.journeyId] ??= <Postcard>[]).add(postcard);
      }
      expect(
        cardsByJourney.values.any(
          (cards) =>
              cards.map((card) => card.locationId).toSet().length ==
              content.locations.length,
        ),
        isTrue,
        reason: 'at least one early graduate should complete all 40 locations',
      );
      for (final cards in cardsByJourney.values) {
        final firstForty = cards.take(content.locations.length).toList();
        expect(
          firstForty.map((card) => card.locationId).toSet().length,
          firstForty.length,
          reason: 'a journey repeated a location before exhausting its route',
        );
      }
      expect(session.wallet.balance, await port.sumCurrency());
      expect(session.postcards.length, greaterThan(100));
      expect(session.visitorLog.length, greaterThan(20));
      expect(
        session.achievements.values
            .where((progress) => progress.unlockedAt != null)
            .length,
        greaterThan(20),
      );
      expect(session.jobs.length, lessThanOrEqualTo(640));
      expect(session.generatedDays.length, lessThanOrEqualTo(121));
      expect(checkpoints.keys, unorderedEquals(<int>[30, 180, 365]));
      expect(
        checkpoints[365]!['postcards']!,
        greaterThan(checkpoints[180]!['postcards']!),
      );
      expect(
        checkpoints[365]!['achievements']!,
        greaterThanOrEqualTo(checkpoints[30]!['achievements']!),
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
