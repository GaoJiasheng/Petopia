import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/ui/postcard_viewer_screen.dart';

void main() {
  final card = PostcardView(
    id: 'pc-test',
    petName: '阿橘',
    speciesId: 'pet_cat',
    variantId: 'pet_cat_v1',
    poseHint: 'gaze',
    locationName: '灯塔海湾',
    bodyText: '今天沿着海湾走了很久，风把云吹得软软的。灯塔旁边有一小片花，我在那里坐了一会儿，想起院子里的草地。',
    photoBg: 'pc_bg_seaside_lighthouse',
    stampId: 'pc_stamp_seaside_lighthouse',
    stickerIds: const [],
    sentAt: DateTime.utc(2026, 7, 13),
    seq: 2,
  );

  Future<void> pumpAtSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: PostcardDisplayCard(card: card, arrivalMode: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('postcard card lays out on iPad portrait', (tester) async {
    await pumpAtSize(tester, const Size(1032, 1376));
    expect(find.textContaining('阿橘'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('postcard card switches to wide layout on iPad landscape', (
    tester,
  ) async {
    await pumpAtSize(tester, const Size(1376, 1032));
    expect(find.textContaining('灯塔'), findsOneWidget);
    expect(find.textContaining('阿橘'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('postcard arrival dialog has a Material text ancestor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPostcardArrivalDialog(context, card),
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final renderedText = tester.widgetList<RichText>(find.byType(RichText));
    expect(renderedText, isNotEmpty);
    for (final richText in renderedText) {
      expect(richText.text.style?.decoration, isNot(TextDecoration.underline));
    }
    expect(tester.takeException(), isNull);
  });
}
