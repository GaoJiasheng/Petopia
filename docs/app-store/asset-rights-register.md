# Petopia 素材版权与来源登记

本登记覆盖当前商业发行包内的美术、音频和运行时衍生素材。代码与素材采用
不同许可：源代码使用根目录 `LICENSE` 中的 Apache-2.0；美术、音频及其运行时
副本使用根目录 `ASSET_LICENSE`。

## 权利边界

| 范围 | 来源与处理 | 第三方内容 | 发行依据 |
| --- | --- | --- | --- |
| `assets/art/` | 为 Petopia 定向生成，经人工筛选、重绘、抠图、构图、校色与 QA | 无刻意使用的图库、素材包、品牌、字体、商标或受保护角色 | 生成服务条款、人工创作与编辑成果、`ASSET_LICENSE` |
| `assets/runtime/` | 从项目母图转换出的移动端 WebP，不改变作品来源 | 无新增第三方内容 | 继承对应母图权利，母版和运行图哈希见发布清单 |
| `assets/audio/` | 项目脚本进行原创程序化合成与转码 | 无采样包、循环、参考音频或商业旋律 | 生成脚本、音频 provenance、`ASSET_LICENSE` |
| Flutter/Dart 依赖 | `pubspec.lock` 锁定的开源依赖 | 有 | App 内 Flutter License 页面展示依赖许可证 |

## 生成式美术记录

- 当前美术批次通过 OpenAI 图像生成能力为本项目定向产生，之后经过人工选片、
  编辑、重构、抠图、动画帧整理、尺寸适配和视觉检查。
- 提示词和生产流程不使用在世艺术家姓名、商业游戏名、受保护角色名，也不要求
  复刻受版权保护的具体作品。
- 截至 2026-07-27，OpenAI
  [Terms of Use](https://openai.com/policies/terms-of-use/) 说明：在法律允许范围内，
  用户与 OpenAI 之间由用户保有输入权利并拥有输出，OpenAI 将其对输出可能拥有的
  权利转让给用户；条款同时说明输出可能不唯一，用户仍需负责内容及其使用。
- 上述条款记录解决的是用户与服务提供方之间的权利分配，不代表任何司法辖区必然
  承认纯生成内容的版权。Petopia 的权利主张还包括人工选择、修改、组合、色彩、
  布局、动画处理和整套素材编排。
- `assets/art/support/` 的点心、暖灯、花篮、守护者徽章和特别明信片同属上述
  Petopia 定向生成批次；运行时 WebP 位于 `assets/runtime/support/`，母版与
  运行图哈希由发布清单逐一关联。

## 音频来源记录

- BGM 与过场音乐：
  `assets/audio/provenance/music_provenance_manifest.json`
- 互动与 UI 音效：
  `assets/audio/provenance/sfx_provenance_manifest.json`
- 环境声与访客声音：
  `assets/audio/provenance/ambient_voc_provenance_manifest.json`
- 三套生产声明均禁止第三方采样、素材包、商业旋律和艺术家模仿；运行时 M4A
  是声明母版的兼容转码。

## 发布清单与复核

- `assets/provenance/release_asset_manifest.json` 记录 `pubspec.yaml` 实际打包
  文件的 SHA-256、类型，以及可追溯时的母版路径与哈希。
- `python3 tools/build_release_asset_manifest.py --check` 验证清单未过期。
- `python3 tools/check_release_candidate.py` 同时验证运行图质量、母版一致性、
  音频 provenance 和资产许可文件。
- 如果后续加入任何第三方素材，必须先在本登记中写明权利人、许可、授权范围、
  到期日和来源，再更新发布清单；不得只用口头确认替代记录。

## 发布人确认

工程可以验证文件、来源声明和哈希闭环，但无法替代账号持有人的法律判断。提交
App Store 前，账号持有人仍需确认生成服务账户与条款适用于商业发行，并在内容版权
问卷中据实确认拥有或获准使用全部内容。

本登记是工程 provenance 和发行留档，不构成法律意见。
