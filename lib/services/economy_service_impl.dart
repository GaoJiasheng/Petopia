import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/game_state.dart';
import 'clock_service.dart';
import 'economy_service.dart';
import 'log_port.dart';

/// EconomyService 实现（spec-technical §3.8 / §4.2）。
///
/// 暖绒收支唯一入口，写 CurrencyLog（INV-4：balance==Σdelta；balance≥0 不透支）。
/// 发奖写**稳定 ref**（grad:/ach:/levelup:）以支持 spec-cloudsave 幂等去重。
class EconomyServiceImpl implements EconomyService {
  final AuditLogPort _port;
  final CurrencyWallet _wallet;
  final YardState _yard;
  final ClockService _clock;
  final String Function() _idGen;

  /// 毕业结算所需计数与物种类别（注入便于测试；生产接 event_log/visitor_log/ContentRepository）。
  final int Function(String petId) _eventCountOf;
  final int Function(String petId) _visitorInteractionCountOf;
  final bool Function(String speciesId) _isFantasySpecies;
  final ShopInventory _inventory;

  EconomyServiceImpl(
    this._port,
    this._wallet,
    this._yard,
    this._clock,
    this._idGen,
    this._eventCountOf,
    this._visitorInteractionCountOf,
    this._isFantasySpecies, [
    ShopInventory? inventory,
  ]) : _inventory = inventory ?? ShopInventory();

  @override
  int get balance => _wallet.balance;

  @override
  void earn(int amount, CurrencyReason reason, {String? ref}) {
    assert(amount > 0, 'earn amount 必须 > 0');
    if (amount <= 0) return;
    _wallet.balance += amount;
    _writeLog(amount, reason, ref);
  }

  @override
  bool spend(int amount, CurrencyReason reason, {String? ref}) {
    assert(amount > 0);
    if (amount <= 0) return true;
    if (_wallet.balance < amount) return false; // 不透支
    _wallet.balance -= amount;
    _writeLog(-amount, reason, ref);
    return true;
  }

  @override
  int settleGraduation(Pet pet) {
    final events = _eventCountOf(pet.id);
    final visitors = _visitorInteractionCountOf(pet.id);
    int fluff = GameConfig.gradBaseFluff;
    fluff += _min(
      events * GameConfig.gradPerEventFluff,
      GameConfig.gradEventCapFluff,
    );
    fluff += _min(
      visitors * GameConfig.gradPerVisitorFluff,
      GameConfig.gradVisitorCapFluff,
    );
    if (_isFantasySpecies(pet.speciesId)) {
      fluff += GameConfig.gradEasterEggBonus;
    }
    earn(fluff, CurrencyReason.graduation, ref: 'grad:${pet.id}'); // 稳定 ref
    return fluff;
  }

  @override
  PurchaseResult purchase(ShopItem item) {
    if (!item.consumable && _isOwned(item)) {
      return const PurchaseResult(success: false, failReason: 'already_owned');
    }
    final purchaseQuote = quote(item);
    if (!spend(
      purchaseQuote.price,
      CurrencyReason.shopPurchase,
      ref: item.id,
    )) {
      return const PurchaseResult(
        success: false,
        failReason: 'insufficient_balance',
      );
    }
    final couponId = purchaseQuote.couponId;
    if (couponId != null) _inventory.ownedCouponIds.remove(couponId);
    _applyEffect(item);
    return const PurchaseResult(success: true);
  }

  @override
  PurchaseQuote quote(ShopItem item) {
    if (item.effect.type != EffectType.themeSkin) {
      return PurchaseQuote(price: item.price);
    }
    final themeId = item.effect.params['themeId'] as String?;
    final candidates = <({String id, double multiplier, String label})>[];
    void add(
      String id,
      double multiplier,
      String label, {
      String? requiredTheme,
    }) {
      if (!_inventory.ownedCouponIds.contains(id)) return;
      if (requiredTheme != null && themeId != requiredTheme) return;
      candidates.add((id: id, multiplier: multiplier, label: label));
    }

    add(
      'theme_four_seasons_garden_50',
      0.5,
      '四季花园 5 折券',
      requiredTheme: 'four_seasons',
    );
    add(
      'theme_candy_bakery_80',
      0.8,
      '糖果焙房 8 折券',
      requiredTheme: 'candy_bakery',
    );
    add('any_theme_50', 0.5, '任意主题 5 折券');
    if (candidates.isEmpty) return PurchaseQuote(price: item.price);
    candidates.sort((a, b) => a.multiplier.compareTo(b.multiplier));
    final selected = candidates.first;
    return PurchaseQuote(
      price: (item.price * selected.multiplier).round(),
      couponId: selected.id,
      couponLabel: selected.label,
    );
  }

  void _applyEffect(ShopItem item) {
    final e = item.effect;
    switch (e.type) {
      case EffectType.themeSkin:
        final id = e.params['themeId'] as String?;
        if (id != null && !_yard.ownedThemeIds.contains(id)) {
          _yard.ownedThemeIds.add(id);
        }
      case EffectType.decor:
        final id = e.params['decorId'] as String?;
        if (id != null && !_yard.ownedDecorIds.contains(id)) {
          _yard.ownedDecorIds.add(id);
        }
      case EffectType.toyPermanentBonus:
        if (!_yard.ownedPerks.contains(item.id)) _yard.ownedPerks.add(item.id);
      case EffectType.feedBonus:
        _addConsumable(item);
      case EffectType.albumSkin:
        final id = e.params['skinId'] as String?;
        if (id != null) {
          _inventory.ownedAlbumSkinIds.add(id);
          _inventory.activeAlbumSkinId = id;
        }
      case EffectType.visitorProb:
        _addConsumable(item);
        final scope = e.params['scope'] as String?;
        final delta = (e.params['delta'] as num?)?.toDouble() ?? 0;
        _inventory.activeVisitorFoodItemId = item.id;
        _yard.foodTray
          ..foodType = _foodType(item.id)
          ..placedAt = _clock.now()
          ..probabilityScope = scope
          ..probabilityDelta = delta
          ..remaining = _inventory.consumables[item.id] ?? 0;
    }
  }

  bool _isOwned(ShopItem item) {
    return switch (item.effect.type) {
      EffectType.themeSkin => _yard.ownedThemeIds.contains(
        item.effect.params['themeId'],
      ),
      EffectType.decor => _yard.ownedDecorIds.contains(
        item.effect.params['decorId'],
      ),
      EffectType.toyPermanentBonus => _yard.ownedPerks.contains(item.id),
      EffectType.albumSkin => _inventory.ownedAlbumSkinIds.contains(
        item.effect.params['skinId'],
      ),
      EffectType.feedBonus || EffectType.visitorProb => false,
    };
  }

  void _addConsumable(ShopItem item) {
    final amount = item.stackCount ?? 1;
    _inventory.consumables[item.id] =
        (_inventory.consumables[item.id] ?? 0) + amount;
  }

  String? _foodType(String itemId) {
    if (itemId.contains('grain')) return 'grain';
    if (itemId.contains('fish')) return 'fishdry';
    if (itemId.contains('nut')) return 'nuts';
    if (itemId.contains('apple')) return 'apple';
    return null;
  }

  void _writeLog(int delta, CurrencyReason reason, String? ref) {
    _port.insertCurrency(
      CurrencyLog(
        id: _idGen(),
        timestamp: _clock.now(),
        delta: delta,
        reason: reason,
        ref: ref,
        balanceAfter: _wallet.balance,
      ),
    );
  }

  int _min(int a, int b) => a < b ? a : b;
}
