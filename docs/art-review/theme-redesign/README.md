# Yard Theme Day/Night Redesign Review

## Scope

- 12 themes: meadow, sakura, autumnjam, bambootea, candybake,
  fourseasons, moongreen, mossrain, seaside, snowhut, starcamp, wheatkite.
- Each theme has four production compositions: portrait day, portrait night,
  native 4:3 day, and native 4:3 night. Total: 48 reviewed backgrounds.
- Day and night are separate paintings. Night is a bright moonlit scene, not a
  dark overlay over the day image.

## Locked Composition Rules

- Full-bleed raster watercolor with no frame, text, watermark, alpha edge, or
  baked interactive object.
- Theme landmarks stay at the perimeter or in the distance. The central actor
  stage remains quiet enough for pets, visitors, bowls, and user decorations.
- Foreground actors keep their original color and value. Weather may add a
  restrained local effect, but time-of-day never dims the complete foreground.
- Portrait and iPad 4:3 are independently composed; neither is a stretched or
  mechanically cropped copy of the other.

## Review Material

- `portrait-day-contact-sheet.jpg` and `portrait-night-contact-sheet.jpg`:
  selected portrait masters.
- `wide-day-contact-sheet.jpg` and `wide-night-contact-sheet.jpg`: selected
  native 4:3 masters.
- `wide-*-actor-proof-contact-sheet.jpg`: pet, visitor, and companion overlays
  used to verify foreground readability.
- `device-qa/iphone17-pro-max-contact-sheet.jpg`: 12 real Flutter renders at
  1320x2868.
- `device-qa/ipad13-landscape-contact-sheet.jpg`: 12 real Flutter renders at
  2752x2064.

## Runtime Mapping

- Portrait day: `assets/art/world/themes/yard_theme_<slug>_bg.webp`
- Portrait night: `assets/art/world/themes/yard_theme_<slug>_bg_night.webp`
- iPad day: `assets/runtime/yard/themes/wide/yard_theme_<slug>_bg_wide.webp`
- iPad night:
  `assets/runtime/yard/themes/wide/yard_theme_<slug>_bg_night_wide.webp`
- Local day is 06:00-17:59; local night is 18:00-05:59.

## Provenance

Generated specifically for Hearth & Tails with OpenAI image generation, then selected,
reframed, color-corrected, exported, and visually reviewed for this product.
References were limited to project-owned theme art and approved control samples
in this directory. No third-party stock image, asset pack, logo, font, trademark,
or copyrighted franchise artwork was used as a source.
