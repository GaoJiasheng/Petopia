import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_error_log.dart';
import 'app/app_brand.dart';
import 'app/game_controller.dart';
import 'app/startup_metrics.dart';
import 'audio/route_audio.dart';
import 'domain/enums.dart';
import 'l10n/petopia_localizations.dart';
import 'ui/image_cache_policy.dart';
import 'ui/petopia_theme.dart';
import 'ui/yard_home_screen.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      StartupMetrics.start();
      final views = PlatformDispatcher.instance.views;
      final logicalShortestSide = views.isEmpty
          ? 390.0
          : views.first.physicalSize.shortestSide /
                views.first.devicePixelRatio;
      PaintingBinding.instance.imageCache
        ..maximumSize = ImageCachePolicy.maximumEntries(logicalShortestSide)
        ..maximumSizeBytes = ImageCachePolicy.maximumBytes(logicalShortestSide);
      unawaited(AppErrorLog.instance.initialize());
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppErrorLog.instance.record(
          details.exception,
          details.stack ?? StackTrace.current,
          source: 'flutter',
        );
        debugPrint(
          '${AppBrand.englishName} Flutter error: ${details.exceptionAsString()}',
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppErrorLog.instance.record(error, stackTrace, source: 'platform');
        debugPrint(
          '${AppBrand.englishName} platform error: $error\n$stackTrace',
        );
        return true;
      };
      runApp(const ProviderScope(child: PetopiaApp()));
    },
    (error, stackTrace) {
      AppErrorLog.instance.record(error, stackTrace, source: 'zone');
      debugPrint('${AppBrand.englishName} zone error: $error\n$stackTrace');
    },
  );
}

/// App 根组件。
class PetopiaApp extends ConsumerWidget {
  const PetopiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguage = ref.watch(
      gameControllerProvider.select(
        (value) => value.valueOrNull?.appLanguage ?? AppLanguage.system,
      ),
    );
    return MaterialApp(
      title: AppBrand.englishName,
      debugShowCheckedModeBanner: false,
      locale: PetopiaLocalizations.localeFor(appLanguage),
      supportedLocales: PetopiaLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) =>
          PetopiaLocalizations.resolveDeviceLocale(
            deviceLocale,
            supportedLocales,
          ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        PetopiaLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: PetopiaSystemUi.lightSurface(),
        child: child ?? const SizedBox.shrink(),
      ),
      navigatorObservers: <NavigatorObserver>[petopiaRouteObserver],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PetopiaColors.actionAccent,
          brightness: Brightness.light,
          surface: PetopiaColors.paper,
        ),
        scaffoldBackgroundColor: PetopiaColors.background,
        fontFamily: null,
        visualDensity: VisualDensity.standard,
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
      home: const YardHomeScreen(),
    );
  }
}
