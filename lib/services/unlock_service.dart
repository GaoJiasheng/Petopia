import '../domain/enums.dart';
import '../domain/models/content_entities.dart';

/// 游戏信号：驱动成就/隐藏成就/彩蛋 hiddenSteps 的统一事件入口。
/// 如 type="visitor_seen"/"night_no_food_login"/"action_pat"，params 携带上下文。
class GameSignal {
  final String type;
  final Map<String, dynamic> params;
  const GameSignal(this.type, {this.params = const {}});
}

/// UnlockService（spec-technical §3.7）。
///
/// 图鉴四态计算、成就进度/解锁、ClueCounter 彩蛋链、隐藏成就判定。
/// 彩蛋链：GameSignal → 累加 HiddenStep → 全达成 bumpClue → count 达阈 → FANTASY 物种转 AVAILABLE。
/// 发奖只一次（rewardClaimed 幂等）。
abstract interface class UnlockService {
  /// 图鉴四态（§1.2）。
  DexState dexStateOf(PetSpecies s);

  /// ClueCounter++；达标则解锁对应彩蛋物种可养。
  void bumpClue(String clueId, {int by});

  /// 统一信号入口，推进成就/隐藏成就/彩蛋 hiddenSteps。
  void trackEvent(GameSignal signal);

  /// 返回本次新解锁的成就。
  List<Achievement> checkAchievements(GameSignal signal);

  /// 发奖（经 EconomyService），置 rewardClaimed（幂等）。
  void claimReward(String achievementId);
}
