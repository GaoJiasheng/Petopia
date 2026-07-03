# Petopia 美术生成状态

> 当前 session 边界：只生成和整理视觉美术素材；不改代码、不改逻辑、不做 Flutter/Flame、不做数据转换。
>
> 当前风格基准：奶油卡通可爱风（creamy cartoon cute），v5 Golden Set 已作为最新 polish 方向参考：`assets/art/samples/petopia-golden-v5-contact-sheet.png`。要求更鲜艳、更卡通，避免整体偏黄，并遵守 full-bleed/分层/无文字硬约束。

## 生产原则

- 最终交付使用 PNG / Spine / DragonBones / PNG sprite sheet；SVG 只允许作为内部草稿，不作为最终资产。
- 先做不需要透明通道的背景与全屏素材，再做透明精灵/UI/图标。
- 每个生成文件必须复制进 `assets/art/...`，不能只留在 Codex 默认生成目录。
- 文件名优先使用规格文档中的 `asset_id`。

## 已生成

- [x] 风格样张 v2：`assets/art/samples/petopia-yard-style-sample-v2.png`
- [x] 风格样张 v3：`assets/art/samples/petopia-yard-style-sample-v3.png`
- [x] v4 Golden Set 合辑：`assets/art/samples/petopia-golden-v4-contact-sheet.png`
- [x] v4 Golden Set 单张：yard / cat growth / visitor / postcard / UI board，见 `docs/art-polish-v4-golden-set.md`
- [x] v5 Golden Set 合辑：`assets/art/samples/petopia-golden-v5-contact-sheet.png`
- [x] v5 Golden Set 单张：full-bleed yard / travel-stage cat growth / natural visitor / V2 postcard / no-text UI board，见 `docs/art-polish-v5-golden-set.md`

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
- [x] `yard_luxury02_delta`: `assets/art/world/layouts/yard_luxury02_delta.png`
- [x] `yard_luxury03_delta`: `assets/art/world/layouts/yard_luxury03_delta.png`
- [x] `yard_luxury04_delta`: `assets/art/world/layouts/yard_luxury04_delta.png`
- [x] `yard_luxury05_delta`: `assets/art/world/layouts/yard_luxury05_delta.png`
- [x] `yard_luxury06_delta`: `assets/art/world/layouts/yard_luxury06_delta.png`
- [x] core decor sprite sheets: `assets/art/world/decor/world_decor_sheet_a_function_food.png` / `world_decor_sheet_b_shop_facilities.png` / `world_decor_sheet_c_facility_toys.png` / `world_decor_sheet_d_reward_atmosphere.png`
- [x] W2 main decor asset ids covered: 40/40 under `assets/art/world/decor/deco_*.png`
- [x] W3 light FX overlays and particles: `assets/art/world/fx/yard_fx_*.png`

Batch D / visitors:

- [x] visitor portrait sheet: `assets/art/world/visitors/visitor_portrait_sheet_all20.png`
- [x] visitor portraits: 20/20 `assets/art/world/visitors/visitor_*_portrait.png`
- [x] visitor yard static source sheet: `assets/art/world/visitors/visitor_yard_static_sheet_all20.png`
- [x] visitor yard sprite sheets: 20/20 `assets/art/world/visitors/visitor_*_yard.png`

Batch E / pets:

- [x] pet morphology sheets: 12/12 under `assets/art/pets/<species>/pet_<species>_morph_sheet.png`
- [x] pet forms: 240/240 `pet_<species>_varNN_stageX.png`
- [x] pet dex assets: 12 color + 12 silhouette + 4 mystery under `assets/art/pets/dex/`
- [x] common action templates: 96 primary `pet_<species>_stageC_<action>.png` plus 96 var01 aliases under `assets/art/pets/<species>/actions/`
- [x] personality action templates: 100/100 under `assets/art/pets/personality/act_*.png`
- [x] easter pet FX: 4/4 under `assets/art/pets/fx/`

Batch F / postcards:

- [x] postcard backgrounds: 40/40 under `assets/art/postcards/backgrounds/pc_bg_*.png`
- [x] postcard pet poses: 96/96 under `assets/art/postcards/poses/pc_pose_*.png`
- [x] postcard filters: 6/6 under `assets/art/postcards/filters/pc_filter_*.png`
- [x] postcard stickers: 61 PNG under `assets/art/postcards/stickers/pc_sticker_*.png`
- [x] postcard stamps: 40/40 under `assets/art/postcards/stamps/pc_stamp_*.png`
- [x] postcard specials: 20/20 under `assets/art/postcards/specials/pc_special_*.png`
- [x] postcard chrome: 10/10 under `assets/art/postcards/chrome/pc_chrome_*.png`

Batch G / UI:

- [x] UI main asset ids extracted from `docs/spec-art-ui.md`: 178 PNG under `assets/art/ui/ui_*.png`
- [x] QA manifest: `assets/art/qa/generated_asset_manifest.json`

Batch H / v4 Golden Set polish samples:

- [x] `petopia-golden-v4-yard-main`: `assets/art/samples/petopia-golden-v4-yard-main.png`
- [x] `petopia-golden-v4-cat-growth`: `assets/art/samples/petopia-golden-v4-cat-growth.png`
- [x] `petopia-golden-v4-visitor-sparrow`: `assets/art/samples/petopia-golden-v4-visitor-sparrow.png`
- [x] `petopia-golden-v4-postcard-lighthouse-bay`: `assets/art/samples/petopia-golden-v4-postcard-lighthouse-bay.png`
- [x] `petopia-golden-v4-ui-board`: `assets/art/samples/petopia-golden-v4-ui-board.png`
- [x] `petopia-golden-v4-contact-sheet`: `assets/art/samples/petopia-golden-v4-contact-sheet.png`
- [x] v4 polish standard doc: `docs/art-polish-v4-golden-set.md`

Batch I / v5 Golden Set polish samples:

- [x] `petopia-golden-v5-yard-main`: `assets/art/samples/petopia-golden-v5-yard-main.png`
- [x] `petopia-golden-v5-cat-growth-travel`: `assets/art/samples/petopia-golden-v5-cat-growth-travel.png`
- [x] `petopia-golden-v5-visitor-sparrow-natural`: `assets/art/samples/petopia-golden-v5-visitor-sparrow-natural.png`
- [x] `petopia-golden-v5-postcard-lighthouse-bay-v2`: `assets/art/samples/petopia-golden-v5-postcard-lighthouse-bay-v2.png`
- [x] `petopia-golden-v5-ui-board`: `assets/art/samples/petopia-golden-v5-ui-board.png`
- [x] `petopia-golden-v5-contact-sheet`: `assets/art/samples/petopia-golden-v5-contact-sheet.png`
- [x] v5 polish standard doc: `docs/art-polish-v5-golden-set.md`

Batch J / v5 production asset correction pass:

- [x] 全域奶油卡通调色与透明边缘清理：覆盖 `assets/art/pets/`、`assets/art/world/`、`assets/art/postcards/`、`assets/art/ui/` 下生产 PNG，排除 `samples/` 与 `qa/`。
- [x] 宠物 A/B/C 单体透明碎片清理，避免非旅装阶段出现误抠残片；抽检图：`assets/art/qa/v5_audit_pet_cat_after_strict.png`。
- [x] D 档旅装 attachment 独立交付：12 物种 × hat / scarf / bag / attachment_sheet，共 `48` 个 PNG，路径为 `assets/art/pets/<species>/attachments/`；抽检图：`assets/art/qa/v5_audit_travel_attachments.png`。
- [x] UI 徽章语义重修：成长等级 4 档（蛋壳 / 嫩芽 / 花朵 / 翅膀）与稀有度 4 档（常见 / 不常见 / 稀有 / 传说）拆分为两套资产。
- [x] UI 动作图标去重重修：喂食 / 摸头 / 玩具 / 洗澡 / 拍照以不同主体符号呈现，避免爪印泛用；抽检图：`assets/art/qa/v5_audit_ui_key_after.png`。
- [x] 院子 / 主题背景按 v5 full-bleed 标准复检，无烤入手账纸框；抽检图：`assets/art/qa/v5_audit_world_themes_after.png`。
- [x] 访客肖像按自然访客规则复检；抽检图：`assets/art/qa/v5_audit_visitors_portraits_after.png`。
- [x] 明信片地点背景 `40/40` 按 Golden Set 重绘到 1080×720，保持无文字、无内嵌边框、V2 在场构图方向；总抽检图：`assets/art/qa/v5_audit_postcard_backgrounds_v5_final.png`。
- [x] QA manifest 已刷新：`assets/art/qa/generated_asset_manifest.json`。

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
- W4 visitors 已生成 20 张 `400x400` 肖像和 20 张 `_yard` 横向 8 帧 sprite sheet；`_yard` 当前是首版微动/动作帧，后续精修批次可逐个强化特征动作。
- Pet domain 已生成形态 `240/240`、图鉴 `28`、通用动作模板 `96`、性格模板 `100`、彩蛋特效 `4`，并补齐 D 旅装独立 attachment `48`。动作资产当前为 stageC 主模板 + var01 别名。
- Postcard domain 已生成背景 `40/40`（v5 重绘版）、姿态 `96/96`、滤镜 `6/6`、贴纸 `61`、邮戳 `40/40`、特例 `20/20`、chrome `10/10`。
- UI domain 已生成 `178` 个 `ui_*.png` 主资产，其中等级徽章、稀有度徽章与核心动作图标已按 v5 规则重修。
- 当前 `assets/art` PNG 总数：`1338`（含 QA chroma 源、样张、sheet、单件、sprite sheet、travel attachment）。

## QA 备注

- `deco_pinwheel_paper` 当前第一版更像风车花环，后续精修批次建议补严格单个纸风车 v2。
- 访客 `_yard` 当前批次使用同一立绘生成 idle/action 微动帧；最终商店级动画建议后续逐个重绘关键帧。
- 宠物通用动作和性格动作当前为程序化微动首版模板；最终 Spine/DragonBones 骨骼拆层与逐物种关键帧仍需精修批次。
- 明信片背景 `40/40` 已完成 v5 逐张重绘，不再按占位/首版处理；后续仅需按具体剧情或地点设定做个别人工微调。
- 院子豪华度 delta 层当前由相邻完整层差分生成，适合作为首版递进素材；最终升级演出建议人工整理每阶新增结构。
- UI 当前为 @1x 主 PNG；@2x/@3x 批量导出可在终稿尺寸冻结后统一生成。
- v5 Golden Set 已生成并取代 v4 作为后续批量 polish 的统一质量标尺：院子主屏 full-bleed 无外框、成长 D 档带旅装、访客自然无统一配饰、明信片采用 V2 在场构图、UI 底图无可读文字。
- 本次 v5 生产修正未触碰代码、逻辑、Flutter/Flame、运行数据转换；仅改动 `assets/art/` 与美术规格/状态文档。
