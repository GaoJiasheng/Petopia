import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/unlock_rule.dart';
import '../domain/models/logs.dart';
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
  /// 当前宠是否已达毕业线（可举行毕业典礼）。
  final bool canGraduate;
  const GameView({
    required this.pet, required this.wallet, required this.luxuryStage,
    required this.cooldownSec, required this.canGraduate,
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

  // ── 各屏数据（供 UI）──────────────────────────

  /// 宠物图鉴四态列表。
  List<DexEntryView> petDex() {
    final yard = _svc.session.yard;
    return _svc.content.species.map((sp) {
      final state = _svc.unlock.dexStateOf(sp);
      String? hint;
      final rule = sp.unlockRule;
      if (state == DexState.lockedKnown && rule is GradCountUnlock) {
        final left = rule.threshold - yard.gradCount;
        hint = '再送 ${left < 0 ? 0 : left} 只毕业就能遇见它';
      } else if (state == DexState.lockedHidden && rule is HiddenClueUnlock) {
        final seen = _svc.session.clues[rule.clueId]?.visitorSeen ?? false;
        hint = seen ? rule.clueText : '？？？';
      }
      return DexEntryView(
          speciesId: sp.id, name: sp.name, category: sp.category,
          baseTone: sp.baseTone, state: state, hint: hint);
    }).toList();
  }

  /// 成就列表（含进度 / 解锁 / 隐藏线索）。
  List<AchievementView> achievementsView() {
    return _svc.content.achievements.map((a) {
      final p = _svc.session.achievements[a.id];
      final unlocked = p?.unlockedAt != null;
      return AchievementView(
        id: a.id,
        name: (a.hidden && !unlocked) ? '？？？' : a.name,
        hidden: a.hidden,
        unlocked: unlocked,
        progress: p?.progress ?? 0,
        target: a.condition.target,
        clueText: (a.hidden && !unlocked) ? a.clueText : null,
        rewardFluff: a.reward.fluff,
      );
    }).toList();
  }

  /// 成长手账：当前宠的经验流水（按时间升序）。
  Future<List<ExpLogEntry>> growthJournal() async {
    final pet = _svc.session.current;
    if (pet == null) return const [];
    return _svc.readExpLog(pet.id);
  }

  /// 商店商品列表（含是否已拥有 / 是否买得起）。
  List<ShopItemView> shopItems() {
    final yard = _svc.session.yard;
    final bal = _svc.session.wallet.balance;
    return _svc.content.shopItems.map((it) {
      final owned = switch (it.effect.type) {
        EffectType.themeSkin => yard.ownedThemeIds.contains(it.effect.params['themeId']),
        EffectType.decor => yard.ownedDecorIds.contains(it.effect.params['decorId']),
        EffectType.toyPermanentBonus => yard.ownedPerks.contains(it.id),
        _ => false, // 消耗品/皮肤/概率：不标已拥有
      };
      return ShopItemView(
        id: it.id, name: it.name, category: it.category, price: it.price,
        owned: owned, affordable: bal >= it.price, consumable: it.consumable);
    }).toList();
  }

  /// 购买。成功后刷新快照。
  Future<void> buy(String itemId) async {
    final item = _svc.content.shopItemById(itemId);
    if (item == null) return;
    _svc.economy.purchase(item);
    state = AsyncData(_snapshot());
  }

  /// 来客图鉴（含是否已收录 / 首次到访 / 次数）。
  List<VisitorDexView> visitorDex() {
    final log = _svc.session.visitorLog;
    return _svc.content.visitors.map((v) {
      final visits = log.where((e) => e.visitorId == v.id).toList();
      final first = visits.isEmpty
          ? null
          : visits.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      return VisitorDexView(
        id: v.id, name: v.name, rarity: v.rarity,
        collected: visits.isNotEmpty, count: visits.length, firstSeen: first);
    }).toList();
  }

  // ── 设置 ──────────────────────────────────────
  bool get notificationsOn => _svc.session.settings.notifications;
  bool get soundOn => _svc.session.settings.sound;
  void toggleNotifications() {
    _svc.session.settings.notifications = !_svc.session.settings.notifications;
    state = AsyncData(_snapshot());
  }
  void toggleSound() {
    _svc.session.settings.sound = !_svc.session.settings.sound;
    state = AsyncData(_snapshot());
  }

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
      canGraduate: p != null && p.exp >= GameConfig.graduationExp,
    );
  }

  // ── 领养 / 毕业（核心情感闭环）──────────────────────

  /// 可领养物种（已解锁）。
  List<AdoptChoiceView> adoptChoices() => _svc.adoptableSpecies().map((sp) {
        return AdoptChoiceView(
          speciesId: sp.id, name: sp.name,
          category: sp.category, baseTone: sp.baseTone);
      }).toList();

  /// 领养新宠为当前在养宠，刷新快照。
  Future<void> adopt(String speciesId, String name) async {
    _svc.adopt(speciesId: speciesId, name: name);
    state = AsyncData(_snapshot());
  }

  /// 举行毕业典礼：结算 + 送宠去旅行。返回旅程站点数（未达标返回 null）。
  Future<int?> graduate() async {
    final stops = await _svc.graduateCurrent();
    state = AsyncData(_snapshot());
    return stops;
  }
}

/// 领养候选视图。
class AdoptChoiceView {
  final String speciesId;
  final String name;
  final PetCategory category;
  final String baseTone;
  const AdoptChoiceView({
    required this.speciesId, required this.name,
    required this.category, required this.baseTone,
  });
}

/// 图鉴条目视图。
class DexEntryView {
  final String speciesId;
  final String name;
  final PetCategory category;
  final String baseTone;
  final DexState state;
  final String? hint; // 未解锁的条件/线索
  const DexEntryView({
    required this.speciesId, required this.name, required this.category,
    required this.baseTone, required this.state, this.hint,
  });
}

/// 成就视图。
class AchievementView {
  final String id;
  final String name;
  final bool hidden;
  final bool unlocked;
  final int progress;
  final int target;
  final String? clueText;
  final int rewardFluff;
  const AchievementView({
    required this.id, required this.name, required this.hidden,
    required this.unlocked, required this.progress, required this.target,
    this.clueText, required this.rewardFluff,
  });
}

/// 商店商品视图。
class ShopItemView {
  final String id;
  final String name;
  final String category;
  final int price;
  final bool owned;
  final bool affordable;
  final bool consumable;
  const ShopItemView({
    required this.id, required this.name, required this.category,
    required this.price, required this.owned, required this.affordable,
    required this.consumable,
  });
}

/// 来客图鉴视图。
class VisitorDexView {
  final String id;
  final String name;
  final VisitorRarity rarity;
  final bool collected;
  final int count;
  final DateTime? firstSeen;
  const VisitorDexView({
    required this.id, required this.name, required this.rarity,
    required this.collected, required this.count, this.firstSeen,
  });
}

final gameControllerProvider =
    AsyncNotifierProvider<GameController, GameView>(GameController.new);
