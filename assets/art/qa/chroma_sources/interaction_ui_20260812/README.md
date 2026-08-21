# Interaction UI Art Generation Record — 2026-08-12

This folder retains the chroma-background source outputs used for the Hearth & Tails
interaction-prop, postcard-weather, and repaired-decor production batch.

## Scope

- `actions/`: feed bowl, petting hand, yarn toy, and open bath-splash wreath.
- `weather/`: clear, cloudy, rain, thunder, snow, fog, and rainbow badges.
- `decor/`: complete postman scarecrow and golden star wind vane.

## Source And Rights Boundary

- Generated specifically for Hearth & Tails with OpenAI image-generation tooling.
- Visual references were limited to project-owned Golden Set art, existing
  Hearth & Tails pet/decor identity, and the palette rules in
  `docs/spec-art-overview.md`.
- Prompts did not name living artists, commercial games, protected
  characters, brands, fonts, logos, stock libraries, or external artworks.
- No third-party reference image, stock asset, texture pack, or sampled game
  asset was supplied.

## Production Prompt Set

All prompts required premium cream-cartoon watercolor rendering, bright but
gentle color, soft dimensional pigment, clean readable silhouettes, no text,
no watermark, no outline-only or geometric-vector treatment, a uniform chroma
background, and generous clearance around the complete subject and shadow.

- Feed: a warm cream ceramic pet bowl with kibble and a small paw motif.
- Pat: a complete gentle human hand with a soft coral cuff and two tiny hearts.
- Play: a lavender-blue yarn ball with a loose curved tail.
- Bath: an open circular wreath of water splashes, bubbles, foam, and a tiny
  yellow duck; the center must remain transparent so the pet stays visible.
- Weather: seven individually rendered, face-free watercolor marks for clear,
  cloudy, rain, thunder, snow, fog, and rainbow. Each mark uses a distinct
  silhouette, dimensional pigment, and a generous safe area so it remains
  recognizable in the postcard's 46 px weather slot.
- Scarecrow: a complete friendly postman scarecrow with an uncropped cap,
  outstretched sleeves, satchel, letter, straw body, flowers, and ground base.
- Wind vane: a complete golden star wind vane with arrow, hanging stars,
  ornamental post, vine, flowers, and stone base.

## Deterministic Derivation

The chroma background was removed with the project image-processing workflow,
edge color was decontaminated, soft alpha was preserved, and each selected
subject was resized onto a transparent production canvas without stretching.
Runtime files are:

- `assets/art/pets/action_props/*.png`
- `assets/art/postcards/weather/*.png`
- `assets/art/world/decor/deco_scarecrow_postman.png`
- `assets/art/world/decor/deco_star_vane.png`

`tools/audit_runtime_art.py` checks their margin, edge, alpha, color-detail,
and soft-shadow constraints. Release hashes are recorded in
`assets/provenance/release_asset_manifest.json`.
