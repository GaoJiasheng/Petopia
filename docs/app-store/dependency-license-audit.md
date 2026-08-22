# Hearth & Tails 商业版权与依赖许可证审计

审计日期：2026-08-21

本文件记录当前 iOS 商业发行候选中美术、音频、字体和第三方代码的工程侧权利
证据。它用于发版留档，不替代律师意见或账号持有人的事实声明。

## 结论

- **美术**：当前发布清单中的美术为 Hearth & Tails 定向生成和人工编辑成果；仓库声明
  未引入图库、素材包、第三方角色、品牌、Logo 或字体。母版、运行时衍生图、
  生成记录与 SHA-256 已闭环。
- **音频**：音乐、环境声、访客声音和 UI 音效由项目脚本原创程序化合成；三个
  provenance manifest 均声明没有第三方采样、循环、参考录音或商业旋律。
- **字体**：`assets/`、`ios/` 和 `android/` 中没有 `.ttf`、`.otf`、`.woff` 或
  `.woff2` 文件；`pubspec.yaml` 没有启用自定义 `fonts`。应用使用系统字体和
  Flutter 随 SDK 提供的 Material Icons，没有单独购买或再分发字体文件。
- **第三方依赖**：解析后的 124 个 Dart/Flutter 包均找到许可证文件并成功分类；
  未发现 GPL、AGPL、SSPL、无许可证或专有闭源包。应用设置页可打开 Flutter
  License 页面，iOS 产物也包含 `NOTICES.Z`。

工程侧结论为：**当前仓库未发现阻止 App Store 商业发行的素材或依赖许可证问题**。
账号持有人和适用条款已在 `generative-art-account-and-terms-record.md` 留档；发布人
也已确认没有在仓库之外手工替换过未登记素材。

## 开源依赖结果

`python3 tools/check_dependency_licenses.py` 对 `.dart_tool/package_config.json` 中
除应用自身外的全部解析包进行检查。当前结果：

| 许可证族 | 包数量 | 商业发行判断 |
| --- | ---: | --- |
| BSD-3-Clause | 92 | 允许，保留版权与免责声明 |
| MIT | 17 | 允许，保留许可证文本 |
| BSD-2-Clause | 7 | 允许，保留版权与免责声明 |
| Apache-2.0 | 6 | 允许，遵守通知与修改声明要求 |
| MPL-2.0 | 1 | 允许；仅 `dbus`，为 Linux 平台传递依赖，未修改其源文件 |
| Flutter SDK 组合许可通知 | 1 | `sky_engine` 的上游多许可证 notices，由 Flutter 打包展示 |

直接运行依赖包括 `audioplayers`、`file_selector`、
`flutter_local_notifications`、`flutter_riverpod`、`flutter_timezone`、
`in_app_purchase`、`package_info_plus`、`path_provider`、`share_plus`、
`sqflite`、`timezone`、`url_launcher` 和 `uuid`。这些直接依赖均为 MIT、BSD 或
Apache-2.0。iOS 插件 podspec 的许可证元数据与其包内许可证一致。

`dbus` 由 Linux 实现包传递引入，不链接进 iOS 原生二进制；Flutter 仍把完整依赖
通知放进应用的许可证清单。项目没有修改或单独分发 `dbus` 源文件，因此不存在需要
公开 Hearth & Tails 自有源代码的要求。

## 素材证据

- 总体权利登记：`docs/app-store/asset-rights-register.md`
- 美术来源声明：`assets/art/LICENSES.md`
- 音频来源声明：`assets/audio/LICENSES.md`
- 发布资产清单：`assets/provenance/release_asset_manifest.json`
- 音乐清单：`assets/audio/provenance/music_provenance_manifest.json`
- 音效清单：`assets/audio/provenance/sfx_provenance_manifest.json`
- 环境声/访客声音清单：
  `assets/audio/provenance/ambient_voc_provenance_manifest.json`
- 源代码许可：`LICENSE`（Apache-2.0）
- Hearth & Tails 素材许可：`ASSET_LICENSE`

截至审计日，OpenAI 的个人版
[Terms of Use](https://openai.com/policies/terms-of-use/) 与商业
[Services Agreement](https://openai.com/policies/services-agreement/) 均说明：在
适用法律允许范围内，用户/客户与 OpenAI 之间由用户/客户拥有输出，OpenAI 转让其
可能拥有的输出权利；同时输出可能不唯一，使用者仍负责输入权利、输出审查和实际
使用。该条款解决服务提供方与使用者之间的分配，不等于保证每一司法辖区都会承认
纯 AI 输出的版权，也不替代第三方近似性审查。

## 持续门禁

- `tools/check_dependency_licenses.py`：新增包无许可证、许可证无法分类或出现
  GPL/AGPL/SSPL 主许可证时失败。
- `tools/build_release_asset_manifest.py --check`：发布素材和哈希变化时失败。
- `tools/check_release_candidate.py`：已串联上述依赖与素材门禁。
- 新增任何外部美术、字体、音频、采样或闭源 SDK 前，必须先登记权利人、来源、
  许可文本、商业范围、地区、期限和署名要求。

## 发布人最终确认

- [x] 已保存生成美术账号控制人、使用入口与当时适用条款记录，见
      `generative-art-account-and-terms-record.md`；账号凭据不进入仓库。
- [x] Gavin Gao 于 2026-08-22 确认没有在仓库之外手工替换或注入未登记的美术、
      音频、字体或 SDK。
- [ ] 若未来加入广告、分析、归因或崩溃 SDK，先重新运行完整许可证和隐私审计。
