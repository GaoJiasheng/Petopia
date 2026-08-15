# 上架前六维打磨 Review 报告

> 状态：**六个维度全部完成**（美术已由 Codex 闭环；UI 交互 / 音频 / 渲染性能 / 玩法数据 / 文案见下文 §二~六）。
> 原则：功能冻结，只修 bug 和打磨，不加新功能。
> 每条 finding 含：位置、问题、失败场景、修法。分级：**P1** = 用户可见错误/数据损坏/卡死/英文界面漏中文，提审前必修；**P2** = 强烈建议上车；**P3** = 可不修、备案。

## 🎯 P1 必修总表（Codex 按此排工单）

| # | 维度 | 一句话 | 详情 |
|---|---|---|---|
| U1 | UI | 毕业双击竞态 → 重复结算 | §二 U1 |
| U2-U4 | UI | 毕业/首启引导/领养失败即永久卡死（无 try/finally） | §二 U2-U4 |
| U10 | UI | IAP 支持页卡片大字号溢出黄黑条（审核高危页） | §二 U10 |
| S1 | 音频 | 关音乐+开音效时返回院子环境声永久静默 | §三 S1 |
| R1 | 渲染 | 序列帧 ImageInfo 从不 dispose，约 8.4MiB/张滞留 | §四 R1 |
| R2 | 渲染 | 主宠物呼吸动画缺 RepaintBoundary，全屏 60fps 重绘 | §四 R2 |
| D1 | 数据 | 两个隐藏成就（尼可/噗噗）名字匹配失败永不可达 | §五 D1 |
| C1 | 文案 | 乱码级错别字「径盶」（应为「径直」） | §六 C1 |
| C2-C4 | 文案 | 英文界面 3 处漏中文/错翻（"Use: Petopia"、暖绒不足、松鼠/蝴蝶/乌鸦名颠倒） | §六 C2-C4 |
| C5 | 文案 | 明信片模板 ~35 条会拼出病句（整句塞名词槽 + 人称错配） | §六 C5 |

---

## ⚠️ 已在工作区落地、未提交的修复（Codex 先看这里）

以下 3 个 P1 修复已由 Claude 直接改在工作区（与既有未提交批次混在一起，**均未 commit**）。
Codex 任务：**复核这些 diff 是否正确，然后随本轮修复一起提交**；不要重复实现，也不要回退。

| 文件 | 改动 |
|---|---|
| `pubspec.yaml` | +21 行：20 张 `visitor_*_yard_base.png` + `ui_frame_offline_card.png` 注册 |
| `lib/app/game_controller.dart` | `_visitorArtAsset` 提为顶层公共函数 `visitorArtAsset()`（含隐藏访客 id→slug 映射），原方法委托之 |
| `lib/ui/visitor_dex_screen.dart` | 3 处 raw `entry.id` 拼路径改为调用 `visitorArtAsset()`（496/619/791 行附近） |
| `assets/art/world/visitors/*_yard_base.png`（7 张） | crow/egret/fox/owl/pigeon/squirrel/tanuki 下方切帧残留碎片已抹除（连通域清理，主体无损；奇幻访客 firefly/emberlight/ghostpuff/rainbowshade 的光点为有意构图，未动） |
| `assets/provenance/release_asset_manifest.json` | 已按当前工作区重烘并 `--check` 通过 |

验证状态：`flutter analyze lib/` 0 issue；`flutter test` 258 全过；`build_release_asset_manifest.py --check` 通过。

---

## 一、美术维度（已完成审查）

### P1（不修 release 就出错）—— 已修复，见上表

**A1. 访客图鉴 `_yard_base.png` 全系列未注册 pubspec → release 包缺图**
- 引用：`lib/ui/visitor_dex_screen.dart:496,619` 拼 `assets/art/world/visitors/${entry.id}_yard_base.png`
- 磁盘 20 张全在，但 pubspec 只注册了 `_yard.png`/`_portrait.png` → 正式包里 20 个访客的图鉴详情图全部降级为色块占位（有 errorBuilder 不会崩溃，但 debug 环境看不出来）。

**A2. 隐藏访客 id ≠ 文件 slug，dex 屏绕过映射（与历史 chameleon 白屏同型）**
- 数据 id `visitor_campfire_light`/`visitor_rainbow_shade`/`visitor_night_blob` 对应文件 slug `visitor_emberlight`/`visitor_rainbowshade`/`visitor_ghostpuff`。
- `game_controller.dart` 有私有映射 `_visitorArtAsset`，但 `visitor_dex_screen.dart` 三处（含 791 行 portrait）用 raw id 拼路径 → 这 3 个访客即使注册了资产也永远命不中。
- **教训固化建议（Codex 可做）**：在 `tools/check_release_candidate.py` 或独立 check 中加"代码字面资产路径 ∈ pubspec 注册集"与"访客 id→slug 映射覆盖核验"，防止再犯。

**A3. `assets/art/ui/ui_frame_offline_card.png` 未注册**
- 引用：`lib/ui/yard_home_screen.dart` 离线收益卡 `DecorationImage`（无失败回调，release 静默丢底框）。
- 全库字面资产路径 vs pubspec 对账已做：**仅此 1 处遗漏**（插值路径已按 12 物种×动作×阶段×变体全展开核对，无缺）。

**A4. release asset manifest 过期**
- `build_release_asset_manifest.py --check` 报 stale（工作区美术改动后未重烘），旧 manifest 还残留已删除的 `yard_fx_dusk/night.webp` 条目。已重烘。

### P2（建议处理）

**A5. 写实动物 `_yard_base` 抠图残留** —— 已修复（见上表第 4 行）。

**A6. 动作枚举与设计口径不一致（仅需确认，无缺文件）**
- 设计文档说 8 动作（idle/eat/pat/play/bath/sit/sleep/walk），代码 `pet_art.dart` 与资产实际只有 eat/pat/play/bath 4 种，闭环一致、无运行期风险。冻结期不动，仅确认这是有意裁剪，建议在 DESIGN.md 里加一句说明避免后人疑惑。

### P3（可不修）

**A7.** `pet_snake_dex_color.png` 底部阴影带品红 fringe；`pet_boo_var01_stageC.webp` 轮廓有极淡绿 halo。整体风格统一、无明显压缩伪影，优先级极低。

**A8.** `ios/Runner/Assets.xcassets/LaunchImage.imageset/` 残留 3 个 68 字节占位 PNG 且 Contents.json images 为空（实际启动屏用 LaunchMark）。纯冗余可删，不影响任何功能。

### Codex 二次闭环（2026-08-02）

- **A1/A2/A3/A4**：复核既有修复正确；新增发布门禁，逐项校验 Dart 代码中的具体资产字面量必须存在且被 `pubspec.yaml` 打包，并校验 20 个访客的 `id → slug → portrait/yard/yard_base` 三类资源全部闭环。隐藏访客映射另有单元测试覆盖。
- **A5**：复核时发现 7 张写实访客底图仍残留主体下方的极低透明弧线；已在不触碰主体的前提下清除，并增加“主体下方不得残留分离低透明像素”的门禁。
- **A6**：已在 `docs/DESIGN.md` 固化口径：源美术规格保留 8 个通用动作，当前功能冻结的上架运行时有意仅打包 `eat/pat/play/bath` 4 个可触发互动动作。
- **A7**：蛇图鉴底部品红阴影已校正为暖棕柔影；Boo 立绘及运行时源图的绿色 halo 已做邻近色去污染，运行时 WebP 重新无损烘焙。两项均加入像素阈值防回归。
- **A8**：已删除未引用的整个 `LaunchImage.imageset`，实际启动屏 `LaunchMark` 保持不变。
- **验证**：`flutter analyze` 0 issue；`flutter test` 260 passed / 3 skipped；源美术、运行时栅格、明信片内容、release manifest 全绿；无签名 iOS Release 构建成功，实际包体预算门禁通过。

### 已核验通过项（Codex 不用再查）

- 运行期路径全展开核对（12 物种 × var01-05 × A-D 立绘 240 张、4 动作序列帧、dex 三态+4 mystery、portraits、12 主题 × 日/夜 × 竖/wide 48 张、40 明信片背景与 locations 对齐、邮票/贴纸/姿势、decor↔shop 映射）全部闭合。
- `tools/check_pet_art.py` 全过；AppIcon 20 尺寸齐全、1024 无 alpha；启动屏底色 `#FAF3E3` 与主题一致；已注册资产无孤儿。

---

## 二、UI 交互维度

### P1

**U1. 毕业操作缺重入保护，双击可触发两次 graduate（数据竞态）**
- `lib/ui/graduation_ceremony_screen.dart:48-59` `_sendOff` 开头无 `if (_sending) return;`。setState 重建前的快速双击/双指点按会连续进入两次；`game_services.dart:429 graduateCurrent` 的守卫在 `await graduate()` 之后才置空 current，两次调用交错通过 → 重复结算暖绒 / roaming 列表重复添加。
- 修法：首行加 `if (_sending) return;`（对照 `adopt_screen.dart:44` 的既有写法）。

**U2. 毕业失败 → 用户永久卡 loading**
- 同文件同函数：`graduate()` 无 try/catch。落盘异常时 `_sending` 永为 true，按钮禁用且"再陪它一会儿"返回按钮被 `if (!_sending)` 隐藏、无 AppBar，只能杀进程。
- 修法：try/finally 恢复 `_sending`，失败给温柔 SnackBar。

**U3. 首启引导完成失败 → 彻底卡死首启流程（审核高危）**
- `lib/ui/onboarding_screen.dart:62-74` `_finish`：`completeOnboarding()` 抛异常时 `_finishing` 永为 true，继续/跳过全禁用，整屏 `PopScope(canPop:false)` 无退路。
- 修法：try/finally 重置 `_finishing`。

**U4. 领养失败静默卡住按钮**
- `lib/ui/adopt_screen.dart:42-49` `_confirm`：异常时 `_adopting` 停留 true，按钮永远"正在迎接…"；成功/失败均无提示。修法：try/finally + 失败 SnackBar。

**U10. IAP 支持页商品卡在系统大字号下 RenderFlex overflow（黄黑条）**
- `lib/ui/support_yard_screen.dart:156`（`mainAxisExtent: 224` 写死）、`:313-314`。大字号（英文尤甚）下 Spacer 压到 0 仍溢出。这是 IAP 页面，审核可能开大字号查看。
- 修法：按 `textScaler` 放大 extent（参照 `visitor_dex_screen.dart:148` 的 `largeText ? 560 : null` 做法）；顺带给 `:342-349` 标题补 `overflow: TextOverflow.ellipsis`（U11）。

### P2

**U5. 院中来客/回访精灵双击叠开两层 dialog**：`yard_home_screen.dart:563-570`（visitor onTap）、`:634-637`（revisitor）、`:3174`（`_HomeMenuButton` 可叠两个手账面板）——均未走 `_momentOpen` 守卫。修法：复用 `_momentOpen` 或本地 bool 防重。
**U6. 导入存档成功提示永远看不到**：`settings_screen.dart:354-359` 先 setState 状态条随即 pop，用户无确认。修法：pop 前挂 root ScaffoldMessenger SnackBar。
**U7. 照料反馈 `clearSnackBars()` 误杀成就 toast**：`yard_home_screen.dart:66-67` vs `:670-704`——成就 toast 展示 3 秒内继续照料会被清掉，且 cue 已出队（`:812`），提示永久丢失。修法：改 `hideCurrentSnackBar()` 或成就 toast 换独立 Overlay。
**U8. 事件对话框 Android 返回键被吞**：`yard_home_screen.dart:1739-1741` `canPop:false + barrierDismissible:false`，未选择前无任何退出。建议返回键按"未选择"关闭（`resolveEvent(choiceIndex: null)` 已有兼容路径）。
**U9. `launchUrl` 异常未捕获**：`settings_screen.dart:285-290`、`privacy_screen.dart:106-115`——部分平台抛 PlatformException 而非返回 false。修法：try/catch 落到已有"暂时无法打开网页"提示。
**U12. 商店分区标题 Row 无弹性约束**：`shop_screen.dart:528-556` title 未包 Flexible，英文长分类名+大字号整行溢出。

### P3（备案）

- `visitor_dex_screen.dart:470-477` 面板标题超长名无 maxLines；`:556-563` memories 空列表无占位。
- `album_screen.dart:34-37`、`postcard_viewer_screen.dart:35-40` initState microtask 用 ref 无 mounted 防护（极低概率 "ref used after dispose"）。
- `settings_screen.dart:145-153` 通知开关无防抖；多点触控双 push 通用风险（最值得防的是毕业横幅 `yard_home_screen.dart:1427`）。

### 已核验无问题（Codex 不用再查）
照料四键冷却先落盘、商店购买 `_buyingId` 全局互斥、IAP busy/restoring 双标志 + `_lastDeliverySequence` 防重、全屏 `async.when` + 重试、空状态覆盖（含筛选无结果）、Timer/controller/listener 全配对 dispose、`HomeMomentPolicy` 自动弹窗串行互斥、Semantics 与 48pt 触达覆盖度高。

---

## 三、音频维度

### P1

**S1. 关音乐+开音效组合下，返回院子后环境声永久静默**
- `lib/audio/audio_service.dart:193`（playBgm 在 `!_musicEnabled` 提前 return）与 `:249`（playYardAmbience 因"曲目相同"提前 return）互相踢皮球，没人 resume 被 `:188` pause 掉的 ambience。触发：设置关音乐开音效 → 进商店返回 → 鸟鸣/雨声消失直到换曲目。
- 修法：`playYardAmbience` 幂等早退需确认播放器实际在播；或 `!_musicEnabled` 分支里 yard context 时也执行 `_resumeOrLoadAmbience`。

### P2

**S2. 16:00 日→黄昏切换缺定时边界**：`yard_home_screen.dart:196-214` 刷新 Timer 只排 06:00/18:00，但 dusk 判定是 `hour>=16`（`:141,389-392`）——挂机跨 16:00 不切曲。修法：边界加 16:00。
**S3. 商店购买成功无音效/触感**：`shop_screen.dart:76-100`、`game_controller.dart:919-927`——关键交互静默；已打包的 `Sfx.tapSoft`（ui_tap_soft.wav）全工程 0 调用正好可用，+haptic。
**S4. IAP 支持完成（情感峰值）无音效**：`support_purchase_controller.dart:226-243` delivery、`support_yard_screen.dart:619` 展示处——播一个 sting（restored 恢复购买可不播）。

### P3（备案）

- **S5** 明信片到站弹窗无音效（`yard_home_screen.dart:750-762`；`Sfx.paperOpen` 语义完全吻合，对比访客到站有 `visitorArrive`）。
- **S6** `Sting.achievementHidden` 与 `Sfx.tapSoft` 为死资产（若做 S3 则 tapSoft 复活）。
- **S7** `audio_service.dart:214-219` fade-out 循环结束到 stop/play 之间缺一次 `request != _bgmRequest` 校验（极快连切 BGM 短暂播错，自愈）。

### 已核验无问题
59 个打包音频 + pubspec 注册 + 许可清单三方完全对账；20 访客声纹双向对齐；关键交互音效覆盖（除 S3/S4/S5）；生命周期打断恢复（iOS ambient 模式、不抢焦点）；开关持久化全局生效；5 个固定 player 无泄漏无爆音；音量层次 ambience 0.20 → sting 0.9 清晰合理。

---

## 四、渲染/性能维度

### P1

**R1. SpriteSheetPlayer 从不 dispose ImageInfo，序列帧原生内存滞留**
- `lib/ui/widgets/sprite_sheet_player.dart:132-137`（存 `info.image`）、`:91`（换资产直接丢）、`:167-176`（dispose 未释放）。每张 4096×512 动作条 ≈8.4MiB 解码位图要等 GC 终结器兜底，`imageCache.clear()` 清不掉被句柄挂住的部分 → 内存告警清理打折、低端机被杀概率升高。
- 修法：State 保存整个 `ImageInfo`，在 didUpdateWidget 换资产、onImage 收新图、dispose 三处调用旧 `ImageInfo.dispose()`。

**R2. 主宠物呼吸动画缺 RepaintBoundary，院子全屏 60fps 重绘**
- `lib/ui/widgets/pet_sprite.dart:202-231`（AnimatedBuilder+Transform）、`yard_home_screen.dart:575-600`（PetSprite 无 RepaintBoundary 包裹）。对比 `_YardVisitor`（`:2415`）自己包了。最常驻界面的最大耗电/发热点。
- 修法：PetSprite 外层（`:578` Align child）包一层 `RepaintBoundary`；`_StaticActionChoreography` 同理受益。

### P2

**R3. 动作 cue watch 放整屏 build 内**：`yard_home_screen.dart:586` 每次互动全场景 rebuild；`:357` 整屏 watch 使每分钟心跳也整屏重建。修法（冻结期最小改动）：PetSprite 一支包 Consumer 只 watch cue。

### P3（备案）

- **R4** 雨/雪 overlay（`:2134`）无 cacheWidth（941×1672 全解 ≈6.3MiB，可省 1-3MiB）；雷暴闪光（`:2143-2153`）alpha≈0 时仍每帧 paint 全屏 ColoredBox。
- **R5** 换宠时旧动作条不主动 evict（`evictOnDispose` 参数存在但无调用方），预算内可接受。
- **R6** 存档 load 的 `jsonDecode` 在主 isolate（`session_store.dart:144`，save 侧已用 compute，不对称）——当前体量毫秒级安全，存档长期增长后建议对称化。

### 已核验无问题
帧 clamp/回调时序/失败 fallback/播放中换资产/controller+listener 配对；图片缓存 72/96MiB 分档 + didHaveMemoryPressure 完整实现（clear+清 live+取消预载+2 分钟保守渲染）；precache 双重限流 + 预算预判；背景大图 cacheWidth 按屏截断；首帧路径轻量（内容 JSON ~400KiB 在 loading 期解析，首帧静态启动页）；WebP 解码预算受控（同刻 1 张主题图，LRU 最多 4-5 张）。

---

## 五、玩法数据维度

### P1

**D1. 两个隐藏成就永不可达（运行期静默失败）**
- `assets/data/achievements.json`：`ach_h_uni` petId=`"尼可"`、`ach_h_boo` petId=`"噗噗"`，但 `game_services.dart:718` 用 `species.name == name` **精确匹配**，正式名是"独角兔尼可"/"小幽灵噗噗" → 永不命中，各 40 暖绒+纪念贴纸拿不到（ember/starbug 恰好全名一致所以能达成）。
- 修法（改数据面更安全）：JSON 两处 petId 补全名。**并补一条取值级测试**（现有 `test/app/achievement_progress_test.dart:592` 只校验 param 键名，没拦住这个）。

### P3（备案，多为改文档不改数值）

- **D2** 成就暖绒总量实际 4,850 vs 文档 ≈4,470（+380）——更新 `content-achievements.md §3.3` 核算数字即可。
- **D3** 带暖绒的特殊事件实为 7 个（文档只记 2 个）——补全 `spec-economy.md §1.6` 表。
- **D4** 31/40 地点的专属遭遇/碰撞池深度仅 1，同地点明信片重复感在长期回信阶段明显——v1.0+ 每地点补 1-2 条，提交版可接受。
- **D5** 软偏差备案（均有代码兜住、非 bug）：`unlockClue` 混用 `clue_ember+1`/`starbug+1` 格式（靠 `_normalizedClueId` 硬编码救回，建议数据统一）；`decorReq` 与商店 decorId 不同名（靠 `yard.dart:70` 别名映射）；`ach_h_tsundere` 的 personality 参数是注释性描述（实际按 `p_aloof` 门控）；shop/species/visitors 的 `artRef` 多为未使用遗留字段；`inc_cs_03` poseHint=idle 有 `idle→gaze` 回退。

### 已核验无问题
全量外键零 dangling（模板/遭遇池/碰撞 vibe/事件引用/244 互动全矩阵/线索链/成就券）；40 地点 8 类×5 齐全；12 物种解锁全可达（3 初始+5 gradCount+4 hiddenClue 阈值与 config 一致）；经济无死锁（首只毕业 445 > 最便宜主题 400）；36 SKU 价目与文档一致；时间参数与 docs 全对齐（含毕业后 +1 天寄首张）；无空串/占位符/截断；其余 79 条成就可达且天数合理。

---

## 六、文案维度

### P1

**C1. 乱码级错别字**：`visitor_interactions.json` `vi_sparrow_boo`（~109 行）「啾啾**径盶**从噗噗身体里穿了过去」→「径直」。
**C2. 英文关于页显示 "Use: Petopia"**：`settings_screen.dart:897` 的源串 `'应用'` 被商店按钮翻译（`english_copy.dart:794` `'应用': 'Use'`）劫持。修法：设置页改用不冲突源串（如 `'应用名称'`）。
**C3. "暖绒不足" 漏翻，英文界面漏中文**：`shop_screen.dart:855` 角标；english_copy 只有 `'暖绒不够'` 条目。修法：统一为「暖绒不足」（`docs/copy-tone-guide.md:15` 的标准词）并补英文条目——顺带解决同屏 `:717`「不够」vs `:855`「不足」不一致。
**C4. 来客缘分范围词漏翻 + 乌鸦名颠倒**：`game_controller.dart:1010-1013` 的 `'松鼠'/'蝴蝶'/'特别'` 在 `_terms` 无条目（英文商店显示 "+10% chance for 松鼠 visitors"）；且 `'亮亮乌鸦'` 与正式名「乌鸦亮亮」颠倒（中文也错）。修法：改「乌鸦亮亮」+ 补 3 个词条。
**C5. 明信片模板 ~35 条会拼出病句（两类系统性问题）**
- *整句塞名词槽*（6 条）：encounter/incident 词条是完整叙事句，但 `tpl_dr_sm_01`「今天我是{incident}的颜色」、`tpl_na_cs_01`「学会了{incident}」、`tpl_na_xy_01`「{location}的{incident}」、`tpl_cu_sd_02`「发现了{incident}！」、`tpl_gl_sd_01`「山顶有{encounter}」、`tpl_ge_sd_01`「遇到{encounter}，它的行李散了一地」——渲染出「今天我是把驼铃当成饭铃狂奔三里地的颜色」类破句。修法：改成让词条独立成句（「有了新发现：{incident}！」式）。
- *人称/指代错配*（~29 条）：模板用「他/它/他们」假设词条主体，但池内人类/动物/第一人称词条混抽——`tpl_en_cs_01`「{encounter}，他说我比早高峰还准时」×「鸽子帮跟我比赛」等。修法：骨架里 `{encounter}` 后不用人称代词（改「对方/那位朋友」或独立成句）；或给模板加 encounterIds 白名单让生成器过滤（`postcard_content_alignment.dart` 已有 locationIds 同型机制可复用）。受影响清单：tpl_gl_xy_03/gl_jd_03/lz_cs_02/lz_jd_02/cu_cs_01/cu_sm_01/en_cs_01/cl_cs_02/ge_sm_02/dr_cs_02/dr_sm_01 及 17 条「{encounter}，它…」型（cl_hb_02/cu_sl_01/ti_jd_01/ge_sl_02 等）。

### P2

**C6. 场景/地点约束穿帮（9 处，根源是分类错误）**：蓝洞泉/运河小城/汽船栈桥三个温带地点被归「极地水域」类共用极地词池 → 夏天的运河小城收到「结冰的运河助跑漂移」（`tpl_en_jd_03`）。另有天气词直接代入的必然病句：`tpl_ge_xy_02`「完工时{weather}刚好停了」→「晴朗刚好停了」（乡野 5 地只有 clear/cloudy）、`tpl_cu_xy_02`「{weather}果然被我说中了」；以及 `tpl_na_jd_03`（蓝洞泉非温泉无雪）、`tpl_al_xy_03`（萤火稻田不下雨）、`tpl_dr_hb_01`（「找到中午，找到的都是月光」）、`tpl_ti_sd_02`/`tpl_na_hb_01`（轻度）。修法：极地通用模板显式绑定 aurora_village/icefloe_lighthouse（或拆「水域」类）；weather 槽两条改写。
**C7. 成就名实不符**：`ach_grad_8`「八次启程」/`ach_grad_12`「十二段相伴」条件却是 `speciesCollected`（集齐物种），与同系列 `gradCount` 条件的「三段相伴/五段相伴」命名撞车。修法：改名（如「八种伙伴」「十二页图鉴」）。
**C8. 旧币名残留**：`yard_home_screen.dart:3028` 无障碍标签「绒光 $wallet」→「暖绒」（中文 VoiceOver 会读出旧名；english_copy:294-295 的绒光兼容分支一并删）。
**C9. 「来客」vs「访客」统一（规范词=来客）**：`visitor_dex_screen.dart:932`（来客图鉴空状态混用「访客」）、`growth_journal_screen.dart:634`（经验来源标签）、`visitor_interactions.json:1929`「访客册」→「来客册」、`events.json` 6 条叙事（ev_d05/d44/d62/d65/d69/d96，同文件 ev_s02/s10 已用「来客」）、`metadata-zh-Hans.md:20,28`（商店描述，`:39` 又用「来客」）。英文侧同一功能三个名（Visitor Compendium/visitor book/Garden Visitor Sticker Book）也收敛为一个。注意改键需同步 english_copy 对应条目。
**C10. 商品名/分类错位**：`shop_album_star_chart` 名叫「图鉴皮肤·星图夜航」effect 却是 albumSkin（同类均「相册皮肤·×××」）→ 名字改「相册皮肤·星图夜航」；该分类名「明信片」下四件全是皮肤，建议改「相册与皮肤」。泡泡浴皂归「特殊食粮」类同理（可只改前者）。
**C11. 词条残留/复读**：`inc_sl_02`「**腮帮/背包**塞太满」半角斜杠是写作候选残留会原样展示（二选一）；`tpl_al_sm_02`「{encounter}。请我喝了一碗奶茶」×`enc_sm_03`「摊主请我喝了一碗驼奶茶」近乎复读（排除该词条或改写）；`vi_snail_rabbit`「慢递…快递」前后不一。
**C12. ASC/审核文档三处**：`review-notes-zh-Hans.md` 写「设置 > 通知」实际路径是「设置 > 温柔提醒 > 允许通知」（审核员照做找不到）；`support-iap.md`/storekit 里 Garden Bouquet 描述用 "yard" 与全局 "garden" 不一致；英文「首次」日期丢年份（english_copy:319-322 vs 280-283 两种格式）。

### P3（备案）

- 英文复数硬伤：`'1 postcards'/'1 visits'`（english_copy:36-37,72-73,226-227，参照 130-133 的 1 item/N items 特判改）。
- 引号体例：模板『』vs 词条「」会拼进同一张明信片；UI 侧「」vs "" 两派（毕业/商店 vs 设置/隐私）。全局定一种。
- 零星措辞：`tpl_ti_hb_01`「探近」疑为「探进」；`ach_h_memory`「翻起旧照片」→「翻看」；`ach_login_100`「一百个日安」vs 前两档「×次日安」；species clueText 省略号/句末标点三处不统一；`pet_uni` baseTone「独角兽幼体」像分类标签；动物代词它/她/他们三处不统一；`vpi_owl_hamster`「建议返工」/`p_timid`「黏死你」调性轻微出戏（可保留）；visitor_interactions 约 10 条句末句号与主流不带句号不一致；`bootstrap.dart:67`「发现异常」偏系统腔（改动需同步 `game_controller.dart:1858` 的整句映射键）；Android 通知渠道名硬编码中文（`notification_service.dart:198-199`）；内容覆盖薄弱地点（星星修理铺/伐木温居专属模板为 0，7 地仅 1 条）v1.0+ 补。
- 工程备注：`game_controller.dart:1706` 用 `memory.text.contains('轻轻来过')` 嗅探状态——改这句文案会静默破坏 interacted 判断，未来应改结构化字段。**本轮所有文案修改前先 grep 该串确认不受影响。**

### 已核验无问题
ASC 硬限制全部在限内（名称 12/30、副标题 13/30、关键词 58/100B、促销 52/170、描述 447/4000）；「40 地点/12 物种/四段成长/IAP 时长」等数字与数据文件全对齐；「手账」全库统一零「手帐」；中文全角标点无混排；无占位/调试文案泄漏（TestFlight 工具有编译开关+收据双重门禁）；调性全库零系统腔零焦虑词（除备案 1 处）；english_narrative 对 120 事件/40 地点/20 访客/12 物种覆盖率 100% 且有测试兜底；明信片模板 slots 结构零偏差、无坏引用、分布均匀。

---

## 七、模拟器全流程走查（2026-08-15，iPad Pro 13 真实新档）

> 方法：干净构建 + 全新安装，从首启引导一路走到支持页；覆盖 onboarding→领养→摸头/喂食→引导完成→来客到访/互动/图鉴收录→手账菜单→商店→设置→支持页。
> **链路结论：核心闭环全部正常**——moment 弹窗串行、照料冷却与钱包、今日任务卡、来客互动+4 经验收录图鉴、商店"暖绒不足"统一文案（C3 修复已生效）、设置页语言/画面/通知/存档全项在位。院子新布局（8 槽+缩小宠物）在真实新档（豪华度① 2 件装饰）下观感正常。

### P2（建议上车）

**W1. 首启迎接页宠物悬空**：三页引导的宠物都悬浮在拱门上方半空（脚下无着地点），iPad 上尤其明显。建议把立绘底边对齐到草地线或给底部加淡淡草影。
**W2. 领养页 iPad 排版失衡**：三张物种卡贴顶、中间约 60% 纯空白、名字输入框贴底。建议 iPad 上卡片放大居中、输入区跟随卡片。
**W3. 支持页 StoreKit 错误透传英文**：商品加载失败时页面显示 `StoreKit: Failed to get response from platform.`——弱网/受限地区真实用户可见,违反全局温柔文案基线。建议改为「商店暂时没有连上,稍后再来看看吧。当前院子不受影响。」类文案（真机 sandbox 验收时注意确认正常路径无此条）。
**W4. 商店主题预览图一半无辨识度**：樱花小径/星夜帐篷/海风假日/糖果焙房的预览图截到的全是草地区域,看不到樱花/夜色/海/糖果元素（雪屋暖灯/秋日果酱正常）。预览裁切区域应对准各主题的特征带（多在背景图上半部）。

### P3（备案）

**W5.** 设置-关于区「应用名称」label 列宽不足被折行为「应用名/称」。
**W6.** 来客互动文案用物种代称（"雪团"）而非玩家起的名——`content-visitor-pet-matrix.md` 既定约定,备案不改;若玩家反馈困惑,v1.x 可改为动态名。
**W7.** 首日新手期四动作各做一次后全部进入 10-15 分钟冷却,首个 session 可做的事较少——设计上由来客/事件/任务承接,符合零焦虑定位,备案确认为有意为之。

### ⚠️ QA 环境教训（后续真机 QA 必读）

**跑过 `flutter test integration_test` 的机器/模拟器上做手动 QA 之前,必须 `rm -rf .dart_tool/flutter_build` 后重新 `flutter build`,并卸载重装 App。** 本次走查开局即踩坑:增量构建把 integration_test 的测试入口留在了 kernel_blob.bin 里,装出来的"App"实际是自动轮播 mock 场景的测试宿主（顶栏"橘团 · Lv 6 / 237"即测试数据）,肉眼与真 App 几乎无法区分。判别方法:`strings <App>/Frameworks/App.framework/flutter_assets/kernel_blob.bin | grep -c 橘团`,非 0 即污染。

---

## 附：给 Codex 的修复铁律

1. 只处理本文件列出的 finding，不顺手重构、不加新功能、不动未提及的资产与代码。
2. §美术"已落地修复"只做复核与提交，不重做、不回退。
3. 修复顺序：先 P1 总表（U→S→R→D→C），再 P2；P3 一律不做（备案供 v1.0+）。
4. 文案类改动注意三个联动：改中文源串必须同步 `english_copy.dart` 对应键；`bootstrap.dart:67` 与 `game_controller.dart:1858` 整句映射成对；动任何访客回忆文案前先 grep `'轻轻来过'`（`game_controller.dart:1706` 有内容嗅探）。
5. C5/C6（明信片模板）修复后跑一次 10,000 张生成仿真（`check_release_candidate.py` 已含），确认无新病句模式。
6. 改完必须过：`flutter analyze`（0 issue）、`flutter test`（全绿）、`python3 tools/check_pet_art.py`、`python3 tools/build_release_asset_manifest.py --check`、`python3 tools/check_release_candidate.py`。
7. 每个维度一个 commit，commit message 引用 finding 编号（如 U1-U4 / S1 / C2-C4）。
8. D1 修复必须附带取值级测试（成就 petId ↔ species.name 全量核验），防止同类回归。
