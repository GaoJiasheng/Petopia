import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/game_state.dart';
import '../domain/models/content_entities.dart';
import 'economy_service.dart';
import 'graduation_service.dart';

/// GraduationService 实现（spec-technical §3.2 / §3）。
///
/// Lv10 毕业编排：暖绒结算 → 生成 Journey(5–8 站，性格加权去重) →
/// 宠物转 TRAVELING → 院子 gradCount++（驱动豪华度进化）。
class GraduationServiceImpl implements GraduationService {
  final EconomyService _economy;
  final List<Location> _locations;
  final YardState _yard;
  final String Function() _idGen;
  final DateTime Function() _now;
  final double Function() _rng; // [0,1)，仅决定站数
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

    final stops = _pickStops(pet);
    final journey = Journey(
      id: _idGen(),
      petId: pet.id,
      stops: stops,
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

  /// 选 5–8 站，按性格加权，去重。站数由 rng 决定，选取按权重降序（确定性、可测）。
  List<String> _pickStops(Pet pet) {
    final count = (5 + (_rng() * 4).floor()).clamp(5, 8);
    final scored = _locations
        .map((l) => MapEntry(l.id, _weight(l, pet)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final n = count > scored.length ? scored.length : count;
    return scored.take(n).map((e) => e.key).toList();
  }

  double _weight(Location l, Pet pet) {
    double w = 1.0;
    for (final tag in pet.personality) {
      w *= l.personalityWeight[tag] ?? 1.0;
    }
    return w;
  }
}
