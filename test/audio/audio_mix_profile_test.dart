import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/audio/audio_service.dart';

void main() {
  test('audio transition curve reaches both endpoints monotonically', () {
    final levels = <double>[
      for (var step = 0; step <= AudioMixProfile.bgmFadeInSteps; step++)
        AudioMixProfile.easedLevel(step, AudioMixProfile.bgmFadeInSteps),
    ];

    expect(levels.first, 0);
    expect(levels.last, 1);
    for (var index = 1; index < levels.length; index++) {
      expect(levels[index], greaterThan(levels[index - 1]));
    }
  });

  test('music and ambience transitions stay deliberately gentle', () {
    final bgmTransition =
        AudioMixProfile.bgmFadeOutSteps *
            AudioMixProfile.bgmFadeOutStep.inMilliseconds +
        AudioMixProfile.bgmFadeInSteps *
            AudioMixProfile.bgmFadeInStep.inMilliseconds;
    final ambienceTransition =
        (AudioMixProfile.ambienceFadeOutSteps +
            AudioMixProfile.ambienceFadeInSteps) *
        AudioMixProfile.ambienceFadeStep.inMilliseconds;

    expect(bgmTransition, inInclusiveRange(650, 850));
    expect(ambienceTransition, inInclusiveRange(550, 750));
  });
}
