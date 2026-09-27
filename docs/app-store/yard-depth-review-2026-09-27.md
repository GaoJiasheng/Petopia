# T0f｜院子统一景深尺度与错落摆放（2026-09-27）

基线：`58482cf`。承接用户批准的“统一尺度、有限夸张”方案。本轮只修改院子呈现，不改玩法数值、素材、版本或商店内容。

## 本轮实现

- `lib/ui/adaptive_layout.dart`：主宠、来客、摆件和双盆共享一个地面透视尺度。以主宠画布内约 80% 的绘制高度对应 0.60 m 的美术参考；这是假定的场景标尺，并非从插画测得的真实尺寸。窄屏限制来客宽度时，同时按透视比例后移其落脚点；碰到摆件继续先寻找水平空位，玩家摆件不随来客移动。
- `lib/ui/yard_home_screen.dart`：八槽按左侧、后侧、右侧错落排布，打破两条统一落地线；横屏和平板竖屏分别安排。来客与回访的预期脚点分别位于主宠前方 0.30、0.24 个主宠画布宽度，并受实际操作栏边界限制。两只盆稍微偏右组成生活区，与绘制模型分离。
- `lib/ui/yard_visitor_geometry.dart`：记录 20 种来客、每种八帧的 alpha 轮廓并集，四周增加画布 3% 余量。显示时只排除透明留白，不拉伸、替换或重绘素材。鹿的动画主体原来只占画布约 45% 的宽度；去掉无用留白后，手机不必把整只鹿缩成小玩偶。动画载入失败时的备用图也放在同一有效区域内。
- `test/ui/yard_projection_test.dart`：新增两项回归，防止主宠与同高度摆件使用两套尺度，以及窄屏把鹿原地缩小。另在 `test/ui/yard_home_layout_test.dart` 新增“八槽全部高摆件时，鹿仍须保留前景位置与可读体型”测试。原有布局断言、2.5% 碰撞阈值、八槽完整性、到访时位置不变、所有 51 场景均未修改。

美术参考：主宠含举起尾巴的绘制高度 0.60 m、幼鹿约 0.80 m、鹭约 0.65 m、猫/狐狸类来客约 0.46 m、双盆宽约 0.18 m。保留小型昆虫的最低可读尺寸。回访宠物沿用原素材透明安全边，因此其画布高度与实际身体高度有所区别。

本轮保留现有背景与裁切策略，使用一致的近似地面透视，不声称还原了每张水彩插画的真实相机。背景、玩家选定摆件、来客类型的最终视觉效果仍以六尺寸截图复核。

## 验证

- `flutter test --no-pub test/ui/yard_projection_test.dart test/ui/yard_home_layout_test.dart test/ui/adaptive_layout_test.dart`：首轮 36 passed、1 existing skip；补充满高摆件下的鹿用例后，`flutter test --no-pub test/ui/yard_home_layout_test.dart test/ui/yard_projection_test.dart` 为 27 passed、1 existing skip。
- `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：**PASS**。内部包含 `flutter analyze`、`flutter test`、美术审计及六配置 placements。
- `flutter analyze`：0 issue；`flutter test`：314 passed、3 existing skips（同一候选检查内执行）。
- 首轮代表场景：iPhone 17e 与 iPad mini 横屏均通过。首轮图仅用于中间复核，不替代最终证据。

- `python3 tools/check_pet_art.py`：PASS。
- `python3 tools/audit_runtime_art.py`：PASS。

动画范围独立核对：20 种来客的 160 帧有效像素均完整包含在新边界内，日志 `logs/visitor-bounds.log`。

首轮完整检查曾因实图发现“高摆件把鹿推退到后景”而主动中止；记录在 `logs/release-before-deer-review.log`，不作为最终通过证据。

日志：`build/yard-depth-2026-09-27/logs/`。最终截图与每组完整命令已归档在同目录的 `final/placements-results.json`；306 张截图均核对物理尺寸，SHA-256 清单在 `capture-manifest.json`。

## 六组截图

| 配置 | 物理像素 | placements 结果 |
|---|---:|---|
| iPhone 6.9 竖 | 1320×2868 | PASS 51/51 |
| iPhone 17e 竖 | 1170×2532 | PASS 51/51 |
| iPad mini 竖 | 1488×2266 | PASS 51/51 |
| iPad 13 竖 | 2064×2752 | PASS 51/51 |
| iPad mini 横 | 2266×1488 | PASS 51/51 |
| iPad 13 横 | 2752×2064 | PASS 51/51 |

横屏明确传 `PETOPIA_VISUAL_LANDSCAPE=true` 与对应物理像素 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT`。

代表场景原尺寸截图（八件玩家摆件、主宠、来客和回访同时出现）：

- [iPhone 6.9 竖屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/iphone69-port/yard-full-player-decor-both-actors.png)
- [iPhone 17e 竖屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/iphone61-port/yard-full-player-decor-both-actors.png)
- [iPad mini 竖屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/ipadmini-port/yard-full-player-decor-both-actors.png)
- [iPad 13 竖屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/ipad13-port/yard-full-player-decor-both-actors.png)
- [iPad mini 横屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/ipadmini-land/yard-full-player-decor-both-actors.png)
- [iPad 13 横屏](/Users/gavin/work/petopia/build/yard-depth-2026-09-27/final/placements/ipad13-land/yard-full-player-decor-both-actors.png)

## 需要账号持有人手动做的事

无。本轮仅本地代码与模拟器截图，不涉及上传、发布、账号或证书操作。
