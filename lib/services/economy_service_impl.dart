import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/yard.dart';
import '../domain/models/content_entities.dart';
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

  EconomyServiceImpl(
    this._port,
    this._wallet,
    this._yard,
    this._clock,
    this._idGen,
    this._eventCountOf,
    this._visitorInteractionCountOf,
    this._isFantasySpecies,
  );

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
    fluff += _min(events * GameConfig.gradPerEventFluff, GameConfig.gradEventCapFluff);
    fluff += _min(visitors * GameConfig.gradPerVisitorFluff, GameConfig.gradVisitorCapFluff);
    if (_isFantasySpecies(pet.speciesId)) fluff += GameConfig.gradEasterEggBonus;
    earn(fluff, CurrencyReason.graduation, ref: 'grad:${pet.id}'); // 稳定 ref
    return fluff;
  }

  @override
  PurchaseResult purchase(ShopItem item) {
    if (!spend(item.price, CurrencyReason.shopPurchase, ref: item.id)) {
      return const PurchaseResult(success: false, failReason: 'insufficient_balance');
    }
    _applyEffect(item);
    return const PurchaseResult(success: true);
  }

  void _applyEffect(ShopItem item) {
    final e = item.effect;
    switch (e.type) {
      case EffectType.themeSkin:
        final id = e.params['themeId'] as String?;
        if (id != null && !_yard.ownedThemeIds.contains(id)) _yard.ownedThemeIds.add(id);
      case EffectType.decor:
        final id = e.params['decorId'] as String?;
        if (id != null && !_yard.ownedDecorIds.contains(id)) _yard.ownedDecorIds.add(id);
      case EffectType.toyPermanentBonus:
        if (!_yard.ownedPerks.contains(item.id)) _yard.ownedPerks.add(item.id);
      case EffectType.feedBonus:
      case EffectType.albumSkin:
      case EffectType.visitorProb:
        // 背包(消耗品)/相册皮肤/概率加成的落地在各自系统处理。
        break; // [待细化]
    }
  }

  void _writeLog(int delta, CurrencyReason reason, String? ref) {
    _port.insertCurrency(CurrencyLog(
      id: _idGen(),
      timestamp: _clock.now(),
      delta: delta,
      reason: reason,
      ref: ref,
      balanceAfter: _wallet.balance,
    ));
  }

  int _min(int a, int b) => a < b ? a : b;
}
