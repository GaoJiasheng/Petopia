import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';
import 'package:petopia/purchases/support_purchase_controller.dart';
import 'package:petopia/purchases/support_storefront.dart';
import 'package:petopia/ui/support_yard_screen.dart';

void main() {
  for (final size in <Size>[
    const Size(390, 844),
    const Size(820, 1180),
    const Size(1366, 1024),
  ]) {
    testWidgets('support page is usable at ${size.width}x${size.height}', (
      tester,
    ) async {
      final storefront = _UiStorefront();
      addTearDown(storefront.dispose);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supportStorefrontProvider.overrideWithValue(storefront),
            supportBenefitsStoreProvider.overrideWithValue(_UiBenefitsStore()),
          ],
          child: const MaterialApp(home: SupportYardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('支持小院'), findsOneWidget);
      expect(find.text('自愿支持 Petopia'), findsOneWidget);
      expect(find.text('支持选项'), findsOneWidget);
      expect(find.text(r'$0.99'), findsOneWidget);
      expect(find.text(r'$6.99'), findsOneWidget);
      expect(find.byType(OverflowBar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('support cards remain readable at accessibility text sizes', (
    tester,
  ) async {
    final storefront = _UiStorefront();
    addTearDown(storefront.dispose);
    await tester.binding.setSurfaceSize(const Size(820, 1180));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportStorefrontProvider.overrideWithValue(storefront),
          supportBenefitsStoreProvider.overrideWithValue(_UiBenefitsStore()),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(820, 1180),
              textScaler: TextScaler.linear(3.2),
            ),
            child: SupportYardScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('支持选项'), findsOneWidget);
    expect(find.byType(OverflowBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guardian state reveals the permanent thank-you letter', (
    tester,
  ) async {
    final storefront = _UiStorefront();
    addTearDown(storefront.dispose);
    final benefits = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'guardian',
      now: DateTime.utc(2026, 7, 27),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportStorefrontProvider.overrideWithValue(storefront),
          supportBenefitsStoreProvider.overrideWithValue(
            _UiBenefitsStore(benefits),
          ),
        ],
        child: const MaterialApp(home: SupportYardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('守护灯已点亮'), findsOneWidget);
    expect(find.text('写给小院守护者'), findsOneWidget);
    expect(find.text('已解锁'), findsOneWidget);
  });

  testWidgets('a treat thanks the current pet with its five-second animation', (
    tester,
  ) async {
    final storefront = _UiStorefront();
    addTearDown(storefront.dispose);
    final pet = PetView(
      name: '小橘',
      speciesId: 'pet_cat',
      speciesName: '橘猫',
      variantId: 'pet_cat_var01',
      level: 7,
      exp: 320,
      stage: PetStage.c,
      personality: const <String>['p_gentle'],
      bornAt: DateTime.utc(2026, 7, 20),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportStorefrontProvider.overrideWithValue(storefront),
          supportBenefitsStoreProvider.overrideWithValue(_UiBenefitsStore()),
        ],
        child: MaterialApp(home: SupportYardScreen(pet: pet)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('support_purchase_treat')),
    );
    storefront.emit(
      SupportTransaction(
        productId: SupportCatalog.treat.id,
        status: SupportTransactionStatus.purchased,
        raw: Object(),
        verificationData: 'signed-treat',
        purchaseId: 'treat-animation',
        transactionDate: '1785144000000',
        needsCompletion: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump();

    expect(find.text('感谢你的支持'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('pet_action_eat')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _UiBenefitsStore implements SupportBenefitsStore {
  _UiBenefitsStore([this.value = const SupportBenefits()]);

  SupportBenefits value;

  @override
  Future<SupportBenefits> load() async => value;

  @override
  Future<void> save(SupportBenefits benefits) async {
    value = benefits;
  }
}

class _UiStorefront implements SupportStorefront {
  final _controller = StreamController<List<SupportTransaction>>.broadcast();

  @override
  Stream<List<SupportTransaction>> get transactions => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SupportOfferQuery> queryOffers(Set<String> productIds) async {
    return SupportOfferQuery(
      offers: <SupportOffer>[
        for (final product in SupportCatalog.all)
          SupportOffer(
            id: product.id,
            title: product.title,
            description: product.subtitle,
            displayPrice: product.fallbackPrice,
          ),
      ],
    );
  }

  @override
  Future<bool> buy(String productId, {required bool consumable}) async => true;

  @override
  Future<void> complete(SupportTransaction transaction) async {}

  @override
  Future<void> restore() async {}

  void emit(SupportTransaction transaction) {
    _controller.add(<SupportTransaction>[transaction]);
  }

  Future<void> dispose() => _controller.close();
}
