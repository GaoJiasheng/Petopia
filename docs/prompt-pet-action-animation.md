# Codex 任务：宠物逐动作序列帧动画（所有物种、每个照料动作一个动画）

## 现状
- 院子里宠物是**静态 PNG**（`pet_{sp}_var01_stage{A-D}.png`）+ 通用「呼吸/点击弹跳/冒爱心」（见 `lib/ui/widgets/pet_sprite.dart`）。
- 照料动作 feed/pat/toy/bath 走 `GameController`（`lib/app/game_controller.dart` 的 `_care`），只加经验，无专属动画。
- 点击宠物 = 摸头（`YardHomeScreen` 里 `PetSprite(onTap: ctrl.pat)`）。

## 已有美术（务必按此切帧）
- 目录：`assets/art/pets/{species}/actions/`（12 物种：cat/shiba/rabbit/hamster/boo/cham/ember/parrot/snake/starbug/turtle/uni）
- 文件：`pet_{sp}_var01_stageC_{action}.png`，`action ∈ {idle,eat,pat,play,bath,sit,sleep,walk}`
- **每张 = 4096×512 的横向序列帧条 = 8 帧，每帧 512×512**（从左到右播放）。
- ⚠️ **只有 var01 / stageC 有动作帧**。仅当当前宠物身份与该帧条完全一致时播放；其他花色或成长档必须保留当前立绘，以五秒身份保持动作编排完成互动，禁止短暂换色、换档或仅显示图标。
- ✅ **pubspec 已注册好 12 个 `actions/` 目录**（无需再改 pubspec 的 assets）。

## 要实现
1. **可复用序列帧播放组件** `lib/ui/widgets/sprite_sheet_player.dart`
   - 纯 Flutter（不引 Flame）：用 `AnimationController` + `CustomPainter`，把 `ui.Image` 按 `frame = (t*frameCount).floor().clamp(0, frameCount-1)` 画对应 `srcRect`（第 i 帧 = `Rect.fromLTWH(i*512, 0, 512, 512)`）到目标区域。
   - 参数：`assetPath`、`frameCount`(默认 8)、`fps`(默认 12)、`loop`(bool)、`onComplete`。
   - 用 `ImageStream`/`precacheImage` 异步加载 `ui.Image`；加载中或失败时渲染传入的 `fallback` widget（绝不崩、不留白）。
2. **改造 `PetSprite`**（保留对外 API：`assetPath`、`width`、`onTap`）
   - **静止态**：维持现在的「当前档静态立绘 + 呼吸」（保住成长视觉：A/B/C/D 立绘不同，别用 idle 帧覆盖）。
   - **动作态**：收到某动作触发时，播放约 5 秒完整演出后回到静止态。`var01 / stageC` 播放手绘帧条；其他身份使用当前立绘的准备→接触→反馈→收势编排，并叠加独立透明水彩道具。
   - 点击宠物：播 **pat（摸头）**动画 + 保留冒爱心。
   - 动作→帧条映射：`feed→eat`、`pat→pat`、`toy→play`、`bath→bath`。
   - 帧条路径：`assets/art/pets/{dir}/actions/pet_{dir}_var01_stageC_{action}.png`，`dir` = speciesId 去掉 `pet_` 前缀（复用 `lib/ui/pet_art.dart`，建议加 `PetArt.actionSheet(speciesId, action)`）。缺文件 → 回退现有弹跳+爱心，绝不崩。
3. **触发接线**（纯视觉，别动经验/冷却逻辑）
   - 用轻量 `ValueNotifier<CareAction?>`（或 Riverpod `StateProvider`）把「按了哪个动作」传给 `PetSprite`。在 `YardHomeScreen`：
     - 4 个动作按钮 `onTap`：先调用原 `ctrl.feed/pat/toy/bath`（**不变**），再把对应 `CareAction` 推给 notifier。
     - 宠物 `onTap`：调用 `ctrl.pat` + 推 `CareAction.pat`。
   - `PetSprite` 监听 notifier，值变化就播对应动画（需能重复触发：用自增序号，或播完置 null）。
   - 冷却中（`cooldownSec>0`、动作被 `_care` 忽略）时**不要**播动画：按钮在冷却时不推 notifier。

## 约束
- 只改/加：`lib/ui/widgets/sprite_sheet_player.dart`(新)、`lib/ui/widgets/pet_sprite.dart`、`lib/ui/yard_home_screen.dart`、`lib/ui/pet_art.dart`（加 `actionSheet`）。**不动** service/controller 的经验逻辑。**pubspec 不用改**（actions 目录已注册）。
- 性能：帧图较大（512²×8）；加载后缓存复用，`dispose` 释放 controller；可对当前物种的动作帧 `precacheImage` 预热。
- `flutter analyze lib/` 必须 **No issues found**；`flutter test` 保持全绿。

## 验收
- 领养一只 → 点宠物播「摸头」、四个动作各播各的动画、播完回到静止呼吸。
- 缺帧物种/动作回落到保留当前身份的完整动作编排，不崩、不留白、不显示几何占位。
- 完成后列出：新增/改动文件、动作→帧条映射、手绘锚点覆盖范围，以及非锚点身份保持编排的覆盖与验收结果。

## 当前覆盖原则
不要求为 960 个状态重复烘焙整套帧条；运行时必须在不改变物种、花色、成长体型和屏上尺寸的前提下，让全部 12×5×4×4 状态获得清晰、完整、可区分的互动反馈。
