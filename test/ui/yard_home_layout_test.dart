import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/distribution_environment.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/audio/route_audio.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/purchases/support_benefits.dart';
import 'package:petopia/purchases/support_catalog.dart';
import 'package:petopia/purchases/support_purchase_controller.dart';
import 'package:petopia/ui/petopia_theme.dart';
import 'package:petopia/ui/yard_home_screen.dart';

import 'voiceover_audit.dart';

class _SilentAudio implements AudioService {
  @override
  bool get effectsEnabled => false;

  @override
  bool get musicEnabled => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playBgm(Bgm bgm) async {}

  @override
  Future<void> playYardAmbience(YardAmbience ambience) async {}

  @override
  Future<void> pauseForInterruption() async {}

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

class _RecordingAudio extends _SilentAudio {
  final List<Bgm> bgms = <Bgm>[];
  final List<YardAmbience> ambiences = <YardAmbience>[];

  @override
  Future<void> playBgm(Bgm bgm) async {
    bgms.add(bgm);
  }

  @override
  Future<void> playYardAmbience(YardAmbience ambience) async {
    ambiences.add(ambience);
  }
}

class _FixtureGameController extends GameController {
  _FixtureGameController(this.fixture, {this.careFeedback});

  final GameView fixture;

  /// When set, care actions succeed and hand out this feedback once.
  final CareFeedbackView? careFeedback;
  CareFeedbackView? _pendingFeedback;

  Future<bool> _care() async {
    if (careFeedback == null) return false;
    _pendingFeedback = careFeedback;
    return true;
  }

  @override
  CareFeedbackView? takeCareFeedback() {
    final feedback = _pendingFeedback;
    _pendingFeedback = null;
    return feedback;
  }

  @override
  Future<GameView> build() async => fixture;

  @override
  List<PostcardView> postcards() => const <PostcardView>[];

  @override
  void refreshView() {}

  @override
  Future<bool> feed() => _care();

  @override
  Future<bool> pat() => _care();

  @override
  Future<bool> toy() => _care();

  @override
  Future<bool> bath() => _care();

  @override
  void completeCareTutorial() {}

  @override
  Future<void> onAppResumed() async {}

  @override
  Future<void> onAppPaused() async {}

  @override
  EventResolution? resolveEvent(String id, {int? choiceIndex}) => null;
}

class _FixtureSupportPurchaseController extends SupportPurchaseController {
  _FixtureSupportPurchaseController(this.fixture);

  final SupportPurchaseState fixture;

  @override
  Future<SupportPurchaseState> build() async => fixture;
}

var _fixtureSequence = 0;

PetView _pet({int level = 6, int exp = 310, PetStage stage = PetStage.b}) {
  return PetView(
    name: '橘团',
    speciesId: 'pet_cat',
    speciesName: '橘猫',
    variantId: 'pet_cat_v1',
    level: level,
    exp: exp,
    stage: stage,
    personality: const ['贪吃', '活力'],
    bornAt: DateTime.utc(2026, 7, 1),
  );
}

VisitorPresenceView _visitor() {
  return VisitorPresenceView(
    id: 'visitor_calico',
    name: '流浪三花猫',
    rarity: VisitorRarity.uncommon,
    message: '它在花丛边安静地坐了一会儿。',
    arrivedAt: DateTime.utc(2026, 7, 22),
    leavesAt: DateTime.utc(2026, 7, 23),
    arrivalSeen: true,
    interacted: true,
    yardAsset: 'assets/art/world/visitors/visitor_calico_yard.png',
    portraitAsset: 'assets/art/world/visitors/visitor_calico_portrait.png',
  );
}

RevisitorPresenceView _revisitor() {
  return RevisitorPresenceView(
    id: 'pet-graduated',
    name: '云朵',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v1',
    arrivedAt: DateTime.utc(2026, 7, 22),
    leavesAt: DateTime.utc(2026, 7, 23),
    arrivalSeen: true,
    interacted: true,
  );
}

const _today = TodayYardView([
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
]);

GameView _view({
  PetView? pet,
  bool emptyYard = false,
  String theme = 'sakura',
  Map<CareAction, int> cooldown = const {},
  Set<CareAction> dailyMaxed = const {},
  bool canGraduate = false,
  int luxuryStage = 1,
  VisitorPresenceView? visitor,
  RevisitorPresenceView? revisitor,
  EventPresentationView? pendingEvent,
  int careTutorialStep = 3,
  CareAction? preferredAction,
  bool careContented = false,
  List<YardMemoryView> recentMemories = const <YardMemoryView>[],
  List<YardSlotView> decorSlots = const <YardSlotView>[],
  TodayYardView? todayYard = _today,
  bool waterBowlOwned = false,
  Weather weather = Weather.clear,
}) {
  return GameView(
    pet: emptyYard ? null : (pet ?? _pet()),
    wallet: 237,
    luxuryStage: luxuryStage,
    cooldownSec: cooldown,
    dailyMaxed: dailyMaxed,
    canGraduate: canGraduate,
    activeThemeId: theme,
    decorSlots: decorSlots,
    activeVisitor: visitor,
    revisitor: revisitor,
    pendingEvent: pendingEvent,
    weather: weather,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: careTutorialStep,
    todayYard: careTutorialStep >= 3 ? todayYard : null,
    preferredCareAction: preferredAction,
    careContented: careContented,
    recentMemories: recentMemories,
    waterBowlOwned: waterBowlOwned,
  );
}

Future<void> _pumpYard(
  WidgetTester tester, {
  required Size size,
  required EdgeInsets safeArea,
  required GameView view,
  double textScale = 1,
  AudioService? audio,
  bool testFlight = false,
  Locale locale = const Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hans',
  ),
  SupportBenefits supportBenefits = const SupportBenefits(),
  CareFeedbackView? careFeedback,
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey<String>('yard_fixture_${_fixtureSequence++}'),
      overrides: [
        audioServiceProvider.overrideWithValue(audio ?? _SilentAudio()),
        gameControllerProvider.overrideWith(
          () => _FixtureGameController(view, careFeedback: careFeedback),
        ),
        supportPurchaseControllerProvider.overrideWith(
          () => _FixtureSupportPurchaseController(
            SupportPurchaseState(
              loadingOffers: false,
              benefits: supportBenefits,
            ),
          ),
        ),
        isTestFlightProvider.overrideWith((_) async => testFlight),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: PetopiaLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          PetopiaLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorObservers: <NavigatorObserver>[petopiaRouteObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: PetopiaColors.actionAccent,
            surface: PetopiaColors.paper,
          ),
          useMaterial3: true,
        ),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              padding: safeArea,
              viewPadding: safeArea,
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          );
        },
        home: const YardHomeScreen(enableCooldownRefresh: false),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _disposeYard(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.platformDispatcher.clearTextScaleFactorTestValue();
  await tester.binding.setSurfaceSize(null);
}

String? _assetName(ImageProvider<Object> provider) {
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage) return _assetName(provider.imageProvider);
  return null;
}

void main() {
  test('yard daypart refresh includes morning, dusk, and night boundaries', () {
    expect(
      nextYardDaypartBoundary(DateTime(2026, 8, 2, 5, 59)),
      DateTime(2026, 8, 2, 6),
    );
    expect(
      nextYardDaypartBoundary(DateTime(2026, 8, 2, 12)),
      DateTime(2026, 8, 2, 16),
    );
    expect(
      nextYardDaypartBoundary(DateTime(2026, 8, 2, 16)),
      DateTime(2026, 8, 2, 18),
    );
    expect(
      nextYardDaypartBoundary(DateTime(2026, 8, 2, 18)),
      DateTime(2026, 8, 3, 6),
    );
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  test('wide luxury composition assets are bundled', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
      manifest.listAssets(),
      containsAll(const [
        'assets/art/world/decor/deco_welcome_bell.png',
        'assets/art/world/decor/deco_tree_seasonal_spring.webp',
        'assets/art/world/decor/deco_tree_seasonal_summer.webp',
        'assets/art/world/decor/deco_tree_seasonal_autumn.webp',
        'assets/art/world/decor/deco_tree_seasonal_winter.webp',
        'assets/art/world/decor/deco_album_shelf.png',
        'assets/art/world/decor/deco_pond_small.png',
      ]),
    );
  });

  testWidgets('phone yard keeps only the quiet HUD and interaction surface', (
    tester,
  ) async {
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(),
    );

    expect(find.byKey(const ValueKey<String>('pet_info_card')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('care_action_feed')),
      findsOneWidget,
    );
    expect(find.text('今日院子'), findsNothing);
    expect(find.textContaining('今日来客'), findsNothing);
    expect(find.textContaining('性格'), findsNothing);
    expect(find.textContaining('档）'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('testflight_advance_day')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets(
    'active support treat replaces the food bowl without touching the water bowl',
    (tester) async {
      final benefits = SupportBenefits(treatUntil: DateTime.utc(2099, 1, 1));
      for (final size in const <Size>[
        Size(393, 852),
        Size(834, 1194),
        Size(1366, 1024),
      ]) {
        await _pumpYard(
          tester,
          size: size,
          safeArea: const EdgeInsets.only(top: 24, bottom: 20),
          view: _view(waterBowlOwned: true),
          supportBenefits: benefits,
        );

        final treat = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              _assetName(widget.image) == SupportCatalog.treat.assetPath,
        );
        final water = find.byKey(
          const ValueKey<String>('yard_decor_1_water_bowl'),
        );
        expect(treat, findsOneWidget);
        expect(water, findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('yard_decor_1_food_bowl_full')),
          findsNothing,
        );

        final treatRect = tester.getRect(treat);
        final waterRect = tester.getRect(water);
        expect(treatRect.center.dx, lessThan(waterRect.center.dx));
        expect(treatRect.overlaps(waterRect), isFalse);
        expect(
          waterRect.left - treatRect.right,
          greaterThanOrEqualTo(2),
          reason: 'support treat needs a visible gap at $size',
        );
        expect(tester.takeException(), isNull);
      }
      await _disposeYard(tester);
    },
  );

  testWidgets(
    'TestFlight tools build shows the compact day control without overflow',
    (tester) async {
      for (final size in const <Size>[Size(393, 852), Size(834, 1194)]) {
        await _pumpYard(
          tester,
          size: size,
          safeArea: const EdgeInsets.only(top: 59, bottom: 34),
          view: _view(),
          testFlight: true,
        );
        expect(
          find.byKey(const ValueKey<String>('testflight_advance_day')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
      await _disposeYard(tester);
    },
    skip: !testFlightToolsCompiled,
  );

  testWidgets('returning from a secondary route restores yard soundscape', (
    tester,
  ) async {
    final audio = _RecordingAudio();
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(theme: 'sea_breeze'),
      audio: audio,
    );
    final yardBgm = audio.bgms.last;
    final yardAmbience = audio.ambiences.last;
    expect(
      yardBgm,
      isIn(const <Bgm>[Bgm.yardDay, Bgm.yardDusk, Bgm.yardNight]),
    );
    expect(yardAmbience, YardAmbience.seaside);

    final context = tester.element(find.byType(YardHomeScreen));
    audio.bgms.add(Bgm.shop);
    final pushed = Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SizedBox.expand()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    Navigator.of(context).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await pushed;

    expect(audio.bgms.last, yardBgm);
    expect(audio.ambiences.last, yardAmbience);
    await _disposeYard(tester);
  });

  testWidgets('phone states stay composed without persistent status banners', (
    tester,
  ) async {
    final scenarios = <({String name, GameView view})>[
      (
        name: 'phone_cooldown',
        view: _view(
          theme: 'starry_camp',
          cooldown: const {
            CareAction.feed: 654,
            CareAction.pat: 331,
            CareAction.toy: 949,
          },
        ),
      ),
      (
        name: 'phone_visitor',
        view: _view(theme: 'sakura', visitor: _visitor()),
      ),
      (
        name: 'phone_graduation',
        view: _view(
          theme: 'sea_breeze',
          pet: _pet(level: 10, exp: 2600, stage: PetStage.d),
          canGraduate: true,
        ),
      ),
      (
        name: 'phone_empty_yard',
        view: _view(theme: 'four_seasons', emptyYard: true),
      ),
      (
        name: 'phone_tutorial',
        view: _view(theme: 'rain_moss', careTutorialStep: 2),
      ),
    ];

    for (final scenario in scenarios) {
      await _pumpYard(
        tester,
        size: const Size(393, 852),
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: scenario.view,
      );
      expect(
        tester.takeException(),
        isNull,
        reason: '${scenario.name} overflowed',
      );
    }
    await _disposeYard(tester);
  });

  testWidgets('pet and daily visitor keep separate layout lanes', (
    tester,
  ) async {
    for (final size in const <Size>[
      Size(320, 568),
      Size(393, 852),
      Size(834, 1194),
      Size(1194, 834),
      Size(1366, 1024),
    ]) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(theme: 'sakura', visitor: _visitor()),
      );
      final petCanvasRect = tester.getRect(
        find.byKey(const ValueKey<String>('yard_pet_sprite')),
      );
      // Pet art keeps transparent safety margins to protect ears and tails.
      // Compare the painted silhouette estimate, not the full PNG canvas.
      final petRect = petCanvasRect.deflate(petCanvasRect.width * 0.10);
      final visitorRect = tester.getRect(
        find.byKey(const ValueKey<String>('active_visitor')),
      );
      expect(
        petRect.overlaps(visitorRect),
        isFalse,
        reason: 'pet and visitor overlap at ${size.width}x${size.height}',
      );
      expect(tester.takeException(), isNull);
    }
    await _disposeYard(tester);
  });

  testWidgets('notebook is a bottom sheet on phone and owns daily context', (
    tester,
  ) async {
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(
        visitor: _visitor(),
        preferredAction: CareAction.pat,
        recentMemories: <YardMemoryView>[
          YardMemoryView(
            id: 'growth:pet-current:lv6',
            type: 'growth',
            text: '橘团听见门响时，总会第一个跑过去等你。',
            createdAt: DateTime.utc(2026, 7, 22),
          ),
          YardMemoryView(
            id: 'visitor:visitor_calico:1',
            type: 'visitor',
            text: '流浪三花猫离开前又回头看了看橘团。',
            createdAt: DateTime.utc(2026, 7, 23),
          ),
        ],
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(
      find.byKey(const ValueKey<String>('home_notebook_panel')),
      findsOneWidget,
    );
    expect(find.text('今日院子'), findsOneWidget);
    expect(find.text('今天的来客'), findsOneWidget);
    expect(find.text('院子记住的事'), findsOneWidget);
    expect(find.textContaining('流浪三花猫离开前'), findsOneWidget);
    expect(find.textContaining('/'), findsNothing);
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets('English notebook menu keeps complete words on iPhone', (
    tester,
  ) async {
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(),
      locale: const Locale('en'),
    );
    await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('Growth\nJournal'), findsOneWidget);
    expect(find.text('Pet\nCompendium'), findsOneWidget);
    expect(find.text('Visitor\nCompendium'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Garden\nLayout'), findsOneWidget);
    expect(find.textContaining('...'), findsNothing);
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets('unread story task opens its pending story from the notebook', (
    tester,
  ) async {
    const event = EventPresentationView(
      id: 'pending-d01',
      eventId: 'ev_d01',
      title: '窗边的新发现',
      script: '它在窗边发现了一片会晃动的光，认真看了很久。',
      type: EventType.daily,
      expReward: 3,
      currencyReward: 0,
    );
    const today = TodayYardView([
      TodayYardItemView(
        id: 'event:today',
        kind: TodayYardKind.event,
        label: '翻开今天刚写下的新故事',
        completed: false,
      ),
    ]);
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(pendingEvent: event, todayYard: today),
    );

    // Dismiss the automatic presentation. The fixture intentionally keeps the
    // pending event so the notebook path can be exercised in the same session.
    await tester.tap(find.text('记进手账'));
    await tester.pump(const Duration(milliseconds: 320));
    await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('点按阅读'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('today_yard_read_story')),
    );
    await tester.pump(const Duration(milliseconds: 320));

    expect(
      find.byKey(const ValueKey<String>('home_notebook_panel')),
      findsNothing,
    );
    expect(find.text('窗边的新发现'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets('special event renders an illustrated scene on phone and iPad', (
    tester,
  ) async {
    const event = EventPresentationView(
      id: 'pending-s03',
      eventId: 'ev_s03',
      title: '流星雨之夜',
      script: '它仰头守着一颗慢慢划过院子的星星，像是认真替你许了一个愿望。',
      type: EventType.special,
      expReward: 12,
      currencyReward: 8,
      illustrationRef: 'ill_s03',
    );
    for (final size in const [Size(393, 852), Size(1366, 1024)]) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(theme: 'starry_camp', pendingEvent: event),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('流星雨之夜'), findsOneWidget);
      expect(find.text('记进手账'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('记进手账'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await _disposeYard(tester);
  });

  testWidgets('iPad Pro 11 and 13 keep a centered stage in every orientation', (
    tester,
  ) async {
    const sizes = <(String, Size)>[
      ('ipad11_portrait', Size(834, 1194)),
      ('ipad11_landscape', Size(1194, 834)),
      ('ipad13_portrait', Size(1024, 1366)),
      ('ipad13_landscape', Size(1366, 1024)),
    ];
    for (final (name, size) in sizes) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(theme: 'sakura', visitor: _visitor()),
      );
      final hud = tester.getRect(
        find.byKey(const ValueKey<String>('pet_info_card')),
      );
      final action = tester.getRect(
        find.byKey(const ValueKey<String>('care_action_feed')),
      );
      final background = tester.widget<Image>(
        find.byKey(const ValueKey<String>('yard_background')),
      );
      final resizedBackground = background.image as ResizeImage;
      final backgroundAsset = resizedBackground.imageProvider as AssetImage;
      expect(hud.center.dx, closeTo(size.width / 2, 1));
      expect(action.center.dx, lessThan(size.width / 2));
      expect(resizedBackground.width, lessThanOrEqualTo(2732));
      expect(backgroundAsset.assetName, contains('/themes/wide/'));
      expect(find.text('今日院子'), findsNothing);
      expect(tester.takeException(), isNull, reason: '$name overflowed');
    }
    await _disposeYard(tester);
  });

  testWidgets('all six luxury stages remain visible in iPad landscape', (
    tester,
  ) async {
    const size = Size(1366, 1024);
    // Each stage includes its composed scenery plus the pet-side food bowl.
    const minimumDecorCount = <int, int>{1: 3, 2: 4, 3: 5, 4: 6, 5: 7, 6: 8};
    for (var stage = 1; stage <= 6; stage++) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(luxuryStage: stage),
      );
      final decor = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'yard_decor_${stage}_',
            ),
      );
      expect(
        decor,
        findsNWidgets(minimumDecorCount[stage]!),
        reason: 'luxury stage $stage should have a complete wide composition',
      );
      for (final element in decor.evaluate()) {
        final decorKey = (element.widget.key! as ValueKey<String>).value;
        final rect = tester.getRect(
          find.byElementPredicate((item) => item == element),
        );
        expect(
          rect.left,
          greaterThanOrEqualTo(-0.1),
          reason: '$decorKey crosses the left edge: $rect',
        );
        expect(
          rect.top,
          greaterThanOrEqualTo(-0.1),
          reason: '$decorKey crosses the top edge: $rect',
        );
        expect(
          rect.right,
          lessThanOrEqualTo(size.width + 0.1),
          reason: '$decorKey crosses the right edge: $rect',
        );
        expect(
          rect.bottom,
          lessThanOrEqualTo(size.height + 0.1),
          reason: '$decorKey crosses the bottom edge: $rect',
        );
      }
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    }
  });

  testWidgets('portrait iPad shows six distinct graduation compositions', (
    tester,
  ) async {
    const size = Size(1024, 1366);
    for (var stage = 1; stage <= 6; stage++) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(luxuryStage: stage),
      );
      expect(find.byKey(ValueKey('yard_luxury_$stage')), findsNothing);
      final decor = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'yard_decor_${stage}_',
            ),
      );
      expect(decor, findsNWidgets(stage + 2));
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    }
  });

  testWidgets(
    'graduation scenery yields to rear slots and follows theme season',
    (tester) async {
      for (final theme in const [
        'sakura',
        'sea_breeze',
        'autumn_jam',
        'snow_house',
      ]) {
        final season = const {
          'sakura': 'spring',
          'sea_breeze': 'summer',
          'autumn_jam': 'autumn',
          'snow_house': 'winter',
        }[theme]!;
        await _pumpYard(
          tester,
          size: const Size(390, 844),
          safeArea: const EdgeInsets.only(top: 24, bottom: 34),
          view: _view(
            theme: theme,
            luxuryStage: 4,
            decorSlots: const [YardSlotView(pos: 0, itemId: 'night_light')],
          ),
        );
        expect(
          find.byKey(ValueKey('yard_decor_4_tree_seasonal_$season')),
          findsOne,
        );
        expect(find.byKey(const ValueKey('yard_decor_4_pond_small')), findsOne);
        await _disposeYard(tester);
      }
      await _pumpYard(
        tester,
        size: const Size(390, 844),
        safeArea: const EdgeInsets.only(top: 24, bottom: 34),
        view: _view(
          luxuryStage: 6,
          decorSlots: const [
            YardSlotView(pos: 6, itemId: 'album_shelf'),
            YardSlotView(pos: 7, itemId: 'night_light'),
          ],
        ),
      );
      expect(
        find.byKey(const ValueKey('yard_decor_6_tree_seasonal_spring')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('yard_decor_6_pond_small')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('yard_decor_6_album_shelf')), findsOne);
      expect(find.byKey(const ValueKey('yard_decor_6_night_light')), findsOne);
      await _disposeYard(tester);
    },
  );

  testWidgets('iPad notebook opens as a right-side sheet', (tester) async {
    const size = Size(1366, 1024);
    await _pumpYard(
      tester,
      size: size,
      safeArea: const EdgeInsets.only(top: 24, bottom: 20),
      view: _view(theme: 'starry_camp', visitor: _visitor()),
    );
    await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    final panel = tester.getRect(
      find.byKey(const ValueKey<String>('home_notebook_panel')),
    );
    expect(panel.width, lessThanOrEqualTo(430));
    expect(panel.right, closeTo(size.width - 12, 1));
    expect(find.text('今日院子'), findsOneWidget);
    expect(find.text('今天的来客'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets('an open notebook adapts while the iPad window is resized', (
    tester,
  ) async {
    const wideSize = Size(1366, 1024);
    const narrowSize = Size(390, 1024);
    await _pumpYard(
      tester,
      size: wideSize,
      safeArea: const EdgeInsets.only(top: 24, bottom: 20),
      view: _view(theme: 'starry_camp', visitor: _visitor()),
    );
    await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));

    final notebook = find.byKey(const ValueKey<String>('home_notebook_panel'));
    var panel = tester.getRect(notebook);
    expect(panel.width, lessThanOrEqualTo(430));
    expect(panel.right, closeTo(wideSize.width - 12, 1));

    await tester.binding.setSurfaceSize(narrowSize);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    panel = tester.getRect(notebook);
    expect(panel.width, closeTo(narrowSize.width - 24, 1));
    expect(panel.bottom, closeTo(narrowSize.height - 20, 1));
    expect(panel.height, lessThanOrEqualTo(narrowSize.height * 0.82 + 1));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(wideSize);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    panel = tester.getRect(notebook);
    expect(panel.width, lessThanOrEqualTo(430));
    expect(panel.right, closeTo(wideSize.width - 12, 1));
    expect(tester.takeException(), isNull);
    await _disposeYard(tester);
  });

  testWidgets('iPad mini, Split View and Stage Manager resize cleanly', (
    tester,
  ) async {
    const sizes = <(String, Size)>[
      ('ipad_mini_portrait', Size(744, 1133)),
      ('ipad_mini_landscape', Size(1133, 744)),
      ('split_view_one_third', Size(390, 1024)),
      ('split_view_half', Size(683, 1024)),
      ('before_expanded_breakpoint', Size(819, 700)),
      ('stage_manager_medium', Size(820, 700)),
      ('before_side_panel_breakpoint', Size(899, 700)),
      ('side_panel_breakpoint', Size(900, 700)),
      ('stage_manager_wide', Size(1100, 760)),
    ];
    for (final (name, size) in sizes) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(theme: 'wheat_kite', visitor: _visitor()),
      );
      expect(
        find.byKey(const ValueKey<String>('care_action_feed')),
        findsOneWidget,
      );
      expect(
        tester.takeException(),
        isNull,
        reason: '$name overflowed after resize',
      );
    }
    await _disposeYard(tester);
  });

  testWidgets('large accessibility text remains usable on phone and iPad', (
    tester,
  ) async {
    for (final (name, size, safeArea) in const [
      (
        'phone_large_text',
        Size(393, 852),
        EdgeInsets.only(top: 59, bottom: 34),
      ),
      (
        'ipad11_large_text',
        Size(834, 1194),
        EdgeInsets.only(top: 24, bottom: 20),
      ),
    ]) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: safeArea,
        view: _view(),
        textScale: 3.2,
      );
      expect(tester.takeException(), isNull, reason: '$name overflowed');
    }
    await _disposeYard(tester);
  });

  testWidgets('VoiceOver never meets an unnamed image in the yard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const fullYard = <YardSlotView>[
      YardSlotView(pos: 0, itemId: 'mailbox_wood'),
      YardSlotView(pos: 1, itemId: 'wind_chime'),
      YardSlotView(pos: 2, itemId: 'flower_box'),
      YardSlotView(pos: 3, itemId: 'mushroom_bench'),
      YardSlotView(pos: 4, itemId: 'scarecrow'),
      YardSlotView(pos: 5, itemId: 'wind_vane'),
      YardSlotView(pos: 6, itemId: 'album_shelf'),
      YardSlotView(pos: 7, itemId: 'pond_small'),
    ];
    for (final (name, view) in [
      ('standard', _view()),
      ('empty luxury 6', _view(luxuryStage: 6)),
      (
        'full yard with visitors',
        _view(
          visitor: _visitor(),
          revisitor: _revisitor(),
          waterBowlOwned: true,
          luxuryStage: 6,
          decorSlots: fullYard,
        ),
      ),
    ]) {
      for (final (size, locale) in const [
        (
          Size(393, 852),
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        ),
        (Size(1194, 834), Locale('en')),
      ]) {
        await _pumpYard(
          tester,
          size: size,
          safeArea: const EdgeInsets.only(top: 59, bottom: 34),
          view: view,
          locale: locale,
        );
        expect(
          unlabeledImageAssets(tester),
          isEmpty,
          reason:
              '$name $size ${locale.languageCode} has images VoiceOver '
              'reads only as "image"',
        );
        await _disposeYard(tester);
      }
    }

    // Props announce what they are, so the yard can be explored by touch.
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(waterBowlOwned: true, decorSlots: fullYard),
    );
    for (final label in const ['亮闪闪风铃', '稻草人邮差', '小池塘', '饭盆', '陶瓷小水碗']) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    // The wallet button speaks its balance once, not "…, open shop, 237".
    expect(find.bySemanticsLabel('暖绒 237，打开商店'), findsOneWidget);
    await _disposeYard(tester);
    semantics.dispose();
  });

  testWidgets('VoiceOver audit covers transient yard states', (tester) async {
    final semantics = tester.ensureSemantics();
    final arriving = VisitorPresenceView(
      id: 'visitor_fox',
      name: '狐狸小茜',
      rarity: VisitorRarity.rare,
      message: '小茜三招骗到了仓鼠一粒瓜子。',
      arrivedAt: DateTime.utc(2026, 7, 22),
      leavesAt: DateTime.utc(2026, 7, 23),
      arrivalSeen: false,
      interacted: false,
      yardAsset: 'assets/art/world/visitors/visitor_fox_yard.png',
      portraitAsset: 'assets/art/world/visitors/visitor_fox_portrait.png',
    );
    const event = EventPresentationView(
      id: 'pending-s03',
      eventId: 'ev_s03',
      title: '流星雨之夜',
      script: '它仰头守着一颗慢慢划过院子的星星。',
      type: EventType.special,
      expReward: 12,
      currencyReward: 8,
      illustrationRef: 'ill_s03',
    );
    Future<void> audit(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        unlabeledImageAssets(tester),
        isEmpty,
        reason: '$name has images VoiceOver reads only as "image"',
      );
    }

    for (final size in const [Size(393, 852), Size(1194, 834)]) {
      for (final weather in const [Weather.rain, Weather.snow]) {
        await _pumpYard(
          tester,
          size: size,
          safeArea: const EdgeInsets.only(top: 59, bottom: 34),
          view: _view(weather: weather),
        );
        await audit('$size $weather');
        await _disposeYard(tester);
      }
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(visitor: arriving),
      );
      await audit('$size visitor arrival');
      await _disposeYard(tester);

      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(theme: 'starry_camp', pendingEvent: event),
      );
      await audit('$size special event');
      await _disposeYard(tester);

      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(visitor: _visitor()),
        supportBenefits: SupportBenefits(
          treatUntil: DateTime.utc(2099, 1, 1),
          lanternUntil: DateTime.utc(2099, 1, 1),
          bouquetUntil: DateTime.utc(2099, 1, 1),
          pendingTreat: 1,
          lastProductId: 'com.petopia.petopia.support.treat',
        ),
      );
      await audit('$size support gifts');
      await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await audit('$size notebook');
      await _disposeYard(tester);
    }
    semantics.dispose();
  });

  testWidgets('VoiceOver announces each completed care action', (tester) async {
    final semantics = tester.ensureSemantics();
    final announcements = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        final map = message as Map<Object?, Object?>;
        if (map['type'] == 'announce') {
          announcements.add(
            (map['data']! as Map<Object?, Object?>)['message']! as String,
          );
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          ),
    );
    for (final (locale, expected) in const [
      (
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        '它吃得很香，经验 +3',
      ),
      (Locale('en'), '+3 EXP'),
    ]) {
      announcements.clear();
      await _pumpYard(
        tester,
        size: const Size(393, 852),
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(),
        locale: locale,
        careFeedback: const CareFeedbackView(
          message: '它吃得很香',
          expApplied: 3,
          preferred: false,
          contented: false,
        ),
      );
      for (final action in CareAction.values) {
        announcements.clear();
        await tester.tap(find.byKey(ValueKey('care_action_${action.name}')));
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          announcements,
          [contains(expected)],
          reason: '${action.name} (${locale.languageCode}) was not announced',
        );
      }
      // Let the visual feedback bar and pose cue finish before teardown.
      await tester.pump(const Duration(seconds: 5));
      await _disposeYard(tester);
    }
    semantics.dispose();
  });

  testWidgets('core yard interactions expose meaningful accessibility labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(
        visitor: _visitor(),
        revisitor: _revisitor(),
        cooldown: const <CareAction, int>{CareAction.feed: 65},
      ),
    );

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('care_action_feed')))
          .label,
      contains('喂食，1:05后可用'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('active_visitor')))
          .label,
      contains('来客 流浪三花猫'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('active_revisitor')))
          .label,
      contains('回访伙伴 云朵'),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('active_visitor')),
        matching: find.byType(InkResponse),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('active_revisitor')),
        matching: find.byType(InkResponse),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('pet_info_card')))
          .label,
      contains('查看橘团的详情'),
    );

    semantics.dispose();
    await _disposeYard(tester);
  });

  testWidgets(
    'social turnover preserves every selected decor and its visual position',
    (tester) async {
      const selected = <YardSlotView>[
        YardSlotView(pos: 0, itemId: 'night_light'),
        YardSlotView(pos: 1, itemId: 'wind_chime'),
        YardSlotView(pos: 2, itemId: 'flower_box'),
        YardSlotView(pos: 3, itemId: 'mushroom_bench'),
        YardSlotView(pos: 4, itemId: 'scarecrow'),
        YardSlotView(pos: 5, itemId: 'wood_sign'),
        YardSlotView(pos: 6, itemId: 'wind_vane'),
        YardSlotView(pos: 7, itemId: 'pond_small'),
      ];
      await _pumpYard(
        tester,
        size: const Size(393, 852),
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(luxuryStage: 6, decorSlots: selected),
      );
      final originalRects = <String, Rect>{
        for (final itemId in const <String>[
          'night_light',
          'wind_chime',
          'flower_box',
          'mushroom_bench',
          'scarecrow',
          'wood_sign',
          'wind_vane',
          'pond_small',
        ])
          itemId: tester.getRect(
            find.byKey(ValueKey<String>('yard_decor_6_$itemId')),
          ),
      };
      await _disposeYard(tester);

      await _pumpYard(
        tester,
        size: const Size(393, 852),
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(
          luxuryStage: 6,
          decorSlots: selected,
          visitor: _visitor(),
          revisitor: _revisitor(),
        ),
      );

      for (final itemId in const <String>[
        'night_light',
        'wind_chime',
        'flower_box',
        'mushroom_bench',
        'scarecrow',
        'wood_sign',
        'wind_vane',
        'pond_small',
      ]) {
        expect(
          find.byKey(ValueKey<String>('yard_decor_6_$itemId')),
          findsOneWidget,
          reason: '$itemId should remain visible after daily social turnover',
        );
        expect(
          tester.getRect(find.byKey(ValueKey<String>('yard_decor_6_$itemId'))),
          originalRects[itemId],
          reason: '$itemId must remain in its player-selected physical slot',
        );
      }
      expect(find.byKey(const ValueKey<String>('active_visitor')), findsOne);
      expect(find.byKey(const ValueKey<String>('active_revisitor')), findsOne);
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    },
  );

  testWidgets(
    'full yard puts both companions at the pet\'s front sides across viewports',
    (tester) async {
      for (final size in const [
        Size(390, 844),
        Size(440, 956),
        Size(744, 1133),
        Size(1032, 1376),
        Size(1133, 744),
        Size(1376, 1032),
      ]) {
        for (final items in const <List<String>>[
          [
            'night_light',
            'wind_chime',
            'flower_box',
            'mushroom_bench',
            'scarecrow',
            'wind_vane',
            'album_shelf',
            'pond_small',
          ],
          [
            'mailbox_wood',
            'wind_chime',
            'scarecrow',
            'wood_sign',
            'fireplace',
            'wind_vane',
            'album_shelf',
            'night_light',
          ],
        ]) {
          await _pumpYard(
            tester,
            size: size,
            safeArea: const EdgeInsets.only(top: 24, bottom: 34),
            view: _view(
              luxuryStage: 6,
              visitor: _visitor(),
              revisitor: _revisitor(),
              waterBowlOwned: true,
              decorSlots: [
                for (var i = 0; i < items.length; i++)
                  YardSlotView(pos: i, itemId: items[i]),
              ],
            ),
          );
          final pet = tester.getRect(
            find.byKey(const ValueKey('yard_pet_sprite')),
          );
          final bar = tester.getRect(
            find.byKey(const ValueKey('care_action_feed')),
          );
          final props = [
            for (final item in items)
              tester.getRect(find.byKey(ValueKey('yard_decor_6_$item'))),
          ];
          Rect subject(Rect rect) => rect.deflate(rect.shortestSide * .1);
          bool substantial(Rect a, Rect b) {
            final overlap = a.intersect(b);
            if (overlap.width <= 2 || overlap.height <= 2) return false;
            final smaller = a.width * a.height < b.width * b.height
                ? a.width * a.height
                : b.width * b.height;
            return overlap.width * overlap.height > smaller * .025;
          }

          for (var i = 0; i < props.length; i++) {
            if (props[i].bottom > pet.bottom) {
              // Outstretched hands and sign tips remain painted all the way
              // to the crop edge. Keep that whole foreground crop off the
              // pet's face, beyond the general subject-overlap oracle.
              expect(
                props[i].overlaps(subject(pet)),
                isFalse,
                reason: '$size ${items[i]} reaches into the pet silhouette',
              );
            }
            expect(
              substantial(subject(props[i]), subject(pet)),
              isFalse,
              reason: '$size ${items[i]} overlaps pet',
            );
            for (var j = i + 1; j < props.length; j++) {
              expect(
                substantial(subject(props[i]), subject(props[j])),
                isFalse,
                reason:
                    '$size ${items[i]} / ${items[j]} overlap: ${props[i]} / ${props[j]}',
              );
            }
          }
          for (final key in ['active_visitor', 'active_revisitor']) {
            final actor = tester.getRect(find.byKey(ValueKey(key)));
            // 2026-09-18：伙伴从主宠后方改到两侧前方，主宠仍是画面主体。
            expect(
              actor.bottom,
              lessThanOrEqualTo(bar.top - 8),
              reason: '$size $key must stay clear of the care bar',
            );
            expect(
              actor.bottom,
              greaterThan(pet.bottom - pet.width * .1),
              reason: '$size $key should stand at the pet\'s front side',
            );
            expect(
              substantial(
                actor.deflate(actor.width * .1),
                pet.deflate(pet.shortestSide * .1),
              ),
              isFalse,
              reason: '$size $key overlaps the pet',
            );
            expect(
              actor.width,
              greaterThanOrEqualTo(pet.width * .35),
              reason: '$size $key should remain readable in a full yard',
            );
            expect(
              actor.height,
              lessThanOrEqualTo(pet.width * .80),
              reason: '$size $key must not dominate the main pet',
            );
            final subject = actor.deflate(actor.width * .1);
            for (final item in items) {
              final decor = tester.getRect(
                find.byKey(ValueKey('yard_decor_6_$item')),
              );
              final painted = decor.deflate(decor.shortestSide * .1);
              expect(
                decor.overlaps(subject),
                isFalse,
                reason: '$size $item painted edge reaches $key',
              );
              expect(
                painted.overlaps(subject),
                isFalse,
                reason: '$size $item covers $key: $painted / $subject',
              );
              expect(decor.bottom, lessThan(bar.top - 8));
            }
          }
          // 饭盆和水盆放在完整主宠画布下方，不与模型叠加。
          for (final bowl in ['food_bowl_full', 'water_bowl']) {
            final rect = tester.getRect(
              find.byKey(ValueKey('yard_decor_6_$bowl')),
            );
            // 与本组其他重叠检查一致，按绘制主体（去掉 10% 透明边）判断；
            // 矮横屏上盆可以进入宠物脚下的透明边，但不得碰到模型本身。
            expect(
              subject(rect).overlaps(subject(pet)),
              isFalse,
              reason: '$size $bowl overlaps the pet: $rect / $pet',
            );
            // 盆贴在主宠脚下（间距 6pt），最窄的 iPhone 17e 上离操作栏约 6pt；
            // 摆件仍沿用 8pt，盆只要求不碰操作栏。
            expect(
              rect.bottom,
              lessThan(bar.top - 4),
              reason: '$size $bowl touches the care bar: $rect / $bar',
            );
          }
          expect(tester.takeException(), isNull);
          await _disposeYard(tester);
        }
      }
    },
  );

  testWidgets(
    'a deer stays in the foreground without dominating the main pet',
    (tester) async {
      for (final size in const [
        Size(390, 844),
        Size(440, 956),
        Size(744, 1133),
        Size(1032, 1376),
        Size(1133, 744),
        Size(1376, 1032),
      ]) {
        final visitor = VisitorPresenceView(
          id: 'visitor_deer',
          name: '小鹿',
          rarity: VisitorRarity.uncommon,
          message: '',
          arrivedAt: DateTime.utc(2026, 7, 22),
          leavesAt: DateTime.utc(2026, 7, 23),
          arrivalSeen: true,
          interacted: true,
          yardAsset: 'assets/art/world/visitors/visitor_deer_yard.png',
          portraitAsset: 'assets/art/world/visitors/visitor_deer_portrait.png',
        );
        const items = [
          'mailbox_wood',
          'wind_chime',
          'scarecrow',
          'wood_sign',
          'fireplace',
          'wind_vane',
          'album_shelf',
          'night_light',
        ];
        await _pumpYard(
          tester,
          size: size,
          safeArea: const EdgeInsets.only(top: 24, bottom: 34),
          view: _view(
            luxuryStage: 6,
            visitor: visitor,
            revisitor: _revisitor(),
            waterBowlOwned: true,
            decorSlots: [
              for (var i = 0; i < items.length; i++)
                YardSlotView(pos: i, itemId: items[i]),
            ],
          ),
        );
        final pet = tester.getRect(
          find.byKey(const ValueKey('yard_pet_sprite')),
        );
        final deer = tester.getRect(
          find.byKey(const ValueKey('active_visitor')),
        );
        expect(
          deer.bottom,
          greaterThan(pet.bottom - pet.width * .1),
          reason: '$size deer retreats behind the pet: $deer / $pet',
        );
        expect(
          deer.height,
          inInclusiveRange(pet.width * .50, pet.width * .72 + .01),
          reason:
              '$size deer must remain readable and subordinate to the main pet',
        );
        for (final item in items) {
          final decor = tester.getRect(
            find.byKey(ValueKey('yard_decor_6_$item')),
          );
          expect(
            decor.overlaps(deer.deflate(deer.shortestSide * .1)),
            isFalse,
            reason: '$size $item reaches the deer',
          );
        }
        expect(tester.takeException(), isNull);
        await _disposeYard(tester);
      }
    },
  );

  testWidgets('core yard controls meet platform accessibility guidelines', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(visitor: _visitor()),
    );

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

    semantics.dispose();
    await _disposeYard(tester);
  });

  testWidgets(
    'notebook remains usable at the largest accessibility text size',
    (tester) async {
      await _pumpYard(
        tester,
        size: const Size(393, 852),
        safeArea: const EdgeInsets.only(top: 59, bottom: 34),
        view: _view(visitor: _visitor()),
        textScale: 3.2,
      );
      await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
      await tester.pump(const Duration(milliseconds: 380));

      expect(
        find.byKey(const ValueKey<String>('home_notebook_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    },
  );
}
