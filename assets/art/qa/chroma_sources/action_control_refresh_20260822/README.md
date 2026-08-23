# Care-Bar Bath Icon Refresh - 2026-08-22

`bath_basin_chroma.png` was generated specifically for Hearth & Tails with
OpenAI image-generation tooling. Its visual references were limited to the
project-owned feed, play, and bath interaction-prop masters.

- No third-party stock image, character, brand, logo, font, or texture pack
  was supplied or referenced.
- `tools/build_action_control_icons.py` removes the chroma matte, preserves the
  soft watercolor edge, and derives the four 96px runtime care-bar icons.
- The transparent bath master is retained at
  `assets/art/source/action_controls/action_bath_master.png`.
- Runtime outputs are `assets/art/ui/ui_icon_act_{feed,pat,toy,bath}.png`.

The three unchanged subjects reuse the existing project-owned 512px feed,
petting-hand, and yarn-ball masters. The bath subject was redrawn as a clearer
cream-and-aqua basin so it remains legible in the 32px care control.
