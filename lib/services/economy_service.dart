import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/content_entities.dart';

/// 购买结果。
class PurchaseResult {
  final bool success;
  final String? failReason; // 如 "insufficient_balance"
  const PurchaseResult({required this.success, this.failReason});
}

class PurchaseQuote {
  final int price;
  final String? couponId;
  final String? couponLabel;

  const PurchaseQuote({required this.price, this.couponId, this.couponLabel});
}

/// EconomyService（spec-technical §3.8）。
///
/// 暖绒收支唯一入口（写 CurrencyLog）、毕业结算、商店购买、发奖。
/// 不变量 INV-4（balance==Σcurrency_log.delta；balance≥0，不透支）。
///
/// 【云同步接线】发奖（成就/毕业/升级）必须写**稳定 ref**以支持
/// spec-cloudsave 的幂等去重（防双设备重复发奖）：
///   成就 `ref="ach:<id>"`、毕业 `ref="grad:<petId>"`、升级 `ref="levelup:<petId>:<level>"`。
abstract interface class EconomyService {
  int get balance;

  /// 收入。amount>0。发奖类务必传稳定 ref（见类注释）。
  void earn(int amount, CurrencyReason reason, {String? ref});

  /// 消费。余额不足返回 false，不透支。
  bool spend(int amount, CurrencyReason reason, {String? ref});

  /// 毕业结算（§4.2 公式，预期 260..380）。返回结算的暖绒。
  int settleGraduation(Pet pet);

  /// 当前实际兑换价；若有适用券，返回最低价且标明将消费的券。
  PurchaseQuote quote(ShopItem item);

  /// 购买：spend(price) 成功后按 ItemEffect.type 应用。
  PurchaseResult purchase(ShopItem item);
}
