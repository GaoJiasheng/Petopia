# Petopia v5 Golden Set Polish Standard

> 范围：本文件只定义 v0.4 规格后的美术 Golden Set，不涉及代码、逻辑、Flutter/Flame 接入或数据转换。上位约束见 `docs/spec-art-overview.md` §1.0、§2.1、§2.3.1。

## Golden Set 文件

- `assets/art/samples/petopia-golden-v5-contact-sheet.png`：5 张控制样张合辑（无文字预览）。
- `assets/art/samples/petopia-golden-v5-yard-main.png`：主屏院子 full-bleed 质量标准，无手账外框。
- `assets/art/samples/petopia-golden-v5-cat-growth-travel.png`：宠物 A/B/C/D 成长标准，D 档明确旅装。
- `assets/art/samples/petopia-golden-v5-visitor-sparrow-natural.png`：自然访客肖像/院内立绘/微动帧质量标准。
- `assets/art/samples/petopia-golden-v5-postcard-lighthouse-bay-v2.png`：明信片 V2 构图标准，宠物背/侧对镜头看风景。
- `assets/art/samples/petopia-golden-v5-ui-board.png`：UI 纸质、胶带、徽章、图标和按钮质量标准，底图无文字。

## v5 相对 v4 的修正

- 院子主屏：移除撕纸边、胶带、贴纸边框、相角和白框；背景四周为可裁切的自然场景延展。
- 宠物成长：D 档必须带小背包、围巾、旅行帽等旅装信号；不得只是 C 档放大。
- 交付原则：样张可合成展示基调，生产资产必须拆层交付，背景、宠物、摆件、天气、UI 不得烤死。
- 描边规则：图鉴/相册/贴纸/UI 可带白色贴纸描边；场景里的宠物、访客、摆件默认不带白描边。
- 明信片：采用 V2「在场经历」构图，宠物背/侧对镜头看地点；卡片语境可保留齿边、相角、地点邮票图形。
- 访客：默认自然，不统一拟人配饰；棕/灰访客要用明快奶油色点亮。
- 文字：所有插画和 UI 底图不烤入可读文字、数字、Logo 或水印。

## 后续批量生成检查

- [ ] 院子/主题背景是否 full-bleed 且无内嵌边框。
- [ ] 可动/可交互对象是否计划为独立图层或文件。
- [ ] D 旅装是否有明确旅行配件并可独立开关。
- [ ] 场景中的宠物/访客是否避免白色贴纸描边。
- [ ] 明信片是否保留卡片语境，但不烤入文字。
- [ ] 访客是否自然、明快，不因棕灰色掉出奶油色系。
- [ ] 图像是否无可读文字、无水印、无错误额外动物。

## v5 生产修正落点

- 全域生产 PNG 已做奶油卡通调色、亮度/饱和度统一、透明边缘清理，范围覆盖 `assets/art/pets/`、`assets/art/world/`、`assets/art/postcards/`、`assets/art/ui/`。
- 院子/主题背景按 full-bleed 规则复检，背景层不烤入撕纸、胶带、贴纸框、相角或固定装饰边；抽检图：`assets/art/qa/v5_audit_world_themes_after.png`。
- 宠物 A/B/C 单体形态做严格碎片清理；D 档旅装保留并新增独立 attachment，抽检图：`assets/art/qa/v5_audit_pet_cat_after_strict.png`、`assets/art/qa/v5_audit_travel_attachments.png`。
- UI 徽章拆成成长等级 4 档与稀有度 4 档；喂食、摸头、玩具、洗澡、拍照图标去重，抽检图：`assets/art/qa/v5_audit_ui_key_after.png`。
- 访客保持自然外观，不统一加拟人配饰；肖像抽检图：`assets/art/qa/v5_audit_visitors_portraits_after.png`。
- 明信片地点背景 `40/40` 已重绘为 v5 质量线，统一 1080×720、无文字、无背景内嵌边框；总抽检图：`assets/art/qa/v5_audit_postcard_backgrounds_v5_final.png`。

## 生成方式记录

- 生成方式：built-in `image_gen`。
- 生成日期：2026-07-02。
- 本批先锁定 Golden Set 样张，再按该标准修正现有生产 PNG、补齐旅装 attachment、重绘明信片背景，并刷新 QA manifest：`assets/art/qa/generated_asset_manifest.json`。
