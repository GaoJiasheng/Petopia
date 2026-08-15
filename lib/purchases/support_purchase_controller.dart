import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support_benefits.dart';
import 'support_catalog.dart';
import 'support_storefront.dart';

class SupportDelivery {
  const SupportDelivery({
    required this.product,
    required this.sequence,
    this.restored = false,
  });

  final SupportProductSpec product;
  final int sequence;
  final bool restored;
}

class SupportPurchaseState {
  const SupportPurchaseState({
    this.storeAvailable = false,
    this.loadingOffers = true,
    this.offers = const <String, SupportOffer>{},
    this.notFoundIds = const <String>{},
    this.benefits = const SupportBenefits(),
    this.busyProductId,
    this.restoring = false,
    this.message,
    this.delivery,
  });

  final bool storeAvailable;
  final bool loadingOffers;
  final Map<String, SupportOffer> offers;
  final Set<String> notFoundIds;
  final SupportBenefits benefits;
  final String? busyProductId;
  final bool restoring;
  final String? message;
  final SupportDelivery? delivery;

  SupportPurchaseState copyWith({
    bool? storeAvailable,
    bool? loadingOffers,
    Map<String, SupportOffer>? offers,
    Set<String>? notFoundIds,
    SupportBenefits? benefits,
    String? busyProductId,
    bool clearBusyProduct = false,
    bool? restoring,
    String? message,
    bool clearMessage = false,
    SupportDelivery? delivery,
  }) {
    return SupportPurchaseState(
      storeAvailable: storeAvailable ?? this.storeAvailable,
      loadingOffers: loadingOffers ?? this.loadingOffers,
      offers: offers ?? this.offers,
      notFoundIds: notFoundIds ?? this.notFoundIds,
      benefits: benefits ?? this.benefits,
      busyProductId: clearBusyProduct
          ? null
          : busyProductId ?? this.busyProductId,
      restoring: restoring ?? this.restoring,
      message: clearMessage ? null : message ?? this.message,
      delivery: delivery ?? this.delivery,
    );
  }
}

final supportStorefrontProvider = Provider<SupportStorefront>(
  (_) => InAppPurchaseSupportStorefront(),
);

final supportBenefitsStoreProvider = Provider<SupportBenefitsStore>(
  (_) => FileSupportBenefitsStore(),
);

class SupportPurchaseController extends AsyncNotifier<SupportPurchaseState> {
  late final SupportStorefront _storefront;
  late final SupportBenefitsStore _benefitsStore;
  late SupportPurchaseState _model;
  StreamSubscription<List<SupportTransaction>>? _subscription;
  Timer? _expiryTimer;
  Future<void> _transactionTail = Future<void>.value();
  var _ready = false;
  var _deliverySequence = 0;

  @override
  Future<SupportPurchaseState> build() async {
    _storefront = ref.read(supportStorefrontProvider);
    _benefitsStore = ref.read(supportBenefitsStoreProvider);
    final benefits = await _benefitsStore.load();
    _model = SupportPurchaseState(benefits: benefits);
    _subscription = _storefront.transactions.listen(
      (transactions) {
        _transactionTail = _transactionTail
            .catchError((Object _, StackTrace _) {})
            .then((_) => _handleTransactions(transactions));
      },
      onError: (Object error, StackTrace stackTrace) {
        _setModel(
          _model.copyWith(
            message: 'App Store 暂时没有回应，请稍后再试。',
            clearBusyProduct: true,
            restoring: false,
          ),
        );
      },
    );
    ref.onDispose(() {
      _expiryTimer?.cancel();
      unawaited(_subscription?.cancel());
    });

    try {
      final available = await _storefront.isAvailable();
      if (!available) {
        _model = _model.copyWith(
          storeAvailable: false,
          loadingOffers: false,
          message: '当前设备暂时无法连接 App Store。',
        );
      } else {
        final query = await _storefront.queryOffers(SupportCatalog.ids);
        if (query.error != null) {
          debugPrint('Support storefront offer query failed: ${query.error}');
        }
        _model = _model.copyWith(
          storeAvailable: true,
          loadingOffers: false,
          offers: <String, SupportOffer>{
            for (final offer in query.offers) offer.id: offer,
          },
          notFoundIds: query.notFoundIds,
          message: query.error == null ? null : '商店暂时没有连上，稍后再来看看吧。当前院子不受影响。',
        );
      }
    } on Object {
      _model = _model.copyWith(
        storeAvailable: false,
        loadingOffers: false,
        message: '当前设备暂时无法连接 App Store。',
      );
    }
    _ready = true;
    _scheduleExpiryRefresh();
    return _model;
  }

  Future<void> buy(SupportProductSpec product) async {
    await future;
    if (!_model.storeAvailable ||
        !_model.offers.containsKey(product.id) ||
        _model.busyProductId != null ||
        _model.restoring) {
      return;
    }
    _setModel(_model.copyWith(busyProductId: product.id, clearMessage: true));
    try {
      final started = await _storefront.buy(
        product.id,
        consumable: product.consumable,
      );
      if (!started) {
        _setModel(
          _model.copyWith(message: '购买没有开始，请稍后再试。', clearBusyProduct: true),
        );
      }
    } on Object {
      _setModel(
        _model.copyWith(
          message: '购买没有完成，请检查 App Store 后重试。',
          clearBusyProduct: true,
        ),
      );
    }
  }

  Future<void> restore() async {
    await future;
    if (!_model.storeAvailable ||
        _model.restoring ||
        _model.busyProductId != null) {
      return;
    }
    _setModel(_model.copyWith(restoring: true, clearMessage: true));
    try {
      await _storefront.restore();
      _setModel(
        _model.copyWith(
          restoring: false,
          message: _model.benefits.guardian ? '小院守护者已经恢复。' : '恢复完成，没有找到新的永久权益。',
        ),
      );
    } on Object {
      _setModel(_model.copyWith(restoring: false, message: '暂时无法恢复购买，请稍后再试。'));
    }
  }

  Future<void> _handleTransactions(
    List<SupportTransaction> transactions,
  ) async {
    for (final transaction in transactions) {
      final product = SupportCatalog.byId(transaction.productId);
      if (product == null) {
        if (transaction.needsCompletion) {
          await _storefront.complete(transaction);
        }
        continue;
      }
      switch (transaction.status) {
        case SupportTransactionStatus.pending:
          _setModel(_model.copyWith(busyProductId: product.id));
          continue;
        case SupportTransactionStatus.purchased:
        case SupportTransactionStatus.restored:
          final transactionKey = _transactionKey(transaction);
          final alreadyDelivered = _model.benefits.processedTransactions
              .contains(transactionKey);
          if (!alreadyDelivered) {
            try {
              final nextBenefits = _model.benefits.apply(
                product: product,
                transactionKey: transactionKey,
                now: DateTime.now().toUtc(),
              );
              await _benefitsStore.save(nextBenefits);
              _deliverySequence += 1;
              _setModel(
                _model.copyWith(
                  benefits: nextBenefits,
                  clearBusyProduct: true,
                  restoring: false,
                  clearMessage: true,
                  delivery: SupportDelivery(
                    product: product,
                    sequence: _deliverySequence,
                    restored:
                        transaction.status == SupportTransactionStatus.restored,
                  ),
                ),
              );
              _scheduleExpiryRefresh();
            } on Object {
              _setModel(
                _model.copyWith(
                  message: '心意已经收到，但回礼暂时没有保存好。请保持网络连接后重试。',
                  clearBusyProduct: true,
                  restoring: false,
                ),
              );
              continue;
            }
          } else {
            _setModel(
              _model.copyWith(clearBusyProduct: true, restoring: false),
            );
          }
          break;
        case SupportTransactionStatus.canceled:
          _setModel(
            _model.copyWith(
              message: '购买已取消，没有产生费用。',
              clearBusyProduct: true,
              restoring: false,
            ),
          );
          break;
        case SupportTransactionStatus.error:
          _setModel(
            _model.copyWith(
              message: transaction.error ?? '购买没有完成，请稍后再试。',
              clearBusyProduct: true,
              restoring: false,
            ),
          );
          break;
      }
      if (transaction.needsCompletion &&
          transaction.status != SupportTransactionStatus.pending) {
        try {
          await _storefront.complete(transaction);
        } on Object {
          _setModel(
            _model.copyWith(
              message: 'App Store 正在确认这次支持，权益不会重复发放。',
              clearBusyProduct: true,
              restoring: false,
            ),
          );
        }
      }
    }
  }

  void _scheduleExpiryRefresh() {
    _expiryTimer?.cancel();
    final now = DateTime.now().toUtc();
    final expiries = <DateTime?>[
      _model.benefits.treatUntil,
      if (!_model.benefits.guardian) _model.benefits.lanternUntil,
      _model.benefits.bouquetUntil,
    ].whereType<DateTime>().where((expiry) => expiry.isAfter(now)).toList();
    if (expiries.isEmpty) return;
    expiries.sort();
    _expiryTimer = Timer(
      expiries.first.difference(now) + const Duration(seconds: 1),
      () {
        if (!_ready) return;
        _setModel(_model.copyWith());
        _scheduleExpiryRefresh();
      },
    );
  }

  String _transactionKey(SupportTransaction transaction) {
    final purchaseId = transaction.purchaseId;
    if (purchaseId != null && purchaseId.isNotEmpty) {
      return '${transaction.productId}:$purchaseId';
    }
    final source =
        '${transaction.productId}|${transaction.transactionDate ?? ''}|'
        '${transaction.verificationData}';
    var hash = 0xcbf29ce484222325;
    for (final unit in source.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return '${transaction.productId}:${hash.toRadixString(16)}';
  }

  void _setModel(SupportPurchaseState next) {
    _model = next;
    if (_ready) state = AsyncData(next);
  }
}

final supportPurchaseControllerProvider =
    AsyncNotifierProvider<SupportPurchaseController, SupportPurchaseState>(
      SupportPurchaseController.new,
    );
