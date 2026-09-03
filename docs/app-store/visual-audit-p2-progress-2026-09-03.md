# 视觉审计 P2 修复报告（持续更新）

起始产品基线：`dc0e2f9`，版本 `1.0.1+41`；后续工单规则修订至 `04896d1`。顺序：T0 → T5 → T9 → T8 → T3 → T4 → T1 → T2 → T6 → T7。仅已完成的条目标为 PASS；未开始的工单不代表已验收。

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

提交按工单拆为 `fix(yard): T0a 来客/回访车道避让已放置摆件` 和 `fix(yard): T0b 紧凑/平板竖屏左列锚点间距`。以上门禁验证的是 T0a + T0b 的完整修复组合。

## T1 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T2 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T3 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T4 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T5 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T6 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T7 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T8 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## T9 — 未开始

修改文件：无。验证命令：未运行。复核截图：未生成。

## 需要账号持有人手动做的事

目前没有需要账号持有人专属权限执行的操作。
