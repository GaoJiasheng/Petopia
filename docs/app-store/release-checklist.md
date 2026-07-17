# Petopia App Store 发布清单

## 自动门禁

- [x] `python3 tools/check_release_candidate.py`
- [x] `flutter build ios --release --no-codesign`
- [x] 检查产物中存在 `PrivacyInfo.xcprivacy`
- [ ] 真机安装并完成首次领养、四个互动、后台恢复、存档导入导出
- [ ] iPhone/iPad 竖横屏与系统最大字号无溢出

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

- [x] 将 `pubspec.yaml` build number 提升为未使用的新值（当前 `14`）
- [ ] 创建 Release archive，Validate App 后上传 TestFlight
- [ ] 完成至少一次 iPhone 与 iPad 外部/内部测试
- [ ] 检查 TestFlight 崩溃、卡死、资源缺失和通知权限行为
- [ ] 选择手动发布或 7 天分阶段发布
