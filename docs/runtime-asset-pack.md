# Runtime Asset Pack

本文件记录 App 首包实际使用的移动端素材层。高质量母图继续保留在 `assets/art/`，运行时副本与显式打包清单只服务于安装包体积、解码速度和稳定性，不替代美术源文件。

## 交付结构

- `assets/runtime/pets/`：12 物种 × 5 配色 × 4 成长档，共 240 张静态透明立绘。
- `assets/runtime/pets/*/actions/`：12 物种 × 4 个互动动作，共 48 张透明
  无损 WebP 动作条；PNG 母图保留但不进入首包。
- `assets/art/postcards/backgrounds/*.jpg`：40 张明信片背景运行件；同名 PNG 保留为母图。
- `assets/art/world/themes/*_bg.jpg`：12 张院子主题背景运行件；同名 PNG 保留为母图。
- `assets/audio/bgm/mix/m4a/`：10 首 48 kHz AAC-LC BGM，128 kbps，由 24-bit WAV 母带转制。
- `assets/audio/sting/m4a/`：15 个 48 kHz AAC-LC 提示音，192 kbps，由 WAV 母带转制。
- `assets/art/postcards/stickers/`：首包精确收录 10 张事件贴纸与 60 张物种/配色旅行背影。
- `pubspec.yaml`：显式列出实际运行件，避免 QA 总览、母图、拼版和未使用导出进入首包。

## 质量基线

- 宠物透明边缘必须保持完整，不裁耳朵、尾巴、阴影或动作极值。
- 全量 alpha 边界审计：240 张静态立绘最小透明安全边距 `51 px`；48 条动作图逐帧最小安全边距 `54 px`，无贴边或截断。
- 静态立绘运行件与母图的代表性合成 SSIM 为 `0.9983`。
- 动作条运行件与母图的代表性合成 SSIM 为 `0.9916`。
- 48 张动作条、5 张豪华度增量层和 5 张院子氛围层均使用无损 WebP；
  发布门禁逐像素对比 58 组运行件与 PNG 母图，不允许尺寸、alpha 或像素漂移。
- 明信片和主题背景使用高质量 JPEG，保留完整像素尺寸与 4:4:4 色度信息。
- 所有运行件由 Flutter `AssetImage` 直接解码，不在运行时缩放或转码母图。
- iOS/Android 音频运行件统一使用原生支持的 M4A；OGG 和 WAV 继续保留为交付源，不进入首包。

## 当前规模

- 宠物运行件：288 个文件，约 43.1 MiB。
- 明信片背景运行件：40 个文件，约 16 MB。
- 院子主题及宽屏/豪华度/氛围运行件：约 33.5 MiB。
- 音频运行件：25 个文件，约 20 MB。
- 明信片贴纸运行件：70 个文件，约 9.7 MB。
- 2026-07-25 iOS device Release 展开包：198.3 MB（约 189.1 MiB）；
  其中 Flutter assets 约 163.8 MiB，本地 ZIP 约 171.7 MiB。

最终上架前每次增删素材都要重新执行 `flutter analyze`、`flutter test` 和 iOS 构建，并检查动态路径对应文件是否仍在 `pubspec.yaml` 中。
