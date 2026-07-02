import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/unlock_rule.dart';
import '../domain/models/yard.dart';
import '../domain/models/game_state.dart';
import '../domain/models/content_entities.dart';
import 'economy_service.dart';
import 'unlock_service.dart';

/// UnlockService 实现（spec-technical §3.7）。
///
/// 图鉴四态、成就进度/解锁(幂等发奖)、ClueCounter 彩蛋链。
/// 彩蛋链：GameSignal → 累加计数 → 达阈使 FANTASY 物种转 AVAILABLE（由 dexStateOf 读计数体现）。
class UnlockServiceImpl implements UnlockService {
  final List<Achievement> _achievements;
  final YardState _yard;
  final Map<String, ClueCounter> _clues; // 可变，按 clueId
  final Map<String, AchievementProgress> _progress; // 可变，按 achievementId
  final bool Function(String speciesId) _wasOwned; // 是否曾养过该物种
  final EconomyService _economy;
  final DateTime Function() _now;

  UnlockServiceImpl(
    this._achievements,
    this._yard,
    this._clues,
    this._progress,
    this._wasOwned,
    this._economy,
    this._now,
  );

  @override
  DexState dexStateOf(PetSpecies s) {
    if (_wasOwned(s.id)) return DexState.ownedBefore;
    final rule = s.unlockRule;
    switch (rule) {
      case InitialUnlock():
        return DexState.available;
      case GradCountUnlock(threshold: final t):
        return _yard.gradCount >= t ? DexState.available : DexState.lockedKnown;
      case HiddenClueUnlock(clueId: final id, threshold: final t):
        final c = _clues[id];
        return (c != null && c.count >= t)
            ? DexState.available
            : DexState.lockedHidden;
    }
  }

  @override
  void bumpClue(String clueId, {int by = 1}) {
    final c = _clues.putIfAbsent(
      clueId,
      () => ClueCounter(
        clueId: clueId,
        threshold: GameConfig.clueThresholds[clueId] ?? 1 << 30,
      ),
    );
    c.count += by;
  }

  @override
  void trackEvent(GameSignal signal) {
    _applyProgress(signal);
  }

  @override
  List<Achievement> checkAchievements(GameSignal signal) {
    return _applyProgress(signal);
  }

  /// 约定：signal.type == AchievementCondType.name（如 "gradCount"）；
  /// params['progress'] = 该指标当前累计值（绝对值）。返回本次新解锁的成就。
  List<Achievement> _applyProgress(GameSignal signal) {
    final value = (signal.params['progress'] as int?) ?? 0;
    final newly = <Achievement>[];
    for (final ach in _achievements) {
      if (ach.condition.type.name != signal.type) continue;
      final p = _progress.putIfAbsent(
        ach.id,
        () => AchievementProgress(achievementId: ach.id),
      );
      if (p.unlockedAt != null) continue; // 已解锁
      if (value > p.progress) p.progress = value;
      if (p.progress >= ach.condition.target) {
        p.unlockedAt = _now();
        newly.add(ach);
      }
    }
    return newly;
  }

  @override
  void claimReward(String achievementId) {
    final p = _progress[achievementId];
    if (p == null || p.unlockedAt == null || p.rewardClaimed) return; // 幂等
    final ach = _achievements.where((a) => a.id == achievementId).firstOrNull;
    if (ach == null) return;
    if (ach.reward.fluff > 0) {
      _economy.earn(ach.reward.fluff, CurrencyReason.achievement,
          ref: 'ach:$achievementId'); // 稳定 ref（云同步幂等）
    }
    p.rewardClaimed = true;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
