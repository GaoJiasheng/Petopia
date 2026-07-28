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
import 'package:petopia/app/app_info.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';
import 'package:petopia/purchases/support_purchase_controller.dart';
import 'package:petopia/purchases/support_storefront.dart';
import 'package:petopia/ui/achievements_screen.dart';
import 'package:petopia/ui/adopt_screen.dart';
import 'package:petopia/ui/album_screen.dart';
import 'package:petopia/ui/graduation_ceremony_screen.dart';
import 'package:petopia/ui/growth_journal_screen.dart';
import 'package:petopia/ui/onboarding_screen.dart';
import 'package:petopia/ui/pet_detail_screen.dart';
import 'package:petopia/ui/pet_dex_screen.dart';
import 'package:petopia/ui/petopia_theme.dart';
import 'package:petopia/ui/postcard_viewer_screen.dart';
import 'package:petopia/ui/privacy_screen.dart';
import 'package:petopia/ui/settings_screen.dart';
import 'package:petopia/ui/shop_screen.dart';
import 'package:petopia/ui/support_yard_screen.dart';
import 'package:petopia/ui/visitor_dex_screen.dart';
import 'package:petopia/ui/yard_home_screen.dart';

const _capturePrefix = String.fromEnvironment(
  'PETOPIA_CAPTURE_PREFIX',
  defaultValue: 'petopia-english-ui',
);
const _captureBoundaryKey = ValueKey<String>(
  'english_ui_visual_capture_boundary',
);

class _SilentAudio implements AudioService {
  @override
  bool get effectsEnabled => false;

  @override
  bool get musicEnabled => false;

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
  Future<void> sfx(Sfx s) async {}

  @override
  Future<void> sting(Sting s) async {}

  @override
  Future<void> visitorVoice(String visitorId) async {}
}

class _VisualController extends GameController {
  static final pet = PetView(
    name: 'Mochi',
    speciesId: 'pet_rabbit',
    speciesName: '垂耳兔',
    variantId: 'pet_rabbit_var01',
    level: 10,
    exp: 2400,
    stage: PetStage.d,
    personality: const <String>['温柔', '爱幻想'],
    bornAt: DateTime.utc(2026, 7, 1),
  );

  static final postcard = PostcardView(
    id: 'postcard-english-visual',
    petId: 'pet-english-visual',
    journeyId: 'journey-english-visual',
    petName: 'Mochi',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_var01',
    poseHint: 'gaze',
    locationName: '灯塔海湾',
    bodyText:
        'The sea breeze softened the clouds today. I rested beside the '
        'lighthouse and saved a little sunset for you.',
    photoBg: 'pc_bg_lighthouse_bay',
    stampId: 'pc_stamp_lighthouse_bay',
    stickerIds: const <String>['pc_sticker_drift_bottle'],
    sentAt: DateTime.utc(2026, 7, 20),
    seq: 6,
  );

  static final fixture = GameView(
    pet: pet,
    wallet: 420,
    luxuryStage: 4,
    cooldownSec: const <CareAction, int>{CareAction.pat: 248},
    dailyMaxed: const <CareAction>{},
    canGraduate: true,
    activeThemeId: 'sakura',
    decorSlots: const <YardSlotView>[],
    activeVisitor: VisitorPresenceView(
      id: 'visitor_squirrel',
      name: '松鼠栗栗',
      rarity: VisitorRarity.common,
      message: 'Chestnut is quietly enjoying the flowers.',
      arrivedAt: DateTime.utc(2026, 7, 27),
      leavesAt: DateTime.utc(2026, 7, 28),
      arrivalSeen: true,
      interacted: true,
      yardAsset: 'assets/art/world/visitors/visitor_squirrel_yard.png',
      portraitAsset: 'assets/art/world/visitors/visitor_squirrel_portrait.png',
    ),
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: 3,
    todayYard: TodayYardView(<TodayYardItemView>[
      TodayYardItemView(
        id: 'pat',
        kind: TodayYardKind.pat,
        label: '摸摸它，听一会儿呼噜声',
        completed: true,
      ),
      TodayYardItemView(
        id: 'feed',
        kind: TodayYardKind.feed,
        label: '准备一份喜欢的点心',
        completed: false,
      ),
      TodayYardItemView(
        id: 'visitor',
        kind: TodayYardKind.visitor,
        label: '向今天的来客打声招呼',
        completed: true,
      ),
    ]),
    preferredCareAction: CareAction.feed,
    recentMemories: <YardMemoryView>[
      YardMemoryView(
        id: 'memory-1',
        type: 'care',
        text: 'Mochi leaned closer after a gentle pat.',
        createdAt: DateTime.utc(2026, 7, 27),
      ),
    ],
    appLanguage: AppLanguage.en,
  );

  @override
  Future<GameView> build() async => fixture;

  @override
  String get activeAlbumSkinId => 'default';

  @override
  bool get effectsOn => true;

  @override
  bool get eventNotificationsOn => true;

  @override
  bool get hapticsOn => true;

  @override
  bool get musicOn => true;

  @override
  bool get notificationsOn => false;

  @override
  bool get postcardNotificationsOn => true;

  @override
  bool get visitorNotificationsOn => true;

  @override
  List<AlbumSkinView> albumSkins() => const <AlbumSkinView>[
    AlbumSkinView(id: 'default', name: '奶油手账', active: true),
    AlbumSkinView(id: 'paper', name: '牛皮纸', active: false),
  ];

  @override
  List<AdoptChoiceView> adoptChoices() => const <AdoptChoiceView>[
    AdoptChoiceView(
      speciesId: 'pet_cat',
      name: '橘猫',
      category: PetCategory.real,
      baseTone: '慵懒、贪吃、晒太阳',
    ),
    AdoptChoiceView(
      speciesId: 'pet_rabbit',
      name: '垂耳兔',
      category: PetCategory.real,
      baseTone: '软糯、胆小、爱啃',
    ),
    AdoptChoiceView(
      speciesId: 'pet_uni',
      name: '独角兔尼可',
      category: PetCategory.fantasy,
      baseTone: '独角兽幼体',
    ),
  ];

  @override
  List<AchievementView> achievementsView() => const <AchievementView>[
    AchievementView(
      id: 'ach_first_grad',
      name: '第一次目送',
      hidden: false,
      unlocked: true,
      progress: 1,
      target: 1,
      rewardFluff: 50,
      rewardSummary: '暖绒 +50',
      rewardClaimed: true,
    ),
    AchievementView(
      id: 'ach_grad_3',
      name: '小院常客',
      hidden: false,
      unlocked: false,
      progress: 2,
      target: 3,
      rewardFluff: 100,
      rewardSummary: '暖绒 +100 · 纪念收藏',
      rewardClaimed: false,
    ),
    AchievementView(
      id: 'ach_h_midnight',
      name: '？？？',
      hidden: true,
      unlocked: false,
      progress: 3,
      target: 7,
      clueText: '有人在星星最亮时来过。',
      rewardFluff: 40,
      rewardSummary: '暖绒 +40 · 纪念贴纸',
      rewardClaimed: false,
    ),
  ];

  @override
  List<DexEntryView> petDex() => const <DexEntryView>[
    DexEntryView(
      speciesId: 'pet_cat',
      name: '橘猫',
      category: PetCategory.real,
      baseTone: '慵懒、贪吃、晒太阳',
      state: DexState.ownedBefore,
    ),
    DexEntryView(
      speciesId: 'pet_rabbit',
      name: '垂耳兔',
      category: PetCategory.real,
      baseTone: '软糯、胆小、爱啃',
      state: DexState.available,
    ),
    DexEntryView(
      speciesId: 'pet_uni',
      name: '独角兔尼可',
      category: PetCategory.fantasy,
      baseTone: '独角兽幼体',
      state: DexState.lockedKnown,
      hint: '再送 2 只毕业就能遇见它',
    ),
  ];

  @override
  List<VisitorDexView> visitorDex() => <VisitorDexView>[
    VisitorDexView(
      id: 'visitor_squirrel',
      name: '松鼠栗栗',
      rarity: VisitorRarity.common,
      collected: true,
      count: 2,
      firstSeen: DateTime.utc(2026, 7, 21),
      memories: <VisitorMemoryView>[
        VisitorMemoryView(
          date: DateTime.utc(2026, 7, 21),
          petName: 'Mochi',
          script: 'Chestnut shared an acorn and stayed until sunset.',
          expReward: 2,
        ),
      ],
    ),
    VisitorDexView(
      id: 'visitor_calico',
      name: '流浪三花猫',
      rarity: VisitorRarity.uncommon,
      collected: true,
      count: 3,
      firstSeen: DateTime.utc(2026, 7, 20),
      memories: const <VisitorMemoryView>[],
    ),
    VisitorDexView(
      id: 'visitor_owl',
      name: '猫头鹰教授',
      rarity: VisitorRarity.rare,
      collected: true,
      count: 1,
      firstSeen: DateTime.utc(2026, 7, 22),
      memories: const <VisitorMemoryView>[],
    ),
    const VisitorDexView(
      id: 'visitor_night_blob',
      name: '深夜白团子',
      rarity: VisitorRarity.legendary,
      collected: false,
      count: 0,
      memories: <VisitorMemoryView>[],
    ),
  ];

  @override
  List<PostcardView> postcards() => <PostcardView>[
    postcard,
    PostcardView(
      id: 'postcard-english-visual-2',
      petId: 'pet-cat-visual',
      journeyId: 'journey-cat-visual',
      petName: 'Tangerine',
      speciesId: 'pet_cat',
      variantId: 'pet_cat_var01',
      poseHint: 'photo',
      locationName: '旧书坊巷',
      bodyText:
          'I found a sunlit reading nook and thought you would like it here.',
      photoBg: 'pc_bg_oldbook_alley',
      stampId: 'pc_stamp_oldbook_alley',
      stickerIds: const <String>[],
      sentAt: DateTime.utc(2026, 7, 24),
      seq: 3,
    ),
  ];

  @override
  List<TravelPetView> travelAlbum() => <TravelPetView>[
    TravelPetView(
      petId: 'pet-english-visual',
      speciesId: 'pet_rabbit',
      variantId: 'pet_rabbit_var01',
      name: 'Mochi',
      graduatedAt: DateTime.utc(2026, 7, 1),
      stops: 40,
      postcardCount: 6,
      completedStops: 12,
      journeyState: JourneyState.active,
      routeTheme: '海滨',
      nextPostcardAt: DateTime.now().toUtc().add(const Duration(days: 3)),
    ),
  ];

  @override
  List<ShopItemView> shopItems() => const <ShopItemView>[
    ShopItemView(
      id: 'shop_theme_sakura',
      name: '樱花小径',
      category: '院子主题',
      artRef: 'ui_shop_sakura',
      effectType: EffectType.themeSkin,
      effectSummary: '完整更换院子的季节、光影与景色',
      price: 400,
      originalPrice: 400,
      owned: false,
      affordable: true,
      consumable: false,
      themeId: 'sakura',
    ),
    ShopItemView(
      id: 'shop_decor_wind_chime',
      name: '亮闪闪风铃',
      category: '装饰小物',
      artRef: 'ui_shop_wind_chime',
      effectType: EffectType.decor,
      effectSummary: '可自由摆进院子，也可能吸引特别来客',
      price: 180,
      originalPrice: 180,
      owned: true,
      affordable: true,
      consumable: false,
      decorId: 'wind_chime',
    ),
    ShopItemView(
      id: 'shop_feed_salmon_cookie',
      name: '三文鱼小饼干 ×5',
      category: '特殊食粮',
      artRef: 'ui_shop_salmon_cookie',
      effectType: EffectType.feedBonus,
      effectSummary: '下一次使用时，经验提升至 6 点',
      price: 80,
      originalPrice: 80,
      owned: false,
      affordable: true,
      consumable: true,
    ),
  ];

  @override
  Future<List<ExpLogEntry>> growthJournal() async => <ExpLogEntry>[
    ExpLogEntry(
      id: 'log-1',
      petId: 'pet-english-visual',
      timestamp: DateTime.utc(2026, 7, 20),
      sourceType: ExpSource.pat,
      delta: 2,
      levelAt: 8,
      expAfter: 1800,
      note: '摸头',
    ),
    ExpLogEntry(
      id: 'log-2',
      petId: 'pet-english-visual',
      timestamp: DateTime.utc(2026, 7, 21),
      sourceType: ExpSource.feed,
      delta: 3,
      levelAt: 8,
      expAfter: 1803,
      note: '喂食',
    ),
  ];

  @override
  List<YardMemoryView> growthMemories() => <YardMemoryView>[
    YardMemoryView(
      id: 'growth-memory-1',
      type: 'care',
      text: 'Mochi discovered the sunny corner by the fence.',
      createdAt: DateTime.utc(2026, 7, 21),
    ),
  ];

  @override
  void applyAlbumSkin(String skinId) {}

  @override
  void applyTheme(String themeId) {}

  @override
  void completeCareTutorial() {}

  @override
  Future<void> onAppPaused() async {}

  @override
  Future<void> onAppResumed() async {}

  @override
  void refreshView() {}

  @override
  void trackAlbumOpened() {}

  @override
  void trackPostcardRead(String postcardId) {}
}

class _VisualBenefitsStore implements SupportBenefitsStore {
  @override
  Future<SupportBenefits> load() async => const SupportBenefits();

  @override
  Future<void> save(SupportBenefits benefits) async {}
}

class _VisualStorefront implements SupportStorefront {
  final _transactions = StreamController<List<SupportTransaction>>.broadcast();

  @override
  Stream<List<SupportTransaction>> get transactions => _transactions.stream;

  @override
  Future<bool> buy(String productId, {required bool consumable}) async => true;

  @override
  Future<void> complete(SupportTransaction transaction) async {}

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
  Future<void> restore() async {}

  Future<void> dispose() => _transactions.close();
}

class _EnglishHost extends StatelessWidget {
  const _EnglishHost({required this.screen});

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: PetopiaLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        PetopiaLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PetopiaColors.actionAccent,
          brightness: Brightness.light,
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
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: PetopiaColors.actionAccent,
            minimumSize: const Size(48, 48),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ),
      home: screen,
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture and audit the complete English UI', (tester) async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    await tester.pump(const Duration(milliseconds: 700));

    final storefront = _VisualStorefront();
    addTearDown(storefront.dispose);

    Future<void> show(
      String name,
      Widget screen, {
      Duration settle = const Duration(milliseconds: 700),
      Duration wallSettle = const Duration(milliseconds: 250),
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: <Override>[
            gameControllerProvider.overrideWith(_VisualController.new),
            audioServiceProvider.overrideWithValue(_SilentAudio()),
            appInfoProvider.overrideWith(
              (ref) async => const AppInfo(version: '1.0.0', buildNumber: '18'),
            ),
            supportStorefrontProvider.overrideWithValue(storefront),
            supportBenefitsStoreProvider.overrideWithValue(
              _VisualBenefitsStore(),
            ),
          ],
          child: RepaintBoundary(
            key: _captureBoundaryKey,
            child: _EnglishHost(screen: screen),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(settle);
      await Future<void>.delayed(wallSettle);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$name has a UI error');
      _expectNoVisibleHanText(tester, name);
      await _captureVisual(tester, name);
    }

    await show('yard', const YardHomeScreen(enableCooldownRefresh: false));

    await show('onboarding-1', const OnboardingScreen(needsAdoption: true));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 500));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await tester.pump();
    _expectNoVisibleHanText(tester, 'onboarding-2');
    await _captureVisual(tester, 'onboarding-2');
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 500));
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await tester.pump();
    _expectNoVisibleHanText(tester, 'onboarding-3');
    await _captureVisual(tester, 'onboarding-3');

    await show('adoption', const AdoptScreen());
    await show(
      'pet-detail',
      PetDetailScreen(initialPet: _VisualController.pet),
    );
    await show('growth-journal', const GrowthJournalScreen());
    await show('album-postcards', const AlbumScreen());
    await tester.tap(find.text('Traveling Friends'));
    await tester.pump(const Duration(milliseconds: 450));
    _expectNoVisibleHanText(tester, 'album-travel');
    await _captureVisual(tester, 'album-travel');

    await show('pet-compendium', const PetDexScreen());
    await show('visitor-compendium', const VisitorDexScreen());
    await show('achievements', const AchievementsScreen());
    await show('shop', const ShopScreen());

    await show('settings-top', const SettingsScreen());
    await tester.scrollUntilVisible(
      find.text('Saves & Privacy'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));
    _expectNoVisibleHanText(tester, 'settings-bottom');
    await _captureVisual(tester, 'settings-bottom');

    await show('privacy', const PrivacyScreen());
    await show(
      'graduation',
      const GraduationCeremonyScreen(
        petName: 'Mochi',
        speciesId: 'pet_rabbit',
        variantId: 'pet_rabbit_var01',
      ),
    );
    await show(
      'postcard',
      PostcardViewerScreen(card: _VisualController.postcard),
      settle: const Duration(milliseconds: 1800),
      wallSettle: const Duration(milliseconds: 900),
    );
    await show('support', SupportYardScreen(pet: _VisualController.pet));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}

Future<void> _captureVisual(WidgetTester tester, String name) async {
  final captureBoundary = find.byKey(_captureBoundaryKey);
  expect(captureBoundary, findsOneWidget);
  final boundary = tester.renderObject<RenderRepaintBoundary>(captureBoundary);
  final pixelRatio = View.of(tester.element(captureBoundary)).devicePixelRatio;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  expect(data, isNotNull, reason: '$name could not be encoded as PNG');

  final bytes = data!.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  await File('/tmp/$_capturePrefix-$name.png').writeAsBytes(bytes, flush: true);
}

void _expectNoVisibleHanText(WidgetTester tester, String screen) {
  const intentionalNativeLanguageLabels = <String>{'简中'};
  final untranslated = <String>{};
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final value = text.data ?? text.textSpan?.toPlainText() ?? '';
    if (RegExp(r'[\u3400-\u9fff]').hasMatch(value) &&
        !intentionalNativeLanguageLabels.contains(value)) {
      untranslated.add(value);
    }
  }
  expect(
    untranslated,
    isEmpty,
    reason: '$screen still contains untranslated visible text',
  );
}
