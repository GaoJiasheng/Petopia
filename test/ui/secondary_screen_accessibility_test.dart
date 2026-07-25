import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/app_info.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/achievements_screen.dart';
import 'package:petopia/ui/album_screen.dart';
import 'package:petopia/ui/pet_dex_screen.dart';
import 'package:petopia/ui/postcard_viewer_screen.dart';
import 'package:petopia/ui/settings_screen.dart';
import 'package:petopia/ui/shop_screen.dart';
import 'package:petopia/ui/visitor_dex_screen.dart';

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

class _FixtureController extends GameController {
  static final postcard = PostcardView(
    id: 'postcard-test',
    petId: 'pet-test',
    journeyId: 'journey-test',
    petName: '云朵',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v1',
    poseHint: 'gaze',
    locationName: '灯塔海湾',
    bodyText: '海风把云吹得软软的，我在灯塔边坐了一会儿，也想起了院子里的花。',
    photoBg: 'pc_bg_lighthouse_bay',
    stampId: 'pc_stamp_lighthouse_bay',
    stickerIds: const <String>[],
    sentAt: DateTime.utc(2026, 7, 20),
    seq: 2,
  );

  static final fixture = GameView(
    pet: null,
    wallet: 420,
    luxuryStage: 3,
    cooldownSec: const <CareAction, int>{},
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
  String get activeAlbumSkinId => 'default';

  @override
  List<AlbumSkinView> albumSkins() => const <AlbumSkinView>[
    AlbumSkinView(id: 'default', name: '奶油手账', active: true),
  ];

  @override
  void applyAlbumSkin(String skinId) {}

  @override
  void applyTheme(String themeId) {}

  @override
  List<PostcardView> postcards() => <PostcardView>[postcard];

  @override
  List<TravelPetView> travelAlbum() => <TravelPetView>[
    TravelPetView(
      petId: 'pet-test',
      speciesId: 'pet_rabbit',
      variantId: 'pet_rabbit_v1',
      name: '云朵',
      graduatedAt: DateTime.utc(2026, 7, 1),
      stops: 40,
      postcardCount: 3,
      completedStops: 7,
      journeyState: JourneyState.active,
    ),
  ];

  @override
  List<DexEntryView> petDex() => const <DexEntryView>[
    DexEntryView(
      speciesId: 'pet_rabbit',
      name: '垂耳兔',
      category: PetCategory.real,
      baseTone: '安静、柔软，也会认真听院子里的每一种声音。',
      state: DexState.ownedBefore,
    ),
  ];

  @override
  List<VisitorDexView> visitorDex() => <VisitorDexView>[
    VisitorDexView(
      id: 'visitor_calico',
      name: '流浪三花猫',
      rarity: VisitorRarity.uncommon,
      collected: true,
      count: 2,
      firstSeen: DateTime.utc(2026, 7, 2),
      memories: <VisitorMemoryView>[
        VisitorMemoryView(
          date: DateTime.utc(2026, 7, 2),
          petName: '云朵',
          script: '它在花丛边坐了一会儿。',
          expReward: 2,
        ),
      ],
    ),
  ];

  @override
  List<AchievementView> achievementsView() => const <AchievementView>[
    AchievementView(
      id: 'ach-test',
      name: '一路有花',
      hidden: false,
      unlocked: false,
      progress: 3,
      target: 12,
      clueText: '陪不同的伙伴慢慢长大。',
      rewardFluff: 30,
      rewardSummary: '一枚花朵纪念章',
      rewardClaimed: false,
    ),
  ];

  @override
  List<ShopItemView> shopItems() => const <ShopItemView>[
    ShopItemView(
      id: 'food_apple_test',
      name: '苹果小点心',
      category: '食物',
      artRef: '',
      effectType: EffectType.feedBonus,
      effectSummary: '下一次喂食时，多留下一点暖暖的陪伴。',
      price: 20,
      originalPrice: 20,
      owned: false,
      affordable: true,
      consumable: true,
    ),
  ];

  @override
  bool get musicOn => true;

  @override
  bool get effectsOn => true;

  @override
  bool get hapticsOn => true;

  @override
  bool get notificationsOn => false;

  @override
  bool get postcardNotificationsOn => true;

  @override
  bool get visitorNotificationsOn => true;

  @override
  bool get eventNotificationsOn => true;

  @override
  void trackAlbumOpened() {}

  @override
  void trackPostcardRead(String postcardId) {}
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required Widget screen,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.platformDispatcher.textScaleFactorTestValue = 3.2;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        gameControllerProvider.overrideWith(_FixtureController.new),
        audioServiceProvider.overrideWithValue(_SilentAudio()),
        appInfoProvider.overrideWith(
          (ref) async => const AppInfo(version: '1.0.0', buildNumber: '15'),
        ),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final screens = <(String, Widget)>[
    ('album', const AlbumScreen()),
    ('pet dex', const PetDexScreen()),
    ('visitor dex', const VisitorDexScreen()),
    ('achievements', const AchievementsScreen()),
    ('shop', const ShopScreen()),
    ('settings', const SettingsScreen()),
    ('postcard', PostcardViewerScreen(card: _FixtureController.postcard)),
  ];

  testWidgets('secondary screens support the largest accessibility text', (
    tester,
  ) async {
    for (final size in const <Size>[Size(393, 852), Size(1194, 834)]) {
      for (final (name, screen) in screens) {
        await _pump(tester, size: size, screen: screen);
        expect(
          tester.takeException(),
          isNull,
          reason: '$name overflowed at $size',
        );
      }
    }
  });

  testWidgets('settings keeps support diagnostics reachable at large text', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(393, 852),
      screen: const SettingsScreen(),
    );
    await tester.scrollUntilVisible(
      find.text('导出诊断信息'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('导出诊断信息'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('album travel tab adapts on phone and iPad at large text', (
    tester,
  ) async {
    for (final size in const <Size>[Size(393, 852), Size(1194, 834)]) {
      await _pump(tester, size: size, screen: const AlbumScreen());
      await tester.tap(find.text('旅行伙伴'));
      await tester.pumpAndSettle();
      expect(find.text('云朵'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'travel tab overflowed at $size',
      );
    }
  });

  testWidgets('visitor memory panel remains readable at large text', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(393, 852),
      screen: const VisitorDexScreen(),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.tap(find.text('流浪三花猫'));
    await tester.pumpAndSettle();
    expect(find.text('流浪三花猫的来访手账'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('相遇回忆'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('相遇回忆'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('travel journey sheet remains usable at large text', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(393, 852),
      screen: const AlbumScreen(),
    );
    await tester.tap(find.text('旅行伙伴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('云朵'));
    await tester.pumpAndSettle();
    expect(find.text('云朵的旅程'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('postcard arrival dialog scrolls cleanly at large text', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(393, 852),
      screen: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showPostcardArrivalDialog(context, _FixtureController.postcard),
            child: const Text('打开明信片'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开明信片'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('收进相册'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collection content exposes concise VoiceOver labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await _pump(
      tester,
      size: const Size(393, 852),
      screen: const PetDexScreen(),
    );
    expect(find.bySemanticsLabel(RegExp('垂耳兔.*已养过')), findsOneWidget);

    await _pump(
      tester,
      size: const Size(393, 852),
      screen: const AchievementsScreen(),
    );
    expect(find.bySemanticsLabel(RegExp('一路有花.*进度 3 / 12')), findsOneWidget);

    await _pump(
      tester,
      size: const Size(393, 852),
      screen: PostcardViewerScreen(card: _FixtureController.postcard),
    );
    expect(find.bySemanticsLabel('灯塔海湾的旅行风景'), findsOneWidget);

    semantics.dispose();
  });
}
