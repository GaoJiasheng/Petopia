import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/domain/models/postcard_content.dart';
import 'package:petopia/services/postcard_generator_impl.dart';

Location _loc(
  String id, {
  String name = '灯塔湾',
  String category = '海滨',
  String photoStyle = 'seaside_lighthouse',
}) => Location(
  id: id,
  name: name,
  category: category,
  climate: '温润',
  vibeTags: const ['sea'],
  photoStyle: photoStyle,
  encounterPoolId: 'enc_seaside',
  personalityWeight: const {},
  stampId: 'stamp_$id',
);

Pet _pet() => Pet(
  id: 'pet1',
  speciesId: 'pet_cat',
  variantId: 'v1',
  name: '阿橘',
  personality: const ['p_glutton', 'p_curious'],
  bornAt: DateTime.utc(2026, 7, 2),
  lastOnlineAt: DateTime.utc(2026, 7, 2),
  offlineDayKey: '2026-07-02',
  state: PetState.traveling,
);

void main() {
  final now = DateTime.utc(2026, 7, 15, 12); // 7月 → summer

  final tpl = const PostcardTemplate(
    id: 't1',
    personalityId: 'p_glutton',
    category: '海滨',
    skeleton: '主人！{location}的{encounter}……{incident}。——{petName}',
  );
  final enc = const Encounter(
    id: 'e1',
    poolId: 'enc_seaside',
    phrase: '烤鱼摊老板请我吃了一条',
  );
  final inc = const Incident(
    id: 'i1',
    vibe: 'sea',
    phrase: '浪花在脚边写了个字',
    poseHint: 'gaze',
  );

  PostcardGeneratorImpl build(
    List<Postcard> sink, {
    double rng = 0.0,
    DateTime? clock,
    List<Location>? locations,
  }) => PostcardGeneratorImpl(
    locations: {
      for (final location in locations ?? [_loc('loc_lighthouse')])
        location.id: location,
    },
    templates: [tpl],
    encounters: [enc],
    incidents: [inc],
    rng: () => rng,
    now: () => clock ?? now,
    idGen: () => 'pc1',
    ownerName: '小明',
    onPostcard: sink.add,
  );

  test('generate：管线渲染正文 + 照片/邮戳/季节', () {
    final sink = <Postcard>[];
    final j = Journey(
      id: 'j1',
      petId: 'pet1',
      stops: ['loc_lighthouse'],
      nextPostcardAt: now,
    );
    final pc = build(sink).generate(pet: _pet(), journey: j);
    expect(pc.bodyText, '主人！灯塔湾的烤鱼摊老板请我吃了一条……浪花在脚边写了个字。——阿橘');
    expect(pc.locationId, 'loc_lighthouse');
    expect(pc.stampId, 'stamp_loc_lighthouse');
    expect(pc.season, Season.summer);
    expect(pc.photoAssetId, 'pc_photo_seaside_lighthouse_pet_cat_gaze');
    expect(pc.encounterId, 'e1');
    expect(sink.single.id, 'pc1');
  });

  test('无模板匹配 → 兜底骨架', () {
    final sink = <Postcard>[];
    final gen = PostcardGeneratorImpl(
      locations: {'loc_lighthouse': _loc('loc_lighthouse')},
      templates: const [],
      encounters: const [],
      incidents: const [],
      rng: () => 0,
      now: () => now,
      idGen: () => 'pc',
      ownerName: 'x',
      onPostcard: sink.add,
    );
    final j = Journey(
      id: 'j',
      petId: 'pet1',
      stops: ['loc_lighthouse'],
      nextPostcardAt: now,
    );
    final pc = gen.generate(pet: _pet(), journey: j);
    expect(pc.bodyText, contains('灯塔湾'));
    expect(pc.bodyText, contains('阿橘'));
  });

  test('地点白名单阻止屋顶/电车内容串入旧书坊背景', () {
    final sink = <Postcard>[];
    final pet = _pet()..personality = ['p_energetic'];
    final oldBook = Location(
      id: 'loc_oldbook_alley',
      name: '旧书坊巷',
      category: '城市',
      climate: '温带城市',
      vibeTags: const ['city'],
      photoStyle: 'pc_bg_oldbook_alley',
      encounterPoolId: 'enc_city',
      personalityWeight: const {},
      stampId: 'pc_stamp_oldbook_alley',
    );
    final gen = PostcardGeneratorImpl(
      locations: {oldBook.id: oldBook},
      templates: const [
        PostcardTemplate(
          id: 'tpl_rooftop',
          personalityId: 'p_energetic',
          category: '城市',
          locationIds: ['loc_rooftop_city'],
          skeleton: '屋顶水塔上视野超好！——{petName}',
        ),
        PostcardTemplate(
          id: 'tpl_city_generic',
          personalityId: 'p_energetic',
          category: '城市',
          skeleton: '我跑到{location}啦！{incident}。——{petName}',
        ),
      ],
      encounters: const [],
      incidents: const [
        Incident(
          id: 'inc_tram',
          vibe: 'city',
          locationIds: ['loc_tram_street'],
          phrase: '学电车报站',
        ),
        Incident(
          id: 'inc_book',
          vibe: 'city',
          locationIds: ['loc_oldbook_alley'],
          phrase: '在旧书堆里发现一枚书签',
        ),
      ],
      rng: () => 0,
      now: () => now,
      idGen: () => 'pc',
      ownerName: '主人',
      onPostcard: sink.add,
    );
    final card = gen.generate(
      pet: pet,
      journey: Journey(
        id: 'journey',
        petId: pet.id,
        stops: [oldBook.id],
        nextPostcardAt: now,
      ),
    );

    expect(card.bodyText, contains('旧书坊巷'));
    expect(card.bodyText, contains('旧书堆'));
    expect(card.bodyText, isNot(contains('屋顶水塔')));
    expect(card.bodyText, isNot(contains('电车')));
    expect(card.incidentId, 'inc_book');
  });

  test('季节、天气、时段和站数占位符全部渲染', () {
    final sink = <Postcard>[];
    final location = Location(
      id: 'loc_lighthouse',
      name: '灯塔湾',
      category: '海滨',
      climate: '温润',
      vibeTags: const ['sea'],
      photoStyle: 'seaside_lighthouse',
      encounterPoolId: 'enc_seaside',
      personalityWeight: const {},
      stampId: 'stamp_loc_lighthouse',
      allowedSeasons: const [Season.summer],
      allowedTimesOfDay: const [TimeOfDayOfDay.dawn],
      allowedWeather: const [Weather.clear],
    );
    final gen = PostcardGeneratorImpl(
      locations: {location.id: location},
      templates: const [
        PostcardTemplate(
          id: 'tpl_slots',
          personalityId: 'p_glutton',
          category: '海滨',
          skeleton:
              '{season}·{timeOfDay}·{weather}·第{seq}站·{location}——{petName}',
        ),
      ],
      encounters: const [],
      incidents: const [],
      rng: () => 0,
      now: () => now,
      idGen: () => 'pc',
      ownerName: '主人',
      onPostcard: sink.add,
    );
    final card = gen.generate(
      pet: _pet(),
      journey: Journey(
        id: 'journey',
        petId: 'pet1',
        stops: [location.id],
        nextPostcardAt: now,
      ),
    );

    expect(card.bodyText, '夏天·清晨·晴朗·第1站·灯塔湾——阿橘');
    expect(card.bodyText, isNot(contains('{')));
  });

  test('固定背景只生成允许的季节、时段和天气', () {
    final sink = <Postcard>[];
    final location = Location(
      id: 'loc_aurora_village',
      name: '极光渔村',
      category: '极地水域',
      climate: '极寒',
      vibeTags: const ['aurora'],
      photoStyle: 'pc_bg_aurora_village',
      encounterPoolId: 'enc_polar',
      personalityWeight: const {},
      stampId: 'pc_stamp_aurora_village',
      allowedSeasons: const [Season.winter],
      allowedTimesOfDay: const [TimeOfDayOfDay.night],
      allowedWeather: const [Weather.snow],
    );
    final generator = PostcardGeneratorImpl(
      locations: {location.id: location},
      templates: const [
        PostcardTemplate(
          id: 'tpl_scene',
          personalityId: 'p_glutton',
          category: '极地水域',
          skeleton: '{season}的{timeOfDay}，{weather}的{location}。——{petName}',
        ),
      ],
      encounters: const [],
      incidents: const [],
      rng: () => 0.99,
      now: () => DateTime(2026, 7, 15, 12),
      idGen: () => 'pc-scene',
      ownerName: '主人',
      onPostcard: sink.add,
    );

    final card = generator.generate(
      pet: _pet(),
      journey: Journey(
        id: 'journey',
        petId: 'pet1',
        stops: [location.id],
        nextPostcardAt: now,
      ),
    );

    expect(card.season, Season.winter);
    expect(card.timeOfDay, TimeOfDayOfDay.night);
    expect(card.weather, Weather.snow);
    expect(card.bodyText, '冬天的深夜，下雪的极光渔村。——阿橘');
  });

  test('dailyTick：未到寄片时刻不生成', () async {
    final sink = <Postcard>[];
    final j = Journey(
      id: 'j',
      petId: 'pet1',
      stops: ['loc_lighthouse', 'loc_lighthouse'],
      nextPostcardAt: now.add(const Duration(days: 2)),
    );
    await build(sink).dailyTick(pet: _pet(), journey: j);
    expect(sink, isEmpty);
  });

  test('dailyTick：主旅程到点生成并推进；末站转补完阶段', () async {
    final sink = <Postcard>[];
    final pet = _pet();
    var clock = now; // 可推进时钟
    final j = Journey(
      id: 'j',
      petId: 'pet1',
      stops: ['loc_lighthouse', 'loc_forest'],
      wanderStops: ['loc_meadow'],
      nextPostcardAt: now,
    );
    final gen = PostcardGeneratorImpl(
      locations: {
        'loc_lighthouse': _loc('loc_lighthouse'),
        'loc_forest': _loc('loc_forest', name: '森林站'),
        'loc_meadow': _loc('loc_meadow', name: '花田站'),
      },
      templates: [tpl],
      encounters: [enc],
      incidents: [inc],
      rng: () => 0,
      now: () => clock,
      idGen: () => 'pc',
      ownerName: 'x',
      onPostcard: sink.add,
    );
    await gen.dailyTick(pet: pet, journey: j); // seq0 → currentIdx 1（未到末站）
    expect(sink.length, 1);
    expect(sink.single.locationId, 'loc_lighthouse');
    expect(sink.single.seq, 0);
    expect(j.currentIdx, 1);
    expect(j.state, JourneyState.active);
    expect(j.nextPostcardAt, now.add(const Duration(days: 3)));
    clock = j.nextPostcardAt; // 推进到 nextPostcardAt
    await gen.dailyTick(pet: pet, journey: j); // seq1 末站 → wandering + roaming
    expect(sink.length, 2);
    expect(sink.last.locationId, 'loc_forest');
    expect(sink.last.seq, 1);
    expect(j.currentIdx, 2);
    expect(j.state, JourneyState.wandering);
    expect(pet.state, PetState.roaming);
    expect(j.nextPostcardAt, clock.add(const Duration(days: 10)));
  });

  test('dailyTick：补完剩余地点后进入约 20 天长期回信', () async {
    final sink = <Postcard>[];
    final pet = _pet()..state = PetState.roaming;
    var clock = now;
    final j = Journey(
      id: 'j',
      petId: 'pet1',
      stops: ['loc_lighthouse'],
      wanderStops: ['loc_forest'],
      currentIdx: 1,
      nextPostcardAt: now,
      state: JourneyState.wandering,
    );
    final gen = PostcardGeneratorImpl(
      locations: {
        'loc_lighthouse': _loc('loc_lighthouse'),
        'loc_forest': _loc('loc_forest', name: '森林站'),
      },
      templates: [tpl],
      encounters: [enc],
      incidents: [inc],
      rng: () => 0,
      now: () => clock,
      idGen: () => 'pc',
      ownerName: 'x',
      onPostcard: sink.add,
    );

    await gen.dailyTick(pet: pet, journey: j);
    expect(sink.single.locationId, 'loc_forest');
    expect(sink.single.seq, 1);
    expect(j.wanderIdx, 1);
    expect(j.longTermSeq, 0);
    expect(j.nextPostcardAt, now.add(const Duration(days: 18)));

    clock = j.nextPostcardAt;
    await gen.dailyTick(pet: pet, journey: j);
    expect(sink.length, 2);
    expect(sink.last.locationId, 'loc_lighthouse');
    expect(sink.last.seq, 2);
    expect(j.longTermSeq, 1);
    expect(j.nextPostcardAt, clock.add(const Duration(days: 18)));
  });
}
