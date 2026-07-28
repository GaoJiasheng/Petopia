import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';
import 'package:petopia/purchases/support_purchase_controller.dart';
import 'package:petopia/purchases/support_storefront.dart';
import 'package:petopia/ui/petopia_theme.dart';
import 'package:petopia/ui/support_yard_screen.dart';

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'support',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render every voluntary-support state on device', (tester) async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    await tester.pump(const Duration(milliseconds: 500));

    final storefront = _VisualStorefront();
    addTearDown(storefront.dispose);
    await _pumpSupport(
      tester,
      storefront: storefront,
      store: _VisualBenefitsStore(),
    );
    await _capture(tester, 'catalog');

    await tester.tap(
      find.byKey(const ValueKey<String>('support_purchase_treat')),
    );
    storefront.emit(
      SupportTransaction(
        productId: SupportCatalog.treat.id,
        status: SupportTransactionStatus.purchased,
        raw: Object(),
        verificationData: 'visual-signed-treat',
        purchaseId: 'visual-treat',
        transactionDate: '1785144000000',
        needsCompletion: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      find.byKey(const ValueKey<String>('pet_action_eat')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await _capture(tester, 'treat-thanks');

    await tester.tap(find.text('收下这份感谢'));
    await tester.pump(const Duration(milliseconds: 500));

    final guardian = const SupportBenefits().apply(
      product: SupportCatalog.guardian,
      transactionKey: 'visual-guardian',
      now: DateTime.utc(2026, 7, 27),
    );
    final guardianStorefront = _VisualStorefront();
    addTearDown(guardianStorefront.dispose);
    await _pumpSupport(
      tester,
      storefront: guardianStorefront,
      store: _VisualBenefitsStore(guardian),
    );
    await _capture(tester, 'guardian-catalog');

    await tester.scrollUntilVisible(
      find.text('写给小院守护者'),
      420,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('写给小院守护者'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('写给小院守护者'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, 'guardian-letter');
  });
}

Future<void> _pumpSupport(
  WidgetTester tester, {
  required _VisualStorefront storefront,
  required _VisualBenefitsStore store,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: <Override>[
        supportStorefrontProvider.overrideWithValue(storefront),
        supportBenefitsStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const <Locale>[Locale('zh', 'CN')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => RepaintBoundary(
          key: const ValueKey<String>('support_visual_boundary'),
          child: child ?? const SizedBox.shrink(),
        ),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: PetopiaColors.actionAccent,
            surface: PetopiaColors.paper,
          ),
          scaffoldBackgroundColor: PetopiaColors.background,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: PetopiaColors.actionAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        home: SupportYardScreen(
          pet: PetView(
            name: '小橘',
            speciesId: 'pet_cat',
            speciesName: '橘猫',
            variantId: 'pet_cat_var01',
            level: 7,
            exp: 320,
            stage: PetStage.c,
            personality: const <String>['p_gentle'],
            bornAt: DateTime.utc(2026, 7, 20),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  expect(find.text('支持小院'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 120));
  final finder = find.byKey(const ValueKey<String>('support_visual_boundary'));
  expect(finder, findsOneWidget);
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  final pixelRatio = View.of(tester.element(finder)).devicePixelRatio;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  expect(
    await _hasSolidDarkBottomBand(image),
    isFalse,
    reason: 'The support-page capture contains a solid dark lower band.',
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = data!.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  final directory = Directory('/tmp/petopia-support-visual')
    ..createSync(recursive: true);
  await File(
    '${directory.path}/$_prefix-$name.png',
  ).writeAsBytes(bytes, flush: true);
}

Future<bool> _hasSolidDarkBottomBand(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return true;
  final bandHeight = (image.height ~/ 50).clamp(8, 80);
  var dark = 0;
  var sampled = 0;
  for (var y = image.height - bandHeight; y < image.height; y += 4) {
    for (var x = 0; x < image.width; x += 8) {
      final offset = (y * image.width + x) * 4;
      if (data.getUint8(offset) < 8 &&
          data.getUint8(offset + 1) < 8 &&
          data.getUint8(offset + 2) < 8) {
        dark += 1;
      }
      sampled += 1;
    }
  }
  return sampled > 0 && dark / sampled > 0.96;
}

class _VisualBenefitsStore implements SupportBenefitsStore {
  _VisualBenefitsStore([this.value = const SupportBenefits()]);

  SupportBenefits value;

  @override
  Future<SupportBenefits> load() async => value;

  @override
  Future<void> save(SupportBenefits benefits) async {
    value = benefits;
  }
}

class _VisualStorefront implements SupportStorefront {
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
