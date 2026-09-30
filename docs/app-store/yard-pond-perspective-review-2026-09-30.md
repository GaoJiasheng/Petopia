# T0h｜池塘地面透视修正（2026-09-30）

基线：`26ae740`。用户批准继续修正池塘，并要求完成后先自行 review，再提供实际截图。

## 修改文件

- `assets/art/world/decor/deco_pond_small_ground_v2.png`：使用内置 imagegen，以原池塘为编辑目标、上一版 iPad 13 横屏院子为相机视角参考，重绘较低视角的水平水面、前后石沿和直立水草。保留蓝绿色水、荷叶与水彩风格。原素材保留，新素材原生透明，不在运行时压扁整张图片。PNG 原稿不打包；实际加载 `deco_pond_small_ground_v2.webp`（480×240），等比缩小后无损编码并保留 alpha。
- `lib/ui/yard_art.dart`：将池塘映射到新素材，记录完整有效轮廓和水面占地中心。新轮廓高宽比约 0.428（包含直立水草），旧轮廓约 0.811。`DecorCrop.groundAnchorFraction` 默认仍为底边；池塘采用水面中心。
- `lib/ui/yard_home_screen.dart`：绘制位置与避让矩形使用同一地面中心；池塘透视尺度按该中心所在的地面深度计算。后排池塘中心定位修正为 0.06 的纵向偏移。未调整其他摆件和动物比例。
- `pubspec.yaml`、`assets/provenance/release_asset_manifest.json`：补齐新素材打包声明与校验清单。
- `tools/audit_runtime_art.py`：将新素材纳入现有审计。2:1 静态池塘不能按两帧动画切割，静态 decor 直接检查完整图片；没有降低透明边距、截断、剪影或 placements 碰撞阈值。
- `docs/art-review/pond-perspective-2026-09-30/prompt.txt`、`provenance.json`：记录内置生成工具、最终完整提示词、输入图、输出路径、尺寸与 SHA-256。

没有修改玩法数值、测试断言或版本。池塘地面中心固定，不随来客到访改变。

## 自行 review

草稿阶段已检查 iPhone 17e 和 iPad mini 横屏实际截图：

1. 水面沿地面水平展开，前后方向缩短，不再接近朝向镜头的圆形。
2. 水草保持直立；前后石沿重绘，没有用整张纵向压缩获得扁平形状。
3. 外沿草叶与背景草坪相接；前沿没有悬空平台或额外阴影椭圆。
4. 水面中心作为地面定位点，与素材顶部水草和前沿分开。
5. 主宠仍是主体，池塘没有压住主宠、凳子或其他摆件；最终六尺寸全量复核已完成；运行版两张横屏原图及四张竖屏代表图均已自审。

这是一套与现有插画匹配的美术透视，并非通过真实相机参数标定所得。

## 验证

- `flutter test --no-pub test/ui/yard_home_layout_test.dart test/ui/yard_art_test.dart`：28 passed、1 existing skip。
- `python3 tools/audit_runtime_art.py`：原稿阶段 PASS，470 cutout files / 946 frames；最终 WebP 阶段 PASS，471 cutout files / 947 frames，包含原稿和运行图。池塘按静态图片完整审计。
- `python3 tools/check_pet_art.py`：PASS。
- 首轮 PNG 的六组摆放全部通过，但发布门禁因 139.46 MiB 超出 138 MiB 资源上限而失败，未提交。日志保留在 `logs/release-png-budget.log`，该轮截图保留在 `png-review/`，不作为最终候选通过证据。运行素材改为 WebP 后，声明资源约 137.995 MiB；没有提高资源上限或压缩无关素材。
- 原稿和运行图的有效像素完整位于裁切范围内，透明边距核对记录在 `logs/pond-bounds.log`。
- `python3 tools/check_release_candidate.py --placements-device E35A99F1-F6C1-4BF8-8EED-018CDDB93917`：**PASS**。包含 `flutter analyze` 0 issue、`flutter test` 314 passed / 3 existing skips、美术审计和四竖两横各 51/51。

日志根目录：`build/yard-pond-perspective-2026-09-30/logs/`。

## 六组 placements 和截图

| 配置 | 物理像素 | 结果 |
|---|---:|---|
| iPhone 6.9 竖 | 1320×2868 | PASS 51/51 |
| iPhone 17e 竖 | 1170×2532 | PASS 51/51 |
| iPad mini 竖 | 1488×2266 | PASS 51/51 |
| iPad 13 竖 | 2064×2752 | PASS 51/51 |
| iPad mini 横 | 2266×1488 | PASS 51/51 |
| iPad 13 横 | 2752×2064 | PASS 51/51 |

横屏同时传入 `PETOPIA_VISUAL_LANDSCAPE=true` 和实际物理像素的 `PETOPIA_VISUAL_EXPECTED_WIDTH/HEIGHT`。最终图与各组完整命令已归档在 `build/yard-pond-perspective-2026-09-30/final/`。

六张代表场景原尺寸图：

- [iPhone 6.9 竖屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/iphone69-port/yard-full-player-decor-both-actors.png)
- [iPhone 17e 竖屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/iphone61-port/yard-full-player-decor-both-actors.png)
- [iPad mini 竖屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/ipadmini-port/yard-full-player-decor-both-actors.png)
- [iPad 13 竖屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/ipad13-port/yard-full-player-decor-both-actors.png)
- [iPad mini 横屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/ipadmini-land/yard-full-player-decor-both-actors.png)
- [iPad 13 横屏](/Users/gavin/work/petopia/build/yard-pond-perspective-2026-09-30/final/placements/ipad13-land/yard-full-player-decor-both-actors.png)

各组设备、完整命令及结果在 `final/placements-results.json`；306 张最终截图均验证物理尺寸，SHA-256 清单为 `capture-manifest.json`。自审联系表在 `contact-sheets/`。

## 需要账号持有人手动做的事

无。本轮没有上传或发布。
