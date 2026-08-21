# App Icon Review - 2026-08-02

## Direction

- Replaced the small prone kitten with a large, upright, front-facing orange
  kitten.
- The kitten uses a restrained head tilt, gentle smile, direct eye contact, and
  a complete seated silhouette.
- Both ears, all paws, and the curled tail remain inside the iOS mask-safe area.
- The full-bleed cream-to-tender-green garden background contains no text,
  frame, watermark, transparency, or pre-rendered rounded corners.

## Production Files

- Master: `docs/art-sources/app-icon/app_icon_master_2026-08-02.png`
- Rounded-mask review: `docs/art-review/app-icon-2026-08-02/ios-rounded-preview.png`
- iPhone home-screen review: `docs/art-review/app-icon-2026-08-02/iphone-home.png`
- iPad home-screen review: `docs/art-review/app-icon-2026-08-02/ipad-home.png`
- Build script: `tools/make_app_icon.py`
- iOS output: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android output: `android/app/src/main/res/mipmap-*/ic_launcher.png`

The master was generated specifically for Hearth & Tails with the built-in OpenAI
image-generation tool. Its only image references were the project's own orange
kitten Stage A art and the previous Hearth & Tails App Icon.

## Final Prompt Summary

Create one large, irresistibly cute Hearth & Tails orange kitten in a relaxed upright
seated pose, facing the viewer with a tiny natural smile, trusting glossy eyes,
and a slight friendly head tilt. Preserve the character's apricot tabby
markings and cream muzzle. Render it as premium cream-cartoon watercolor on a
clean ivory-to-tender-green full-bleed garden background. Keep the complete
silhouette within the platform mask-safe area. Use no text, logo mark, frame,
rounded corners, props, clothing, watermark, transparency, third-party
character, or stock imagery.

## QA

- 1024 x 1024 iOS marketing icon: opaque RGB.
- All 15 iOS icon renditions: expected dimensions and opaque RGB.
- All 5 Android launcher renditions: expected dimensions and opaque RGB.
- Manual checks: rounded-mask clearance, 40 px recognition, ear/paw/tail
  clipping, color separation, and visual noise.
- Simulator checks: successful iOS simulator build and installation on iPhone
  17 Pro Max and iPad Pro 13-inch; the system-rendered home-screen icon remains
  clear, correctly masked, and visually prominent on both device classes.
