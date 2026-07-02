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

- [x] `yard_luxury01_layout`: `assets/art/world/layouts/yard_luxury01_layout.png`
- [x] `yard_luxury02_layout`: `assets/art/world/layouts/yard_luxury02_layout.png`
- [x] `yard_luxury03_layout`: `assets/art/world/layouts/yard_luxury03_layout.png`
- [x] `yard_luxury04_layout`: `assets/art/world/layouts/yard_luxury04_layout.png`
- [x] `yard_luxury05_layout`: `assets/art/world/layouts/yard_luxury05_layout.png`
- [x] `yard_luxury06_layout`: `assets/art/world/layouts/yard_luxury06_layout.png`
- [ ] `yard_luxury02_delta`
- [ ] `yard_luxury03_delta`
- [ ] `yard_luxury04_delta`
- [ ] `yard_luxury05_delta`
- [ ] `yard_luxury06_delta`
- [x] core decor sprite sheets: `assets/art/world/decor/world_decor_sheet_a_function_food.png` / `world_decor_sheet_b_shop_facilities.png` / `world_decor_sheet_c_facility_toys.png` / `world_decor_sheet_d_reward_atmosphere.png`
- [x] W2 main decor asset ids covered: 40/40 under `assets/art/world/decor/deco_*.png`
- [x] W3 light FX overlays and particles: `assets/art/world/fx/yard_fx_*.png`

## 待确认/待修规格

- [ ] 全屏源文件尺寸口径：`1290x2796` vs `1080x1920 @1x`。
- [ ] 寄居蟹搬家队是否补美术条目。
- [ ] `spec-art-world.md` MVP 摆件数量 13 vs 实际 12。
- [ ] 透明角色/精灵资产是否接受 chroma-key 抠图流程，还是后续改用原生透明工作流。

## 当前实际生成口径

- built-in imagegen 输出主题背景为 `941x1672` 9:16 PNG；后续如需严格 `1080x1920` 或 `1290x2796`，在美术终稿/导出版阶段统一升采样或重绘导出。
- theme props 透明 PNG 为 `1254x1254` sprite sheet；chroma 源文件保存在 `assets/art/qa/chroma_sources/`。
- yard layout 透明 PNG 为 `941x1672` full-screen layer；chroma 源文件保存在 `assets/art/qa/chroma_sources/`。
- W2 decor 主资产 40/40 已覆盖，另含满/空、亮/灭、四季树、动效首帧等变体，共 `78` 个 `deco_*.png`。
- W3 FX 已生成 `16` 个透明 PNG：白天/黄昏/夜晚/雨/雪覆盖层，雨雪粒子、极光 12 帧、萤火、柔雷 6 帧、花瓣/落叶/柳絮粒子。

## QA 备注

- `deco_pinwheel_paper` 当前第一版更像风车花环，后续精修批次建议补严格单个纸风车 v2。
