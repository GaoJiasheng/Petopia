# 视觉审计 P2 修复工单（Codex）

> 来源：`docs/app-store/visual-audit-2026-09-02.md`（全量截图在 `~/Desktop/petopia-visual-audit-2026-09-02/`）。
> 基线：`main` @ `e81aa09`，版本 `1.0.1+41`（1.0 已上架）。
> 十张工单彼此独立，**每张一组 commit**，message 引用编号。全部不加新功能、不动数值。

## 铁律（每张工单都适用）

1. **不得触碰 `lib/config/game_config.dart`**，不得改任何经验/暖绒/概率/冷却数值；`SupportBenefits` 只允许 `bool`/`DateTime`。
2. 改了院子摆放/锚点，必跑并贴结果：
   ```bash
   flutter test integration_test/yard_home_visual_test.dart -d <udid> --dart-define=PETOPIA_VISUAL_PLACEMENTS=true
   ```
   横屏加 `--dart-define=PETOPIA_VISUAL_LANDSCAPE=true --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH=<px> --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT=<px>`（iPad 13：2752×2064；iPad mini：2266×1488）。**`flutter test` 下 `setPreferredOrientations` 不会转模拟器，不传 EXPECTED 尺寸截出来的仍是竖屏。**
3. 新增用户可见中文串必须同步 `lib/l10n/english_copy.dart`（繁中由 `TraditionalCopy` 自动转，无需手写）。
4. 新增/替换美术资源走 `tools/audit_runtime_art.py` 与 `tools/check_pet_art.py` 门禁，PASS 才交。
5. `flutter analyze` 0 issue、`flutter test` 全绿、`python3 tools/check_release_candidate.py` PASS。
6. 完成报告按工单编号逐条列：改了什么文件、跑了哪条验证命令、截图放哪。**不要**顺手改工单之外的东西。

---

## T0｜来客左车道与槽位 0 摆件重叠（P2，四台竖屏设备全部复现）

**现象**：玩家在槽位 0（左上，如犬舍/信箱）放了摆件时，走左车道的来客**站在摆件正前方、压住底座与花丛**。`PETOPIA_VISUAL_PLACEMENTS` 更新到"来客不挤占摆件"策略后，四台竖屏设备在 `meadow-visitor-left` 全部报 `slot 0 overlaps visitor`：
- iPhone 6.9"：visitor Rect(36.6, 434.1, 93.7, 494.8)；iPhone 17e：(32.6, 378.3, 87.1, 436.3)
- iPad mini 竖：(61.5, 487.3, 142.5, 573.4)；iPad 13 竖：(85.2, 581.0, 192.7, 695.2)
- 实图：`11-placements/iphone69-port/yard-meadow-visitor-left.png`

**根因**：`3a9d761` 把院子改成"摆件是固定物理位置，来客走自己的侧车道"（`yard_home_screen.dart` `_visibleDecor` 注释），但车道 `_visitorYardPlacement`（`yard_home_screen.dart:2680–2697`，如 calico/tanuki/owl/crow/snowhare = `Alignment(-0.50, 0.43)`，deer/fox/egret = `(-0.54, 0.38)`）与 `_compactDecorAnchors`/`_tabletPortraitDecorAnchors` 的槽位 0 在同一片区域，`PetopiaAdaptive.yardSideActorRect` 只避让宠物、不避让摆件。

**要求**：
- 来客车道要避开**已放置**的槽位 0/1（左/右上）摆件：优先把车道下移到槽位 2/3 与宠物之间的空带（视觉上来客站在摆件前方偏下，不压底座），其次才是水平内收；摆件本身**一像素都不能动**（这是 3a9d761 定下的原则）。
- 右车道同理避开槽位 1。回访者（`active_revisitor`）同规则。
- 修改后 `_hasSubstantialOverlap`（重叠面积 > 较小矩形 2.5%）在 6 组配置零违规。

**验收**：`PETOPIA_VISUAL_PLACEMENTS` 四台竖屏全绿（横屏另见 T1）；贴 `meadow-visitor-left` 与 `meadow-visitor-right` 的 iPhone 6.9" + iPad 13 竖屏截图。

---

## T1｜iPad 横屏满摆件右列重叠 + mini 横屏被动作栏盖住（P2）

**现象**（`_logs/11-placements-ipad13-land.log`、`11-placements-ipadmini-land.log` 有精确 Rect）：
- iPad 13 横（1376×1032）：`meadow-decor-only` 槽位 1/3 纵向重叠 37px、3/5 重叠 38px。
- iPad mini 横（1133×744）：0/2、1/3、3/5 两两重叠；槽位 4 底边超动作栏 8px、槽位 5 超 23px。

**根因**：`lib/ui/yard_home_screen.dart` `_wideDecorAnchors` 的右列（1/3/5）y 值按 1032pt 高度排布，744pt 高时挤不下；左列 0/2/4 同理但程度轻。

**要求**：
- 横屏锚点的纵向间距按画布高度缩放（或 mini 横屏走 6 槽），使 `PETOPIA_VISUAL_PLACEMENTS` 在 iPad 13 横、iPad mini 横两种尺寸**零违规**。
- 竖屏三档（iPhone 6.9"/17e、iPad mini 竖、iPad 13 竖）回归不得变红。
- 完成后把 `tools/check_release_candidate.py` 的 `--placements-device` 扩成也跑横屏（现在注释写明"portrait only until the iPad landscape anchors are re-tuned"）。

**验收**：6 组 placements 全绿；`_contact-sheets` 风格贴一张 iPad mini 横屏满摆件截图。

---

## T2｜豪华阶段在 iPhone / iPad 竖屏零可见反馈（P2，产品级）

**现象**：`luxuryStage`（毕业 1/3/5/8/12 次 → 阶段 2–6，`graduation_service_impl.dart:60`）在 iPhone 与 iPad 竖屏**没有任何可见表现**；只有 iPad 横屏且玩家一件摆件都没放时，`_wideLuxuryDecor[stage]` 才给 6 套专属摆件。

**根因**：`yard_home_screen.dart:3062` `_visibleDecor`：`slots.isEmpty && wideLayout` 才用豪华表，竖屏直接 `_defaultDecor`；`slots` 非空则任何布局都忽略。`yard.dart:130` 的 `deco_tree`/`deco_pond` 只进 `activeDecorIds`（成就/来客权重）从不渲染；`assets/art/world/decor/deco_tree_seasonal_{spring,summer,autumn,winter}.png` 与 `deco_pond_small.png` 已画好、零引用。

**要求（最小改法）**：
- 竖屏也按阶段显示豪华摆件：复用现成资源，阶段 ≥3 在**后排**（宠物后方两个槽位 6/7，`_compactDecorAnchors`/`_tabletPortraitDecorAnchors` 已有）挂四季树，≥4 挂小池塘；树按当前主题季节选 `_spring/_summer/_autumn/_winter`。
- 玩家已放置摆件时，豪华摆件**只占后排且优先级低于玩家摆件**（玩家放满 8 槽则豪华件让位），不得移动玩家摆放。
- 不改 `luxuryStageFor` 阈值，不改来客权重/成就条件。
- 更新 `yard_home_visual_test` 的 `luxuryScenarios` 期望，让 luxury-1..6 在 iPhone 上**逐张不同**。

**验收**：`PETOPIA_VISUAL_ALL_LUXURY=true` 在 iPhone 6.9" 与 iPad 13 竖屏各 6 张，接触表逐阶段可辨；placements 6 组仍绿。

---

## T3｜iPad 竖屏主题标志物被顶部裁掉（P2）

**现象**：iPad 13 竖屏 wheatkite 三只风筝只剩尾巴、starcamp 帐篷贴顶、moongreen 温室顶被切（`01-yard-themes/ipad13-port/`）。iPad mini 竖（0.66）只轻微。

**根因**：`YardArt.themeBg(wide: false)` 只在 `useYardSidePanels`（横屏）时用 4:3 wide 母图；竖屏 iPad 用手机 1290×2796 竖版母图 + `BoxFit.cover`，3:4 画布比 9:19.5 宽得多，按宽放大后上下各切一截。

**要求**：`width >= 600 && !landscape` 也走 `wide` 母图 + `BoxFit.cover`（4:3 铺 3:4 会按高放大、左右各裁约 22%，纵向构图完整；被裁的是麦田/树丛边缘）。夜间图同理。

**验收**：`PETOPIA_VISUAL_ALL_THEMES=true` 在 iPad 13 竖屏 12 张风筝/帐篷/温室顶完整；iPad 13 竖 + iPad mini 竖 placements 绿（地面带不得被特征元素侵占）；iPhone 12 主题像素级不变。

---

## T4｜iPad 横屏引导页猫悬空、文字压屋顶（P2）

**现象**：`08-ui/*/ipad13-land/ui-onboarding-{1,2,3}.png`、mini 横屏同：猫浮在天空中（脚下带投影），标题与「继续」压在屋顶/树冠。

**根因**：`lib/ui/onboarding_screen.dart` 竖版插画 cover 到 4:3 只剩天空段，猫按固定纵向比例锚定。

**要求**：横屏（`width > height`）用 `meadow` 的 wide 母图做背景（`YardArt.themeBg('meadow', wide: true)`），猫锚到地面带（参考 `PetopiaAdaptive.yardPetAlignment`），文案区落在草地上；竖屏不变。三页一致。

**验收**：`english_ui_visual_test` 三语 × iPad 13 横 + iPad mini 横（带 EXPECTED 尺寸）6 组，引导 3 页猫脚踩草地、文字不压建筑；竖屏 12 组像素级不变。

---

## T5｜iPhone 英文来客图鉴「First seen」日期截断丢年份（P2）

**现象**：所有 iPhone 两列布局：6.9" 显示 `First seen 7/21/20...`，17e 显示 `First seen 7/21...`。

**根因**：中文源串 `首次 2026.07.21`（`visitor_dex_screen.dart:361`）经 `english_copy.dart:369` 正则 `^首次 (\d{4})\.(\d{2})\.(\d{2})$` 展开为 `First seen M/d/yyyy`，chip `maxLines: 1` + ellipsis。

**要求**：英文改短——`Seen 7/21/26` 或 `First seen 7/21`（二选一，全 App 统一）；`visitor_dex_screen.dart:529` 详情页的「第一次见面」保持全年份。中文不动。

**验收**：`english_ui_visual_test` en × iPhone 17e（最窄）`ui-visitor-compendium.png` 无省略号；iPad 三档不变。

---

## T6｜来客肖像卡框不统一（P2，美术）

**现象**：20 个来客肖像里 **8 个没有卡片边框**（butterfly / deer / egret / emberlight / fox / rainbowshade / starbug / tanuki），另 12 个有；来客图鉴里两套风格并列（`00-assets-review/04-yard-visitors/asset-review/all-portraits.png`）。

**要求**：给 8 张补齐与其余 12 张一致的卡框（同尺寸、同描边、同底纹）；源文件进 `assets/art/source/`，运行时图走既有导出脚本；`tools/audit_runtime_art.py`「160 visitor frames match masters」不得变红。

**验收**：`build_full_art_review.py` 重出 `all-portraits.png`，20 张风格一致；`ui-visitor-compendium*.png` 三语 × iPhone/iPad 复查。

---

## T7｜parrot var04（玄凤）比其他变体小一圈（P2，美术）

**现象**：画框占比约 60%（其余 80%），院内实拍四阶段都缩水，iPad 上叠加后更明显（`_contact-sheets/03-pets-iphone69/parrot.png`、`03-pets-ipad13/parrot.png`）。

**要求**：重新裁切/缩放 `pet_parrot_var04_stage{A,B,C,D}` 及其 `actions/*` 序列帧，使主体长边占比与 var01–03/05 一致（美术规格 §0.2：78–82%），基线不变；过 `tools/check_pet_art.py` 帧稳定门禁。

**验收**：`PETOPIA_VISUAL_CATALOG=pets` 重截 parrot 20 张，五个变体同框肉眼同大；`check_pet_art.py` PASS。

---

## T8｜「旅行中的伙伴」页大面积空白（P2）

**现象**：iPhone 6.9" 只有一张头卡，其余约 75% 屏幕空白；iPad 同（`08-ui/*/*/ui-album-travel.png`）。

**要求**：头卡下方加空状态/引导区：一张现成明信片风格插画（可复用 `assets/runtime/postcards/backgrounds/` 任一张做 60% 透明底图）+ 一句话（中英），如「毕业的伙伴会从每一站寄回明信片，这里会慢慢填满」。**不加倒计时、不加催促语气**（零焦虑红线）。有 ≥2 位旅行伙伴时空状态自动隐藏。

**验收**：三语 × 6 配置 `ui-album-travel.png` 复查，无 overflow。

---

## T9｜支持卡片正文与价格按钮之间留白过大（P2）

**现象**：iPhone 单列下卡片高度被左列商品图撑起，两行描述下面空约 200pt 才到按钮；iPad mini 竖屏（744pt）最重（`ui-support*.png`）。

**根因**：`lib/ui/support_yard_screen.dart` 商品卡 Row 里图片列固定高度 + 右列 `Column` 用 `MainAxisAlignment.spaceBetween`（或等价）把按钮推到底。

**要求**：右列改为内容自然堆叠（标题 → 描述 → 按钮，间距 8–12pt），卡片高度取内容与图片高度的较大值，图片垂直居中于卡片；≥600pt 的双列布局不变。

**验收**：三语 × iPhone 6.9"/17e/iPad mini 竖 `ui-support*.png` 复查，无 overflow；`support_visual_test` drive 6 态正常。

---

## 提交顺序与门禁规则（已按 Codex 反馈修订）

**顺序：T0 → T5 → T9 → T8 → T3 → T4 → T1 → T2 → T6 → T7。**

T0 是唯一会让竖屏摆放回归变红的阻断者，且改动面小，所以放最前；它修完后，后面每张工单跑门禁都是真绿，不需要维护"已知失败"清单。

| 工单 | `check_release_candidate.py` | 摆放回归要求 |
|---|---|---|
| T5 / T9 / T8 / T4 / T6 / T7（不碰院子） | **不带** `--placements-device` | 无 |
| T0 / T3 / T2（碰院子竖屏） | **带** `--placements-device <udid>` | 四台竖屏全绿 |
| T1（横屏锚点） | 带 `--placements-device`，并把门禁扩成含横屏 | 4 竖 + 2 横全绿 |

唯一允许"记录已知失败"的情形：T3 完成时横屏两组仍因 T1 未修而红——报告里注明 `known: T1 pending` 即可，不阻塞提交。除此之外任何红门禁都不得提交。
