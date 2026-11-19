import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lists the asset names of images that VoiceOver would read as a bare
/// "image": the picture reaches the accessibility tree, but neither it nor the
/// node it merges into carries a label.
///
/// Decorative pictures must set `excludeFromSemantics`; meaningful ones need a
/// `semanticLabel`. Requires an active `tester.ensureSemantics()` handle.
List<String> unlabeledImageAssets(WidgetTester tester) {
  final hits = <String>{};
  for (final element in find.byType(Image).evaluate()) {
    final image = element.widget as Image;
    if (image.excludeFromSemantics) continue;
    final data = tester
        .getSemantics(find.byWidget(image).first)
        .getSemanticsData();
    if (data.flagsCollection.isImage &&
        data.label.trim().isEmpty &&
        data.tooltip.trim().isEmpty) {
      hits.add(_assetName(image.image));
    }
  }
  return hits.toList()..sort();
}

String _assetName(ImageProvider provider) {
  final source = switch (provider) {
    ResizeImage(:final imageProvider) => imageProvider,
    _ => provider,
  };
  return source is AssetImage
      ? source.assetName.split('/').last
      : source.runtimeType.toString();
}
