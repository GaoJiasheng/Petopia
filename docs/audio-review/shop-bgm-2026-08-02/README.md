# Shop BGM Review - 2026-08-02

## Direction

The previous shop loop combined four short marimba attacks per bar, a repeated
single whistle pitch, and evenly spaced brush/shaker hits at 84 BPM. That
combination read as a timer or alarm instead of a warm shop.

The replacement is a quieter indoor variation of the yard theme:

- The yard harmony and eight-note motif remain recognizable.
- Tempo is reduced from 84 BPM to 76 BPM.
- Felt piano and nylon guitar carry the music.
- Four naturally varied finger-picking shapes replace the fixed pulse.
- One muted wooden accent appears only every four bars.
- Soft counter ambience replaces the repeated whistle and shaker pattern.

## Deliverables

- Runtime mix: `assets/audio/bgm/mix/m4a/bgm_shop.m4a`
- WAV master: `assets/audio/bgm/mix/wav/bgm_shop.wav`
- OGG master: `assets/audio/bgm/mix/ogg/bgm_shop.ogg`
- Home motif stem: `assets/audio/bgm/stems/wav/bgm_shop__st1_home_motif.wav`
- Counter glow stem: `assets/audio/bgm/stems/wav/bgm_shop__st2_counter_glow.wav`
- Generator: `assets/audio/provenance/generate_music_assets.py --only shop`

## QA

| Check | Result |
| --- | --- |
| Duration | 101.053 seconds |
| Tempo | 76 BPM |
| Format | 48 kHz stereo; 24-bit WAV master; AAC-LC runtime M4A |
| Integrated loudness | -16.28 LUFS |
| True peak | -2.39 dBTP |
| Loudness range | 2.20 LU |
| PCM loop seam, first/last 60 ms | Exact match |
| DC offset | 0.000000041 max absolute |
| Median spectral centroid | 490 Hz, down from 855 Hz |
| Energy above 2.5 kHz | 0.35%, down from 0.93% |
| Transient crest | 22.07, down from 29.85 |

The lowered centroid, reduced high-frequency energy, and softer transient crest
directly address the alarm-like quality while preserving enough rhythmic motion
for browsing.

## Provenance

This track is original procedural synthesis for Petopia. It uses no third-party
sample, loop, recording, commercial melody, artist reference, or generated
audio service. The production manifest records the WAV, OGG, and runtime M4A
hashes; the release asset manifest records the bundled M4A hash.
