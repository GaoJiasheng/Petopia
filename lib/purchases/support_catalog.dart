enum SupportProductKind { treat, lantern, bouquet, guardian }

class SupportProductSpec {
  const SupportProductSpec({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.thankYou,
    required this.fallbackPrice,
    this.duration,
    this.consumable = true,
  });

  final SupportProductKind kind;
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String thankYou;
  final String fallbackPrice;
  final Duration? duration;
  final bool consumable;
}

abstract final class SupportCatalog {
  static const treat = SupportProductSpec(
    kind: SupportProductKind.treat,
    id: 'com.petopia.petopia.support.treat',
    title: '一份小点心',
    subtitle: '点心会在院子里保留 24 小时，伙伴也会来尝一口。',
    assetPath: 'assets/runtime/support/support_treat.webp',
    thankYou: '点心已经放进院子，将保留 24 小时。感谢你的支持。',
    fallbackPrice: r'$0.99',
    duration: Duration(hours: 24),
  );

  static const lantern = SupportProductSpec(
    kind: SupportProductKind.lantern,
    id: 'com.petopia.petopia.support.lantern',
    title: '点亮一盏暖灯',
    subtitle: '暖灯会在院子里亮 24 小时。',
    assetPath: 'assets/runtime/support/support_lantern.webp',
    thankYou: '暖灯已经点亮，将持续 24 小时。感谢你的支持。',
    fallbackPrice: r'$2.99',
    duration: Duration(hours: 24),
  );

  static const bouquet = SupportProductSpec(
    kind: SupportProductKind.bouquet,
    id: 'com.petopia.petopia.support.bouquet',
    title: '送来一篮花',
    subtitle: '花篮会在院子里展示七天。',
    assetPath: 'assets/runtime/support/support_bouquet.webp',
    thankYou: '花篮已经放进院子，会展示七天。感谢你的支持。',
    fallbackPrice: r'$4.99',
    duration: Duration(days: 7),
  );

  static const guardian = SupportProductSpec(
    kind: SupportProductKind.guardian,
    id: 'com.petopia.petopia.support.guardian',
    title: '小院守护者',
    subtitle: '永久点亮守护灯，并解锁纪念徽章和一张特别来信。',
    assetPath: 'assets/runtime/support/support_guardian_badge.webp',
    thankYou: '感谢你支持暖绒小院。守护灯、纪念徽章和特别来信已经解锁。',
    fallbackPrice: r'$6.99',
    consumable: false,
  );

  static const all = <SupportProductSpec>[treat, lantern, bouquet, guardian];

  static final ids = <String>{treat.id, lantern.id, bouquet.id, guardian.id};

  static SupportProductSpec? byId(String id) {
    for (final product in all) {
      if (product.id == id) return product;
    }
    return null;
  }
}
