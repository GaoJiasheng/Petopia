# T0 追加视觉调整：动物主体与后场摆件（2026-09-18）

> **状态更新（2026-09-18 晚）**：账号持有人已批准本方案及下文列出的测试更新范围。Claude 复核时补齐两处六尺寸问题
> （iPad mini 横屏饭盆压进操作栏 6pt、iPad 13 横屏稻草人与夜灯重叠），已作为 `582eeb0`
> `fix(yard): T0e …` 提交，发布门禁 306/306 场景全绿，并随 **1.0.1 (41)** 上传 TestFlight。
> 下文"未提交 / 未获准"为提交前的历史记录。

状态：实现与截图供复核，未提交。旧布局位置断言尚未获准更新，不能标记门禁通过。本文不代表 T0–T9 全部完成。

## 用户本次要求

主宠放大，饭盆和水盆不与模型叠加；“访客”和“回家看看”在前侧，摆件退后，不抢主体。

## 改动文件

- `lib/ui/adaptive_layout.dart`：主宠画布放大；主宠尺度与背景摆件尺度分离；两位伙伴使用前侧空间，并继续避让摆件、宠物和实际操作栏。
- `lib/ui/yard_home_screen.dart`：八个固定摆件位退到后场，横屏两排横向错位，避开风铃与风向标的真实重叠；饭盆和水盆按裁切后的实际高度放在完整主宠画布下方，留 6 逻辑像素间距；保留各自素材比例。
- 本报告。未改玩法数值、资源文件、测试或工单之外的既有 T8 改动。

| 画布 | 原主宠宽 → 新宽（逻辑像素） |
|---|---:|
| iPhone 6.9 | 110 → 176 |
| iPhone 17e | 97.5 → 156 |
| iPad mini 竖 | 141.36 → 200.88 |
| iPad 13 竖 | 180 → 278.64 |
| iPad mini 横 | 119.04 → 193.44 |
| iPad 13 横 | 165.12 → 268.32 |

## 验证与审批边界

`flutter analyze`：0 issue。日志 `build/yard-animal-focus-2026-09-18/logs/analyze.log`。

`flutter test --no-pub test/ui/yard_home_layout_test.dart test/ui/adaptive_layout_test.dart`：旧规则失败。具体是两条主宠位置快照（原脚点 0.74/0.76）及“伙伴必须在主宠后面”断言。到访时八槽不移动、伙伴不叠主宠等现有检查仍保留。日志 `logs/widget-original-contract.log`。

`flutter test`：308 passed、3 skipped、3 failed。失败仍为上述三个旧布局位置断言，日志 `logs/flutter-test.log`。

`python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：FAIL，原单元布局断言失败，placements 在第一组 iPhone 6.9 的 `meadow-decor-only` 因旧前排规则失败并中止矩阵，不能算六组全量通过。日志 `logs/release-candidate.log`。其他静态、资源检查通过。

自动审批拒绝替换旧深度断言，理由是可能违反“不要改测试让它变绿”。因此原测试保持不变；另一次拟新增独立对照测试的请求也被拒绝，没有落盘。

待明确批准的范围仅为：

- 伙伴从“主宠后面”改为“主宠前侧”；
- 摆件槽 4/5 从强制前景改为后场，并增加不得侵入动物前景的上界；
- 更新被新构图取代的主宠位置快照；
- 新增两只盆不得重叠完整宠物画布的断言。

2.5% 重叠阈值、完整八槽、到访时位置不变、实际操作栏边界、51 个场景和六尺寸均不应删减。

## 截图

根目录：`build/yard-animal-focus-2026-09-18/review/`。均为实际 Flutter 渲染的 `full-player-decor-both-actors` 场景，主宠 + 鹿访客 + 兔回访 + 八槽摆件。

六组命令及退出码记录在 `build/yard-animal-focus-2026-09-18/review-results.json`。横屏显式传 `PETOPIA_VISUAL_LANDSCAPE=true` 及物理像素 EXPECTED_WIDTH/HEIGHT。当前只用于视觉复核，不冒充完整 51 场景门禁通过。

六张已全部生成并核对 PNG 物理尺寸：

| 配置 | PNG 物理像素 | 场景结果 |
|---|---:|---|
| iphone69-port | 1320×2868 | FAIL：旧前排深度规则 |
| iphone61-port | 1170×2532 | FAIL：旧前排深度规则 |
| ipadmini-port | 1488×2266 | FAIL：旧前排深度规则 |
| ipad13-port | 2064×2752 | FAIL：旧前排深度规则 |
| ipadmini-land | 2266×1488 | FAIL：旧前排深度规则 |
| ipad13-land | 2752×2064 | FAIL：旧前排深度规则 |

此代表场景的六组检查均未报告动物/摆件碰撞，但不能据此推断其余 50 场景已通过。原图 SHA256 在 `capture-manifest.json`；四竖屏拼图在 `contact-sheets/portrait.png`，两横屏拼图在 `contact-sheets/landscape.png`。

## 需要账号持有人手动做的事

无账号、证书或商店操作。

另外待用户决定：确认新版截图，并对上述旧位置断言与新要求之间的冲突作出明确授权；尚未批准。
