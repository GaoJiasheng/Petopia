import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/game_state.dart';
import '../domain/models/content_entities.dart';
import 'visitor_service.dart';

/// VisitorService 实现（spec-technical §3.6 / §8）。
///
/// 概率轮盘：P = Base(rarity) × M_time × M_weather × M_food × M_decor × M_season，
/// 再加豪华度绝对加成，clamp[0,1]。每窗口最多命中 1 只（加权轮盘，miss=1-ΣP）；
/// 传说访客各自独立伯努利，可与普通同日。
class VisitorServiceImpl implements VisitorService {
  final List<Visitor> _visitors;
  final List<VisitorPetInteraction> _interactions;
  final double Function() _rng; // [0,1)
  final String Function() _idGen;
  final DateTime Function() _now;
  final void Function(VisitorLogEntry) _onLog;
  final void Function(String clueId) _onClue;

  VisitorServiceImpl(
    this._visitors,
    this._interactions,
    this._rng,
    this._idGen,
    this._now,
    this._onLog,
    this._onClue,
  );

  static const Set<TimeOfDayOfDay> _dayTimes = {
    TimeOfDayOfDay.dawn,
    TimeOfDayOfDay.morning,
    TimeOfDayOfDay.noon,
    TimeOfDayOfDay.afternoon,
  };
  static const Set<TimeOfDayOfDay> _nightTimes = {
    TimeOfDayOfDay.evening,
    TimeOfDayOfDay.night,
  };

  @override
  Visitor? rollWindow({
    required TimeWindow window,
    required YardState yard,
    required Weather weather,
    required Season season,
    required DateTime now,
  }) {
    final cands = <MapEntry<Visitor, double>>[];
    for (final v in _visitors) {
      if (v.rarity == VisitorRarity.legendary) continue;
      final p = _probability(
        v,
        window,
        yard,
        weather,
        season,
        legendary: false,
      );
      if (p > 0) cands.add(MapEntry(v, p));
    }
    if (cands.isEmpty) return null;

    double sum = 0;
    for (final e in cands) {
      sum += e.value;
    }
    // ΣP>1 时归一化到无 miss；否则 miss 区间 = [sum, 1)。
    final total = sum > 1 ? sum : 1.0;
    final r = _rng() * total;
    double acc = 0;
    for (final e in cands) {
      acc += e.value;
      if (r < acc) return e.key;
    }
    return null; // miss
  }

  @override
  Visitor? rollLegendary({
    required YardState yard,
    required Weather weather,
    required Season season,
    required DateTime now,
  }) {
    // 传说访客不限时段窗口，用夜窗判定（多为夜行）；各自独立伯努利。
    for (final v in _visitors) {
      if (v.rarity != VisitorRarity.legendary) continue;
      final window = _isNight(now) ? TimeWindow.night : TimeWindow.day;
      final p = _probability(v, window, yard, weather, season, legendary: true);
      if (p > 0 && _rng() < p) return v;
    }
    return null;
  }

  @override
  VisitorPetInteraction pickInteraction(Visitor v, Pet? pet) {
    final species = pet?.speciesId;
    if (pet != null && species != null) {
      // 1) exact(visitor, species, personality)
      for (final it in _interactions) {
        if (it.visitorId == v.id &&
            it.petSpeciesId == species &&
            it.personalityBias != null &&
            it.personalityBias!.any(pet.personality.contains)) {
          return it;
        }
      }
      // 2) exact(visitor, species)
      for (final it in _interactions) {
        if (it.visitorId == v.id &&
            it.petSpeciesId == species &&
            it.personalityBias == null) {
          return it;
        }
      }
    }
    // 3) fallback(visitor, "*")
    for (final it in _interactions) {
      if (it.visitorId == v.id && it.petSpeciesId == '*') return it;
    }
    // 兜底：无任何条目时合成默认，保证非空返回。
    return VisitorPetInteraction(
      id: 'vi_default_${v.id}',
      visitorId: v.id,
      petSpeciesId: '*',
      script: '${v.name}来院子里转了转。',
      animRef: '',
      expReward: 3,
    );
  }

  @override
  void recordVisit(Visitor v, Pet? pet, VisitorPetInteraction? it) {
    _onLog(
      VisitorLogEntry(
        id: _idGen(),
        visitorId: v.id,
        date: _now(),
        interactionId: it?.id,
        withPetId: pet?.id,
      ),
    );
    // 彩蛋线索推进：互动自带 unlockClue 优先，否则传说访客用 clueRole。
    final clue = it?.unlockClue ?? v.clueRole;
    if (clue != null) _onClue(clue);
  }

  // ── 内部 ──────────────────────────────────────
  double _probability(
    Visitor v,
    TimeWindow window,
    YardState yard,
    Weather weather,
    Season season, {
    required bool legendary,
  }) {
    if (!_timeEligible(v, window)) return 0;
    // 必要装饰硬门槛
    for (final d in v.decorReq) {
      if (!yard.ownedDecorIds.contains(d)) return 0;
    }
    double p = _baseProb(v.rarity);
    p *= v.weatherPref[weather] ?? 1.0;
    final food = yard.foodTray.foodType;
    p *= food == null ? GameConfig.emptyTrayMult : (v.foodPref[food] ?? 1.0);
    final scope = yard.foodTray.probabilityScope;
    if (food != null && scope != null && _matchesFoodScope(v.id, scope)) {
      p *= 1 + yard.foodTray.probabilityDelta.clamp(0.0, 2.0);
    }
    p *= v.seasonPref[season] ?? 1.0;
    // 豪华度绝对加成（先乘后加）
    if (yard.luxuryStage >= 2) p += GameConfig.luxuryStage2AllBonus;
    if (legendary && yard.luxuryStage >= 5) {
      p += GameConfig.luxuryStage5LegendaryBonus;
    }
    return p.clamp(0.0, 1.0);
  }

  bool _timeEligible(Visitor v, TimeWindow window) {
    if (v.activeTime.isEmpty) return true; // 不限时段
    final set = window == TimeWindow.day ? _dayTimes : _nightTimes;
    return v.activeTime.any(set.contains);
  }

  bool _isNight(DateTime now) => now.hour >= 18 || now.hour < 6;

  bool _matchesFoodScope(String visitorId, String scope) {
    return switch (scope) {
      'bird' || 'birds' =>
        visitorId == 'visitor_sparrow' ||
            visitorId == 'visitor_pigeon' ||
            visitorId == 'visitor_crow' ||
            visitorId == 'visitor_owl' ||
            visitorId == 'visitor_egret',
      'cat_egret' =>
        visitorId == 'visitor_calico' || visitorId == 'visitor_egret',
      'squirrel' => visitorId == 'visitor_squirrel',
      'rabbit_deer' =>
        visitorId == 'visitor_snowhare' || visitorId == 'visitor_deer',
      'night' => true,
      'legendary' => true,
      _ => false,
    };
  }

  double _baseProb(VisitorRarity r) => switch (r) {
    VisitorRarity.common => GameConfig.baseProbCommon,
    VisitorRarity.uncommon => GameConfig.baseProbUncommon,
    VisitorRarity.rare => GameConfig.baseProbRare,
    VisitorRarity.legendary => GameConfig.baseProbLegendary,
  };
}
