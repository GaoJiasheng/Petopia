import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_error_log.dart';
import 'ui/yard_home_screen.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      PaintingBinding.instance.imageCache
        ..maximumSize = 320
        ..maximumSizeBytes = 96 << 20;
      unawaited(AppErrorLog.instance.initialize());
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppErrorLog.instance.record(
          details.exception,
          details.stack ?? StackTrace.current,
          source: 'flutter',
        );
        debugPrint('Petopia Flutter error: ${details.exceptionAsString()}');
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppErrorLog.instance.record(error, stackTrace, source: 'platform');
        debugPrint('Petopia platform error: $error\n$stackTrace');
        return true;
      };
      runApp(const ProviderScope(child: PetopiaApp()));
    },
    (error, stackTrace) {
      AppErrorLog.instance.record(error, stackTrace, source: 'zone');
      debugPrint('Petopia zone error: $error\n$stackTrace');
    },
  );
}

/// Petopia 根组件。
class PetopiaApp extends StatelessWidget {
  const PetopiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petopia',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const <Locale>[Locale('zh', 'CN')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A15C),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFDF7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF3E3),
        fontFamily: null,
        visualDensity: VisualDensity.standard,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE8A15C),
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
      home: const YardHomeScreen(),
    );
  }
}
