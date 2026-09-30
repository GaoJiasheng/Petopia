# 1.0.1 (42) App Store 提审记录

2026-09-30，用户批准最终院子截图后，授权直接提交 App Store 审核。

## 最终结果

- 版本：**1.0.1 (42)**，正式 `app-store` 变体；包含 `1da4252` 的池塘、景深、比例与落点修正。
- 构建 ID / 上传 ID：`d531b8c6-5550-472e-b0f8-5ed1c6cbfabc`。
- Apple 构建状态：`VALID` / `APP_STORE_ELIGIBLE`；上传后处理 `COMPLETE`，0 errors、0 warnings。
- App Store 版本 ID：`e694a6ba-c12d-47b2-b75e-d599fce2720c`。
- 最终审核单：`9af1eb21-cbaf-4dc2-aa8f-6cf9d1bd2312`。
- 提交时间：2026-09-30 13:53:57 UTC（新加坡时间 21:53:57）。
- App 版本及审核单均反向读取确认为 **`WAITING_FOR_REVIEW`**，关联构建号确认为 **42**。
- 当前发布设置为 **`AFTER_APPROVAL`（审核通过后自动发布）**，沿用提交期间页面中的设置。

处理过程中页面曾将旧 build 41 提交到审核单 `b40d8600-d9ac-417e-9e4e-3c96f4152018`。
最终核对发现该包不含最新修正，因此在 build 42 完成后处理并确认可送审之后，撤回旧单、
关联 build 42，并创建上述新审核单重新提交。旧单最终为 `COMPLETE`；审核排队从新单开始。

## 本次发布文件

- `pubspec.yaml`：同步版本为 `1.0.1+42`。归档使用源码提交 `1da4252`，通过构建参数明确指定 build 42。
- `docs/app-store/release-1.0.1-build42-whats-new.json`：简中、繁中、英文更新说明；已同步 ASC 并逐项反向比对。
- `docs/app-store/review-notes-en-US.md`：审核路径指向顶部状态栏右端手账按钮及常驻「支持小院」卡片；已同步 ASC，保留原联系人。
- `docs/app-store/release-checklist.md`、`docs/app-store/owner-todo.md`：记录本次正式提审。
- 本报告。没有新增产品功能、调整玩法数值或修改测试。

三语各 14 张商店截图沿用已发布资料，共 **42 张，全部 `COMPLETE`**。

## 验证与构建

```bash
tools/build_ios_variants.sh app-store 42 --no-codesign
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa-build42 \
  -exportOptionsPlist build/ExportOptions-AppStore-42.plist \
  -allowProvisioningUpdates
python3 tools/check_release_candidate.py --require-ios-build
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist build/ExportOptions-AppStore-42-Upload.plist \
  -allowProvisioningUpdates
```

归档、签名导出、Apple 上传均成功。使用 Xcode 现有账号签名，导出配置为
`app-store-connect`、`testFlightInternalTestingOnly=false`、禁止自动改写版本号。
正式包不传内测工具或模拟购买开关。最低 iOS 16.0，非豁免加密为 false。

发布门禁 **PASS**：`flutter analyze` 0 issue，`flutter test` 314 passed / 3 原有 skips；
真实 iOS 包体、美术、资源清单、依赖与内容检查全部通过。
其中 `tools/check_pet_art.py`、`tools/audit_runtime_art.py` 均 PASS。

六配置 placements 已在产品源码 `1da4252` 提交前完成：四竖屏及两横屏各 **51/51**，合计 **306/306**。
本次仅同步构建号及发布资料，未再改变院子代码或美术。
命令、截图及各配置结果见 [池塘最终复核报告](yard-pond-perspective-review-2026-09-30.md)。

本地签名 IPA：`build/ios/ipa-build42/Hearth & Tails.ipa`，161.55 MiB；SHA-256：
`368d473d2515b396b26e7760aac436918f12a3084dd4aa1099ddc10eda2b6fb0`。
已读取包内版本号为 1.0.1 / 42，并确认池塘 WebP 与批准的源资源哈希一致。

日志及证据（本地 `build/`，未包含凭据）：

- `app-store-1.0.1-build42.log`：正式归档。
- `app-store-build42-export.log`、`app-store-build42-upload.log`：签名导出和上传成功。
- `app-store-build42-release-check.log`：最终完整发布门禁。
- `app-store-build42-release-evidence.json`：构建、版本、提交与反向核对摘要。
- `app-store-build42-processed.json`、`app-store-build42-final-version.json`、`app-store-build42-final-submission.json`：Apple 最终状态。
- `app-store-build42-screenshots-{en-US,zh-Hans,zh-Hant}.json`：截图资产状态。
- `yard-pond-perspective-2026-09-30/final/`：六个分辨率最终复核截图及 placements 结果。

## 需要账号持有人手动做的事

当前没有必须手动完成的步骤。版本已进入审核队列，审核通过后自动发布；
如果 Apple 后续要求补充信息，届时需要处理审核反馈。这尚未发生，不标为已完成。
