# Petopia App Store 发布清单

账号持有人必须完成的项目见
[`owner-todo.md`](owner-todo.md)。

## 自动门禁

- [x] `python3 tools/check_release_candidate.py`
- [x] 英文叙事全集覆盖测试：40 地点、240 明信片模板、60 遭遇、60 碰撞、
      120 事件及全部分支、244 来客互动均无中文与未解析占位符
- [x] `flutter build ios --release --no-codesign`
- [x] 30 / 180 / 365 天固定种子仿真逐日保存并重载，覆盖 12 物种成长、
      毕业、访客、回访、事件、40 地点旅程和成就推进
- [x] 10,000 张明信片生成仿真：240 骨架、60 遭遇、60 碰撞全部可达，
      无占位符和地点文案错配
- [x] 参数化/隐藏成就逐条件契约测试，所有条件参数均有显式判定器
- [x] 检查产物中存在 `PrivacyInfo.xcprivacy`
- [x] 2026-08-01 build 20 App Store 签名归档成功，导出 IPA 为
      159.01 MiB，
      低于当前 200 MiB 首包目标（最终商店下载体积以 App Store Connect
      thinning 报告为准）
- [ ] 真机安装并完成首次领养、四个互动、后台恢复、存档导入导出
- [x] iPhone/iPad 竖横屏、3.2 倍自动化字号与 iOS 最大辅助字号无溢出；
      相册、旅行详情、宠物/来客图鉴、来客回忆、成就、商店、设置与到信弹框
      均纳入门禁
- [x] 母版与 340 个运行时透明素材 / 816 帧均通过主体占比、顶部/左右安全区、
      底部柔和阴影和逐帧基线门槛；380 组无损 WebP 与 PNG 母版逐像素一致，
      19 个 App Icon 均为不透明正确尺寸
- [x] 693 个实际打包素材已生成 SHA-256 发布清单并追溯母版/provenance；
      代码 Apache-2.0 与专有美术音频许可边界已分离
- [x] 声明素材从约 147 MiB 降至 135.66 MiB；宠物、动作、贴纸保持逐像素
      无损，只有不透明场景背景采用质量门禁下的高质量 WebP
- [x] 图片缓存按逻辑短边分档为手机 72 MiB、iPad 96 MiB；系统内存警告会
      取消动作预热并清理 live/keep-alive 图片缓存
- [x] 设置页可导出隐私安全诊断信息，不含昵称、明信片正文或设备标识
- [x] iPhone、iPad Pro 11/13 英寸关键状态、12 套主题与豪华度 1–6
      已完成模拟器截图复核
- [ ] 在物理 iPhone/iPad 上运行 Profile 帧时序与内存采样；Flutter iOS
      模拟器不支持 Profile AOT，不能用模拟器数据代替。执行步骤与阈值见
      `performance-budget.md`

## App Store Connect

- [ ] 按 `support-iap.md` 创建并提交 4 个 IAP 商品；确认价格、本地化、商品类型、
      审核截图和 Product ID 与本地 StoreKit 配置完全一致
- [ ] 使用 Sandbox Apple Account 在真机验证消耗型购买、取消/失败、幂等发放，
      以及“小院守护者”跨安装恢复
- [ ] 按 `metadata-zh-Hans.md` 和 `metadata-en-US.md` 分别填写简体中文与英文名称、
      副标题、描述、关键词和促销文本
- [ ] 上传 iPhone 6.9 英寸和 iPad 13 英寸截图
- [ ] 配置主类别“游戏/休闲”与次类别“游戏/模拟”
- [x] 填写隐私政策 URL：`https://blog.gavingao.cn/petopia/privacy.html`
- [x] 填写包含真实联系方式的支持 URL：`https://blog.gavingao.cn/petopia/support.html`
- [x] 已将 `privacy-policy-en.md`、`support-en.md` 和 `marketing-en.md` 同步到三个公开
      URL，并验证网页中英文切换、移动端排版和联系方式
- [ ] 完成 App Privacy 问卷，并与 Xcode Privacy Report 复核
- [ ] 完成年龄分级问卷
- [ ] 确认出口合规答案与 `ITSAppUsesNonExemptEncryption=false` 一致
- [ ] 填写版权主体与 App Review 联系人
- [ ] 粘贴 `review-notes-en-US.md` 的英文审核说明；需要中文上下文时附
      `review-notes-zh-Hans.md`
- [ ] 完成 EU Digital Services Act trader / non-trader 声明
- [ ] 按真机验收结果填写 Accessibility Nutrition Labels；未经完整验证的
      VoiceOver、Voice Control 或对比度能力不做超额声明
- [x] `screenshots/release/en-US/` 中 7 张 iPhone 6.9 英寸与 7 张 iPad
      13 英寸最终截图均为无 alpha PNG，并通过
      `python3 tools/check_app_store_screenshots.py --require-release-set docs/app-store/screenshots/release/en-US`

## 发布控制

- [x] 将 `pubspec.yaml` build number 提升为未使用的新值（当前 `22`）
- [x] 内测日推进工具已改为双重编译门禁：Dart 仅在
      `PETOPIA_TESTFLIGHT_TOOLS=true` 时保留入口，Swift 仅在
      `PETOPIA_TESTFLIGHT_TOOLS` 条件下注册 StoreKit 环境通道。普通 Release
      不生成按钮、不调用通道，也不能从控制器推进时间。
- [ ] 使用 `tools/build_ios_variants.sh testflight-tools 21` 构建仅供内部
      TestFlight 的工具包；使用 `tools/build_ios_variants.sh app-store 22`
      构建无内测入口的送审包。不得将 build 21 选为 App Store 审核版本。
- [x] 完整双语 build 20 已归档、通过 Apple 后处理验证并上传 TestFlight
- [x] 2026-07-25 创建 `1.0.0 (16)` Release archive，Validate 后上传
      TestFlight；Delivery UUID `407ad891-403b-44a8-ab2b-6e7ec2bf9bbc`，
      Apple 状态为 `VALID` / `APP_STORE_ELIGIBLE`
- [x] 2026-07-27 创建并上传 `1.0.0 (18)` App Store 签名归档；
      Delivery UUID `205eaf09-caab-4be9-9da2-f0d727966cc4`，上传过程
      零 errors、零 warnings，Apple 已接收并进入 `PROCESSING`
- [x] 2026-07-28 创建并上传 `1.0.0 (19)` App Store 签名归档；
      Delivery UUID `16298ef6-e96f-4cab-b091-8a5d22723188`，上传过程
      零 errors、零 warnings，Apple 状态为 `VALID` /
      `APP_STORE_ELIGIBLE`，并已进入 App Store Connect
- [x] 2026-08-01 创建并上传完整双语 `1.0.0 (20)` App Store 签名归档；
      Delivery UUID `20a4bf3d-b830-45fe-b75f-13e205638a12`，Apple 状态为
      `VALID` / `APP_STORE_ELIGIBLE`，`usesNonExemptEncryption=false`，
      并已进入 App Store Connect
- [ ] 从 TestFlight build 18 或 19 覆盖安装 build 20，验证 schema 2 → 3 升级
- [ ] 完成至少一次 iPhone 与 iPad 外部/内部测试
- [ ] 检查 TestFlight 崩溃、卡死、资源缺失和通知权限行为
- [ ] 在 TestFlight build 21 确认首页右上角出现 `+1` 日推进按钮；在正式
      build 22 确认按钮不存在且控制器执行能力被编译门禁关闭
- [ ] 选择手动发布或 7 天分阶段发布
