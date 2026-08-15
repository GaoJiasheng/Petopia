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
import 'package:petopia/ui/pet_art.dart';
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
  Future<bool> feed() async => true;

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

const _petSpecies = <String>[
  'boo',
  'cat',
  'chameleon',
  'ember',
  'hamster',
  'parrot',
  'rabbit',
  'shiba',
  'snake',
  'starbug',
  'turtle',
  'uni',
];

const _visitorIds = <String>[
  'visitor_sparrow',
  'visitor_calico',
  'visitor_snail',
  'visitor_butterfly',
  'visitor_hedgehog',
  'visitor_pigeon',
  'visitor_squirrel',
  'visitor_crow',
  'visitor_frog',
  'visitor_firefly',
  'visitor_tanuki',
  'visitor_egret',
  'visitor_fox',
  'visitor_owl',
  'visitor_deer',
  'visitor_snowhare',
  'visitor_starbug',
  'visitor_campfire_light',
  'visitor_rainbow_shade',
  'visitor_night_blob',
];

PetView _catalogPet(String species, int variant, PetStage stage) {
  return PetView(
    name: '$species $variant',
    speciesId: 'pet_$species',
    speciesName: species,
    variantId: 'pet_${species}_v$variant',
    level: stage.index * 3 + 1,
    exp: stage.index * 700,
    stage: stage,
    personality: const ['温柔', '活力'],
    bornAt: DateTime.utc(2026, 7, 1),
  );
}

VisitorPresenceView _catalogVisitor(String id) {
  return VisitorPresenceView(
    id: id,
    name: id.replaceFirst('visitor_', ''),
    rarity: VisitorRarity.common,
    message: '它在院子里安静地待了一会儿。',
    arrivedAt: DateTime.utc(2026, 8, 2),
    leavesAt: DateTime.utc(2026, 8, 3),
    arrivalSeen: true,
    interacted: true,
    yardAsset: visitorArtAsset(id, 'yard'),
    portraitAsset: visitorArtAsset(id, 'portrait'),
  );
}

RevisitorPresenceView _catalogRevisitor(String species, int variant) {
  return RevisitorPresenceView(
    id: 'revisitor-$species-$variant',
    name: '$species $variant',
    speciesId: 'pet_$species',
    variantId: 'pet_${species}_v$variant',
    arrivedAt: DateTime.utc(2026, 8, 2),
    leavesAt: DateTime.utc(2026, 8, 4),
    arrivalSeen: true,
    interacted: true,
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

bool _visitorUsesRightLaneForTest(VisitorPresenceView visitor) => const {
  'visitor_butterfly',
  'visitor_firefly',
  'visitor_starbug',
  'visitor_campfire_light',
}.contains(visitor.id);

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

// Worst case for placement: every slot holds one of the tallest props, so the
// regression fails before a real player can create an overlapping yard.
const _allDecorSlots = <YardSlotView>[
  YardSlotView(pos: 0, itemId: 'mailbox_wood'),
  YardSlotView(pos: 1, itemId: 'wind_chime'),
  YardSlotView(pos: 2, itemId: 'scarecrow'),
  YardSlotView(pos: 3, itemId: 'wood_sign'),
  YardSlotView(pos: 4, itemId: 'fireplace'),
  YardSlotView(pos: 5, itemId: 'wind_vane'),
  YardSlotView(pos: 6, itemId: 'album_shelf'),
  YardSlotView(pos: 7, itemId: 'night_light'),
];

const _selectedDecorRegressionSlots = <YardSlotView>[
  YardSlotView(pos: 0, itemId: 'night_light'),
  YardSlotView(pos: 1, itemId: 'wind_chime'),
  YardSlotView(pos: 2, itemId: 'flower_box'),
  YardSlotView(pos: 3, itemId: 'mushroom_bench'),
  YardSlotView(pos: 4, itemId: 'scarecrow'),
  YardSlotView(pos: 5, itemId: 'wood_sign'),
];

// A representative player-authored full yard. Unlike [_allDecorSlots], which
// intentionally stacks the tallest silhouettes for collision stress testing,
// this mix is meant for human composition review with all eight slots filled.
const _fullPlayerDecorSlots = <YardSlotView>[
  YardSlotView(pos: 0, itemId: 'night_light'),
  YardSlotView(pos: 1, itemId: 'wind_chime'),
  YardSlotView(pos: 2, itemId: 'flower_box'),
  YardSlotView(pos: 3, itemId: 'mushroom_bench'),
  YardSlotView(pos: 4, itemId: 'fireplace'),
  YardSlotView(pos: 5, itemId: 'wind_vane'),
  YardSlotView(pos: 6, itemId: 'album_shelf'),
  YardSlotView(pos: 7, itemId: 'pond_small'),
];

const _compactDecorAnchorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.05),
  1: Alignment(0.82, 0.17),
  2: Alignment(-0.88, 0.40),
  3: Alignment(0.86, 0.37),
  4: Alignment(-0.80, 0.68),
  5: Alignment(0.78, 0.67),
  6: Alignment(-0.30, 0.04),
  7: Alignment(0.32, 0.07),
};

const _tabletDecorAnchorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.03),
  1: Alignment(0.82, 0.16),
  2: Alignment(-0.88, 0.40),
  3: Alignment(0.86, 0.38),
  4: Alignment(-0.80, 0.72),
  5: Alignment(0.78, 0.76),
  6: Alignment(-0.30, 0.02),
  7: Alignment(0.32, 0.05),
};

const _wideDecorAnchorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.02),
  1: Alignment(0.82, 0.16),
  2: Alignment(-0.88, 0.40),
  3: Alignment(0.86, 0.38),
  4: Alignment(-0.80, 0.72),
  5: Alignment(0.78, 0.76),
  6: Alignment(-0.30, 0.01),
  7: Alignment(0.32, 0.04),
};

const _compactDualActorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.56),
  1: Alignment(0.84, 0.58),
  6: Alignment(-0.30, 0.04),
  7: Alignment(0.32, 0.08),
};

const _tabletDualActorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.56),
  1: Alignment(0.84, 0.58),
  6: Alignment(-0.30, 0.03),
  7: Alignment(0.32, 0.07),
};

const _wideDualActorAlignmentsForTest = <int, Alignment>{
  0: Alignment(-0.84, 0.56),
  1: Alignment(0.84, 0.58),
  6: Alignment(-0.30, 0.02),
  7: Alignment(0.32, 0.06),
};

List<({YardSlotView slot, int targetPos})> _resolvedDecorSlotsForTest(
  List<YardSlotView> slots,
  Set<int> excludedPositions,
  Map<int, Alignment> anchorAlignments,
) {
  final available = anchorAlignments.keys
      .where((pos) => !excludedPositions.contains(pos))
      .toSet();
  final resolved = <({YardSlotView slot, int targetPos})>[];
  for (final slot in slots) {
    if (available.isEmpty) break;
    final preferred = anchorAlignments[slot.pos];
    final targetPos = available.reduce((best, candidate) {
      if (candidate == slot.pos) return candidate;
      if (best == slot.pos) return best;
      if (preferred == null) return candidate < best ? candidate : best;
      final bestAnchor = anchorAlignments[best]!;
      final candidateAnchor = anchorAlignments[candidate]!;
      final bestDistance =
          math.pow(bestAnchor.x - preferred.x, 2) +
          math.pow(bestAnchor.y - preferred.y, 2);
      final candidateDistance =
          math.pow(candidateAnchor.x - preferred.x, 2) +
          math.pow(candidateAnchor.y - preferred.y, 2);
      if (candidateDistance == bestDistance) {
        return candidate < best ? candidate : best;
      }
      return candidateDistance < bestDistance ? candidate : best;
    });
    available.remove(targetPos);
    resolved.add((slot: slot, targetPos: targetPos));
  }
  return resolved;
}

Rect _visualSubjectRect(Rect rect) {
  final inset = math.min(rect.width, rect.height) * 0.10;
  return rect.deflate(inset);
}

bool _hasSubstantialOverlap(Rect a, Rect b) {
  final overlap = a.intersect(b);
  if (overlap.isEmpty || overlap.width <= 2 || overlap.height <= 2) {
    return false;
  }
  final overlapArea = overlap.width * overlap.height;
  final smallerArea = math.min(a.width * a.height, b.width * b.height);
  return overlapArea > smallerArea * 0.025;
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
  CareAction? preferredAction,
  bool careContented = false,
  List<YardMemoryView> recentMemories = const <YardMemoryView>[],
  List<YardSlotView> decorSlots = const <YardSlotView>[],
  RevisitorPresenceView? revisitor,
  bool waterBowlOwned = false,
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
    waterBowlOwned: waterBowlOwned,
  );
}

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'yard',
);
const _captureDirectory = String.fromEnvironment(
  'PETOPIA_VISUAL_DIR',
  defaultValue: '/tmp/petopia-yard-visual',
);
const _catalogMode = String.fromEnvironment('PETOPIA_VISUAL_CATALOG');
const _actionSpeciesFilter = String.fromEnvironment(
  'PETOPIA_VISUAL_ACTION_SPECIES',
);
const _actionVariantFilter = int.fromEnvironment(
  'PETOPIA_VISUAL_ACTION_VARIANT',
);
const _actionStageFilter = String.fromEnvironment(
  'PETOPIA_VISUAL_ACTION_STAGE',
);
const _captureActionTimeline = bool.fromEnvironment(
  'PETOPIA_VISUAL_ACTION_TIMELINE',
);
const _landscape = bool.fromEnvironment('PETOPIA_VISUAL_LANDSCAPE');
const _allThemes = bool.fromEnvironment('PETOPIA_VISUAL_ALL_THEMES');
const _allLuxury = bool.fromEnvironment('PETOPIA_VISUAL_ALL_LUXURY');
const _placementRegression = bool.fromEnvironment('PETOPIA_VISUAL_PLACEMENTS');
const _scenarioFilter = String.fromEnvironment('PETOPIA_VISUAL_SCENARIO');
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
  final catalogCapture = _catalogMode.isNotEmpty;
  final settleFrames = _catalogMode == 'actions'
      ? 5
      : catalogCapture
      ? 12
      : 18;
  for (var frame = 0; frame < settleFrames; frame++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
  await Future<void>.delayed(
    Duration(
      milliseconds: _catalogMode == 'actions'
          ? 80
          : catalogCapture
          ? 250
          : 500,
    ),
  );
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
  final directory = Directory(_captureDirectory)..createSync(recursive: true);
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
          name: '${theme.$1}-decor-only',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            waterBowlOwned: true,
          ),
        ),
        (
          name: '${theme.$1}-visitor-left',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            visitor: _placementVisitor(rightLane: false),
            waterBowlOwned: true,
          ),
        ),
        (
          name: '${theme.$1}-visitor-right',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            visitor: _placementVisitor(rightLane: true),
            waterBowlOwned: true,
          ),
        ),
        (
          name: '${theme.$1}-revisitor',
          view: _view(
            theme: theme.$2,
            luxuryStage: 6,
            decorSlots: _allDecorSlots,
            revisitor: _revisitor(),
            waterBowlOwned: true,
          ),
        ),
      ],
      (
        name: 'selected-decor-both-actors',
        view: _view(
          theme: 'snow_house',
          luxuryStage: 6,
          decorSlots: _selectedDecorRegressionSlots,
          visitor: _placementVisitor(rightLane: false),
          revisitor: _revisitor(),
          waterBowlOwned: true,
        ),
      ),
      (
        name: 'full-player-decor',
        view: _view(
          theme: 'meadow',
          luxuryStage: 6,
          decorSlots: _fullPlayerDecorSlots,
          waterBowlOwned: true,
        ),
      ),
      (
        name: 'full-player-decor-both-actors',
        view: _view(
          theme: 'meadow',
          luxuryStage: 6,
          decorSlots: _fullPlayerDecorSlots,
          visitor: _placementVisitor(rightLane: false),
          revisitor: _revisitor(),
          waterBowlOwned: true,
        ),
      ),
    ];
    final luxuryScenarios = <({String name, GameView view})>[
      for (var stage = 1; stage <= 6; stage++)
        (
          name: 'luxury-$stage',
          view: _view(theme: 'meadow', luxuryStage: stage),
        ),
    ];
    final petCatalogScenarios = <({String name, GameView view})>[
      for (final species in _petSpecies)
        for (var variant = 1; variant <= 5; variant++)
          for (final stage in PetStage.values)
            (
              name: 'pet-$species-v$variant-stage-${stage.name.toLowerCase()}',
              view: _view(
                theme: 'meadow',
                pet: _catalogPet(species, variant, stage),
              ),
            ),
    ];
    final visitorCatalogScenarios = <({String name, GameView view})>[
      for (final visitorId in _visitorIds)
        (
          name: visitorId.replaceFirst('visitor_', 'visitor-'),
          view: _view(
            theme: 'meadow',
            pet: _catalogPet('cat', 1, PetStage.c),
            visitor: _catalogVisitor(visitorId),
          ),
        ),
    ];
    final revisitorCatalogScenarios = <({String name, GameView view})>[
      for (final species in _petSpecies)
        for (var variant = 1; variant <= 5; variant++)
          (
            name: 'revisitor-$species-v$variant',
            view: _view(
              theme: 'meadow',
              pet: _catalogPet('cat', 1, PetStage.c),
              revisitor: _catalogRevisitor(species, variant),
            ),
          ),
    ];
    final actionCatalogScenarios = <({String name, GameView view})>[
      for (final species in _petSpecies)
        if (_actionSpeciesFilter.isEmpty || species == _actionSpeciesFilter)
          for (var variant = 1; variant <= 5; variant++)
            if (_actionVariantFilter == 0 || variant == _actionVariantFilter)
              for (final stage in PetStage.values)
                if (_actionStageFilter.isEmpty ||
                    stage.name == _actionStageFilter.toLowerCase())
                  for (final action in PetArt.interactionNames)
                    (
                      name:
                          'action-$species-v$variant-stage-'
                          '${stage.name.toLowerCase()}-$action',
                      view: _view(
                        theme: 'meadow',
                        pet: _catalogPet(species, variant, stage),
                      ),
                    ),
    ];
    final allScenarios = switch (_catalogMode) {
      'pets' => petCatalogScenarios,
      'visitors' => visitorCatalogScenarios,
      'revisitors' => revisitorCatalogScenarios,
      'actions' => actionCatalogScenarios,
      _ when _placementRegression => placementScenarios,
      _ when _allThemes => themeScenarios,
      _ when _allLuxury => luxuryScenarios,
      _ => standardScenarios,
    };
    final scenarios = _scenarioFilter.isEmpty
        ? allScenarios
        : allScenarios
              .where((scenario) => scenario.name == _scenarioFilter)
              .toList(growable: false);
    expect(
      scenarios,
      isNotEmpty,
      reason: 'No visual scenario named $_scenarioFilter',
    );

    final fingerprints = <String, String>{};
    for (final scenario in scenarios) {
      await _pumpScenario(tester, scenario.view);
      expect(tester.takeException(), isNull, reason: scenario.name);
      if (_catalogMode == 'actions') {
        final action = scenario.name.split('-').last;
        final buttonAction = switch (action) {
          'eat' => 'feed',
          'play' => 'toy',
          _ => action,
        };
        await tester.tap(
          find.byKey(ValueKey<String>('care_action_$buttonAction')),
        );
        // Action props reach full opacity after 400 ms of the five-second cue.
        // Capture shortly after that point so the 960-state matrix remains
        // practical while still validating a fully rendered animation state.
        await tester.pump(const Duration(milliseconds: 520));
        expect(
          find.byKey(ValueKey<String>('pet_action_$action')),
          findsOneWidget,
          reason: '${scenario.name} did not start its interaction',
        );
        final pet = scenario.view.pet!;
        if (!PetArt.hasExactAction(
          variantId: pet.variantId,
          stage: pet.stage,
        )) {
          expect(
            find.byKey(ValueKey<String>('pet_action_prop_$action')),
            findsOneWidget,
            reason: '${scenario.name} lost its identity-safe rendered prop',
          );
        }
        if (_captureActionTimeline) {
          await _capture(tester, '${scenario.name}-t0520');
          await tester.pump(const Duration(milliseconds: 730));
          await _capture(tester, '${scenario.name}-t1250');
          await tester.pump(const Duration(milliseconds: 1250));
          await _capture(tester, '${scenario.name}-t2500');
          await tester.pump(const Duration(milliseconds: 1500));
          await _capture(tester, '${scenario.name}-t4000');
        }
      }
      if (_placementRegression) {
        expect(
          find.byKey(const ValueKey<String>('yard_pet_sprite')),
          findsOneWidget,
          reason: '${scenario.name} is missing its current pet',
        );
        final visitorUsesRightLane =
            scenario.view.activeVisitor != null &&
            _visitorUsesRightLaneForTest(scenario.view.activeVisitor!);
        final bothSocialActors =
            scenario.view.activeVisitor != null &&
            scenario.view.revisitor != null;
        final occupiedAnimalPoints = <int>{
          if (bothSocialActors) ...const <int>{4, 5},
          if (scenario.view.activeVisitor != null)
            ...(bothSocialActors
                ? visitorUsesRightLane
                      ? const <int>{3}
                      : const <int>{2}
                : visitorUsesRightLane
                ? const <int>{1, 3}
                : const <int>{0, 2}),
          if (scenario.view.revisitor != null)
            ...(bothSocialActors
                ? visitorUsesRightLane
                      ? const <int>{2}
                      : const <int>{3}
                : const <int>{1, 3}),
        };
        final sceneSize = tester.getSize(
          find.byKey(const ValueKey<String>('yard_background')),
        );
        final wideLayout =
            sceneSize.width >= 900 && sceneSize.width > sceneSize.height * 1.05;
        final tabletPortrait = !wideLayout && sceneSize.width >= 600;
        final standardAnchorAlignments = wideLayout
            ? _wideDecorAnchorAlignmentsForTest
            : tabletPortrait
            ? _tabletDecorAnchorAlignmentsForTest
            : _compactDecorAnchorAlignmentsForTest;
        final dualActorLayout = occupiedAnimalPoints.containsAll(const <int>{
          2,
          3,
          4,
          5,
        });
        final anchorAlignments = dualActorLayout
            ? wideLayout
                  ? _wideDualActorAlignmentsForTest
                  : tabletPortrait
                  ? _tabletDualActorAlignmentsForTest
                  : _compactDualActorAlignmentsForTest
            : standardAnchorAlignments;
        final resolvedDecor = _resolvedDecorSlotsForTest(
          scenario.view.decorSlots,
          occupiedAnimalPoints,
          anchorAlignments,
        );
        final decorFinders =
            <({YardSlotView slot, int targetPos, Finder finder})>[];
        for (final slot in scenario.view.decorSlots) {
          final finder = find.byKey(
            ValueKey<String>('yard_decor_6_${slot.itemId}'),
          );
          final placement = resolvedDecor
              .where((entry) => entry.slot.itemId == slot.itemId)
              .firstOrNull;
          if (placement == null) {
            expect(
              finder,
              findsNothing,
              reason:
                  '${scenario.name} rendered a lower-priority overflow '
                  'item from slot ${slot.pos}',
            );
          } else {
            expect(
              finder,
              findsOneWidget,
              reason:
                  '${scenario.name} is missing selected decor '
                  'slot ${slot.pos} at ${placement.targetPos}',
            );
            decorFinders.add((
              slot: slot,
              targetPos: placement.targetPos,
              finder: finder,
            ));
          }
        }
        for (final utility in const ['food_bowl_full', 'water_bowl']) {
          expect(
            find.byKey(ValueKey<String>('yard_decor_6_$utility')),
            findsOneWidget,
            reason: '${scenario.name} is missing fixed utility $utility',
          );
        }
        final visitorFinder = find.byKey(
          const ValueKey<String>('active_visitor'),
        );
        final revisitorFinder = find.byKey(
          const ValueKey<String>('active_revisitor'),
        );
        expect(
          visitorFinder,
          scenario.view.activeVisitor != null ? findsOneWidget : findsNothing,
          reason: '${scenario.name} visitor visibility mismatch',
        );
        expect(
          revisitorFinder,
          scenario.view.revisitor != null ? findsOneWidget : findsNothing,
          reason: '${scenario.name} revisitor visibility mismatch',
        );
        final petRect = _visualSubjectRect(
          tester.getRect(find.byKey(const ValueKey<String>('yard_pet_sprite'))),
        );
        final yardRect = tester.getRect(
          find.byKey(const ValueKey<String>('yard_background')),
        );
        // Artwork may extend upward, but every visible base must be planted
        // below the fence. These floors deliberately reject the former
        // sky/fence anchors instead of merely checking screen bounds.
        final farGroundStart = yardRect.top + yardRect.height * 0.50;
        final animalGroundStart = yardRect.top + yardRect.height * 0.56;
        final sideGroundStart = yardRect.top + yardRect.height * 0.60;
        final foregroundStart = yardRect.top + yardRect.height * 0.78;
        final actionBarTop = tester
            .getRect(find.byKey(const ValueKey<String>('care_action_feed')))
            .top;
        final actorRects = <({String name, Rect rawRect, Rect rect})>[
          if (scenario.view.activeVisitor != null)
            (
              name: 'visitor',
              rawRect: tester.getRect(visitorFinder),
              rect: _visualSubjectRect(tester.getRect(visitorFinder)),
            ),
          if (scenario.view.revisitor != null)
            (
              name: 'revisitor',
              rawRect: tester.getRect(revisitorFinder),
              rect: _visualSubjectRect(tester.getRect(revisitorFinder)),
            ),
        ];
        for (final actor in actorRects) {
          expect(
            actor.rawRect.bottom,
            greaterThanOrEqualTo(animalGroundStart),
            reason: '${scenario.name} ${actor.name} is standing above the lawn',
          );
          expect(
            actor.rawRect.bottom,
            lessThan(actionBarTop - 8),
            reason:
                '${scenario.name} ${actor.name} is hidden by the action bar',
          );
          expect(
            _hasSubstantialOverlap(petRect, actor.rect),
            isFalse,
            reason: '${scenario.name} overlaps the pet and ${actor.name}',
          );
        }
        for (var i = 0; i < actorRects.length; i++) {
          for (var j = i + 1; j < actorRects.length; j++) {
            expect(
              _hasSubstantialOverlap(actorRects[i].rect, actorRects[j].rect),
              isFalse,
              reason:
                  '${scenario.name} overlaps ${actorRects[i].name} and '
                  '${actorRects[j].name}',
            );
          }
        }
        final decorRects =
            <({YardSlotView slot, int targetPos, Rect rawRect, Rect rect})>[
              for (final entry in decorFinders)
                (
                  slot: entry.slot,
                  targetPos: entry.targetPos,
                  rawRect: tester.getRect(entry.finder),
                  rect: _visualSubjectRect(tester.getRect(entry.finder)),
                ),
            ];
        final placementIssues = <String>[];
        for (var i = 0; i < decorRects.length; i++) {
          final current = decorRects[i];
          // 6/7 are the back row that sits behind the pet; 4/5 are the near
          // foreground; 2/3 flank the pet; 0/1 are the upper side pair.
          final minimumBaseline =
              current.targetPos >= 4 && current.targetPos <= 5
              ? foregroundStart
              : current.targetPos >= 2 && current.targetPos <= 3
              ? sideGroundStart
              : farGroundStart;
          if (current.rawRect.bottom < minimumBaseline) {
            placementIssues.add(
              'slot ${current.slot.pos}->${current.targetPos} floats above '
              'its depth band: '
              '${current.rawRect}',
            );
          }
          if (current.rawRect.bottom > actionBarTop - 8) {
            placementIssues.add(
              'slot ${current.slot.pos} is hidden by the action bar: '
              '${current.rawRect}',
            );
          }
          if (current.rawRect.left < yardRect.left + 8 ||
              current.rawRect.right > yardRect.right - 8) {
            placementIssues.add(
              'slot ${current.slot.pos} is clipped by the scene edge: '
              '${current.rawRect}',
            );
          }
          if (_hasSubstantialOverlap(current.rect, petRect)) {
            placementIssues.add(
              'slot ${current.slot.pos} overlaps pet: ${current.rect}',
            );
          }
          for (final actor in actorRects) {
            if (_hasSubstantialOverlap(current.rect, actor.rect)) {
              placementIssues.add(
                'slot ${current.slot.pos} overlaps ${actor.name}: '
                '${current.rect}',
              );
            }
          }
          for (var j = i + 1; j < decorRects.length; j++) {
            final other = decorRects[j];
            if (_hasSubstantialOverlap(current.rect, other.rect)) {
              placementIssues.add(
                'slots ${current.slot.pos}/${other.slot.pos} overlap: '
                '${current.rect} / ${other.rect}',
              );
            }
          }
        }
        expect(
          placementIssues,
          isEmpty,
          reason:
              '${scenario.name} placement issues (ground bands start at '
              '$farGroundStart/$sideGroundStart/$foregroundStart, '
              'action bar starts at $actionBarTop, pet: '
              '$petRect, side actors: $actorRects):\n'
              '${placementIssues.join('\n')}\nall decor:\n'
              '${decorRects.map((entry) => '${entry.slot.pos}->${entry.targetPos}: ${entry.rect}').join('\n')}',
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

    if (_catalogMode.isEmpty &&
        !_placementRegression &&
        !_allThemes &&
        !_allLuxury) {
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
