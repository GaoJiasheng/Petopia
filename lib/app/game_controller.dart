import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_service.dart';
import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/unlock_rule.dart';
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
  final int level;
  final int exp;
  final PetStage stage;
  final List<String> personality;
  const PetView({
    required this.name,
    required this.speciesId,
    required this.level,
    required this.exp,
    required this.stage,
    required this.personality,
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

  /// 当前装备的院子主题 id（驱动院子背景）。
  final String activeThemeId;

  /// 自定义院子摆件槽位；为空时 UI 使用默认布置。
  final List<YardSlotView> decorSlots;
  const GameView({
    required this.pet,
    required this.wallet,
    required this.luxuryStage,
    required this.cooldownSec,
    required this.canGraduate,
    required this.activeThemeId,
    required this.decorSlots,
  });
}

/// 游戏控制器：唯一启动入口 + 带冷却的动作 + 响应式快照。
/// UI 通过它读状态、发动作；动作后重建快照触发刷新。
class GameController extends AsyncNotifier<GameView> {
  late GameServices _svc;
  final Map<CareAction, DateTime> _lastAt = {};
  int _achievementCueSeq = 0;

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

  Future<void> feed() => _care(
    CareAction.feed,
    ExpSource.feed,
    GameConfig.feedExp,
    GameConfig.feedCooldownMin,
  );
  Future<void> pat() => _care(
    CareAction.pat,
    ExpSource.pat,
    GameConfig.patExp,
    GameConfig.patCooldownMin,
  );
  Future<void> toy() => _care(
    CareAction.toy,
    ExpSource.toy,
    GameConfig.toyExp,
    GameConfig.toyCooldownMin,
  );
  Future<void> bath() => _care(
    CareAction.bath,
    ExpSource.bath,
    GameConfig.bathExp,
    0,
  ); // 洗澡按自然日，无分钟冷却

  Future<void> _care(
    CareAction action,
    ExpSource source,
    int baseExp,
    int cooldownMin,
  ) async {
    final pet = _svc.session.current;
    if (pet == null) return;
    if (_remainingSec(action, cooldownMin) > 0) return; // 冷却中，忽略
    final beforeLevel = pet.level;
    final beforeStage = pet.stage;
    HapticFeedback.lightImpact();
    _svc.exp.addExp(pet: pet, baseDelta: baseExp, source: source);
    _svc.session.careActionCount++; // 成就：照料动作累计
    _lastAt[action] = _svc.clock.now();
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
        _ => false, // 消耗品/皮肤/概率：不标已拥有
      };
      final themeId = it.effect.type == EffectType.themeSkin
          ? it.effect.params['themeId'] as String?
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
        active: themeId != null && themeId == yard.activeThemeId,
      );
    }).toList();
  }

  /// 购买。成功后刷新快照。
  Future<void> buy(String itemId) async {
    final item = _svc.content.shopItemById(itemId);
    if (item == null) return;
    _svc.economy.purchase(item);
    state = AsyncData(_snapshot());
    _afterGameAction();
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

  void _persist() {
    unawaited(_svc.store.save(_svc.session));
  }

  /// 游戏推进类动作统一收尾：同步成就（新解锁播 sting）+ 存档。
  void _afterGameAction() {
    final newly = _svc.syncAchievements();
    if (newly.isNotEmpty) {
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

  GameView _snapshot() {
    final p = _svc.session.current;
    return GameView(
      pet: p == null
          ? null
          : PetView(
              name: p.name,
              speciesId: p.speciesId,
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
      canGraduate: p != null && p.exp >= GameConfig.graduationExp,
      activeThemeId: _svc.session.yard.activeThemeId,
      decorSlots: _svc.session.yard.slots
          .map((slot) => YardSlotView(pos: slot.pos, itemId: slot.itemId))
          .toList(growable: false),
    );
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
    final stops = await _svc.graduateCurrent();
    if (stops != null) {
      HapticFeedback.mediumImpact();
      _audio.sting(Sting.graduationDepart);
      _afterGameAction();
    }
    state = AsyncData(_snapshot());
    return stops;
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
        name: p.name,
        graduatedAt: p.graduatedAt,
        stops: journey.isEmpty ? 0 : journey.first.stops.length,
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
  final String name;
  final DateTime? graduatedAt;
  final int stops;
  final int postcardCount;
  const TravelPetView({
    required this.speciesId,
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
