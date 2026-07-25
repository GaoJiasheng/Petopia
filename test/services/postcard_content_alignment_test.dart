import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/content_entities.dart';
import 'package:petopia/domain/models/logs.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/domain/models/postcard_content.dart';
import 'package:petopia/services/postcard_content_alignment.dart';

void main() {
  test(
    'repairs a legacy rooftop/tram story stored on an old-bookshop card',
    () {
      final pet = Pet(
        id: 'pet-1',
        speciesId: 'pet_parrot',
        variantId: 'var01',
        name: '鹦鹉',
        personality: ['p_energetic'],
        bornAt: DateTime.utc(2026, 7, 1),
        lastOnlineAt: DateTime.utc(2026, 7, 1),
        offlineDayKey: '2026-07-01',
        state: PetState.roaming,
      );
      const location = Location(
        id: 'loc_oldbook_alley',
        name: '旧书坊巷',
        category: '城市',
        climate: '温带城市',
        vibeTags: ['city'],
        photoStyle: 'pc_bg_oldbook_alley',
        encounterPoolId: 'enc_city',
        personalityWeight: {},
        stampId: 'pc_stamp_oldbook_alley',
      );
      const badTemplate = PostcardTemplate(
        id: 'tpl_en_cs_03',
        personalityId: 'p_energetic',
        category: '城市',
        locationIds: ['loc_rooftop_city'],
        skeleton:
            '屋顶水塔上视野超好！！我是跳上来的！三级跳！！{incident}！'
            '下去的路线已经勘察完毕：还是三级跳！！——{petName}',
      );
      const tramIncident = Incident(
        id: 'inc_cs_01',
        vibe: 'city',
        locationIds: ['loc_tram_street'],
        phrase: '学电车报站学得太像，害一个站台的人白等了一趟车',
        poseHint: 'surprise',
      );
      const bookIncident = Incident(
        id: 'inc_cs_04',
        vibe: 'city',
        locationIds: ['loc_oldbook_alley'],
        phrase: '在旧书坊打盹压皱了一页地图',
        poseHint: 'sleep',
      );
      final cards = <Postcard>[
        Postcard(
          id: 'postcard-6',
          petId: pet.id,
          journeyId: 'journey-1',
          locationId: location.id,
          seq: 5,
          sentAt: DateTime.utc(2026, 7, 23),
          season: Season.summer,
          timeOfDay: TimeOfDayOfDay.morning,
          weather: Weather.clear,
          incidentId: tramIncident.id,
          bodyText:
              '屋顶水塔上视野超好！！我是跳上来的！三级跳！！'
              '学电车报站学得太像，害一个站台的人白等了一趟车！'
              '下去的路线已经勘察完毕：还是三级跳！！——鹦鹉',
          photoAssetId: 'pc_photo_pc_bg_oldbook_alley_pet_parrot_surprise',
          stampId: location.stampId,
        ),
      ];

      final count = repairMisalignedPostcards(
        postcards: cards,
        pets: [pet],
        locations: {location.id: location},
        templates: const [badTemplate],
        encounters: const [],
        incidents: const [tramIncident, bookIncident],
        ownerName: '主人',
      );

      expect(count, 1);
      expect(cards.single.bodyText, contains('旧书坊巷'));
      expect(cards.single.bodyText, contains('旧书坊打盹'));
      expect(cards.single.bodyText, isNot(contains('屋顶水塔')));
      expect(cards.single.bodyText, isNot(contains('电车')));
      expect(cards.single.incidentId, bookIncident.id);
      expect(cards.single.photoAssetId, endsWith('_sleep'));
    },
  );

  test('leaves an already aligned rendered card unchanged', () {
    final pet = Pet(
      id: 'pet-1',
      speciesId: 'pet_cat',
      variantId: 'var01',
      name: '阿橘',
      personality: ['p_gentle'],
      bornAt: DateTime.utc(2026, 7, 1),
      lastOnlineAt: DateTime.utc(2026, 7, 1),
      offlineDayKey: '2026-07-01',
    );
    const location = Location(
      id: 'loc_oldbook_alley',
      name: '旧书坊巷',
      category: '城市',
      climate: '温带城市',
      vibeTags: ['city'],
      photoStyle: 'pc_bg_oldbook_alley',
      encounterPoolId: 'enc_city',
      personalityWeight: {},
      stampId: 'pc_stamp_oldbook_alley',
    );
    const template = PostcardTemplate(
      id: 'tpl_book',
      personalityId: 'p_gentle',
      category: '城市',
      locationIds: ['loc_oldbook_alley'],
      skeleton: '在{location}晒了一下午书。——{petName}',
    );
    final cards = <Postcard>[
      Postcard(
        id: 'card',
        petId: pet.id,
        journeyId: 'journey',
        locationId: location.id,
        seq: 0,
        sentAt: DateTime.utc(2026, 7, 23),
        season: Season.summer,
        timeOfDay: TimeOfDayOfDay.afternoon,
        weather: Weather.clear,
        bodyText: '在旧书坊巷晒了一下午书。——阿橘',
        photoAssetId: 'photo',
        stampId: location.stampId,
      ),
    ];

    expect(
      repairMisalignedPostcards(
        postcards: cards,
        pets: [pet],
        locations: {location.id: location},
        templates: const [template],
        encounters: const [],
        incidents: const [],
        ownerName: '主人',
      ),
      0,
    );
    expect(cards.single.bodyText, '在旧书坊巷晒了一下午书。——阿橘');
  });

  test(
    'repairs persisted scene words that contradict the fixed background',
    () {
      final pet = Pet(
        id: 'pet-1',
        speciesId: 'pet_cat',
        variantId: 'var01',
        name: '阿橘',
        personality: ['p_gentle'],
        bornAt: DateTime.utc(2026, 7, 1),
        lastOnlineAt: DateTime.utc(2026, 7, 1),
        offlineDayKey: '2026-07-01',
      );
      const location = Location(
        id: 'loc_aurora_village',
        name: '极光渔村',
        category: '极地水域',
        climate: '极寒',
        vibeTags: ['aurora'],
        photoStyle: 'pc_bg_aurora_village',
        encounterPoolId: 'enc_polar',
        personalityWeight: {},
        stampId: 'pc_stamp_aurora_village',
        allowedSeasons: [Season.winter],
        allowedTimesOfDay: [TimeOfDayOfDay.night],
        allowedWeather: [Weather.snow],
      );
      const template = PostcardTemplate(
        id: 'tpl_aurora',
        personalityId: 'p_gentle',
        category: '极地水域',
        locationIds: ['loc_aurora_village'],
        skeleton: '{season}的{timeOfDay}，{weather}的{location}。——{petName}',
      );
      final cards = <Postcard>[
        Postcard(
          id: 'scene-card',
          petId: pet.id,
          journeyId: 'journey',
          locationId: location.id,
          seq: 0,
          sentAt: DateTime.utc(2026, 7, 23),
          season: Season.summer,
          timeOfDay: TimeOfDayOfDay.noon,
          weather: Weather.clear,
          bodyText: '夏天的中午，晴朗的极光渔村。——阿橘',
          photoAssetId: 'photo',
          stampId: location.stampId,
        ),
      ];

      expect(
        repairMisalignedPostcards(
          postcards: cards,
          pets: [pet],
          locations: {location.id: location},
          templates: const [template],
          encounters: const [],
          incidents: const [],
          ownerName: '主人',
        ),
        1,
      );
      expect(cards.single.season, Season.winter);
      expect(cards.single.timeOfDay, TimeOfDayOfDay.night);
      expect(cards.single.weather, Weather.snow);
      expect(cards.single.bodyText, '冬天的深夜，下雪的极光渔村。——阿橘');
    },
  );
}
