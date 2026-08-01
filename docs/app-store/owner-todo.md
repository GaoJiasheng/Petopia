# Petopia 上架前 Owner Todo

以下项目需要 Apple Developer / App Store Connect 账号持有人亲自确认。工程侧
自动化、素材审计、无签名 Release 构建和模拟器矩阵不重复列在这里。

## 提交前

- [ ] 在 App Store Connect 确认 `com.petopia.petopia` 对应的 App 记录、SKU、
      主语言和开发者显示名称均正确。
- [x] 完整双语 build `20` 已上传 App Store Connect，Apple 状态为 `VALID` /
      `APP_STORE_ELIGIBLE`；Delivery UUID
      `20a4bf3d-b830-45fe-b75f-13e205638a12`。
- [ ] 确认 Apple Developer Program 协议、税务与银行资料没有待处理项目。
- [ ] 在 App Store Connect 接受 Paid Applications Agreement，并确认税务与
      收款账户状态允许提交应用内购买。
- [ ] 最终确认生成式美术、原创程序化音效、字体和所有第三方依赖均拥有商业发行权。
- [ ] 确认 `Petopia：小院来信` 的产品名、商标与目标地区不存在不可接受的冲突。

## 商店资料

- [ ] 按 `metadata-zh-Hans.md` 填写名称、副标题、描述、关键词、分类和促销文本。
- [ ] 为英语地区按 `metadata-en-US.md` 填写独立的英文名称、副标题、描述、关键词
      和促销文本；不要依赖 App Store 自动翻译。
- [x] 已将 2026-07-27 版 `privacy-policy-zh-Hans.md` 同步到
      `https://blog.gavingao.cn/petopia/privacy.html`，确认公开页已说明
      StoreKit、自愿支持本地记录和永久权益恢复。
- [x] 已将 `privacy-policy-en.md`、`support-en.md` 与 `marketing-en.md` 的英文内容同步
      到隐私、支持和产品公开页，并在每页提供明确的中英文切换入口。
- [ ] 填写版权主体、App Review 联系人姓名、邮箱和可接听电话。
- [ ] 将 `screenshots/release/en-US/` 中已通过门禁的 iPhone 6.9 英寸与
      iPad 13 英寸最终截图上传到 App Store Connect。14 张成品已逐张确认无
      TestFlight 标记、调试信息、占位图、裁切、alpha 透明通道或过期文案。
- [ ] 选择首发国家/地区、免费价格档和手动发布或分阶段发布策略。
- [ ] 按 `support-iap.md` 创建 4 个应用内购买商品，补齐英文和简体中文本地化，
      上传审核截图，并把 4 个商品随首个 App 版本一起提交审核。

## 合规问卷

- [ ] 完成 App Privacy 问卷，并按当前实现复核“无账号、无广告、无第三方分析、
      数据仅保存在设备本地”；与 Xcode Privacy Report 逐项一致。
- [ ] 完成年龄分级问卷。
- [ ] 回答 2026 年年龄分级新增的社交媒体能力问题；本版本无聊天、公开资料、
      用户生成内容或联网社交。
- [ ] 出口合规选择与 `ITSAppUsesNonExemptEncryption=false` 保持一致。
- [ ] 在内容版权问题中确认拥有或获准使用 App 内全部内容。
- [ ] 完成 EU Digital Services Act trader / non-trader 声明；若作为 trader
      在欧盟发布，完成公开联系方式验证。
- [ ] 在 App Accessibility 中按真机结果填写 Larger Text、Reduced Motion
      等标签；只有全部常用任务均可完成时才声明 VoiceOver 或 Voice Control。

## 签名与人工验收

- [x] 使用 Cloud Managed Apple Distribution 签名创建 build 20 Archive，
      通过 Apple package/SPI analysis，并上传 TestFlight。
- [ ] 在保留进度的设备上先安装 TestFlight build 18 或 19，再覆盖安装 build 20，
      确认 schema 2 → 3 后宠物、货币、旅程、明信片、来客、成就和设置均保留。
- [ ] 在至少一台真实 iPhone 和一台真实 iPad 上走完：首次领养、四种互动、
      后台恢复、来客、明信片、存档导出与导入、横竖屏旋转。
- [ ] 使用 Sandbox Apple Account 分别验证 3 个消耗型支持、取消购买、弱网重试、
      “小院守护者”首次购买，以及卸载重装后的恢复购买。
- [ ] 按 `performance-budget.md` 在物理设备执行四互动 Profile 帧时序门禁，
      再用 Instruments 复核冷启动、院子待机、首次动作、事件弹框和旋转时的
      峰值内存与温度。
- [ ] TestFlight 连续使用至少 24 小时，检查崩溃、卡死、音频中断、通知权限、
      真实时间事件和资源缺失。
- [ ] 提交审核时为英文审核上下文粘贴 `review-notes-en-US.md`（中文团队可同时保留
      `review-notes-zh-Hans.md`），并确认隐私、支持、营销三个
      URL 仍可公开访问。
- [ ] 提交后监控 App Store Connect 崩溃报告与支持邮箱，准备首个修复版本的
      build number。
