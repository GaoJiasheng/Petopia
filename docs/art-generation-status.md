# Petopia 美术生成状态

> 当前 session 边界：只生成和整理视觉美术素材；不改代码、不改逻辑、不做 Flutter/Flame、不做数据转换。
>
> 当前风格基准：奶油卡通可爱风（creamy cartoon cute），以 `assets/art/samples/petopia-yard-style-sample-v3.png` 为第一版方向参考。要求更鲜艳、更卡通，避免整体偏黄。

## 生产原则

- 最终交付使用 PNG / Spine / DragonBones / PNG sprite sheet；SVG 只允许作为内部草稿，不作为最终资产。
- 先做不需要透明通道的背景与全屏素材，再做透明精灵/UI/图标。
- 每个生成文件必须复制进 `assets/art/...`，不能只留在 Codex 默认生成目录。
- 文件名优先使用规格文档中的 `asset_id`。

## 已生成

- [x] 风格样张 v2：`assets/art/samples/petopia-yard-style-sample-v2.png`
- [x] 风格样张 v3：`assets/art/samples/petopia-yard-style-sample-v3.png`

## 当前批次

Batch B / world theme backgrounds:

- [x] `yard_theme_meadow_bg` first pass: `assets/art/world/themes/yard_theme_meadow_bg.png`（QA：含飞鸟剪影，保留但不作为最终首选）
- [x] `yard_theme_meadow_bg` v2 no-animals candidate: `assets/art/world/themes/yard_theme_meadow_bg_v2.png`（QA：可作为首选版本）
- [x] `yard_theme_sakura_bg`: `assets/art/world/themes/yard_theme_sakura_bg.png`
- [x] `yard_theme_starcamp_bg`: `assets/art/world/themes/yard_theme_starcamp_bg.png`
- [x] `yard_theme_seaside_bg`: `assets/art/world/themes/yard_theme_seaside_bg.png`
- [x] `yard_theme_autumnjam_bg`: `assets/art/world/themes/yard_theme_autumnjam_bg.png`
- [x] `yard_theme_snowhut_bg`: `assets/art/world/themes/yard_theme_snowhut_bg.png`
- [x] `yard_theme_mossrain_bg`: `assets/art/world/themes/yard_theme_mossrain_bg.png`
- [x] `yard_theme_candybake_bg`: `assets/art/world/themes/yard_theme_candybake_bg.png`
- [x] `yard_theme_fourseasons_bg`: `assets/art/world/themes/yard_theme_fourseasons_bg.png`
- [x] `yard_theme_bambootea_bg`: `assets/art/world/themes/yard_theme_bambootea_bg.png`
- [x] `yard_theme_moongreen_bg`: `assets/art/world/themes/yard_theme_moongreen_bg.png`
- [x] `yard_theme_wheatkite_bg`: `assets/art/world/themes/yard_theme_wheatkite_bg.png`

Batch B / world theme prop sheets:

- [x] `yard_theme_meadow_props`: `assets/art/world/themes/yard_theme_meadow_props.png`
- [x] `yard_theme_sakura_props`: `assets/art/world/themes/yard_theme_sakura_props.png`
- [x] `yard_theme_starcamp_props`: `assets/art/world/themes/yard_theme_starcamp_props.png`
- [x] `yard_theme_seaside_props`: `assets/art/world/themes/yard_theme_seaside_props.png`
- [x] `yard_theme_autumnjam_props`: `assets/art/world/themes/yard_theme_autumnjam_props.png`
- [x] `yard_theme_snowhut_props`: `assets/art/world/themes/yard_theme_snowhut_props.png`
- [x] `yard_theme_mossrain_props`: `assets/art/world/themes/yard_theme_mossrain_props.png`
- [x] `yard_theme_candybake_props`: `assets/art/world/themes/yard_theme_candybake_props.png`
- [x] `yard_theme_fourseasons_props`: `assets/art/world/themes/yard_theme_fourseasons_props.png`
- [x] `yard_theme_bambootea_props`: `assets/art/world/themes/yard_theme_bambootea_props.png`
- [x] `yard_theme_moongreen_props`: `assets/art/world/themes/yard_theme_moongreen_props.png`
- [x] `yard_theme_wheatkite_props`: `assets/art/world/themes/yard_theme_wheatkite_props.png`

Batch C / yard layouts, decor, and light FX:

- [ ] `yard_luxury01_layout`
- [ ] `yard_luxury02_layout`
- [ ] `yard_luxury03_layout`
- [ ] `yard_luxury04_layout`
- [ ] `yard_luxury05_layout`
- [ ] `yard_luxury06_layout`
- [ ] core decor sprite sheet
- [ ] day/dusk/night/rain light FX overlays

## 待确认/待修规格

- [ ] 全屏源文件尺寸口径：`1290x2796` vs `1080x1920 @1x`。
- [ ] 寄居蟹搬家队是否补美术条目。
- [ ] `spec-art-world.md` MVP 摆件数量 13 vs 实际 12。
- [ ] 透明角色/精灵资产是否接受 chroma-key 抠图流程，还是后续改用原生透明工作流。

## 当前实际生成口径

- built-in imagegen 输出主题背景为 `941x1672` 9:16 PNG；后续如需严格 `1080x1920` 或 `1290x2796`，在美术终稿/导出版阶段统一升采样或重绘导出。
- theme props 透明 PNG 为 `1254x1254` sprite sheet；chroma 源文件保存在 `assets/art/qa/chroma_sources/`。
