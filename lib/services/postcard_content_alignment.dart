import '../domain/enums.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/logs.dart';
import '../domain/models/pet.dart';
import '../domain/models/postcard_content.dart';

bool postcardContentAllowsLocation(
  List<String> locationIds,
  String locationId,
) => locationIds.isEmpty || locationIds.contains(locationId);

List<T> preferPostcardLocationSpecific<T>(
  Iterable<T> items,
  String locationId,
  List<String> Function(T item) locationIdsOf,
) {
  final allowed = items
      .where(
        (item) =>
            postcardContentAllowsLocation(locationIdsOf(item), locationId),
      )
      .toList();
  final specific = allowed
      .where((item) => locationIdsOf(item).isNotEmpty)
      .toList();
  return specific.isNotEmpty ? specific : allowed;
}

String renderPostcardText({
  required String skeleton,
  required Location location,
  required Pet pet,
  required String ownerName,
  required Season season,
  required TimeOfDayOfDay timeOfDay,
  required Weather weather,
  required int seq,
  Encounter? encounter,
  Incident? incident,
}) {
  return _renderCore(
        skeleton: skeleton,
        location: location,
        pet: pet,
        ownerName: ownerName,
        encounter: encounter,
        incident: incident,
      )
      .replaceAll('{season}', _seasonLabel(season))
      .replaceAll('{timeOfDay}', _timeOfDayLabel(timeOfDay))
      .replaceAll('{weather}', _weatherLabel(weather))
      .replaceAll('{seq}', '${seq + 1}');
}

String fallbackPostcardSkeleton(String personalityId) {
  return _fallbackSkeletons[personalityId] ??
      '{ownerName}，我到{location}了。{encounter}。{incident}。'
          '这里很好，我会替你好好记住。——{petName}';
}

bool postcardSceneMatchesLocation({
  required Location location,
  required Season season,
  required TimeOfDayOfDay timeOfDay,
  required Weather weather,
}) {
  return location.allowedSeasons.contains(season) &&
      location.allowedTimesOfDay.contains(timeOfDay) &&
      location.allowedWeather.contains(weather);
}

typedef PostcardScene = ({
  Season season,
  TimeOfDayOfDay timeOfDay,
  Weather weather,
});

PostcardScene normalizePostcardScene({
  required Location location,
  required Season season,
  required TimeOfDayOfDay timeOfDay,
  required Weather weather,
  required String stableSeed,
}) {
  return (
    season: location.allowedSeasons.contains(season)
        ? season
        : (_stablePick(location.allowedSeasons, '$stableSeed:scene-season') ??
              season),
    timeOfDay: location.allowedTimesOfDay.contains(timeOfDay)
        ? timeOfDay
        : (_stablePick(location.allowedTimesOfDay, '$stableSeed:scene-time') ??
              timeOfDay),
    weather: location.allowedWeather.contains(weather)
        ? weather
        : (_stablePick(location.allowedWeather, '$stableSeed:scene-weather') ??
              weather),
  );
}

/// Repairs cards generated before location and scene constraints existed.
///
/// Existing cards only stored their rendered body, so the source template is
/// recovered by rendering the old skeleton with the card's persisted slots.
/// Cards are replaced when their content belongs to another location, their
/// fixed background contradicts the persisted season/time/weather, or a legacy
/// placeholder was left unresolved.
int repairMisalignedPostcards({
  required List<Postcard> postcards,
  required Iterable<Pet> pets,
  required Map<String, Location> locations,
  required List<PostcardTemplate> templates,
  required List<Encounter> encounters,
  required List<Incident> incidents,
  required String ownerName,
}) {
  final petsById = {for (final pet in pets) pet.id: pet};
  final encountersById = {for (final item in encounters) item.id: item};
  final incidentsById = {for (final item in incidents) item.id: item};
  var repairedCount = 0;

  for (var index = 0; index < postcards.length; index++) {
    final card = postcards[index];
    final pet = petsById[card.petId];
    final location = locations[card.locationId];
    if (pet == null || location == null) continue;

    final encounter = card.encounterId == null
        ? null
        : encountersById[card.encounterId];
    final incident = card.incidentId == null
        ? null
        : incidentsById[card.incidentId];
    final sourceTemplate = _findSourceTemplate(
      bodyText: card.bodyText,
      templates: templates,
      location: location,
      pet: pet,
      ownerName: ownerName,
      season: card.season,
      timeOfDay: card.timeOfDay,
      weather: card.weather,
      seq: card.seq,
      encounter: encounter,
      incident: incident,
    );

    final templateMismatch =
        sourceTemplate != null &&
        !postcardContentAllowsLocation(sourceTemplate.locationIds, location.id);
    final encounterMismatch =
        card.encounterId != null &&
        (encounter == null ||
            !postcardContentAllowsLocation(encounter.locationIds, location.id));
    final incidentMismatch =
        card.incidentId != null &&
        (incident == null ||
            !postcardContentAllowsLocation(incident.locationIds, location.id));
    final unresolvedSlot = _unresolvedSlot.hasMatch(card.bodyText);
    final scene = normalizePostcardScene(
      location: location,
      season: card.season,
      timeOfDay: card.timeOfDay,
      weather: card.weather,
      stableSeed: card.id,
    );
    final sceneMismatch =
        scene.season != card.season ||
        scene.timeOfDay != card.timeOfDay ||
        scene.weather != card.weather;

    if (!templateMismatch &&
        !encounterMismatch &&
        !incidentMismatch &&
        !sceneMismatch &&
        !unresolvedSlot) {
      continue;
    }

    final personalityId = pet.personality.isEmpty ? '' : pet.personality.first;
    final compatibleTemplates = preferPostcardLocationSpecific(
      templates.where(
        (template) =>
            template.personalityId == personalityId &&
            template.category == location.category,
      ),
      location.id,
      (template) => template.locationIds,
    );
    final compatibleEncounters = preferPostcardLocationSpecific(
      encounters.where((item) => item.poolId == location.encounterPoolId),
      location.id,
      (item) => item.locationIds,
    );
    final compatibleIncidents = preferPostcardLocationSpecific(
      incidents.where((item) => location.vibeTags.contains(item.vibe)),
      location.id,
      (item) => item.locationIds,
    );

    final nextTemplate =
        sourceTemplate != null &&
            postcardContentAllowsLocation(
              sourceTemplate.locationIds,
              location.id,
            )
        ? sourceTemplate
        : compatibleTemplates.isEmpty
        ? null
        : compatibleTemplates[_stableIndex(
            '${card.id}:template',
            compatibleTemplates.length,
          )];
    final nextEncounter =
        encounter != null &&
            postcardContentAllowsLocation(encounter.locationIds, location.id)
        ? encounter
        : _stablePick(compatibleEncounters, '${card.id}:encounter');
    final nextIncident =
        incident != null &&
            postcardContentAllowsLocation(incident.locationIds, location.id)
        ? incident
        : _stablePick(compatibleIncidents, '${card.id}:incident');

    final bodyText = renderPostcardText(
      skeleton:
          nextTemplate?.skeleton ?? fallbackPostcardSkeleton(personalityId),
      location: location,
      pet: pet,
      ownerName: ownerName,
      season: scene.season,
      timeOfDay: scene.timeOfDay,
      weather: scene.weather,
      seq: card.seq,
      encounter: nextEncounter,
      incident: nextIncident,
    );
    final photoAssetId =
        'pc_photo_${location.photoStyle}_${pet.speciesId}_'
        '${nextIncident?.poseHint ?? 'idle'}';

    postcards[index] = Postcard(
      id: card.id,
      petId: card.petId,
      journeyId: card.journeyId,
      locationId: card.locationId,
      seq: card.seq,
      sentAt: card.sentAt,
      receivedAt: card.receivedAt,
      season: scene.season,
      timeOfDay: scene.timeOfDay,
      weather: scene.weather,
      encounterId: nextEncounter?.id,
      incidentId: nextIncident?.id,
      bodyText: bodyText,
      photoAssetId: photoAssetId,
      stampId: card.stampId,
      clueToPet: card.clueToPet,
      clueToVisitor: card.clueToVisitor,
    );
    repairedCount += 1;
  }

  return repairedCount;
}

PostcardTemplate? _findSourceTemplate({
  required String bodyText,
  required List<PostcardTemplate> templates,
  required Location location,
  required Pet pet,
  required String ownerName,
  required Season season,
  required TimeOfDayOfDay timeOfDay,
  required Weather weather,
  required int seq,
  Encounter? encounter,
  Incident? incident,
}) {
  for (final template in templates) {
    if (template.category != location.category) continue;
    final legacy = _renderCore(
      skeleton: template.skeleton,
      location: location,
      pet: pet,
      ownerName: ownerName,
      encounter: encounter,
      incident: incident,
    );
    if (legacy == bodyText) return template;

    final current = renderPostcardText(
      skeleton: template.skeleton,
      location: location,
      pet: pet,
      ownerName: ownerName,
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
      seq: seq,
      encounter: encounter,
      incident: incident,
    );
    if (current == bodyText) return template;
  }
  return null;
}

String _renderCore({
  required String skeleton,
  required Location location,
  required Pet pet,
  required String ownerName,
  Encounter? encounter,
  Incident? incident,
}) {
  return skeleton
      .replaceAll('{location}', location.name)
      .replaceAll('{encounter}', encounter?.phrase ?? '')
      .replaceAll('{incident}', incident?.phrase ?? '')
      .replaceAll('{petName}', pet.name)
      .replaceAll('{ownerName}', ownerName);
}

T? _stablePick<T>(List<T> items, String seed) {
  if (items.isEmpty) return null;
  return items[_stableIndex(seed, items.length)];
}

int _stableIndex(String seed, int length) {
  var hash = 0x811c9dc5;
  for (final codeUnit in seed.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash % length;
}

String _seasonLabel(Season season) => switch (season) {
  Season.spring => '春天',
  Season.summer => '夏天',
  Season.autumn => '秋天',
  Season.winter => '冬天',
};

String _timeOfDayLabel(TimeOfDayOfDay timeOfDay) => switch (timeOfDay) {
  TimeOfDayOfDay.dawn => '清晨',
  TimeOfDayOfDay.morning => '上午',
  TimeOfDayOfDay.noon => '中午',
  TimeOfDayOfDay.afternoon => '午后',
  TimeOfDayOfDay.evening => '黄昏',
  TimeOfDayOfDay.night => '深夜',
};

String _weatherLabel(Weather weather) => switch (weather) {
  Weather.clear => '晴朗',
  Weather.cloudy => '多云',
  Weather.rain => '下雨',
  Weather.thunder => '雷雨',
  Weather.snow => '下雪',
  Weather.fog => '起雾',
  Weather.rainbow => '有彩虹',
};

final RegExp _unresolvedSlot = RegExp(
  r'\{(?:location|encounter|incident|petName|ownerName|season|'
  r'timeOfDay|weather|seq)\}',
);

const Map<String, String> _fallbackSkeletons = {
  'p_glutton':
      '{ownerName}，我到{location}了！{encounter}。{incident}。'
      '这里闻起来就很值得多住几天，我会认真替你尝一遍。——{petName}',
  'p_lazy':
      '到{location}了。{encounter}。{incident}。'
      '这里刚好有一块舒服的位置，我先替你躺一会儿。——{petName}',
  'p_curious':
      '{ownerName}，我到{location}了！{encounter}。{incident}。'
      '这里还有好多没弄明白的事，我要再仔细调查一下。——{petName}',
  'p_timid':
      '我平安到{location}了。{encounter}。{incident}。'
      '一开始有一点紧张，不过现在已经敢慢慢往前走了。——{petName}',
  'p_energetic':
      '我到{location}啦！！{encounter}！{incident}！'
      '这里还有好多地方没跑到，我现在就继续出发！！——{petName}',
  'p_clingy':
      '{ownerName}，我到{location}了。{encounter}。{incident}。'
      '风景很好，可我第一件事还是想写信给你。——{petName}',
  'p_aloof':
      '{location}。到了。{encounter}。{incident}。'
      '景色还行。想起你只是顺便，别多想。——{petName}',
  'p_naughty':
      '先声明，{location}今天发生的事不全是我干的。'
      '{encounter}。{incident}。细节等回去再交代。——{petName}',
  'p_gentle':
      '今天到了{location}。{encounter}。{incident}。'
      '这里的人和风景都很温柔，我会好好记住。——{petName}',
  'p_dreamy':
      '{location}像一封被风摊开的信。{encounter}。{incident}。'
      '我把这一页风景寄给你，愿你今晚做个好梦。——{petName}',
};
