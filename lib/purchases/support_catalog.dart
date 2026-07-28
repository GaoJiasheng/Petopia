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
    subtitle: '点心会在院子里留到明天，宠物也会收到一份开心。',
    assetPath: 'assets/runtime/support/support_treat.webp',
    thankYou: '点心已经放好。它闻到了香味，也知道有人惦记这个小院。',
    fallbackPrice: r'$0.99',
    duration: Duration(hours: 24),
  );

  static const lantern = SupportProductSpec(
    kind: SupportProductKind.lantern,
    id: 'com.petopia.petopia.support.lantern',
    title: '点亮一盏暖灯',
    subtitle: '守护灯会亮到明天，让晚归的伙伴看清回家的路。',
    assetPath: 'assets/runtime/support/support_lantern.webp',
    thankYou: '今晚的灯会亮得久一点。谢谢你让回家的路更暖。',
    fallbackPrice: r'$2.99',
    duration: Duration(hours: 24),
  );

  static const bouquet = SupportProductSpec(
    kind: SupportProductKind.bouquet,
    id: 'com.petopia.petopia.support.bouquet',
    title: '送来一篮花',
    subtitle: '鲜花会在院子里盛开七天，替大家安静地说声谢谢。',
    assetPath: 'assets/runtime/support/support_bouquet.webp',
    thankYou: '花已经放进院子。接下来七天，它会替我们向你说谢谢。',
    fallbackPrice: r'$4.99',
    duration: Duration(days: 7),
  );

  static const guardian = SupportProductSpec(
    kind: SupportProductKind.guardian,
    id: 'com.petopia.petopia.support.guardian',
    title: '成为小院守护者',
    subtitle: '永久点亮守护灯，并收下一枚徽章和一张特别来信。',
    assetPath: 'assets/runtime/support/support_guardian_badge.webp',
    thankYou: '谢谢你让院子里的灯一直亮着。我们会替你照顾花，也会记得每天等你回来。',
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
