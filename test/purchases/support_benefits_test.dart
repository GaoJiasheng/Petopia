import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_state.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/l10n/english_copy.dart';
import 'package:petopia/l10n/traditional_copy.dart';
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

  test('support copy is factual, bilingual, and never pay-to-progress', () {
    final pressureLanguage = RegExp(
      r'错过|限时优惠|最划算|最受欢迎|没有你|离不开你|等你回来|'
      r'best value|most popular|please come back|need you|without you',
      caseSensitive: false,
    );

    expect(SupportCatalog.treat.duration, const Duration(hours: 24));
    expect(SupportCatalog.lantern.duration, const Duration(hours: 24));
    expect(SupportCatalog.bouquet.duration, const Duration(days: 7));
    expect(SupportCatalog.guardian.duration, isNull);

    for (final product in SupportCatalog.all) {
      for (final value in <String>[
        product.title,
        product.subtitle,
        product.thankYou,
      ]) {
        expect(pressureLanguage.hasMatch(value), isFalse, reason: value);
        final english = EnglishCopy.translate(value);
        expect(english, isNot(value), reason: 'Missing English copy: $value');
        expect(
          RegExp(r'[\u3400-\u9fff]').hasMatch(english),
          isFalse,
          reason: english,
        );
      }
    }

    for (final source in <String>[
      '今天的暖灯',
      '今天也可以点一盏。\n暖灯会亮 24 小时。',
      '免费点亮',
      '今天已经点亮',
      '暖灯亮起来了，愿小院今天也暖暖的。',
      '暖灯暂时没有保存好，稍后再来看看吧。',
      '暖灯还会亮约 3 小时',
      '暖灯还会亮约 2 天',
      '礼物已经送到，你想什么时候拆开都可以。',
      '礼物暂时没有保存好，它还在这里。稍后再拆开吧。',
      '有 2 份礼物在这里',
      '有一份礼物在这里，打开支持小院',
      '拆开一份',
      '一份心意，慢慢收好',
      '正在拆开礼物',
      '不用着急，让它慢慢打开。',
      '收好',
      '一份小点心正在慢慢拆开',
    ]) {
      expect(EnglishCopy.translate(source), isNot(source), reason: source);
      expect(TraditionalCopy.translate(source), isNot(source), reason: source);
    }
  });

  test('consumables wait unopened and extend only when opened', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final firstPurchase = const SupportBenefits().apply(
      product: SupportCatalog.bouquet,
      transactionKey: 'bouquet-1',
      now: now,
    );
    final first = firstPurchase.openGift(
      product: SupportCatalog.bouquet,
      now: now,
    );
    final secondPurchase = first.apply(
      product: SupportCatalog.bouquet,
      transactionKey: 'bouquet-2',
      now: now.add(const Duration(days: 1)),
    );
    final second = secondPurchase.openGift(
      product: SupportCatalog.bouquet,
      now: now.add(const Duration(days: 1)),
    );

    expect(firstPurchase.bouquetUntil, isNull);
    expect(firstPurchase.pendingBouquet, 1);
    expect(first.bouquetUntil, now.add(const Duration(days: 7)));
    expect(first.pendingBouquet, 0);
    expect(secondPurchase.bouquetUntil, first.bouquetUntil);
    expect(secondPurchase.pendingBouquet, 1);
    expect(second.bouquetUntil, now.add(const Duration(days: 14)));
    expect(second.pendingBouquet, 0);
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

    expect(duplicate.pendingLantern, 1);
    expect(duplicate.lanternUntil, isNull);
    expect(duplicate.processedTransactions, first.processedTransactions);
    expect(duplicate.lastSupportedAt, first.lastSupportedAt);
  });

  test('guardian lantern is active only while its duration remains', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final benefits = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'guardian-1',
      now: now,
    );

    expect(benefits.guardian, isTrue);
    expect(benefits.lanternActive(now), isFalse);
    final lit = benefits.lightFreeLantern(now);
    expect(lit.lanternActive(now.add(const Duration(hours: 23))), isTrue);
    expect(lit.lanternActive(now.add(const Duration(hours: 24))), isFalse);
  });

  test('guardian gets one free lantern per local calendar day', () {
    final firstDay = DateTime(2026, 8, 22, 23, 55);
    final nextDay = DateTime(2026, 8, 23, 0, 5);
    final guardian = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'guardian-daily',
      now: firstDay,
    );

    final first = guardian.lightFreeLantern(firstDay);
    final duplicate = first.lightFreeLantern(
      firstDay.add(const Duration(minutes: 3)),
    );
    final second = duplicate.lightFreeLantern(nextDay);

    expect(first.canLightFreeLantern(firstDay), isFalse);
    expect(identical(duplicate, first), isTrue);
    expect(first.canLightFreeLantern(nextDay), isTrue);
    expect(second.lastFreeLanternAt, nextDay);
    expect(
      second.lanternUntil,
      first.lanternUntil!.add(const Duration(days: 1)),
    );
  });

  test('non-guardian cannot use the free lantern', () {
    final now = DateTime(2026, 8, 22, 12);
    const benefits = SupportBenefits();

    expect(benefits.canLightFreeLantern(now), isFalse);
    expect(identical(benefits.lightFreeLantern(now), benefits), isTrue);
  });

  test('benefits round trip without storing payment details', () {
    final now = DateTime.utc(2026, 7, 27, 12);
    final source = const SupportBenefits().apply(
      product: SupportCatalog.treat,
      transactionKey: 'treat-1',
      now: now,
    );
    final restored = SupportBenefits.fromJson(source.toJson());

    expect(restored.treatUntil, isNull);
    expect(restored.pendingTreat, 1);
    expect(restored.lastProductId, SupportCatalog.treat.id);
    expect(restored.processedTransactions, <String>['treat-1']);
  });

  test(
    'free lantern timestamp round trips and old saves remain compatible',
    () {
      final now = DateTime(2026, 8, 22, 19, 30);
      final source = const SupportBenefits()
          .apply(
            product: SupportCatalog.guardian,
            transactionKey: 'guardian-roundtrip',
            now: now,
          )
          .lightFreeLantern(now);

      final restored = SupportBenefits.fromJson(source.toJson());
      final legacy = SupportBenefits.fromJson(<String, Object?>{
        'version': 1,
        'guardian': true,
        'processedTransactions': <String>['legacy-guardian'],
      });

      expect(restored.lastFreeLanternAt, source.lastFreeLanternAt!.toUtc());
      expect(restored.lanternUntil, source.lanternUntil!.toUtc());
      expect(legacy.lastFreeLanternAt, isNull);
      expect(legacy.canLightFreeLantern(now), isTrue);
    },
  );

  test('version 3 pending gifts round trip and malformed values are safe', () {
    final restored = SupportBenefits.fromJson(<String, Object?>{
      'version': 3,
      'pendingTreat': 2,
      'pendingLantern': -4,
      'pendingBouquet': 'many',
    });
    final legacy = SupportBenefits.fromJson(<String, Object?>{
      'version': 2,
      'guardian': false,
    });

    expect(restored.pendingTreat, 2);
    expect(restored.pendingLantern, 0);
    expect(restored.pendingBouquet, 0);
    expect(restored.pendingGiftCount, 2);
    expect(legacy.pendingGiftCount, 0);
    expect(restored.toJson()['version'], 3);
  });

  test('opening without inventory is a no-op', () {
    const benefits = SupportBenefits();
    expect(
      identical(
        benefits.openGift(
          product: SupportCatalog.treat,
          now: DateTime.utc(2026, 8, 22),
        ),
        benefits,
      ),
      isTrue,
    );
  });

  test('file store persists and restores the free lantern date', () async {
    final directory = await Directory.systemTemp.createTemp(
      'hearth-tails-support-benefits-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final store = FileSupportBenefitsStore(
      supportDirectory: () async => directory,
    );
    final now = DateTime(2026, 8, 22, 19, 30);
    final source = const SupportBenefits()
        .apply(
          product: SupportCatalog.guardian,
          transactionKey: 'guardian-file-roundtrip',
          now: now,
        )
        .lightFreeLantern(now);

    await store.save(source);
    final restored = await store.load();

    expect(restored.lastFreeLanternAt, source.lastFreeLanternAt!.toUtc());
    expect(restored.lanternUntil, source.lanternUntil!.toUtc());
    expect(restored.canLightFreeLantern(now), isFalse);
  });

  test('free lantern leaves every gameplay value unchanged', () {
    final now = DateTime(2026, 8, 22, 12);
    final session = GameSession(
      current: Pet(
        id: 'pet-1',
        speciesId: 'pet_cat',
        variantId: 'pet_cat_var01',
        name: '小橘',
        personality: <String>['p_gentle', 'p_curious'],
        bornAt: now.toUtc(),
        lastOnlineAt: now.toUtc(),
        offlineDayKey: '2026-08-22',
        exp: 317,
        level: 6,
        stage: PetStage.b,
        state: PetState.raising,
      ),
      wallet: CurrencyWallet(balance: 428),
    );
    session.careLedger.lastAt['feed'] = now.subtract(
      const Duration(minutes: 4),
    );
    const visitorProbability = 0.18;
    Map<String, Object?> snapshot() => <String, Object?>{
      'petExp': session.current!.exp,
      'warmfluff': session.wallet.balance,
      'cooldowns': Map<String, DateTime>.from(session.careLedger.lastAt),
      'visitorProbability': visitorProbability,
    };
    final before = snapshot();
    final guardian = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'guardian-no-gameplay',
      now: now,
    );

    final lit = guardian.lightFreeLantern(now);
    final opened = const SupportBenefits()
        .apply(
          product: SupportCatalog.treat,
          transactionKey: 'treat-no-gameplay',
          now: now,
        )
        .openGift(product: SupportCatalog.treat, now: now);

    expect(snapshot(), before);
    expect(opened.treatUntil, now.add(const Duration(days: 1)));
    expect(snapshot(), before);
    expect(lit.toJson().keys, isNot(contains('petExp')));
    expect(lit.toJson().keys, isNot(contains('warmfluff')));
    expect(lit.toJson().keys, isNot(contains('cooldowns')));
    expect(lit.toJson().keys, isNot(contains('visitorProbability')));
  });
}
