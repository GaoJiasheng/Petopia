# Hearth & Tails 生成式美术账号与条款留档

记录日期：2026-08-22

本文件为 App Store 商业发行保留生成服务使用记录。它不保存登录密码、API Key、
付款卡号或完整账单资料，也不替代律师意见。

## 账号与使用入口

- 账号控制人 / 项目发布人：**Gavin Gao**。
- 服务提供方：**OpenAI**。
- 本项目使用入口：Gavin Gao 登录的 Codex 桌面工作区中的 OpenAI 图像生成能力。
- 使用目的：为 `Hearth & Tails: Letters Home` 定向生成和编辑宠物、访客、院子、
  明信片、UI 道具及动画序列帧等美术素材。
- 仓库不保存 OpenAI 登录标识或凭据。发布人应在私有档案中保留可证明账号控制权和
  使用期间订阅关系的账单、订阅收据或账号页面截图；这些资料不得提交到公开仓库。
- 当前仓库无法独立证明该账号在每个生成批次使用的是个人方案还是 Business/API
  方案，因此同时留存下列两套官方条款入口，并以生成当日账号实际方案为准。

## 适用条款快照

检索日期均为 2026-08-22：

| 使用情形 | 官方文件 | 页面标注版本 | 与素材权利直接相关的要点 |
| --- | --- | --- | --- |
| ChatGPT、Codex 等个人服务 | [OpenAI Terms of Use](https://openai.com/policies/terms-of-use/) | Published / Effective: 2026-01-01 | 第 Content 节说明用户负责 Input/Output；在法律允许范围内，用户与 OpenAI 之间由用户拥有 Output，OpenAI 转让其可能拥有的权利；Output 可能不唯一，使用前仍需人工评估。 |
| API、ChatGPT Business / Enterprise 等商业或开发者服务 | [OpenAI Services Agreement](https://openai.com/policies/services-agreement/) | Updated: 2025-12-01；Effective: 2026-01-01 | 第 4.1–4.4 节说明客户与 OpenAI 之间由客户拥有 Output，OpenAI 转让其可能拥有的权利；客户负责 Input 权利和 Output 使用，Output 可能不唯一。 |

## 本项目的事实记录

- 当前发布素材的批次、母图、运行时衍生文件及 SHA-256 由
  `asset-rights-register.md`、`assets/art/LICENSES.md` 和
  `assets/provenance/release_asset_manifest.json` 共同记录。
- 生成提示没有刻意要求模仿在世艺术家、商业游戏、第三方角色、品牌、Logo 或具体
  受保护作品；生成结果经过人工选片、重绘、抠图、校色、构图、动画整理和设备 QA。
- 2026-08-22 的支持礼物动画批次包括点心盒、暖灯和花束三条 8 帧手绘水彩序列，
  源图位于 `assets/art/support-open/source/`，生产图位于
  `assets/art/support-open/`，验证图和逐帧数据位于
  `assets/art/qa/support-open/`；提交为 `9dd2b1a`。
- 2026-08-22 的暖绒商店商品批次包括 8 份特餐、4 件玩具和 4 款相册封面，
  通过同一 Codex 桌面工作区中的 OpenAI 图像生成能力定向生成。母图、逐项 brief
  和无外部参考声明位于 `assets/art/shop/products/source/README.md`，运行时衍生
  文件位于 `assets/runtime/shop/products/`。
- 2026-08-22 的 8 份首页功能图标与洗澡互动按钮也通过同一 Codex 桌面工作区中的
  OpenAI 图像生成能力定向生成。首页图标声明位于
  `assets/art/source/home_menu/README.md`；互动按钮的生成与派生记录位于
  `assets/art/qa/chroma_sources/action_control_refresh_20260822/README.md`。
- 2026-08-22，发布人确认当前仓库之外没有为本候选包手工注入或替换未登记的美术、
  音频、字体或 SDK。

## 风险边界

- OpenAI 条款解决 OpenAI 与使用者之间的权利分配，不保证纯生成内容在所有司法辖区
  都具备版权，也不保证 Output 不与第三方内容相似。
- Hearth & Tails 的发行依据同时包括人工选择、修改、组合、布局、动画处理、软件
  集成和完整素材编排；发布前仍由发布人对近似性、商标和第三方权利承担最终审核责任。
- 条款发生更新、改用其他生成服务或新增外部参考素材时，必须新增一条日期化记录，
  不得覆盖本次留档。

## 发布人确认

- [x] 账号控制人已确认为 Gavin Gao。
- [x] 已记录 2026-08-22 可见的官方条款版本与适用范围。
- [x] 已确认当前候选包没有仓库外未登记素材。
- [ ] 发布人在私有档案中保留账号/订阅凭证或账单截图（不得提交账号密码或密钥）。
