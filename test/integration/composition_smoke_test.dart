import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/log_port.dart';

class MemPort implements AuditLogPort {
  final List<ExpLogEntry> exp = [];
  final List<CurrencyLog> cur = [];
  @override
  Future<void> insertExp(ExpLogEntry e) async => exp.add(e);
  @override
  Future<void> insertCurrency(CurrencyLog e) async => cur.add(e);
  @override
  Future<int> sumExp(String petId) async =>
      exp.where((e) => e.petId == petId).fold<int>(0, (a, e) => a + e.delta);
  @override
  Future<int> sumCurrency() async => cur.fold<int>(0, (a, e) => a + e.delta);
}

class FixedClock implements ClockService {
  final DateTime t;
  FixedClock(this.t);
  @override
  DateTime now() => t;
  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      Duration.zero;
  @override
  void markHeartbeat() {}
}

class MutableClock implements ClockService {
  DateTime t;
  MutableClock(this.t);

  @override
  DateTime now() => t;

  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      t.difference(lastOnlineAt);

  @override
  void markHeartbeat() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('组合根装配 + 一日 tick 跑通，INV-1 恒成立', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    expect(content.species.length, 12); // 内容加载 sanity
    expect(content.visitorInteractions.isNotEmpty, true); // 访客互动已入库

    final session = GameSession();
    session.current = Pet(
      id: 'pet1',
      speciesId: 'pet_cat',
      variantId: 'pet_cat_v1',
      name: '阿橘',
      personality: const ['p_glutton', 'p_curious'],
      bornAt: DateTime.utc(2026, 7, 3),
      lastOnlineAt: DateTime.utc(2026, 7, 3),
      offlineDayKey: '2026-07-03',
    );

    final port = MemPort();
    final t0 = DateTime.utc(2026, 7, 3, 8);
    var i = 0;
    final svc = GameServices.wire(
      session: session,
      port: port,
      content: content,
      clock: FixedClock(t0),
      rng: () => 0.3,
      idGen: () => 'id${i++}',
      ownerName: '小明',
    );

    await svc.scheduler.onDailyTick(t0);
    expect(session.jobs.isNotEmpty, true); // 有 job 被补种
    await svc.scheduler.onResume(t0);
    expect(
      session.jobs.where((j) => !j.dueAt.isAfter(t0)).every((j) => j.consumed),
      true,
    );
    expect(
      session.jobs.where((j) => j.dueAt.isAfter(t0)).every((j) => !j.consumed),
      true,
    );

    // 至此可能通过日常事件/访客给了经验；INV-1 必须恒成立
    expect(session.current!.exp, await port.sumExp('pet1'), reason: 'INV-1');
  });

  test('事件、来客、回访都只在主动确认后结算一次', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    final now = DateTime.utc(2026, 7, 3, 20);
    final session = GameSession(
      current: Pet(
        id: 'pet-current',
        speciesId: 'pet_cat',
        variantId: 'pet_cat_v1',
        name: '阿橘',
        personality: const ['p_glutton', 'p_curious'],
        bornAt: now,
        lastOnlineAt: now,
        offlineDayKey: '2026-07-03',
      ),
    );
    final port = MemPort();
    var id = 0;
    final svc = GameServices.wire(
      session: session,
      port: port,
      content: content,
      clock: FixedClock(now),
      rng: () => 0.3,
      idGen: () => 'id${id++}',
      ownerName: '小明',
    );

    session.pendingEvents.add(
      PendingGameEvent(
        id: 'pending-event',
        eventId: 'ev_test',
        petId: 'pet-current',
        title: '树下的选择',
        script: '要走哪一边？',
        type: EventType.daily,
        expReward: 5,
        currencyReward: 7,
        createdAt: now,
        choices: [
          PendingEventChoice(text: '花径', resultScript: '闻到了花香。', expDelta: 1),
        ],
      ),
    );
    expect(session.current!.exp, 0);
    expect(session.wallet.balance, 0);

    final event = svc.resolveEvent('pending-event', choiceIndex: 0);
    expect(event?.expApplied, 6);
    expect(session.current!.exp, 6);
    expect(session.wallet.balance, 7);
    expect(session.eventCounts['pet-current'], 1);
    expect(session.achievementSignals['custom:branch_choice'], 1);
    expect(svc.resolveEvent('pending-event', choiceIndex: 0), isNull);
    expect(session.current!.exp, 6);

    final interaction = content.visitorInteractions.firstWhere(
      (item) =>
          item.visitorId == 'visitor_sparrow' &&
          item.petSpeciesId == 'pet_cat' &&
          item.personalityBias == null,
    );
    session.activeVisitor = ActiveVisitor(
      visitorId: 'visitor_sparrow',
      arrivedAt: now,
      leavesAt: now.add(const Duration(days: 1)),
      interactionId: interaction.id,
      withPetId: 'pet-current',
    );
    final beforeVisitor = session.current!.exp;
    final visitor = svc.interactActiveVisitor('visitor_sparrow');
    expect(visitor?.expApplied, interaction.expReward);
    expect(session.current!.exp, beforeVisitor + interaction.expReward);
    expect(session.visitorLog, hasLength(1));
    expect(svc.interactActiveVisitor('visitor_sparrow'), isNull);
    expect(session.visitorLog, hasLength(1));

    final revisitor = Pet(
      id: 'pet-away',
      speciesId: 'pet_shiba',
      variantId: 'pet_shiba_v1',
      name: '柴犬',
      personality: const ['p_gentle', 'p_lazy'],
      bornAt: now.subtract(const Duration(days: 20)),
      lastOnlineAt: now,
      offlineDayKey: '2026-07-03',
      state: PetState.roaming,
    );
    session
      ..revisitor = revisitor
      ..revisitorArrivedAt = now
      ..revisitorLeavesAt = now.add(const Duration(days: 1));
    final beforeRevisit = session.current!.exp;
    final revisit = svc.interactRevisitor('pet-away');
    expect(revisit, isNotNull);
    expect(session.current!.exp, beforeRevisit + revisit!.currentPetExp);
    expect(session.revisitCount, 1);
    expect(svc.interactRevisitor('pet-away'), isNull);
    expect(session.revisitCount, 1);
    expect(
      session.current!.exp,
      await port.sumExp('pet-current'),
      reason: 'INV-1',
    );
  });

  test('同物种变体先完成一整轮去重，再允许重复', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    final session = GameSession();
    var id = 0;
    final svc = GameServices.wire(
      session: session,
      port: MemPort(),
      content: content,
      clock: FixedClock(DateTime.utc(2026, 7, 3)),
      rng: () => 0,
      idGen: () => 'id${id++}',
      ownerName: '小明',
    );

    final firstRound = <String>[];
    for (var i = 0; i < 5; i++) {
      firstRound.add(svc.adopt(speciesId: 'pet_cat', name: '阿橘').variantId);
      session.current = null;
    }
    expect(firstRound.toSet(), hasLength(5));
    final repeated = svc.adopt(speciesId: 'pet_cat', name: '阿橘').variantId;
    expect(firstRound, contains(repeated));
  });

  test('特殊事件硬条件阻止初雪在夏天触发', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    final summer = DateTime.utc(2026, 7, 3, 20, 45);
    final clock = MutableClock(summer);
    final pet = Pet(
      id: 'weather-pet',
      speciesId: 'pet_cat',
      variantId: 'pet_cat_v1',
      name: '阿橘',
      personality: const ['p_gentle', 'p_curious'],
      bornAt: DateTime.utc(2026, 1, 1),
      lastOnlineAt: summer,
      offlineDayKey: '2026-07-03',
    );
    final session = GameSession(current: pet);
    var id = 0;
    final svc = GameServices.wire(
      session: session,
      port: MemPort(),
      content: content,
      clock: clock,
      rng: () => 0.1,
      idGen: () => 'weather-${id++}',
      ownerName: '小明',
    );

    void blockOtherSpecials(DateTime at) {
      for (final event in content.events.where(
        (event) => event.type == EventType.special && event.id != 'ev_s01',
      )) {
        session.eventLastFiredAt['${pet.id}:${event.id}'] = at;
      }
    }

    blockOtherSpecials(summer);
    session.jobs.add(
      ScheduledJob(
        id: 'summer-special',
        type: JobType.specialEventEval,
        dueAt: summer,
        priority: 2,
      ),
    );
    await svc.scheduler.onResume(summer);
    expect(session.pendingEvents, isEmpty);

    final snowyWinter = DateTime.utc(2026, 1, 1, 20, 45);
    clock.t = snowyWinter;
    blockOtherSpecials(snowyWinter);
    session.jobs.add(
      ScheduledJob(
        id: 'winter-special',
        type: JobType.specialEventEval,
        dueAt: snowyWinter,
        priority: 2,
      ),
    );
    await svc.scheduler.onResume(snowyWinter);
    expect(session.pendingEvents.single.eventId, 'ev_s01');
  });

  test('完整生命周期：领养、成长、毕业、40站去重、长期回信与回访', () async {
    final content = AssetContentRepository();
    await content.loadAll();
    expect(content.locations, hasLength(40));

    final start = DateTime.utc(2026, 7, 3, 9);
    final clock = MutableClock(start);
    final session = GameSession();
    final port = MemPort();
    var id = 0;
    final svc = GameServices.wire(
      session: session,
      port: port,
      content: content,
      clock: clock,
      rng: () => 0.31,
      idGen: () => 'life-${id++}',
      ownerName: '小明',
      postcardTemplates: content.postcardTemplates,
      encounters: content.encounters,
      incidents: content.incidents,
    );

    final first = svc.adopt(speciesId: 'pet_cat', name: '阿橘');
    final firstVariant = first.variantId;
    final growth = svc.exp.addExp(
      pet: first,
      baseDelta: 800,
      source: ExpSource.eventDaily,
      sourceRef: 'lifecycle-growth',
      applyPersonalityBonus: false,
    );
    expect(growth.graduated, isTrue);
    expect(first.stage, PetStage.d);
    expect(first.exp, await port.sumExp(first.id));

    final mainStops = await svc.graduateCurrent();
    expect(mainStops, 25);
    expect(session.current, isNull);
    expect(session.roaming.single.variantId, firstVariant);
    expect(session.yard.gradCount, 1);
    expect(session.yard.luxuryStage, 2);

    final journey = session.journeys.single;
    expect(journey.stops, hasLength(25));
    expect(journey.wanderStops, hasLength(15));
    expect({...journey.stops, ...journey.wanderStops}, hasLength(40));

    for (var index = 0; index < 40; index++) {
      clock.t = journey.nextPostcardAt;
      await svc.processRoaming(clock.t);
    }
    expect(session.postcards, hasLength(40));
    expect(
      session.postcards.map((card) => card.locationId).toSet(),
      hasLength(40),
    );
    expect(journey.currentIdx, 25);
    expect(journey.wanderIdx, 15);
    expect(journey.state, JourneyState.wandering);

    clock.t = journey.nextPostcardAt;
    await svc.processRoaming(clock.t);
    expect(session.postcards, hasLength(41));
    expect(journey.longTermSeq, 1);
    expect(
      journey.nextPostcardAt.difference(clock.t).inDays,
      inInclusiveRange(18, 22),
    );

    final second = svc.adopt(speciesId: 'pet_shiba', name: '柴犬');
    expect(session.current, same(second));
    final away = session.roaming.single;
    clock.t = away.nextRevisitAt!;
    await svc.processRoaming(clock.t);
    expect(session.revisitor?.id, away.id);
    final revisit = svc.interactRevisitor(away.id);
    expect(revisit, isNotNull);
    expect(session.revisitCount, 1);
    expect(svc.interactRevisitor(away.id), isNull);
    expect(second.exp, await port.sumExp(second.id));
  });
}
