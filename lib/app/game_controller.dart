import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/game_config.dart';
import '../domain/enums.dart';
import 'bootstrap.dart';
import 'game_services.dart';

/// 照料动作。
enum CareAction { feed, pat, toy, bath }

/// 宠物视图（不可变快照，供 UI）。
class PetView {
  final String name;
  final String speciesId;
  final int level;
  final int exp;
  final PetStage stage;
  final List<String> personality;
  const PetView({
    required this.name, required this.speciesId, required this.level,
    required this.exp, required this.stage, required this.personality,
  });
}

/// 游戏视图快照。
class GameView {
  final PetView? pet;
  final int wallet;
  final int luxuryStage;
  /// 各动作剩余冷却秒数（>0 表示冷却中，UI 显示水彩沙漏、置灰）。
  final Map<CareAction, int> cooldownSec;
  const GameView({
    required this.pet, required this.wallet, required this.luxuryStage,
    required this.cooldownSec,
  });
}

/// 游戏控制器：唯一启动入口 + 带冷却的动作 + 响应式快照。
/// UI 通过它读状态、发动作；动作后重建快照触发刷新。
class GameController extends AsyncNotifier<GameView> {
  late GameServices _svc;
  final Map<CareAction, DateTime> _lastAt = {};

  @override
  Future<GameView> build() async {
    _svc = await bootstrapGame();
    return _snapshot();
  }

  GameServices get services => _svc;

  Future<void> feed() => _care(CareAction.feed, ExpSource.feed, GameConfig.feedExp, GameConfig.feedCooldownMin);
  Future<void> pat() => _care(CareAction.pat, ExpSource.pat, GameConfig.patExp, GameConfig.patCooldownMin);
  Future<void> toy() => _care(CareAction.toy, ExpSource.toy, GameConfig.toyExp, GameConfig.toyCooldownMin);
  Future<void> bath() => _care(CareAction.bath, ExpSource.bath, GameConfig.bathExp, 0); // 洗澡按自然日，无分钟冷却

  Future<void> _care(CareAction action, ExpSource source, int baseExp, int cooldownMin) async {
    final pet = _svc.session.current;
    if (pet == null) return;
    if (_remainingSec(action, cooldownMin) > 0) return; // 冷却中，忽略
    _svc.exp.addExp(pet: pet, baseDelta: baseExp, source: source);
    _lastAt[action] = _svc.clock.now();
    state = AsyncData(_snapshot());
  }

  int _remainingSec(CareAction action, int cooldownMin) {
    if (cooldownMin <= 0) return 0;
    final last = _lastAt[action];
    if (last == null) return 0;
    final elapsed = _svc.clock.now().difference(last).inSeconds;
    final total = cooldownMin * 60;
    final rem = total - elapsed;
    return rem > 0 ? rem : 0;
  }

  static const _cooldownMinOf = {
    CareAction.feed: GameConfig.feedCooldownMin,
    CareAction.pat: GameConfig.patCooldownMin,
    CareAction.toy: GameConfig.toyCooldownMin,
    CareAction.bath: 0,
  };

  GameView _snapshot() {
    final p = _svc.session.current;
    return GameView(
      pet: p == null
          ? null
          : PetView(
              name: p.name, speciesId: p.speciesId, level: p.level, exp: p.exp,
              stage: p.stage, personality: p.personality),
      wallet: _svc.session.wallet.balance,
      luxuryStage: _svc.session.yard.luxuryStage,
      cooldownSec: {
        for (final a in CareAction.values) a: _remainingSec(a, _cooldownMinOf[a]!),
      },
    );
  }
}

final gameControllerProvider =
    AsyncNotifierProvider<GameController, GameView>(GameController.new);
