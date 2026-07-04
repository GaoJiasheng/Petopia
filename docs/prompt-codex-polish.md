# Codex 打磨/优化任务包（Petopia）

## ⛔ 铁律（务必遵守，上次被违反过）
1. **一个美术/资源文件都不许改**：`assets/**`（png/jpg/ogg/wav/json 里的 data 除外见下）、`ios/Runner/Assets.xcassets/**`（App 图标）、任何图片/音频。**不许重新生成美术、不许 re-save PNG、不许碰 App 图标**。
2. **不许改 `pubspec.yaml` 的 assets 清单**（已配好），也不要改依赖。
3. **不许改动已测的核心逻辑**：`lib/services/**`、`lib/domain/**`、`lib/data/**`（除非某任务明确要求，且要保持 `flutter test` 全绿）。
4. 若某任务看起来需要新美术/改美术 → **停下，在产出说明里报告**，不要自己造图。
5. 每个任务**独立小提交**，提交信息说明改了什么。全程 `flutter analyze lib/` = No issues found、`flutter test` 全绿。
6. 只在必要文件上动手；不做无关重构、不改格式化风格。

---

## 任务 1：逐动作序列帧动画（**只写代码**）
详细规格见 `docs/prompt-pet-action-animation.md`，**严格照它做，且遵守上面铁律（一个 PNG 都不碰，动作帧美术已存在）**。
核心：新建 `lib/ui/widgets/sprite_sheet_player.dart`（CustomPainter 播 4096×512 的 8 帧条）+ 改 `lib/ui/widgets/pet_sprite.dart` 播动作 + `lib/ui/yard_home_screen.dart` 触发（点宠物=pat，四动作各播 eat/pat/play/bath），缺帧回落现有弹跳。**不新建/不修改任何图片。**
验收：领养后点宠物播摸头、四动作各播各的、播完回静止呼吸；analyze 0 / tests 绿。

## 任务 2：院子摆件自由摆放（买了能摆）
现状：院子 `_YardDecor` 写死 3 个摆件，`yard.ownedDecorIds`（商店买的）没被使用；`YardState.slots`（`List<YardSlot>{pos,itemId}`）已存在但没接。
做：
- 新增「院子布置」入口（院子菜单加一项，或信息卡旁一个小按钮）→ 布置屏：列出 `ownedDecorIds` 里已拥有的摆件（用 `assets/art/world/decor/<decorId>.png`，缺图 errorBuilder 回落），可把某摆件指派到院子的若干槽位（`yard.slots`，pos 为预设锚点，如左/中/右几个固定点即可，不必自由拖拽）。
- `GameController` 加 `placeDecor(pos, decorId?)`（null=清空该槽）+ 读 slots 的视图数据；院子渲染改为按 `yard.slots` 画摆件（保留现有 3 个作为「默认布置」的初始值也可）。
- 存档：slots 已在 SessionStore 序列化，确认往返正常。
验收：商店买个摆件 → 布置屏能把它摆到院子 → 院子出现该摆件 → 重启还在。analyze 0 / tests 绿。

## 任务 3：照料冷却实时倒计时
现状：动作按钮显示 `cooldownSec` 但只在动作时重算，不逐秒跳。
做：在 `YardHomeScreen`（或动作栏组件）用一个每秒 `Timer.periodic` 触发 `setState`/刷新，让冷却数字**逐秒递减**、到 0 自动恢复可点（数据仍从 `GameController` 的 `cooldownSec` 取，不要把冷却逻辑搬进 UI）。`dispose` 要取消 timer。
验收：喂食后按钮上的秒数每秒减 1，归 0 变回「喂食 +3」。analyze 0。

## 任务 4：成就「解锁庆祝」toast + 补齐几类成就接线
4a. **解锁庆祝**：`GameController._afterGameAction` 已知本次 `syncAchievements()` 返回的新解锁列表（现在只播 sting）。把新解锁的成就名冒泡给 UI：加一个 `ValueNotifier<List<String>>`（或 Riverpod）传出新解锁成就名，`YardHomeScreen` 监听后弹一个温柔的 toast/浮层（「达成成就：XXX」）。别打断操作。
4b. **loginStreak 每日推进**（现在从不更新）：在 `bootstrap` 里比较 `settings.lastLoginDay` 与今天——同日不变；隔 1 天 `loginStreakCurrent++`；断档则重置为 1；更新 `lastLoginDay` 与 `loginStreakMax=max(...)`。然后现有 `syncAchievements` 会自动推进 loginStreak 类成就。
4c.（可选）`unlockPet`/`seasonPostcard` 类：若能从 session 现状派生就并进 `GameServices.syncAchievements` 的 counts；派生不了就**在说明里列出**，别硬凑。
验收：解锁成就时院子弹 toast；连续两个自然日进游戏 loginStreak 前进（可用改设备日期验证）。analyze 0 / tests 绿。

## 任务 5：明信片查看器叠加姿态 + 贴纸
现状：`postcard_viewer_screen.dart` 只画背景 + 手写正文。
做：在照片区把**宠物姿态**叠到背景上（`assets/art/postcards/poses/pc_pose_<species>_<poseHint>.png`，species 取该明信片对应宠物、poseHint 来自 incident 的 poseHint——需要 `PostcardView` 补带 `speciesId` 与 `poseHint`，从 `Postcard`/incident 取），再点缀 1–2 个贴纸（`assets/art/postcards/stickers/pc_sticker_*`，可按 incident/vibe 选或随机固定）。全部 `errorBuilder` 回落，缺图不崩、不留白。**不新建图片**，只用现有资源。
验收：打开一张明信片，照片区能看到宠物姿态叠在地点背景上 + 邮戳 + 正文。analyze 0 / tests 绿。

## 任务 6：菜单弹层图标换成真图标
`yard_home_screen.dart` 的 `_MenuRow` 与弹层项还用 Material 图标；换成 `AppIcon('nav_*')`/相应语义图标（成长手账/相册/图鉴/成就/商店/设置/来客），缺图回落 Material。纯视觉替换。
验收：院子菜单每项显示水彩图标。analyze 0。

## 任务 7：首帧性能（预缓存）
在院子首次构建时对**当前宠物**的静止立绘与其动作帧做 `precacheImage`，避免动作首播卡顿。别过度预热（只当前物种）。
验收：analyze 0；无行为回归。

---

## 交付
每个任务单独 commit。产出说明里逐条列：改了哪些文件、任务 4c/需要美术的地方有没有卡住、以及 analyze/test 结果。
再次强调：**任何 png/图标/音频/pubspec-assets 都不许动**——只写 Dart 代码（任务涉及的 `lib/**`）。
