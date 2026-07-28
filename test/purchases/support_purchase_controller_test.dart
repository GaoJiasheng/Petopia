import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';
import 'package:petopia/purchases/support_purchase_controller.dart';
import 'package:petopia/purchases/support_storefront.dart';

void main() {
  late _FakeStorefront storefront;
  late _MemoryBenefitsStore benefitsStore;
  late ProviderContainer container;

  setUp(() {
    storefront = _FakeStorefront();
    benefitsStore = _MemoryBenefitsStore();
    container = ProviderContainer(
      overrides: [
        supportStorefrontProvider.overrideWithValue(storefront),
        supportBenefitsStoreProvider.overrideWithValue(benefitsStore),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await storefront.dispose();
  });

  test(
    'purchase delivery is persisted, completed, and not duplicated',
    () async {
      await container.read(supportPurchaseControllerProvider.future);
      await container
          .read(supportPurchaseControllerProvider.notifier)
          .buy(SupportCatalog.treat);
      expect(storefront.lastBoughtId, SupportCatalog.treat.id);

      final transaction = _transaction(
        SupportCatalog.treat.id,
        purchaseId: 'purchase-1',
      );
      storefront.emit(<SupportTransaction>[transaction]);
      await _flush();

      final delivered = container
          .read(supportPurchaseControllerProvider)
          .requireValue;
      final firstExpiry = delivered.benefits.treatUntil;
      expect(firstExpiry, isNotNull);
      expect(delivered.delivery?.product, SupportCatalog.treat);
      expect(storefront.completed, 1);
      expect(benefitsStore.saves, 1);

      storefront.emit(<SupportTransaction>[transaction]);
      await _flush();

      final duplicate = container
          .read(supportPurchaseControllerProvider)
          .requireValue;
      expect(duplicate.benefits.treatUntil, firstExpiry);
      expect(benefitsStore.saves, 1);
      expect(storefront.completed, 2);
    },
  );

  test('restoring guardian grants permanent entitlement', () async {
    await container.read(supportPurchaseControllerProvider.future);
    final restore = container
        .read(supportPurchaseControllerProvider.notifier)
        .restore();
    await _flush();
    storefront.emit(<SupportTransaction>[
      _transaction(
        SupportCatalog.guardian.id,
        purchaseId: 'guardian-restore',
        status: SupportTransactionStatus.restored,
      ),
    ]);
    await restore;
    await _flush();

    final state = container
        .read(supportPurchaseControllerProvider)
        .requireValue;
    expect(state.benefits.guardian, isTrue);
    expect(state.delivery?.restored, isTrue);
    expect(storefront.restoreCalls, 1);
  });

  test('missing App Store products stay disabled', () async {
    storefront.notFoundIds = <String>{SupportCatalog.bouquet.id};
    final state = await container.read(
      supportPurchaseControllerProvider.future,
    );

    expect(state.storeAvailable, isTrue);
    expect(state.notFoundIds, contains(SupportCatalog.bouquet.id));
    expect(state.offers, isNot(contains(SupportCatalog.bouquet.id)));
  });

  test(
    'transaction stays incomplete when local entitlement cannot be saved',
    () async {
      benefitsStore.failWrites = true;
      await container.read(supportPurchaseControllerProvider.future);
      await container
          .read(supportPurchaseControllerProvider.notifier)
          .buy(SupportCatalog.lantern);

      storefront.emit(<SupportTransaction>[
        _transaction(SupportCatalog.lantern.id, purchaseId: 'write-failure'),
      ]);
      await _flush();

      final state = container
          .read(supportPurchaseControllerProvider)
          .requireValue;
      expect(state.benefits.lanternUntil, isNull);
      expect(state.message, contains('回礼暂时没有保存好'));
      expect(storefront.completed, 0);
    },
  );
}

SupportTransaction _transaction(
  String productId, {
  required String purchaseId,
  SupportTransactionStatus status = SupportTransactionStatus.purchased,
}) {
  return SupportTransaction(
    productId: productId,
    status: status,
    raw: Object(),
    verificationData: 'signed-$purchaseId',
    purchaseId: purchaseId,
    transactionDate: '1785144000000',
    needsCompletion: true,
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}

class _MemoryBenefitsStore implements SupportBenefitsStore {
  SupportBenefits value = const SupportBenefits();
  var saves = 0;
  var failWrites = false;

  @override
  Future<SupportBenefits> load() async => value;

  @override
  Future<void> save(SupportBenefits benefits) async {
    if (failWrites) throw const FileSystemException('simulated write failure');
    value = benefits;
    saves += 1;
  }
}

class _FakeStorefront implements SupportStorefront {
  final _controller = StreamController<List<SupportTransaction>>.broadcast();
  Set<String> notFoundIds = <String>{};
  String? lastBoughtId;
  var completed = 0;
  var restoreCalls = 0;

  @override
  Stream<List<SupportTransaction>> get transactions => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SupportOfferQuery> queryOffers(Set<String> productIds) async {
    return SupportOfferQuery(
      offers: <SupportOffer>[
        for (final product in SupportCatalog.all)
          if (!notFoundIds.contains(product.id))
            SupportOffer(
              id: product.id,
              title: product.title,
              description: product.subtitle,
              displayPrice: product.fallbackPrice,
            ),
      ],
      notFoundIds: notFoundIds,
    );
  }

  @override
  Future<bool> buy(String productId, {required bool consumable}) async {
    lastBoughtId = productId;
    return true;
  }

  @override
  Future<void> complete(SupportTransaction transaction) async {
    completed += 1;
  }

  @override
  Future<void> restore() async {
    restoreCalls += 1;
  }

  void emit(List<SupportTransaction> transactions) {
    _controller.add(transactions);
  }

  Future<void> dispose() => _controller.close();
}
