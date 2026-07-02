// 具名构造用私有字段，无法用 this._x 初始化形参，故豁免该 lint。
// ignore_for_file: prefer_initializing_formals
import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';
import '../domain/models/content_entities.dart';
import '../domain/models/postcard_content.dart';
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
  })  : _locations = locations,
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
    final loc = _locations[journey.stops[journey.currentIdx]]!;
    final mainP = pet.personality.isNotEmpty ? pet.personality.first : '';

    final season = _seasonOf(_now());
    final timeOfDay = _pick(TimeOfDayOfDay.values);
    final weather = _pick(_weatherPool);

    final enc = _pickWeighted(
        _encounters.where((e) => e.poolId == loc.encounterPoolId).toList(),
        pet.personality);
    final inc = _pickWeighted(
        _incidents.where((i) => loc.vibeTags.contains(i.vibe)).toList(),
        pet.personality);

    final body = _render(_pickTemplate(mainP, loc.category), loc, enc, inc, pet);
    final photoId =
        'pc_photo_${loc.photoStyle}_${pet.speciesId}_${inc?.poseHint ?? 'idle'}';

    final pc = Postcard(
      id: _idGen(),
      petId: pet.id,
      journeyId: journey.id,
      locationId: loc.id,
      seq: journey.currentIdx,
      sentAt: _now(),
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
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

    generate(pet: pet, journey: journey);

    // 推进站点：到末尾则转「世界漫游」。
    if (journey.currentIdx < journey.stops.length - 1) {
      journey.currentIdx += 1;
      final gap = GameConfig.postcardIntervalMinDays +
          (_rng() *
                  (GameConfig.postcardIntervalMaxDays -
                      GameConfig.postcardIntervalMinDays +
                      1))
              .floor();
      journey.nextPostcardAt = _now().add(Duration(days: gap));
    } else {
      journey.state = JourneyState.wandering;
      pet.state = PetState.roaming;
      final gap = GameConfig.wanderPostcardMinDays +
          (_rng() *
                  (GameConfig.wanderPostcardMaxDays -
                      GameConfig.wanderPostcardMinDays +
                      1))
              .floor();
      journey.nextPostcardAt = _now().add(Duration(days: gap));
    }
  }

  // ── 内部 ──────────────────────────────────────
  static const List<Weather> _weatherPool = [
    Weather.clear,
    Weather.cloudy,
    Weather.rain,
    Weather.snow,
  ];

  PostcardTemplate? _pickTemplate(String personalityId, String category) {
    final exact = _templates
        .where((t) => t.personalityId == personalityId && t.category == category)
        .toList();
    if (exact.isNotEmpty) return exact[(_rng() * exact.length).floor()];
    final byCat = _templates.where((t) => t.category == category).toList();
    if (byCat.isNotEmpty) return byCat[(_rng() * byCat.length).floor()];
    return _templates.isNotEmpty ? _templates.first : null;
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
      PostcardTemplate? tpl, Location loc, Encounter? enc, Incident? inc, Pet pet) {
    final skeleton = tpl?.skeleton ??
        '主人，我到了{location}。{incident}。想你。——{petName}';
    return skeleton
        .replaceAll('{location}', loc.name)
        .replaceAll('{encounter}', enc?.phrase ?? '')
        .replaceAll('{incident}', inc?.phrase ?? '')
        .replaceAll('{petName}', pet.name)
        .replaceAll('{ownerName}', _ownerName);
  }

  T _pick<T>(List<T> pool) => pool[(_rng() * pool.length).floor()];

  Season _seasonOf(DateTime t) {
    final m = t.month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }
}
