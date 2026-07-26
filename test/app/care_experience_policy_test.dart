import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';

void main() {
  test('第三种不同互动完成今日满足，重复动作不会重复触发', () {
    final counts = <String, int>{'feed': 1, 'pat': 2};

    expect(
      CareExperiencePolicy.completesVariety(counts, CareAction.toy),
      isTrue,
    );
    expect(
      CareExperiencePolicy.completesVariety(counts, CareAction.feed),
      isFalse,
    );

    counts['toy'] = 1;
    expect(CareExperiencePolicy.isContented(counts), isTrue);
    expect(
      CareExperiencePolicy.completesVariety(counts, CareAction.bath),
      isFalse,
    );
  });

  test('性格偏好映射到明确互动', () {
    expect(
      CareExperiencePolicy.preferredAction(const ['p_glutton', 'p_curious']),
      CareAction.feed,
    );
    expect(
      CareExperiencePolicy.preferredAction(const ['p_energetic', 'p_gentle']),
      CareAction.toy,
    );
    expect(
      CareExperiencePolicy.preferredAction(const ['p_lazy', 'p_dreamy']),
      CareAction.bath,
    );
    expect(
      CareExperiencePolicy.preferredAction(const ['p_gentle', 'p_curious']),
      CareAction.pat,
    );
  });
}
