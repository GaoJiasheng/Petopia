import '../domain/enums.dart';

/// Authored English narrative copy keyed by stable content IDs.
///
/// Save files continue to store language-neutral IDs and the original Chinese
/// snapshot. English is rebuilt at presentation time so changing languages is
/// immediate and old postcards remain compatible.
abstract final class EnglishNarrative {
  static bool coversLocation(String id) => _locationNames.containsKey(id);

  static bool coversVisitor(String id) => _visitorNames.containsKey(id);

  static bool coversSpecies(String id) => _speciesNames.containsKey(id);

  static bool coversEncounter(String id) => _encounters.containsKey(id);

  static bool coversIncident(String id) => _incidents.containsKey(id);

  static bool coversPostcardVoice(String personalityId) =>
      _postcardVoices.containsKey(personalityId);

  static bool coversVisitorInteraction({
    required String interactionId,
    required String visitorId,
    required String speciesId,
  }) =>
      _legendaryVisitorInteractions.containsKey(interactionId) ||
      (_visitorMoments.containsKey(visitorId) &&
          _speciesResponses.containsKey(speciesId));

  static bool coversEvent(String id) =>
      _eventTitles.containsKey(id) && _eventScripts.containsKey(id);

  static bool coversEventChoice(String id, int index) =>
      _eventChoiceTexts.containsKey('$id:$index') &&
      _eventChoiceResults.containsKey('$id:$index');

  static String locationName(String id, {required String fallback}) =>
      _locationNames[id] ?? fallback;

  static String visitorName(String id, {required String fallback}) =>
      _visitorNames[id] ?? fallback;

  static String speciesName(String id, {required String fallback}) =>
      _speciesNames[id] ?? fallback;

  static String encounter(String? id) => id == null
      ? 'I met a kind traveler along the way'
      : (_encounters[id] ?? 'I met a kind traveler along the way');

  static String incident(String? id) => id == null
      ? 'a small surprise made the day worth remembering'
      : (_incidents[id] ?? 'a small surprise made the day worth remembering');

  static String postcardBody({
    required String personalityId,
    required String? templateId,
    required String locationId,
    required String locationFallback,
    required String? encounterId,
    required String? incidentId,
    required String petName,
    required Season season,
    required TimeOfDayOfDay timeOfDay,
    required Weather weather,
    required int seq,
  }) {
    final location = locationName(locationId, fallback: locationFallback);
    final values = <String, String>{
      '{location}': location,
      '{encounter}': _sentenceCase(encounter(encounterId)),
      '{incident}': _sentenceCase(incident(incidentId)),
      '{petName}': petName,
      '{ownerName}': 'My dear friend',
      '{season}': _seasonLabel(season),
      '{timeOfDay}': _timeLabel(timeOfDay),
      '{weather}': _weatherLabel(weather),
      '{seq}': '${seq + 1}',
    };
    final variant = _templateVariant(templateId, seq);
    var result = _postcardSkeleton(personalityId, variant);
    for (final entry in values.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static String visitorInteraction({
    required String interactionId,
    required String visitorId,
    required String speciesId,
    required String visitorFallback,
    String? petName,
  }) {
    final special = _legendaryVisitorInteractions[interactionId];
    if (special != null) return special;

    final visitor = visitorName(visitorId, fallback: visitorFallback);
    final friend = petName?.trim().isNotEmpty == true
        ? petName!.trim()
        : speciesName(speciesId, fallback: 'your friend');
    final arrival =
        _visitorMoments[visitorId] ??
        'shared a quiet patch of the garden with $friend';
    final response =
        _speciesResponses[speciesId] ??
        '$friend stayed close and made the visitor feel at home';
    return '$visitor $arrival. $response.';
  }

  static String visitorWaiting({
    required String visitorId,
    required String visitorFallback,
  }) {
    final visitor = visitorName(visitorId, fallback: visitorFallback);
    return '$visitor has just arrived and is waiting to say hello.';
  }

  static String visitorResting({
    required String visitorId,
    required String visitorFallback,
  }) {
    final visitor = visitorName(visitorId, fallback: visitorFallback);
    return '$visitor is taking their time looking around the garden.';
  }

  static String growthMemory({
    required String memoryId,
    required String petName,
    required String personalityId,
    required String fallback,
  }) {
    final levelMatch = RegExp(r':lv(\d+)$').firstMatch(memoryId);
    final level = int.tryParse(levelMatch?.group(1) ?? '');
    return switch (level) {
      2 => '$petName can already tell the sound of your footsteps apart.',
      3 => '$petName has chosen a favorite corner for quiet daydreams.',
      4 => 'Whenever someone says their name, $petName looks for you first.',
      6 => _personalityGrowthMemory(petName, personalityId),
      7 =>
        '$petName now treats the flowers, breeze, and garden visitors as friends.',
      9 => '$petName has begun watching the gate and packing for the journey.',
      _ => fallback,
    };
  }

  static String travelMemory({
    required String petName,
    required String personalityId,
  }) {
    final detail = switch (personalityId) {
      'p_glutton' =>
        'has learned exactly when each town takes its pastries from the oven',
      'p_energetic' => 'found another road where the wind keeps pace for miles',
      'p_lazy' => 'found a faraway stone warmed to the perfect temperature',
      'p_curious' => 'has already filled half a notebook with new questions',
      'p_clingy' =>
        'still thinks of the garden gate before exploring each new place',
      'p_aloof' =>
        'wrote only "All is well," then tucked a pressed leaf into the envelope',
      'p_mischievous' || 'p_naughty' =>
        'promises there was no trouble this time, or at least no large trouble',
      'p_gentle' => 'has been looking after every small friend met on the road',
      'p_dreamy' =>
        'dreamed they could see the garden light even from far away',
      _ => 'is still seeing the world slowly and remembers every turn home',
    };
    return 'News from afar: $petName $detail.';
  }

  static String visitorDeparture({
    required String visitorId,
    required String visitorFallback,
    required bool hadPet,
    required bool interacted,
    String? petName,
  }) {
    final visitor = visitorName(visitorId, fallback: visitorFallback);
    if (!interacted) {
      return '$visitor passed through gently, leaving a small trace beside the garden path.';
    }
    if (hadPet && petName?.trim().isNotEmpty == true) {
      return 'Before leaving, $visitor looked back at ${petName!.trim()}; a quiet trail of footprints remained in the garden.';
    }
    return '$visitor lingered before leaving, as though memorizing the way back.';
  }

  static String eventTitle(String id, {required String fallback}) =>
      _eventTitles[id] ?? fallback;

  static String eventScript(String id, {required String fallback}) =>
      _eventScripts[id] ?? fallback;

  static String eventChoiceText(
    String id,
    int index, {
    required String fallback,
  }) => _eventChoiceTexts['$id:$index'] ?? fallback;

  static String eventChoiceResult(
    String id,
    int index, {
    required String fallback,
  }) => _eventChoiceResults['$id:$index'] ?? fallback;

  static int _templateVariant(String? templateId, int seq) {
    final match = RegExp(r'_(\d+)$').firstMatch(templateId ?? '');
    final parsed = int.tryParse(match?.group(1) ?? '');
    return parsed == null ? seq.abs() % 3 : (parsed - 1).clamp(0, 2);
  }

  static String _sentenceCase(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static String _postcardSkeleton(String personalityId, int variant) {
    final options = _postcardVoices[personalityId] ?? _postcardVoices['']!;
    return options[variant.clamp(0, options.length - 1)];
  }

  static String _personalityGrowthMemory(String petName, String personalityId) {
    final habit = switch (personalityId) {
      'p_glutton' =>
        'saves the tastiest bite for last, then gives you one thoughtful look',
      'p_energetic' =>
        'finishes every garden lap by coming back to touch your side',
      'p_lazy' => 'naps most peacefully wherever you spend the most time',
      'p_curious' =>
        'always checks that you noticed whenever something new appears',
      'p_clingy' => 'is always first to look when footsteps approach',
      'p_aloof' =>
        'still pretends not to care, but keeps moving their resting place closer to you',
      'p_mischievous' || 'p_naughty' =>
        'sits beside you with perfect innocence after every harmless bit of trouble',
      'p_gentle' => 'quietly watches over visitors smaller than they are',
      'p_dreamy' => 'wakes as if returning from a clear, warm dream',
      _ => 'has grown a habit that only you know by heart',
    };
    return '$petName $habit.';
  }

  static String _seasonLabel(Season value) => switch (value) {
    Season.spring => 'spring',
    Season.summer => 'summer',
    Season.autumn => 'autumn',
    Season.winter => 'winter',
  };

  static String _timeLabel(TimeOfDayOfDay value) => switch (value) {
    TimeOfDayOfDay.dawn => 'dawn',
    TimeOfDayOfDay.morning => 'morning',
    TimeOfDayOfDay.noon => 'noon',
    TimeOfDayOfDay.afternoon => 'afternoon',
    TimeOfDayOfDay.evening => 'evening',
    TimeOfDayOfDay.night => 'night',
  };

  static String _weatherLabel(Weather value) => switch (value) {
    Weather.clear => 'clear skies',
    Weather.cloudy => 'soft clouds',
    Weather.rain => 'rain',
    Weather.thunder => 'a thunderstorm',
    Weather.snow => 'snow',
    Weather.fog => 'mist',
    Weather.rainbow => 'a rainbow',
  };

  static const Map<String, String> _locationNames = <String, String>{
    'loc_lighthouse_bay': 'Lighthouse Bay',
    'loc_catback_reef': "Cat's Back Reef",
    'loc_shell_town': 'Seashell Town',
    'loc_tide_flat': 'Low-Tide Sandbar',
    'loc_seafog_pier': 'Sea Mist Pier',
    'loc_cloud_pass': 'Cloudtop Pass',
    'loc_monkey_spring': 'Monkey Hot Springs',
    'loc_maple_ridge': 'Maplefire Ridge',
    'loc_snowline_cabin': 'Snowline Cabin',
    'loc_echo_canyon': 'Echo Canyon',
    'loc_tram_street': 'Old Tram Street',
    'loc_rooftop_city': 'Rooftop Water Tower City',
    'loc_midnight_noodles': 'Midnight Noodle Street',
    'loc_oldbook_alley': 'Old Bookshop Alley',
    'loc_ferris_wharf': 'Ferris Wheel Wharf',
    'loc_wheat_post': 'Wheatfield Post Office',
    'loc_sunflower_station': 'Sunflower Station',
    'loc_firefly_paddy': 'Firefly Rice Fields',
    'loc_apple_farm': 'Apple Hill Farm',
    'loc_windmill_pond': 'Windmill Pond',
    'loc_mushroom_ring': 'Mushroom Ring Grove',
    'loc_oak_postbox': 'Ancient Oak Postbox',
    'loc_pinecone_market': 'Pinecone Market',
    'loc_fog_bridge': 'Misty Rope Bridge',
    'loc_logger_lodge': "Woodcutter's Lodge",
    'loc_salt_lake': 'Starlit Salt Lake',
    'loc_camel_oasis': 'Camel Bell Oasis',
    'loc_painted_bazaar': 'Painted Bazaar',
    'loc_wind_rocks': 'Wind-Carved Stone Forest',
    'loc_balloon_camp': 'Hot-Air Balloon Camp',
    'loc_aurora_village': 'Aurora Fishing Village',
    'loc_icefloe_lighthouse': 'Ice-Floe Lighthouse',
    'loc_blue_spring': 'Blue Grotto Spring',
    'loc_canal_town': 'Canal Town',
    'loc_steamboat_pier': 'Steamboat Pier',
    'loc_cloud_ranch': 'Cloudtop Ranch',
    'loc_moon_post': 'Far-Side Moon Post Office',
    'loc_frosting_volcano': 'Frosting Volcano',
    'loc_walking_island': 'Wandering Island',
    'loc_star_repair': 'Star Repair Shop',
  };

  static const Map<String, String> _visitorNames = <String, String>{
    'visitor_sparrow': 'Chirpy the Sparrow',
    'visitor_calico': 'Wandering Calico',
    'visitor_snail': 'Slow-Mail Snail',
    'visitor_butterfly': 'Cabbage White',
    'visitor_hedgehog': 'Pip the Hedgehog',
    'visitor_pigeon': 'Coo the Pigeon',
    'visitor_squirrel': 'Chestnut the Squirrel',
    'visitor_crow': 'Shiny the Crow',
    'visitor_frog': 'Ribbit the Frog',
    'visitor_firefly': 'Firefly Parade',
    'visitor_tanuki': 'Ginger Tanuki',
    'visitor_egret': 'Mr. Egret',
    'visitor_fox': 'Sienna the Fox',
    'visitor_owl': 'Professor Owl',
    'visitor_deer': 'Little Fawn',
    'visitor_snowhare': 'Snow Hare',
    'visitor_starbug': 'Starbug',
    'visitor_campfire_light': 'Campfire Glow',
    'visitor_rainbow_shade': 'The Rainbow\'s White Shadow',
    'visitor_night_blob': 'Midnight Puff',
  };

  static const Map<String, String> _speciesNames = <String, String>{
    'pet_cat': 'Orange Tabby',
    'pet_shiba': 'Shiba Inu',
    'pet_rabbit': 'Lop Rabbit',
    'pet_hamster': 'Hamster',
    'pet_turtle': 'Tortoise',
    'pet_parrot': 'Parrot',
    'pet_snake': 'Corn Snake',
    'pet_chameleon': 'Chameleon',
    'pet_ember': 'Emberling',
    'pet_uni': 'Niko the Uni-Rabbit',
    'pet_boo': 'Boo the Little Ghost',
    'pet_starbug': 'Starbug',
  };

  static const Map<String, String> _visitorMoments = <String, String>{
    'visitor_sparrow': 'sang a tiny fence-top concert for the afternoon',
    'visitor_calico': 'shared the warmest patch of sunlight without a fuss',
    'visitor_snail': 'delivered a leaf-sized note at an admirably careful pace',
    'visitor_butterfly': 'rested nearby while its pale wings opened and closed',
    'visitor_hedgehog': 'rolled in with a pocketful of leaves and good manners',
    'visitor_pigeon': 'cooed the latest rooftop news in a very official tone',
    'visitor_squirrel': 'brought one polished acorn and a dozen quick stories',
    'visitor_crow': 'showed off a bright button found beyond the fence',
    'visitor_frog': 'kept time with the water bowl in a soft evening rhythm',
    'visitor_firefly': 'turned the grass into a path of slow, floating lights',
    'visitor_tanuki': 'settled beside the gate as though this were an old stop',
    'visitor_egret':
        'stood quietly by the water and made the garden feel still',
    'visitor_fox': 'arrived with a russet leaf tucked neatly behind one ear',
    'visitor_owl': 'offered a thoughtful lecture on clouds, shadows, and naps',
    'visitor_deer': 'stepped softly among the flowers without bending a stem',
    'visitor_snowhare': 'left a cool footprint beside the sun-warmed path',
    'visitor_starbug':
        'blinked among the grass like a pocket-sized constellation',
    'visitor_campfire_light':
        'flickered beside the lantern without casting a shadow',
    'visitor_rainbow_shade':
        'waited where the last ribbon of rainbow touched the yard',
    'visitor_night_blob':
        'floated past like a shy cloud that had lost the moon',
  };

  static const Map<String, String> _speciesResponses = <String, String>{
    'pet_cat': 'They answered with three slow tail taps and a contented blink',
    'pet_shiba':
        'They stood proudly on lookout, taking the visit very seriously',
    'pet_rabbit': 'They listened with both long ears loose and peaceful',
    'pet_hamster':
        'They offered one carefully saved crumb from their secret stash',
    'pet_turtle': 'They made room on the warmest stone and stayed for company',
    'pet_parrot':
        'They tried out a brand-new greeting until everyone recognized it',
    'pet_snake':
        'They curled into a polite comma and listened without interrupting',
    'pet_chameleon':
        'They changed into the gentlest welcome color they could find',
    'pet_ember': 'They kept one tiny flame glowing warmly between them',
    'pet_uni': 'They left a faint rainbow shimmer over the visitor\'s path',
    'pet_boo':
        'They floated close enough to be friendly and calmly enough not to startle',
    'pet_starbug':
        'They blinked in time until the garden seemed full of scattered stars',
  };

  static const Map<String, String>
  _legendaryVisitorInteractions = <String, String>{
    'vpi_l_starbug_any':
        'Your friend held their breath as a point of light blinked among the grass. For a moment, even the visitor book seemed to glow.',
    'vpi_l_flame_any':
        'A flame that should not have been there danced beside the hearth. You both saw it, and neither of you broke the quiet.',
    'vpi_l_white_any':
        'After the rain, a white shape flashed where the rainbow touched the ground. Your friend watched that spot for a long time.',
    'vpi_l_boo_any':
        'A round white puff drifted through the midnight garden. Your friend followed it with their eyes; you saw only the wind.',
  };

  static const Map<String, List<String>>
  _postcardVoices = <String, List<String>>{
    'p_glutton': <String>[
      '{ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName}',
      'Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName}',
      'I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName}',
    ],
    'p_lazy': <String>[
      'Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName}',
      '{location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today\'s remaining energy. Love, {petName}',
      'The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName}',
    ],
    'p_curious': <String>[
      '{ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName}',
      'Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName}',
      'Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName}',
    ],
    'p_timid': <String>[
      'I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName}',
      '{location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName}',
      'The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName}',
    ],
    'p_energetic': <String>[
      'I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName}',
      'Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName}',
      '{ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName}',
    ],
    'p_clingy': <String>[
      '{ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName}',
      '{location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName}',
      'I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName}',
    ],
    'p_aloof': <String>[
      '{location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName}',
      'Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName}',
      '{location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName}',
    ],
    'p_naughty': <String>[
      'For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName}',
      'Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName}',
      '{ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName}',
    ],
    'p_gentle': <String>[
      'Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName}',
      'The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName}',
      '{ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName}',
    ],
    'p_dreamy': <String>[
      '{location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName}',
      'At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName}',
      'Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName}',
    ],
    '': <String>[
      '{ownerName}, I reached {location}. {encounter}. {incident}. I am safe, and I am keeping this piece of the journey for you. Love, {petName}',
      'A note from {location}: {encounter}. {incident}. The road is kind today, and I still remember every turn home. Love, {petName}',
      'Today at {location}. {encounter}. {incident}. I hope this letter carries some of the view back to you. Love, {petName}',
    ],
  };

  static const Map<String, String> _encounters = <String, String>{
    'enc_hb_01':
        'the grilled-fish vendor treated me to a fish fresh from the fire',
    'enc_hb_02':
        'the lighthouse keeper let me spend the night inside the tower',
    'enc_hb_03': 'an old sea turtle who navigates by currents kept me company',
    'enc_hb_04': 'a squad of gulls challenged me to race the crest of a wave',
    'enc_hb_05':
        'a beachcomber traded a piece of sea glass for one naturally shed whisker',
    'enc_hb_06':
        'I helped a hermit-crab moving crew carry new homes all afternoon',
    'enc_hb_07': 'an old boatbuilder raised a sail to shade me from the sun',
    'enc_hb_08': 'a white dolphin surfaced and traded one secret with me',
    'enc_sd_01': 'a little monkey insisted I was its new scarf',
    'enc_sd_02': 'I helped a porter catch luggage rolling down the slope',
    'enc_sd_03': 'a mountain goat challenged me to a climbing race',
    'enc_sd_04':
        'an herb-gathering grandmother shared a handful of roasted chestnuts',
    'enc_sd_05': 'a photographer asked me to pose above the sea of clouds',
    'enc_sd_06':
        'a self-appointed jay guide showed me a shortcut that was not shorter',
    'enc_sd_07': 'the lodge dog gave me the warmest place beside the stove',
    'enc_sd_08':
        'a badger hired me as a hot-spring digging apprentice for half a day',
    'enc_cs_01': 'the noodle-shop owner saved a slice of roast pork for me',
    'enc_cs_02': 'the tram driver invited me into the cab for one stop',
    'enc_cs_03': 'the old bookseller let me settle on top of the book piles',
    'enc_cs_04':
        'a rooftop calico traded me a map of every sunny spot in the city',
    'enc_cs_05': 'a lost puppy joined me while we searched for home',
    'enc_cs_06': 'a street artist painted me while we talked all afternoon',
    'enc_cs_07': 'I guarded a cart of parcels for the night-shift post carrier',
    'enc_cs_08':
        'a pigeon crew raced me for the best place beside the fountain',
    'enc_xy_01':
        'the farm grandmother paid me in apple pie for watching the orchard',
    'enc_xy_02':
        'I helped the postmistress deliver a letter to the farthest house',
    'enc_xy_03':
        'the goose that scolded me all day eventually showed me the way',
    'enc_xy_04': 'a field-mouse family invited me underground for wheat tea',
    'enc_xy_05':
        'the field keeper and I held a serious napping contest under the windmill',
    'enc_xy_06':
        'Mr. Scarecrow and I became friends, by my official declaration',
    'enc_xy_07': 'an orchard keeper traded two plums for my help at the stall',
    'enc_xy_08': 'a line of fireflies lit the night path for me',
    'enc_sl_01': 'a squirrel accountant negotiated a pinecone deal with me',
    'enc_sl_02': 'a lost little hedgehog decided to follow me',
    'enc_sl_03': 'Director Owl showed me the inside of a tree-hollow postbox',
    'enc_sl_04': 'a mushroom gatherer saved a small basket of trimmings for me',
    'enc_sl_05': 'the woodcutter\'s dog raced me to the ancient oak',
    'enc_sl_06':
        'a deer with a tiny bird on its head walked through the mist with me',
    'enc_sl_07': 'a spider weaver gave me a dew-bright length of silver thread',
    'enc_sl_08': 'a bear preparing to hibernate shared the last of its honey',
    'enc_sm_01':
        'the caravan leader let me travel at the back of the line for three days',
    'enc_sm_02': 'a painter searched for me, then appointed me color adviser',
    'enc_sm_03': 'a market vendor treated me to a bowl of warm camel-milk tea',
    'enc_sm_04':
        'a large-eared desert fox traded me the location of a cool burrow',
    'enc_sm_05': 'a balloon captain took me up to see the sunset',
    'enc_sm_06':
        'I spent the afternoon drawing water for travelers at the well',
    'enc_sm_07':
        'an old stargazer and I lay side by side naming constellations',
    'enc_jd_01':
        'a fishing-village grandfather gave me a place beside his stove',
    'enc_jd_02': 'a whole seal family took turns cuddling close for warmth',
    'enc_jd_03': 'a retired sled dog led me safely across the ice',
    'enc_jd_04':
        'I shared one very quiet night watch with the lighthouse keeper',
    'enc_jd_05': 'a flock of puffins recruited me for their diving show',
    'enc_jd_06': 'the boatman shared half a steaming grilled fish with me',
    'enc_jd_07':
        'a white fox sat beside me beneath the aurora for a long while',
    'enc_qh_01':
        'the moon-post carrier taught me the local rules for sending letters',
    'enc_qh_02': 'a cloud shepherd let me help herd cloud sheep all afternoon',
    'enc_qh_03': 'the island spoke to me in a very slow, gentle tremor',
    'enc_qh_04':
        'the confectioner let me taste the first batch of volcano frosting',
    'enc_qh_05': 'a Starbug merchant traded a vial of starlight for one wish',
    'enc_qh_06':
        'a little guardian spirit searching for an old friend traveled one stop with me',
  };

  static const Map<String, String> _incidents = <String, String>{
    'inc_hb_01': 'one wave carried off my hat and the next wave returned it',
    'inc_hb_02':
        'a bottle on the shore held a blank sheet that seemed saved for my letter',
    'inc_hb_03':
        'the low-tide sand glittered with a field of tiny silver fish scales',
    'inc_hb_04':
        'the tide rose while I slept and a piece of driftwood toured half the bay with me',
    'inc_hb_05':
        'a whole row of crabs sidestepped to let me pass like an honor guard',
    'inc_hb_06':
        'the lighthouse beam laid three seconds of broken gold across the sea',
    'inc_hb_07':
        'I chased a crab into seaweed and emerged with a brand-new hairstyle',
    'inc_hb_08':
        'the sea took my buried fish snack and returned two the next morning',
    'inc_sd_01':
        'the cloud sea opened at the pass just as I arrived, revealing every light below',
    'inc_sd_02':
        'the hot-spring mist was so thick that I hugged a rock by mistake',
    'inc_sd_03':
        'Echo Canyon carried my sneeze across five mountains, and all five answered',
    'inc_sd_04':
        'a pinecone landed squarely on my head while a squirrel apologized overhead',
    'inc_sd_05':
        'maple leaves filled my open backpack until it held a whole sunset',
    'inc_sd_06':
        'a second set of pawprints walked beside mine through the snow, though we never met',
    'inc_sd_07':
        'the mountain wind filled one yawn and rolled me into soft alpine flowers',
    'inc_sd_08':
        'frost flowers on the cabin window looked exactly like the garden fence',
    'inc_cs_01':
        'my tram-stop impression was so convincing that a platform waited for the wrong tram',
    'inc_cs_02': 'the noodle shop radio played the song you always hum',
    'inc_cs_03':
        'a broken midnight signal stayed green as if the city had cleared a path for me',
    'inc_cs_04':
        'I creased a map while napping on it, and the bookseller called the crease a shortcut',
    'inc_cs_05':
        'the Ferris wheel paused for repairs with my carriage at the very top',
    'inc_cs_06':
        'the water-tower shadow fitted over me like an enormous custom hat',
    'inc_cs_07':
        'a runaway flyer led me through three alleys and turned out to be a noodle coupon',
    'inc_cs_08':
        'a toy in a shop window was holding exactly the same pose as me',
    'inc_xy_01':
        'a rolling apple received a little guidance and rolled directly toward my mouth',
    'inc_xy_02':
        'fireflies formed one long, breathing ribbon of light above the rice fields',
    'inc_xy_03':
        'the only passenger at Sunflower Station was a basket full of chicks',
    'inc_xy_04':
        'I fell asleep in a haystack and woke in the next village on the hay cart',
    'inc_xy_05':
        'the windmill and my wagging tail kept exactly the same rhythm all afternoon',
    'inc_xy_06':
        'straight evening smoke rose from every chimney like ladders into the clouds',
    'inc_xy_07':
        'I knocked over the sale sign, so the orchard keeper thanked the whole village with a sale',
    'inc_xy_08':
        'a dry postmark stamped a perfect little heart around the missing ink',
    'inc_sl_01':
        'a mushroom ring lit up all at once as though tiny path lights were applauding',
    'inc_sl_02':
        'an overfilled backpack wedged me in a tree hollow and the whole market pulled me free',
    'inc_sl_03':
        'I forgot my acorn hiding place and every wrong hole contained someone else\'s treasure',
    'inc_sl_04':
        'when the fog opened, a deer looked back from the bridge and vanished a second later',
    'inc_sl_05':
        'a springy root flipped me straight into a freshly swept mountain of leaves',
    'inc_sl_06':
        'one ancient-oak leaf landed on my letter, so I counted it as the tree\'s signature',
    'inc_sl_07': 'resin lamps made the night market smell like warm biscuits',
    'inc_sl_08':
        'three experimental taps brought replies from every woodpecker in the forest',
    'inc_sm_01':
        'the still salt lake held one Milky Way overhead and another under my feet',
    'inc_sm_02':
        'my tail swept a paint stall into a mural that the merchant promptly priced',
    'inc_sm_03':
        'the dunes moved overnight and turned my marker stone into a summit monument',
    'inc_sm_04':
        'I mistook camel bells for a dinner bell and earned a proper caravan meal',
    'inc_sm_05':
        'a ten-minute desert shower became cool mist before touching the ground',
    'inc_sm_06': 'a market mynah called my name in exactly your voice',
    'inc_sm_07':
        'I hugged a loose balloon sandbag and received one free flight as ballast',
    'inc_sm_08':
        'the first star the old astronomer pointed to was the one I wished on last night',
    'inc_jd_01':
        'the aurora glowed so brightly that every village dog, including me, sang to it',
    'inc_jd_02':
        'I slid into a seal cuddle pile and was reluctantly, happily accepted',
    'inc_jd_03': 'my breath cloud and the steamboat whistle met in midair',
    'inc_jd_04':
        'an ice floe carried me beneath the lighthouse, where its beam covered me all night',
    'inc_jd_05':
        'I licked a frozen rail and the keeper rescued me with warm water',
    'inc_jd_06':
        'window light stamped the snowy village in neat squares of warm gold',
    'inc_jd_07':
        'the blue spring dressed my reflection in a transparent blue coat',
    'inc_qh_01':
        'a cloud sheep brushed past and left a tiny raining cloud on my back',
    'inc_qh_02':
        'the walking island sneezed, tossing every hat skyward and back onto the right head',
    'inc_qh_03':
        'the moon post office had an old postmark bearing the garden gate\'s number',
    'inc_qh_04':
        'Frosting Volcano sent down sweet snow flavored like {season} fruit',
    'inc_qh_05':
        'the guardian spirit had seen the name I keep saying on many other letters',
  };

  static const Map<String, String> _eventTitles = <String, String>{
    'ev_d01': 'Chasing Leaves',
    'ev_d02': 'Sun-Warmed Pancake',
    'ev_d03': 'Three Head Tilts',
    'ev_d04': 'The Hidden Glove',
    'ev_d05': 'Quality Inspection',
    'ev_d06': 'Surprise Sneeze',
    'ev_d07': 'Moonlight Recital',
    'ev_d08': 'The Pot Did It',
    'ev_d09': 'Half the Eaves',
    'ev_d10': 'Coat Watch',
    'ev_d11': 'The Forgotten Acorn',
    'ev_d12': 'A Quiet Garden Moment',
    'ev_d13': 'Waiting for Sunrise',
    'ev_d14': 'Meal-Time Watch',
    'ev_d15': 'First Snow',
    'ev_d16': 'Listening from the Box',
    'ev_d17': 'Snail Escort',
    'ev_d18': 'A View of Your Light',
    'ev_d19': 'The Eighth Pass',
    'ev_d20': 'The First Flower',
    'ev_d21': 'Sky in a Puddle',
    'ev_d22': 'Following Fireflies',
    'ev_d23': 'Polite Drooling',
    'ev_d24': 'A Dewy Stone',
    'ev_d25': 'The Hidden Biscuit',
    'ev_d26': 'Dinner in the Air',
    'ev_d27': 'Sleepy Chewing',
    'ev_d28': 'The Frozen Carrot',
    'ev_d29': 'Studying the Compendium',
    'ev_d30': 'The Acorn Banquet',
    'ev_d31': 'Rolling into Sunshine',
    'ev_d32': 'The Afternoon Yawn',
    'ev_d33': 'Too Foggy to Rise',
    'ev_d34': 'Keeping Cool',
    'ev_d35': 'Another Nap',
    'ev_d36': 'Staying Close',
    'ev_d37': 'Ant Procession Escort',
    'ev_d38': 'Patrol in the Mist',
    'ev_d39': 'A Wind Chime Lesson',
    'ev_d40': 'A Dinosaur Egg, Perhaps',
    'ev_d41': 'Waiting for the Bloom',
    'ev_d42': 'Peace with a Shadow',
    'ev_d43': 'Checking You Are There',
    'ev_d44': 'Playing a Stone',
    'ev_d45': 'Questioning the Clothesline',
    'ev_d46': 'The Crunchy Detour',
    'ev_d47': 'Shelter in Your Coat',
    'ev_d48': 'Morning Sprint',
    'ev_d49': 'Snowfield Art',
    'ev_d50': 'After the Laps',
    'ev_d51': 'Chasing the Grass Cord',
    'ev_d52': 'Chasing Rainbow Mist',
    'ev_d53': 'By Your Knee',
    'ev_d54': 'Your Footsteps',
    'ev_d55': 'The Treasure Button',
    'ev_d56': 'A Window of Mist',
    'ev_d57': 'Warming Up',
    'ev_d58': 'Sunbathing, Listening',
    'ev_d59': 'Polishing the Portrait',
    'ev_d60': 'A Neat Collection',
    'ev_d61': 'Watching the Moon',
    'ev_d62': 'Inspecting the Visitor\'s Seat',
    'ev_d63': 'The Slipper Hunt',
    'ev_d64': 'The Open Food Bowl',
    'ev_d65': 'Borrowed Hat',
    'ev_d66': 'Puddle Stomping',
    'ev_d67': 'The Perfect Cough',
    'ev_d68': 'Helping with the Leaves',
    'ev_d69': 'The Biggest Piece',
    'ev_d70': 'A Warm Place to Land',
    'ev_d71': 'Watching the Web Mend',
    'ev_d72': 'A Favorite Leaf for You',
    'ev_d73': 'Beetle Escort',
    'ev_d74': 'A Long Way into the Mist',
    'ev_d75': 'Chasing the Sunset Colors',
    'ev_d76': 'Dandelion Fleet',
    'ev_d77': 'One Snowflake',
    'ev_d78': 'Guardian of the Bowl Moon',
    'ev_d79': 'Dewdrop Sneeze',
    'ev_d80': 'Everything Is Here',
    'ev_d81': 'One by One',
    'ev_d82': 'Ready by the Door',
    'ev_d83': 'The Secret Tunnel',
    'ev_d84': 'Where Was I Going?',
    'ev_d85': 'Enough for Today',
    'ev_d86': 'A Self Wake-Up Call',
    'ev_d87': 'A Fresh Look',
    'ev_d88': 'Finding the Right Light',
    'ev_d89': 'A Grass-Scented Breath',
    'ev_d90': 'Chasing Winter Breath',
    'ev_d91': 'Raindrop Rhythm',
    'ev_d92': 'Turning Gold',
    'ev_d93': 'Waiting for Another Blink',
    'ev_d94': 'The Branch Exhibition',
    'ev_d95': 'Unfinished Watercolor',
    'ev_d96': 'Cloud-Watching Debate',
    'ev_d97': 'Checking on You',
    'ev_d98': 'A Trace of the Season',
    'ev_d99': 'By the Window Light',
    'ev_d100': 'A Good Kind of Day',
    'ev_s01': 'First Snow',
    'ev_s02': 'Adoption Anniversary',
    'ev_s03': 'Night of Falling Stars',
    'ev_s04': 'A Half-Day Adventure',
    'ev_s05': 'Shelter from the Storm',
    'ev_s06': 'A Departure Rehearsal',
    'ev_s07': 'An Old Friend\'s Keepsake',
    'ev_s08': 'Campfire Gathering',
    'ev_s09': 'The Rainbow\'s End',
    'ev_s10': 'Full-Moon Tea',
    'ev_s11': 'The First Flower Breeze',
    'ev_s12': 'The Great Firefly Parade',
    'ev_s13': 'Autumn Treasures in the Sun',
    'ev_s14': 'The Longest Winter Night',
    'ev_s15': 'Growing Into Themselves',
    'ev_s16': 'Coming of Age',
    'ev_s17': 'The Night the Grass Blinked',
    'ev_s18': 'The Midnight White Puff',
    'ev_s19': 'The Post Carrier in the Fog',
    'ev_s20': 'Two Weeks Together',
  };
  static const Map<String, String> _eventScripts = <String, String>{
    'ev_d01':
        'They caught a spinning leaf and carried it over for you to admire.',
    'ev_d02': 'They spread out like a pancake on a stone warmed by the sun.',
    'ev_d03':
        'They tilted their head at the reflection in the water bowl three times.',
    'ev_d04':
        'They dragged the glove you left outside into their bed and solemnly claimed it for safekeeping.',
    'ev_d05':
        'Caught nibbling from the visitor dish, they pretended to be checking the food quality.',
    'ev_d06':
        'Their own sneeze startled them into a quick jump straight upward.',
    'ev_d07':
        'Late at night, they offered the moon one suspiciously poetic recital.',
    'ev_d08':
        'After tipping over a flowerpot, they looked certain that it had made the decision itself.',
    'ev_d09':
        'They gave half their shelter beneath the eaves to a rain-soaked white butterfly.',
    'ev_d10':
        'They guarded the coat you set down from a distance, putting on their most serious look whenever anyone approached.',
    'ev_d11':
        'They buried an acorn with great care and immediately forgot where it was.',
    'ev_d12':
        'They found a comfortable patch of grass and sat perfectly still, listening to the wind move through the flowers.',
    'ev_d13':
        'At dawn, they waited on top of the mailbox and greeted the first ray of sunlight with a long yawn.',
    'ev_d14':
        'They began standing watch over the food bowl an hour early, asking with their eyes whether it was time yet.',
    'ev_d15':
        'The first touch of snow stopped them in place while they studied the cool white mystery.',
    'ev_d16':
        'Thunder sent them into a cardboard box, leaving only a narrow gap through which to watch the world.',
    'ev_d17':
        'They ran circles to guide Slow-Mail Snail. The snail traveled three centimeters; they completed thirty laps.',
    'ev_d18':
        'During the night, they quietly moved their bed to a place where they could see your light.',
    'ev_d19':
        'They casually passed the clothesline seven times, then dragged away your sock on the eighth.',
    'ev_d20':
        'They studied spring\'s first flower up close and returned with pollen dusting their face.',
    'ev_d21':
        'They spent the rainy afternoon watching the sky break apart and mend itself in a puddle.',
    'ev_d22':
        'They trotted after summer fireflies, then stopped as if catching one suddenly felt too sad.',
    'ev_d23':
        'A delicious smell drifted from the reunion cottage, so they sat politely by the fence and waited.',
    'ev_d24':
        'At dawn, they brought a dew-bright stone and placed it where you usually sit.',
    'ev_d25':
        'They hid the last biscuit in their bed overnight, then followed its scent straight back in the morning.',
    'ev_d26':
        'At dusk, they watched cooking smoke beyond the fence and looked up at every clink of dishes.',
    'ev_d27':
        'They sleepily chewed a leaf that drifted to their mouth before realizing they were awake.',
    'ev_d28':
        'They dragged home a carrot frozen solid by the snow and insisted it was a gift from nature.',
    'ev_d29':
        'They studied the illustrated food bowls in the pet compendium until one tiny drool spot bloomed on the page.',
    'ev_d30':
        'They found an acorn left from last autumn and held a very formal banquet for one.',
    'ev_d31':
        'They inched from bed to the sunlit patch with impressive calm and not one wasted movement.',
    'ev_d32':
        'One yawn stretched across the whole afternoon. You counted seven continuations.',
    'ev_d33':
        'One look at the fog convinced them that visibility was too poor for getting up, so back to bed they went.',
    'ev_d34':
        'On a summer afternoon, they stretched across the coolest stone until only slow, easy breathing remained.',
    'ev_d35':
        'Halfway through a nap, they peered out from bed, decided everything was fine, and settled in for another round.',
    'ev_d36':
        'At dusk, they stayed close to your feet, shifting every so often into an even more comfortable spot.',
    'ev_d37':
        'They discovered a line of ants moving house and anxiously escorted the procession for three whole meters.',
    'ev_d38':
        'They patrolled the misty garden with great care, looking for whoever had hidden the world.',
    'ev_d39':
        'After a long study of the new wind chime, they learned how to ring it with the lightest touch.',
    'ev_d40':
        'They found a perfectly round stone by the flower bed and rushed over to ask whether it might be a dinosaur egg.',
    'ev_d41':
        'They waited beside one flower bud all morning just to see the moment it opened.',
    'ev_d42':
        'After being followed by their own shadow all day, they finally spun around at dusk. The shadow stopped too, and peace was declared.',
    'ev_d43':
        'In the fog, they stayed within sight and looked back every three steps to make sure you were still there.',
    'ev_d44':
        'When a visitor arrived, they became perfectly still and played the part of a stone. Half an hour later, they glanced over and found the visitor still waiting patiently.',
    'ev_d45':
        'After the windblown clothesline startled them at night, they returned in daylight to question it properly.',
    'ev_d46':
        'The first crunch of a dry leaf froze them for ten seconds. They chose a quieter route after that.',
    'ev_d47':
        'Before the thunder began, they slipped into the coat you wore yesterday, where the familiar scent felt safe.',
    'ev_d48':
        'They sprinted ten morning laps around the garden, flinging a sparkling trail of dew behind them.',
    'ev_d49':
        'They plowed one crooked trench across the snow, then turned around to admire their landscape art.',
    'ev_d50':
        'They ran several fast laps around the garden. After stopping, the flowers still seemed to circle around them.',
    'ev_d51':
        'They fought an evenly matched battle with a windblown grass cord, then called a truce.',
    'ev_d52':
        'They chased the rainbow in the summer spray until they were completely soaked.',
    'ev_d53':
        'For as long as you sat in the garden, they rested quietly beside your knee.',
    'ev_d54':
        'They learned the sound of your footsteps and began spinning before you even reached the gate.',
    'ev_d55':
        'They found one of your lost buttons, declared it treasure, and hid it in the deepest part of their bed.',
    'ev_d56':
        'On a rainy day, they left a patch of mist on the window, then slowly cleared it to see you again.',
    'ev_d57':
        'On a winter morning, they moved close to your open palm for warmth while looking straight ahead as if merely passing by.',
    'ev_d58':
        'They sunbathed with their back to you while keeping careful track of every sound from your direction.',
    'ev_d59':
        'After you praised another pet in the compendium, they polished their own portrait until it shone.',
    'ev_d60':
        'They arranged the day\'s finest grass blades in one perfectly straight line, presenting an unquestionably flawless result.',
    'ev_d61':
        'They sat alone in a high place watching the moon, then pretended to be counting roof tiles when you came outside.',
    'ev_d62':
        'After the visitor left, they carefully inspected the place where the guest had sat, then paused as if reaching a private conclusion.',
    'ev_d63':
        'They hid your slippers at opposite ends of the garden and sat in the middle to enjoy the search.',
    'ev_d64':
        'They learned to open the food-bowl lid. Only three uneaten pieces remained at the scene.',
    'ev_d65':
        'They borrowed a visitor\'s hat, showed it off around half the garden, then returned it with ceremony.',
    'ev_d66':
        'They chose every puddle after the rain and seemed thoroughly pleased with every new splash of mud.',
    'ev_d67':
        'They copied your cough perfectly enough to fool you three times, then laughed first on the fourth.',
    'ev_d68':
        'They dove through the leaf pile you had just made, then offered to help rebuild it into something much wider.',
    'ev_d69':
        'They nudged the largest piece in the bowl toward the visitor and quietly ate a smaller one.',
    'ev_d70':
        'In the snow, their warmth cleared one small patch of ground for a passing sparrow to land.',
    'ev_d71':
        'They found a rain-damaged spiderweb and watched its owner repair it all afternoon without interrupting.',
    'ev_d72':
        'When you sneezed, they hurried over and placed their favorite leaf on the back of your hand.',
    'ev_d73':
        'At dusk, they slowed every movement while escorting a lost beetle all the way beyond the fence.',
    'ev_d74':
        'They sat for a long time in the deepest fog and returned looking as though they had traveled very far.',
    'ev_d75':
        'They tried several spots beneath the sunset, searching for the corner whose colors looked most like the sky.',
    'ev_d76':
        'They gathered a small tuft of dandelion down and blew it into the night like a fleet of invisible boats.',
    'ev_d77':
        'On a snowy night, they watched one flake fall from high above until it came to rest before them.',
    'ev_d78':
        'They announced that another moon lived in the water bowl and volunteered for nightly guard duty.',
    'ev_d79': 'A bright morning sneeze launched a nearby dewdrop into the air.',
    'ev_d80':
        'After a nap changed the angle of the light, they checked the whole garden: grass, bowl, and you. Everything was where it belonged.',
    'ev_d81':
        'They pushed each small object from the windowsill one at a time, looking back after every piece to check your expression.',
    'ev_d82':
        'They dragged your shoes to the door and arranged them into a very clear request to go outside together.',
    'ev_d83':
        'They dug a secret tunnel beside the flower bed. Its exit was twenty centimeters from the entrance, and they were delighted.',
    'ev_d84':
        'After filling their travel pouch, they forgot where they had been going and stood thinking for a very long time.',
    'ev_d85':
        'They moved one meter over the course of the afternoon. From their expression, that was clearly enough exercise for one day.',
    'ev_d86':
        'They learned the exact way you call their name and now use it to wake themselves every morning.',
    'ev_d87':
        'After carefully tidying up, they checked their reflection in the water bowl and approved of the day\'s fresh look.',
    'ev_d88':
        'They tried several spots beside your sweater and finally found the light that suited them best.',
    'ev_d89':
        'After the storm, they took one enormous breath of wet grass and seemed to relax from end to end.',
    'ev_d90':
        'Their first white breath of the winter morning surprised them, so they chased it for two steps.',
    'ev_d91':
        'They sat beneath a paper umbrella and nodded gently to the rhythm of spring rain.',
    'ev_d92':
        'They lay on top of the autumn leaves and slowly turned gold with the setting sun.',
    'ev_d93':
        'They waited beside the place in the grass that blinked last time, hoping someone might blink again.',
    'ev_d94':
        'They found an exceptionally fine branch and took it around the garden on exhibition all day.',
    'ev_d95':
        'The way they emerged slowly from the mist looked like a watercolor still waiting for its final brushstroke.',
    'ev_d96':
        'They sat beside a visitor watching clouds. One particular cloud drifted by, and the discussion suddenly became very serious.',
    'ev_d97':
        'As soon as the thunder passed, they checked you from head to toe, then pretended they had only wandered by.',
    'ev_d98':
        'While tidying the bed for the new season, you found a small trace of an earlier day. They studied it as though recognizing their past self.',
    'ev_d99':
        'Sleep was slow to arrive, so they stayed near your window for a while and returned to bed when the light dimmed.',
    'ev_d100':
        'Nothing happened today. They rested quietly and watched the sky for a long time. It was a good kind of day.',
    'ev_s01':
        'Your friend stepped into snow for the first time and left a trail of blossom-shaped marks behind.',
    'ev_s02':
        'On the anniversary of your first meeting, garden visitors arrived one by one, each carrying a gift chosen along the way.',
    'ev_s03':
        'As falling stars crossed the garden sky, your friend closed their eyes and made a wish, then shared only half of it with you.',
    'ev_s04':
        'Your friend discovered a new path by the fence and returned at dusk with a flower no one in the garden had seen before.',
    'ev_s05':
        'When thunder rolled across the garden, your friend moved close. As the rain softened, they relaxed beside you.',
    'ev_s06':
        'With departure drawing closer, your friend tried on a backpack, took two steps toward the gate, and looked back at you.',
    'ev_s07':
        'Before leaving, an old friend placed a scarf in the garden. Your current companion kept it close all day.',
    'ev_s08':
        'Beside the winter fire, a small shape seemed to dance inside the glow, then vanished between two flickers.',
    'ev_s09':
        'After the rain, the rainbow touched one corner of the garden. A white shape passed through the light, and your friend kept watching long after it vanished.',
    'ev_s10':
        'On the full moon, visitors filled the garden for a quiet tea gathering where no one needed to speak.',
    'ev_s11':
        'The first warm spring breeze filled the garden with petals. Your friend turned through the shower before stopping in the brightest patch of sunlight.',
    'ev_s12':
        'Hundreds of fireflies passed through on a summer night, lighting the fence while your friend watched from below.',
    'ev_s13':
        'In the clear autumn sun, your friend carefully laid out every treasure from the bed: a button, a branch, half an acorn, each warmed in turn.',
    'ev_s14':
        'On the longest winter night, you sat together in the lantern glow. Before falling asleep, your friend moved closer to your hand.',
    'ev_s15':
        'After growing into a new form, your friend studied the reflection in the water bowl, then looked back to make sure you still knew them. Of course you did.',
    'ev_s16':
        'On the first evening in their grown-up form, your friend brought over a beloved childhood toy as if offering that time a quiet thank-you.',
    'ev_s17':
        'On a clear moonless night, the grass beside the lantern truly blinked. You and your friend held your breath together.',
    'ev_s18':
        'Late at night, a round white shape floated over the wall and paused above your friend for one shy second.',
    'ev_s19':
        'A nameless old postcard appeared in the mailbox during heavy fog. It showed a garden no one had ever seen, and your friend studied it for a long time.',
    'ev_s20':
        'After fourteen days together, the growth journal turned back to its first page and set your friend\'s earliest clumsy steps beside who they are today.',
  };
  static const Map<String, String> _eventChoiceTexts = <String, String>{
    'ev_d12:0': 'Take a keepsake photo',
    'ev_d12:1': 'Sit beside them',
    'ev_d16:0': 'Sit beside the box',
    'ev_d16:1': 'Lower the lid partway',
    'ev_d24:0': 'Display the stone on the windowsill',
    'ev_d24:1': 'Praise it and return it for safekeeping',
    'ev_d28:0': 'Let them warm the carrot slowly',
    'ev_d28:1': 'Quietly trade it for a fresh one',
    'ev_d36:0': 'See them back to bed and tuck them in',
    'ev_d36:1': 'Stay together until the sky is dark',
    'ev_d40:0': 'Give it a place on the treasure shelf',
    'ev_d40:1': 'Return to the dig as an archaeology team',
    'ev_d52:0': 'Wait at the finish line with a towel',
    'ev_d52:1': 'Roll up your sleeves and join the chase',
    'ev_d61:0': 'Bring a stool and watch the moon together',
    'ev_d61:1': 'Leave a lantern and head inside',
    'ev_d66:0': 'Straight to the bath',
    'ev_d66:1': 'Let them enjoy one more triumphant lap',
    'ev_d78:0': 'Share one night watch',
    'ev_d78:1': 'Place a small lantern beside the bowl',
    'ev_d81:0': 'Move every small object out of reach',
    'ev_d81:1': 'Keep a straight face for the final piece',
    'ev_d87:0': 'Tell them they look wonderful today',
    'ev_d87:1': 'Take a photo of the new look',
    'ev_d94:0': 'Build the branch a proper display stand',
    'ev_d94:1': 'Admire it as though seeing it for the first time',
    'ev_d96:0': 'Agree that the cloud looks like a rice ball',
    'ev_d96:1': 'Insist that the cloud looks like a pillow',
    'ev_d99:0': 'Turn the light off early for bedtime',
    'ev_d99:1': 'Leave the light on and stay a while longer',
  };
  static const Map<String, String> _eventChoiceResults = <String, String>{
    'ev_d12:0':
        'You lifted the camera, and they sat straighter for you. The photograph kept the stillness of the afternoon.',
    'ev_d12:1':
        'You sat down beside them. Neither of you said a word while the breeze slowly carried the scent of flowers past.',
    'ev_d16:0':
        'You sat beside the box. The gap slowly widened, and together you listened until the storm had passed.',
    'ev_d16:1':
        'You lowered the lid by a third. They curled up at once and soon fell asleep in the soft darkness.',
    'ev_d24:0':
        'You placed the stone in the brightest spot on the windowsill. They pretended not to care while secretly checking it.',
    'ev_d24:1':
        'Your thoughtful praise delighted them. They reclaimed the stone and set it solemnly inside their keepsake box.',
    'ev_d28:0':
        'You set the carrot on a warm cloth to thaw. They stayed beside it as though guarding the whole winter.',
    'ev_d28:1':
        'You quietly swapped in a fresh carrot. One surprised bite later, it was joyfully gone.',
    'ev_d36:0':
        'You carried them back and tucked in the blanket. Their breathing soon settled into an easy rhythm.',
    'ev_d36:1':
        'You stayed until the stars appeared. Leaning against your feet, they finally felt ready for bed.',
    'ev_d40:0':
        'You made a special place for it on the treasure shelf. They now inspect the exhibit every day.',
    'ev_d40:1':
        'You returned to the dig together. They worked earnestly while you served as the official assistant.',
    'ev_d52:0':
        'You waited with a towel. They rushed over and scattered a trail of rainbow droplets across the grass.',
    'ev_d52:1':
        'You joined the chase. By the time the rainbow faded, both of you were soaked and neither was ready to stop.',
    'ev_d61:0':
        'You sat beside them on a small stool. They edged closer without taking their eyes from the moon.',
    'ev_d61:1':
        'You left a warm lantern and went inside. A quiet sound behind you felt exactly like good night.',
    'ev_d66:0':
        'You carried them to the bath, where they discovered that splashing indoors was every bit as enjoyable.',
    'ev_d66:1':
        'You let the victory lap continue. The puddles grew smaller while the muddy spots spread across the garden.',
    'ev_d78:0':
        'You shared the watch. They studied the moon in the bowl and nodded every so often to confirm all was well.',
    'ev_d78:1':
        'You placed a lantern beside the bowl. They settled down, satisfied that the moon now had a proper guard light.',
    'ev_d81:0':
        'You moved everything away. They stared for a moment, then discovered an entirely new harmless game.',
    'ev_d81:1':
        'You watched the final piece fall without changing expression. Thoroughly satisfied, they bounded off to explore.',
    'ev_d87:0':
        'You praised the way they looked today. They turned proudly until the sunlight found every angle.',
    'ev_d87:1':
        'You took a photograph. Whenever the journal opens to this page, the light from that day is there again.',
    'ev_d94:0':
        'You built a display stand. They now inspect the branch each day to make sure the collection is complete.',
    'ev_d94:1':
        'Your admiration made them even prouder. The exhibition immediately continued for another lap of the garden.',
    'ev_d96:0':
        'You agreed that it looked like a rice ball. They happily explained every fluffy detail.',
    'ev_d96:1':
        'You insisted on pillow. They gave you one doubtful look, then accepted the new interpretation.',
    'ev_d99:0':
        'You turned the light off early. They headed toward bed, pausing at the doorway for one last look at you.',
    'ev_d99:1':
        'You stayed with the light on. After a quiet moment beside you, they returned to bed content.',
  };
}
