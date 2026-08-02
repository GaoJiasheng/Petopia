import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/app/game_services.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/petopia_theme.dart';
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
  _VisualGameController(this.fixture, this._careFeedback);

  final GameView fixture;
  CareFeedbackView? _careFeedback;

  @override
  Future<GameView> build() async => fixture;

  @override
  List<PostcardView> postcards() => const <PostcardView>[];

  @override
  void refreshView() {}

  @override
  Future<bool> feed() async => _careFeedback != null;

  @override
  Future<bool> pat() async => true;

  @override
  Future<bool> toy() async => true;

  @override
  Future<bool> bath() async => true;

  @override
  CareFeedbackView? takeCareFeedback() {
    final feedback = _careFeedback;
    _careFeedback = null;
    return feedback;
  }

  @override
  void completeCareTutorial() {}

  @override
  Future<void> onAppResumed() async {}

  @override
  Future<void> onAppPaused() async {}

  @override
  EventResolution? resolveEvent(String id, {int? choiceIndex}) => null;
}

class _VisualApp extends StatelessWidget {
  const _VisualApp();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey<String>('visual_capture_boundary'),
      child: MaterialApp(
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
        home: YardHomeScreen(
          enableCooldownRefresh: false,
          visualTestHour: _visualHour < 0 ? null : _visualHour,
        ),
      ),
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

VisitorPresenceView _placementVisitor({required bool rightLane}) {
  final id = rightLane ? 'visitor_butterfly' : 'visitor_deer';
  return VisitorPresenceView(
    id: id,
    name: rightLane ? '白粉蝶' : '小鹿',
    rarity: rightLane ? VisitorRarity.common : VisitorRarity.rare,
    message: rightLane ? '它停在花香旁边。' : '它从篱笆边安静地走来。',
    arrivedAt: DateTime.utc(2026, 8, 2),
    leavesAt: DateTime.utc(2026, 8, 3),
    arrivalSeen: true,
    interacted: true,
    yardAsset: 'assets/art/world/visitors/${id}_yard.png',
    portraitAsset: 'assets/art/world/visitors/${id}_portrait.png',
  );
}

RevisitorPresenceView _revisitor() {
  return RevisitorPresenceView(
    id: 'visual-revisitor-rabbit',
    name: '小云',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v1',
    arrivedAt: DateTime.utc(2026, 8, 2),
    leavesAt: DateTime.utc(2026, 8, 4),
    arrivalSeen: true,
    interacted: true,
  );
}

const _allDecorSlots = <YardSlotView>[
  YardSlotView(pos: 0, itemId: 'mailbox_wood'),
  YardSlotView(pos: 1, itemId: 'food_bowl_full'),
  YardSlotView(pos: 2, itemId: 'flowerbed_small'),
  YardSlotView(pos: 3, itemId: 'water_bowl'),
  YardSlotView(pos: 4, itemId: 'night_light'),
  YardSlotView(pos: 5, itemId: 'fireplace'),
  YardSlotView(pos: 6, itemId: 'wind_chime'),
  YardSlotView(pos: 7, itemId: 'flower_box'),
  YardSlotView(pos: 8, itemId: 'mushroom_bench'),
  YardSlotView(pos: 9, itemId: 'scarecrow'),
  YardSlotView(pos: 10, itemId: 'wind_vane'),
  YardSlotView(pos: 11, itemId: 'wood_sign'),
  YardSlotView(pos: 12, itemId: 'pond_small'),
  YardSlotView(pos: 13, itemId: 'album_shelf'),
];

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
  CareAction? preferredAction,
  bool careContented = false,
  List<YardMemoryView> recentMemories = const <YardMemoryView>[],
  List<YardSlotView> decorSlots = const <YardSlotView>[],
  RevisitorPresenceView? revisitor,
}) {
  return GameView(
    pet: emptyYard ? null : (pet ?? _pet()),
    wallet: 237,
    luxuryStage: luxuryStage,
    cooldownSec: cooldown,
    dailyMaxed: const {},
    canGraduate: canGraduate,
    activeThemeId: theme,
    decorSlots: decorSlots,
    activeVisitor: visitor,
    revisitor: revisitor,
    pendingEvent: pendingEvent,
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: careTutorialStep,
    todayYard: careTutorialStep >= 3 ? _today : null,
    preferredCareAction: preferredAction,
    careContented: careContented,
    recentMemories: recentMemories,
  );
}

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'yard',
);
const _landscape = bool.fromEnvironment('PETOPIA_VISUAL_LANDSCAPE');
const _allThemes = bool.fromEnvironment('PETOPIA_VISUAL_ALL_THEMES');
const _allLuxury = bool.fromEnvironment('PETOPIA_VISUAL_ALL_LUXURY');
const _placementRegression = bool.fromEnvironment('PETOPIA_VISUAL_PLACEMENTS');
const _visualHour = int.fromEnvironment(
  'PETOPIA_VISUAL_HOUR',
  defaultValue: -1,
);
const _capturePerformance = bool.fromEnvironment('PETOPIA_CAPTURE_PERFORMANCE');
const _expectedScreenshotWidth = int.fromEnvironment(
  'PETOPIA_VISUAL_EXPECTED_WIDTH',
);
const _expectedScreenshotHeight = int.fromEnvironment(
  'PETOPIA_VISUAL_EXPECTED_HEIGHT',
);

Future<void> _pumpScenario(
  WidgetTester tester,
  GameView view, {
  CareFeedbackView? careFeedback,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        audioServiceProvider.overrideWithValue(_SilentAudio()),
        gameControllerProvider.overrideWith(
          () => _VisualGameController(view, careFeedback),
        ),
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

final class _VisualFingerprint {
  const _VisualFingerprint({
    required this.signature,
    required this.luminanceDeviation,
  });

  final String signature;
  final double luminanceDeviation;
}

Future<_VisualFingerprint> _capture(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 120));
  final captureBoundary = find.byKey(
    const ValueKey<String>('visual_capture_boundary'),
  );
  expect(captureBoundary, findsOneWidget);
  final boundary = tester.renderObject<RenderRepaintBoundary>(captureBoundary);
  final pixelRatio = View.of(tester.element(captureBoundary)).devicePixelRatio;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  expect(
    await _hasSolidDarkBottomBand(image),
    isFalse,
    reason:
        'The iOS screenshot surface contains a solid black lower band. '
        'Use the widget capture path instead of a rotated screen buffer.',
  );
  final fingerprint = await _analyzeVisual(image, name);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = data!.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  final directory = Directory('/tmp/petopia-yard-visual')
    ..createSync(recursive: true);
  final output = File('${directory.path}/$_prefix-$name.png')
    ..writeAsBytesSync(bytes);
  if (_expectedScreenshotWidth > 0 && _expectedScreenshotHeight > 0) {
    final width = _pngDimension(bytes, 16);
    final height = _pngDimension(bytes, 20);
    expect(
      (width, height),
      (_expectedScreenshotWidth, _expectedScreenshotHeight),
      reason:
          '${output.path} has a mismatched orientation buffer. '
          'Rotate the simulator before capture.',
    );
  }
  return fingerprint;
}

int _pngDimension(List<int> bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

Future<bool> _hasSolidDarkBottomBand(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return true;
  final bandHeight = math.max(8, image.height ~/ 50);
  var dark = 0;
  var sampled = 0;
  for (var y = image.height - bandHeight; y < image.height; y += 4) {
    for (var x = 0; x < image.width; x += 8) {
      final offset = (y * image.width + x) * 4;
      final red = data.getUint8(offset);
      final green = data.getUint8(offset + 1);
      final blue = data.getUint8(offset + 2);
      if (red < 8 && green < 8 && blue < 8) dark++;
      sampled++;
    }
  }
  return sampled > 0 && dark / sampled > 0.98;
}

Future<_VisualFingerprint> _analyzeVisual(ui.Image image, String name) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  expect(data, isNotNull, reason: '$name did not expose RGBA pixels');
  final pixels = data!;
  final stepX = math.max(1, image.width ~/ 180);
  final stepY = math.max(1, image.height ~/ 220);
  var sampled = 0;
  var opaque = 0;
  var nearBlack = 0;
  var luminanceSum = 0.0;
  var luminanceSquares = 0.0;
  final colorBuckets = <int>{};
  for (var y = 0; y < image.height; y += stepY) {
    for (var x = 0; x < image.width; x += stepX) {
      final offset = (y * image.width + x) * 4;
      final red = pixels.getUint8(offset);
      final green = pixels.getUint8(offset + 1);
      final blue = pixels.getUint8(offset + 2);
      final alpha = pixels.getUint8(offset + 3);
      final luminance = red * 0.2126 + green * 0.7152 + blue * 0.0722;
      luminanceSum += luminance;
      luminanceSquares += luminance * luminance;
      if (alpha >= 250) opaque++;
      if (red < 8 && green < 8 && blue < 8) nearBlack++;
      colorBuckets.add(((red >> 5) << 6) | ((green >> 5) << 3) | (blue >> 5));
      sampled++;
    }
  }
  final mean = luminanceSum / sampled;
  final deviation = math.sqrt(
    math.max(0, luminanceSquares / sampled - mean * mean),
  );
  expect(
    opaque / sampled,
    greaterThan(0.999),
    reason: '$name contains unintended transparent output',
  );
  expect(
    nearBlack / sampled,
    lessThan(0.12),
    reason: '$name contains an excessive black fallback surface',
  );
  expect(
    deviation,
    greaterThan(18),
    reason: '$name is visually flat or failed to render its art',
  );
  expect(
    colorBuckets.length,
    greaterThan(24),
    reason: '$name does not contain enough rendered color detail',
  );

  final signature = StringBuffer();
  for (var row = 0; row < 12; row++) {
    final y = ((row + 0.5) * image.height / 12).floor();
    for (var column = 0; column < 16; column++) {
      final x = ((column + 0.5) * image.width / 16).floor();
      final offset = (y * image.width + x) * 4;
      final packed =
          ((pixels.getUint8(offset) >> 5) << 6) |
          ((pixels.getUint8(offset + 1) >> 5) << 3) |
          (pixels.getUint8(offset + 2) >> 5);
      signature.write(packed.toRadixString(16).padLeft(3, '0'));
    }
  }
  return _VisualFingerprint(
    signature: signature.toString(),
    luminanceDeviation: deviation,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render every yard home state for visual review', (tester) async {
    if (_expectedScreenshotWidth > 0 && _expectedScreenshotHeight > 0) {
      final pixelRatio = tester.view.devicePixelRatio;
      await tester.binding.setSurfaceSize(
        Size(
          _expectedScreenshotWidth / pixelRatio,
          _expectedScreenshotHeight / pixelRatio,
        ),
      );
      addTearDown(() => tester.binding.setSurfaceSize(null));
    } else if (_landscape) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
      ]);
    }
    await tester.pump(const Duration(milliseconds: 800));
    if (_capturePerformance) {
      await _pumpScenario(
        tester,
        _view(
          pet: _pet(stage: PetStage.c),
          preferredAction: CareAction.feed,
        ),
      );
      // The production yard waits for its first composition to settle, then
      // decodes the highest-priority sheets within its current cache budget.
      await tester.pump(const Duration(seconds: 3));
      await binding.watchPerformance(
        () => _playAllAuthoredInteractions(tester),
        reportKey: 'authored_care_interactions',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
      return;
    }
    final standardScenarios = <({String name, GameView view})>[
      (name: 'standard', view: _view(preferredAction: CareAction.feed)),
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
      (
        name: 'visitor',
        view: _view(
          visitor: _visitor(),
          preferredAction: CareAction.feed,
          careContented: true,
          recentMemories: <YardMemoryView>[
            YardMemoryView(
              id: 'growth:pet-current:lv6',
              type: 'growth',
              text: '橘团会把最好吃的那一口留到最后，再认真看你一眼。',
              createdAt: DateTime.utc(2026, 7, 22),
            ),
            YardMemoryView(
              id: 'visitor:visitor_calico:1',
              type: 'visitor',
              text: '流浪三花猫离开前又回头看了看橘团，院子里留下了一段安静的脚印。',
              createdAt: DateTime.utc(2026, 7, 23),
            ),
          ],
        ),
      ),
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
    final placementScenarios = <({String name, GameView view})>[
      for (final theme in const <(String, String)>[
        ('meadow', 'meadow'),
        ('autumnjam', 'autumn_jam'),
        ('bambootea', 'bamboo_tea'),
        ('candybake', 'candy_bakery'),
        ('fourseasons', 'four_seasons'),
        ('moongreen', 'moonlight'),
        ('mossrain', 'rain_moss'),
        ('sakura', 'sakura'),
        ('seaside', 'sea_breeze'),
        ('snowhut', 'snow_house'),
        ('starcamp', 'starry_camp'),
        ('wheatkite', 'wheat_kite'),
      ]) ...[
        (
          name: '${theme.$1}-visitor-left',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            visitor: _placementVisitor(rightLane: false),
          ),
        ),
        (
          name: '${theme.$1}-visitor-right',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            visitor: _placementVisitor(rightLane: true),
          ),
        ),
        (
          name: '${theme.$1}-revisitor',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            revisitor: _revisitor(),
          ),
        ),
      ],
    ];
    final luxuryScenarios = <({String name, GameView view})>[
      for (var stage = 1; stage <= 6; stage++)
        (
          name: 'luxury-$stage',
          view: _view(theme: 'meadow', luxuryStage: stage),
        ),
    ];
    final scenarios = _placementRegression
        ? placementScenarios
        : _allThemes
        ? themeScenarios
        : _allLuxury
        ? luxuryScenarios
        : standardScenarios;

    final fingerprints = <String, String>{};
    for (final scenario in scenarios) {
      await _pumpScenario(tester, scenario.view);
      expect(tester.takeException(), isNull, reason: scenario.name);
      if (_placementRegression) {
        expect(
          find.byKey(const ValueKey<String>('yard_pet_sprite')),
          findsOneWidget,
          reason: '${scenario.name} is missing its current pet',
        );
        for (final slot in _allDecorSlots) {
          expect(
            find.byKey(ValueKey<String>('yard_decor_6_${slot.itemId}')),
            findsOneWidget,
            reason: '${scenario.name} is missing decor slot ${slot.pos}',
          );
        }
        final sideActor = scenario.view.activeVisitor != null
            ? find.byKey(const ValueKey<String>('active_visitor'))
            : find.byKey(const ValueKey<String>('active_revisitor'));
        expect(sideActor, findsOneWidget, reason: scenario.name);
        expect(
          tester
              .getRect(find.byKey(const ValueKey<String>('yard_pet_sprite')))
              .overlaps(tester.getRect(sideActor)),
          isFalse,
          reason: '${scenario.name} overlaps the current pet and side actor',
        );
      }
      final fingerprint = await _capture(tester, scenario.name);
      expect(
        fingerprint.luminanceDeviation,
        greaterThan(18),
        reason: scenario.name,
      );
      if (_allThemes) {
        expect(
          fingerprints.values,
          isNot(contains(fingerprint.signature)),
          reason:
              '${scenario.name} rendered the same coarse visual fingerprint '
              'as another theme, which usually means a background fallback.',
        );
        fingerprints[scenario.name] = fingerprint.signature;
      }
    }

    if (!_placementRegression && !_allThemes && !_allLuxury) {
      await _pumpScenario(
        tester,
        _view(preferredAction: CareAction.feed),
        careFeedback: const CareFeedbackView(
          message: '三种陪伴都收到了，橘团今天已经很满足。',
          expApplied: 5,
          preferred: true,
          contented: true,
        ),
      );
      final feedButton = find.byKey(const ValueKey<String>('care_action_feed'));
      final feedInkWell = find.descendant(
        of: feedButton,
        matching: find.byType(InkWell),
      );
      tester.widget<InkWell>(feedInkWell).onTap!.call();
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, 'care-feedback');

      await _pumpScenario(
        tester,
        _view(
          visitor: _visitor(),
          recentMemories: <YardMemoryView>[
            YardMemoryView(
              id: 'growth:pet-current:lv6',
              type: 'growth',
              text: '橘团会把最好吃的那一口留到最后，再认真看你一眼。',
              createdAt: DateTime.utc(2026, 7, 22),
            ),
            YardMemoryView(
              id: 'visitor:visitor_calico:1',
              type: 'visitor',
              text: '流浪三花猫离开前又回头看了看橘团，院子里留下了一段安静的脚印。',
              createdAt: DateTime.utc(2026, 7, 23),
            ),
          ],
        ),
      );
      final menuButton = tester.widget<IconButton>(
        find.byKey(const ValueKey<String>('home_menu')),
      );
      expect(menuButton.onPressed, isNotNull);
      menuButton.onPressed!.call();
      await tester.pump(const Duration(milliseconds: 380));
      expect(
        find.byKey(const ValueKey<String>('home_notebook_panel')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, 'notebook');
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}

Future<void> _playAllAuthoredInteractions(WidgetTester tester) async {
  for (final interaction in const <(String, String)>[
    ('feed', 'eat'),
    ('pat', 'pat'),
    ('toy', 'play'),
    ('bath', 'bath'),
  ]) {
    final button = find.byKey(
      ValueKey<String>('care_action_${interaction.$1}'),
    );
    final animation = find.byKey(
      ValueKey<String>('pet_action_${interaction.$2}'),
    );
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    expect(animation, findsOneWidget);
    for (
      var frame = 0;
      frame < 80 && animation.evaluate().isNotEmpty;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(animation, findsNothing);
    expect(tester.takeException(), isNull);
  }
}
