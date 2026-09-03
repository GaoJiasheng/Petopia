# 全量视觉审计报告（2026-09-02）

> 范围：**所有主题 × 所有宠物/变体/阶段 × 所有来客/回访 × 所有配饰摆放 × 所有界面 × 三语 × 四台设备六种配置**。
> 产物在 `~/Desktop/petopia-visual-audit-2026-09-02/`，按套件与设备分目录；`_contact-sheets/` 是拼好的接触表，`_logs/` 是每组 run 的原始输出。
> 复现：`tools/visual_audit_all.sh`（一条命令跑完整个矩阵）。
> 基线：1.0 (build 40) 已上架；本次截图基于工作区 `1.0.1+41`（含手账「小院的灯」入口）。

## 设备与布局类覆盖

| 配置 | 逻辑尺寸 | 布局类（`adaptive_layout.dart`） |
|---|---|---|
| iPhone 17 Pro Max 竖 | 440×956 | 紧凑（最大手机，商店截图机型） |
| iPhone 17e 竖 | 390×844 | 紧凑（最窄现售机型，文案换行压力最大） |
| iPad mini 竖 | 744×1133 | **中**（600–819，此前从未截过） |
| iPad mini 横 | 1133×744 | 宽 + 院子侧栏 |
| iPad Pro 13 竖 | 1032×1376 | 宽 |
| iPad Pro 13 横 | 1376×1032 | **超宽** + 院子侧栏 |

iPhone 仅支持竖屏（`Info.plist`），iPad 四向。

## 覆盖清单（实际产出）

| 套件 | 内容 | 张数 | 结果 |
|---|---|---|---|
| 00 资源审阅包 | 12 物种 × 5 变体 × 4 阶段 cutout、动作条、来客三视图、回访、40 明信片背景、8 姿势 | 336 | 已逐张审阅 |
| 01 院子主题 | 12 主题 × 6 配置 | 72 | 6/6 PASS |
| 02 院子状态 | 10 状态 × 6 配置 | 60 | 6/6 PASS |
| 03 宠物目录 | 12 × 5 × 4 = 240，× iPhone 6.9" + iPad 13 | 480 | 2/2 PASS |
| 04 来客 / 05 回访 | 20 + 60，× 2 设备 | 160 | 4/4 PASS |
| 06 豪华阶段 | 6 × (iPhone + iPad 横) | 12 | 2/2 PASS（但见 L1） |
| 07 动作抽样 | 12 物种 var01 stageC × 4 动作 | 48 | PASS |
| 08 界面 | 28–33 屏 × 3 语 × 6 配置 | 540 | **18/18 PASS，零 overflow** |
| 09 明信片 | 40 地点 × 2 设备 | 80 | 2/2 PASS |
| 10 支持页 | 6 态 × 2 设备（drive） | 12 | 2/2 PASS |
| 11 摆放回归 | 6 配置 | 4 | **0/6 PASS**（见 P1 / P2） |
| 12 本地化 | 3（drive） | 3 | PASS |
| **合计** | 50 组 run | **1869** | **44 PASS / 6 FAIL** |

产物 6.4 GB；`_contact-sheets/` 下 40+ 张接触表可快速通览。

---

## 🎯 优化点总表

| # | 级别 | 维度 | 问题 | 位置 / 证据 |
|---|---|---|---|---|
| A1 | P2 | 美术·来客 | **20 个来客肖像里 8 个没有卡片边框**（butterfly / deer / egret / emberlight / fox / rainbowshade / starbug / tanuki），另 12 个有；来客图鉴里两套风格并列 | `00-assets-review/04-yard-visitors/asset-review/all-portraits.png` |
| A2 | P2 | 美术·宠物 | **parrot var04（玄凤）在画框里明显比其他 4 个变体小一圈**（约 60% vs 80% 占比），**院内实拍确认缩水**，四个阶段都小；iPad 13 竖屏上叠加 I2 后更明显 | `02-pets.../contact-sheets/parrot.png`；`_contact-sheets/03-pets-iphone69/parrot.png` |
| A3 | ~~P2~~ 排除 | 美术·宠物 | starbug var03（粉星）在透明底审阅图上像透出棋盘格，**院内实拍在草地上完全正常**——只是粉色浅，不是 alpha 问题 | `_contact-sheets/03-pets-iphone69/starbug.png` |
| A4 | P3 | 美术·宠物 | **boo var04 stage A 是白色无瞳"发光眼"**，其余 19 张（含 var04 自己的 B/C/D）都是黑瞳 | `contact-sheets/boo.png` |
| A5 | P3 | 美术·宠物 | **四阶段"长大"可读性弱**：turtle（A/B/C 院内同大小，只有 D 靠背包区分）、chameleon（四张同姿势）、starbug（A/B/C 只差腿）、hamster/uni（B≈C）。对比 cat/shiba/rabbit/ember 的 A 趴→B 站→C 坐→D 装备 很清楚 | 各物种接触表 |
| A6 | P3 | 美术·明信片 | **`tide_flat` / `iceflow_lighthouse` / `fog_bridge` 三张背景整体偏白低对比**，浅色宠物（uni/boo/白兔/白仓鼠）叠上去容易"化掉"；**App 内实拍确认**这三张上宠物姿势只剩一个小色点 | `06-postcards/background-art-review/`；`09-postcards/iphone69/postcard-postcard-review-loc_tide_flat.png` |
| U1 | P2 | UI·相册 | **「旅行中的伙伴」页只有一张头卡，其余 75% 屏幕空白**（iPhone 6.9"），缺空状态插画或引导文案 | `08-ui/*/iphone69-port/ui-album-travel.png` |
| U2 | P2 | UI·支持页 | **支持卡片正文与价格按钮之间留白过大**：图在左列垂直居中，标题/描述贴顶、按钮贴底；卡片高度被左列图片撑起，中文两行描述下面空出约 200pt | `08-ui/{en,zh-Hans,zh-Hant}/iphone69-port/ui-support*.png` |
| U4 | **P1（已修并复验）** | UI·来客图鉴 | **iPad 竖屏（≥900pt）英文来客图鉴卡片底部溢出 18px**——英文名折两行（"Chestnut the Squirrel"）把「Read This Memory」顶出卡片，release 下会被裁掉。`c17c7ed` 只修了中文 25px，英文 0.78 仍不够。**已在本次修复**：`visitor_dex_screen.dart` 英文非放大字号比例 0.78→0.72 | `08-ui/en/ipad13-port/ui-visitor-compendium.png`（修复前截图，黄黑条纹可见）；`_logs/08-ui-en-ipad13-port.log` |
| U6 | P2 | UI·来客图鉴 | **iPhone 两列下英文「First seen 7/21/2026」chip 被省略号截断，年份丢失**（6.9" 截成 `7/21/20...`，17e 截成 `7/21...`）。chip `maxLines: 1` + ellipsis。中文源串是 `首次 2026.07.21`（`visitor_dex_screen.dart:361`），英文经 `english_copy.dart:369` 的正则 `^首次 (\d{4})\.(\d{2})\.(\d{2})$` 展开成 "First seen M/d/yyyy" 才超宽。建议英文改短（`Seen 7/21/26` 或 `First seen 7/21`）| `08-ui/en/iphone69-port/ui-visitor-compendium.png`、`08-ui/en/iphone61-port/...` |
| U5 | P3 | UI·设置 | **「轻柔触感」开关沿用了「互动音效」的喇叭图标**，三语一致；触感应换成震动/触感图标 | `ui-settings-top.png`（任意语言） |
| I1 | P2 | iPad·主题 | **iPad 竖屏主题标志物被顶部裁掉**：wheatkite 三只风筝只剩尾巴、starcamp 帐篷贴顶、moongreen 温室顶被切。根因：`YardArt.themeBg(wide: false)` 只在 `useYardSidePanels`（横屏）时用 4:3 wide 母图，竖屏 iPad 用的是手机 1290×2796 竖版母图 + `BoxFit.cover`，3:4 画布比 9:19.5 宽得多，按宽放大后上下各切掉一截。**iPad mini 竖屏（744×1133，宽高比 0.66）只轻微裁切，风筝/帐篷完整**——问题集中在 13"/11" 的 0.75 比例上 | `01-yard-themes/ipad13-port/yard-theme-wheatkite.png` vs `01-yard-themes/ipadmini-port/` vs `assets/art/world/themes/yard_theme_wheatkite_bg.webp` |
| V1 | P3（待验） | 美术·来客 | **四个近白色来客（egret / rainbowshade / ghostpuff / snowhare）在浅色主题上可见度存疑**——动画帧本身连贯，但画布占比小、近白；04-visitors 只在 meadow 截，需在 snowhut / moongreen 上补一张定级 | `00-assets-review/04-yard-visitors/asset-review/all-animation-frames.png` |
| I3 | P2 | iPad·引导页 | **iPad 横屏三页引导：猫悬浮在天空中（脚下带投影）、标题与「Continue」压在屋顶/树冠上**。竖版引导插画 cover 到 4:3 只剩天空段，猫按固定纵向比例锚定在草地位置以上。建议横屏用 `meadow` 的 wide 母图做背景 + 猫锚到地面带，或 `alignment: bottomCenter` 保草地 | `08-ui/en/ipad13-land/ui-onboarding-1.png`（2/3 同；iPad mini 横屏三语同样复现） |
| M1 | P3 | 中布局（600–819pt） | **iPad mini 竖屏商店 / 支持页仍走手机单列**：744pt 宽的主题卡一屏只放 3 张，支持页卡片图小、右侧大片空白（U2 在此档最重）。同档来客图鉴已正确切 3 列，商店/支持页可比照切双列 | `08-ui/en/ipadmini-port/ui-shop.png`、`ui-support.png` |
| V2 | P3 | 院子·来客 | **来客在院子里普遍偏小**：104pt 档（狐狸/鹿/白鹭）约屏宽 7.5%（宠物 20%）尚可辨认；**72pt 档（蝴蝶/萤火/篝火光/星星虫）与默认 78pt 档在缩略图里接近一个点**。来客到访是核心收集时刻，弹窗里很大、落到院子里存在感弱。尺寸在 `yard_home_screen.dart:2680–2697` `_visitorYardPlacement`，受 `adaptive_layout.dart:117` 车道宽约束，放大需连 `PETOPIA_VISUAL_PLACEMENTS` 回归一起调。**回访者**（毕业伙伴）尺寸与 104pt 档同级、可辨认，但站在右侧花坛旁时**左侧与石圈轻微重叠**，景深含糊 | `_contact-sheets/04-visitors-iphone69.png`；`04-visitors/iphone69/yard-visitor-fox.png`；`05-revisitors/iphone69/yard-revisitor-shiba-v1.png` |
| L1 | P2 | 玩法·豪华阶段 | **豪华阶段（`luxuryStage`，毕业 1/3/5/8/12 次 → 阶段 2–6，`graduation_service_impl.dart:60`）在 iPhone / iPad 竖屏没有任何可见表现**：6 张 luxury 截图完全相同。`yard_home_screen.dart:3062` `_visibleDecor` 只在 `wideLayout && slots.isEmpty` 时返回 `_wideLuxuryDecor[stage]`（iPad 横屏 6 套专属摆件：铃铛→蘑菇凳→路牌→树→池塘→长椅），竖屏分支直接 `_defaultDecor`；且任何布局只要玩家放过一件摆件就不再显示。`yard.dart:130` 的 `deco_tree` / `deco_pond` 只进 `activeDecorIds`（成就/来客权重），从不渲染；`assets/art/world/decor/deco_tree_seasonal_{spring,summer,autumn,winter}.png` 与 `deco_pond_small.png` 已画好但零引用。毕业是核心情感节点，其长期奖励目前对 iPhone 玩家不可见 | `_contact-sheets/06-luxury-iphone69.png`（6 张相同） vs `_contact-sheets/06-luxury-ipad13-land.png`（6 张各异） |
| P1 | P2 | 流程·门禁 | **摆放回归 oracle 自 8/24 起过期、且发布门禁不跑它**。`3a9d761`（Codex build 40 polish）把 App 改成"来客绝不移动/隐藏玩家摆件，临时角色走侧车道"（`yard_home_screen.dart:3089` 注释），但 `yard_home_visual_test.dart:1085` 的 `occupiedAnimalPoints` 仍按 8/15 的旧规则要求来客在场时槽位 {0,2}/{1,3} 让路、低优先级摆件溢出。结果 `PETOPIA_VISUAL_PLACEMENTS` 在三台竖屏设备上都在 `meadow-visitor-left` 挂掉（`album_shelf` 被渲染而 oracle 期望溢出）。`check_release_candidate.py` 未包含该门禁，所以 build 40 带着红门禁上架。**修法：更新 oracle 到新策略（来客不占槽位），并把 PLACEMENTS（竖屏 + `EXPECTED_WIDTH/HEIGHT` 横屏）加进发布门禁** | `_logs/11-placements-{iphone69,iphone61,ipadmini,ipad13}-port.log` |
| P2 | P2 | iPad 横屏·摆放 | **iPad 横屏满摆件时右列 1/3/5 三件两两重叠，mini 横屏槽位 4/5 还被动作栏盖住**——首次真横屏验证暴露的真几何问题。iPad 13 横（1376×1032）：slots 1/3 纵向重叠 37px、3/5 重叠 38px；iPad mini 横（1133×744）：0/2、1/3、3/5 重叠，slot 4 底边超动作栏 8px、slot 5 超 23px。`_wideDecorAnchors` 的右列 y 值按 1032pt 高排的，744pt 高时挤不下。**修法：右列 1/3/5 在横屏按画布高度缩放 y 间距，或 mini 横屏降到 6 槽** | `_logs/11-placements-ipad13-land.log`、`_logs/11-placements-ipadmini-land.log`（含精确 Rect） |
| I2 | P3 | iPad·院子 | **iPad 13 竖屏宠物占比偏小**（约 14% 画布宽，iPhone 约 30%），配饰按同比例放大后宠物显得"被淹"。25% 缩小是按 iPhone 调的，iPad 竖屏可单独给一档 | `_contact-sheets/01-themes-ipad13-port.png` |
| U3 | 已验证 | UI·手账 | 1.0.1 新增的「小院的灯 / 支持小院」入口：**iPad 侧栏 + iPhone 底部弹层两种形态均已验证**（真机全新存档、滚到底可见，网格下方，礼物图标 + 副标题 + 箭头） | `02-yard-states/ipad13-port/yard-notebook.png`；`13-real-app/iphone69-notebook-bottom-support-entry.png` |
| U7 | P3 | UI·手账 | 「支持小院」入口卡用的 `ui_icon_gift`（扁平蓝盒粉结）与上方 8 个 `home_*` 水彩菜单图标不是一个家族，并排看略显生硬。建议补一张 `ui_icon_home_support.png` 同族水彩图标 | `13-real-app/iphone69-notebook-bottom-support-entry.png` |
| D1 | 建议 | 设计·主题 | **犬舍/花坛在 12 个主题里是同一张图**：雪屋主题的木犬舍不带雪、温室瓷砖上摆木犬舍。可作 v1.x「主题化默认摆件」候选 | `_contact-sheets/01-themes-iphone69-port.png` |


### I1 修复建议

短期（不加资源）：iPad 竖屏（`width >= 600 && !landscape`）也走 `wide` 母图 + `BoxFit.cover`。4:3 母图铺到 3:4 画布会按高放大、左右各裁约 22%，但**上下构图完整**——风筝、帐篷、温室顶都保得住；左右被裁的是麦田/树丛边缘，无特征元素。需跑一遍 `PETOPIA_VISUAL_PLACEMENTS` 确认地面带仍满足摆放约束。

长期：为 iPad 竖屏单独出 3:4 母图（12 张），构图规则同 `docs/prompt-codex-theme-revamp.md`「特征在上 1/3、中下 55% 留地面」。

（iPad 横屏 / iPad mini / iPhone 17e 部分待矩阵跑完追加）

---

## 已核验无问题

- **PNG/WebP 双份打包 —— 排除**。`pubspec.yaml` 只列 `.webp`；`Runner.app` 的 `assets/runtime` 下 0 个 PNG、455 个 WebP。审阅包把源 PNG 一起收进来是工具行为。仓库里 51 MB 的 runtime PNG 只影响 LFS，不影响包体。
- `audit_runtime_art.py`：469 cutout / 945 帧 / 19 图标 PASS；160 来客帧与母版一致；2 处配饰 footer 守卫通过。
- 12 主题在 iPhone 6.9" 上：宠物站位、食盆、犬舍锚点一致，地面带均未被特征元素侵占。
- 10 个院子状态（iPhone）：冷却计时、来客、到访弹窗、特殊事件、毕业围巾、空院领养卡、教程提示——全部正常。
- 28 屏界面 en / zh-Hans（iPhone 6.9"）：日志零 overflow / exception；两语布局逐屏对齐；`_expectNoVisibleHanText` 英文模式通过。
- 猫动作条 8 动作 × 8 帧：帧间基线稳定，无残片。
- 12 物种 × 5 变体 × 4 阶段 240 张 cutout：除 A2–A5 外风格、描边、上色一致。
- 40 张明信片背景：除 A6 外品质一致。
- 回访（毕业）姿态 5 变体：围巾/挎包细节一致。
- 宠物目录院内实拍 240 张（iPhone 6.9"，meadow）：站位/食盆锚点全部一致，日志零异常；除 A2 外无尺寸离群。
- 宠物目录院内实拍 240 张（iPad 13 竖屏）：同上，零异常；接触表在 `_contact-sheets/03-pets-ipad13/`。
- 来客院内实拍 20 张（iPhone 6.9"，meadow）：站位不与宠物/摆件重叠，左右车道分配正确；除 V2 尺寸外无问题。
- 回访院内实拍 60 张（12 物种 × 5 变体）：围巾/背包毕业装全部正确加载，日志零异常。
- 来客院内实拍 20 张（iPad 13 竖屏）：站位/车道正确，零异常；V2 尺寸问题在 iPad 上同样成立（萤火/星星虫几乎不可见）。
- 回访院内实拍 60 张（iPad 13 竖屏）：零异常，接触表 `_contact-sheets/05-revisitors-ipad13.png`。
- 明信片 App 内实拍 40 张（iPad 13 竖屏）：零异常，接触表 `_contact-sheets/09-postcards-ipad13.png`。
- 明信片 App 内实拍 40 张（全地点 × 全天气，iPhone 6.9"）：卡片版式、正文、日期、按钮一致，日志零异常。
- 支持页 drive 截图 6 张：商品目录、守护者「今天的暖灯」未点/已点两态、守护者来信、礼物送达「拆开一份」、开礼弹窗——S1/S2 全部状态渲染正确。
- 支持页 drive 截图 6 张（iPad 13）：同上，`_contact-sheets/10-support-ipad13.png`。
- 本地化 drive 截图 3 张：设置/商店/来客图鉴英文态正常。商店里风铃显示为扁平占位图是该测试 fixture 传了不存在的 `artRef: ui_shop_wind_chime` 落到分类回落图标；`08-ui` 的商店分类页确认真实路径渲染的是水彩风铃，不是 App 问题。
- 顺带勘误：给 App Review 的 2.1(b) 回复里写的是"journal button in the upper-left corner"，实际手账按钮在顶部 HUD 胶囊的**右端**；审核已通过，`review-reply-2.1b.md` 已更正备注。
- 33 屏界面 zh-Hans / zh-Hant（iPad 13 竖屏）：零 overflow；商店侧栏 + 5 分类页、支持页双列、设置/手账居中定宽列均正常。接触表上看似"内容左贴"的页面放大后确认是居中列 + 测试数据稀疏，不是布局缺陷。
- 10 个院子状态（iPad 13 竖屏）：正常。
- iPad 13 **横屏**（真横屏，`setSurfaceSize` 2752×2064）：12 主题 wide 母图特征完整、地面带充足；10 个院子状态正常；33 屏英文界面零 overflow，商店侧栏 + 双列、支持页 2×2、设置/手账居中列均正常（除 I3）。
- iPad mini 竖屏（744pt，中布局类，首次覆盖）：12 主题裁切轻微、10 状态正常、28 屏英文零 overflow；来客图鉴 3 列正确。
- **界面套件总计 18 组（en / zh-Hans / zh-Hant × 六种配置）全部 PASS、日志零 RenderFlex overflow**（`08-ui-en-ipad13-port` 为 U4 修复后重跑结果）。iPhone 17e（390pt，最窄）三语 28 屏无换行/截断异常（U6 除外）。
- iPad mini 横屏、iPhone 17e：12 主题与 10 状态均正常。

## 待办

- [x] U3（iPad）：`02-yard-states/ipad13-port/yard-notebook.png` 已确认
- [x] U3（iPhone）：真机 `13-real-app/iphone69-notebook-bottom-support-entry.png` 已确认
- [ ] P1：更新摆放 oracle 后重跑 6 组 `11-placements-*`，补齐全配饰 × 全主题截图（本次仅各得 0–1 张）
- [ ] P1 补一张 `meadow-visitor-left` 满摆件 + 来客同框截图，确认新策略下无视觉重叠
- [x] iPad mini 横屏商店 5 张分类页：harness 宽度门已修，en / zh-Hans 用 `PETOPIA_VISUAL_SHOP_ONLY=true` 补截完成（各 33 张）
- [x] U4：`08-ui-en-ipad13-port` 修复后重跑 33 屏全过、日志零 overflow；`ui-visitor-compendium.png` 已替换为修复后截图
- [ ] 本次截图基线说明：`08-ui-en-ipad13-port` 之前的 run 是修复前代码，`01-themes-ipad13-land` 起为修复后

---

## 🧪 本次对截图 harness 的修正（已在工作区）

1. **横屏从来没截对过**：`flutter test` 下 `SystemChrome.setPreferredOrientations` 不会旋转模拟器，此前所有 `PETOPIA_VISUAL_LANDSCAPE=true` 产物都是竖屏。`yard_home_visual_test` 已有 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT` → `setSurfaceSize`；本次给 `english_ui_visual_test` 补了同名开关。**横屏必须同时传 `EXPECTED_WIDTH/HEIGHT`（物理像素）**，`tools/visual_audit_all.sh` 已内置。
2. `english_ui_visual_test` 商店分类页的"宽屏才截"门用的是 `tester.view.physicalSize`，`setSurfaceSize` 不改它；已改为优先读 `_expectedScreenshotWidth`。
3. `build_ui_audit_contact_sheet.py` 的 `output` 参数是**文件名**（含 `.png`），不是目录。
4. 跑过 integration_test 的模拟器上，装出来的 App 是测试宿主。做真机 QA 前先 `rm -rf .dart_tool/flutter_build` 重建并卸载重装（见 `polish-review-findings.md` §QA 环境教训）。

## 复现

```bash
# 全矩阵（约 2 小时，四台模拟器需先 boot）
./tools/visual_audit_all.sh
# 单组示例：iPad 13 真横屏英文界面
flutter test integration_test/english_ui_visual_test.dart -d <udid> \
  --dart-define=PETOPIA_CAPTURE_DIR=/tmp/x --dart-define=PETOPIA_VISUAL_LANGUAGE=en \
  --dart-define=PETOPIA_VISUAL_LANDSCAPE=true \
  --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH=2752 --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT=2064
```

