# Theme Placement Regression - 2026-08-02

## Scope

- Themes: 12 (`meadow`, `sakura`, `seaside`, `starcamp`, `snowhut`,
  `autumnjam`, `bambootea`, `candybake`, `fourseasons`, `moongreen`,
  `mossrain`, `wheatkite`)
- Decor: all 14 yard placement slots occupied at once with distinct production
  assets.
- Animal combinations: the current pet plus one second animal in every
  supported side lane.
- Lighting: forced day and night passes, independent of the host clock.
- Devices: iPhone 17 Pro Max portrait and iPad Pro 13-inch landscape.

## Test Matrix

| Device | Lighting | Resolution | Scenes | Result |
| --- | --- | ---: | ---: | --- |
| iPhone 17 Pro Max | Day | 1320 x 2868 | 36 | Pass |
| iPhone 17 Pro Max | Night | 1320 x 2868 | 36 | Pass |
| iPad Pro 13-inch | Day | 2752 x 2064 | 36 | Pass |
| iPad Pro 13-inch | Night | 2752 x 2064 | 36 | Pass |

Each 36-scene set contains all 12 themes in these configurations:

- `<theme>-visitor-left.jpg`: current cat plus a large deer visitor on the left.
- `<theme>-visitor-right.jpg`: current cat plus a small butterfly visitor on the
  right.
- `<theme>-revisitor.jpg`: current cat plus a returning graduate rabbit.

Each device/lighting directory also contains three `contact-*.jpg` sheets for
fast visual comparison across all themes.

## Automated Checks

- All 14 keyed decor widgets are rendered in every scene.
- The current pet and the expected visitor or revisitor are rendered.
- The current pet and secondary animal layout rectangles do not overlap.
- Captures match the native simulator resolution and use opaque RGB output.
- No missing theme assets, fallback backgrounds, black bands, or framework
  exceptions were observed.

## Findings And Fixes

The first iPhone day pass exposed two genuine side-lane conflicts:

- Decor slot 8 (mushroom bench) competed with the left visitor lane.
- Decor slot 9 (scarecrow) competed with the right revisitor lane.

Both anchors were moved away from the animal lanes. All four complete batches
were then regenerated and manually reviewed at full size and as contact sheets.
No remaining clipping, animal overlap, or unreasonable decor collision was
found.

The visual test can inject an hour to make day/night captures deterministic.
The production default remains unset and continues to use the player's local
time.

## Archive

- Individual screenshots: 144
- Contact sheets: 12
- Total JPEG files: 156
