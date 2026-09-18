# 视觉审计 P2 修复报告（持续更新）

起始产品基线：`dc0e2f9`，版本 `1.0.1+41`；后续工单规则修订至 `04896d1`。顺序：T0 → T5 → T9 → T8 → T3 → T4 → T1 → T2 → T6 → T7。仅已完成的条目标为 PASS；未开始的工单不代表已验收。

> 2026-09-14 院子后续：用户批准整体构图方案后，T0 追加修订及 T1/T2/T3 已实施并通过六配置门禁。最新文件、结果和截图见 [院子实施报告](yard-layout-implementation-2026-09-14.md)。下文 T1/T2/T3 和横屏 harness 的“未开始 / 未应用”为 9/3 历史记录。T4/T6/T7/T8 不因此视为完成。

## T0 — 完成

修改文件：

- `lib/ui/adaptive_layout.dart`：来客与回访者共用摆件避让；先下移、再内收，拥挤的小屏最后才适当缩小临时角色，并保留至少 48pt 点击区域。车道下界读取真实动作按钮矩形，删除固定的 140pt 高度估算。
- `lib/ui/yard_home_screen.dart`：测量喂食按钮在院子中的实际矩形（空院测量领养入口），读取已有摆件的裁切和显示尺寸供避让使用；到访前后玩家摆放不变。
- 经批准修订静态表：紧凑布局槽位 2 的 y：0.40 → 0.34，槽位 5 的尺寸单位：81 → 78；平板竖屏槽位 2 的 y：0.40 → 0.32。槽位 0/1、6/7 及横屏锚点不变。
- 本报告。没有修改玩法配置、资源或任何测试，包括 placements oracle。

验证结果：

- `flutter analyze`：**PASS，0 issue**（最终发布门禁内再次执行）。
- `flutter test`：**PASS，308 项通过、3 项跳过**（最终发布门禁内再次执行）。原有“来客/回访出现前后玩家摆件位置完全相同”测试通过。
- `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：**PASS: release candidate checks are green**。日志：`build/visual-audit-p2/T0/logs/release.log`。内部包含最窄 iPhone 的完整 placements，以及美术、依赖与资源清单等全部门禁；来客 160 帧与母版一致检查通过。
- 另外三台设备运行以下命令，全部退出码为 0；每台通过全部 51 个场景，没有使用场景过滤器。

```bash
flutter test integration_test/yard_home_visual_test.dart   -d 00701277-220E-4074-BCAF-245FE12A5253   --dart-define=PETOPIA_VISUAL_PLACEMENTS=true   --dart-define=PETOPIA_VISUAL_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T0/iphone69-port
flutter test integration_test/yard_home_visual_test.dart   -d 7759EEF5-F257-4C08-BBE0-600B320B724E   --dart-define=PETOPIA_VISUAL_PLACEMENTS=true   --dart-define=PETOPIA_VISUAL_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T0/ipadmini-port
flutter test integration_test/yard_home_visual_test.dart   -d ED7AC183-F9B7-4784-9DF3-C5394AB51952   --dart-define=PETOPIA_VISUAL_PLACEMENTS=true   --dart-define=PETOPIA_VISUAL_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T0/ipad13-port
```

| 配置 | 结果 | 截图目录 | 日志（T0/logs/ 下） |
| --- | --- | --- | --- |
| iPhone 6.9 英寸竖屏，1320×2868 | PASS，51 场景 | `T0/iphone69-port/` | `placements-iphone69-port.log` |
| iPhone 17e 竖屏，1170×2532 | PASS，51 场景 | `T0/iphone61-port/` | `release.log` |
| iPad mini 竖屏，1488×2266 | PASS，51 场景 | `T0/ipadmini-port/` | `placements-ipadmini-port.log` |
| iPad 13 英寸竖屏，2064×2752 | PASS，51 场景 | `T0/ipad13-port/` | `placements-ipad13-port.log` |

合计 **204 个场景全绿**。横屏按修订后的分级规则留给 T1，不作为 T0 放行条件。iPhone 17e 门禁截图由 `/tmp/petopia-placements-gate/` 复制归档，未替换截图内容。

截图根目录：`/Users/gavin/work/petopia/build/visual-audit-p2/`。所需左右车道证据：

- [iPhone 6.9 左车道](/Users/gavin/work/petopia/build/visual-audit-p2/T0/iphone69-port/yard-meadow-visitor-left.png)
- [iPhone 6.9 右车道](/Users/gavin/work/petopia/build/visual-audit-p2/T0/iphone69-port/yard-meadow-visitor-right.png)
- [iPad 13 竖屏左车道](/Users/gavin/work/petopia/build/visual-audit-p2/T0/ipad13-port/yard-meadow-visitor-left.png)
- [iPad 13 竖屏右车道](/Users/gavin/work/petopia/build/visual-audit-p2/T0/ipad13-port/yard-meadow-visitor-right.png)

![T0 左右车道复核接触表](/Users/gavin/work/petopia/build/visual-audit-p2/T0/contact-sheet.png)

接触表使用 `python3 tools/build_ui_audit_contact_sheet.py build/visual-audit-p2/T0/contact-sheet-source build/visual-audit-p2/T0/contact-sheet.png --columns 4` 生成。原始截图均保留。

提交按工单拆为 `fix(yard): T0a 来客/回访车道避让已放置摆件` 和 `fix(yard): T0b 紧凑/平板竖屏左列锚点间距`。T0a 提交为 `66389bb`，T0b 为 `ab33479`。以上门禁验证的是 T0a + T0b 的完整修复组合。

## T1 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T2 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T3 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T4 — 暂停，横屏证据与实际代码不符

产品文件尚未修改。`onboarding_screen.dart:108` 已对宽度 ≥820 且宽大于高的设备选择 wide 母图；实际横屏截图却仍走竖屏分支。独立诊断确认，现有 `EXPECTED_WIDTH/HEIGHT` 只改变绘制画布，未改变 `MediaQuery`：

```text
surface-only: constraints=1133×744, MediaQuery=744×1133, view=1488×2266
surface-and-view: constraints=1133×744, MediaQuery=1133×744, view=2266×1488
```

诊断命令：`flutter test integration_test/visual_size_probe_test.dart -d 7759EEF5-F257-4C08-BBE0-600B320B724E`，PASS。临时诊断文件已移除，原文和日志保留在 `build/visual-audit-p2/diagnostics/`（脚本原文另存）。只读检查 Flutter 当前 SDK 也确认 `MediaQueryData.fromView` 直接取 `view.physicalSize`。

拟议验证修复：两个现有视觉 harness 在显式 EXPECTED 尺寸时同时设置 `tester.view.physicalSize`，并在 teardown 恢复；不改 placements 场景、重叠算法或阈值。可审阅补丁：`build/visual-audit-p2/diagnostics/landscape-view-size.patch`。按“描述不符先停并报告”的要求，未应用补丁、未猜测修改 T4 产品代码。需先补正横屏验证并重拍，再判断 T4 实际剩余问题。

T5 已完成的四组截图中，iPad 横屏组须按补正后的 harness 重验；三台竖屏结果有效。T0/T9 的验收均为竖屏，不受此问题影响。

## T5 — 完成

修改文件：`lib/l10n/english_copy.dart`、本报告。英文列表日期统一为 `Seen M/d/yy`；详情“第一次见面”按工单目标显示四位年份 `First met: M/d/yyyy`（基线原为两位年份，已恢复）。中文源串及布局代码未改。

验证命令与结果：

- `python3 tools/check_release_candidate.py`（不带 `--placements-device`）：**PASS**。内部 `flutter analyze` 为 0 issue；`flutter test` 为 308 项通过、3 项跳过。日志：`build/visual-audit-p2/T5/logs/release.log`。
- `dart /tmp/petopia-t5-copy.dart`：实际输出 `Seen 7/21/26 / First met: 7/21/2026`；日志：`build/visual-audit-p2/T5/logs/copy-probe.log`。
- 以下 4 组完整英文界面套件 **全部 PASS**，共 122 张截图，无尺寸错误或 overflow。iPhone 17e 图鉴日期完整、无省略号；iPad 三档保持原有布局，统一短日期在各档均生效。

```bash
flutter test integration_test/english_ui_visual_test.dart -d E35A99F1-F6C1-4BF8-8EED-018CDDB93917 --dart-define=PETOPIA_VISUAL_LANGUAGE=en --dart-define=PETOPIA_CAPTURE_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/iphone61-port --dart-define=PETOPIA_CAPTURE_PREFIX=ui
flutter test integration_test/english_ui_visual_test.dart -d 7759EEF5-F257-4C08-BBE0-600B320B724E --dart-define=PETOPIA_VISUAL_LANGUAGE=en --dart-define=PETOPIA_CAPTURE_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/ipadmini-port --dart-define=PETOPIA_CAPTURE_PREFIX=ui
flutter test integration_test/english_ui_visual_test.dart -d ED7AC183-F9B7-4784-9DF3-C5394AB51952 --dart-define=PETOPIA_VISUAL_LANGUAGE=en --dart-define=PETOPIA_CAPTURE_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/ipad13-port --dart-define=PETOPIA_CAPTURE_PREFIX=ui
flutter test integration_test/english_ui_visual_test.dart -d ED7AC183-F9B7-4784-9DF3-C5394AB51952 --dart-define=PETOPIA_VISUAL_LANGUAGE=en --dart-define=PETOPIA_CAPTURE_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/ipad13-land --dart-define=PETOPIA_CAPTURE_PREFIX=ui --dart-define=PETOPIA_VISUAL_LANDSCAPE=true --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH=2752 --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT=2064
```

| 配置 | 物理像素 | 截图数 | 日志（T5/logs/ 下） |
| --- | --- | --- | --- |
| iphone61-port | 1170×2532 | 28 | `ui-en-iphone61-port.log` |
| ipadmini-port | 1488×2266 | 28 | `ui-en-ipadmini-port.log` |
| ipad13-port | 2064×2752 | 33 | `ui-en-ipad13-port.log` |
| ipad13-land | 2752×2064 | 33 | `ui-en-ipad13-land.log` |

复核截图根目录：`/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/`；每台保留 `ui-visitor-compendium.png` 与 `ui-visitor-compendium-bottom.png`。

[最窄 iPhone 图鉴截图](/Users/gavin/work/petopia/build/visual-audit-p2/T5/en/iphone61-port/ui-visitor-compendium.png)。

## T6 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T7 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T8 — 修复已写入，验证中

修改文件：`lib/ui/album_screen.dart`、`lib/l10n/english_copy.dart`。复用大树邮筒明信片，以 60% 透明度显示；少于两位旅行伙伴时显示中英说明，两位及以上隐藏。矮屏将插画上限从 600pt 缩至 480pt。

`python3 tools/check_release_candidate.py`（不带设备）：PASS；`flutter analyze` 0 issue、`flutter test` 308 项通过、3 项原有跳过。日志 `build/visual-audit-p2/T8/logs/release.log`。三语六配置截图尚未完成，不能提交。首轮截图归档于 `T8/first-pass/`；修正插画尺寸后重新复核。横屏 harness 的尺寸问题见 T4 条目。

## T9 — 完成

修改文件：`lib/ui/support_yard_screen.dart`、本报告。单列商品卡取消固定高度，正文按标题 → 描述 → 状态（如有）→ 按钮自然堆叠，间距为 8/10pt；卡片取文字与 104pt 商品图的较大高度，图片垂直居中。现有双列阈值实际为 760pt（工单写作 ≥600pt）；保持既有阈值、双列尺寸与间距，没有另改布局分档。

验证命令与结果：

- `python3 tools/check_release_candidate.py`（不带 `--placements-device`）：**PASS**；内含 `flutter analyze`：0 issue，`flutter test`：308 项通过、3 项原有跳过。日志：`build/visual-audit-p2/T9/logs/release.log`。
- 三语 × iPhone 6.9 / 17e / iPad mini 竖屏，共 9 组完整 `english_ui_visual_test` **全部 PASS**，252 张截图，所有尺寸正确、无 overflow。逐组完整命令和结果保存在 `build/visual-audit-p2/T9/ui-validation.json`。

```bash
flutter test integration_test/english_ui_visual_test.dart -d <下表 UDID> --dart-define=PETOPIA_VISUAL_LANGUAGE=<en|zh-Hans|zh-Hant> --dart-define=PETOPIA_CAPTURE_DIR=/Users/gavin/work/petopia/build/visual-audit-p2/T9/<语言>/<配置> --dart-define=PETOPIA_CAPTURE_PREFIX=ui
```

| 配置 | UDID | 物理像素 | en / zh-Hans / zh-Hant |
| --- | --- | --- | --- |
| iphone69-port | 00701277-220E-4074-BCAF-245FE12A5253 | 1320×2868 | PASS / PASS / PASS |
| iphone61-port | E35A99F1-F6C1-4BF8-8EED-018CDDB93917 | 1170×2532 | PASS / PASS / PASS |
| ipadmini-port | 7759EEF5-F257-4C08-BBE0-600B320B724E | 1488×2266 | PASS / PASS / PASS |

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/support_visual_test.dart -d 00701277-220E-4074-BCAF-245FE12A5253 --dart-define=PETOPIA_VISUAL_PREFIX=petopia-T9-support-20260903
```

以上 drive **PASS**，catalog / treat-arrived / treat-opening / guardian-unused / guardian-used / guardian-letter 六态通过，使用模拟交易数据。日志 `T9/logs/support-drive.log`，原始六态截图归档在 `T9/support-drive/`。

复核截图根目录：`/Users/gavin/work/petopia/build/visual-audit-p2/T9/`。三语三台各保留 `ui-support.png`、`ui-support-middle.png`、`ui-support-bottom.png`。

![T9 单列卡片复核](/Users/gavin/work/petopia/build/visual-audit-p2/T9/contact-sheet.png)

![T9 支持六态](/Users/gavin/work/petopia/build/visual-audit-p2/T9/support-drive-contact-sheet.png)

## 需要账号持有人手动做的事

目前没有需要账号持有人专属权限执行的操作。
