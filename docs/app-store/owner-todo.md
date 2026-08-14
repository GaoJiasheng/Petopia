# Petopia 上架前 Owner Todo

以下项目需要 Apple Developer / App Store Connect 账号持有人亲自确认。工程侧
自动化、素材审计、无签名 Release 构建和模拟器矩阵不重复列在这里。

## 提交前

- [x] 已确认 App 记录为 `com.petopia.petopia`、SKU `petopia001`、主语言
      English (U.S.)，商店名称为 `Petopia: Letters from Home`。
- [x] build 30 为带 `+1` 的内部 TestFlight 工具包；build 24 为不含内测入口的
      正式包，Apple 状态为 `VALID` / `APP_STORE_ELIGIBLE`，且已关联 App 1.0。
- [ ] 确认 Apple Developer Program 协议、税务与银行资料没有待处理项目。
- [ ] 在 App Store Connect 接受 Paid Applications Agreement，并确认税务与
      收款账户状态允许提交应用内购买。
- [ ] 最终确认生成式美术、原创程序化音效、字体和所有第三方依赖均拥有商业发行权。
- [ ] 确认 `Petopia：小院来信` 的产品名、商标与目标地区不存在不可接受的冲突。

## 商店资料

- [x] 已按 `metadata-zh-Hans.md` 填写名称、副标题、描述、关键词、分类和促销文本。
- [x] 已为英语地区按 `metadata-en-US.md` 填写独立的英文名称、副标题、描述、关键词
      和促销文本；不要依赖 App Store 自动翻译。
- [x] 已将 2026-07-27 版 `privacy-policy-zh-Hans.md` 同步到
      `https://blog.gavingao.cn/petopia/privacy.html`，确认公开页已说明
      StoreKit、自愿支持本地记录和永久权益恢复。
- [x] 已将 `privacy-policy-en.md`、`support-en.md` 与 `marketing-en.md` 的英文内容同步
      到隐私、支持和产品公开页，并在每页提供明确的中英文切换入口。
- [x] 已填写版权主体 `2026 Gavin Gao`、App Review 联系人姓名、邮箱和电话。
- [x] 已将 `screenshots/release/en-US/` 中通过门禁的 iPhone 6.9 英寸与
      iPad 13 英寸最终截图上传到 App Store Connect。14 张成品已逐张确认无
      TestFlight 标记、调试信息、占位图、裁切、alpha 透明通道或过期文案。
- [x] 已选择免费价格、手动发布；当前开放 173 个地区，中国大陆和越南未开放。
- [x] 已按 `support-iap.md` 创建 4 个应用内购买商品，补齐英文和简体中文本地化、
      价格和审核截图，并把 4 个商品与 App 1.0 加入同一审核草稿。

## 合规问卷

- [ ] 完成 App Privacy 问卷，并按当前实现复核“无账号、无广告、无第三方分析、
      数据仅保存在设备本地”；与 Xcode Privacy Report 逐项一致。
- [x] 已完成年龄分级问卷，当前评级为 4+。
- [x] 已回答社交媒体能力问题；本版本无聊天、公开资料、
      用户生成内容或联网社交。
- [x] 出口合规选择与 `ITSAppUsesNonExemptEncryption=false` 保持一致；Apple
      已确认 build 24 的 `usesNonExemptEncryption=false`。
- [x] App Store Connect 内容版权字段已选择“不使用第三方内容”。
- [ ] 完成 EU Digital Services Act trader / non-trader 声明；若作为 trader
      在欧盟发布，完成公开联系方式验证。
- [ ] 在 App Accessibility 中按真机结果填写 Larger Text、Reduced Motion
      等标签；只有全部常用任务均可完成时才声明 VoiceOver 或 Voice Control。

## 签名与人工验收

- [x] 使用 Cloud Managed Apple Distribution 签名创建 build 24、25、26、27、28、29
      与 30 Archive，均通过 Apple 验证；build 30 为 `INTERNAL_ONLY` 并已进入内部测试，
      build 24 用于送审。
- [ ] 在保留进度的设备上先安装 TestFlight build 18、19 或 20，再覆盖安装 build 24，
      确认 schema 2 → 3 后宠物、货币、旅程、明信片、来客、成就和设置均保留。
- [ ] 在 TestFlight build 30 连续点击 `+1`，确认新来客弹窗、院子模型和来客图鉴
      始终为同一访客；build 21/22 不再作为验收或送审候选。
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
- [ ] 最终检查审核草稿中 App 1.0 与四个 IAP 共五项，并点击“提交审核”。当前
      五项均为 `READY_FOR_REVIEW`，尚未正式提交。
- [ ] 提交后监控 App Store Connect 崩溃报告与支持邮箱，准备首个修复版本的
      build number。
