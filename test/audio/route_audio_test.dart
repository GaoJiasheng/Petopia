import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/audio/audio_service.dart';
import 'package:petopia/audio/route_audio.dart';

class _RecordingAudio implements AudioService {
  final List<Bgm> played = <Bgm>[];

  @override
  bool get effectsEnabled => true;

  @override
  bool get musicEnabled => true;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> pauseForInterruption() async {}

  @override
  Future<void> playBgm(Bgm bgm) async => played.add(bgm);

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

class _AudioPage extends ConsumerStatefulWidget {
  const _AudioPage({required this.bgm, this.next});

  final Bgm bgm;
  final Bgm? next;

  @override
  ConsumerState<_AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends ConsumerState<_AudioPage>
    with RouteAudio<_AudioPage> {
  @override
  Bgm get routeBgm => widget.bgm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.next == null
            ? const Text('leaf')
            : FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _AudioPage(bgm: widget.next!),
                  ),
                ),
                child: const Text('open'),
              ),
      ),
    );
  }
}

void main() {
  testWidgets('page music switches on push and restores after pop', (
    tester,
  ) async {
    final audio = _RecordingAudio();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[audioServiceProvider.overrideWithValue(audio)],
        child: MaterialApp(
          navigatorObservers: <NavigatorObserver>[petopiaRouteObserver],
          home: const _AudioPage(bgm: Bgm.opening, next: Bgm.shop),
        ),
      ),
    );
    await tester.pump();
    expect(audio.played.last, Bgm.opening);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(audio.played.last, Bgm.shop);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(audio.played.last, Bgm.opening);
  });
}
