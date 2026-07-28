import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';

void main() {
  test('support catalog keeps stable unique product identifiers', () {
    expect(SupportCatalog.ids.length, SupportCatalog.all.length);
    expect(SupportCatalog.guardian.consumable, isFalse);
    expect(
      SupportCatalog.all
          .where((product) => product != SupportCatalog.guardian)
          .every((product) => product.consumable),
      isTrue,
    );
  });

  test('consumable benefits extend from the active expiry', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final first = const SupportBenefits().apply(
      product: SupportCatalog.bouquet,
      transactionKey: 'bouquet-1',
      now: now,
    );
    final second = first.apply(
      product: SupportCatalog.bouquet,
      transactionKey: 'bouquet-2',
      now: now.add(const Duration(days: 1)),
    );

    expect(first.bouquetUntil, now.add(const Duration(days: 7)));
    expect(second.bouquetUntil, now.add(const Duration(days: 14)));
    expect(second.bouquetActive(now.add(const Duration(days: 13))), isTrue);
  });

  test('duplicate transactions are idempotent', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final first = const SupportBenefits().apply(
      product: SupportCatalog.lantern,
      transactionKey: 'lantern-1',
      now: now,
    );
    final duplicate = first.apply(
      product: SupportCatalog.lantern,
      transactionKey: 'lantern-1',
      now: now.add(const Duration(hours: 8)),
    );

    expect(duplicate.lanternUntil, first.lanternUntil);
    expect(duplicate.processedTransactions, first.processedTransactions);
    expect(duplicate.lastSupportedAt, first.lastSupportedAt);
  });

  test('guardian permanently keeps the lantern active', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final benefits = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'guardian-1',
      now: now,
    );

    expect(benefits.guardian, isTrue);
    expect(benefits.lanternActive(now.add(const Duration(days: 9999))), isTrue);
  });

  test('benefits round trip without storing payment details', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final source = const SupportBenefits().apply(
      product: SupportCatalog.treat,
      transactionKey: 'treat-1',
      now: now,
    );
    final restored = SupportBenefits.fromJson(source.toJson());

    expect(restored.treatUntil, source.treatUntil);
    expect(restored.lastProductId, SupportCatalog.treat.id);
    expect(restored.processedTransactions, <String>['treat-1']);
  });
}
