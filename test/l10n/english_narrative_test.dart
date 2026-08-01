import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/l10n/english_copy.dart';
import 'package:petopia/l10n/english_narrative.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetContentRepository content;

  setUpAll(() async {
    content = AssetContentRepository();
    await content.loadAll();
  });

  test('all locations, encounters, and incidents have clean English copy', () {
    expect(content.locations, hasLength(40));
    expect(content.encounters, hasLength(60));
    expect(content.incidents, hasLength(60));

    for (final location in content.locations) {
      expect(EnglishNarrative.coversLocation(location.id), isTrue);
      _expectEnglish(
        EnglishNarrative.locationName(location.id, fallback: location.name),
        reason: location.id,
      );
    }
    for (final encounter in content.encounters) {
      expect(EnglishNarrative.coversEncounter(encounter.id), isTrue);
      _expectEnglish(
        EnglishNarrative.encounter(encounter.id),
        reason: encounter.id,
      );
    }
    for (final incident in content.incidents) {
      expect(EnglishNarrative.coversIncident(incident.id), isTrue);
      _expectEnglish(
        EnglishNarrative.incident(incident.id),
        reason: incident.id,
      );
    }
  });

  test('location and visitor names stay consistent across every screen', () {
    for (final location in content.locations) {
      expect(
        EnglishNarrative.locationName(location.id, fallback: location.name),
        EnglishCopy.translate(location.name),
        reason: 'Location name diverged for ${location.id}',
      );
    }
    for (final visitor in content.visitors) {
      expect(
        EnglishNarrative.visitorName(visitor.id, fallback: visitor.name),
        EnglishCopy.translate(visitor.name),
        reason: 'Visitor name diverged for ${visitor.id}',
      );
    }
  });

  test('all 120 events and every branch have clean English copy', () {
    expect(content.events, hasLength(120));

    for (final event in content.events) {
      expect(EnglishNarrative.coversEvent(event.id), isTrue);
      _expectEnglish(
        EnglishNarrative.eventTitle(event.id, fallback: event.title),
        reason: '${event.id} title',
      );
      _expectEnglish(
        EnglishNarrative.eventScript(event.id, fallback: event.script),
        reason: '${event.id} script',
      );
      final choices = event.choices ?? const [];
      for (var index = 0; index < choices.length; index++) {
        expect(EnglishNarrative.coversEventChoice(event.id, index), isTrue);
        _expectEnglish(
          EnglishNarrative.eventChoiceText(
            event.id,
            index,
            fallback: choices[index].text,
          ),
          reason: '${event.id} choice $index',
        );
        _expectEnglish(
          EnglishNarrative.eventChoiceResult(
            event.id,
            index,
            fallback: choices[index].resultScript,
          ),
          reason: '${event.id} result $index',
        );
      }
    }
  });

  test('quiet garden event copy matches its static sitting artwork', () {
    final event = content.events.firstWhere((item) => item.id == 'ev_d12');

    expect(event.title, '安静时刻');
    expect(event.script, contains('坐得一动不动'));
    expect(event.choices, hasLength(2));
    expect(event.choices![1].text, '坐到它旁边');
    expect(
      EnglishNarrative.eventTitle(event.id, fallback: event.title),
      'A Quiet Garden Moment',
    );
    expect(
      EnglishNarrative.eventScript(event.id, fallback: event.script),
      contains('sat perfectly still'),
    );
    expect(
      EnglishNarrative.eventChoiceText(
        event.id,
        1,
        fallback: event.choices![1].text,
      ),
      'Sit beside them',
    );
  });

  test('all 244 visitor interactions produce clean species-aware English', () {
    expect(content.visitorInteractions, hasLength(244));

    for (final interaction in content.visitorInteractions) {
      final visitor = content.visitorById(interaction.visitorId);
      expect(visitor, isNotNull, reason: interaction.id);
      final speciesId = interaction.petSpeciesId == '*'
          ? 'pet_cat'
          : interaction.petSpeciesId;
      expect(
        EnglishNarrative.coversVisitor(visitor!.id),
        isTrue,
        reason: '${interaction.id} visitor ${visitor.id}',
      );
      expect(
        EnglishNarrative.coversSpecies(speciesId),
        isTrue,
        reason: '${interaction.id} species $speciesId',
      );
      expect(
        EnglishNarrative.coversVisitorInteraction(
          interactionId: interaction.id,
          visitorId: interaction.visitorId,
          speciesId: speciesId,
        ),
        isTrue,
        reason: interaction.id,
      );
      _expectEnglish(
        EnglishNarrative.visitorInteraction(
          interactionId: interaction.id,
          visitorId: interaction.visitorId,
          speciesId: speciesId,
          visitorFallback: visitor.name,
          petName: 'Mikan',
        ),
        reason: interaction.id,
      );
    }
  });

  test('all 240 postcard templates produce complete English letters', () {
    expect(content.postcardTemplates, hasLength(240));

    for (var index = 0; index < content.postcardTemplates.length; index++) {
      final template = content.postcardTemplates[index];
      expect(
        EnglishNarrative.coversPostcardVoice(template.personalityId),
        isTrue,
        reason: template.id,
      );
      final locationId = template.locationIds.isEmpty
          ? content.locations
                .firstWhere(
                  (location) => location.category == template.category,
                )
                .id
          : template.locationIds.first;
      final body = EnglishNarrative.postcardBody(
        personalityId: template.personalityId,
        templateId: template.id,
        locationId: locationId,
        locationFallback: 'A Faraway Place',
        encounterId: content.encounters[index % content.encounters.length].id,
        incidentId: content.incidents[index % content.incidents.length].id,
        petName: 'Mikan',
        season: Season.spring,
        timeOfDay: TimeOfDayOfDay.afternoon,
        weather: Weather.clear,
        seq: index,
      );
      _expectEnglish(body, reason: template.id);
      expect(body, isNot(contains(RegExp(r'\{[^}]+\}'))), reason: template.id);
      expect(
        RegExp(r'[.!?] [a-z]').hasMatch(body),
        isFalse,
        reason: '${template.id} contains a lowercase sentence start: $body',
      );
      expect(
        RegExp(r'[!！]{2,}|[?？]{2,}').hasMatch(body),
        isFalse,
        reason: '${template.id} uses exaggerated punctuation: $body',
      );
    }
  });

  test('runtime narrative copy stays warm, clean, and species-neutral', () {
    final forbiddenInternal = RegExp(
      r'【§|系统自动|线索\+\d|图鉴到访|Lv\s?\d',
      caseSensitive: false,
    );
    final repeatedPunctuation = RegExp(r'[!！]{2,}|[?？]{2,}');
    final coercive = RegExp(r'每天等信|很想很想|除非你肯等|要听完|应一声|没有你|离不开你');
    final genericAnatomy = RegExp(r'我的耳朵|我的尾巴|我的爪|我的肚皮|我的胡须|四条腿');

    final rows = <MapEntry<String, String>>[];
    for (final event in content.events) {
      rows.add(MapEntry('${event.id} title', event.title));
      rows.add(MapEntry('${event.id} script', event.script));
      for (var index = 0; index < (event.choices?.length ?? 0); index++) {
        final choice = event.choices![index];
        rows.add(MapEntry('${event.id} choice $index', choice.text));
        rows.add(MapEntry('${event.id} result $index', choice.resultScript));
      }
    }
    for (final template in content.postcardTemplates) {
      rows.add(MapEntry(template.id, template.skeleton));
      expect(
        genericAnatomy.hasMatch(template.skeleton),
        isFalse,
        reason: '${template.id} cannot assume a generic pet anatomy',
      );
    }
    for (final interaction in content.visitorInteractions) {
      rows.add(MapEntry(interaction.id, interaction.script));
    }

    for (final row in rows) {
      expect(forbiddenInternal.hasMatch(row.value), isFalse, reason: row.key);
      expect(repeatedPunctuation.hasMatch(row.value), isFalse, reason: row.key);
      expect(coercive.hasMatch(row.value), isFalse, reason: row.key);
    }
  });
}

void _expectEnglish(String value, {required String reason}) {
  expect(value.trim(), isNotEmpty, reason: reason);
  expect(value, isNot(contains(RegExp(r'[\u3400-\u9fff]'))), reason: reason);
}
