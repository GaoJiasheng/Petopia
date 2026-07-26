import '../domain/enums.dart';

abstract final class YardRenderPolicy {
  static bool conserveMemory(
    RenderQuality quality, {
    required bool memoryPressure,
  }) {
    return quality == RenderQuality.low || memoryPressure;
  }

  static int actionPreloadLimit(
    RenderQuality quality, {
    required bool memoryPressure,
  }) {
    if (memoryPressure) return 0;
    return switch (quality) {
      RenderQuality.low => 0,
      RenderQuality.auto => 2,
      RenderQuality.high => 4,
    };
  }

  static double actionPreloadBudgetFraction(
    RenderQuality quality, {
    required bool memoryPressure,
  }) {
    if (memoryPressure || quality == RenderQuality.low) return 0;
    return quality == RenderQuality.high ? 0.84 : 0.72;
  }

  static bool useBackdropBlur(
    RenderQuality quality, {
    required bool memoryPressure,
  }) {
    return quality != RenderQuality.low && !memoryPressure;
  }
}
