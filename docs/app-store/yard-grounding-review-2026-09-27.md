# T0g｜主次比例与草坪落点修订（2026-09-27）

基线：`55c3243`。回应用户对来客/回访过大、池塘不落地及炉子压住背景花丛的复核意见。

## 修改

- `lib/ui/yard_home_screen.dart`：来客投影尺寸乘以 0.72，并限制有效画布高度不超过主宠画布的 72%；回访参考尺寸由 0.54 调整为 0.38。主宠与双盆不变。保留物种相对差异和透视，但以主宠的视觉主导地位约束最大体量。
- 后排池塘的前缘向草坪内移动，横屏额外右移，避免侵入主宠轮廓。只修正后排槽位，不覆盖玩家在其他槽位的选择；修正不依赖来客是否出现。横屏槽位 3 向前错开，为池塘留出完整落地范围。
- 炉子左右落点限制到内部草坪，平板竖屏采用不同边界，避开外侧花丛并保留与稻草人的间距。此边界是对当前插画构图的视觉修正，不是自动识别所有背景花朵的碰撞图。
- `test/ui/yard_home_layout_test.dart`：根据用户本轮“配角过大”的明确反馈，替换上一版过强的最小体量断言，并增加最大体量断言。配角须可辨识、位于前景且小于主宠。没有修改 placements oracle、2.5% 碰撞阈值、完整槽位数量或到访时位置不变断言。

没有改动素材、玩法数值、版本或发布配置。测试通过只证明受测布局约束；落地感仍通过实际背景截图逐张复核。

## 验证

- `flutter test --no-pub test/ui/yard_home_layout_test.dart test/ui/yard_projection_test.dart`：27 passed、1 existing skip。
- `flutter analyze`：0 issue，日志 `logs/final-analyze.log`。
- `flutter test`：314 passed、3 existing skips，日志 `logs/final-tests.log`。
- `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：**PASS**，四竖两横各 51/51。
- `python3 tools/check_pet_art.py`：PASS；`python3 tools/audit_runtime_art.py`：PASS（发布候选检查内执行）。
- 草稿阶段发现炉子内收与稻草人相交、横屏池塘与主宠/蘑菇凳相交，已通过实现调整消除，没有放宽碰撞断言。草稿日志不作为最终通过证据。

## 六组截图

截图根目录：`build/yard-grounding-2026-09-27/`。草稿在 `draft/`，最终证据在 `final/`；二者分别保存。

| 配置 | 物理像素 | placements |
|---|---:|---|
| iPhone 6.9 竖 | 1320×2868 | PASS 51/51 |
| iPhone 17e 竖 | 1170×2532 | PASS 51/51 |
| iPad mini 竖 | 1488×2266 | PASS 51/51 |
| iPad 13 竖 | 2064×2752 | PASS 51/51 |
| iPad mini 横 | 2266×1488 | PASS 51/51 |
| iPad 13 横 | 2752×2064 | PASS 51/51 |

横屏同时传入 `PETOPIA_VISUAL_LANDSCAPE=true` 与对应 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT` 物理像素。

六张代表场景原尺寸截图：

- [iPhone 6.9 竖屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/iphone69-port/yard-full-player-decor-both-actors.png)
- [iPhone 17e 竖屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/iphone61-port/yard-full-player-decor-both-actors.png)
- [iPad mini 竖屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/ipadmini-port/yard-full-player-decor-both-actors.png)
- [iPad 13 竖屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/ipad13-port/yard-full-player-decor-both-actors.png)
- [iPad mini 横屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/ipadmini-land/yard-full-player-decor-both-actors.png)
- [iPad 13 横屏](/Users/gavin/work/petopia/build/yard-grounding-2026-09-27/final/placements/ipad13-land/yard-full-player-decor-both-actors.png)

完整命令、设备与结果：`final/placements-results.json`；306 张图片的物理尺寸均已核对，校验清单为 `capture-manifest.json`。修改前后手机对照为 `before-after-phone.png`。

## 需要账号持有人手动做的事

无。不涉及上传、发布、账号或证书。
