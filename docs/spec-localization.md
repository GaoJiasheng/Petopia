# Petopia Localization

Runtime copy must also follow the [bilingual copy tone guide](copy-tone-guide.md), including warmth, restraint, character voice, purchase language, and narrative immersion.

## Supported languages

- `system`: follow the device. Simplified Chinese devices use Chinese; all
  other and unsupported device languages use English.
- `zhHans`: always use Simplified Chinese.
- `en`: always use English.

The choice is stored in `Settings.appLanguage`, included in normal save
round-trips, and applied at the root `MaterialApp`. iOS declares both
`zh-Hans` and `en` in `CFBundleLocalizations`.

## UI copy

Chinese remains the canonical source language for existing widgets.
`AppText` translates legacy source strings through `EnglishCopy` without
changing layout or business logic. Tooltips, form labels, image semantics,
and standalone `Semantics` labels must use `context.tr(...)`.

New copy should prefer a stable key:

```dart
context.l10n.keyed(
  'settings.notifications.title',
  zhHans: '温柔提醒',
  en: 'Gentle Reminders',
)
```

Do not branch on locale inside game rules, persistence, economy, scheduling,
or asset selection.

## Content names and narrative

Content IDs are language-neutral and are never translated in saves.
Species, personalities, locations, visitors, shop items, and other compact
display names are translated only at presentation time.

Long-form narrative content is localized through `EnglishNarrative` using
stable content IDs. The English layer covers all locations, postcard
encounters and incidents, personality-specific postcard voices, visitor and
species interactions, event stories and branches, and persisted growth/travel
memories.

Chinese narrative snapshots remain in saves so Chinese playback never changes.
New postcards also persist `templateId`. For older saves, the source template
is recovered from the rendered Chinese body and its persisted scene slots, then
English is rebuilt at presentation time. Player-authored pet names are never
translated. Unknown future content uses a neutral authored fallback instead of
machine translation.

## Adding a language

1. Add the enum value and locale mapping in `PetopiaLocalizations`.
2. Add the locale to `supportedLocales` and the platform declarations.
3. Add keyed UI copy and content display-name translations.
4. Add exact and dynamic-copy tests.
5. Add complete narrative coverage tests keyed by content IDs.
6. Run phone, 11-inch iPad, and 13-inch iPad layout tests in portrait and
   landscape, including 125% text scaling.

## Release checks

- `flutter analyze`
- `flutter test`
- Verify language switching takes effect immediately and survives relaunch.
- Verify no clipped labels in Settings, Shop, Album, Compendiums, Adoption,
  Growth Journal, Privacy, and postcard dialogs.
- Verify VoiceOver labels use the selected language.
