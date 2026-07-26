import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/ui/yard_render_policy.dart';

void main() {
  test('render quality tiers have distinct action preload budgets', () {
    expect(
      YardRenderPolicy.actionPreloadLimit(
        RenderQuality.low,
        memoryPressure: false,
      ),
      0,
    );
    expect(
      YardRenderPolicy.actionPreloadLimit(
        RenderQuality.auto,
        memoryPressure: false,
      ),
      2,
    );
    expect(
      YardRenderPolicy.actionPreloadLimit(
        RenderQuality.high,
        memoryPressure: false,
      ),
      4,
    );
    expect(
      YardRenderPolicy.actionPreloadBudgetFraction(
        RenderQuality.high,
        memoryPressure: false,
      ),
      greaterThan(
        YardRenderPolicy.actionPreloadBudgetFraction(
          RenderQuality.auto,
          memoryPressure: false,
        ),
      ),
    );
  });

  test('memory pressure overrides every quality tier', () {
    for (final quality in RenderQuality.values) {
      expect(
        YardRenderPolicy.conserveMemory(quality, memoryPressure: true),
        isTrue,
      );
      expect(
        YardRenderPolicy.actionPreloadLimit(quality, memoryPressure: true),
        0,
      );
      expect(
        YardRenderPolicy.useBackdropBlur(quality, memoryPressure: true),
        isFalse,
      );
    }
  });

  test('low quality avoids blur without changing auto and high', () {
    expect(
      YardRenderPolicy.useBackdropBlur(
        RenderQuality.low,
        memoryPressure: false,
      ),
      isFalse,
    );
    expect(
      YardRenderPolicy.useBackdropBlur(
        RenderQuality.auto,
        memoryPressure: false,
      ),
      isTrue,
    );
    expect(
      YardRenderPolicy.useBackdropBlur(
        RenderQuality.high,
        memoryPressure: false,
      ),
      isTrue,
    );
  });
}
