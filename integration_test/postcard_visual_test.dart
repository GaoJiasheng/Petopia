import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petopia/app/game_controller.dart';
import 'package:petopia/data/content/content_repository_impl.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/pet.dart';
import 'package:petopia/l10n/english_narrative.dart';
import 'package:petopia/l10n/petopia_localizations.dart';
import 'package:petopia/services/postcard_content_alignment.dart';
import 'package:petopia/ui/petopia_theme.dart';
import 'package:petopia/ui/postcard_viewer_screen.dart';

const _prefix = String.fromEnvironment(
  'PETOPIA_VISUAL_PREFIX',
  defaultValue: 'postcard',
);
const _landscape = bool.fromEnvironment('PETOPIA_VISUAL_LANDSCAPE');
const _allPostcards = bool.fromEnvironment('PETOPIA_VISUAL_ALL_POSTCARDS');
const _allWeather = bool.fromEnvironment('PETOPIA_VISUAL_ALL_WEATHER');
const _visualLanguage = String.fromEnvironment(
  'PETOPIA_VISUAL_LANGUAGE',
  defaultValue: 'zh',
);
const _captureDirectory = String.fromEnvironment(
  'PETOPIA_VISUAL_DIR',
  defaultValue: '/tmp/petopia-postcard-visual',
);
const _species = <String>[
  'boo',
  'cat',
  'chameleon',
  'ember',
  'hamster',
  'parrot',
  'rabbit',
  'shiba',
  'snake',
  'starbug',
  'turtle',
  'uni',
];

final _cards = <PostcardView>[
  PostcardView(
    id: 'pc-visual-cat',
    petId: 'pet-cat-visual',
    petName: '阿橘',
    speciesId: 'pet_cat',
    variantId: 'pet_cat_v1',
    poseHint: 'gaze',
    locationName: '灯塔海湾',
    bodyText: '今天沿着海湾走了很久，风把云吹得软软的。灯塔旁边有一小片花，我在那里坐了一会儿，想起院子里的草地。',
    photoBg: 'pc_bg_lighthouse_bay',
    stampId: 'pc_stamp_lighthouse_bay',
    weather: Weather.clear,
    stickerIds: const ['pc_sticker_drift_bottle'],
    sentAt: DateTime.utc(2026, 7, 26),
    seq: 2,
  ),
  PostcardView(
    id: 'pc-visual-rabbit',
    petId: 'pet-rabbit-visual',
    petName: '云朵',
    speciesId: 'pet_rabbit',
    variantId: 'pet_rabbit_v2',
    poseHint: 'photo',
    locationName: '云端牧场',
    bodyText: '云像刚晒好的被子一样软。我背着包坐在山坡下，看风把远处的草一层层吹亮，也替你留了一小块安静的天空。',
    photoBg: 'pc_bg_cloud_ranch',
    stampId: 'pc_stamp_cloud_ranch',
    weather: Weather.rainbow,
    stickerIds: const ['pc_sticker_cloud_gap'],
    sentAt: DateTime.utc(2026, 7, 27),
    seq: 8,
  ),
];

List<PostcardView> _buildWeatherCards() {
  final base = _cards.first;
  return <PostcardView>[
    for (final weather in Weather.values)
      PostcardView(
        id: 'pc-visual-weather-${weather.name}',
        petId: base.petId,
        petName: base.petName,
        speciesId: base.speciesId,
        variantId: base.variantId,
        poseHint: base.poseHint,
        locationName: base.locationName,
        bodyText: base.bodyText,
        photoBg: base.photoBg,
        stampId: base.stampId,
        weather: weather,
        stickerIds: base.stickerIds,
        sentAt: base.sentAt,
        seq: base.seq,
      ),
  ];
}

Future<List<PostcardView>> _buildAllPostcards() async {
  final repo = AssetContentRepository();
  await repo.loadAll();
  final cards = <PostcardView>[];
  for (var index = 0; index < repo.locations.length; index++) {
    final location = repo.locations[index];
    final personality = repo.personalities[index % repo.personalities.length];
    final pet = Pet(
      id: 'postcard-review-pet-$index',
      speciesId: 'pet_${_species[index % _species.length]}',
      variantId: 'pet_${_species[index % _species.length]}_v1',
      name: '阿橘',
      personality: <String>[personality.id],
      bornAt: DateTime.utc(2026, 7, 1),
      lastOnlineAt: DateTime.utc(2026, 7, 1),
      offlineDayKey: '2026-07-01',
    );
    final encounters = preferPostcardLocationSpecific(
      repo.encounters.where((item) => item.poolId == location.encounterPoolId),
      location.id,
      (item) => item.locationIds,
    );
    final incidents = preferPostcardLocationSpecific(
      repo.incidents.where((item) => location.vibeTags.contains(item.vibe)),
      location.id,
      (item) => item.locationIds,
    );
    final templates = preferPostcardLocationSpecific(
      repo.postcardTemplates.where(
        (item) =>
            item.personalityId == personality.id &&
            item.category == location.category,
      ),
      location.id,
      (item) => item.locationIds,
    );
    final encounter = encounters.first;
    final incident = incidents.first;
    final template = templates.isEmpty ? null : templates.first;
    final season = location.allowedSeasons.first;
    final timeOfDay = location.allowedTimesOfDay.first;
    final weather = location.allowedWeather.first;
    final seq = index + 1;
    final body = renderPostcardText(
      skeleton: template?.skeleton ?? fallbackPostcardSkeleton(personality.id),
      location: location,
      pet: pet,
      ownerName: '主人',
      season: season,
      timeOfDay: timeOfDay,
      weather: weather,
      seq: seq,
      encounter: encounter,
      incident: incident,
    );
    cards.add(
      PostcardView(
        id: 'postcard-review-${location.id}',
        petId: pet.id,
        petName: _visualLanguage == 'en' ? 'Mochi' : pet.name,
        speciesId: pet.speciesId,
        variantId: pet.variantId,
        poseHint: incident.poseHint,
        locationName: location.name,
        locationNameEn: EnglishNarrative.locationName(
          location.id,
          fallback: 'A Faraway Place',
        ),
        bodyText: body,
        bodyTextEn: EnglishNarrative.postcardBody(
          personalityId: personality.id,
          templateId: template?.id,
          locationId: location.id,
          locationFallback: location.name,
          encounterId: encounter.id,
          incidentId: incident.id,
          petName: 'Mochi',
          season: season,
          timeOfDay: timeOfDay,
          weather: weather,
          seq: seq,
        ),
        photoBg: location.photoStyle,
        stampId: location.stampId,
        weather: weather,
        stickerIds: const <String>['pc_sticker_creased_map'],
        sentAt: DateTime.utc(2026, 8, 9),
        seq: index,
      ),
    );
  }
  return cards;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render postcard arrival art on device', (tester) async {
    await SystemChrome.setPreferredOrientations([
      _landscape
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp,
    ]);
    await tester.pump(const Duration(milliseconds: 800));

    final cards = _allPostcards
        ? await _buildAllPostcards()
        : _allWeather
        ? _buildWeatherCards()
        : _cards;
    expect(
      cards,
      hasLength(
        _allPostcards
            ? 40
            : _allWeather
            ? 7
            : 2,
      ),
    );
    for (final card in cards) {
      await tester.pumpWidget(_VisualHost(card: card));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey<String>('open_postcard')));
      await tester.pump(const Duration(milliseconds: 500));
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await tester.pump();

      expect(find.textContaining(card.petName), findsWidgets);
      expect(
        find.byKey(ValueKey<String>('postcard_weather_${card.weather.name}')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _capture(tester, binding, card.id);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
  });
}

class _VisualHost extends StatelessWidget {
  const _VisualHost({required this.card});

  final PostcardView card;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey<String>(card.id),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PetopiaColors.actionAccent,
          surface: PetopiaColors.paper,
        ),
        scaffoldBackgroundColor: PetopiaColors.background,
      ),
      locale: _visualLanguage == 'en'
          ? const Locale('en')
          : const Locale('zh', 'Hans'),
      supportedLocales: PetopiaLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        PetopiaLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/art/world/themes/yard_theme_sakura_bg.webp',
                fit: BoxFit.cover,
              ),
              Center(
                child: FilledButton(
                  key: const ValueKey<String>('open_postcard'),
                  onPressed: () => showPostcardArrivalDialog(context, card),
                  child: const Text('打开明信片'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 120));
  final bytes = await binding.takeScreenshot('$_prefix-$name');
  final directory = Directory(_captureDirectory)..createSync(recursive: true);
  File('${directory.path}/$_prefix-$name.png').writeAsBytesSync(bytes);
}
