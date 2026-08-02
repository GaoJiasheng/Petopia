# App Store Connect 发布审计（2026-08-02）

本记录来自 App Store Connect API 的写入后反向读取。API 密钥、JWT 和私钥不写入
仓库。2026-08-01 的记录保留为历史快照。

## 正式版本

| 项目 | 已验证状态 |
| --- | --- |
| App | `Petopia: Letters from Home` / `com.petopia.petopia` / SKU `petopia001` |
| 版本 | iOS 1.0，手动发布，`READY_FOR_REVIEW` |
| 正式构建 | build 24，`VALID` / `APP_STORE_ELIGIBLE`，无非豁免加密，无内测入口 |
| 本地化 | English (U.S.) 与简体中文名称、描述、关键词、促销文本和 URL 已同步 |
| 分类 | Games；子分类 Casual、Simulation |
| 年龄分级 | 4+；无聊天、社交媒体或 UGC |
| 价格与地区 | 免费；173 个地区可用；中国大陆和越南未开放 |
| 截图 | iPhone 6.9 与 iPad 13 各 7 张，14 个资产均为 `COMPLETE` |
| 审核信息 | `2026 Gavin Gao`、联系人和英文审核说明已填写 |
| 公开页面 | 营销、隐私和支持 URL 均返回 HTTP 200 与 UTF-8 HTML |

build 22 因访客切换时动画组件可能保留上一位访客的已解码图像而停用。build 24
已修复资源热切换，并通过真实青蛙与小鹿访客素材之间的像素级组件回归测试。

## 内购与审核草稿

四项自愿支持商品均已配置英文与简体中文本地化、价格、地区和审核截图。App 1.0
与四个 IAP 仍位于同一个审核草稿；切换 build 24 后反向读取确认草稿恰好包含
1 个 App 与 4 个 IAP，五项均为 `READY_FOR_REVIEW`，尚未执行最终提交。

## TestFlight

| 项目 | 已验证状态 |
| --- | --- |
| 内测构建 | build 25，Apple 已验证，带编译隔离的 `+1` 日推进工具 |
| 内部测试组 | `test001`，1 位内部测试员，可访问 build 25 |
| TestFlight App 信息 | English (U.S.) 与简体中文描述、反馈邮箱、营销和隐私 URL 已填写 |
| 测试内容 | build 25 的中英文说明已填写，明确 `+1` 仅存在于内测构建 |

## 二进制门禁

- build 25：原生环境通道与 Dart `+1` 标记均存在，供内部测试；Apple Build ID
  `3aba2ccf-a91a-49b3-80ff-9da1b91d3362`。
- build 24：原生环境通道与 Dart `+1` 标记均不存在，签名验证通过。
- 两个构建均声明 `ITSAppUsesNonExemptEncryption=false`。

## 保留给账号持有人

- Apple Developer Program、Paid Applications Agreement、税务和银行状态确认。
- EU Digital Services Act trader / non-trader 法律身份声明。
- 生成式美术、字体、音频和第三方依赖商业发行权的最终主体确认。
- build 25 真机连续跨日、Sandbox 购买、真实 iPhone/iPad 性能验收，以及最终点击
  “提交审核”。
