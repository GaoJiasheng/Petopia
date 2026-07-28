import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

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
  });

  final List<SupportOffer> offers;
  final Set<String> notFoundIds;
  final String? error;
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
