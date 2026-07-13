# Visitor Prototype QA v10

Scope: `assets/art/world/visitors/*_{portrait,yard_base,yard}.png`

Date: 2026-07-13

## Result

- Portrait prototypes: all 20 pass. No recrop needed.
- Yard static prototypes: all 20 were reframed from the LFS originals.
- Yard animation strips: all 20 strips were reframed from the LFS originals with one shared scale per strip, so the 8 frames stay size-consistent.
- Remodel needed: none found. The issue was tight export framing, not missing character geometry.

Acceptance target: each `yard_base` and every frame inside each `yard` strip keeps at least 12% transparent safety margin on all sides.

Machine QA:

- Before visual audit: `assets/art/qa/visitor_prototype_audit_v10.png`
- Reframe report: `assets/art/qa/visitor_reframe_report_v10.json`
- After margin summary: `assets/art/qa/visitor_margin_summary_v10_after.json`
- Final visual audit: `assets/art/qa/visitor_prototype_audit_v10_after.png`
- Updated static overview: `assets/art/world/visitors/visitor_yard_static_sheet_all20.png`

## Visitor List

| Visitor | Portrait | Yard static | Yard strip | Action |
|---|---|---|---|---|
| `visitor_butterfly` | OK | tight bottom | tight frame edges | reframed |
| `visitor_calico` | OK | tight bottom | tight bottom | reframed |
| `visitor_crow` | OK | tight bottom | tight top/side on some frames | reframed |
| `visitor_deer` | OK | tight bottom | tight bottom | reframed |
| `visitor_egret` | OK | tight bottom | tight bottom | reframed |
| `visitor_emberlight` | OK | tight bottom | tight edges | reframed |
| `visitor_firefly` | OK | tight bottom | tight bottom | reframed |
| `visitor_fox` | OK | tight bottom | tight bottom | reframed |
| `visitor_frog` | OK | tight bottom | tight edges | reframed |
| `visitor_ghostpuff` | OK | tight bottom | tight top/bottom | reframed |
| `visitor_hedgehog` | OK | tight bottom | tight edges | reframed |
| `visitor_owl` | OK | tight bottom | tight top/bottom | reframed |
| `visitor_pigeon` | OK | tight bottom | tight top/side/bottom | reframed |
| `visitor_rainbowshade` | OK | tight bottom | tight top/bottom | reframed |
| `visitor_snail` | OK | tight bottom | tight edges | reframed |
| `visitor_snowhare` | OK | tight bottom | tight side/bottom | reframed |
| `visitor_sparrow` | OK | tight side/bottom | tight side/bottom | reframed |
| `visitor_squirrel` | OK | tight bottom | tight edges | reframed |
| `visitor_starbug` | OK | tight side/bottom | tight edges | reframed |
| `visitor_tanuki` | OK | tight bottom | tight top/bottom | reframed |

## Notes

- The reported small-bird clipping was reproducible as a framing risk in `visitor_sparrow_yard_base.png` and `visitor_sparrow_yard.png`: the character was complete, but the transparent safety margin was too tight for downstream UI scaling.
- The final assets keep original filenames and pixel dimensions. Runtime references do not need code changes.
- No new generated model art was introduced in this pass because the original drawings were complete after safe reframing.
