import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/app_info.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/ui/settings_screen.dart';

class _LanguageController extends GameController {
  AppLanguage selected = AppLanguage.en;

  GameView _view() => GameView(
    pet: null,
    wallet: 0,
    luxuryStage: 0,
    cooldownSec: const <CareAction, int>{},
    dailyMaxed: const <CareAction>{},
    canGraduate: false,
    activeThemeId: 'theme_meadow',
    decorSlots: const <YardSlotView>[],
    weather: Weather.clear,
    onboardingComplete: true,
    needsFirstCare: false,
    careTutorialStep: 3,
    appLanguage: selected,
  );

  @override
  Future<GameView> build() async => _view();

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
  void setAppLanguage(AppLanguage language) {
    selected = language;
    state = AsyncData(_view());
  }
}

class _LocalizedSettingsHost extends ConsumerWidget {
  const _LocalizedSettingsHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(
      gameControllerProvider.select(
        (value) => value.valueOrNull?.appLanguage ?? AppLanguage.system,
      ),
    );
    return MaterialApp(
      locale: PetopiaLocalizations.localeFor(language),
      supportedLocales: PetopiaLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) =>
          PetopiaLocalizations.resolveDeviceLocale(locale, supported),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        PetopiaLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SettingsScreen(),
    );
  }
}

void main() {
  testWidgets('language choice updates the whole app locale immediately', (
    tester,
  ) async {
    late _LanguageController controller;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          gameControllerProvider.overrideWith(() {
            controller = _LanguageController();
            return controller;
          }),
          appInfoProvider.overrideWith(
            (ref) async => const AppInfo(version: '1.0.0', buildNumber: '18'),
          ),
        ],
        child: const _LocalizedSettingsHost(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.text('Simplified Chinese'));
    await tester.pumpAndSettle();

    expect(controller.selected, AppLanguage.zhHans);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
  });

  testWidgets('Traditional Chinese choice updates settings immediately', (
    tester,
  ) async {
    late _LanguageController controller;
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          gameControllerProvider.overrideWith(() {
            controller = _LanguageController();
            return controller;
          }),
          appInfoProvider.overrideWith(
            (ref) async => const AppInfo(version: '1.0.0', buildNumber: '34'),
          ),
        ],
        child: const _LocalizedSettingsHost(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Traditional Chinese'));
    await tester.pumpAndSettle();

    expect(controller.selected, AppLanguage.zhHant);
    expect(find.text('設定'), findsOneWidget);
    expect(find.text('語言'), findsOneWidget);
    expect(find.text('固定使用繁體中文。'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('回報問題'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('回報問題'), findsOneWidget);
  });
}
