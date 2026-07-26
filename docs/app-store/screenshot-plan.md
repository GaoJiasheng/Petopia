# App Store 截图计划

## 交付尺寸

- iPhone 6.9 英寸竖屏：优先 `1320 × 2868`，同组保持一个尺寸。
- iPad 13 英寸竖屏：优先 `2064 × 2752`。
- iPad 13 英寸横屏：补充 `2752 × 2064`，用于展示双侧面板布局。
- 每个设备组准备 6 张，上传前保留无压缩 PNG 母图。

## iPhone 叙事顺序

1. 白天小院：成年宠物、院子摆件与今日来客同屏，突出核心陪伴场景。
2. 互动动作：选择辨识度最高的一帧，底部四个动作入口完整可见。
3. 成长详情：旅装形态、等级、成长进度与性格标签。
4. 明信片惊喜：大图优先的收信弹框，背景柔和虚化。
5. 相册：明信片瀑布流与旅行伙伴列表。
6. 收藏：宠物图鉴或来客图鉴，展示内容规模与水彩统一性。

## iPad 叙事顺序

1. 横屏院子：宠物居中、信息卡与动作面板分置两侧，不遮挡主体。
2. 竖屏明信片：插画占主导，正文清晰但不抢画面。
3. 横屏相册：多列明信片与旅行伙伴信息密度。
4. 竖屏图鉴：大尺寸宠物插画与收集状态。
5. 横屏商店/布置：展示 iPad 响应式多列布局。
6. 竖屏成长手账：长期陪伴与记录感。

## 拍摄纪律

- 使用真实运行画面，不伪造尚未实现的功能。
- 状态栏时间、语言、宠物名和日期保持一致。
- 不出现 TestFlight 标记、调试横幅、加载占位、资源缺失图标或溢出警告。
- 第一张必须让宠物与水彩小院成为第一视觉，不用大段营销文字盖住画面。
- 同一设备组保持一致的亮度、主题和视觉安全区。
- 导出后执行
  `python3 tools/check_app_store_screenshots.py --require-release-set <截图目录>`；
  只有尺寸正确、无 alpha 通道、无方向缓冲黑边的 RGB PNG/JPEG 才可上传。

## 自动化方向门禁

使用院子视觉集成测试拍摄 iPad 13 英寸时，同时声明期望像素尺寸。截图缓冲区
方向不一致会直接让测试失败，不允许在后期拉伸补救：

```bash
# 竖屏 2064 × 2752
flutter drive -d <ipad-simulator> \
  --target=integration_test/yard_home_visual_test.dart \
  --driver=test_driver/integration_test.dart \
  --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH=2064 \
  --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT=2752

# 横屏 2752 × 2064；拍摄前先把模拟器旋转到横屏
flutter drive -d <ipad-simulator> \
  --target=integration_test/yard_home_visual_test.dart \
  --driver=test_driver/integration_test.dart \
  --dart-define=PETOPIA_VISUAL_LANDSCAPE=true \
  --dart-define=PETOPIA_VISUAL_EXPECTED_WIDTH=2752 \
  --dart-define=PETOPIA_VISUAL_EXPECTED_HEIGHT=2064
```
