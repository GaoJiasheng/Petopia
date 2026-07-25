// 私有构造用私有字段，无法用 this._x 初始化形参，故豁免该 lint。
// ignore_for_file: prefer_initializing_formals
import 'dart:io';

import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/postcard_content.dart';
import '../data/content/content_repository.dart';
import '../data/save/session_store.dart';
import '../services/audit_service.dart';
import '../services/audit_service_impl.dart';
import '../services/clock_service.dart';
import '../services/economy_service.dart';
import '../services/economy_service_impl.dart';
import '../services/event_scheduler.dart';
import '../services/event_scheduler_impl.dart';
import '../services/exp_engine.dart';
import '../services/exp_engine_impl.dart';
import '../services/graduation_service.dart';
import '../services/graduation_service_impl.dart';
import '../services/log_port.dart';
import '../services/local_calendar.dart';
import '../services/postcard_generator.dart';
import '../services/postcard_generator_impl.dart';
import '../services/pending_event_policy.dart';
import '../services/revisit_service.dart';
import '../services/revisit_service_impl.dart';
import '../services/save_service.dart';
import '../services/unlock_service.dart';
import '../services/unlock_service_impl.dart';
import '../services/visitor_service.dart';
import '../services/visitor_service_impl.dart';
import 'game_state.dart';

class EventResolution {
  final int expApplied;
  final int currencyApplied;
  final String? resultScript;

  const EventResolution({
    required this.expApplied,
    required this.currencyApplied,
    this.resultScript,
  });
}

class VisitorInteractionOutcome {
  final String message;
  final int expApplied;
  final String animRef;

  const VisitorInteractionOutcome({
    required this.message,
    required this.expApplied,
    required this.animRef,
  });
}

class RevisitInteractionOutcome {
  final int gift;
  final bool broughtCompanion;
  final int currentPetExp;

  const RevisitInteractionOutcome({
    required this.gift,
    required this.broughtCompanion,
    required this.currentPetExp,
  });
}

/// 组合根：按依赖顺序装配全部 Service，并把 EventScheduler.dispatch 路由到各服务。
/// 通过注入 [AuditLogPort]（运行期=DAO适配器，单测=内存）与 [ContentRepository] 解耦。
class GameServices {
  final ClockService clock;
  final AuditService audit;
  final ExpEngine exp;
  final EconomyService economy;
  final UnlockService unlock;
  final VisitorService visitor;
  final GraduationService graduation;
  final RevisitService revisit;
  final PostcardGenerator postcard;
  final EventScheduler scheduler;

  final GameSession _session;
  final SessionStore _store;
  final ContentRepository _content;
  final double Function() _rng;
  final String Function() _idGen;
  final Future<List<ExpLogEntry>> Function(String petId)? _expLogReader;
  final SaveService? _portableSave;
  final Future<void> Function()? _dispose;

  /// One-shot startup context consumed by the presentation layer. These stay
  /// out of the save file because the underlying EXP grant is already audited.
  Duration startupOfflineElapsed = Duration.zero;
  int startupOfflineExp = 0;
  String? startupRecoveryReason;

  /// 当前游戏状态（UI 读取）。
  GameSession get session => _session;
  SessionStore get store => _store;
  ContentRepository get content => _content;
  SaveService? get portableSave => _portableSave;

  /// 读某只宠物的经验流水（成长手账）；未接持久化时返回空。
  Future<List<ExpLogEntry>> readExpLog(String petId) async =>
      (await _expLogReader?.call(petId)) ?? const [];

  GameServices._({
    required this.clock,
    required this.audit,
    required this.exp,
    required this.economy,
    required this.unlock,
    required this.visitor,
    required this.graduation,
    required this.revisit,
    required this.postcard,
    required this.scheduler,
    required GameSession session,
    required SessionStore store,
    required ContentRepository content,
    required double Function() rng,
    required String Function() idGen,
    Future<List<ExpLogEntry>> Function(String petId)? expLogReader,
    SaveService? portableSave,
    Future<void> Function()? dispose,
  }) : _session = session,
       _store = store,
       _content = content,
       _rng = rng,
       _idGen = idGen,
       _expLogReader = expLogReader,
       _portableSave = portableSave,
       _dispose = dispose;

  Future<void> dispose() async => _dispose?.call();

  factory GameServices.wire({
    required GameSession session,
    required AuditLogPort port,
    required ContentRepository content,
    required ClockService clock,
    required double Function() rng,
    required String Function() idGen,
    required String ownerName,
    List<PostcardTemplate> postcardTemplates = const [],
    List<Encounter> encounters = const [],
    List<Incident> incidents = const [],
    Future<List<ExpLogEntry>> Function(String petId)? expLogReader,
    SessionStore? store,
    SaveService? portableSave,
    Future<void> Function()? dispose,
  }) {
    final audit = AuditServiceImpl(
      port,
      () => session.allPets,
      () => session.wallet,
    );

    final exp = ExpEngineImpl(
      audit,
      clock,
      (tag, src) => content.personalityById(tag)?.actionExpBonus[src] ?? 0.0,
      idGen,
    );

    final economy = EconomyServiceImpl(
      port,
      session.wallet,
      session.yard,
      clock,
      idGen,
      (petId) => session.eventCounts[petId] ?? 0,
      (petId) => session.visitorCounts[petId] ?? 0,
      (sp) => content.speciesById(sp)?.category == PetCategory.fantasy,
      session.shopInventory,
    );

    final unlock = UnlockServiceImpl(
      content.achievements,
      session.yard,
      session.clues,
      session.achievements,
      session.ownedSpecies.contains,
      economy,
      () => clock.now(),
      session.shopInventory,
    );

    final visitor = VisitorServiceImpl(
      content.visitors,
      content.visitorInteractions,
      rng,
      idGen,
      () => clock.now(),
      (log) {
        session.visitorLog.add(log);
        final id = log.withPetId;
        if (id != null) {
          session.visitorCounts[id] = (session.visitorCounts[id] ?? 0) + 1;
        }
      },
      (clueId) => unlock.bumpClue(clueId),
      history: () => session.visitorLog,
      themeBonus: (yard, candidate, season, window, weather) {
        for (final item in content.shopItems) {
          if (item.effect.type != EffectType.themeSkin ||
              item.effect.params['themeId'] != yard.activeThemeId) {
            continue;
          }
          final raw = item.effect.params['visitorProbBonus'];
          if (raw is! Map) return 0;
          final scope = raw['scope'] as String?;
          final delta = (raw['delta'] as num?)?.toDouble() ?? 0;
          final matches = switch (scope) {
            'night' || 'nocturnal' => window == TimeWindow.night,
            'morning' => window == TimeWindow.day,
            'autumn' => season == Season.autumn,
            'rainy' => weather == Weather.rain,
            'snow_rabbit' => candidate.id == 'visitor_snowhare',
            'bird' => _isBirdVisitor(candidate.id),
            'seasonal' => true,
            _ => false,
          };
          return matches ? delta : 0;
        }
        return 0;
      },
    );

    final graduation = GraduationServiceImpl(
      economy,
      content.locations,
      session.yard,
      idGen,
      () => clock.now(),
      rng,
      (j) => session.journeys.add(j),
    );

    final revisit = RevisitServiceImpl(exp, rng, () => clock.now());

    final postcard = PostcardGeneratorImpl(
      locations: {for (final l in content.locations) l.id: l},
      templates: postcardTemplates,
      encounters: encounters,
      incidents: incidents,
      rng: rng,
      now: () => clock.now(),
      idGen: idGen,
      ownerName: ownerName,
      onPostcard: (pc) => session.postcards.add(pc), // 旅行相册数据源；DAO 持久化 [待细化]
    );

    late GameServices svc;
    final scheduler = EventSchedulerImpl(
      session.jobs,
      session.generatedDays,
      idGen,
      rng,
      (job) => svc._dispatch(job),
    );

    svc = GameServices._(
      clock: clock,
      audit: audit,
      exp: exp,
      economy: economy,
      unlock: unlock,
      visitor: visitor,
      graduation: graduation,
      revisit: revisit,
      postcard: postcard,
      scheduler: scheduler,
      session: session,
      content: content,
      rng: rng,
      idGen: idGen,
      expLogReader: expLogReader,
      store: store ?? _NoopSessionStore.instance,
      portableSave: portableSave,
      dispose: dispose,
    );
    return svc;
  }

  // ── 领养 / 毕业编排（UI 动作入口）─────────────────────

  /// 可领养物种：图鉴已解锁（当前可得 / 曾拥有）的真实或彩蛋宠。
  List<PetSpecies> adoptableSpecies() => _content.species.where((sp) {
    final st = unlock.dexStateOf(sp);
    return st == DexState.available || st == DexState.ownedBefore;
  }).toList();

  /// 领养一只新宠为当前在养宠（INV-2：调用前需确保无在养宠）。
  /// 随机 2 个不重复性格；变体优先从该物种未拥有集合中抽取。
  Pet adopt({required String speciesId, required String name}) {
    final sp = _content.speciesById(speciesId);
    final now = clock.now();
    final variants = sp?.variantIds ?? const <String>[];
    final unseenVariants = variants
        .where((variant) => !_session.ownedVariants.contains(variant))
        .toList(growable: false);
    final variantPool = unseenVariants.isNotEmpty ? unseenVariants : variants;
    final variantId = variantPool.isEmpty
        ? '${speciesId}_v1'
        : variantPool[(_rng() * variantPool.length).floor().clamp(
            0,
            variantPool.length - 1,
          )];
    final trimmed = name.trim();
    final pet = Pet(
      id: _idGen(),
      speciesId: speciesId,
      variantId: variantId,
      name: trimmed.isEmpty ? (sp?.name ?? '宝贝') : trimmed,
      personality: _pickTwoPersonalities(),
      bornAt: now,
      lastOnlineAt: now,
      offlineDayKey: LocalCalendar.dayKey(now),
    );
    _session.current = pet;
    _session.ownedSpecies.add(speciesId);
    _session.ownedVariants.add(variantId);
    _bumpSignal('custom:name_pet');
    final collectedVariants = variants
        .where(_session.ownedVariants.contains)
        .length;
    _setSignalMax('custom:collect_all_variants', collectedVariants);
    return pet;
  }

  /// 毕业当前在养宠：暖绒结算 + 生成旅程 → 转漫游、清空在养位。
  /// 返回旅程站点数（供典礼展示）；无在养宠或经验未达标返回 null。
  Future<int?> graduateCurrent() async {
    final pet = _session.current;
    if (pet == null || pet.exp < GameConfig.graduationExp) return null;
    final journeyId = await graduation.graduate(pet);
    _session.roaming.add(pet);
    _session.current = null;
    revisit.scheduleNextRevisit(pet); // 漫游开始即排下次回访
    final match = _session.journeys.where((e) => e.id == journeyId);
    return match.isEmpty ? null : match.first.stops.length;
  }

  /// 成就同步：从 session 现状重算所有可派生的累计计数，逐类型推进成就。
  /// 幂等（UnlockService 只取更大值），每次游戏动作后调用。返回本次新解锁的成就。
  List<Achievement> syncAchievements() {
    final newly = <Achievement>[];
    for (final achievement in _content.achievements) {
      final value = _achievementValue(achievement);
      newly.addAll(
        unlock.checkAchievements(
          GameSignal(
            achievement.condition.type.name,
            params: {'progress': value, 'achievementId': achievement.id},
          ),
        ),
      );
    }
    return newly;
  }

  int _achievementValue(Achievement achievement) {
    final s = _session;
    final params = achievement.condition.params;
    return switch (achievement.condition.type) {
      AchievementCondType.gradCount => _graduationAchievementValue(params),
      AchievementCondType.speciesCollected => _speciesAchievementValue(params),
      AchievementCondType.postcardCount => _postcardAchievementValue(params),
      AchievementCondType.visitorDexCount => _visitorAchievementValue(params),
      AchievementCondType.actionCount => _actionAchievementValue(params),
      AchievementCondType.revisitCount => _revisitAchievementValue(params),
      AchievementCondType.loginStreak => s.settings.loginStreakCurrent,
      AchievementCondType.specialEventCount => _specialEventAchievementValue(
        params,
      ),
      AchievementCondType.yardStage => s.yard.luxuryStage,
      AchievementCondType.themeCount => s.yard.ownedThemeIds.length,
      AchievementCondType.stampCount =>
        s.postcards.map((postcard) => postcard.stampId).toSet().length,
      AchievementCondType.seasonPostcard => _seasonPostcardAchievementValue(
        params,
      ),
      AchievementCondType.unlockPet => _unlockPetAchievementValue(params),
      AchievementCondType.custom => _customAchievementValue(params),
    };
  }

  int _graduationAchievementValue(Map<String, dynamic> params) {
    if (params['seasons'] is List) {
      final required = (params['seasons'] as List).whereType<String>().toSet();
      return _session.roaming
          .map((pet) => pet.graduatedAt)
          .whereType<DateTime>()
          .map((at) => LocalCalendar.season(at).name)
          .where(required.contains)
          .toSet()
          .length;
    }
    return _session.yard.gradCount;
  }

  int _speciesAchievementValue(Map<String, dynamic> params) {
    if (params['sameSpecies'] == true) {
      final counts = <String, int>{};
      for (final pet in _session.allPets) {
        counts[pet.speciesId] = (counts[pet.speciesId] ?? 0) + 1;
      }
      return counts.values.fold<int>(
        0,
        (largest, count) => count > largest ? count : largest,
      );
    }
    final species = _session.ownedSpecies
        .map(_content.speciesById)
        .whereType<PetSpecies>();
    if (params['regularOnly'] == true) {
      return species.where((item) => item.category == PetCategory.real).length;
    }
    if (params['fantasyOnly'] == true) {
      return species
          .where((item) => item.category == PetCategory.fantasy)
          .length;
    }
    return species.length;
  }

  int _postcardAchievementValue(Map<String, dynamic> params) {
    if (params['categories'] is int) {
      return _session.postcards
          .map((postcard) => _content.locationById(postcard.locationId))
          .whereType<Location>()
          .map((location) => location.category)
          .toSet()
          .length;
    }
    if (params['allReadSameDay'] == true) {
      for (final journey in _session.journeys) {
        final firstByLocation = <String, Postcard>{};
        for (final postcard in _session.postcards.where(
          (item) => item.journeyId == journey.id,
        )) {
          firstByLocation.putIfAbsent(postcard.locationId, () => postcard);
        }
        if (firstByLocation.length < _content.locations.length) continue;
        if (firstByLocation.values.every(
          (postcard) =>
              (_session
                      .achievementSignals['fact:postcard-read-on-arrival:${postcard.id}'] ??
                  0) >
              0,
        )) {
          return 1;
        }
      }
      return 0;
    }
    return _session.postcards.length;
  }

  int _visitorAchievementValue(Map<String, dynamic> params) {
    final seen = _session.visitorLog.map((entry) => entry.visitorId).toSet();
    final typeNames = (params['types'] as List?)?.whereType<String>().toSet();
    if (typeNames != null && typeNames.isNotEmpty) {
      return _content.visitors.where((visitor) {
        if (!seen.contains(visitor.id)) return false;
        return typeNames.any((name) => visitor.name.contains(name));
      }).length;
    }
    final rarityName = params['rarity'] as String?;
    if (rarityName != null) {
      return _content.visitors
          .where(
            (visitor) =>
                seen.contains(visitor.id) && visitor.rarity.name == rarityName,
          )
          .length;
    }
    return seen.length;
  }

  int _revisitAchievementValue(Map<String, dynamic> params) {
    if (params['samePet'] == true) {
      return _session.achievementSignals.entries
          .where((entry) => entry.key.startsWith('count:revisit-pet:'))
          .map((entry) => entry.value)
          .fold<int>(0, (largest, count) => count > largest ? count : largest);
    }
    if (params['differentPets'] == true && params['withinWeek'] == true) {
      final petsByWeek = <String, Set<String>>{};
      const prefix = 'fact:revisit-week:';
      for (final key in _session.achievementSignals.keys.where(
        (key) => key.startsWith(prefix),
      )) {
        final suffix = key.substring(prefix.length);
        final petMarker = suffix.indexOf(':pet:');
        if (petMarker <= 0) continue;
        final week = suffix.substring(0, petMarker);
        final petId = suffix.substring(petMarker + 5);
        if (petId.isEmpty) continue;
        (petsByWeek[week] ??= <String>{}).add(petId);
      }
      return petsByWeek.values.fold<int>(
        0,
        (largest, pets) => pets.length > largest ? pets.length : largest,
      );
    }
    return _session.revisitCount;
  }

  int _specialEventAchievementValue(Map<String, dynamic> params) {
    final eventType = params['eventType'] as String?;
    if (eventType == 'rainy' || eventType == 'snowy') {
      final weather = eventType == 'rainy' ? 'rain' : 'snow';
      return (_session.achievementSignals['seconds:weather:$weather'] ?? 0) ~/
          Duration.secondsPerHour;
    }
    if (eventType == 'companion_visit') {
      return _session.achievementSignals['custom:companion_joined'] ?? 0;
    }
    if (params['eventTypes'] is List) {
      final visitorDays = _factScopes('fact:visitor-day:');
      final revisitDays = _factScopes('fact:revisit-day:');
      final specialDays = _factScopes('fact:special-day:');
      return visitorDays
          .where(revisitDays.contains)
          .where(specialDays.contains)
          .length;
    }
    final eventId = params['eventId'] as String?;
    if (eventId != null && params.containsKey('differentPets')) {
      return _factScopes('fact:event:$eventId:pet:').length;
    }
    if (eventId != null) {
      return _session.achievementSignals['count:event:$eventId'] ?? 0;
    }
    final eventIds = (params['eventIds'] as List?)?.whereType<String>().toSet();
    if (eventIds != null &&
        eventIds.isNotEmpty &&
        params['branch'] == 'companion') {
      return _session.achievementSignals['custom:thunder_companion'] ?? 0;
    }
    return _session.specialEventCount;
  }

  int _seasonPostcardAchievementValue(Map<String, dynamic> params) {
    if (params['eventId'] == 'ev_s03' && params['wishResponse'] == true) {
      final pets = <String, Pet>{
        for (final pet in _session.allPets) pet.id: pet,
      };
      return _session.postcards.any((postcard) {
            final pet = pets[postcard.petId];
            return postcard.locationId == 'loc_star_repair' &&
                pet?.wishId == 'ev_s03';
          })
          ? 1
          : 0;
    }
    return _session.postcards.map((postcard) => postcard.season).toSet().length;
  }

  int _actionAchievementValue(Map<String, dynamic> params) {
    final actions = params['actions'];
    if (actions is List) {
      if (params['dailyMax'] == true) {
        return _session.achievementSignals['custom:daily_fullcare'] ?? 0;
      }
      return actions.whereType<String>().where((action) {
        final key = action == 'play' ? 'play_toy' : action;
        return (_session.achievementSignals['action:$key'] ?? 0) > 0;
      }).length;
    }
    final action = params['action'] as String?;
    if (action == null) return _session.careActionCount;
    if (action == 'daily_care') {
      return _session.achievementSignals['care:days'] ?? 0;
    }
    return _session.achievementSignals['action:$action'] ?? 0;
  }

  int _customAchievementValue(Map<String, dynamic> params) {
    final action = params['action'] as String?;
    if (action == 'weather_postcard') {
      return _session.postcards
          .map((postcard) => postcard.weather)
          .toSet()
          .length;
    }
    if (action == 'name_pet' && params['noDuplicate'] == true) {
      return _session.allPets
          .expand((pet) => <String>[pet.name, ...pet.pastNames])
          .map((name) => name.trim().toLowerCase())
          .where((name) => name.isNotEmpty)
          .toSet()
          .length;
    }
    if (action == 'care_only' && params['noEvent'] == true) {
      final today = LocalCalendar.dayKey(clock.now());
      final careDays = _factScopes('fact:care-day:');
      final eventDays = _factScopes('fact:event-day:');
      return careDays
          .where((day) => day.compareTo(today) < 0)
          .where((day) => !eventDays.contains(day))
          .length;
    }
    if (action == null && params['event'] == 'white_butterfly') {
      return _session.achievementSignals['custom:white_butterfly'] ?? 0;
    }
    return _session.achievementSignals['custom:$action'] ?? 0;
  }

  int _unlockPetAchievementValue(Map<String, dynamic> params) {
    if (params['regularOnly'] == true) {
      return _content.species
          .where((species) => species.category == PetCategory.real)
          .where(
            (species) => unlock.dexStateOf(species) != DexState.lockedKnown,
          )
          .length;
    }
    final name = params['petId'] as String?;
    if (name == null) return _session.ownedSpecies.length;
    final matches = _content.species.where((species) => species.name == name);
    return matches.any((species) => _session.ownedSpecies.contains(species.id))
        ? 1
        : 0;
  }

  void bumpAchievementSignal(String key, {int by = 1}) =>
      _bumpSignal(key, by: by);

  /// Records care-related facts with natural-day deduplication.
  ///
  /// This keeps achievements stable when a player repeats an action many times
  /// in one session and makes the persisted signal map backward compatible.
  void recordCareAchievementFacts({
    required DateTime at,
    required String action,
    required bool fullCareDay,
  }) {
    final local = LocalCalendar.local(at);
    final day = LocalCalendar.dayKey(at);
    _session.achievementSignals['fact:care-day:$day'] = 1;
    if (local.hour < 2) {
      _recordUniqueSignal('custom:night_care', day);
    }
    if (local.hour == 5 || (local.hour == 6 && local.minute <= 30)) {
      _recordUniqueSignal('custom:dawn_care', day);
    }
    if (action == 'feed') {
      final weather = weatherAt(at);
      if (weather == Weather.rain || weather == Weather.thunder) {
        _recordUniqueSignal('custom:rainy_day_care', day);
      }
    }
    if (fullCareDay) {
      _setSignalMax('custom:daily_fullcare', 4);
    }
    recordDailyWorldFacts(at);
  }

  /// Persists the minimum daily world context needed by cross-day
  /// achievements. A rainbow only counts when the player was present during
  /// the immediately preceding rainy day.
  void recordDailyWorldFacts(DateTime at) {
    final day = LocalCalendar.dayKey(at);
    final weather = weatherAt(at);
    if (weather == Weather.rain || weather == Weather.thunder) {
      _session.achievementSignals['fact:weather-rain:$day'] = 1;
    }
    if (weather == Weather.rainbow) {
      final previousDay = LocalCalendar.previousDayKey(at);
      if ((_session.achievementSignals['fact:weather-rain:$previousDay'] ?? 0) >
          0) {
        _recordUniqueSignal('custom:wait_rainbow', day);
      }
    }
  }

  /// Records foreground time against the actual daily weather. The interval is
  /// split at local midnight so a long session cannot attribute time to the
  /// wrong day. Callers flush this periodically and again before suspension.
  void recordActivePresence({required DateTime from, required DateTime to}) {
    if (!to.isAfter(from)) return;
    var cursor = from;
    final hardEnd = to.difference(from) > const Duration(hours: 6)
        ? from.add(const Duration(hours: 6))
        : to;
    while (cursor.isBefore(hardEnd)) {
      final local = LocalCalendar.local(cursor);
      final nextMidnight = DateTime(
        local.year,
        local.month,
        local.day + 1,
      ).toUtc();
      final segmentEnd = nextMidnight.isBefore(hardEnd)
          ? nextMidnight
          : hardEnd;
      final seconds = segmentEnd.difference(cursor).inSeconds;
      if (seconds <= 0) break;
      final weather = weatherAt(cursor);
      if (weather == Weather.rain || weather == Weather.thunder) {
        _bumpSignal('seconds:weather:rain', by: seconds);
      } else if (weather == Weather.snow) {
        _bumpSignal('seconds:weather:snow', by: seconds);
      }
      cursor = segmentEnd;
    }
  }

  /// Marks a postcard as opened on its arrival day. Reopening is idempotent,
  /// and late reads intentionally do not qualify for the perfect-journey rule.
  void recordPostcardRead(String postcardId, {DateTime? at}) {
    Postcard? postcard;
    for (final candidate in _session.postcards) {
      if (candidate.id == postcardId) {
        postcard = candidate;
        break;
      }
    }
    if (postcard == null) return;
    final readAt = at ?? clock.now();
    if (LocalCalendar.dayKey(readAt) != LocalCalendar.dayKey(postcard.sentAt)) {
      return;
    }
    _session.achievementSignals['fact:postcard-read-on-arrival:$postcardId'] =
        1;
  }

  void _bumpSignal(String key, {int by = 1}) {
    _session.achievementSignals[key] =
        (_session.achievementSignals[key] ?? 0) + by;
  }

  void _setSignalMax(String key, int value) {
    final current = _session.achievementSignals[key] ?? 0;
    if (value > current) _session.achievementSignals[key] = value;
  }

  bool _recordUniqueSignal(String key, String scope) {
    final marker = 'unique:$key:$scope';
    if ((_session.achievementSignals[marker] ?? 0) > 0) return false;
    _session.achievementSignals[marker] = 1;
    _bumpSignal(key);
    return true;
  }

  Set<String> _factScopes(String prefix) => _session.achievementSignals.keys
      .where((key) => key.startsWith(prefix))
      .map((key) => key.substring(prefix.length))
      .toSet();

  void _recordVisitorArrival(DateTime at) {
    _session.achievementSignals['fact:visitor-day:${LocalCalendar.dayKey(at)}'] =
        1;
  }

  void _recordRevisitArrival(Pet pet, DateTime at) {
    final day = LocalCalendar.dayKey(at);
    final week = LocalCalendar.weekKey(at);
    _session.achievementSignals['fact:revisit-day:$day'] = 1;
    _session.achievementSignals['fact:revisit-week:$week:pet:${pet.id}'] = 1;
  }

  void _recordSpecialEventOccurrence(DateTime at) {
    _session.achievementSignals['fact:special-day:${LocalCalendar.dayKey(at)}'] =
        1;
  }

  void _recordResolvedEventFacts(
    PendingGameEvent pending,
    Pet? pet, {
    required int? choiceIndex,
    required PendingEventChoice? choice,
  }) {
    _bumpSignal('count:event:${pending.eventId}');
    if (pet != null) {
      _session.achievementSignals['fact:event:${pending.eventId}:pet:${pet.id}'] =
          1;
      if (pending.eventId == 'ev_s03') pet.wishId = 'ev_s03';
    }
    final companionBranch =
        pending.eventId == 'ev_s05' ||
        (pending.eventId == 'ev_d16' &&
            (choiceIndex == 0 || (choice?.text.contains('陪') ?? false)));
    if (companionBranch) _bumpSignal('custom:thunder_companion');
  }

  /// 处理漫游宠（每次日切/恢复调用）：按期寄明信片 + 到点回访串门。
  /// 明信片/回访不走 scheduler job（那是院子在养宠的事），按 roaming 逐只驱动。
  Future<void> processRoaming(DateTime now) async {
    recordDailyWorldFacts(now);
    // 明信片：每只漫游宠的活跃旅程按 nextPostcardAt 寄片（内部判定到点）。
    for (final pet in _session.roaming) {
      final jid = pet.journeyId;
      if (jid == null) continue;
      final matches = _session.journeys.where((j) => j.id == jid);
      if (matches.isEmpty) continue;
      final journey = matches.first;
      await postcard.dailyTick(pet: pet, journey: journey);
      final visitedLocations = _session.postcards
          .where((item) => item.journeyId == journey.id)
          .map((item) => item.locationId)
          .toSet();
      final completeLocationCount = _content.locations.length.clamp(0, 40);
      if (completeLocationCount > 0 &&
          visitedLocations.length >= completeLocationCount) {
        _recordUniqueSignal('action:journey_complete', journey.id);
      }
    }
    // 回访：在院子驻留 1–2 天；到期后再安排下一次。
    final prev = _session.revisitor;
    final leavesAt = _session.revisitorLeavesAt;
    if (prev != null && leavesAt != null && !leavesAt.isAfter(now)) {
      revisit.onRevisitEnd(prev);
      _session.revisitor = null;
      _session.revisitorArrivedAt = null;
      _session.revisitorLeavesAt = null;
      _session.revisitorArrivalSeen = false;
      _session.revisitorInteracted = false;
    }
    if (_session.revisitor != null) return;
    final next = revisit.pickRevisitor(
      _session.roaming,
      now,
      hasCurrentRevisitor: _session.revisitor != null,
    );
    if (next != null) {
      _session.revisitor = next;
      _session.revisitorArrivedAt = now;
      _recordRevisitArrival(next, now);
      final span =
          GameConfig.revisitStayMaxDays - GameConfig.revisitStayMinDays + 1;
      final stayDays = GameConfig.revisitStayMinDays + (_rng() * span).floor();
      _session.revisitorLeavesAt = now.add(Duration(days: stayDays));
      _session.revisitorArrivalSeen = false;
      _session.revisitorInteracted = false;
    }
  }

  RevisitInteractionOutcome? interactRevisitor(String petId) {
    final pet = _session.revisitor;
    if (pet == null || pet.id != petId || _session.revisitorInteracted) {
      return null;
    }
    final broughtCompanion = revisit.onRevisitInteract(pet, _session.current);
    if (broughtCompanion) _bumpSignal('custom:companion_joined');
    _bumpSignal('count:revisit-pet:${pet.id}');
    final giftSpan = GameConfig.revisitGiftMax - GameConfig.revisitGiftMin + 1;
    final gift = GameConfig.revisitGiftMin + (_rng() * giftSpan).floor();
    economy.earn(
      gift,
      CurrencyReason.revisitGift,
      ref: 'revisit:${pet.id}:${LocalCalendar.dayKey(clock.now())}',
    );
    _bumpSignal('custom:revisit_gift_received');
    _session.revisitCount++;
    _session.revisitorInteracted = true;
    return RevisitInteractionOutcome(
      gift: gift,
      broughtCompanion: broughtCompanion,
      currentPetExp: _session.current == null ? 0 : GameConfig.revisitPetExp,
    );
  }

  List<String> _pickTwoPersonalities() {
    final ids = _content.personalities.map((p) => p.id).toList();
    if (ids.length < 2) return ids;
    final i = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    var j = (_rng() * ids.length).floor().clamp(0, ids.length - 1);
    if (j == i) j = (i + 1) % ids.length;
    return [ids[i], ids[j]];
  }

  /// EventScheduler 单个 job 的执行路由（§3.4）。
  Future<void> _dispatch(ScheduledJob job) async {
    final pet = _session.current;
    final now = clock.now();
    _clearExpiredActiveVisitor(now);
    switch (job.type) {
      case JobType.visitorCheck:
        if (_session.activeVisitor != null) break;
        final window = job.payloadRef == 'night'
            ? TimeWindow.night
            : TimeWindow.day;
        final weather = weatherAt(job.dueAt);
        final season = LocalCalendar.season(job.dueAt);
        var v = visitor.rollWindow(
          window: window,
          yard: _session.yard,
          weather: weather,
          season: season,
          now: now,
        );
        v ??= (window == TimeWindow.night)
            ? visitor.rollLegendary(
                yard: _session.yard,
                weather: weather,
                season: season,
                now: now,
              )
            : null;
        if (v != null) {
          final it = visitor.pickInteraction(v, pet);
          _session.activeVisitor = ActiveVisitor(
            visitorId: v.id,
            arrivedAt: now,
            leavesAt: now.add(const Duration(hours: 24)),
            interactionId: it.id,
            withPetId: pet?.id,
          );
          _recordVisitorArrival(now);
        }
      case JobType.dailyEventGen:
        if (pet == null) break;
        final dailies = _eligibleEvents(EventType.daily, pet, job.dueAt);
        if (dailies.isNotEmpty) {
          final ev = _pickWeightedEvent(dailies, pet, job.dueAt);
          _session.eventLastFiredAt['${pet.id}:${ev.id}'] = now;
          _queueEvent(ev, pet, now);
        }
      case JobType.specialEventEval:
        if (pet == null) break;
        // 眷顾资格的彩蛋事件：满足等级/豪华度门槛，oncePerPet 未触发过。
        final eligible = _eligibleEvents(EventType.special, pet, job.dueAt)
            .where((e) {
              if (e.oncePerPet &&
                  _session.firedSpecials.contains('${pet.id}:${e.id}')) {
                return false;
              }
              return true;
            })
            .toList();
        if (eligible.isEmpty) break;
        if (_rng() >= _specialEventChance) break; // 低频彩蛋（日 cap=1）
        final ev = _pickWeightedEvent(eligible, pet, job.dueAt);
        if (ev.oncePerPet) _session.firedSpecials.add('${pet.id}:${ev.id}');
        _session.eventLastFiredAt['${pet.id}:${ev.id}'] = now;
        _queueEvent(ev, pet, now);
      case JobType.revisitDue:
      case JobType.postcardDue:
        break; // 漫游宠的明信片/回访不走 scheduler，由 processRoaming 驱动
    }
  }

  /// 彩蛋事件单次评估触发概率（日 cap=1，见 GameConfig.specialEventDailyCap）。
  static const double _specialEventChance = 0.25;

  List<Event> _eligibleEvents(EventType type, Pet pet, DateTime now) {
    final weather = weatherAt(now);
    final timeOfDay = LocalCalendar.timeOfDay(now);
    final season = LocalCalendar.season(now);
    final ageDays = now.difference(pet.bornAt).inDays;
    return _content.events.where((event) {
      if (event.type != type) return false;
      final weights = event.weights;
      if (weights.minLevel != null && pet.level < weights.minLevel!) {
        return false;
      }
      if (weights.minLuxuryStage != null &&
          _session.yard.luxuryStage < weights.minLuxuryStage!) {
        return false;
      }
      if (weights.minAgeDays != null && ageDays < weights.minAgeDays!) {
        return false;
      }
      if (weights.requiredWeather.isNotEmpty &&
          !weights.requiredWeather.contains(weather)) {
        return false;
      }
      if (weights.requiredTimeOfDay.isNotEmpty &&
          !weights.requiredTimeOfDay.contains(timeOfDay)) {
        return false;
      }
      if (weights.requiredSeason.isNotEmpty &&
          !weights.requiredSeason.contains(season)) {
        return false;
      }
      if (weights.requiresVisitor != null &&
          _session.activeVisitor?.visitorId != weights.requiresVisitor) {
        return false;
      }
      if (weights.requiresDecor != null &&
          !_session.yard.activeDecorIds.contains(weights.requiresDecor)) {
        return false;
      }
      final last = _session.eventLastFiredAt['${pet.id}:${event.id}'];
      if (last != null) {
        final today = LocalCalendar.date(now);
        final lastDay = LocalCalendar.date(last);
        if (today.difference(lastDay).inDays <= event.cooldownDays) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Event _pickWeightedEvent(List<Event> events, Pet pet, DateTime now) {
    final season = LocalCalendar.season(now);
    final time = LocalCalendar.timeOfDay(now);
    final weather = weatherAt(now);
    final weighted = <MapEntry<Event, double>>[];
    var total = 0.0;
    for (final event in events) {
      var weight = 1.0;
      for (final personality in pet.personality) {
        weight *= event.weights.personality[personality] ?? 1.0;
      }
      weight *= event.weights.weather[weather] ?? 1.0;
      weight *= event.weights.timeOfDay[time] ?? 1.0;
      weight *= event.weights.season[season] ?? 1.0;
      if (weight <= 0) continue;
      total += weight;
      weighted.add(MapEntry(event, weight));
    }
    if (weighted.isEmpty || total <= 0) return events.first;
    final roll = _rng() * total;
    var cursor = 0.0;
    for (final entry in weighted) {
      cursor += entry.value;
      if (roll < cursor) return entry.key;
    }
    return weighted.last.key;
  }

  void _queueEvent(Event event, Pet pet, DateTime now) {
    _session.achievementSignals['fact:event-day:${LocalCalendar.dayKey(now)}'] =
        1;
    if (event.type == EventType.special) {
      _recordSpecialEventOccurrence(now);
    }
    _session.pendingEvents.add(
      PendingGameEvent(
        id: _idGen(),
        eventId: event.id,
        petId: pet.id,
        title: event.title,
        script: event.script,
        type: event.type,
        expReward: event.expReward,
        currencyReward: event.currencyReward ?? 0,
        animRef: event.animRef,
        illustrationRef: event.illustrationRef,
        choices: event.choices
            ?.map(
              (choice) => PendingEventChoice(
                text: choice.text,
                resultScript: choice.resultScript,
                expDelta: choice.expDelta,
              ),
            )
            .toList(growable: false),
        createdAt: now,
      ),
    );
    trimPendingEventQueue(_session.pendingEvents);
  }

  EventResolution? resolveEvent(String pendingId, {int? choiceIndex}) {
    final matches = _session.pendingEvents.where(
      (item) => item.id == pendingId,
    );
    if (matches.isEmpty) return null;
    final pending = matches.first;
    PendingEventChoice? choice;
    if (choiceIndex != null &&
        choiceIndex >= 0 &&
        choiceIndex < pending.choices.length) {
      choice = pending.choices[choiceIndex];
    }
    var expApplied = 0;
    if (!pending.rewardSettled) {
      Pet? pet;
      for (final candidate in _session.allPets) {
        if (candidate.id == pending.petId) {
          pet = candidate;
          break;
        }
      }
      pet ??= _session.current;
      if (pet != null) {
        final amount = pending.expReward + (choice?.expDelta ?? 0);
        final result = exp.addExp(
          pet: pet,
          baseDelta: amount,
          source: pending.type == EventType.special
              ? ExpSource.eventSpecial
              : ExpSource.eventDaily,
          sourceRef: pending.eventId,
          note: choice?.resultScript ?? pending.script,
          applyPersonalityBonus: false,
        );
        expApplied = result.deltaApplied;
        _session.eventCounts[pet.id] = (_session.eventCounts[pet.id] ?? 0) + 1;
      }
      if (pending.currencyReward > 0) {
        economy.earn(
          pending.currencyReward,
          CurrencyReason.eventReward,
          ref: 'evt:${pending.petId}:${pending.eventId}',
        );
      }
      if (pending.type == EventType.special) _session.specialEventCount++;
      if (choice != null) _bumpSignal('custom:branch_choice');
      _recordResolvedEventFacts(
        pending,
        pet,
        choiceIndex: choiceIndex,
        choice: choice,
      );
      pending.rewardSettled = true;
    }
    _session.pendingEvents.remove(pending);
    return EventResolution(
      expApplied: expApplied,
      currencyApplied: pending.currencyReward,
      resultScript: choice?.resultScript,
    );
  }

  VisitorInteractionOutcome? interactActiveVisitor(String visitorId) {
    final active = _session.activeVisitor;
    if (active == null || active.visitorId != visitorId || active.interacted) {
      return null;
    }
    final candidate = _content.visitorById(visitorId);
    if (candidate == null) return null;
    final pet = _session.current;
    final interaction =
        _interactionById(active.interactionId) ??
        visitor.pickInteraction(candidate, pet);
    var expApplied = 0;
    if (pet != null) {
      expApplied = exp
          .addExp(
            pet: pet,
            baseDelta: interaction.expReward,
            source: ExpSource.visitor,
            sourceRef: candidate.id,
            note: interaction.script,
            applyPersonalityBonus: false,
          )
          .deltaApplied;
    }
    visitor.recordVisit(candidate, pet, interaction);
    if (candidate.id == 'visitor_owl' && pet?.speciesId == 'pet_starbug') {
      _recordUniqueSignal(
        'custom:owl_and_starbug_same_night',
        LocalCalendar.dayKey(clock.now()),
      );
    }
    if (candidate.id == 'visitor_butterfly' &&
        pet != null &&
        _petWasResting(clock.now())) {
      _recordUniqueSignal('custom:white_butterfly', pet.id);
    }
    active
      ..interactionId = interaction.id
      ..withPetId = pet?.id
      ..interacted = true;
    _consumeVisitorFood();
    return VisitorInteractionOutcome(
      message: interaction.script,
      expApplied: expApplied,
      animRef: interaction.animRef,
    );
  }

  VisitorPetInteraction? _interactionById(String? id) {
    if (id == null) return null;
    for (final interaction in _content.visitorInteractions) {
      if (interaction.id == id) return interaction;
    }
    return null;
  }

  bool _petWasResting(DateTime now) {
    const restThreshold = Duration(minutes: 30);
    for (final lastAt in _session.careLedger.lastAt.values) {
      final elapsed = now.difference(lastAt);
      if (!elapsed.isNegative && elapsed < restThreshold) return false;
    }
    return true;
  }

  Weather weatherAt(DateTime time) {
    final local = LocalCalendar.local(time);
    final seed = local.year * 372 + local.month * 31 + local.day;
    final roll = seed.abs() % 100;
    return switch (LocalCalendar.season(time)) {
      Season.spring =>
        roll < 18
            ? Weather.rain
            : roll < 23
            ? Weather.rainbow
            : roll < 43
            ? Weather.cloudy
            : Weather.clear,
      Season.summer =>
        roll < 10
            ? Weather.thunder
            : roll < 24
            ? Weather.rain
            : roll < 39
            ? Weather.cloudy
            : Weather.clear,
      Season.autumn =>
        roll < 15
            ? Weather.fog
            : roll < 31
            ? Weather.rain
            : roll < 51
            ? Weather.cloudy
            : Weather.clear,
      Season.winter =>
        roll < 21
            ? Weather.snow
            : roll < 34
            ? Weather.fog
            : roll < 57
            ? Weather.cloudy
            : Weather.clear,
    };
  }

  void _clearExpiredActiveVisitor(DateTime now) {
    final active = _session.activeVisitor;
    if (active != null && !active.leavesAt.isAfter(now)) {
      _session.activeVisitor = null;
    }
  }

  void _consumeVisitorFood() {
    final inventory = _session.shopInventory;
    final itemId = inventory.activeVisitorFoodItemId;
    if (itemId == null) return;
    final remaining = (inventory.consumables[itemId] ?? 0) - 1;
    if (remaining > 0) {
      inventory.consumables[itemId] = remaining;
      _session.yard.foodTray.remaining = remaining;
      return;
    }
    inventory.consumables.remove(itemId);
    inventory.activeVisitorFoodItemId = null;
    _session.yard.foodTray
      ..foodType = null
      ..placedAt = null
      ..probabilityScope = null
      ..probabilityDelta = 0
      ..remaining = 0;
  }
}

class _NoopSessionStore extends SessionStore {
  _NoopSessionStore._() : super(Directory.systemTemp);

  static final instance = _NoopSessionStore._();

  @override
  Future<GameSession?> load() async => null;

  @override
  Future<void> save(GameSession session) async {}
}

bool _isBirdVisitor(String visitorId) => const {
  'visitor_sparrow',
  'visitor_pigeon',
  'visitor_crow',
  'visitor_owl',
  'visitor_egret',
}.contains(visitorId);
