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
    final legendary = repo.visitors.where((v) => v.rarity.name == 'legendary').toList();
    expect(legendary.length, 4);
    expect(legendary.every((v) => v.clueRole != null), true);
  });
}
