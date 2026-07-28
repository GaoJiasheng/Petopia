import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petopia/app/app_info.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/ui/settings_screen.dart';
import 'package:petopia/ui/shop_screen.dart';
import 'package:petopia/ui/visitor_dex_screen.dart';

class _VisualController extends GameController {
  @override
  Future<GameView> build() async => const GameView(
    pet: null,
    wallet: 420,
    luxuryStage: 3,
    cooldownSec: <CareAction, int>{},
    dailyMaxed: <CareAction>{},
    canGraduate: false,
    activeThemeId: 'theme_meadow',
    decorSlots: <YardSlotView>[],
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: 3,
    appLanguage: AppLanguage.en,
  );

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
      owned: false,
      affordable: true,
      consumable: false,
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
  List<VisitorDexView> visitorDex() => <VisitorDexView>[
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
      id: 'visitor_squirrel',
      name: '松鼠栗栗',
      rarity: VisitorRarity.common,
      collected: true,
      count: 2,
      firstSeen: DateTime.utc(2026, 7, 21),
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
    VisitorDexView(
      id: 'visitor_night_blob',
      name: '深夜白团子',
      rarity: VisitorRarity.legendary,
      collected: false,
      count: 0,
      firstSeen: null,
      memories: const <VisitorMemoryView>[],
    ),
  ];
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
      theme: ThemeData(useMaterial3: true),
      home: screen,
    );
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('English UI visual review on real iOS surfaces', (tester) async {
    for (final (name, screen) in <(String, Widget)>[
      ('settings', const SettingsScreen()),
      ('shop', const ShopScreen()),
      ('visitors', const VisitorDexScreen()),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            gameControllerProvider.overrideWith(_VisualController.new),
            appInfoProvider.overrideWith(
              (ref) async => const AppInfo(version: '1.0.0', buildNumber: '18'),
            ),
          ],
          child: _EnglishHost(screen: screen),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _capture(binding, tester, name);
    }
  });
}

const _capturePrefix = String.fromEnvironment(
  'PETOPIA_CAPTURE_PREFIX',
  defaultValue: 'petopia-localization',
);

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 500));
  await binding.takeScreenshot('$_capturePrefix-$name');
}
