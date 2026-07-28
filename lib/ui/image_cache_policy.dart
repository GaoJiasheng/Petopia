abstract final class ImageCachePolicy {
  static const _tabletThreshold = 600.0;

  static int maximumBytes(double logicalShortestSide) =>
      logicalShortestSide >= _tabletThreshold ? 96 << 20 : 72 << 20;

  static int maximumEntries(double logicalShortestSide) =>
      logicalShortestSide >= _tabletThreshold ? 320 : 240;
}
