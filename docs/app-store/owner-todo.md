# Hearth & Tails 上架前 Owner Todo

以下项目需要 Apple Developer / App Store Connect 账号持有人亲自确认。工程侧
自动化、素材审计、无签名 Release 构建和模拟器矩阵不重复列在这里。

## 提交前

- [x] 已确认 App 记录为 `com.petopia.petopia`、SKU `petopia001`、主语言
      English (U.S.)，商店名称为 `Hearth & Tails: Letters Home`。
- [x] build 32 为带 `+1` 的旧内部 TestFlight 工具包；build 35 为不含内测入口的
      已上传正式候选，Apple 状态为 `VALID` / `APP_STORE_ELIGIBLE`。本轮 S1/S2 完成后
      将上传新的带 `+1` 内部测试包，正式版编译条件仍不包含该入口。
- [x] 当前 `main` 已加入“今日故事”直达入口、繁体中文、主动邮件问题反馈及
      `Hearth & Tails` 品牌，并已通过 build 35 上传并关联 App 1.0。
- [ ] 确认 Apple Developer Program 协议、税务与银行资料没有待处理项目。
- [ ] 在 App Store Connect 接受 Paid Applications Agreement，并确认税务与
      收款账户状态允许提交应用内购买。
- [x] 工程侧已完成生成式美术、原创程序化音效、字体和 124 个 Flutter/Dart 依赖的
      商业版权/许可证审计，并把自动门禁接入发版检查；结果见
      `dependency-license-audit.md`。
- [x] 已将生成美术账号控制人、使用入口和 2026-08-22 可见的 OpenAI 条款版本记录在
      `generative-art-account-and-terms-record.md`；Gavin Gao 已确认当前候选包没有
      仓库外未登记素材。
- [x] 已停用高风险曾用名 `Petopia`，并完成 `Hearth & Tails` /
      `Hearth & Tails: Letters Home` 的第一轮商店和公开商标检索；未发现精确同名的
      在架宠物游戏，但这不是正式法律意见，详见 `trademark-clearance.md`。
- [x] Gavin Gao 已于 2026-08-22 阅读 `trademark-clearance.md` 并接受当前组合名称的
      剩余商业风险；App Store 允许建档仍不等于商标无冲突证明。专业清权可在扩大
      市场投放前另行完成。

## 商店资料

- [x] 已按 `metadata-zh-Hans.md` 填写名称、副标题、描述、关键词、分类和促销文本。
- [x] 已为英语地区按 `metadata-en-US.md` 填写独立的英文名称、副标题、描述、关键词
      和促销文本；不要依赖 App Store 自动翻译。
- [ ] **重新同步公开隐私页**：仓库内三语隐私稿已补充“未拆礼物数量”的本地保存说明；
      需把 2026-08-22 版本重新发布到
      `https://blog.gavingao.cn/petopia/privacy.html`，并检查三语切换入口。
- [x] 已将 `privacy-policy-en.md`、`support-en.md` 与 `marketing-en.md` 的英文内容同步
      到隐私、支持和产品公开页，并在每页提供明确的中英文切换入口。
- [x] 已填写版权主体 `2026 Gavin Gao`、App Review 联系人姓名、邮箱和电话。
- [x] 已将 `screenshots/release/en-US/` 中通过门禁的 iPhone 6.9 英寸与
      iPad 13 英寸最终截图上传到 App Store Connect。14 张成品已逐张确认无
      TestFlight 标记、调试信息、占位图、裁切、alpha 透明通道或过期文案。
- [ ] **补 zh-Hans 截图**（提审前必做）：当前 zh-Hans 本地化 0 张截图，简中
      设备用户（港澳台/新马/海外华人）的商店页正在 fallback 显示英文截图。
      按 `screenshot-plan.md` 用中文界面重拍 iPhone 6.9 英寸 + iPad 13 英寸
      两组（可用焕新后 12 套主题选最上相场景），过
      `tools/check_app_store_screenshots.py --require-release-set` 后上传。
- [x] App 内已支持 zh-Hant：台湾、香港、澳门设备会自动选择繁中，设置页也可手动
      切换；界面、叙事和本地通知均覆盖。繁中商店元数据、隐私与支持稿已归档为
      `metadata-zh-Hant.md`、`privacy-policy-zh-Hant.md` 与 `support-zh-Hant.md`。
- [x] 已在 App Store Connect 新增繁体中文本地化并同步 `metadata-zh-Hant.md`；
      公开隐私页也已加入繁中入口。繁中商店截图可随 1.0 一并补齐或作为 v1.x 优化。
- [x] 已选择免费价格、手动发布；当前开放 173 个地区，中国大陆和越南未开放。
- [x] 已按 `support-iap.md` 创建 4 个应用内购买商品，补齐英文和简体中文本地化、
      价格和审核截图，并把 4 个商品与 App 1.0 加入同一审核草稿。
- [ ] **在 ASC 更新四个 IAP 的三语商品描述**：本地 `.storekit` 不会自动同步。
      三个消耗型商品现在是“购买后成为待拆礼物，拆开才开始计时”；守护者现在是
      “每天可免费点亮一盏 24 小时暖灯”。英文、简中、繁中的最终文本逐条列在
      `support-iap.md` 的“商品描述”一节，四个商品都必须人工更新。

## 合规问卷

- [ ] 完成 App Privacy 问卷，并按当前实现复核“无账号、无广告、无第三方分析、
      数据仅保存在设备本地”；与 Xcode Privacy Report 逐项一致。
- [x] 已完成年龄分级问卷，当前评级为 4+。
- [x] 已回答社交媒体能力问题；本版本无聊天、公开资料、
      用户生成内容或联网社交。
- [x] 出口合规选择与 `ITSAppUsesNonExemptEncryption=false` 保持一致；Apple
      已确认 build 35 的 `usesNonExemptEncryption=false`。
- [x] App Store Connect 内容版权字段已选择“不使用第三方内容”。
- [ ] 完成 EU Digital Services Act trader / non-trader 声明；若作为 trader
      在欧盟发布，完成公开联系方式验证。
- [ ] 在 App Accessibility 中按真机结果填写 Larger Text、Reduced Motion
      等标签；只有全部常用任务均可完成时才声明 VoiceOver 或 Voice Control。

## 签名与人工验收

- [x] 使用 Cloud Managed Apple Distribution 签名创建 build 24、25、26、27、28、29、
      30、32、33、34 与 35 Archive；build 32 为 `INTERNAL_ONLY`，build 35 为当前已上传的
      无内测入口候选。
- [ ] 在保留进度的设备上先安装 TestFlight build 18、19 或 20，再覆盖安装本轮新上传的
      正式候选，确认 schema 2 → 3 后宠物、货币、旅程、明信片、来客、成就和设置均保留。
- [ ] 在 TestFlight build 32 连续点击 `+1`，确认新来客弹窗、院子模型和来客图鉴
      始终为同一访客；build 21/22 不再作为验收或送审候选。
- [ ] 在本轮带 `+1` 的 TestFlight 上验证 S1/S2：守护者每天只可免费点一盏灯；三个
      消耗型支持购买后均先显示为待拆礼物；拆开前不开始计时，拆开后分别播放点心盒、
      暖灯、花束的手绘序列并正确叠加有效期；开启“减少动态效果”后改为安静淡入。
- [ ] 使用保留旧支持记录的真机覆盖安装本轮 TestFlight，确认支持存档 schema 2 → 3
      后守护者、有效期和交易幂等记录均保留，未拆数量从 0 安全初始化。
- [ ] 在至少一台真实 iPhone 和一台真实 iPad 上走完：首次领养、四种互动、
      后台恢复、来客、明信片、存档导出与导入、横竖屏旋转。
- [ ] 使用 Sandbox Apple Account 分别验证 3 个消耗型支持、取消购买、弱网重试、
      “小院守护者”首次购买，以及卸载重装后的恢复购买。
- [ ] 按 `performance-budget.md` 在物理设备执行四互动 Profile 帧时序门禁，
      再用 Instruments 复核冷启动、院子待机、首次动作、事件弹框和旋转时的
      峰值内存与温度。
- [ ] TestFlight 连续使用至少 24 小时，检查崩溃、卡死、音频中断、通知权限、
      真实时间事件和资源缺失。
- [x] 英文审核说明已写入，隐私、支持、营销三个 URL 已填写；最终提交前仍需
      快速确认三个公开页可访问。
- [x] 设置页已接入问题反馈邮箱 `gaojiasheng.him@foxmail.com`：仅在用户主动操作时
      打开邮件并预填脱敏诊断摘要；无邮件 App 时回退系统分享，不后台上传数据。
- [ ] 最终检查审核草稿中 App 1.0 与四个 IAP 共五项，并点击“提交审核”。当前
      五项均为 `READY_FOR_REVIEW`，尚未正式提交。
- [ ] 提交后监控 App Store Connect 崩溃报告与支持邮箱，准备首个修复版本的
      build number。
