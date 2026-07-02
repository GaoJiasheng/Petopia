import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/domain/models/postcard_content.dart';
import 'package:petopia/services/postcard_generator_impl.dart';

Location _loc() => const Location(
      id: 'loc_lighthouse', name: '灯塔湾', category: '海滨', climate: '温润',
      vibeTags: ['sea'], photoStyle: 'seaside_lighthouse',
      encounterPoolId: 'enc_seaside', personalityWeight: {}, stampId: 'stamp_lh');

Pet _pet() => Pet(
      id: 'pet1', speciesId: 'pet_cat', variantId: 'v1', name: '阿橘',
      personality: const ['p_glutton', 'p_curious'],
      bornAt: DateTime.utc(2026, 7, 2), lastOnlineAt: DateTime.utc(2026, 7, 2),
      offlineDayKey: '2026-07-02', state: PetState.traveling);

void main() {
  final now = DateTime.utc(2026, 7, 15, 12); // 7月 → summer

  final tpl = const PostcardTemplate(
      id: 't1', personalityId: 'p_glutton', category: '海滨',
      skeleton: '主人！{location}的{encounter}……{incident}。——{petName}');
  final enc = const Encounter(id: 'e1', poolId: 'enc_seaside', phrase: '烤鱼摊老板请我吃了一条');
  final inc = const Incident(id: 'i1', vibe: 'sea', phrase: '浪花在脚边写了个字', poseHint: 'gaze');

  PostcardGeneratorImpl build(List<Postcard> sink, {double rng = 0.0, DateTime? clock}) =>
      PostcardGeneratorImpl(
        locations: {'loc_lighthouse': _loc()},
        templates: [tpl], encounters: [enc], incidents: [inc],
        rng: () => rng, now: () => clock ?? now, idGen: () => 'pc1',
        ownerName: '小明', onPostcard: sink.add);

  test('generate：管线渲染正文 + 照片/邮戳/季节', () {
    final sink = <Postcard>[];
    final j = Journey(id: 'j1', petId: 'pet1', stops: ['loc_lighthouse'], nextPostcardAt: now);
    final pc = build(sink).generate(pet: _pet(), journey: j);
    expect(pc.bodyText, '主人！灯塔湾的烤鱼摊老板请我吃了一条……浪花在脚边写了个字。——阿橘');
    expect(pc.locationId, 'loc_lighthouse');
    expect(pc.stampId, 'stamp_lh');
    expect(pc.season, Season.summer);
    expect(pc.photoAssetId, 'pc_photo_seaside_lighthouse_pet_cat_gaze');
    expect(pc.encounterId, 'e1');
    expect(sink.single.id, 'pc1');
  });

  test('无模板匹配 → 兜底骨架', () {
    final sink = <Postcard>[];
    final gen = PostcardGeneratorImpl(
      locations: {'loc_lighthouse': _loc()},
      templates: const [], encounters: const [], incidents: const [],
      rng: () => 0, now: () => now, idGen: () => 'pc', ownerName: 'x', onPostcard: sink.add);
    final j = Journey(id: 'j', petId: 'pet1', stops: ['loc_lighthouse'], nextPostcardAt: now);
    final pc = gen.generate(pet: _pet(), journey: j);
    expect(pc.bodyText, contains('灯塔湾'));
    expect(pc.bodyText, contains('阿橘'));
  });

  test('dailyTick：未到寄片时刻不生成', () async {
    final sink = <Postcard>[];
    final j = Journey(id: 'j', petId: 'pet1', stops: ['loc_lighthouse', 'loc_lighthouse'], nextPostcardAt: now.add(const Duration(days: 2)));
    await build(sink).dailyTick(pet: _pet(), journey: j);
    expect(sink, isEmpty);
  });

  test('dailyTick：到点生成并推进；末站转世界漫游', () async {
    final sink = <Postcard>[];
    final pet = _pet();
    var clock = now; // 可推进时钟
    final j = Journey(id: 'j', petId: 'pet1', stops: ['loc_lighthouse', 'loc_lighthouse'], nextPostcardAt: now);
    final gen = PostcardGeneratorImpl(
      locations: {'loc_lighthouse': _loc()},
      templates: [tpl], encounters: [enc], incidents: [inc],
      rng: () => 0, now: () => clock, idGen: () => 'pc', ownerName: 'x', onPostcard: sink.add);
    await gen.dailyTick(pet: pet, journey: j); // seq0 → currentIdx 1（未到末站）
    expect(sink.length, 1);
    expect(j.currentIdx, 1);
    expect(j.state, JourneyState.active);
    clock = clock.add(const Duration(days: 10)); // 推进过 nextPostcardAt
    await gen.dailyTick(pet: pet, journey: j); // seq1 末站 → wandering + roaming
    expect(sink.length, 2);
    expect(j.state, JourneyState.wandering);
    expect(pet.state, PetState.roaming);
  });
}
