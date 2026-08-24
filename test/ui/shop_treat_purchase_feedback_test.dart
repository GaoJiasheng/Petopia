import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/ui/shop_screen.dart';

class _RecordingAudio implements AudioService {
  final List<Sfx> played = <Sfx>[];

  @override
  bool get effectsEnabled => true;

  @override
  bool get musicEnabled => true;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pauseForInterruption() async {}

  @override
  Future<void> playBgm(Bgm bgm) async {}

  @override
  Future<void> playYardAmbience(YardAmbience ambience) async {}

  @override
  Future<void> resumeAfterInterruption() async {}

  @override
  Future<void> setEffectsEnabled(bool enabled) async {}

  @override
  Future<void> setMusicEnabled(bool enabled) async {}

  @override
  Future<void> sfx(Sfx s) async {
    played.add(s);
  }

  @override
  Future<void> sting(Sting s) async {}

  @override
  Future<void> visitorVoice(String visitorId) async {}
}

class _ShopFixtureController extends GameController {
  _ShopFixtureController(this.item);

  final ShopItemView item;
  final List<String> purchases = <String>[];

  static final PetView pet = PetView(
    name: '橘团',
    speciesId: 'pet_cat',
    speciesName: '橘猫',
    variantId: 'pet_cat_v1',
    level: 6,
    exp: 310,
    stage: PetStage.b,
    personality: const <String>['贪吃', '活力'],
    bornAt: DateTime.utc(2026, 7, 1),
  );

  static final GameView fixture = GameView(
    pet: pet,
    wallet: 420,
    luxuryStage: 3,
    cooldownSec: const <CareAction, int>{
      CareAction.feed: 420,
      CareAction.bath: 720,
    },
    dailyMaxed: const <CareAction>{},
    canGraduate: false,
    activeThemeId: 'theme_meadow',
    decorSlots: const <YardSlotView>[],
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: 3,
  );

  @override
  Future<GameView> build() async => fixture;

  @override
  List<ShopItemView> shopItems() => <ShopItemView>[item];

  @override
  Future<bool> buy(String itemId) async {
    purchases.add(itemId);
    return true;
  }
}

const _grainBag = ShopItemView(
  id: 'shop_food_grain_bag',
  name: '谷粒袋 ×3 盘',
  category: '特殊食粮',
  artRef: 'assets/runtime/shop/products/shop_food_grain_bag.webp',
  effectType: EffectType.visitorProb,
  effectSummary: '鸟类来客缘分 +80%',
  price: 20,
  originalPrice: 20,
  owned: false,
  affordable: true,
  consumable: true,
);

const _salmonCookie = ShopItemView(
  id: 'shop_feed_salmon_cookie',
  name: '三文鱼小饼干 ×5',
  category: '特殊食粮',
  artRef: 'assets/runtime/shop/products/shop_feed_salmon_cookie.webp',
  effectType: EffectType.feedBonus,
  effectSummary: '下次喂食时自动享用',
  price: 80,
  originalPrice: 80,
  owned: false,
  affordable: true,
  consumable: true,
);

const _bubbleSoap = ShopItemView(
  id: 'shop_feed_bubble_soap',
  name: '泡泡浴皂 ×2',
  category: '特殊食粮',
  artRef: 'assets/runtime/shop/products/shop_feed_bubble_soap.webp',
  effectType: EffectType.feedBonus,
  effectSummary: '下次洗澡时自动使用',
  price: 90,
  originalPrice: 90,
  owned: false,
  affordable: true,
  consumable: true,
);

Future<({_ShopFixtureController controller, _RecordingAudio audio})> _pumpShop(
  WidgetTester tester, {
  required ShopItemView item,
  Size size = const Size(393, 852),
  Locale locale = const Locale('zh', 'CN'),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final controller = _ShopFixtureController(item);
  final audio = _RecordingAudio();
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        gameControllerProvider.overrideWith(() => controller),
        audioServiceProvider.overrideWithValue(audio),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: PetopiaLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          PetopiaLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ShopScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return (controller: controller, audio: audio);
}

Future<void> _buyVisibleItem(WidgetTester tester, String label) async {
  final button = find.text(label).last;
  await tester.scrollUntilVisible(
    button,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 380));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('visitor food purchase shows a real pet tasting celebration', (
    tester,
  ) async {
    final fixture = await _pumpShop(tester, item: _grainBag);

    await _buyVisibleItem(tester, '兑换');

    expect(fixture.controller.purchases, <String>[_grainBag.id]);
    expect(fixture.audio.played, contains(Sfx.feed));
    expect(
      find.byKey(const ValueKey('shop_treat_celebration')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('shop_treat_pet_action')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('shop_treat_product_art_shop_food_grain_bag')),
      findsOneWidget,
    );
    expect(find.text('橘团闻香来尝了一口'), findsOneWidget);
    expect(find.text('来客食粮已摆好'), findsOneWidget);
    expect(find.text('谷粒袋 ×3 盘已经添进来客食盆，来客缘分正在生效。'), findsOneWidget);
    expect(_ShopFixtureController.fixture.pet!.exp, 310);
    expect(_ShopFixtureController.fixture.cooldownSec, const <CareAction, int>{
      CareAction.feed: 420,
      CareAction.bath: 720,
    });
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('shop_treat_continue')));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('pet treat is saved for the next feeding with eat feedback', (
    tester,
  ) async {
    final fixture = await _pumpShop(
      tester,
      item: _salmonCookie,
      size: const Size(1024, 1366),
      locale: const Locale('en'),
    );

    await _buyVisibleItem(tester, 'Get');

    expect(fixture.audio.played, contains(Sfx.feed));
    expect(find.text('橘团 tried a little taste'), findsOneWidget);
    expect(find.text('Treat saved for later'), findsOneWidget);
    expect(
      find.text(
        'Salmon Biscuits ×5 is tucked away and will be enjoyed automatically at the next feeding.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('shop_treat_continue')));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
    'bubble soap uses the bath animation and bath sound on a narrow phone',
    (tester) async {
      final fixture = await _pumpShop(
        tester,
        item: _bubbleSoap,
        size: const Size(320, 568),
      );

      await _buyVisibleItem(tester, '兑换');

      expect(fixture.audio.played, contains(Sfx.bath));
      expect(fixture.audio.played, isNot(contains(Sfx.feed)));
      expect(find.text('橘团先试了试新泡泡'), findsOneWidget);
      expect(find.text('浴皂已经收好'), findsOneWidget);
      expect(find.text('泡泡浴皂 ×2已经收好，下次洗澡时会自动使用。'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('shop_treat_continue')));
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}
