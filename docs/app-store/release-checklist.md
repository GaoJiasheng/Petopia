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

- [x] 按 `support-iap.md` 创建 4 个 IAP 商品；价格、本地化、商品类型、审核截图和
      Product ID 已与本地 StoreKit 配置核对，并与 App 1.0 一同加入审核草稿
- [ ] 使用 Sandbox Apple Account 在真机验证消耗型购买、取消/失败、幂等发放，
      以及“小院守护者”跨安装恢复
- [x] 按 `metadata-zh-Hans.md` 和 `metadata-en-US.md` 分别填写简体中文与英文名称、
      副标题、描述、关键词和促销文本
- [x] 上传 iPhone 6.9 英寸和 iPad 13 英寸截图；两组各 7 张，资产状态均为
      `COMPLETE`，顺序已经反向读取复核
- [x] 配置主类别“游戏”，主类别子分类为“休闲”和“模拟”
- [x] 填写隐私政策 URL：`https://blog.gavingao.cn/petopia/privacy.html`
- [x] 填写包含真实联系方式的支持 URL：`https://blog.gavingao.cn/petopia/support.html`
- [x] 已将 `privacy-policy-en.md`、`support-en.md` 和 `marketing-en.md` 同步到三个公开
      URL，并验证网页中英文切换、移动端排版和联系方式
- [ ] 完成 App Privacy 问卷，并与 Xcode Privacy Report 复核
- [x] 完成年龄分级问卷；当前评级为 4+，无聊天、社交媒体或 UGC
- [x] 确认出口合规答案与 `ITSAppUsesNonExemptEncryption=false` 一致；build 24
      已由 Apple 标记 `usesNonExemptEncryption=false`
- [x] 填写版权主体 `2026 Gavin Gao` 与 App Review 联系人
- [x] 粘贴 `review-notes-en-US.md` 的英文审核说明；需要中文上下文时附
      `review-notes-zh-Hans.md`
- [ ] 完成 EU Digital Services Act trader / non-trader 声明
- [ ] 按真机验收结果填写 Accessibility Nutrition Labels；未经完整验证的
      VoiceOver、Voice Control 或对比度能力不做超额声明
- [x] `screenshots/release/en-US/` 中 7 张 iPhone 6.9 英寸与 7 张 iPad
      13 英寸最终截图均为无 alpha PNG，并通过
      `python3 tools/check_app_store_screenshots.py --require-release-set docs/app-store/screenshots/release/en-US`

## 发布控制

- [x] 将 `pubspec.yaml` build number 提升为未使用的新值（当前 `30`）
- [x] 内测日推进工具已改为双重编译门禁：Dart 仅在
      `PETOPIA_TESTFLIGHT_TOOLS=true` 时保留入口，Swift 仅在
      `PETOPIA_TESTFLIGHT_TOOLS` 条件下注册 StoreKit 环境通道。普通 Release
      不生成按钮、不调用通道，也不能从控制器推进时间。
- [x] 使用 `tools/build_ios_variants.sh testflight-tools 30` 构建仅供内部
      TestFlight 的工具包；使用 `tools/build_ios_variants.sh app-store 24`
      构建无内测入口的送审包。build 24 已选为 App Store 审核版本；build 30
      仅对内部 TestFlight 组开放。
- [x] build 30 已上传并通过 Apple 验证；Delivery UUID
      `9e8112ef-7cd2-4e4a-93dc-a004533384ef`，状态 `VALID` / `INTERNAL_ONLY`，
      `usesNonExemptEncryption=false`，最低系统为 iOS 16.0。中英文测试说明已同步，
      内部测试组启用全部构建访问。该构建修复院子装饰悬空与篱笆贴附问题，使用
      可见底边落地、远近透视和动物动态让位，并通过 12 主题、三种设备、昼夜、
      四种院子状态共 288 张截图回归；同时保留仅限内测的 `+1` 日推进工具。
- [x] build 29 已上传并通过 Apple 验证；Delivery UUID
      `199e9018-10cc-4a05-a2f2-ad525eed7b4e`，状态 `VALID` / `INTERNAL_ONLY`，
      `usesNonExemptEncryption=false`，最低系统为 iOS 16.0。中英文测试说明已同步，
      内部测试组启用全部构建访问。该构建包含围绕主宠物的语义点位院子布局、
      最多 10 件装饰限制、访客与回访伙伴独立空间，以及仅限内测的 `+1` 日推进工具。
- [x] build 28 已上传并通过 Apple 验证；Delivery UUID
      `eee7800c-ecfa-473d-bf8e-a41bb8fc0294`，状态 `VALID` / `INTERNAL_ONLY`，
      `usesNonExemptEncryption=false`。中英文测试说明已同步，内部测试组启用
      全部构建访问。该构建包含完整四互动动画矩阵、明信片天气图标、装饰重绘与
      全素材裁切回归，并保留仅限内测的 `+1` 日推进工具。
- [x] build 27 已上传并通过 Apple 验证；Apple Build ID / Delivery UUID
      `f5ff91c5-34a7-440d-bfb2-9255ac3d074e`，状态 `VALID` /
      `APP_STORE_ELIGIBLE` / `IN_BETA_TESTING`。中英文测试说明已同步，内部测试组
      启用全部构建访问，非豁免加密为“否”。该构建包含完整素材裁切回归、全设备
      双语截图复核，并保留仅限内测的 `+1` 日推进工具。
- [x] build 26 已上传并通过 Apple 验证；Apple Build ID / Delivery UUID
      `c2b605b2-86cb-412b-af64-1a46f67db043`，状态 `VALID` /
      `APP_STORE_ELIGIBLE`。中英文测试说明已同步，内部测试组启用全部构建访问，
      非豁免加密为“否”。该构建包含访客、明信片姿态和院子装饰裁切修复。
- [x] build 25 已上传并通过 Apple 验证；Apple Build ID
      `3aba2ccf-a91a-49b3-80ff-9da1b91d3362`，已加入内部组 `test001`，
      中英文“测试内容”均已填写，非豁免加密为“否”
- [x] build 23 已上传并通过 Apple 验证；Delivery UUID
      `d53385db-45ac-4a8b-a374-88f347e9ee9c`，中英文 TestFlight App 说明与
      “测试内容”均已填写
- [x] build 24 已上传并通过 Apple 验证；Delivery UUID
      `bb9c85d0-6515-4e7e-9431-701b83853eb9`，状态 `VALID` /
      `APP_STORE_ELIGIBLE`，并已关联 App 1.0 审核草稿
- [x] build 21/22 已停用：它们的访客数据会正常跨日更新，但院子动画组件可能
      保留上一位访客的已解码图像；build 23/24 已修复资源切换并加入回归测试
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
- [ ] 从 TestFlight build 18、19 或 20 覆盖安装 build 24，验证 schema 2 → 3 升级
- [ ] 完成至少一次 iPhone 与 iPad 外部/内部测试
- [ ] 检查 TestFlight 崩溃、卡死、资源缺失和通知权限行为
- [ ] 在真机 TestFlight build 30 确认首页右上角出现 `+1` 日推进按钮，并验证
      连续跨日时来客弹窗与院子模型一致；在正式 build 24 确认按钮不存在且
      控制器执行能力被编译门禁关闭
- [x] 已选择手动发布

## 审核草稿

- [x] App 1.0 与 4 个 IAP 已加入同一审核草稿，五项均为
      `READY_FOR_REVIEW`
- [x] 发布方式为手动，首发免费；中国大陆和越南未开放，其余 173 个地区可用
- [ ] 账号持有人完成法律、税务、银行与 DSA 声明后，执行最终“提交审核”
