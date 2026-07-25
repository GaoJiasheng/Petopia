# Petopia App Store 发布清单

账号持有人必须完成的项目见
[`owner-todo.md`](owner-todo.md)。

## 自动门禁

- [x] `python3 tools/check_release_candidate.py`
- [x] `flutter build ios --release --no-codesign`
- [x] 30 / 180 / 365 天固定种子仿真逐日保存并重载，覆盖 12 物种成长、
      毕业、访客、回访、事件、40 地点旅程和成就推进
- [x] 10,000 张明信片生成仿真：240 骨架、60 遭遇、60 碰撞全部可达，
      无占位符和地点文案错配
- [x] 参数化/隐藏成就逐条件契约测试，所有条件参数均有显式判定器
- [x] 检查产物中存在 `PrivacyInfo.xcprivacy`
- [x] 2026-07-25 device Release `Runner.app` 为 198.3 MB
      （约 189.1 MiB）；本地 ZIP 压缩估算为 171.7 MiB，
      低于当前 200 MiB 首包目标（最终商店下载体积以 App Store Connect
      thinning 报告为准）
- [ ] 真机安装并完成首次领养、四个互动、后台恢复、存档导入导出
- [x] iPhone/iPad 竖横屏、3.2 倍自动化字号与 iOS 最大辅助字号无溢出；
      相册、旅行详情、宠物/来客图鉴、来客回忆、成就、商店、设置与到信弹框
      均纳入门禁
- [x] 424 个运行时透明素材 / 900 帧无触边裁切，19 个 App Icon 均为不透明
      正确尺寸
- [x] 设置页可导出隐私安全诊断信息，不含昵称、明信片正文或设备标识
- [x] iPhone、iPad Pro 11/13 英寸关键状态、12 套主题与豪华度 1–6
      已完成模拟器截图复核
- [ ] 在物理 iPhone/iPad 上运行 Profile 帧时序与内存采样；Flutter iOS
      模拟器不支持 Profile AOT，不能用模拟器数据代替

## App Store Connect

- [ ] 填写简体中文名称、副标题、描述、关键词与促销文本
- [ ] 上传 iPhone 6.9 英寸和 iPad 13 英寸截图
- [ ] 配置主类别“游戏/休闲”与次类别“游戏/模拟”
- [x] 填写隐私政策 URL：`https://blog.gavingao.cn/petopia/privacy.html`
- [x] 填写包含真实联系方式的支持 URL：`https://blog.gavingao.cn/petopia/support.html`
- [ ] 完成 App Privacy 问卷，并与 Xcode Privacy Report 复核
- [ ] 完成年龄分级问卷
- [ ] 确认出口合规答案与 `ITSAppUsesNonExemptEncryption=false` 一致
- [ ] 填写版权主体与 App Review 联系人
- [ ] 粘贴 `review-notes-zh-Hans.md` 的审核说明

## 发布控制

- [x] 将 `pubspec.yaml` build number 提升为未使用的新值（当前 `16`）
- [x] 2026-07-25 创建 `1.0.0 (16)` Release archive，Validate 后上传
      TestFlight；Delivery UUID `407ad891-403b-44a8-ab2b-6e7ec2bf9bbc`，
      Apple 状态为 `VALID` / `APP_STORE_ELIGIBLE`
- [ ] 完成至少一次 iPhone 与 iPad 外部/内部测试
- [ ] 检查 TestFlight 崩溃、卡死、资源缺失和通知权限行为
- [ ] 选择手动发布或 7 天分阶段发布
