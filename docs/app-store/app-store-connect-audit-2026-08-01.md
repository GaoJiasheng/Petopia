# App Store Connect 发布审计（2026-08-01）

本记录来自 App Store Connect API 的写入后反向读取。API 密钥、JWT 和私钥不写入
仓库。

## 正式版本

| 项目 | 已验证状态 |
| --- | --- |
| App | `Petopia: Letters from Home` / `com.petopia.petopia` / SKU `petopia001` |
| 版本 | iOS 1.0，手动发布，`READY_FOR_REVIEW` |
| 正式构建 | build 22，`VALID` / `APP_STORE_ELIGIBLE`，无非豁免加密 |
| 本地化 | English (U.S.) 与简体中文名称、描述、关键词、促销文本和 URL 已同步 |
| 分类 | Games；子分类 Casual、Simulation |
| 年龄分级 | 4+；无聊天、社交媒体或 UGC |
| 价格与地区 | 免费；173 个地区可用；中国大陆和越南未开放 |
| 截图 | iPhone 6.9 与 iPad 13 各 7 张，14 个资产均为 `COMPLETE` |
| 审核信息 | `2026 Gavin Gao`、联系人和英文审核说明已填写 |
| 公开页面 | 营销、隐私和支持 URL 均返回 HTTP 200 与 UTF-8 HTML |

## 内购与审核草稿

四项自愿支持商品均已配置英文与简体中文本地化、价格、地区和审核截图：

| Product ID | 类型 | 美国基准价 | 审核状态 |
| --- | --- | ---: | --- |
| `com.petopia.petopia.support.treat` | Consumable | $0.99 | `READY_FOR_REVIEW` |
| `com.petopia.petopia.support.lantern` | Consumable | $2.99 | `READY_FOR_REVIEW` |
| `com.petopia.petopia.support.bouquet` | Consumable | $4.99 | `READY_FOR_REVIEW` |
| `com.petopia.petopia.support.guardian` | Non-Consumable | $6.99 | `READY_FOR_REVIEW` |

App 1.0 与四个 IAP 已加入同一个审核草稿。反向读取确认草稿恰好包含五项，五项均为
`READY_FOR_REVIEW`；尚未执行最终提交。

## TestFlight

| 项目 | 已验证状态 |
| --- | --- |
| 内测构建 | build 21，`VALID`，带编译隔离的 `+1` 日推进工具 |
| 内部测试组 | 1 个内部组，启用所有构建访问 |
| TestFlight App 信息 | English (U.S.) 与简体中文描述、反馈邮箱、营销和隐私 URL 已填写 |
| 测试内容 | build 21 的中英文说明已填写，明确 `+1` 仅存在于内测构建 |

## 保留给账号持有人

- Apple Developer Program、Paid Applications Agreement、税务和银行状态确认。
- EU Digital Services Act trader / non-trader 法律身份声明。
- 生成式美术、字体、音频和第三方依赖商业发行权的最终主体确认。
- 真机与 Sandbox 购买验收，以及最终点击“提交审核”。
