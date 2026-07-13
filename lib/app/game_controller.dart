import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_service.dart';
import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/unlock_rule.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/logs.dart';
import '../domain/models/yard.dart';
import 'bootstrap.dart';
import 'game_services.dart';
import 'notification_service.dart';

/// 照料动作。
enum CareAction { feed, pat, toy, bath }

class AchievementUnlockCue {
  final List<String> names;
  final int seq;
  const AchievementUnlockCue(this.names, this.seq);
}

/// 宠物视图（不可变快照，供 UI）。
class PetView {
  final String name;
  final String speciesId;
  final String variantId;
  final int level;
  final int exp;
  final PetStage stage;
  final List<String> personality;
  const PetView({
    required this.name,
    required this.speciesId,
    required this.variantId,
    required this.level,
    required this.exp,
    required this.stage,
    required this.personality,
  });
}

class EventPresentationView {
  final String id;
  final String title;
  final String script;
  final EventType type;
  final int expReward;
  final int currencyReward;

  const EventPresentationView({
    required this.id,
    required this.title,
    required this.script,
    required this.type,
    required this.expReward,
    required this.currencyReward,
  });
}

class RevisitorPresenceView {
  final String id;
  final String name;
  final String speciesId;
  final String variantId;
  final DateTime arrivedAt;
  final DateTime leavesAt;
  final bool arrivalSeen;
  final bool interacted;

  const RevisitorPresenceView({
    required this.id,
    required this.name,
    required this.speciesId,
    required this.variantId,
    required this.arrivedAt,
    required this.leavesAt,
    required this.arrivalSeen,
    required this.interacted,
  });
}

/// 当前驻留访客视图。
class VisitorPresenceView {
  final String id;
  final String name;
  final VisitorRarity rarity;
  final String message;
  final DateTime arrivedAt;
  final DateTime leavesAt;
  final bool arrivalSeen;
  final String yardAsset;
  final String portraitAsset;

  const VisitorPresenceView({
    required this.id,
    required this.name,
    required this.rarity,
    required this.message,
    required this.arrivedAt,
    required this.leavesAt,
    required this.arrivalSeen,
    required this.yardAsset,
    required this.portraitAsset,
  });
}

/// 游戏视图快照。
class GameView {
  final PetView? pet;
  final int wallet;
  final int luxuryStage;

  /// 各动作剩余冷却秒数（>0 表示冷却中，UI 显示水彩沙漏、置灰）。
  final Map<CareAction, int> cooldownSec;

  /// 达到自然日次数上限的动作。
  final Set<CareAction> dailyMaxed;

  /// 当前宠是否已达毕业线（可举行毕业典礼）。
  final bool canGraduate;

  /// 当前装备的院子主题 id（驱动院子背景）。
  final String activeThemeId;

  /// 自定义院子摆件槽位；为空时 UI 使用默认布置。
  final List<YardSlotView> decorSlots;

  /// 今日驻留在院子里的野生访客。
  final VisitorPresenceView? activeVisitor;

  /// 尚未展示过到访弹框的访客。
  final VisitorPresenceView? visitorArrival;
  final RevisitorPresenceView? revisitor;
  final RevisitorPresenceView? revisitorArrival;
  final EventPresentationView? pendingEvent;

  const GameView({
    required this.pet,
    required this.wallet,
    required this.luxuryStage,
    required this.cooldownSec,
    required this.dailyMaxed,
    required this.canGraduate,
    required this.activeThemeId,
    required this.decorSlots,
    this.activeVisitor,
    this.visitorArrival,
    this.revisitor,
    this.revisitorArrival,
    this.pendingEvent,
  });
}

/// 游戏控制器：唯一启动入口 + 带冷却的动作 + 响应式快照。
/// UI 通过它读状态、发动作；动作后重建快照触发刷新。
class GameController extends AsyncNotifier<GameView> {
  late GameServices _svc;
  int _achievementCueSeq = 0;
  bool _resuming = false;

  @override
  Future<GameView> build() async {
    _svc = await bootstrapGame();
    // 同步声音开关到音频引擎；若开启通知则注册每日提醒。
    ref.read(audioServiceProvider).setEnabled(_svc.session.settings.sound);
    if (_svc.session.settings.notifications) {
      ref.read(notificationServiceProvider).setDailyReminder(true);
    }
    return _snapshot();
  }

  GameServices get services => _svc;

  AudioService get _audio => ref.read(audioServiceProvider);

  Future<bool> feed() => _care(
    CareAction.feed,
    ExpSource.feed,
    GameConfig.feedExp,
    GameConfig.feedCooldownMin,
  );
  Future<bool> pat() => _care(
    CareAction.pat,
    ExpSource.pat,
    GameConfig.patExp,
    GameConfig.patCooldownMin,
  );
  Future<bool> toy() => _care(
    CareAction.toy,
    ExpSource.toy,
    GameConfig.toyExp,
    GameConfig.toyCooldownMin,
  );
  Future<bool> bath() => _care(
    CareAction.bath,
    ExpSource.bath,
    GameConfig.bathExp,
    0,
  ); // 洗澡按自然日，无分钟冷却

  Future<bool> _care(
    CareAction action,
    ExpSource source,
    int baseExp,
    int cooldownMin,
  ) async {
    final pet = _svc.session.current;
    if (pet == null) return false;
    _renewCareLedger();
    if (_dailyMaxed(action)) return false;
    if (_remainingSec(action, cooldownMin) > 0) return false;
    final beforeLevel = pet.level;
    final beforeStage = pet.stage;
    HapticFeedback.lightImpact();
    final effectiveExp = _effectiveCareExp(action, baseExp);
    _svc.exp.addExp(pet: pet, baseDelta: effectiveExp, source: source);
    _svc.session.careActionCount++; // 成就：照料动作累计
    final ledger = _svc.session.careLedger;
    final firstCareOfDay = !ledger.firstCareRewarded;
    ledger.counts[action.name] = (ledger.counts[action.name] ?? 0) + 1;
    ledger.lastAt[action.name] = _svc.clock.now();
    if (firstCareOfDay) {
      _svc.economy.earn(
        GameConfig.dailyFirstCareFluff,
        CurrencyReason.dailyFirstCare,
        ref: 'daily-care:${ledger.dayKey}',
      );
      ledger.firstCareRewarded = true;
      _svc.bumpAchievementSignal('care:days');
    }
    final actionSignal = switch (action) {
      CareAction.toy => 'play_toy',
      _ => action.name,
    };
    _svc.bumpAchievementSignal('action:$actionSignal');
    final localNow = _svc.clock.now().toLocal();
    if (localNow.hour < 2) {
      _svc.bumpAchievementSignal('custom:night_care');
    }
    if (localNow.hour == 5 || (localNow.hour == 6 && localNow.minute <= 30)) {
      _svc.bumpAchievementSignal('custom:dawn_care');
    }
    if (localNow.month == 1 && localNow.day == 1) {
      _svc.bumpAchievementSignal('custom:care');
    }
    if (action == CareAction.pat && pet.personality.contains('p_aloof')) {
      _svc.bumpAchievementSignal('custom:pat');
    }
    if (beforeLevel < GameConfig.stageBLevel &&
        pet.level >= GameConfig.stageBLevel) {
      _svc.bumpAchievementSignal('action:evolve_lv5');
    }
    if (beforeLevel < GameConfig.stageCLevel &&
        pet.level >= GameConfig.stageCLevel) {
      _svc.bumpAchievementSignal('action:reach_lv8');
    }
    _grantLevelRewards(pet.id, beforeLevel, pet.level);
    // 升级 / 换模 的手感 + 音效反馈。
    if (pet.stage != beforeStage) {
      HapticFeedback.mediumImpact();
      _audio.sting(switch (pet.stage) {
        PetStage.b => Sting.evolveB,
        PetStage.c => Sting.evolveC,
        PetStage.d => Sting.evolveD,
        PetStage.a => Sting.levelup,
      });
    } else if (pet.level > beforeLevel) {
      HapticFeedback.selectionClick();
      _audio.sting(Sting.levelup);
    }
    state = AsyncData(_snapshot());
    _afterGameAction();
    return true;
  }

  int _remainingSec(CareAction action, int cooldownMin) {
    if (cooldownMin <= 0) return 0;
    _renewCareLedger();
    final last = _svc.session.careLedger.lastAt[action.name];
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

  static const _dailyCapOf = {
    CareAction.feed: GameConfig.feedDailyCap,
    CareAction.pat: GameConfig.patDailyCap,
    CareAction.toy: GameConfig.toyDailyCap,
    CareAction.bath: GameConfig.bathDailyCap,
  };

  void _renewCareLedger() {
    _svc.session.careLedger.renew(_dayKey(_svc.clock.now().toLocal()));
  }

  bool _dailyMaxed(CareAction action) {
    final count = _svc.session.careLedger.counts[action.name] ?? 0;
    return count >= _dailyCapOf[action]!;
  }

  void _grantLevelRewards(String petId, int before, int after) {
    for (var level = before + 1; level <= after; level++) {
      _svc.economy.earn(
        GameConfig.levelUpFluff,
        CurrencyReason.levelUp,
        ref: 'levelup:$petId:$level',
      );
    }
  }

  int _effectiveCareExp(CareAction action, int baseExp) {
    if (action == CareAction.toy) {
      var effective = baseExp;
      for (final itemId in _svc.session.yard.ownedPerks) {
        final item = _svc.content.shopItemById(itemId);
        final expTo = item?.effect.params['expTo'] as int?;
        if (expTo != null && expTo > effective) effective = expTo;
      }
      return effective;
    }
    if (action != CareAction.feed && action != CareAction.bath) return baseExp;
    final inventory = _svc.session.shopInventory.consumables;
    for (final item in _svc.content.shopItems) {
      if (item.effect.type != EffectType.feedBonus) continue;
      final count = inventory[item.id] ?? 0;
      if (count <= 0 || item.effect.params['expFrom'] != baseExp) continue;
      if (count == 1) {
        inventory.remove(item.id);
      } else {
        inventory[item.id] = count - 1;
      }
      return (item.effect.params['expTo'] as int?) ?? baseExp;
    }
    return baseExp;
  }

  static String _dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

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
        speciesId: sp.id,
        name: sp.name,
        category: sp.category,
        baseTone: sp.baseTone,
        state: state,
        hint: hint,
      );
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
        EffectType.themeSkin => yard.ownedThemeIds.contains(
          it.effect.params['themeId'],
        ),
        EffectType.decor => yard.ownedDecorIds.contains(
          it.effect.params['decorId'],
        ),
        EffectType.toyPermanentBonus => yard.ownedPerks.contains(it.id),
        EffectType.albumSkin =>
          _svc.session.shopInventory.ownedAlbumSkinIds.contains(
            it.effect.params['skinId'],
          ),
        _ => false, // 消耗品/皮肤/概率：不标已拥有
      };
      final themeId = it.effect.type == EffectType.themeSkin
          ? it.effect.params['themeId'] as String?
          : null;
      final albumSkinId = it.effect.type == EffectType.albumSkin
          ? it.effect.params['skinId'] as String?
          : null;
      return ShopItemView(
        id: it.id,
        name: it.name,
        category: it.category,
        price: it.price,
        owned: owned,
        affordable: bal >= it.price,
        consumable: it.consumable,
        themeId: themeId,
        albumSkinId: albumSkinId,
        quantity: _svc.session.shopInventory.consumables[it.id] ?? 0,
        active:
            (themeId != null && themeId == yard.activeThemeId) ||
            (albumSkinId != null &&
                albumSkinId == _svc.session.shopInventory.activeAlbumSkinId),
      );
    }).toList();
  }

  /// 购买。成功后刷新快照。
  Future<bool> buy(String itemId) async {
    final item = _svc.content.shopItemById(itemId);
    if (item == null) return false;
    final result = _svc.economy.purchase(item);
    if (!result.success) return false;
    state = AsyncData(_snapshot());
    _afterGameAction();
    return true;
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
        id: v.id,
        name: v.name,
        rarity: v.rarity,
        collected: visits.isNotEmpty,
        count: visits.length,
        firstSeen: first,
      );
    }).toList();
  }

  // ── 设置 ──────────────────────────────────────
  bool get notificationsOn => _svc.session.settings.notifications;
  bool get soundOn => _svc.session.settings.sound;
  void toggleNotifications() {
    _svc.session.settings.notifications = !_svc.session.settings.notifications;
    ref
        .read(notificationServiceProvider)
        .setDailyReminder(_svc.session.settings.notifications);
    state = AsyncData(_snapshot());
    _persist();
  }

  void toggleSound() {
    _svc.session.settings.sound = !_svc.session.settings.sound;
    _audio.setEnabled(_svc.session.settings.sound);
    state = AsyncData(_snapshot());
    _persist();
  }

  /// App 从后台恢复时统一推进离线成长、日程、明信片和回访。
  Future<void> onAppResumed() async {
    if (_resuming) return;
    _resuming = true;
    try {
      final pet = _svc.session.current;
      if (pet != null) {
        final before = pet.level;
        final elapsed = _svc.clock.resolveOfflineElapsed(
          lastOnlineAt: pet.lastOnlineAt,
        );
        _svc.exp.grantOffline(pet: pet, elapsed: elapsed);
        _grantLevelRewards(pet.id, before, pet.level);
      }
      final now = _svc.clock.now();
      _svc.clock.markHeartbeat();
      await _svc.scheduler.onDailyTick(now);
      await _svc.scheduler.onResume(now);
      await _svc.processRoaming(now);
      _renewCareLedger();
      _afterGameAction();
      state = AsyncData(_snapshot());
      await _svc.store.save(_svc.session);
    } finally {
      _resuming = false;
    }
  }

  Future<void> onAppPaused() async {
    if (!state.hasValue) return;
    final pet = _svc.session.current;
    if (pet != null) pet.lastOnlineAt = _svc.clock.now();
    _svc.clock.markHeartbeat();
    await _svc.store.save(_svc.session);
  }

  void _persist() {
    unawaited(_svc.store.save(_svc.session));
  }

  /// 游戏推进类动作统一收尾：同步成就（新解锁播 sting）+ 存档。
  void _afterGameAction() {
    final newly = _svc.syncAchievements();
    if (newly.isNotEmpty) {
      for (final achievement in newly) {
        _svc.unlock.claimReward(achievement.id);
      }
      _audio.sting(Sting.achievement);
      ref
          .read(achievementUnlockCueProvider.notifier)
          .state = AchievementUnlockCue(
        newly.map((achievement) => achievement.name).toList(growable: false),
        ++_achievementCueSeq,
      );
    }
    _persist();
  }

  /// 首页欢迎弹框展示后调用；访客仍会继续驻留到 leavesAt。
  void markVisitorArrivalSeen(String visitorId) {
    final active = _svc.session.activeVisitor;
    if (active == null || active.visitorId != visitorId || active.arrivalSeen) {
      return;
    }
    active.arrivalSeen = true;
    state = AsyncData(_snapshot());
    _persist();
  }

  void markRevisitorArrivalSeen(String petId) {
    final revisitor = _svc.session.revisitor;
    if (revisitor == null || revisitor.id != petId) return;
    _svc.session.revisitorArrivalSeen = true;
    state = AsyncData(_snapshot());
    _persist();
  }

  void markRevisitorInteracted(String petId) {
    final revisitor = _svc.session.revisitor;
    if (revisitor == null || revisitor.id != petId) return;
    _svc.session.revisitorInteracted = true;
    state = AsyncData(_snapshot());
    _persist();
  }

  void dismissEvent(String id) {
    _svc.session.pendingEvents.removeWhere((event) => event.id == id);
    state = AsyncData(_snapshot());
    _persist();
  }

  GameView _snapshot() {
    if (_expireActiveVisitorIfNeeded()) {
      _persist();
    }
    final p = _svc.session.current;
    final activeVisitor = _activeVisitorView();
    return GameView(
      pet: p == null
          ? null
          : PetView(
              name: p.name,
              speciesId: p.speciesId,
              variantId: p.variantId,
              level: p.level,
              exp: p.exp,
              stage: p.stage,
              // 解析性格 id→展示名（爱幻想/温柔…），回退 id。
              personality: p.personality
                  .map((id) => _svc.content.personalityById(id)?.name ?? id)
                  .toList(),
            ),
      wallet: _svc.session.wallet.balance,
      luxuryStage: _svc.session.yard.luxuryStage,
      cooldownSec: {
        for (final a in CareAction.values)
          a: _remainingSec(a, _cooldownMinOf[a]!),
      },
      dailyMaxed: {
        for (final action in CareAction.values)
          if (_dailyMaxed(action)) action,
      },
      canGraduate: p != null && p.exp >= GameConfig.graduationExp,
      activeThemeId: _svc.session.yard.activeThemeId,
      decorSlots: _svc.session.yard.slots
          .map((slot) => YardSlotView(pos: slot.pos, itemId: slot.itemId))
          .toList(growable: false),
      activeVisitor: activeVisitor,
      visitorArrival: activeVisitor != null && !activeVisitor.arrivalSeen
          ? activeVisitor
          : null,
      revisitor: _revisitorView(),
      revisitorArrival: !_svc.session.revisitorArrivalSeen
          ? _revisitorView()
          : null,
      pendingEvent: _pendingEventView(),
    );
  }

  RevisitorPresenceView? _revisitorView() {
    final pet = _svc.session.revisitor;
    final arrivedAt = _svc.session.revisitorArrivedAt;
    final leavesAt = _svc.session.revisitorLeavesAt;
    if (pet == null || arrivedAt == null || leavesAt == null) return null;
    if (!leavesAt.isAfter(_svc.clock.now())) return null;
    return RevisitorPresenceView(
      id: pet.id,
      name: pet.name,
      speciesId: pet.speciesId,
      variantId: pet.variantId,
      arrivedAt: arrivedAt,
      leavesAt: leavesAt,
      arrivalSeen: _svc.session.revisitorArrivalSeen,
      interacted: _svc.session.revisitorInteracted,
    );
  }

  EventPresentationView? _pendingEventView() {
    if (_svc.session.pendingEvents.isEmpty) return null;
    final event = _svc.session.pendingEvents.first;
    return EventPresentationView(
      id: event.id,
      title: event.title,
      script: event.script,
      type: event.type,
      expReward: event.expReward,
      currencyReward: event.currencyReward,
    );
  }

  bool _expireActiveVisitorIfNeeded() {
    final active = _svc.session.activeVisitor;
    if (active == null) return false;
    if (active.leavesAt.isAfter(_svc.clock.now())) return false;
    _svc.session.activeVisitor = null;
    return true;
  }

  VisitorPresenceView? _activeVisitorView() {
    final active = _svc.session.activeVisitor;
    if (active == null || active.visitorId.isEmpty) return null;
    final visitor = _svc.content.visitorById(active.visitorId);
    if (visitor == null) return null;
    final interaction = _visitorInteractionById(active.interactionId);
    return VisitorPresenceView(
      id: visitor.id,
      name: visitor.name,
      rarity: visitor.rarity,
      message: interaction?.script ?? '${visitor.name}正在院子里慢慢逛。',
      arrivedAt: active.arrivedAt,
      leavesAt: active.leavesAt,
      arrivalSeen: active.arrivalSeen,
      yardAsset: _visitorArtAsset(visitor.id, 'yard'),
      portraitAsset: _visitorArtAsset(visitor.id, 'portrait'),
    );
  }

  String _visitorArtAsset(String visitorId, String suffix) {
    final slug = switch (visitorId) {
      'visitor_campfire_light' => 'visitor_emberlight',
      'visitor_rainbow_shade' => 'visitor_rainbowshade',
      'visitor_night_blob' => 'visitor_ghostpuff',
      _ => visitorId,
    };
    return 'assets/art/world/visitors/${slug}_$suffix.png';
  }

  VisitorPetInteraction? _visitorInteractionById(String? id) {
    if (id == null) return null;
    for (final interaction in _svc.content.visitorInteractions) {
      if (interaction.id == id) return interaction;
    }
    return null;
  }

  /// 已拥有的主题（供商店/布置显示「使用中/应用」）。含当前是否装备。
  String get activeThemeId => _svc.session.yard.activeThemeId;
  Set<String> get ownedThemeIds => _svc.session.yard.ownedThemeIds.toSet();

  /// 装备主题（themeId 需在 ownedThemeIds 内）。刷新快照 + 存档。
  void applyTheme(String themeId) {
    if (!_svc.session.yard.ownedThemeIds.contains(themeId)) return;
    _svc.session.yard.activeThemeId = themeId;
    state = AsyncData(_snapshot());
    _persist();
  }

  String get activeAlbumSkinId => _svc.session.shopInventory.activeAlbumSkinId;

  void applyAlbumSkin(String skinId) {
    final inventory = _svc.session.shopInventory;
    if (!inventory.ownedAlbumSkinIds.contains(skinId)) return;
    inventory.activeAlbumSkinId = skinId;
    state = AsyncData(_snapshot());
    _persist();
  }

  /// 已拥有摆件（来自商店 decor 商品）。仅返回已购买的 decorId。
  List<DecorItemView> decorInventory() {
    final owned = _svc.session.yard.ownedDecorIds.toSet();
    return _svc.content.shopItems
        .where((item) => item.effect.type == EffectType.decor)
        .map((item) {
          final decorId = item.effect.params['decorId'] as String?;
          if (decorId == null || !owned.contains(decorId)) return null;
          return DecorItemView(decorId: decorId, name: item.name);
        })
        .whereType<DecorItemView>()
        .toList(growable: false);
  }

  /// 指派院子摆件到固定槽位。decorId=null 表示清空。
  void placeDecor(int pos, String? decorId) {
    if (pos < 0 || pos >= decorSlotCount) return;
    final yard = _svc.session.yard;
    if (decorId != null && !yard.ownedDecorIds.contains(decorId)) return;

    yard.slots.removeWhere(
      (slot) => slot.pos == pos || (decorId != null && slot.itemId == decorId),
    );
    yard.slots.add(YardSlot(pos: pos, itemId: decorId));
    yard.slots.sort((a, b) => a.pos.compareTo(b.pos));
    state = AsyncData(_snapshot());
    _persist();
  }

  static const int decorSlotCount = 6;

  /// 仅刷新派生视图数据（例如动作冷却剩余秒数），不改存档。
  void refreshView() {
    if (!state.hasValue) return;
    state = AsyncData(_snapshot());
  }

  // ── 领养 / 毕业（核心情感闭环）──────────────────────

  /// 可领养物种（已解锁）。
  List<AdoptChoiceView> adoptChoices() => _svc.adoptableSpecies().map((sp) {
    return AdoptChoiceView(
      speciesId: sp.id,
      name: sp.name,
      category: sp.category,
      baseTone: sp.baseTone,
    );
  }).toList();

  /// 领养新宠为当前在养宠，刷新快照。
  Future<void> adopt(String speciesId, String name) async {
    _svc.adopt(speciesId: speciesId, name: name);
    HapticFeedback.mediumImpact();
    _audio.sting(Sting.adoptionWelcome);
    state = AsyncData(_snapshot());
    _afterGameAction();
  }

  /// 举行毕业典礼：结算 + 送宠去旅行。返回旅程站点数（未达标返回 null）。
  Future<int?> graduate() async {
    final localNow = _svc.clock.now().toLocal();
    final stops = await _svc.graduateCurrent();
    if (stops != null) {
      if (localNow.hour >= 5 && localNow.hour < 8) {
        _svc.bumpAchievementSignal('custom:graduation');
      }
      HapticFeedback.mediumImpact();
      _audio.sting(Sting.graduationDepart);
      _afterGameAction();
    }
    state = AsyncData(_snapshot());
    return stops;
  }

  void trackAlbumOpened() {
    if (_svc.session.roaming.isEmpty) return;
    _svc.bumpAchievementSignal('custom:view_album');
    _afterGameAction();
  }

  void trackPostcardRead() {
    final hour = _svc.clock.now().toLocal().hour;
    if (hour < 2) _svc.bumpAchievementSignal('custom:read_postcard');
    _afterGameAction();
  }

  // ── 明信片 / 相册（#24）────────────────────────────

  /// 收到的明信片（最新在前），已解析地点名与宠物名。
  List<PostcardView> postcards() {
    final pets = {for (final p in _svc.session.allPets) p.id: p};
    final incidents = {for (final i in _svc.content.incidents) i.id: i};
    return _svc.session.postcards.reversed.map((pc) {
      final loc = _svc.content.locationById(pc.locationId);
      final pet = pets[pc.petId];
      final incident = pc.incidentId == null ? null : incidents[pc.incidentId];
      return PostcardView(
        id: pc.id,
        petName: pet?.name ?? '旅行者',
        speciesId: pet?.speciesId ?? 'pet_cat',
        variantId: pet?.variantId ?? '',
        poseHint: incident?.poseHint ?? 'gaze',
        locationName: loc?.name ?? pc.locationId,
        bodyText: pc.bodyText,
        photoBg: loc?.photoStyle ?? '',
        stampId: pc.stampId,
        stickerIds: _postcardStickerIds(pc),
        sentAt: pc.sentAt,
        seq: pc.seq,
      );
    }).toList();
  }

  static const _postcardStickerPool = [
    'pc_sticker_heart_postmark',
    'pc_sticker_straw_hat',
    'pc_sticker_creased_map',
    'pc_sticker_drift_bottle',
    'pc_sticker_leaf_spring',
    'pc_sticker_wish_star',
    'pc_sticker_cloud_gap',
    'pc_sticker_gold_beam',
    'pc_sticker_warm_kettle',
    'pc_sticker_signed_leaf',
  ];

  static List<String> _postcardStickerIds(Postcard pc) {
    final seed = '${pc.locationId}:${pc.incidentId ?? ''}:${pc.seq}';
    final value = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    final first = value % _postcardStickerPool.length;
    final second =
        (value ~/ _postcardStickerPool.length + 3) %
        _postcardStickerPool.length;
    if (first == second) return [_postcardStickerPool[first]];
    return [_postcardStickerPool[first], _postcardStickerPool[second]];
  }

  /// 旅行相册：已毕业漫游的宠物（含旅程站数 / 收到的明信片数）。
  List<TravelPetView> travelAlbum() {
    final counts = <String, int>{};
    for (final pc in _svc.session.postcards) {
      counts[pc.petId] = (counts[pc.petId] ?? 0) + 1;
    }
    return _svc.session.roaming.map((p) {
      final journey = _svc.session.journeys.where((j) => j.id == p.journeyId);
      return TravelPetView(
        speciesId: p.speciesId,
        variantId: p.variantId,
        name: p.name,
        graduatedAt: p.graduatedAt,
        stops: journey.isEmpty
            ? 0
            : journey.first.stops.length + journey.first.wanderStops.length,
        postcardCount: counts[p.id] ?? 0,
      );
    }).toList();
  }
}

/// 明信片视图（旅行相册 / 查看器）。
class PostcardView {
  final String id;
  final String petName;
  final String speciesId;
  final String variantId;
  final String poseHint;
  final String locationName;
  final String bodyText;
  final String photoBg; // 地点背景美术引用（pc_bg_*）
  final String stampId;
  final List<String> stickerIds;
  final DateTime sentAt;
  final int seq;
  const PostcardView({
    required this.id,
    required this.petName,
    required this.speciesId,
    required this.variantId,
    required this.poseHint,
    required this.locationName,
    required this.bodyText,
    required this.photoBg,
    required this.stampId,
    required this.stickerIds,
    required this.sentAt,
    required this.seq,
  });
}

/// 旅行相册条目（已毕业漫游的宠物）。
class TravelPetView {
  final String speciesId;
  final String variantId;
  final String name;
  final DateTime? graduatedAt;
  final int stops;
  final int postcardCount;
  const TravelPetView({
    required this.speciesId,
    required this.variantId,
    required this.name,
    required this.graduatedAt,
    required this.stops,
    required this.postcardCount,
  });
}

/// 领养候选视图。
class AdoptChoiceView {
  final String speciesId;
  final String name;
  final PetCategory category;
  final String baseTone;
  const AdoptChoiceView({
    required this.speciesId,
    required this.name,
    required this.category,
    required this.baseTone,
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
    required this.speciesId,
    required this.name,
    required this.category,
    required this.baseTone,
    required this.state,
    this.hint,
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
    required this.id,
    required this.name,
    required this.hidden,
    required this.unlocked,
    required this.progress,
    required this.target,
    this.clueText,
    required this.rewardFluff,
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
  final String? themeId; // themeSkin 类的主题 id（可装备）；否则 null
  final String? albumSkinId;
  final int quantity;
  final bool active; // 是否当前装备中的主题
  const ShopItemView({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.owned,
    required this.affordable,
    required this.consumable,
    this.themeId,
    this.albumSkinId,
    this.quantity = 0,
    this.active = false,
  });
}

/// 院子摆件槽位视图。
class YardSlotView {
  final int pos;
  final String? itemId;
  const YardSlotView({required this.pos, this.itemId});
}

/// 已拥有摆件视图。
class DecorItemView {
  final String decorId;
  final String name;
  const DecorItemView({required this.decorId, required this.name});
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
    required this.id,
    required this.name,
    required this.rarity,
    required this.collected,
    required this.count,
    this.firstSeen,
  });
}

final gameControllerProvider = AsyncNotifierProvider<GameController, GameView>(
  GameController.new,
);

final achievementUnlockCueProvider = StateProvider<AchievementUnlockCue?>(
  (ref) => null,
);
