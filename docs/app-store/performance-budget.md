# Hearth & Tails 真机性能门禁

性能结论必须来自 Profile 模式物理设备。iOS 模拟器不支持 AOT Profile，
不能用于首发性能签字。

## 冷启动

启动会在 Timeline 写入 `Petopia.firstInteractiveFrame`，参数
`elapsedMs` 从 Flutter 进程初始化计到院子首个可互动帧。每台签字设备至少
冷启动 5 次，丢弃第一次安装后的系统缓存异常值，记录其余结果：

- iPhone / iPad 中位数不超过 2.0 秒。
- P90 不超过 2.8 秒。
- 原生启动页到 Flutter 启动面不得闪黑、闪白或改变主体位置。
- 存档审计、备份恢复和每日推进仍属于首帧前硬门禁；通知重排可以在首帧后完成。

## 自动采样

在至少一台真实 iPhone 和一台真实 iPad 上执行。第一条覆盖首次领养后的静态
动作编排，第二条覆盖 Stage C 锚点宠物的四套 4096 × 512 手绘动作帧：

```bash
flutter drive --profile --no-dds -d <device-id> \
  --target=integration_test/app_store_smoke_test.dart \
  --driver=test_driver/integration_test.dart \
  --dart-define=PETOPIA_CAPTURE_PERFORMANCE=true

python3 tools/check_flutter_performance.py \
  build/integration_response_data.json

flutter drive --profile --no-dds -d <device-id> \
  --target=integration_test/yard_home_visual_test.dart \
  --driver=test_driver/integration_test.dart \
  --dart-define=PETOPIA_CAPTURE_PERFORMANCE=true

python3 tools/check_flutter_performance.py \
  --report-key=authored_care_interactions \
  build/integration_response_data.json
```

采样覆盖首次会话中的喂食、摸头、玩具和洗澡四个完整五秒动画。默认门禁：

- 至少采集 60 帧。
- Build / Raster 的 P90 不超过 16 ms。
- Build / Raster 的 P99 不超过 32 ms。
- 超过 16 ms 帧预算的比例各自不超过 5%。

高刷新率设备仍按以上 60 FPS 基线签字；120 FPS 表现作为锦上添花，不以牺牲
水彩画面完整度为代价。

## Instruments 人工采样

自动帧时序通过后，继续记录：

- 冷启动到院子可操作。
- 第一次触发每一种互动。
- 明信片、来客与特殊事件弹框的打开和关闭。
- iPad 横竖屏旋转和窗口尺寸变化。
- 院子连续停留 15–30 分钟后的峰值内存、回落情况、温度和音频状态。

出现持续掉帧、可见白屏、动作首次解码停顿、内存持续爬升或明显发热时，不得仅
通过放宽脚本阈值放行。
