# Hearth & Tails 素材版权与来源登记

本登记覆盖当前商业发行包内的美术、音频和运行时衍生素材。代码与素材采用
不同许可：源代码使用根目录 `LICENSE` 中的 Apache-2.0；美术、音频及其运行时
副本使用根目录 `ASSET_LICENSE`。

## 权利边界

| 范围 | 来源与处理 | 第三方内容 | 发行依据 |
| --- | --- | --- | --- |
| `assets/art/` | 为 Hearth & Tails 定向生成，经人工筛选、重绘、抠图、构图、校色与 QA | 无刻意使用的图库、素材包、品牌、字体、商标或受保护角色 | 生成服务条款、人工创作与编辑成果、`ASSET_LICENSE` |
| `assets/runtime/` | 从项目母图转换出的移动端 WebP，不改变作品来源 | 无新增第三方内容 | 继承对应母图权利，母版和运行图哈希见发布清单 |
| `assets/audio/` | 项目脚本进行原创程序化合成与转码 | 无采样包、循环、参考音频或商业旋律 | 生成脚本、音频 provenance、`ASSET_LICENSE` |
| 字体与图标字体 | 未打包自定义字体；使用系统字体和 Flutter SDK Material Icons | Flutter SDK 内容 | Flutter SDK 许可证和 App 内 License 页面 |
| Flutter/Dart 依赖 | `pubspec.lock` 锁定的开源依赖 | 有 | 自动许可证审计、App 内 Flutter License 页面与 iOS `NOTICES.Z` |

## 生成式美术记录

- 账号控制人、使用入口、2026-08-22 可见的 OpenAI 条款版本与风险边界另见
  `docs/app-store/generative-art-account-and-terms-record.md`。该记录不保存登录凭据，
  账号/订阅证明由发布人在私有档案中保留。
- 当前美术批次通过 OpenAI 图像生成能力为本项目定向产生，之后经过人工选片、
  编辑、重构、抠图、动画帧整理、尺寸适配和视觉检查。
- 提示词和生产流程不使用在世艺术家姓名、商业游戏名、受保护角色名，也不要求
  复刻受版权保护的具体作品。
- 截至 2026-08-21，OpenAI
  [Terms of Use](https://openai.com/policies/terms-of-use/) 说明：在法律允许范围内，
  用户与 OpenAI 之间由用户保有输入权利并拥有输出，OpenAI 将其对输出可能拥有的
  权利转让给用户；条款同时说明输出可能不唯一，用户仍需负责内容及其使用。
- 上述条款记录解决的是用户与服务提供方之间的权利分配，不代表任何司法辖区必然
  承认纯生成内容的版权。Hearth & Tails 的权利主张还包括人工选择、修改、组合、色彩、
  布局、动画处理和整套素材编排。
- `assets/art/support/` 的点心、暖灯、花篮、守护者徽章和特别明信片同属上述
  Hearth & Tails 定向生成批次；运行时 WebP 位于 `assets/runtime/support/`，母版与
  运行图哈希由发布清单逐一关联。
- 2026-08-02 的 12 套院子昼夜重绘批次，仅以 Hearth & Tails 已有主题美术和
  `docs/art-review/theme-redesign/` 内经确认的控制样张作为视觉锚点；竖屏与
  iPad 4:3 均为本项目定向生成和人工选片、校色、适配的成果，不含第三方参考图、
  图库或素材包。运行时昼夜 WebP 与对应审核母版由发布清单逐一关联。
- 2026-08-02 的 App Icon 重绘以 Hearth & Tails 自有橘猫 Stage A 立绘和旧版图标作为
  角色与色彩参考，为本项目定向生成；未使用第三方角色、品牌、字体、图库或素材包。
  经人工构图审核、小尺寸清晰度处理和平台尺寸适配后，母图保存在
  `docs/art-sources/app-icon/app_icon_master_2026-08-02.png`，iOS 与 Android
  图标由 `tools/make_app_icon.py` 确定性生成。
- 2026-08-10 的明信片姿势与访客修复批次仅参考 Hearth & Tails 自有物种原型、访客规格
  和 Golden Set。生成源图保存在
  `assets/art/qa/chroma_sources/postcard_pose_redo_20260810/` 与
  `assets/art/qa/chroma_sources/visitor_redo_20260810/`；其 README 记录生成工具、
  参考边界和派生范围。生产图经过人工选片、透明底提取、完整主体重构、安全边距
  校验和真实设备回归，不含第三方图库、角色、品牌、字体或外部参考图。
- 2026-08-10 的花箱与蘑菇凳修复批次仅以 Hearth & Tails 自有旧版摆件作为物件设定、
  视角与色彩参考，重新生成完整无残片的透明摆件。生成源图与说明保存在
  `assets/art/qa/chroma_sources/decor_redo_20260810/`，不含第三方图库、品牌、
  字体、角色或外部参考图。
- 2026-08-12 的互动 UI 批次包含喂食、摸头、玩具、洗澡四套手绘道具，七种
  明信片天气徽章，以及重新生成的邮差稻草人与星星风向标。视觉参考仅限
  Hearth & Tails 自有 Golden Set、既有宠物与摆件设定；生成源图、提示词边界和派生
  说明保存在 `assets/art/qa/chroma_sources/interaction_ui_20260812/`。该批次未
  使用第三方参考图、图库、贴图包、角色、品牌、Logo 或字体。
- 2026-08-13 的落地式风铃重绘仅参考 Hearth & Tails 自有院子摆件设定、Golden Set
  色彩和既有风铃物件描述。生成源图与派生说明保存在
  `assets/art/qa/chroma_sources/decor_redo_20260813/`；生产图经过人工选片、
  色键移除、边缘清理、完整支架与石基座保留以及透明画布适配，不含第三方
  参考图、图库、贴图包、角色、品牌、Logo 或字体。
- 2026-08-22 的支持礼物动画批次包含点心盒、暖灯和花束三条 8 帧手绘水彩序列。
  每条生产图均为 4096×512 无损 WebP 透明底，源图位于
  `assets/art/support-open/source/`，生产图位于 `assets/art/support-open/`，逐帧
  接触表、最终帧衔接图和透明边界验证位于 `assets/art/qa/support-open/`。该批次仅
  对齐 Hearth & Tails 自有支持页静态回礼与 Golden Set，不含第三方角色、品牌、
  字体、图库或外部参考图。
- 2026-08-22 的暖绒商店商品重绘批次包含 8 份特餐、4 件玩具和 4 款相册封面，
  共 16 份独立透明水彩母图。生成过程只使用项目自有 Golden Set 的色彩、媒介和
  完整边界约束，没有输入第三方图片、角色、品牌、Logo、字体、图库或艺术家姓名。
  母图与逐项 brief 位于 `assets/art/shop/products/source/`，带透明安全边的运行时
  WebP 位于 `assets/runtime/shop/products/`；商品数据逐项绑定独立文件，并由测试
  禁止回退到旧的几何占位图。
- 2026-08-22 的首页功能图标批次包含成长手账、相册、宠物图鉴、来客图鉴、成就、
  商店、院子布置与设置共 8 份透明水彩母图；只参考项目自有 Golden Set、既有 UI
  色板和功能语义，不含第三方图片、角色、品牌、Logo、字体、图库或艺术家姓名。
  母图与声明位于 `assets/art/source/home_menu/`，运行时图标位于 `assets/art/ui/`。
- 同日重新整理首页四个互动按钮，其中喂食、摸头与玩具沿用项目自有母图，洗澡盆
  重新定向生成并经过色键移除与边缘清理。生成源图、派生脚本和权利声明位于
  `assets/art/qa/chroma_sources/action_control_refresh_20260822/`、
  `assets/art/source/action_controls/` 与 `tools/build_action_control_icons.py`；未使用
  第三方图片、角色、品牌、Logo、字体、图库或艺术家姓名。
- 2026-08-23 将首页右上角早期扁平菜单占位图替换为透明水彩袖珍手账图标；生成只
  参考项目自有首页手账母图的媒介、色板与完成度，未输入第三方图片、品牌、Logo、
  字体、图库或艺术家姓名。母图为 `assets/art/source/home_menu/nav_menu_master.webp`，
  运行时衍生图为 `assets/art/ui/ui_icon_nav_menu.png`。
- 2026-08-23 将老朋友信物、院子主题、来客贴纸册与拆礼操作四处早期通用占位图
  替换为独立语义的透明奶油水彩图标。生成仅参考 Hearth & Tails 自有 Golden Set、
  UI 色板与功能描述，未输入第三方图片、角色、品牌、Logo、字体、图库或艺术家姓名。
  母图、运行时衍生关系和提示边界记录在
  `assets/art/source/ui_semantic_refresh/README.md`。

## 音频来源记录

- BGM 与过场音乐：
  `assets/audio/provenance/music_provenance_manifest.json`
- 2026-08-02 的暖绒商店 BGM 重制沿用 Hearth & Tails 程序化生成器中自有的院子和声与
  主主题动机，重新编配为毛毡钢琴、尼龙吉他、柔和木质点音和空气织体；未使用
  第三方采样、循环、参考录音、商业旋律或艺术家风格提示。WAV/OGG 分轨、运行时
  M4A、响度记录与哈希均由同一生成流程更新。
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
  音频 provenance、资产许可文件和第三方依赖许可证。
- `python3 tools/check_dependency_licenses.py` 已核验当前 124 个解析后的 Dart/Flutter
  包均有许可证文件且可归类；详细结果、字体盘点和剩余发布人确认见
  `docs/app-store/dependency-license-audit.md`。
- 如果后续加入任何第三方素材，必须先在本登记中写明权利人、许可、授权范围、
  到期日和来源，再更新发布清单；不得只用口头确认替代记录。

## 发布人确认

工程可以验证文件、来源声明和哈希闭环，但无法替代账号持有人的法律判断。提交
App Store 前，账号持有人仍需确认生成服务账户与条款适用于商业发行，并在内容版权
问卷中据实确认拥有或获准使用全部内容。

本登记是工程 provenance 和发行留档，不构成法律意见。
