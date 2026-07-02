import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import 'exp_engine.dart';
import 'revisit_service.dart';

/// RevisitService 实现（spec-technical §3 / §7）。
class RevisitServiceImpl implements RevisitService {
  final ExpEngine _exp;
  final double Function() _rng; // [0,1)
  final DateTime Function() _now;

  RevisitServiceImpl(this._exp, this._rng, this._now);

  @override
  void scheduleNextRevisit(Pet pet) {
    final span = GameConfig.revisitWindowMaxDays - GameConfig.revisitWindowMinDays + 1; // 7..14 → 8
    final days = GameConfig.revisitWindowMinDays + (_rng() * span).floor();
    pet.nextRevisitAt = _now().add(Duration(days: days));
  }

  @override
  bool isDue(Pet pet, DateTime today) {
    if (pet.state != PetState.roaming) return false;
    final at = pet.nextRevisitAt;
    return at != null && !at.isAfter(today);
  }

  @override
  Pet? pickRevisitor(List<Pet> roaming, DateTime today,
      {bool hasCurrentRevisitor = false}) {
    if (hasCurrentRevisitor) return null; // INV-2：同时最多 1 只
    Pet? earliest;
    for (final p in roaming) {
      if (!isDue(p, today)) continue;
      if (earliest == null || p.nextRevisitAt!.isBefore(earliest.nextRevisitAt!)) {
        earliest = p;
      }
    }
    return earliest;
  }

  @override
  bool onRevisitInteract(Pet revisitor, Pet? current) {
    if (current != null) {
      _exp.addExp(
        pet: current,
        baseDelta: GameConfig.revisitPetExp, // +5
        source: ExpSource.revisit,
        sourceRef: revisitor.id,
        note: '${revisitor.name} 回来串门',
        applyPersonalityBonus: false,
      );
    }
    return _rng() < GameConfig.revisitBringFriendProb; // 20% 带旅伴
  }

  @override
  void onRevisitEnd(Pet pet) => scheduleNextRevisit(pet);
}
