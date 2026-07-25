import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:petopia/main.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install reaches every critical first-session screen', (
    tester,
  ) async {
    await _clearLocalState();
    await tester.pumpWidget(const ProviderScope(child: PetopiaApp()));

    await _pumpUntil(tester, find.text('院子醒来了'));
    expect(find.text('跳过'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, binding, 'onboarding');

    await tester.tap(find.text('跳过'));
    await _pumpUntil(tester, find.text('领养新伙伴'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('橘猫'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('adopt_choice_pet_cat')));
    await tester.pump(const Duration(milliseconds: 250));
    final adoptButton = find.byKey(const ValueKey('adopt_confirm'));
    await tester.ensureVisible(adoptButton);
    await tester.tap(adoptButton);

    await _pumpUntil(tester, find.textContaining('Lv 1'));
    await tester.pump(const Duration(seconds: 1));
    await _capture(tester, binding, 'arrival');
    await _dismissArrivalDialogs(tester);
    expect(find.byKey(const ValueKey('pet_info_card')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, binding, 'yard');

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
      await _pumpUntil(tester, animation);
      expect(tester.takeException(), isNull);
      await _capture(tester, binding, 'interaction-${interaction.$2}');
      await _pumpUntilGone(
        tester,
        animation,
        timeout: const Duration(seconds: 8),
      );
    }

    await tester.tap(find.byKey(const ValueKey('pet_info_card')));
    await _pumpUntil(tester, find.text('翻开成长手账'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('相伴 1 天'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, binding, 'pet-detail');

    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await _pumpUntil(tester, find.byKey(const ValueKey('home_menu')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('home_menu')));
    await tester.pump(const Duration(milliseconds: 400));
    final settingsItem = find.byKey(const ValueKey('menu_settings'));
    await _pumpUntil(tester, settingsItem);
    await tester.ensureVisible(settingsItem);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(settingsItem);

    await _pumpUntil(tester, find.text('温柔提醒'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('存档与隐私'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('隐私说明'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('隐私说明'), findsOneWidget);
    expect(find.text('帮助与支持'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, binding, 'settings');

    // Dispose providers before the test binding performs its final scheduler
    // assertion so native audio position callbacks have one frame to stop.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}

const _captureScreenshots = bool.fromEnvironment('PETOPIA_CAPTURE_SCREENSHOTS');
const _capturePrefix = String.fromEnvironment(
  'PETOPIA_CAPTURE_PREFIX',
  defaultValue: 'petopia',
);

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  if (!_captureScreenshots) return;
  for (var frame = 0; frame < 10; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await Future<void>.delayed(const Duration(milliseconds: 500));
  await tester.pump();
  final bytes = await binding.takeScreenshot('$_capturePrefix-$name');
  await File('/tmp/$_capturePrefix-$name.png').writeAsBytes(bytes, flush: true);
}

Future<void> _dismissArrivalDialogs(WidgetTester tester) async {
  const labels = <String>[
    '和它打个招呼',
    '收进来客图鉴',
    '欢迎它',
    '欢迎回家',
    '在院子里好好休息',
    '记进手账',
    '收进相册',
  ];
  for (var pass = 0; pass < 6; pass++) {
    Finder? target;
    for (final label in labels) {
      final candidate = find.text(label);
      if (candidate.evaluate().isNotEmpty) {
        target = candidate.last;
        break;
      }
    }
    if (target == null) return;
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 800));
  }
}

Future<void> _clearLocalState() async {
  final documents = await getApplicationDocumentsDirectory();
  final saveDir = Directory(p.join(documents.path, 'save'));
  if (await saveDir.exists()) {
    await saveDir.delete(recursive: true);
  }
  await deleteDatabase(p.join(await getDatabasesPath(), 'petopia_logs.db'));
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
}

Future<void> _pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isNotEmpty && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsNothing);
}
