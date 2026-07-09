import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/data/content/content_repository_impl.dart';

/// 端到端内容加载：用真实解析器加载 assets/data/*.json，
/// 验证 schemaVersion、枚举 byName、计数、抽查字段。任一枚举串味即抛错。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AssetContentRepository.loadAll 解析全部内容 JSON', () async {
    final repo = AssetContentRepository();
    await repo.loadAll();

    expect(repo.personalities.length, 10, reason: 'personalities');
    expect(repo.species.length, 12, reason: 'species');
    expect(repo.locations.length, 40, reason: 'locations');
    expect(repo.visitors.length, 20, reason: 'visitors');
    expect(repo.events.length, 120, reason: 'events(100+20)');
    expect(repo.achievements.length, 81, reason: 'achievements(51+30)');
    expect(repo.shopItems.length, 36, reason: 'shop_items');
    expect(
      repo.postcardTemplates.length,
      240,
      reason: 'postcard templates(80×3)',
    );
    expect(repo.encounters.length, 60, reason: 'encounters');
    expect(repo.incidents.length, 60, reason: 'incidents');

    // 明信片内容交叉引用：encounter.poolId 命中 Location.encounterPoolId；
    // incident.vibe 命中某地点 vibeTags（迁移后每类地点带规范 vibe）。
    final pools = repo.locations.map((l) => l.encounterPoolId).toSet();
    expect(
      repo.encounters.every((e) => pools.contains(e.poolId)),
      true,
      reason: 'every encounter pool matches a location',
    );
    final vibes = repo.locations.expand((l) => l.vibeTags).toSet();
    expect(
      repo.incidents.every((i) => vibes.contains(i.vibe)),
      true,
      reason: 'every incident vibe matches a location vibeTag',
    );
    expect(repo.postcardTemplates.first.slots, contains('petName'));

    for (final location in repo.locations) {
      expect(
        File(
          'assets/art/postcards/backgrounds/${location.photoStyle}.png',
        ).existsSync(),
        true,
        reason:
            'missing postcard background for ${location.id} '
            '(${location.name}): ${location.photoStyle}',
      );
      expect(
        File(
          'assets/art/postcards/stamps/${location.stampId}.png',
        ).existsSync(),
        true,
        reason:
            'missing postcard stamp for ${location.id} '
            '(${location.name}): ${location.stampId}',
      );
    }

    // 抽查解析正确性（枚举、unlockRule、交叉引用）
    expect(repo.speciesById('pet_cat'), isNotNull);
    final ember = repo.speciesById('pet_ember');
    expect(ember, isNotNull);
    expect(ember!.category.name, 'fantasy');

    // events 类型分布
    final daily = repo.events.where((e) => e.type.name == 'daily').length;
    final special = repo.events.where((e) => e.type.name == 'special').length;
    expect(daily, 100);
    expect(special, 20);

    // 传说访客 clueRole 存在
    final legendary = repo.visitors
        .where((v) => v.rarity.name == 'legendary')
        .toList();
    expect(legendary.length, 4);
    expect(legendary.every((v) => v.clueRole != null), true);
  });
}
