import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/yard_home_screen.dart';

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

class _FixtureGameController extends GameController {
  _FixtureGameController(this.fixture);

  final GameView fixture;

  @override
  Future<GameView> build() async => fixture;

  @override
  List<PostcardView> postcards() => const <PostcardView>[];

  @override
  void refreshView() {}

  @override
  Future<bool> feed() async => false;

  @override
  Future<bool> pat() async => false;

  @override
  Future<bool> toy() async => false;

  @override
  Future<bool> bath() async => false;

  @override
  void completeCareTutorial() {}

  @override
  EventResolution? resolveEvent(String id, {int? choiceIndex}) => null;
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
  EventPresentationView? pendingEvent,
  int careTutorialStep = 3,
}) {
  return GameView(
    pet: emptyYard ? null : (pet ?? _pet()),
    wallet: 237,
    luxuryStage: luxuryStage,
    cooldownSec: cooldown,
    dailyMaxed: dailyMaxed,
    canGraduate: canGraduate,
    activeThemeId: theme,
    decorSlots: const <YardSlotView>[],
    activeVisitor: visitor,
    pendingEvent: pendingEvent,
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: careTutorialStep,
    todayYard: careTutorialStep >= 3 ? _today : null,
  );
}

Future<void> _pumpYard(
  WidgetTester tester, {
  required Size size,
  required EdgeInsets safeArea,
  required GameView view,
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey<String>('yard_fixture_${_fixtureSequence++}'),
      overrides: [
        audioServiceProvider.overrideWithValue(_SilentAudio()),
        gameControllerProvider.overrideWith(() => _FixtureGameController(view)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8A15C),
            surface: const Color(0xFFFFFDF7),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('wide luxury composition assets are bundled', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
      manifest.listAssets(),
      containsAll(const [
        'assets/art/world/decor/deco_welcome_bell.png',
        'assets/art/world/decor/deco_arch_flower.png',
        'assets/art/world/decor/deco_tree_seasonal.png',
        'assets/art/world/decor/deco_attic_house.png',
        'assets/art/world/decor/deco_album_shelf.png',
        'assets/art/world/decor/deco_pond_small.png',
        'assets/art/world/decor/deco_mailbox_red.png',
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
    expect(tester.takeException(), isNull);
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

  testWidgets('notebook is a bottom sheet on phone and owns daily context', (
    tester,
  ) async {
    await _pumpYard(
      tester,
      size: const Size(393, 852),
      safeArea: const EdgeInsets.only(top: 59, bottom: 34),
      view: _view(visitor: _visitor()),
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
    expect(find.textContaining('/'), findsNothing);
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
      final backgroundAsset = background.image as AssetImage;
      expect(hud.center.dx, closeTo(size.width / 2, 1));
      expect(action.center.dx, lessThan(size.width / 2));
      if (name.endsWith('landscape')) {
        expect(backgroundAsset.assetName, contains('/themes/wide/'));
      } else {
        expect(backgroundAsset.assetName, isNot(contains('/themes/wide/')));
      }
      expect(find.text('今日院子'), findsNothing);
      expect(tester.takeException(), isNull, reason: '$name overflowed');
    }
    await _disposeYard(tester);
  });

  testWidgets('all six luxury stages remain visible in iPad landscape', (
    tester,
  ) async {
    const size = Size(1366, 1024);
    const minimumDecorCount = <int, int>{1: 3, 2: 4, 3: 5, 4: 6, 5: 6, 6: 6};
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
        final rect = tester.getRect(
          find.byElementPredicate((item) => item == element),
        );
        expect(rect.left, greaterThanOrEqualTo(-0.1));
        expect(rect.top, greaterThanOrEqualTo(-0.1));
        expect(rect.right, lessThanOrEqualTo(size.width + 0.1));
        expect(rect.bottom, lessThanOrEqualTo(size.height + 0.1));
      }
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    }
  });

  testWidgets('portrait iPad keeps the authored luxury overlays', (
    tester,
  ) async {
    const size = Size(1024, 1366);
    for (var stage = 2; stage <= 6; stage++) {
      await _pumpYard(
        tester,
        size: size,
        safeArea: const EdgeInsets.only(top: 24, bottom: 20),
        view: _view(luxuryStage: stage),
      );
      expect(find.byKey(ValueKey('yard_luxury_$stage')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _disposeYard(tester);
    }
  });

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
      ('stage_manager_medium', Size(820, 700)),
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
          .getSemantics(find.byKey(const ValueKey<String>('pet_info_card')))
          .label,
      contains('查看橘团的详情'),
    );

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
