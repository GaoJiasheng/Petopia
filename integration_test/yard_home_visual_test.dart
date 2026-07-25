import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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

class _VisualGameController extends GameController {
  _VisualGameController(this.fixture);

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

class _VisualApp extends StatelessWidget {
  const _VisualApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A15C),
          surface: const Color(0xFFFFFDF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF3E3),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE8A15C),
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
      home: const YardHomeScreen(enableCooldownRefresh: false),
    );
  }
}

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
  int luxuryStage = 1,
  Map<CareAction, int> cooldown = const {},
  bool canGraduate = false,
  VisitorPresenceView? visitor,
  EventPresentationView? pendingEvent,
  int careTutorialStep = 3,
}) {
  return GameView(
    pet: emptyYard ? null : (pet ?? _pet()),
    wallet: 237,
    luxuryStage: luxuryStage,
    cooldownSec: cooldown,
    dailyMaxed: const {},
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

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'yard',
);
const _landscape = bool.fromEnvironment('PETOPIA_VISUAL_LANDSCAPE');
const _allThemes = bool.fromEnvironment('PETOPIA_VISUAL_ALL_THEMES');
const _allLuxury = bool.fromEnvironment('PETOPIA_VISUAL_ALL_LUXURY');

Future<void> _pumpScenario(WidgetTester tester, GameView view) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        audioServiceProvider.overrideWithValue(_SilentAudio()),
        gameControllerProvider.overrideWith(() => _VisualGameController(view)),
      ],
      child: const _VisualApp(),
    ),
  );
  await tester.pump();
  for (var frame = 0; frame < 18; frame++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
  await Future<void>.delayed(const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 120));
  final bytes = await binding.takeScreenshot('$_prefix-$name');
  final directory = Directory('/tmp/petopia-yard-visual')
    ..createSync(recursive: true);
  File('${directory.path}/$_prefix-$name.png').writeAsBytesSync(bytes);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render every yard home state for visual review', (tester) async {
    if (_landscape) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
    await tester.pump(const Duration(milliseconds: 800));
    final standardScenarios = <({String name, GameView view})>[
      (name: 'standard', view: _view()),
      (
        name: 'cooldown',
        view: _view(
          theme: 'starry_camp',
          cooldown: const {
            CareAction.feed: 654,
            CareAction.pat: 331,
            CareAction.toy: 949,
          },
        ),
      ),
      (name: 'visitor', view: _view(visitor: _visitor())),
      (
        name: 'special-event',
        view: _view(
          theme: 'starry_camp',
          pendingEvent: const EventPresentationView(
            id: 'pending-s03',
            eventId: 'ev_s03',
            title: '流星雨之夜',
            script: '它仰头守着一颗慢慢划过院子的星星，像是认真替你许了一个愿望。',
            type: EventType.special,
            expReward: 12,
            currencyReward: 8,
            illustrationRef: 'ill_s03',
          ),
        ),
      ),
      (
        name: 'graduation',
        view: _view(
          theme: 'sea_breeze',
          pet: _pet(level: 10, exp: 2600, stage: PetStage.d),
          canGraduate: true,
        ),
      ),
      (name: 'empty-yard', view: _view(theme: 'four_seasons', emptyYard: true)),
      (name: 'tutorial', view: _view(theme: 'rain_moss', careTutorialStep: 2)),
    ];
    final themeScenarios = <({String name, GameView view})>[
      (name: 'theme-meadow', view: _view(theme: 'meadow')),
      (name: 'theme-autumnjam', view: _view(theme: 'autumn_jam')),
      (name: 'theme-bambootea', view: _view(theme: 'bamboo_tea')),
      (name: 'theme-candybake', view: _view(theme: 'candy_bakery')),
      (name: 'theme-fourseasons', view: _view(theme: 'four_seasons')),
      (name: 'theme-moongreen', view: _view(theme: 'moonlight')),
      (name: 'theme-mossrain', view: _view(theme: 'rain_moss')),
      (name: 'theme-sakura', view: _view(theme: 'sakura')),
      (name: 'theme-seaside', view: _view(theme: 'sea_breeze')),
      (name: 'theme-snowhut', view: _view(theme: 'snow_house')),
      (name: 'theme-starcamp', view: _view(theme: 'starry_camp')),
      (name: 'theme-wheatkite', view: _view(theme: 'wheat_kite')),
    ];
    final luxuryScenarios = <({String name, GameView view})>[
      for (var stage = 1; stage <= 6; stage++)
        (
          name: 'luxury-$stage',
          view: _view(theme: 'meadow', luxuryStage: stage),
        ),
    ];
    final scenarios = _allThemes
        ? themeScenarios
        : _allLuxury
        ? luxuryScenarios
        : standardScenarios;

    for (final scenario in scenarios) {
      await _pumpScenario(tester, scenario.view);
      expect(tester.takeException(), isNull, reason: scenario.name);
      await _capture(tester, binding, scenario.name);
    }

    if (!_allThemes && !_allLuxury) {
      await _pumpScenario(tester, _view(visitor: _visitor()));
      await tester.tap(find.byKey(const ValueKey<String>('home_menu')));
      await tester.pump(const Duration(milliseconds: 380));
      expect(
        find.byKey(const ValueKey<String>('home_notebook_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, binding, 'notebook');
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}
