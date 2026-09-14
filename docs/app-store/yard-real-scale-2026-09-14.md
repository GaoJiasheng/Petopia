# 院子实物比例与纵深修订 · 2026-09-14

根据用户对上一版截图的反馈“按真实大小盘一下”“可以放远一点，不用非得聚一圈”，重新标定院子中的体量与远近关系。本轮延续 T0 / T1 / T2 的院子复核，替代上一份实施报告中的物件比例结论；不代表其余视觉工单已完成。

## T0 追加：体量和竖屏排布

文件：`lib/ui/adaptive_layout.dart`、`lib/ui/yard_home_screen.dart`、`test/ui/adaptive_layout_test.dart`、`test/ui/yard_home_layout_test.dart`。

- 主宠从近景展示尺寸缩小到院子里的动物尺度；毕业典礼继续使用原来的展示尺寸。
- 去掉每个槽位独立的放大系数，以及远处花箱 / 座椅的额外放大。所有摆件使用同一套体量参照和地面透视，保留原画比例。
- 四处远景位置分布在围栏前，中景沿中央偏侧与右侧展开，近景两处错开放在草地边缘。中央留下连续草地，物件与伙伴不再沿主宠外围排一圈。
- 来客可在整条侧边草地中向远处找空位；鹿、白鹭、狐狸区分大小，回访伙伴也与主宠错开前后距离。实际动作栏上沿和玩家摆件仍是避让边界。
- 到访前后不移动或隐藏玩家摆件，保留全部八槽。未修改任何玩法数值、经验、收益、概率、毕业条件或冷却。

以下数值是为现有童话插画选定的**造型参照**，用于统一比例，不是对素材的实物测量：

| 物件 | 同一距离下的体量参照 | 定尺寸方式 |
| --- | --- | --- |
| 坐姿宠物（含翘起的尾巴） | 约 50 cm | 主体高度，另保留原图透明边距 |
| 食盆 / 水碗 | 约 20 cm | 宽度 |
| 花箱、矮凳、庭院小灯 | 约 35 cm | 高度 |
| 小炉子 / 相册架 | 约 55 / 60 cm | 高度 |
| 木信箱 / 木指示牌 | 约 65 / 70 cm | 高度 |
| 落地风铃 / 风向标 | 约 90 cm | 高度 |
| 庭院稻草人 | 约 95 cm | 高度 |
| 小池塘 | 约 135 cm | 水池整体宽度 |
| 四季幼树 | 约 140 cm | 树体高度 |
| 小花坛 | 约 85 cm | 宽度 |

屏幕中的大小还取决于物件离视平线的距离。相同物件放在远景时可缩至近景的约四分之一；因此远处的凳子可以小，近处的风向标应当比猫高。池塘按地面宽度计算，主体宽度约为近处食盆的 2.8 倍（横屏约 3.2 倍）。

## T1 追加：横屏构图

文件：同上两份布局文件。

横屏沿更宽的草地展开：远景书架偏左、水池偏右，中景与前景错开横向位置，保留 mini 横屏动作栏前的间距。两台横屏都保留八槽。

截图继续显式传 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT` 的物理像素，横屏同时传 `PETOPIA_VISUAL_LANDSCAPE=true`。本轮没有修改截图 harness、placements 的 51 个场景、2.5% 重叠阈值、地面范围或动作栏间距规则。

## T2 追加：豪华阶段的物件落地

文件：`lib/ui/yard_home_screen.dart`。

树木、池塘与其他物件使用相同的体量和透视规则。空院阶段 2 的默认墙挂迎宾铃改用已有的落地风铃，避免木支架悬在草地上；阶段 3–6 仍依次增加四季树、池塘、蘑菇凳、相册书架。玩家摆件的优先级不变，没有新增或编辑美术文件。

## 验证

**最终 PASS：4 竖 + 2 横，306 个 placements 场景全部通过。**

| 命令 | 结果 |
| --- | --- |
| `flutter analyze` | 0 issue |
| `flutter test` | 311 项通过，3 项原有跳过，无失败 |
| `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917` | PASS，包含上述分析 / 测试及六配置 placements |
| `python3 tools/audit_runtime_art.py` | PASS，包含 160 帧来客与母版一致检查 |
| `python3 tools/check_pet_art.py` | PASS |
| `python3 tools/run_yard_visual_matrix.py --suite luxury --configs iphone69-port ipad13-port --output build/yard-real-scale-2026-09-14/final-review` | 两设备各 6/6，通过阶段差异及树 / 池塘可见性检查 |

美术检查随完整发布候选门禁执行；本轮美术文件没有改动。最终发布门禁日志：[release-candidate.log](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/logs/release-candidate.log)。

| PETOPIA_VISUAL_PLACEMENTS 配置 | 物理像素 | 场景数 | 结果 |
| --- | --- | --- | --- |
| iPhone 6.9 竖 | 1320×2868 | 51/51 | PASS |
| iPhone 17e 竖 | 1170×2532 | 51/51 | PASS |
| iPad mini 竖 | 1488×2266 | 51/51 | PASS |
| iPad 13 竖 | 2064×2752 | 51/51 | PASS |
| iPad mini 横 | 2266×1488 | 51/51 | PASS |
| iPad 13 横 | 2752×2064 | 51/51 | PASS |

六组均实际调用 `flutter test integration_test/yard_home_visual_test.dart -d <udid> --dart-define=PETOPIA_VISUAL_PLACEMENTS=true`，并传入对应物理像素 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT`；两组横屏另传 `PETOPIA_VISUAL_LANDSCAPE=true`。每组完整命令、UDID、退出码、图片尺寸及归档日志在 [placements-results.json](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements-results.json)。

本次体量、锚点、角色避让为一组院子追加修订，完整门禁验证最终组合。最终 306 张摆放截图与门禁产物逐文件校验一致；加上 12 张豪华阶段图，共归档 318 张。图片清单与 SHA-256 在 `final-review/capture-manifest.json`；最终 placements 对应的四份代码 / 测试文件指纹在 `verified-source-sha256.json`。中间构建冲突与视觉迭代的日志单独保留，最终验收以本节结果和 `final-review/` 为准。


现有布局检查全部保留。仅同步两条固定主宠位置的旧快照期望，并新增六画布脚底位置、最小可点尺寸及统一透视比例检查。`yard_home_layout_test.dart` 保留原有碰撞、到访位置不变、伙伴可辨认尺寸和动作栏间距检查，另增加摆件完整裁切范围不得碰到前景宠物或伙伴主体的严格检查，覆盖稻草人手臂、帽檐等外伸部位。

## 原尺寸截图与对照

固定上午 10 点、同一只 B 阶橘猫。以下每个入口均为对应设备的原生像素截图。

| 配置 | 八槽与双伙伴 | 高摆件 / 稻草人组合 |
| --- | --- | --- |
| iPhone 6.9 竖 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/iphone69-port/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/iphone69-port/yard-selected-decor-both-actors.png) |
| iPhone 17e 竖 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/iphone61-port/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/iphone61-port/yard-selected-decor-both-actors.png) |
| iPad mini 竖 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipadmini-port/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipadmini-port/yard-selected-decor-both-actors.png) |
| iPad 13 竖 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipad13-port/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipad13-port/yard-selected-decor-both-actors.png) |
| iPad mini 横 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipadmini-land/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipadmini-land/yard-selected-decor-both-actors.png) |
| iPad 13 横 | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipad13-land/yard-full-player-decor-both-actors.png) | [原图](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/final-review/placements/ipad13-land/yard-selected-decor-both-actors.png) |

![四台竖屏](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/contact-sheets/full-portrait.png)

![两台横屏](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/contact-sheets/full-landscape.png)

[上一版 / 本版对照](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/contact-sheets/before-after.png) · [手机豪华六阶段](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/contact-sheets/luxury-phone.png) · [iPad 豪华六阶段](/Users/gavin/work/petopia/build/yard-real-scale-2026-09-14/contact-sheets/luxury-ipad.png)

## 需要账号持有人手动做的事

无账号专属操作。本轮不涉及商店上传或线上发布。视觉方案仍交由用户通过截图 review。
