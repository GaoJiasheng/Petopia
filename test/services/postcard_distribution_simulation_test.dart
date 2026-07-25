import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/services/postcard_generator_impl.dart';

class _SeededRng {
  int _state;

  _SeededRng(this._state);

  double next() {
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state / 0x80000000;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '10k postcard samples remain resolved, scene-safe and well distributed',
    () async {
      final content = AssetContentRepository();
      await content.loadAll();
      final rng = _SeededRng(0x5043);
      var generatedAt = DateTime.utc(2026, 1, 1, 4);
      var id = 0;
      final encounterIds = <String>{};
      final incidentIds = <String>{};
      final bodies = <String>{};
      var generated = 0;
      final generator = PostcardGeneratorImpl(
        locations: {
          for (final location in content.locations) location.id: location,
        },
        templates: content.postcardTemplates,
        encounters: content.encounters,
        incidents: content.incidents,
        rng: rng.next,
        now: () => generatedAt,
        idGen: () => 'distribution-${id++}',
        ownerName: '小院主人',
        onPostcard: (postcard) {
          generated++;
          if (postcard.encounterId != null) {
            encounterIds.add(postcard.encounterId!);
          }
          if (postcard.incidentId != null) {
            incidentIds.add(postcard.incidentId!);
          }
          bodies.add(postcard.bodyText);
        },
      );

      for (
        var personalityIndex = 0;
        personalityIndex < content.personalities.length;
        personalityIndex++
      ) {
        final personality = content.personalities[personalityIndex];
        final secondary =
            content.personalities[(personalityIndex + 1) %
                content.personalities.length];
        for (final location in content.locations) {
          for (var sample = 0; sample < 25; sample++) {
            generatedAt = DateTime.utc(2026, 1, 1, 4).add(
              Duration(
                days: (sample * 17 + personalityIndex * 29) % 365,
                hours: (sample * 5) % 24,
              ),
            );
            final pet = Pet(
              id: 'pet-${personality.id}',
              speciesId: 'pet_cat',
              variantId: 'pet_cat_var01',
              name: personality.name,
              personality: [personality.id, secondary.id],
              bornAt: DateTime.utc(2025, 1, 1),
              lastOnlineAt: generatedAt,
              offlineDayKey: '2026-01-01',
              state: PetState.roaming,
            );
            final journey = Journey(
              id: 'journey-${personality.id}-${location.id}-$sample',
              petId: pet.id,
              stops: [location.id],
              nextPostcardAt: generatedAt,
            );
            final postcard = generator.generate(pet: pet, journey: journey);

            expect(postcard.locationId, location.id);
            expect(location.allowedSeasons, contains(postcard.season));
            expect(location.allowedTimesOfDay, contains(postcard.timeOfDay));
            expect(location.allowedWeather, contains(postcard.weather));
            expect(postcard.stampId, location.stampId);
            expect(postcard.bodyText, isNot(contains(RegExp(r'\{[^}]+\}'))));
            expect(postcard.bodyText.runes.length, inInclusiveRange(12, 260));
          }
        }
      }

      expect(generated, 10000);
      expect(
        content.encounters
            .map((entry) => entry.id)
            .toSet()
            .difference(encounterIds),
        isEmpty,
        reason: 'some encounter entries are unreachable',
      );
      expect(
        content.incidents
            .map((entry) => entry.id)
            .toSet()
            .difference(incidentIds),
        isEmpty,
        reason: 'some incident entries are unreachable',
      );
      expect(
        bodies.length,
        greaterThan(1200),
        reason: 'postcard combinations are repeating more than intended',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
