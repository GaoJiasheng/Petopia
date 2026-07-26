# Runtime Asset Pack

本文件记录 App 首包实际使用的移动端素材层。高质量母图继续保留在 `assets/art/`，运行时副本与显式打包清单只服务于安装包体积、解码速度和稳定性，不替代美术源文件。

## 交付结构

- `assets/runtime/pets/`：12 物种 × 5 配色 × 4 成长档，共 240 张静态透明
  立绘。App 打包像素无损 WebP；同目录 PNG 仅作为未打包母版，由
  `tools/build_runtime_pet_assets.sh` 可重复生成。
- `assets/runtime/pets/*/actions/`：12 物种 × 4 个互动动作，共 48 张透明
  无损 WebP 动作条；PNG 母图保留但不进入首包。
- `assets/runtime/postcards/poses/`：12 物种各 1 张 `gaze` 回退姿态，共 12 张
  透明无损 WebP；完整的 12 物种 × 8 姿态 PNG 母图仍保留在
  `assets/art/postcards/poses/`，但当前背包背影渲染路径不会加载其余 84 张。
- `assets/runtime/postcards/stickers/`：10 张事件贴纸与 60 张物种/配色旅行
  背影的透明无损 WebP；对应 PNG 母图保留在 `assets/art/postcards/stickers/`。
- `assets/art/postcards/backgrounds/*.jpg`：40 张明信片背景运行件；同名 PNG 保留为母图。
- `assets/art/world/themes/*_bg.webp`：12 张 `1290×2796` 竖屏院子主题
  高质量 WebP 运行件；由 `assets/art/world/exports_1290/themes/` 母版通过
  `tools/build_runtime_yard_themes.sh` 可重复生成。iPad 横屏使用
  `assets/runtime/yard/themes/wide/` 下的高质量 WebP；母图是单独重绘的
  `2732×2048` JPEG。
- `assets/audio/bgm/mix/m4a/`：10 首 48 kHz AAC-LC BGM，128 kbps，由 24-bit WAV 母带转制。
- `assets/audio/sting/m4a/`：15 个 48 kHz AAC-LC 提示音，192 kbps，由 WAV 母带转制。
- `pubspec.yaml`：显式列出实际运行件，避免 QA 总览、母图、拼版和未使用导出进入首包。

## 质量基线

- 宠物透明边缘必须保持完整，不裁耳朵、尾巴、阴影或动作极值。
- 全量 alpha 边界审计：240 张静态立绘最小透明安全边距 `51 px`；48 条动作图逐帧最小安全边距 `54 px`，无贴边或截断。
- 240 张静态立绘、48 张动作条、12 张明信片回退姿态、70 张贴纸、5 张
  豪华度增量层和 5 张院子氛围层均使用无损 WebP；发布门禁逐像素对比
  380 组运行件与 PNG 母图，不允许尺寸、alpha 或像素漂移。
- 明信片和 iPad 横屏主题使用质量 95 的不透明 WebP，竖屏主题使用
  `1290×2796` 高质量 WebP。发布门禁逐张校验尺寸、格式、透明通道和母版
  PSNR：明信片不低于 33 dB，横屏院子不低于 39 dB。
- 所有运行件由 Flutter `AssetImage` 直接解码，不在运行时转码母图；院子背景
  按当前窗口逻辑尺寸与设备像素密度设置解码宽度，并以母图宽度为上限，保证
  iPhone/iPad 全屏清晰度的同时避免 Split View 无意义占用峰值内存。
- iOS/Android 音频运行件统一使用原生支持的 M4A；OGG 和 WAV 继续保留为交付源，不进入首包。

## 当前规模

- 宠物运行件：288 个无损 WebP，36.40 MiB。
- 明信片背景运行件：40 个高质量 WebP，13.53 MiB。
- 院子主题及宽屏/豪华度/氛围运行件：34 个 WebP，37.54 MiB。
- 音频运行件：59 个文件，22.78 MiB。
- 明信片回退姿态与贴纸运行件：82 个无损 WebP，7.20 MiB。
- `pubspec.yaml` 声明的 688 个发布素材合计 133.79 MiB；自动门禁上限为
  138 MiB。与本轮瘦身前约 147 MiB 的声明素材相比减少约 13 MiB。
- 2026-07-25 build 16 iOS device Release 展开包：198.3 MB
  （约 189.1 MiB）。
- 2026-07-27 build 17 iOS device Release 候选包：169.1 MB
  （文件合计约 161.2 MiB）；本地 ZIP 压缩估算为 144.0 MiB。相比本轮前
  181.1 MB 的候选包再减少 12.0 MB，且 380 组透明运行件继续通过逐像素
  一致性检查。

每次增删素材都要先运行
`python3 tools/build_release_asset_manifest.py`，再执行
`python3 tools/check_release_candidate.py` 和 iOS Release 构建。构建后再运行
`python3 tools/check_release_candidate.py --skip-flutter --require-ios-build`。
发布清单会核对 `pubspec.yaml` 中所有运行文件、母版路径与 SHA-256，避免动态
路径漏包或素材被无记录替换。
