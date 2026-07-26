import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/ui/petopia_theme.dart';
import 'package:petopia/ui/postcard_viewer_screen.dart';

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'postcard',
);
const _landscape = bool.fromEnvironment('PETOPIA_VISUAL_LANDSCAPE');

final _cards = <PostcardView>[
  PostcardView(
    id: 'pc-visual-cat',
    petId: 'pet-cat-visual',
    petName: '阿橘',
    speciesId: 'pet_cat',
    variantId: 'pet_cat_v1',
    poseHint: 'gaze',
    locationName: '灯塔海湾',
    bodyText: '今天沿着海湾走了很久，风把云吹得软软的。灯塔旁边有一小片花，我在那里坐了一会儿，想起院子里的草地。',
    photoBg: 'pc_bg_lighthouse_bay',
    stampId: 'pc_stamp_lighthouse_bay',
    stickerIds: const ['pc_sticker_drift_bottle'],
    sentAt: DateTime.utc(2026, 7, 26),
    seq: 2,
  ),
  PostcardView(
    id: 'pc-visual-rabbit',
    petId: 'pet-rabbit-visual',
    petName: '云朵',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v2',
    poseHint: 'photo',
    locationName: '云端牧场',
    bodyText: '云像刚晒好的被子一样软。我背着包坐在山坡下，看风把远处的草一层层吹亮，也替你留了一小块安静的天空。',
    photoBg: 'pc_bg_cloud_ranch',
    stampId: 'pc_stamp_cloud_ranch',
    stickerIds: const ['pc_sticker_cloud_gap'],
    sentAt: DateTime.utc(2026, 7, 27),
    seq: 8,
  ),
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render postcard arrival art on device', (tester) async {
    await SystemChrome.setPreferredOrientations([
      _landscape
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp,
    ]);
    await tester.pump(const Duration(milliseconds: 800));

    for (final card in _cards) {
      await tester.pumpWidget(_VisualHost(card: card));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey<String>('open_postcard')));
      await tester.pump(const Duration(milliseconds: 500));
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await tester.pump();

      expect(find.textContaining(card.petName), findsWidgets);
      expect(tester.takeException(), isNull);
      await _capture(tester, binding, card.id);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}

class _VisualHost extends StatelessWidget {
  const _VisualHost({required this.card});

  final PostcardView card;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey<String>(card.id),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PetopiaColors.actionAccent,
          surface: PetopiaColors.paper,
        ),
        scaffoldBackgroundColor: PetopiaColors.background,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/art/world/themes/yard_theme_sakura_bg.webp',
                fit: BoxFit.cover,
              ),
              Center(
                child: FilledButton(
                  key: const ValueKey<String>('open_postcard'),
                  onPressed: () => showPostcardArrivalDialog(context, card),
                  child: const Text('打开明信片'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 120));
  final bytes = await binding.takeScreenshot('$_prefix-$name');
  final directory = Directory('/tmp/petopia-postcard-visual')
    ..createSync(recursive: true);
  File('${directory.path}/$_prefix-$name.png').writeAsBytesSync(bytes);
}
