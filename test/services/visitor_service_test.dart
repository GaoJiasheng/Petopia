import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/yard.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/services/visitor_service.dart';
import 'package:petopia/services/visitor_service_impl.dart';

Visitor _v(
  String id,
  VisitorRarity rarity, {
  List<TimeOfDayOfDay> active = const [],
  Map<Weather, double> weather = const {},
  Map<String, double> food = const {},
  Map<Season, double> season = const {},
  List<String> decorReq = const [],
  String? clue,
}) => Visitor(
  id: id,
  name: id,
  rarity: rarity,
  activeTime: active,
  weatherPref: weather,
  foodPref: food,
  seasonPref: season,
  decorReq: decorReq,
  clueRole: clue,
  artRef: '${id}_portrait',
);

Pet _pet() => Pet(
  id: 'pet1',
  speciesId: 'pet_cat',
  variantId: 'v1',
  name: 'x',
  personality: const ['p_glutton', 'p_curious'],
  bornAt: DateTime.utc(2026, 7, 2),
  lastOnlineAt: DateTime.utc(2026, 7, 2),
  offlineDayKey: '2026-07-02',
);

/// 队列式 rng：按序返回预设值。
double Function() _rngOf(List<double> vals) {
  var i = 0;
  return () => vals[i++ % vals.length];
}

VisitorServiceImpl _svc(
  List<Visitor> vis,
  List<double> rng, {
  List<VisitorPetInteraction> inter = const [],
  void Function(VisitorLogEntry)? onLog,
  void Function(String)? onClue,
}) => VisitorServiceImpl(
  vis,
  inter,
  _rngOf(rng),
  () => 'log',
  () => DateTime.utc(2026, 7, 2, 22),
  onLog ?? (_) {},
  onClue ?? (_) {},
);

void main() {
  final yardEmpty = YardState(); // luxuryStage1, 空盘, 无装饰
  const clear = Weather.clear;
  const summer = Season.summer;
  final noon = DateTime.utc(2026, 7, 2, 12);
  final night = DateTime.utc(2026, 7, 2, 22);

  test('时段门槛：夜行访客在白天窗被排除', () {
    final owl = _v('v_owl', VisitorRarity.rare, active: [TimeOfDayOfDay.night]);
    final s = _svc([owl], [0.01]);
    expect(
      s.rollWindow(
        window: TimeWindow.day,
        yard: yardEmpty,
        weather: clear,
        season: summer,
        now: noon,
      ),
      isNull,
    );
  });

  test('装饰硬门槛：缺必要装饰→排除；有→可命中', () {
    final lampBug = _v(
      'v_lampbug',
      VisitorRarity.rare,
      decorReq: ['deco_night_lamp'],
    );
    expect(
      _svc([lampBug], [0.001]).rollWindow(
        window: TimeWindow.night,
        yard: yardEmpty,
        weather: clear,
        season: summer,
        now: night,
      ),
      isNull,
    );
    final yardLamp = YardState(ownedDecorIds: ['deco_night_lamp']);
    expect(
      _svc([lampBug], [0.001]).rollWindow(
        window: TimeWindow.night,
        yard: yardLamp,
        weather: clear,
        season: summer,
        now: night,
      ),
      isNotNull,
    );
  });

  test('轮盘 + 空盘 ×0.8：麻雀 P=0.28，rng<0.28 命中 / >0.28 miss', () {
    final sparrow = _v('v_sparrow', VisitorRarity.common, food: {'grain': 1.8});
    // 空盘 → P=0.35×0.8=0.28
    expect(
      _svc([sparrow], [0.1])
          .rollWindow(
            window: TimeWindow.day,
            yard: yardEmpty,
            weather: clear,
            season: summer,
            now: noon,
          )
          ?.id,
      'v_sparrow',
    );
    expect(
      _svc([sparrow], [0.5]).rollWindow(
        window: TimeWindow.day,
        yard: yardEmpty,
        weather: clear,
        season: summer,
        now: noon,
      ),
      isNull,
    );
  });

  test('食物加成：谷粒盘 → 麻雀 P=0.63，rng=0.5 命中', () {
    final sparrow = _v('v_sparrow', VisitorRarity.common, food: {'grain': 1.8});
    final yardGrain = YardState(foodTray: FoodTray(foodType: 'grain'));
    expect(
      _svc([sparrow], [0.5])
          .rollWindow(
            window: TimeWindow.day,
            yard: yardGrain,
            weather: clear,
            season: summer,
            now: noon,
          )
          ?.id,
      'v_sparrow',
    );
  });

  test('商店访客粮按 scope 提高目标来客概率', () {
    final sparrow = _v('visitor_sparrow', VisitorRarity.common);
    final yardGrain = YardState(
      foodTray: FoodTray(
        foodType: 'grain',
        probabilityScope: 'bird',
        probabilityDelta: 0.8,
        remaining: 3,
      ),
    );
    expect(
      _svc([sparrow], [0.5])
          .rollWindow(
            window: TimeWindow.day,
            yard: yardGrain,
            weather: clear,
            season: summer,
            now: noon,
          )
          ?.id,
      'visitor_sparrow',
    );
  });

  test('传说伯努利：P=0.03，rng<0.03 命中 / 否则 null', () {
    final star = _v(
      'v_starbug',
      VisitorRarity.legendary,
      active: [TimeOfDayOfDay.night],
      weather: {Weather.clear: 2.0},
      decorReq: ['deco_night_lamp'],
      clue: 'clue_starbug',
    );
    final yardLamp = YardState(ownedDecorIds: ['deco_night_lamp']);
    expect(
      _svc([star], [0.01])
          .rollLegendary(
            yard: yardLamp,
            weather: clear,
            season: summer,
            now: night,
          )
          ?.id,
      'v_starbug',
    );
    expect(
      _svc([star], [0.5]).rollLegendary(
        yard: yardLamp,
        weather: clear,
        season: summer,
        now: night,
      ),
      isNull,
    );
  });

  group('pickInteraction 选取优先级', () {
    final v = _v('v_sparrow', VisitorRarity.common);
    final fallback = VisitorPetInteraction(
      id: 'i_fb',
      visitorId: 'v_sparrow',
      petSpeciesId: '*',
      script: '兜底',
      animRef: '',
      expReward: 3,
    );
    final species = VisitorPetInteraction(
      id: 'i_cat',
      visitorId: 'v_sparrow',
      petSpeciesId: 'pet_cat',
      script: '对猫',
      animRef: '',
      expReward: 4,
    );
    final perso = VisitorPetInteraction(
      id: 'i_cat_glut',
      visitorId: 'v_sparrow',
      petSpeciesId: 'pet_cat',
      personalityBias: ['p_glutton'],
      script: '对贪吃猫',
      animRef: '',
      expReward: 5,
    );

    test('性格精确 > 物种精确 > 兜底', () {
      expect(
        _svc(
          [v],
          [0],
          inter: [fallback, species, perso],
        ).pickInteraction(v, _pet()).id,
        'i_cat_glut',
      );
      expect(
        _svc(
          [v],
          [0],
          inter: [fallback, species],
        ).pickInteraction(v, _pet()).id,
        'i_cat',
      );
      expect(
        _svc([v], [0], inter: [fallback]).pickInteraction(v, _pet()).id,
        'i_fb',
      );
    });
    test('无任何条目 → 合成默认（非空）', () {
      final it = _svc([v], [0]).pickInteraction(v, _pet());
      expect(it.petSpeciesId, '*');
      expect(it.expReward, 3);
    });
  });

  test('recordVisit：写日志 + 传说访客推进彩蛋线索', () {
    final logs = <VisitorLogEntry>[];
    final clues = <String>[];
    final star = _v('v_starbug', VisitorRarity.legendary, clue: 'clue_starbug');
    final s = _svc([star], [0], onLog: logs.add, onClue: clues.add);
    s.recordVisit(star, _pet(), null);
    expect(logs.single.visitorId, 'v_starbug');
    expect(clues.single, 'clue_starbug');
  });
}
