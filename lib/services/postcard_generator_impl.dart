// 具名构造用私有字段，无法用 this._x 初始化形参，故豁免该 lint。
// ignore_for_file: prefer_initializing_formals
import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/postcard_content.dart';
import 'local_calendar.dart';
import 'postcard_content_alignment.dart';
import 'postcard_generator.dart';

/// PostcardGenerator 实现（spec-technical §3.5 / §6.3）。
///
/// 管线：地点 × 时间(季节/时段/天气) × 遭遇 × 碰撞 → 正文(性格文风) + 照片 + 邮戳。
/// 正文存渲染定稿以保证回看一致。
class PostcardGeneratorImpl implements PostcardGenerator {
  final Map<String, Location> _locations; // by id
  final List<PostcardTemplate> _templates;
  final List<Encounter> _encounters;
  final List<Incident> _incidents;
  final double Function() _rng;
  final DateTime Function() _now;
  final String Function() _idGen;
  final String _ownerName;
  final void Function(Postcard) _onPostcard;

  PostcardGeneratorImpl({
    required Map<String, Location> locations,
    required List<PostcardTemplate> templates,
    required List<Encounter> encounters,
    required List<Incident> incidents,
    required double Function() rng,
    required DateTime Function() now,
    required String Function() idGen,
    required String ownerName,
    required void Function(Postcard) onPostcard,
  }) : _locations = locations,
       _templates = templates,
       _encounters = encounters,
       _incidents = incidents,
       _rng = rng,
       _now = now,
       _idGen = idGen,
       _ownerName = ownerName,
       _onPostcard = onPostcard;

  @override
  Postcard generate({required Pet pet, required Journey journey}) {
    final locationId = _currentLocationId(journey);
    if (locationId == null) {
      throw StateError('Journey ${journey.id} has no postcard location');
    }
    return _generateAtLocation(
      pet: pet,
      journey: journey,
      locationId: locationId,
      seq: _currentSeq(journey),
    );
  }

  Postcard _generateAtLocation({
    required Pet pet,
    required Journey journey,
    required String locationId,
    required int seq,
  }) {
    final loc = _locations[locationId];
    if (loc == null) {
      throw StateError('Unknown postcard location: $locationId');
    }
    final mainP = pet.personality.isNotEmpty ? pet.personality.first : '';
    final generatedAt = _now();
    final season = _preferSceneValue(
      loc.allowedSeasons,
      LocalCalendar.season(generatedAt),
    );
    final timeOfDay = _preferSceneValue(
      loc.allowedTimesOfDay,
      LocalCalendar.timeOfDay(generatedAt),
    );
    final weather = _pick(loc.allowedWeather);

    final enc = _pickWeighted(
      preferPostcardLocationSpecific(
        _encounters.where((e) => e.poolId == loc.encounterPoolId),
        loc.id,
        (item) => item.locationIds,
      ),
      pet.personality,
    );
    final inc = _pickWeighted(
      preferPostcardLocationSpecific(
        _incidents.where((i) => loc.vibeTags.contains(i.vibe)),
        loc.id,
        (item) => item.locationIds,
      ),
      pet.personality,
    );

    final template = _pickTemplate(mainP, loc);
    final body = _render(
      template,
      loc,
      enc,
      inc,
      pet,
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
      seq: seq,
    );
    final photoId =
        'pc_photo_${loc.photoStyle}_${pet.speciesId}_${inc?.poseHint ?? 'idle'}';

    final pc = Postcard(
      id: _idGen(),
      petId: pet.id,
      journeyId: journey.id,
      locationId: loc.id,
      seq: seq,
      sentAt: generatedAt,
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
      templateId: template?.id,
      encounterId: enc?.id,
      incidentId: inc?.id,
      bodyText: body,
      photoAssetId: photoId,
      stampId: loc.stampId,
    );
    _onPostcard(pc);
    return pc;
  }

  @override
  Future<void> dailyTick({required Pet pet, required Journey journey}) async {
    if (journey.state == JourneyState.done) return;
    if (_now().isBefore(journey.nextPostcardAt)) return;

    switch (journey.state) {
      case JourneyState.active:
        _tickActiveJourney(pet: pet, journey: journey);
      case JourneyState.wandering:
        _tickWanderingJourney(pet: pet, journey: journey);
      case JourneyState.done:
        return;
    }
  }

  // ── 内部 ──────────────────────────────────────
  void _tickActiveJourney({required Pet pet, required Journey journey}) {
    final locationId = _locationAt(journey.stops, journey.currentIdx);
    if (locationId == null) return;

    _generateAtLocation(
      pet: pet,
      journey: journey,
      locationId: locationId,
      seq: journey.currentIdx,
    );

    if (journey.currentIdx < journey.stops.length - 1) {
      journey.currentIdx += 1;
      _scheduleNext(
        journey,
        GameConfig.postcardIntervalMinDays,
        GameConfig.postcardIntervalMaxDays,
      );
      return;
    }

    journey.currentIdx = journey.stops.length;
    journey.state = JourneyState.wandering;
    pet.state = PetState.roaming;
    _ensureWanderStops(journey, pet);
    _scheduleNextWandering(journey);
  }

  void _tickWanderingJourney({required Pet pet, required Journey journey}) {
    _ensureWanderStops(journey, pet);

    if (journey.wanderIdx < journey.wanderStops.length) {
      final locationId = _locationAt(journey.wanderStops, journey.wanderIdx);
      if (locationId == null) return;
      _generateAtLocation(
        pet: pet,
        journey: journey,
        locationId: locationId,
        seq: journey.stops.length + journey.wanderIdx,
      );
      journey.wanderIdx += 1;
      _scheduleNextWandering(journey);
      return;
    }

    final locationId = _pickAnyLocationId();
    if (locationId == null) return;
    _generateAtLocation(
      pet: pet,
      journey: journey,
      locationId: locationId,
      seq:
          journey.stops.length +
          journey.wanderStops.length +
          journey.longTermSeq,
    );
    journey.longTermSeq += 1;
    _scheduleNext(
      journey,
      GameConfig.longTermPostcardMinDays,
      GameConfig.longTermPostcardMaxDays,
    );
  }

  void _scheduleNextWandering(Journey journey) {
    if (journey.wanderIdx < journey.wanderStops.length) {
      _scheduleNext(
        journey,
        GameConfig.wanderPostcardMinDays,
        GameConfig.wanderPostcardMaxDays,
      );
    } else {
      _scheduleNext(
        journey,
        GameConfig.longTermPostcardMinDays,
        GameConfig.longTermPostcardMaxDays,
      );
    }
  }

  void _scheduleNext(Journey journey, int minDays, int maxDays) {
    final lower = minDays <= maxDays ? minDays : maxDays;
    final upper = maxDays >= minDays ? maxDays : minDays;
    final gap = lower + (_rng() * (upper - lower + 1)).floor();
    journey.nextPostcardAt = _now().add(Duration(days: gap));
  }

  void _ensureWanderStops(Journey journey, Pet pet) {
    if (journey.wanderStops.isNotEmpty ||
        journey.wanderIdx > 0 ||
        journey.longTermSeq > 0) {
      return;
    }

    final used = journey.stops.toSet();
    final candidates = <Location>[];
    final seen = <String>{...used};
    for (final location in _locations.values) {
      if (!seen.add(location.id)) continue;
      candidates.add(location);
    }

    final next = <String>[];
    while (candidates.isNotEmpty) {
      final index = _drawWeightedIndex(candidates, pet);
      final selected = candidates.removeAt(index);
      next.add(selected.id);
    }
    journey.wanderStops = next;
  }

  String? _currentLocationId(Journey journey) {
    if (journey.state == JourneyState.wandering) {
      if (journey.wanderIdx < journey.wanderStops.length) {
        return _locationAt(journey.wanderStops, journey.wanderIdx);
      }
      return _pickAnyLocationId();
    }
    return _locationAt(journey.stops, journey.currentIdx);
  }

  int _currentSeq(Journey journey) {
    if (journey.state == JourneyState.wandering) {
      if (journey.wanderIdx < journey.wanderStops.length) {
        return journey.stops.length + journey.wanderIdx;
      }
      return journey.stops.length +
          journey.wanderStops.length +
          journey.longTermSeq;
    }
    return journey.currentIdx;
  }

  String? _locationAt(List<String> locations, int index) {
    if (locations.isEmpty) return null;
    final safeIndex = index.clamp(0, locations.length - 1).toInt();
    return locations[safeIndex];
  }

  String? _pickAnyLocationId() {
    if (_locations.isEmpty) return null;
    final locations = _locations.values.toList();
    final index = (_rng() * locations.length)
        .floor()
        .clamp(0, locations.length - 1)
        .toInt();
    return locations[index].id;
  }

  int _drawWeightedIndex(List<Location> candidates, Pet pet) {
    var total = 0.0;
    for (final location in candidates) {
      final weight = _locationWeight(location, pet);
      if (weight.isFinite && weight > 0) {
        total += weight;
      }
    }

    if (total <= 0) {
      return (_rng() * candidates.length)
          .floor()
          .clamp(0, candidates.length - 1)
          .toInt();
    }

    final target = _rng() * total;
    var cursor = 0.0;
    for (var i = 0; i < candidates.length; i++) {
      final weight = _locationWeight(candidates[i], pet);
      if (!weight.isFinite || weight <= 0) continue;
      cursor += weight;
      if (target < cursor) return i;
    }
    return candidates.length - 1;
  }

  double _locationWeight(Location location, Pet pet) {
    var weight = 1.0;
    for (final tag in pet.personality) {
      weight *= location.personalityWeight[tag] ?? 1.0;
    }
    return weight;
  }

  PostcardTemplate? _pickTemplate(String personalityId, Location location) {
    final exact = preferPostcardLocationSpecific(
      _templates.where(
        (t) =>
            t.personalityId == personalityId && t.category == location.category,
      ),
      location.id,
      (item) => item.locationIds,
    );
    if (exact.isNotEmpty) return exact[(_rng() * exact.length).floor()];
    return null;
  }

  /// 按性格权重挑选（personalityBias 命中 pet 标签则乘权）；空则 null。
  T? _pickWeighted<T>(List<T> items, List<String> personality) {
    if (items.isEmpty) return null;
    double weightOf(T it) {
      final bias = it is Encounter
          ? it.personalityBias
          : (it is Incident ? it.personalityBias : const <String, double>{});
      double w = 1.0;
      for (final tag in personality) {
        w *= bias[tag] ?? 1.0;
      }
      return w;
    }

    final weights = items.map(weightOf).toList();
    final total = weights.fold<double>(0, (a, b) => a + b);
    var r = _rng() * total;
    for (var i = 0; i < items.length; i++) {
      r -= weights[i];
      if (r < 0) return items[i];
    }
    return items.last;
  }

  String _render(
    PostcardTemplate? tpl,
    Location loc,
    Encounter? enc,
    Incident? inc,
    Pet pet, {
    required Season season,
    required TimeOfDayOfDay timeOfDay,
    required Weather weather,
    required int seq,
  }) {
    final personalityId = pet.personality.isEmpty ? '' : pet.personality.first;
    return renderPostcardText(
      skeleton: tpl?.skeleton ?? fallbackPostcardSkeleton(personalityId),
      location: loc,
      encounter: enc,
      incident: inc,
      pet: pet,
      ownerName: _ownerName,
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
      seq: seq,
    );
  }

  T _pick<T>(List<T> pool) => pool[(_rng() * pool.length).floor()];

  T _preferSceneValue<T>(List<T> allowed, T preferred) {
    if (allowed.isEmpty) {
      throw StateError('Postcard scene profile must not be empty');
    }
    return allowed.contains(preferred) ? preferred : _pick(allowed);
  }
}
