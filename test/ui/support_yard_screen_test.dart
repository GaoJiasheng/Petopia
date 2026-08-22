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
import 'package:petopia/ui/widgets/sprite_sheet_player.dart';

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
      expect(find.text('自愿支持暖绒小院'), findsOneWidget);
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

  testWidgets('guardian state reveals the daily lantern and thank-you letter', (
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

    expect(find.text('小院守护者已解锁'), findsWidgets);
    expect(find.text('今天的暖灯'), findsOneWidget);
    expect(find.text('免费点亮'), findsOneWidget);
    expect(find.text(r'$2.99'), findsNothing);
    expect(find.text('写给小院守护者'), findsOneWidget);
    expect(find.text('已解锁'), findsOneWidget);
  });

  testWidgets(
    'guardian daily lantern moves from free to used without StoreKit',
    (tester) async {
      final storefront = _UiStorefront();
      addTearDown(storefront.dispose);
      final benefits = const SupportBenefits().apply(
        product: SupportCatalog.guardian,
        transactionKey: 'guardian-daily-ui',
        now: DateTime.now(),
      );
      final store = _UiBenefitsStore(benefits);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supportStorefrontProvider.overrideWithValue(storefront),
            supportBenefitsStoreProvider.overrideWithValue(store),
          ],
          child: const MaterialApp(home: SupportYardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('support_free_guardian_lantern')),
      );
      await tester.pumpAndSettle();

      expect(find.text('今天已经点亮'), findsOneWidget);
      expect(find.textContaining('暖灯还会亮约'), findsOneWidget);
      expect(storefront.buyCalls, 0);
      expect(store.value.lastFreeLanternAt, isNotNull);
      expect(store.value.lanternUntil, isNotNull);
    },
  );

  testWidgets(
    'a purchased treat waits until the player opens its hand-painted gift',
    (tester) async {
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
      await tester.pump(const Duration(milliseconds: 40));

      expect(find.text('礼物已经送到，你想什么时候拆开都可以。'), findsOneWidget);
      expect(find.text('有 1 份礼物在这里'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('support_open_treat')),
        findsOneWidget,
      );
      expect(find.text('感谢你的支持'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey<String>('support_open_treat')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('正在拆开礼物'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('support_opening_treat')),
        findsOneWidget,
      );
      tester
          .widget<SpriteSheetPlayer>(
            find.byKey(const ValueKey<String>('support_opening_treat')),
          )
          .onComplete!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('一份心意，慢慢收好'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('support_gift_close')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion opens a saved gift with a quiet fade', (
    tester,
  ) async {
    final storefront = _UiStorefront();
    addTearDown(storefront.dispose);
    final store = _UiBenefitsStore(const SupportBenefits(pendingTreat: 1));
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
          supportBenefitsStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: SupportYardScreen(pet: pet),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('support_open_treat')));
    for (var tick = 0; tick < 6; tick += 1) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(
      find.byKey(const ValueKey<String>('support_gift_opened_reduced_motion')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('support_opening_treat')),
      findsNothing,
    );
    expect(store.value.pendingTreat, 0);
    expect(store.value.treatUntil, isNotNull);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey<String>('support_gift_close')),
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
  var buyCalls = 0;

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
  Future<bool> buy(String productId, {required bool consumable}) async {
    buyCalls += 1;
    return true;
  }

  @override
  Future<void> complete(SupportTransaction transaction) async {}

  @override
  Future<void> restore() async {}

  void emit(SupportTransaction transaction) {
    _controller.add(<SupportTransaction>[transaction]);
  }

  Future<void> dispose() => _controller.close();
}
