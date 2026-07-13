# Petopia Audio Asset License And Provenance

This folder contains Petopia-specific music assets generated for this project.

## Scope

- Covered assets: `bgm_*` and `sting_*` files under `assets/audio/bgm/` and `assets/audio/sting/`.
- Current generation batch: see `assets/audio/provenance/music_provenance_manifest.json`.
- Runtime `.m4a` files are platform-compatible transcodes of the declared WAV masters and inherit the same provenance.
- These audio assets are not automatically covered by the repository root MIT License unless the project owner explicitly adds them to that license.

## Source Declaration

The current batch was generated through procedural original synthesis from the Petopia audio specification:

- No third-party samples, sample packs, loops, or reference audio were used.
- No artist-name, composer-name, band-name, soundtrack-name, or commercial song prompts were used.
- No commercial melody, recording, or copyrighted reference track was intentionally reproduced.
- The generator source is `assets/audio/provenance/generate_music_assets.py`.

## Compliance Notes

Before commercial release, keep this file with:

- the manifest hash records,
- final human review notes,
- any later composer/audio-director contracts,
- and any replacement asset licenses if files are swapped out.

This file is a provenance record, not legal advice.
