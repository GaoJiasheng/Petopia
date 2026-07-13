import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/item_effect.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/services/clock_service.dart';
import 'package:petopia/services/economy_service_impl.dart';
import 'package:petopia/services/log_port.dart';

class FakeLogPort implements AuditLogPort {
  final List<CurrencyLog> cur = [];
  @override
  Future<void> insertExp(e) async {}
  @override
  Future<void> insertCurrency(CurrencyLog e) async => cur.add(e);
  @override
  Future<int> sumExp(String petId) async => 0;
  @override
  Future<int> sumCurrency() async => cur.fold<int>(0, (a, e) => a + e.delta);
}

class FixedClock implements ClockService {
  @override
  DateTime now() => DateTime.utc(2026, 7, 2, 12);
  @override
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt}) =>
      Duration.zero;
  @override
  void markHeartbeat() {}
}

Pet _pet(String species) => Pet(
  id: 'petX',
  speciesId: species,
  variantId: 'v1',
  name: 'x',
  personality: const ['p_curious', 'p_gentle'],
  bornAt: DateTime.utc(2026, 7, 2),
  lastOnlineAt: DateTime.utc(2026, 7, 2),
  offlineDayKey: '2026-07-02',
);

void main() {
  late FakeLogPort port;
  late CurrencyWallet wallet;
  late YardState yard;
  late ShopInventory inventory;
  int idc = 0;

  EconomyServiceImpl build({
    int events = 0,
    int visitors = 0,
    Set<String> fantasy = const {},
  }) => EconomyServiceImpl(
    port,
    wallet,
    yard,
    FixedClock(),
    () => 'c${idc++}',
    (_) => events,
    (_) => visitors,
    (sp) => fantasy.contains(sp),
    inventory,
  );

  setUp(() {
    port = FakeLogPort();
    wallet = CurrencyWallet(balance: 0);
    yard = YardState();
    inventory = ShopInventory();
    idc = 0;
  });

  test('earn 增余额 + 写流水', () {
    final e = build();
    e.earn(50, CurrencyReason.achievement, ref: 'ach:x');
    expect(wallet.balance, 50);
    expect(port.cur.single.delta, 50);
    expect(port.cur.single.ref, 'ach:x');
  });

  test('spend 扣余额；不足则 false 且不写流水', () {
    final e = build();
    e.earn(100, CurrencyReason.graduation, ref: 'grad:petX');
    expect(e.spend(30, CurrencyReason.shopPurchase, ref: 'shop_a'), true);
    expect(wallet.balance, 70);
    expect(e.spend(999, CurrencyReason.shopPurchase), false); // 不透支
    expect(wallet.balance, 70);
    expect(port.cur.length, 2); // earn + spend，失败的 spend 不写
  });

  group('settleGraduation 公式', () {
    test('常规：base200 + 事件封顶 + 访客封顶', () {
      final e = build(
        events: 10,
        visitors: 5,
      ); // +min(20,100)=20, +min(15,60)=15
      final f = e.settleGraduation(_pet('pet_cat'));
      expect(f, 235);
      expect(wallet.balance, 235);
      expect(port.cur.single.ref, 'grad:petX'); // 稳定 ref
    });
    test('封顶生效：事件×2 封 100、访客×3 封 60', () {
      final e = build(events: 100, visitors: 50);
      expect(e.settleGraduation(_pet('pet_cat')), 200 + 100 + 60); // 360
    });
    test('彩蛋宠 +80', () {
      final e = build(events: 0, visitors: 0, fantasy: {'pet_ember'});
      expect(e.settleGraduation(_pet('pet_ember')), 280);
    });
  });

  test('purchase 主题：扣费 + ownedThemeIds 增加', () {
    final e = build();
    e.earn(500, CurrencyReason.graduation, ref: 'grad:petX');
    final item = ShopItem(
      id: 'shop_theme_sakura',
      category: '院子主题',
      name: '樱花小径',
      price: 400,
      effect: const ItemEffect(
        type: EffectType.themeSkin,
        params: {'themeId': 'theme_sakura'},
      ),
      artRef: 'x',
    );
    final r = e.purchase(item);
    expect(r.success, true);
    expect(wallet.balance, 100);
    expect(yard.ownedThemeIds.contains('theme_sakura'), true);
  });

  test('purchase 余额不足 → 失败、不改院子', () {
    final e = build();
    final item = ShopItem(
      id: 'shop_theme_x',
      category: '院子主题',
      name: 'x',
      price: 400,
      effect: const ItemEffect(
        type: EffectType.themeSkin,
        params: {'themeId': 'theme_x'},
      ),
      artRef: 'x',
    );
    expect(e.purchase(item).success, false);
    expect(yard.ownedThemeIds.contains('theme_x'), false);
  });

  test('消耗品进入库存，访客粮同步食盆概率效果', () {
    final e = build();
    e.earn(100, CurrencyReason.graduation, ref: 'seed');
    final item = ShopItem(
      id: 'shop_food_grain_bag',
      category: '特殊食粮',
      name: '谷粒袋 ×3 盘',
      price: 20,
      effect: const ItemEffect(
        type: EffectType.visitorProb,
        params: {'scope': 'bird', 'delta': 0.8},
      ),
      artRef: 'x',
      consumable: true,
      stackCount: 3,
    );

    expect(e.purchase(item).success, true);
    expect(inventory.consumables[item.id], 3);
    expect(yard.foodTray.foodType, 'grain');
    expect(yard.foodTray.probabilityScope, 'bird');
    expect(yard.foodTray.remaining, 3);
  });

  test('相册皮肤可拥有，永久商品重复购买不会再次扣费', () {
    final e = build();
    e.earn(500, CurrencyReason.graduation, ref: 'seed');
    final item = ShopItem(
      id: 'shop_album_paper',
      category: '明信片',
      name: '相册皮肤·牛皮纸',
      price: 150,
      effect: const ItemEffect(
        type: EffectType.albumSkin,
        params: {'skinId': 'paper'},
      ),
      artRef: 'x',
    );

    expect(e.purchase(item).success, true);
    expect(inventory.ownedAlbumSkinIds, contains('paper'));
    expect(inventory.activeAlbumSkinId, 'paper');
    expect(e.purchase(item).failReason, 'already_owned');
    expect(wallet.balance, 350);
  });

  test('INV-4：balance == Σcurrency流水delta', () async {
    final e = build(events: 10, visitors: 5);
    e.settleGraduation(_pet('pet_cat')); // +235
    e.spend(60, CurrencyReason.shopPurchase, ref: 'shop_a'); // -60
    e.earn(50, CurrencyReason.achievement, ref: 'ach:y'); // +50
    expect(wallet.balance, await port.sumCurrency());
    expect(wallet.balance, 225);
  });
}
