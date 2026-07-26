import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/ui/graduation_ceremony_screen.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = <Size>[
    Size(834, 1194),
    Size(1194, 834),
    Size(1024, 1366),
    Size(1366, 1024),
  ];

  testWidgets('graduation keeps the exact pet variant on iPad Pro 11/13', (
    tester,
  ) async {
    for (final size in sizes) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [audioServiceProvider.overrideWithValue(_SilentAudio())],
          child: const MaterialApp(
            home: GraduationCeremonyScreen(
              petName: '云朵',
              speciesId: 'pet_rabbit',
              variantId: 'pet_rabbit_v5',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 80));

      final assetNames = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .whereType<AssetImage>()
          .map((provider) => provider.assetName)
          .toList();
      expect(
        assetNames,
        contains('assets/runtime/pets/rabbit/pet_rabbit_var05_stageD.webp'),
        reason: 'variant must remain stable at $size',
      );
      expect(find.textContaining('云朵'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout overflow at $size',
      );
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('graduation route choice remains usable with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioServiceProvider.overrideWithValue(_SilentAudio())],
        child: MaterialApp(
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            );
          },
          home: const GraduationCeremonyScreen(
            petName: '云朵',
            speciesId: 'pet_rabbit',
            variantId: 'pet_rabbit_v5',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('海边'), findsOneWidget);
    expect(find.text('森林'), findsOneWidget);
    expect(find.text('城市'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.binding.setSurfaceSize(null);
  });
}
