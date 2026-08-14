# Petopia Art Asset License And Provenance

This folder contains Petopia-specific visual assets created for this project.

## Scope

- Covered assets: runtime illustrations, pet art, visitors, world scenes,
  postcards, UI art, icons, and their lossless runtime derivatives under
  `assets/art/` and `assets/runtime/`.
- The distribution license is the repository root `ASSET_LICENSE`.
- The exact bundled inventory and hashes are recorded in
  `assets/provenance/release_asset_manifest.json`; production QA manifests under
  `assets/art/qa/` remain supporting records rather than the release inventory.
- Runtime derivatives preserve the visual source and inherit the same
  provenance. A format conversion does not grant or remove rights.

## Source Declaration

- The current visual batches were generated specifically for Petopia with
  image-generation tools and were then selected, edited, reframed, cut out,
  color-corrected, and quality-checked for this product.
- No third-party stock image, character sheet, game asset pack, logo, font,
  trademark, or copyrighted franchise artwork is intentionally included.
- Prompts and production rules avoid living-artist names, commercial game
  titles, copyrighted character names, and requests to reproduce protected
  artwork.
- Human review covers composition, clipping, transparency, text, watermark,
  visual consistency, and similarity concerns before an asset enters runtime.
- The 2026-08-02 day/night yard-theme batch uses only Petopia-owned theme art
  and approved control samples under `docs/art-review/theme-redesign/` as its
  visual references. It contains no third-party reference image or stock asset.
- The 2026-08-02 App Icon batch uses only the Petopia-owned orange kitten Stage
  A art and the previous Petopia icon as character and palette references. The
  approved master is retained under `docs/art-sources/app-icon/`; platform
  renditions are deterministic project derivatives with no third-party stock,
  character, logo, or font content.
- The 2026-08-10 postcard-pose and visitor-repair batch uses only Petopia-owned
  species prototypes, visitor specifications, and Golden Set references. Its
  chroma-key generation records are retained under
  `assets/art/qa/chroma_sources/*_20260810/`; production cutouts, portraits,
  and animation strips are human-reviewed project derivatives with no
  third-party stock, character, brand, logo, or font content.
- The 2026-08-10 decor-repair batch uses only Petopia-owned legacy decoration
  art as identity and palette reference. Chroma-key generation records are
  retained under `assets/art/qa/chroma_sources/decor_redo_20260810/`; the
  production planter and mushroom stool are human-reviewed project derivatives
  with no third-party stock, character, brand, logo, or font content.
- The 2026-08-12 interaction-UI batch covers four care props, seven postcard
  weather badges, and the repaired scarecrow and star wind vane. It uses only
  Petopia-owned Golden Set and existing project art as visual references.
  Chroma-key source outputs and prompt boundaries are retained under
  `assets/art/qa/chroma_sources/interaction_ui_20260812/`; no third-party
  reference image, stock asset, texture pack, character, brand, logo, or font
  is included.
- The 2026-08-13 freestanding wind-chime redraw uses only Petopia-owned yard
  decoration art, the Golden Set palette, and the existing item description.
  Its chroma-key source and processing boundary are retained under
  `assets/art/qa/chroma_sources/decor_redo_20260813/`; no third-party reference
  image, stock asset, texture pack, character, brand, logo, or font is included.

## Commercial Release Record

Before each commercial release, retain:

- the applicable generation service terms and account records;
- source and runtime manifest hashes;
- the final human QA report;
- contracts or licenses for any later third-party replacement asset.

The repository root Apache License 2.0 covers source code. The repository root
`ASSET_LICENSE` separately governs these art assets and their runtime copies.
The full release record is `docs/app-store/asset-rights-register.md`.

This file is a provenance record, not legal advice.
