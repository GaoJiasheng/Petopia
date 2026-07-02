import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/enums.dart';
import '../../domain/item_effect.dart';
import '../../domain/models/content_entities.dart';
import '../../domain/unlock_rule.dart';
import 'content_repository.dart';

const int _contentSchemaVersion = 1;
const String _contentRoot = 'assets/data';

class AssetContentRepository implements ContentRepository {
  bool _loaded = false;

  List<PetSpecies> _species = const <PetSpecies>[];
  List<PersonalityTag> _personalities = const <PersonalityTag>[];
  List<Location> _locations = const <Location>[];
  List<Visitor> _visitors = const <Visitor>[];
  List<VisitorPetInteraction> _visitorInteractions =
      const <VisitorPetInteraction>[];
  List<Event> _events = const <Event>[];
  List<Achievement> _achievements = const <Achievement>[];
  List<ShopItem> _shopItems = const <ShopItem>[];

  Map<String, PetSpecies> _speciesById = const <String, PetSpecies>{};
  Map<String, PersonalityTag> _personalitiesById =
      const <String, PersonalityTag>{};
  Map<String, Location> _locationsById = const <String, Location>{};
  Map<String, Visitor> _visitorsById = const <String, Visitor>{};
  Map<String, Event> _eventsById = const <String, Event>{};
  Map<String, Achievement> _achievementsById = const <String, Achievement>{};
  Map<String, ShopItem> _shopItemsById = const <String, ShopItem>{};

  @override
  Future<void> loadAll() async {
    if (_loaded) {
      return;
    }

    _species = await _loadItems('species.json', _parseSpecies);
    _personalities = await _loadItems('personalities.json', _parsePersonality);
    _locations = await _loadItems('locations.json', _parseLocation);
    _visitors = await _loadItems('visitors.json', _parseVisitor);
    _visitorInteractions = await _loadItems(
      'visitor_interactions.json',
      _parseVisitorInteraction,
    );
    _events = await _loadItems('events.json', _parseEvent);
    _achievements = await _loadItems('achievements.json', _parseAchievement);
    _shopItems = await _loadItems('shop_items.json', _parseShopItem);

    _speciesById = _indexById(_species, (item) => item.id);
    _personalitiesById = _indexById(_personalities, (item) => item.id);
    _locationsById = _indexById(_locations, (item) => item.id);
    _visitorsById = _indexById(_visitors, (item) => item.id);
    _eventsById = _indexById(_events, (item) => item.id);
    _achievementsById = _indexById(_achievements, (item) => item.id);
    _shopItemsById = _indexById(_shopItems, (item) => item.id);

    _loaded = true;
  }

  @override
  List<PetSpecies> get species => _species;

  @override
  List<PersonalityTag> get personalities => _personalities;

  @override
  List<Location> get locations => _locations;

  @override
  List<Visitor> get visitors => _visitors;

  @override
  List<VisitorPetInteraction> get visitorInteractions => _visitorInteractions;

  @override
  List<Event> get events => _events;

  @override
  List<Achievement> get achievements => _achievements;

  @override
  List<ShopItem> get shopItems => _shopItems;

  @override
  PetSpecies? speciesById(String id) => _speciesById[id];

  @override
  PersonalityTag? personalityById(String id) => _personalitiesById[id];

  @override
  Location? locationById(String id) => _locationsById[id];

  @override
  Visitor? visitorById(String id) => _visitorsById[id];

  @override
  Event? eventById(String id) => _eventsById[id];

  @override
  Achievement? achievementById(String id) => _achievementsById[id];

  @override
  ShopItem? shopItemById(String id) => _shopItemsById[id];
}

Future<List<T>> _loadItems<T>(
  String fileName,
  T Function(Map<String, dynamic>) parse,
) async {
  final path = '$_contentRoot/$fileName';
  final raw = await _loadStringOrNull(path);
  if (raw == null) {
    return List<T>.unmodifiable(<T>[]);
  }

  final root = _asObject(jsonDecode(raw), path);
  final schemaVersion = root['schemaVersion'];
  if (schemaVersion != _contentSchemaVersion) {
    throw StateError(
      '$path schemaVersion=$schemaVersion, expected $_contentSchemaVersion',
    );
  }

  final items = _asList(root['items'], '$path.items');
  return List<T>.unmodifiable(
    items.map((item) => parse(_asObject(item, '$path.items[]'))),
  );
}

Future<String?> _loadStringOrNull(String path) async {
  try {
    return await rootBundle.loadString(path);
  } on FlutterError catch (error) {
    if (error.toString().contains('Unable to load asset')) {
      debugPrint('Petopia content warning: missing $path, using empty list.');
      return null;
    }
    rethrow;
  }
}

PetSpecies _parseSpecies(Map<String, dynamic> json) {
  return PetSpecies(
    id: _string(json['id'], 'species.id'),
    name: _string(json['name'], 'species.name'),
    category: PetCategory.values.byName(_string(json['category'], 'category')),
    baseTone: _string(json['baseTone'], 'species.baseTone'),
    unlockRule: _parseUnlockRule(_asObject(json['unlockRule'], 'unlockRule')),
    variantIds: _stringList(json['variantIds']),
    dexArtRef: _string(json['dexArtRef'], 'species.dexArtRef'),
    dexSilhouetteRef: _string(
      json['dexSilhouetteRef'],
      'species.dexSilhouetteRef',
    ),
    dexMysteryRef: _nullableString(json['dexMysteryRef']),
  );
}

UnlockRule _parseUnlockRule(Map<String, dynamic> json) {
  final type = UnlockRuleType.values.byName(_string(json['type'], 'type'));
  return switch (type) {
    UnlockRuleType.initial => const InitialUnlock(),
    UnlockRuleType.gradCount => GradCountUnlock(
      _int(json['threshold'], 'unlockRule.threshold'),
    ),
    UnlockRuleType.hiddenClue => HiddenClueUnlock(
      clueId: _string(json['clueId'], 'unlockRule.clueId'),
      threshold: _int(json['threshold'], 'unlockRule.threshold'),
      clueText: _string(json['clueText'], 'unlockRule.clueText'),
      visitorPrereqId: _string(
        json['visitorPrereqId'],
        'unlockRule.visitorPrereqId',
      ),
      hiddenSteps: _asList(json['hiddenSteps'], 'unlockRule.hiddenSteps').map((
        item,
      ) {
        final step = _asObject(item, 'unlockRule.hiddenSteps[]');
        return HiddenStep(
          stepId: _string(step['stepId'], 'hiddenStep.stepId'),
          condType: AchievementCondType.values.byName(
            _string(step['condType'], 'hiddenStep.condType'),
          ),
          params: _dynamicMap(step['params']),
        );
      }).toList(),
    ),
  };
}

PersonalityTag _parsePersonality(Map<String, dynamic> json) {
  return PersonalityTag(
    id: _string(json['id'], 'personality.id'),
    name: _string(json['name'], 'personality.name'),
    persona: _string(json['persona'], 'personality.persona'),
    eventWeightMap: _stringDoubleMap(json['eventWeightMap']),
    actionExpBonus: _enumDoubleMap(json['actionExpBonus'], ExpSource.values),
    actionSetId: _string(json['actionSetId'], 'personality.actionSetId'),
    postcardStyleId: _string(
      json['postcardStyleId'],
      'personality.postcardStyleId',
    ),
    specialFlags: _stringList(json['specialFlags']),
  );
}

Location _parseLocation(Map<String, dynamic> json) {
  return Location(
    id: _string(json['id'], 'location.id'),
    name: _string(json['name'], 'location.name'),
    category: _string(json['category'], 'location.category'),
    climate: _string(json['climate'], 'location.climate'),
    vibeTags: _stringList(json['vibeTags']),
    photoStyle: _string(json['photoStyle'], 'location.photoStyle'),
    encounterPoolId: _string(
      json['encounterPoolId'],
      'location.encounterPoolId',
    ),
    personalityWeight: _stringDoubleMap(json['personalityWeight']),
    stampId: _string(json['stampId'], 'location.stampId'),
  );
}

Visitor _parseVisitor(Map<String, dynamic> json) {
  return Visitor(
    id: _string(json['id'], 'visitor.id'),
    name: _string(json['name'], 'visitor.name'),
    rarity: VisitorRarity.values.byName(_string(json['rarity'], 'rarity')),
    activeTime: _enumList(json['activeTime'], TimeOfDayOfDay.values),
    weatherPref: _enumDoubleMap(json['weatherPref'], Weather.values),
    foodPref: _stringDoubleMap(json['foodPref']),
    seasonPref: _enumDoubleMap(json['seasonPref'], Season.values),
    decorReq: _stringList(json['decorReq']),
    clueRole: _nullableString(json['clueRole']),
    artRef: _string(json['artRef'], 'visitor.artRef'),
  );
}

VisitorPetInteraction _parseVisitorInteraction(Map<String, dynamic> json) {
  return VisitorPetInteraction(
    id: _string(json['id'], 'visitorInteraction.id'),
    visitorId: _string(json['visitorId'], 'visitorInteraction.visitorId'),
    petSpeciesId: _string(
      json['petSpeciesId'],
      'visitorInteraction.petSpeciesId',
    ),
    script: _string(json['script'], 'visitorInteraction.script'),
    animRef: _string(json['animRef'], 'visitorInteraction.animRef'),
    expReward: _int(json['expReward'], 'visitorInteraction.expReward'),
    personalityBias: _nullableStringList(json['personalityBias']),
    unlockClue: _nullableString(json['unlockClue']),
  );
}

Event _parseEvent(Map<String, dynamic> json) {
  return Event(
    id: _string(json['id'], 'event.id'),
    type: EventType.values.byName(_string(json['type'], 'event.type')),
    title: _string(json['title'], 'event.title'),
    script: _string(json['script'], 'event.script'),
    expReward: _int(json['expReward'], 'event.expReward'),
    weights: _parseEventWeights(_asObject(json['weights'], 'event.weights')),
    animRef: _nullableString(json['animRef']),
    illustrationRef: _nullableString(json['illustrationRef']),
    currencyReward: _nullableInt(json['currencyReward']),
    cooldownDays: _intOrDefault(json['cooldownDays'], 0),
    oncePerPet: _boolOrDefault(json['oncePerPet'], defaultValue: false),
    choices: _parseEventChoices(json['choices']),
  );
}

EventWeights _parseEventWeights(Map<String, dynamic> json) {
  return EventWeights(
    personality: _stringDoubleMap(json['personality']),
    weather: _enumDoubleMap(json['weather'], Weather.values),
    timeOfDay: _enumDoubleMap(json['timeOfDay'], TimeOfDayOfDay.values),
    season: _enumDoubleMap(json['season'], Season.values),
    requiresVisitor: _nullableString(json['requiresVisitor']),
    requiresDecor: _nullableString(json['requiresDecor']),
    minLevel: _nullableInt(json['minLevel']),
    minLuxuryStage: _nullableInt(json['minLuxuryStage']),
  );
}

List<EventChoice>? _parseEventChoices(Object? value) {
  if (value == null) {
    return null;
  }
  return _asList(value, 'event.choices').map((item) {
    final json = _asObject(item, 'event.choices[]');
    return EventChoice(
      text: _string(json['text'], 'eventChoice.text'),
      resultScript: _string(json['resultScript'], 'eventChoice.resultScript'),
      expDelta: _int(json['expDelta'], 'eventChoice.expDelta'),
    );
  }).toList();
}

Achievement _parseAchievement(Map<String, dynamic> json) {
  return Achievement(
    id: _string(json['id'], 'achievement.id'),
    name: _string(json['name'], 'achievement.name'),
    hidden: _bool(json['hidden'], 'achievement.hidden'),
    condition: _parseAchievementCond(
      _asObject(json['condition'], 'achievement.condition'),
    ),
    reward: _parseRewardSpec(_asObject(json['reward'], 'achievement.reward')),
    clueText: _nullableString(json['clueText']),
  );
}

AchievementCond _parseAchievementCond(Map<String, dynamic> json) {
  return AchievementCond(
    type: AchievementCondType.values.byName(
      _string(json['type'], 'achievement.condition.type'),
    ),
    target: _int(json['target'], 'achievement.condition.target'),
    params: _dynamicMap(json['params']),
  );
}

RewardSpec _parseRewardSpec(Map<String, dynamic> json) {
  return RewardSpec(
    fluff: _intOrDefault(json['fluff'], 0),
    decorItemId: _nullableString(json['decorItemId']),
    couponId: _nullableString(json['couponId']),
    stickerId: _nullableString(json['stickerId']),
  );
}

ShopItem _parseShopItem(Map<String, dynamic> json) {
  return ShopItem(
    id: _string(json['id'], 'shopItem.id'),
    category: _string(json['category'], 'shopItem.category'),
    name: _string(json['name'], 'shopItem.name'),
    price: _int(json['price'], 'shopItem.price'),
    effect: _parseItemEffect(_asObject(json['effect'], 'shopItem.effect')),
    artRef: _string(json['artRef'], 'shopItem.artRef'),
    consumable: _boolOrDefault(json['consumable'], defaultValue: false),
    stackCount: _nullableInt(json['stackCount']),
  );
}

ItemEffect _parseItemEffect(Map<String, dynamic> json) {
  return ItemEffect(
    type: EffectType.values.byName(_string(json['type'], 'itemEffect.type')),
    params: _dynamicMap(json['params']),
  );
}

Map<String, T> _indexById<T>(List<T> items, String Function(T) idOf) {
  final map = <String, T>{};
  for (final item in items) {
    final id = idOf(item);
    if (map.containsKey(id)) {
      throw StateError('Duplicate content id: $id');
    }
    map[id] = item;
  }
  return Map<String, T>.unmodifiable(map);
}

Map<String, dynamic> _asObject(Object? value, String context) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw FormatException('$context must be an object');
}

List<Object?> _asList(Object? value, String context) {
  if (value == null) {
    return const <Object?>[];
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  throw FormatException('$context must be a list');
}

String _string(Object? value, String context) {
  if (value is String) {
    return value;
  }
  throw FormatException('$context must be a string');
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw const FormatException('nullable string field must be string or null');
}

int _int(Object? value, String context) {
  if (value is int) {
    return value;
  }
  throw FormatException('$context must be an int');
}

int _intOrDefault(Object? value, int defaultValue) {
  if (value == null) {
    return defaultValue;
  }
  if (value is int) {
    return value;
  }
  throw const FormatException('int field must be int or null');
}

int? _nullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  throw const FormatException('nullable int field must be int or null');
}

bool _bool(Object? value, String context) {
  if (value is bool) {
    return value;
  }
  throw FormatException('$context must be a bool');
}

bool _boolOrDefault(Object? value, {required bool defaultValue}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  throw const FormatException('bool field must be bool or null');
}

double _double(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  throw const FormatException('number field must be numeric');
}

List<String> _stringList(Object? value) {
  return _asList(
    value,
    'stringList',
  ).map((item) => _string(item, 'stringList[]')).toList();
}

List<String>? _nullableStringList(Object? value) {
  if (value == null) {
    return null;
  }
  return _stringList(value);
}

Map<String, double> _stringDoubleMap(Object? value) {
  if (value == null) {
    return const <String, double>{};
  }
  final json = _asObject(value, 'stringDoubleMap');
  return Map<String, double>.unmodifiable(
    json.map((key, value) => MapEntry(key, _double(value))),
  );
}

Map<E, double> _enumDoubleMap<E extends Enum>(Object? value, List<E> values) {
  if (value == null) {
    return <E, double>{};
  }
  final json = _asObject(value, 'enumDoubleMap');
  return Map<E, double>.unmodifiable(
    json.map((key, value) => MapEntry(values.byName(key), _double(value))),
  );
}

List<E> _enumList<E extends Enum>(Object? value, List<E> values) {
  return _asList(
    value,
    'enumList',
  ).map((item) => values.byName(_string(item, 'enumList[]'))).toList();
}

Map<String, dynamic> _dynamicMap(Object? value) {
  if (value == null) {
    return const <String, dynamic>{};
  }
  return Map<String, dynamic>.unmodifiable(_asObject(value, 'dynamicMap'));
}
