import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/english_copy.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/l10n/petopia_text.dart';

void main() {
  group('PetopiaLocalizations', () {
    const english = PetopiaLocalizations(Locale('en'));
    const chinese = PetopiaLocalizations(Locale('zh', 'CN'));

    test('maps persisted language modes to app locales', () {
      expect(PetopiaLocalizations.localeFor(AppLanguage.system), isNull);
      expect(
        PetopiaLocalizations.localeFor(AppLanguage.zhHans),
        const Locale('zh', 'CN'),
      );
      expect(
        PetopiaLocalizations.localeFor(AppLanguage.en),
        const Locale('en'),
      );
    });

    test('uses Chinese for Chinese devices and English as global fallback', () {
      expect(
        PetopiaLocalizations.resolveDeviceLocale(
          const Locale('zh', 'SG'),
          PetopiaLocalizations.supportedLocales,
        ),
        const Locale('zh', 'CN'),
      );
      expect(
        PetopiaLocalizations.resolveDeviceLocale(
          const Locale('en', 'GB'),
          PetopiaLocalizations.supportedLocales,
        ),
        const Locale('en'),
      );
      expect(
        PetopiaLocalizations.resolveDeviceLocale(
          const Locale('fr', 'FR'),
          PetopiaLocalizations.supportedLocales,
        ),
        const Locale('en'),
      );
    });

    test('keeps Chinese canonical copy unchanged', () {
      expect(chinese.text('设置'), '设置');
      expect(chinese.text('灯塔湾'), '灯塔湾');
    });

    test('selects explicit bilingual narrative by locale', () {
      expect(chinese.bilingual(zhHans: '新睡姿', en: 'A New Sleep Pose'), '新睡姿');
      expect(
        english.bilingual(zhHans: '新睡姿', en: 'A New Sleep Pose'),
        'A New Sleep Pose',
      );
    });

    test('translates polished UI, content names, and dynamic copy', () {
      expect(english.text('设置'), 'Settings');
      expect(english.text('支持小院'), 'Support the Garden');
      expect(english.text('灯塔湾'), 'Lighthouse Bay');
      expect(english.text('流浪三花猫'), 'Wandering Calico');
      expect(english.text('樱花小径'), 'Cherry Blossom Path');
      expect(
        english.text('打开小橘从灯塔湾寄来的第 3 张明信片'),
        'Open postcard 3 from Tangerine in Lighthouse Bay',
      );
      expect(
        english.text('摸头，今天更合它心意，增加4点经验'),
        'Pet was just right today · +4 XP',
      );
      expect(
        english.text('小橘的旅程，已走过 7 / 40 站，已寄回 3 张明信片'),
        "Tangerine's journey · 7 of 40 stops · 3 postcards",
      );
      expect(english.text('7月21日'), '7/21');
      expect(english.text('喂食 +3'), 'Feed +3');
    });

    test('leaves unknown player-authored copy untouched', () {
      expect(english.text('我自己取的名字'), '我自己取的名字');
    });

    test('covers every achievement name and hidden clue', () async {
      final json =
          jsonDecode(await File('assets/data/achievements.json').readAsString())
              as Map<String, dynamic>;
      final items = json['items']! as List<dynamic>;

      for (final rawItem in items) {
        final item = rawItem! as Map<String, dynamic>;
        final name = item['name']! as String;
        expect(
          EnglishCopy.translate(name),
          isNot(name),
          reason: 'Missing English achievement name: $name',
        );

        final clue = item['clueText'] as String?;
        if (clue != null) {
          expect(
            EnglishCopy.translate(clue),
            isNot(clue),
            reason: 'Missing English achievement clue: $clue',
          );
        }
      }
    });
  });

  testWidgets('AppText localizes plain and rich text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: PetopiaLocalizations.supportedLocales,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          PetopiaLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Column(
            children: <Widget>[
              AppText('设置'),
              AppText.rich(
                TextSpan(
                  text: '语言',
                  children: <InlineSpan>[TextSpan(text: ' · 跟随系统')],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan?.toPlainText() == 'Language · Use Device Language',
      ),
      findsOneWidget,
    );
  });
}
