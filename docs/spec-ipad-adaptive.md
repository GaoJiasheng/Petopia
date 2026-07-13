# Petopia iPad 自适应规格 · v0.1

> 配套 `DESIGN.md`、`spec-ux.md`、`spec-devices.md`、`spec-art-overview.md`。本文件把 iPad 支持从「放大手机 UI」升级为「真正 adaptive app」。目标是兼容 iPad 全屏、横竖屏、Split View、Stage Manager 可变窗口，同时保持 Petopia 的奶油水彩、满幅无黑边、零焦虑体验。

---

## 1. 产品原则

- **手机体验不被牺牲**：Compact 宽度继续沿用现有竖向院子体验。
- **iPad 不是大号手机**：宽屏下使用多栏布局与最大宽度约束，避免按钮、卡片、文字被无意义拉宽。
- **院子仍是情绪中心**：无论横竖屏，院子舞台永远优先占据视觉中心；状态、来客、明信片、照料动作围绕舞台组织。
- **全尺寸可重排**：支持 iPad 全屏、Split View、小窗、Stage Manager resize。窗口尺寸变化只触发布局重排，不丢失当前页面/弹框/滚动状态。
- **满幅无黑边**：背景和插画按 cover/overscan 处理；UI 进入 safe area；宠物、访客、图标保持等比，不拉伸。

---

## 2. 断点

断点以 Flutter 逻辑宽度 `MediaQuery.size.width` 为准。

| 档位 | 宽度 | 主要场景 | 布局策略 |
|---|---:|---|---|
| Compact | `< 600` | iPhone、iPad 窄小窗 | 现有手机布局；底部动作栏；网格 2 列 |
| Medium | `600–839` | iPad mini 竖屏、Split View | 单列内容居中；卡片最大宽度封顶；网格 3 列 |
| Expanded | `840–1199` | iPad 竖屏、较宽小窗 | 左侧轻导航/状态 + 中央内容；网格 4 列 |
| Wide | `>= 1200` | iPad 横屏、大窗、Stage Manager | 三栏：左状态/导航，中院子舞台，右今日事件；网格 5 列 |

通用尺寸函数：

- `sideMargin = clamp(width * 0.045, 16, 40)`
- `contentMaxWidth = 1040`，正文/表单/普通列表不超过此宽度。
- `dialogMaxWidth = 720`，小弹框不超过此宽度。
- `postcardMaxWidth = clamp(width * 0.72, 560, 860)`，明信片更突出图片，但不铺满整屏。
- `petStageWidth = clamp(shortestSide * 0.34, 220, 340)`，宠物不随 iPad 无限放大。

---

## 3. 院子主屏

### 3.1 Compact / Medium

- 维持竖向堆叠：顶部状态卡、中央院子、底部动作条。
- 背景 `BoxFit.cover` 满幅。
- 动作条固定在 safe area 底部；冷却态仍显示灰化图标 + 倒计时。

### 3.2 Expanded / Wide

宽屏改成三层关系：

- **背景层**：继续 full-bleed cover。若后续补齐横屏美术，优先使用 `yard_theme_*_wide_bg`；缺失时使用竖屏背景 cover 兜底。
- **院子舞台层**：宠物、访客、摆件集中在画面中央 60% 区域，宠物尺寸用 `petStageWidth`。
- **UI 面板层**：
  - 左侧：宠物名牌、等级、经验、暖绒余额、主导航入口。
  - 右侧：今日来客、未读明信片、旅行动态、照料动作。
  - 若宽度不足 Wide，右侧动作面板回落到底部，左侧状态保持顶部。

宽屏 UI 面板使用半透明暖白卡，最大宽度约 320；不遮挡宠物主视觉。

---

## 4. 明信片

- 收信弹框背景保持模糊或纯暖色遮罩，避免院子背景与明信片互相抢。
- Compact：上下布局，图片约 52–58% 卡片高度。
- Medium+：图片优先，卡片最大宽度提升到 720–860；正文缩小并限制行高，图片区域约占 62–70%。
- Wide 横屏：允许左图右文或大图上置，原则是图片比文字更重要。
- 文字永远由 UI 渲染，不烤进图。

---

## 5. 相册 / 图鉴 / 商店

### 5.1 相册

- 明信片网格：Compact 2 列、Medium 3 列、Expanded 4 列、Wide 5 列。
- 网格内容居中并限制最大宽度，宽屏不贴边。
- 旅行伙伴：Compact 为单列列表；Expanded+ 改为 2 列伙伴卡。头像使用毕业旅装正面图。

### 5.2 图鉴

- 宠物图鉴和来客图鉴沿用现有响应式列数，但要统一使用断点 helper。
- 宽屏详情可做 side sheet，避免全屏打断。

### 5.3 商店

- Compact 单列分类。
- Expanded+ 左侧分类栏 + 右侧商品网格。

---

## 6. iPad 平台配置

- iPad 支持 `portrait`、`portraitUpsideDown`、`landscapeLeft`、`landscapeRight`。
- iPhone 可继续 portrait-first；是否开放横屏由 `Info.plist` 和 Flutter orientation policy 统一决定。
- 不使用 `UIRequiresFullScreen` 逃避 iPad 多任务；正式目标是 Split View / Stage Manager 可 resize。
- 所有弹框、列表、网格必须响应窗口 resize，不依赖固定设备型号。

---

## 7. 验收矩阵

必须截图验证：

- iPhone 15/16 Pro Max portrait。
- iPad mini portrait / landscape。
- iPad 11-inch portrait / landscape。
- iPad 13-inch landscape。
- iPad Split View 1/2、1/3。
- Stage Manager 小窗、中窗、大窗。

每张截图检查：

- 四边无黑边。
- 背景不变形，宠物不变胖/变瘦。
- 顶栏、底栏、动作按钮避开 safe area。
- 文字无溢出，卡片不无限拉宽。
- 明信片弹框图片优先，背景不干扰阅读。

