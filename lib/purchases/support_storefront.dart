import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'support_catalog.dart';

class SupportOffer {
  const SupportOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.displayPrice,
  });

  final String id;
  final String title;
  final String description;
  final String displayPrice;
}

class SupportOfferQuery {
  const SupportOfferQuery({
    required this.offers,
    this.notFoundIds = const <String>{},
    this.error,
    this.simulated = false,
  });

  final List<SupportOffer> offers;
  final Set<String> notFoundIds;
  final String? error;
  final bool simulated;
}

/// In-memory storefront used only by explicitly flagged internal builds.
///
/// It emits the same transaction shapes as StoreKit, allowing the production
/// controller, persistence, gift-opening, and entitlement paths to run
/// unchanged without initiating a payment.
class SimulatedSupportStorefront implements SupportStorefront {
  SimulatedSupportStorefront({
    this.transactionDelay = const Duration(milliseconds: 650),
  });

  final Duration transactionDelay;
  final _transactions = StreamController<List<SupportTransaction>>.broadcast();
  var _sequence = 0;
  var _disposed = false;
  var _guardianPurchased = false;

  @override
  Stream<List<SupportTransaction>> get transactions => _transactions.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SupportOfferQuery> queryOffers(Set<String> productIds) async {
    final offers = <SupportOffer>[];
    final notFoundIds = <String>{};
    for (final productId in productIds) {
      final product = SupportCatalog.byId(productId);
      if (product == null) {
        notFoundIds.add(productId);
        continue;
      }
      offers.add(
        SupportOffer(
          id: product.id,
          title: product.title,
          description: product.subtitle,
          displayPrice: product.fallbackPrice,
        ),
      );
    }
    return SupportOfferQuery(
      offers: offers,
      notFoundIds: notFoundIds,
      simulated: true,
    );
  }

  @override
  Future<bool> buy(String productId, {required bool consumable}) async {
    if (SupportCatalog.byId(productId) == null || _disposed) return false;
    _sequence += 1;
    final purchaseId =
        'simulated-${DateTime.now().microsecondsSinceEpoch}-$_sequence';
    _emit(
      SupportTransaction(
        productId: productId,
        status: SupportTransactionStatus.pending,
        raw: purchaseId,
        verificationData: 'simulated-pending-$purchaseId',
        purchaseId: purchaseId,
      ),
    );
    await Future<void>.delayed(transactionDelay);
    if (_disposed) return false;
    if (!consumable) _guardianPurchased = true;
    _emit(
      SupportTransaction(
        productId: productId,
        status: SupportTransactionStatus.purchased,
        raw: purchaseId,
        verificationData: 'simulated-verified-$purchaseId',
        purchaseId: purchaseId,
        transactionDate: DateTime.now().toUtc().toIso8601String(),
        needsCompletion: true,
      ),
    );
    return true;
  }

  @override
  Future<void> restore() async {
    if (!_guardianPurchased || _disposed) return;
    _sequence += 1;
    final purchaseId = 'simulated-restore-$_sequence';
    _emit(
      SupportTransaction(
        productId: SupportCatalog.guardian.id,
        status: SupportTransactionStatus.restored,
        raw: purchaseId,
        verificationData: 'simulated-restored-$purchaseId',
        purchaseId: purchaseId,
        transactionDate: DateTime.now().toUtc().toIso8601String(),
        needsCompletion: true,
      ),
    );
  }

  @override
  Future<void> complete(SupportTransaction transaction) async {}

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _transactions.close();
  }

  void _emit(SupportTransaction transaction) {
    if (!_disposed) _transactions.add(<SupportTransaction>[transaction]);
  }
}

enum SupportTransactionStatus { pending, purchased, restored, canceled, error }

class SupportTransaction {
  const SupportTransaction({
    required this.productId,
    required this.status,
    required this.raw,
    required this.verificationData,
    this.purchaseId,
    this.transactionDate,
    this.error,
    this.needsCompletion = false,
  });

  final String productId;
  final SupportTransactionStatus status;
  final Object raw;
  final String verificationData;
  final String? purchaseId;
  final String? transactionDate;
  final String? error;
  final bool needsCompletion;
}

abstract interface class SupportStorefront {
  Stream<List<SupportTransaction>> get transactions;

  Future<bool> isAvailable();

  Future<SupportOfferQuery> queryOffers(Set<String> productIds);

  Future<bool> buy(String productId, {required bool consumable});

  Future<void> restore();

  Future<void> complete(SupportTransaction transaction);
}

class InAppPurchaseSupportStorefront implements SupportStorefront {
  InAppPurchaseSupportStorefront({InAppPurchase? purchase})
    : _purchase = purchase ?? InAppPurchase.instance;

  final InAppPurchase _purchase;
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};

  @override
  Stream<List<SupportTransaction>> get transactions =>
      _purchase.purchaseStream.map(
        (purchases) => purchases.map(_mapTransaction).toList(growable: false),
      );

  @override
  Future<bool> isAvailable() => _purchase.isAvailable();

  @override
  Future<SupportOfferQuery> queryOffers(Set<String> productIds) async {
    final response = await _purchase.queryProductDetails(productIds);
    _products
      ..clear()
      ..addEntries(
        response.productDetails.map((product) => MapEntry(product.id, product)),
      );
    return SupportOfferQuery(
      offers: response.productDetails
          .map(
            (product) => SupportOffer(
              id: product.id,
              title: product.title,
              description: product.description,
              displayPrice: product.price,
            ),
          )
          .toList(growable: false),
      notFoundIds: response.notFoundIDs.toSet(),
      error: response.error?.message,
    );
  }

  @override
  Future<bool> buy(String productId, {required bool consumable}) {
    final product = _products[productId];
    if (product == null) {
      throw StateError('Product $productId is not loaded.');
    }
    final param = PurchaseParam(productDetails: product);
    return consumable
        ? _purchase.buyConsumable(purchaseParam: param)
        : _purchase.buyNonConsumable(purchaseParam: param);
  }

  @override
  Future<void> restore() => _purchase.restorePurchases();

  @override
  Future<void> complete(SupportTransaction transaction) {
    return _purchase.completePurchase(transaction.raw as PurchaseDetails);
  }

  SupportTransaction _mapTransaction(PurchaseDetails purchase) {
    return SupportTransaction(
      productId: purchase.productID,
      status: switch (purchase.status) {
        PurchaseStatus.pending => SupportTransactionStatus.pending,
        PurchaseStatus.purchased => SupportTransactionStatus.purchased,
        PurchaseStatus.restored => SupportTransactionStatus.restored,
        PurchaseStatus.canceled => SupportTransactionStatus.canceled,
        PurchaseStatus.error => SupportTransactionStatus.error,
      },
      raw: purchase,
      verificationData: purchase.verificationData.serverVerificationData,
      purchaseId: purchase.purchaseID,
      transactionDate: purchase.transactionDate,
      error: purchase.error?.message,
      needsCompletion: purchase.pendingCompletePurchase,
    );
  }
}
