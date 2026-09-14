# 院子排布实施与多尺寸复核 · 2026-09-14

本轮按用户对《院子排布截图分析与建议》的批准实施整体构图，扩展了原 T0 的静态锚点修改范围。玩家到访前后摆件位置不变的约束仍保留。版本维持 `1.0.1+41`，没有修改 `lib/config/game_config.dart`、毕业阈值、来客权重、收益或冷却。

本报告只记录此次院子实现；T4/T6/T7 和尚未验收完的 T8 不因此视为完成。

## T0 / 院子构图追加修订

文件：`lib/ui/yard_home_screen.dart`、`lib/ui/adaptive_layout.dart`、`test/ui/adaptive_layout_test.dart`、`test/ui/yard_home_layout_test.dart`。

- 保留完整八槽，0/2/6 与 1/3/7 形成两侧前后错落的小景，4/5 留在前景。竖屏后排底座下移至实际草地，避免麦田主题中摆件贴在围栏上。
- 手机主宠尺寸保持；平板竖屏主宠画布改为 270–340pt，iPad 13 从 288pt 增至 340pt。场景物件同时按高度限制放大幅度，避免风向标超过主宠。
- 池塘、花坛按可见宽度定尺寸；其他立件按高度和远近关系定尺寸。后排池塘从手机约 23pt / iPad 13 约 43pt 增至约 73pt / 115pt，保留透明边界之外的实际主体。
- 食盆和水碗采用主宠宽度的 25%，位置跟随主宠脚下；不再因为首个玩家摆件出现而切换尺寸规则。
- 来客 / 回访在主宠侧后方寻找可用位置，落脚点同时受主宠脚底和实际 `care_action_feed` 上沿约束；不再向动作栏方向无限下探。正常满摆件测试要求两名伙伴画布均至少达到主宠的 50%，并保持完整可点区域。
- 原有到访前后八件摆设矩形不变测试保留；新增六配置正常 / 最高摆件两种组合的物件间距、宠物间距、双角色景深、可辨认尺寸和动作栏间距检查。

后排池塘在六配置中约为食盆宽度的 1.30–1.54 倍，符合方案的 1.3–1.6 倍试排范围。`layout-metrics.json` 保存按可见裁切计算的尺寸。

## T1 / 横屏与截图画布

文件：上述布局文件、`integration_test/yard_home_visual_test.dart`、`integration_test/english_ui_visual_test.dart`、`tools/check_release_candidate.py`、新增 `tools/run_yard_visual_matrix.py`。

- 横屏场景比例按高度缩放；mini 横屏保留八槽，前景底座与动作栏留出空隙。
- 两个截图 harness 在设置逻辑画布时同步 `tester.view.physicalSize`，结束后恢复。院子截图额外断言 `MediaQuery` 与真实渲染区域一致。
- `--placements-device <booted iPhone UDID>` 现在自动检查四台指定机型均已启动，再顺序运行 4 竖 + 2 横。缺少设备、场景数量不符、尺寸不符或任何测试失败均返回失败。
- 横屏继续显式传物理像素宽高；不依赖 `setPreferredOrientations` 旋转模拟器。
- 没有修改 placements 的 51 个场景、玩家优先级 oracle、重叠比例、地面下界或动作栏间距阈值。豪华场景另加阶段可见性断言。

## T2 / 豪华阶段

文件：`lib/ui/yard_home_screen.dart`、`lib/ui/yard_art.dart`、`pubspec.yaml`、`integration_test/yard_home_visual_test.dart`、`test/ui/yard_home_layout_test.dart`、`tools/check_release_candidate.py`、`assets/provenance/release_asset_manifest.json`；新增 `tools/build_runtime_yard_decor.sh` 与四季树 `.webp`。

所有画布共用同一套空院阶段构图，逐步增加现有美术：

| 阶段 | 空院可见变化 |
| --- | --- |
| 1 | 信箱、花坛 |
| 2 | 增加迎宾铃 |
| 3 | 空闲后排 6 增加四季树 |
| 4 | 空闲后排 7 增加池塘 |
| 5 | 增加蘑菇凳 |
| 6 | 增加相册书架 |

玩家已有摆放时，只补未占用的后排 6/7；已在其他槽位放置池塘时不重复显示豪华池塘。四季树按主题映射春夏秋冬，八槽全满时豪华件完全让位。

四张原始 PNG 保留，运行资源用现有无损 WebP 参数导出。原横屏专用预设中已不再引用的拱门、通用树、阁楼与红邮箱从打包清单移除，原文件保留。清单同步到实际使用资源，并增加四张导出的逐像素无损检查；没有放宽 138 MiB 上限，最终包内资源为 **137.878 MiB**。

## T3 / 平板背景取景

文件：`lib/ui/yard_home_screen.dart`、`lib/ui/yard_art.dart`、`test/ui/yard_home_layout_test.dart`。

宽度 ≥600 的平板横竖屏统一选择已有 wide 背景，白天和夜间共用该选择。露营主题的帐篷尖在 wide 母图靠右，竖屏中心裁切仍会切掉，因此竖屏对此主题轻微右移取景，保留帐篷尖。

iPhone 背景资源与选择分支未改；本轮同时批准了摆件重排，因此整张院子截图会变化，不能宣称整屏与旧版逐像素相同。麦田红风筝仍有一部分位于固定顶部信息卡后方，这是界面遮挡，不是原竖版母图的上下裁切；该处保留在主题截图中供 review，没有移动信息卡或重画美术。

## 验证与截图

**PASS：4 竖 + 2 横，306 个 placements 场景全部通过。**

- `flutter analyze`：0 issue。
- `flutter test`：310 项通过，3 项原有跳过，无失败。
- `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：PASS。包含完整六配置 placements；日志 `build/yard-layout-implementation-2026-09-14/logs/release-verified.log`。
- `python3 tools/check_release_candidate.py`：PASS。最终静态复验日志 `logs/release-final-static.log`，包含最终主题树映射及全部分析 / 测试。
- `python3 tools/audit_runtime_art.py`、`python3 tools/check_pet_art.py`：在上述发布门禁内均 PASS；来客 160 帧母版一致检查通过。
- 十二主题 × 六配置：72 张截图全部 PASS，无 overflow 或尺寸错误。
- 豪华六阶段 × iPhone 6.9 / iPad 13 竖屏：12 张截图全部 PASS，各阶段实际道具数量和树 / 池塘可见性断言通过。

| PETOPIA_VISUAL_PLACEMENTS 配置 | 物理像素 | 场景 | 结果 |
| --- | --- | --- | --- |
| iPhone 6.9 竖 | 1320×2868 | 51/51 | PASS |
| iPhone 17e 竖 | 1170×2532 | 51/51 | PASS |
| iPad mini 竖 | 1488×2266 | 51/51 | PASS |
| iPad 13 竖 | 2064×2752 | 51/51 | PASS |
| iPad mini 横 | 2266×1488 | 51/51 | PASS |
| iPad 13 横 | 2752×2064 | 51/51 | PASS |

以上门禁验证的是本轮完整构图组合；提交按 T3 / T0c / T1 / T2 拆分，不改写原 T0a/T0b。最终 placements 从门禁目录原样归档到 `final-review/placements/`，306 张逐文件校验一致。

主要命令：

```bash
python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917
python3 tools/run_yard_visual_matrix.py --suite themes --output build/yard-layout-implementation-2026-09-14/final-review
python3 tools/run_yard_visual_matrix.py --suite luxury --configs iphone69-port ipad13-port --output build/yard-layout-implementation-2026-09-14/final-review
```

摆放门禁的每组设备、完整命令、退出码、逐张物理尺寸及日志路径均记录在 `placements-results.json`；主题与豪华截图的数量、像素和日志汇总在 `final-review/review-inventory.json`，各次实际调用另有 `*-results.json`。正式门禁中还执行 `flutter analyze`、`flutter test`、`tools/audit_runtime_art.py`、`tools/check_pet_art.py` 与原有全部资源/依赖检查。

过程中曾发现稻草人碰撞、mini 前景间距和新增资源体积问题，均修正后重验；没有以 known failure 放行。旧版布局中断的验证与草稿截图留在 `first-pass/`、`second-pass/`、`geometry-check/`、`review/` 供追溯，最终审阅以 `final-review/` 为准。

## 原尺寸截图入口

所有图片是模拟器运行截图，固定上午 10 点，使用同一只 B 阶橘猫和相同 fixture。日常与满摆件对照统一使用草地主题。

| 配置 | 物理像素 | 日常院子 | 八槽满摆件 | 八槽 + 来客 + 回访 |
| --- | --- | --- | --- | --- |
| iPhone 6.9 竖 | 1320×2868 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/iphone69-port/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone69-port/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone69-port/yard-full-player-decor-both-actors.png) |
| iPhone 17e 竖 | 1170×2532 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/iphone61-port/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone61-port/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone61-port/yard-full-player-decor-both-actors.png) |
| iPad mini 竖 | 1488×2266 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/ipadmini-port/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipadmini-port/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipadmini-port/yard-full-player-decor-both-actors.png) |
| iPad 13 竖 | 2064×2752 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/ipad13-port/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-port/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-port/yard-full-player-decor-both-actors.png) |
| iPad mini 横 | 2266×1488 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/ipadmini-land/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipadmini-land/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipadmini-land/yard-full-player-decor-both-actors.png) |
| iPad 13 横 | 2752×2064 | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/themes/ipad13-land/yard-theme-meadow.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-land/yard-full-player-decor.png) | [查看](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-land/yard-full-player-decor-both-actors.png) |

![四台竖屏满摆件与双角色](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/full-portrait.png)

![两台横屏满摆件与双角色](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/full-landscape.png)

[日常竖屏总览](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/daily-portrait.png) · [日常横屏总览](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/daily-landscape.png) · [改前 / 改后](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/before-after.png)

[T2：iPhone 六阶段](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/luxury-phone.png) · [T2：iPad 六阶段](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/luxury-ipad.png) · [T3：iPad 13 竖屏十二主题](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/contact-sheets/themes-ipad13.png)

T0 车道证据：[iPhone 左](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone69-port/yard-meadow-visitor-left.png) · [iPhone 右](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/iphone69-port/yard-meadow-visitor-right.png) · [iPad 13 左](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-port/yard-meadow-visitor-left.png) · [iPad 13 右](/Users/gavin/work/petopia/build/yard-layout-implementation-2026-09-14/final-review/placements/ipad13-port/yard-meadow-visitor-right.png)。

## 提交

| 工单 | 提交 | 内容 |
| --- | --- | --- |
| T3 | `c3fba51` | 平板背景与帐篷取景 |
| T0 追加 | `82fbe4a` | 两侧生活角、物件比例与来客景深 |
| T1 | `50d5e68` | 横屏八槽、画布同步与六配置门禁 |
| T2 | 随本报告提交 | 各画布豪华反馈、四季树无损资源及验收归档 |

## 需要账号持有人手动做的事

无。本轮没有需要账号专属权限的操作，也未上传商店、发布构建或修改线上资料。
