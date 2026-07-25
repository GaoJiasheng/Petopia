# Petopia 上架前 Owner Todo

以下项目需要 Apple Developer / App Store Connect 账号持有人亲自确认。工程侧
自动化、素材审计、无签名 Release 构建和模拟器矩阵不重复列在这里。

## 提交前

- [ ] 在 App Store Connect 确认 `com.petopia.petopia` 对应的 App 记录、SKU、
      主语言和开发者显示名称均正确。
- [ ] 确认 build `15` 尚未被 App Store Connect 使用；若已使用，提交前提升
      `pubspec.yaml` build number。
- [ ] 确认 Apple Developer Program 协议、税务与银行资料没有待处理项目。
- [ ] 最终确认生成式美术、原创程序化音效、字体和所有第三方依赖均拥有商业发行权。

## 商店资料

- [ ] 按 `metadata-zh-Hans.md` 填写名称、副标题、描述、关键词、分类和促销文本。
- [ ] 填写版权主体、App Review 联系人姓名、邮箱和可接听电话。
- [ ] 上传 iPhone 6.9 英寸与 iPad 13 英寸最终截图；逐张确认无 TestFlight
      标记、调试信息、占位图、裁切或过期文案。
- [ ] 选择首发国家/地区、免费价格档和手动发布或分阶段发布策略。

## 合规问卷

- [ ] 完成 App Privacy 问卷，并按当前实现复核“无账号、无广告、无第三方分析、
      数据仅保存在设备本地”；与 Xcode Privacy Report 逐项一致。
- [ ] 完成年龄分级问卷。
- [ ] 出口合规选择与 `ITSAppUsesNonExemptEncryption=false` 保持一致。
- [ ] 在内容版权问题中确认拥有或获准使用 App 内全部内容。

## 签名与人工验收

- [ ] 使用 Distribution 签名创建 Archive，先运行 Validate App，再上传
      TestFlight。
- [ ] 在至少一台真实 iPhone 和一台真实 iPad 上走完：首次领养、四种互动、
      后台恢复、来客、明信片、存档导出与导入、横竖屏旋转。
- [ ] 在物理设备执行
      `flutter drive --profile -d <device-id> --target=integration_test/yard_home_visual_test.dart --driver=test_driver/integration_test.dart`
      并用 Instruments 复核院子待机、互动动画和事件弹框的帧时序、峰值内存。
- [ ] TestFlight 连续使用至少 24 小时，检查崩溃、卡死、音频中断、通知权限、
      真实时间事件和资源缺失。
- [ ] 提交审核时粘贴 `review-notes-zh-Hans.md`，并确认隐私、支持、营销三个
      URL 仍可公开访问。
- [ ] 提交后监控 App Store Connect 崩溃报告与支持邮箱，准备首个修复版本的
      build number。
