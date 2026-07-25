import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/services/postcard_content_alignment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all 40 locations compose aligned copy for every personality', () async {
    final repo = AssetContentRepository();
    await repo.loadAll();
    final personalityIds = repo.personalities.map((item) => item.id).toList();

    for (final location in repo.locations) {
      final encounters = preferPostcardLocationSpecific(
        repo.encounters.where(
          (item) => item.poolId == location.encounterPoolId,
        ),
        location.id,
        (item) => item.locationIds,
      );
      final incidents = preferPostcardLocationSpecific(
        repo.incidents.where((item) => location.vibeTags.contains(item.vibe)),
        location.id,
        (item) => item.locationIds,
      );
      expect(
        encounters,
        isNotEmpty,
        reason: '${location.id} must have an aligned encounter',
      );
      expect(
        incidents,
        isNotEmpty,
        reason: '${location.id} must have an aligned incident',
      );
      expect(location.allowedSeasons, isNotEmpty, reason: location.id);
      expect(location.allowedTimesOfDay, isNotEmpty, reason: location.id);
      expect(location.allowedWeather, isNotEmpty, reason: location.id);

      for (final personalityId in personalityIds) {
        final pet = Pet(
          id: 'pet-$personalityId',
          speciesId: 'pet_cat',
          variantId: 'var01',
          name: '阿橘',
          personality: [personalityId],
          bornAt: DateTime.utc(2026, 7, 1),
          lastOnlineAt: DateTime.utc(2026, 7, 1),
          offlineDayKey: '2026-07-01',
        );
        final templates = preferPostcardLocationSpecific(
          repo.postcardTemplates.where(
            (item) =>
                item.personalityId == personalityId &&
                item.category == location.category,
          ),
          location.id,
          (item) => item.locationIds,
        );
        final skeleton = templates.isEmpty
            ? fallbackPostcardSkeleton(personalityId)
            : templates.first.skeleton;
        final body = renderPostcardText(
          skeleton: skeleton,
          location: location,
          pet: pet,
          ownerName: '主人',
          season: location.allowedSeasons.first,
          timeOfDay: location.allowedTimesOfDay.first,
          weather: location.allowedWeather.first,
          seq: 5,
          encounter: encounters.first,
          incident: incidents.first,
        );

        expect(
          body,
          isNot(matches(RegExp(r'\{[^}]+\}'))),
          reason: '${location.id}/$personalityId left a raw slot: $body',
        );
        expect(
          body,
          contains('阿橘'),
          reason: '${location.id}/$personalityId lost pet identity',
        );
        expect(
          postcardSceneMatchesLocation(
            location: location,
            season: location.allowedSeasons.first,
            timeOfDay: location.allowedTimesOfDay.first,
            weather: location.allowedWeather.first,
          ),
          isTrue,
          reason: '${location.id}: scene profile rejected its own values',
        );
      }
    }
  });
}
