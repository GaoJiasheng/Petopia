import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/game_state.dart';
import '../domain/models/content_entities.dart';
import 'economy_service.dart';
import 'graduation_service.dart';

/// GraduationService 实现（spec-technical §3.2 / §3）。
///
/// Lv10 毕业编排：暖绒结算 → 生成 Journey(25+15 站，性格加权去重) →
/// 宠物转 TRAVELING → 院子 gradCount++（驱动豪华度进化）。
class GraduationServiceImpl implements GraduationService {
  final EconomyService _economy;
  final List<Location> _locations;
  final YardState _yard;
  final String Function() _idGen;
  final DateTime Function() _now;
  final double Function() _rng; // [0,1)
  final void Function(Journey) _onJourney;

  GraduationServiceImpl(
    this._economy,
    this._locations,
    this._yard,
    this._idGen,
    this._now,
    this._rng,
    this._onJourney,
  );

  @override
  Future<String> graduate(Pet pet) async {
    _economy.settleGraduation(pet); // 稳定 ref grad:<petId>

    final route = _pickRoute(pet);
    final journey = Journey(
      id: _idGen(),
      petId: pet.id,
      stops: route.stops,
      wanderStops: route.wanderStops,
      nextPostcardAt: _now().add(const Duration(days: 1)),
      state: JourneyState.active,
    );

    pet.state = PetState.traveling;
    pet.graduatedAt = _now();
    pet.journeyId = journey.id;

    _yard.gradCount += 1;
    _yard.luxuryStage = luxuryStageFor(_yard.gradCount);

    _onJourney(journey);
    return journey.id;
  }

  /// 豪华度阶段（gradCount → 1..6）：0→①,1→②,3→③,5→④,8→⑤,12→⑥。
  static int luxuryStageFor(int gradCount) {
    if (gradCount >= 12) return 6;
    if (gradCount >= 8) return 5;
    if (gradCount >= 5) return 4;
    if (gradCount >= 3) return 3;
    if (gradCount >= 1) return 2;
    return 1;
  }

  /// 选 25 张主旅程 + 其余地点补完，按性格加权随机、不放回抽取。
  ({List<String> stops, List<String> wanderStops}) _pickRoute(Pet pet) {
    final count = _journeyStopCount();
    final candidates = <Location>[];
    final seen = <String>{};
    for (final location in _locations) {
      if (!seen.add(location.id)) continue;
      candidates.add(location);
    }

    final stops = <String>[];
    while (stops.length < count && candidates.isNotEmpty) {
      final index = _drawWeightedIndex(candidates, pet);
      final selected = candidates.removeAt(index);
      stops.add(selected.id);
    }

    final wanderStops = <String>[];
    while (candidates.isNotEmpty) {
      final index = _drawWeightedIndex(candidates, pet);
      final selected = candidates.removeAt(index);
      wanderStops.add(selected.id);
    }
    return (stops: stops, wanderStops: wanderStops);
  }

  int _journeyStopCount() {
    const min = GameConfig.journeyStopsMin;
    const max = GameConfig.journeyStopsMax;
    if (max <= min) return min;
    return min + (_rng() * (max - min + 1)).floor();
  }

  double _weight(Location l, Pet pet) {
    double w = 1.0;
    for (final tag in pet.personality) {
      w *= l.personalityWeight[tag] ?? 1.0;
    }
    return w;
  }

  int _drawWeightedIndex(List<Location> candidates, Pet pet) {
    var total = 0.0;
    for (final location in candidates) {
      final weight = _weight(location, pet);
      if (weight.isFinite && weight > 0) {
        total += weight;
      }
    }

    if (total <= 0) {
      return (_rng() * candidates.length)
          .floor()
          .clamp(0, candidates.length - 1)
          .toInt();
    }

    final target = _rng() * total;
    var cursor = 0.0;
    for (var i = 0; i < candidates.length; i++) {
      final weight = _weight(candidates[i], pet);
      if (!weight.isFinite || weight <= 0) continue;
      cursor += weight;
      if (target < cursor) return i;
    }
    return candidates.length - 1;
  }
}
