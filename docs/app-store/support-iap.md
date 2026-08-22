# 暖绒小院自愿支持 IAP 上架配置

## 产品原则

- App 免费，主页不展示付费入口、价格、红点或限时促销。
- 入口仅位于“设置 > 小院的灯 > 支持小院”；支持完成后，手账会留下安静的感谢记录。
- 所有回礼均为装饰和情绪反馈，不改变成长速度、暖绒、冷却、稀有概率、图鉴、
  明信片、访客或任何可玩内容。
- 不使用订阅、随机付费、付费加速、付费宠物、限时折扣或外部支付链接。

## App Store Connect 商品

| Product ID | 类型 | 美国基准价 | 英文名称 | 简体中文名称 | 繁体中文名称 |
| --- | --- | ---: | --- | --- | --- |
| `com.petopia.petopia.support.treat` | Consumable | $0.99 | A Treat | 一份小点心 | 一份小點心 |
| `com.petopia.petopia.support.lantern` | Consumable | $2.99 | A Warm Lantern | 点亮一盏暖灯 | 點亮一盞暖燈 |
| `com.petopia.petopia.support.bouquet` | Consumable | $4.99 | Garden Bouquet | 送来一篮花 | 送來一籃花 |
| `com.petopia.petopia.support.guardian` | Non-Consumable | $6.99 | Garden Keeper | 小院守护者 | 小院守護者 |

其他国家和地区使用 App Store Connect 的等值价格，不在 App 内硬编码货币或
换算；界面始终显示 StoreKit 返回的本地价格。

## 回礼与恢复

| 商品 | 回礼 | 保存与恢复 |
| --- | --- | --- |
| 一份小点心 | 先成为待拆礼物；主动拆开后播放手绘动画，点心在院子停留 24 小时 | 未拆数量与有效期均在本地保存，可重复购买；消耗型商品不可恢复 |
| 点亮一盏暖灯 | 先成为待拆礼物；主动拆开后播放手绘动画，暖灯在院子点亮 24 小时 | 未拆数量与有效期均在本地保存，可重复购买；消耗型商品不可恢复 |
| 送来一篮花 | 先成为待拆礼物；主动拆开后播放手绘动画，花篮在院子盛开 7 天 | 未拆数量与有效期均在本地保存，可重复购买；消耗型商品不可恢复 |
| 小院守护者 | 永久纪念徽章、特别感谢明信片；每个本地自然日可免费点亮一盏持续 24 小时的暖灯 | 永久权益，可通过“恢复‘小院守护者’”恢复；每日免费点亮只在本机存档，不产生 StoreKit 交易 |

购买完成不会提前开始回礼时长；玩家主动拆开时才开始计时。重复拆开同一种固定时长
回礼时，从当前有效期末尾继续顺延。交易按 App Store
transaction ID 幂等处理；本地权益成功落盘后才完成交易，避免付款成功但回礼丢失。
本地只保存 Product ID、未拆数量、交易幂等键和回礼到期时间，不保存支付卡、Apple ID、
订单金额或商店账号信息。

## 商品描述

`A Treat`
: Open this decorative treat whenever you like; it then stays in the garden for 24 hours.

`A Warm Lantern`
: Open it whenever you like to light the garden lantern for 24 hours.

`Garden Bouquet`
: Open the bouquet whenever you like; its flowers then bloom in the garden for seven days.

`一份小点心`（简体中文）
: 随时拆开这份装饰点心；拆开后会在院子里展示24小时。

`一份小點心`（繁體中文）
: 隨時拆開這份裝飾點心；拆開後會在院子裡展示24小時。

`点亮一盏暖灯`（简体中文）
: 随时拆开并点亮装饰暖灯；拆开后会在小院里亮24小时。

`點亮一盞暖燈`（繁體中文）
: 隨時拆開並點亮裝飾暖燈；拆開後會在小院裡亮24小時。

`送来一篮花`（简体中文）
: 随时拆开这份装饰花篮；拆开后会在院子里展示七天。

`送來一籃花`（繁體中文）
: 隨時拆開這份裝飾花籃；拆開後會在院子裡展示七天。

`Garden Keeper`
: Includes a daily free 24-hour lantern, keepsake badge, and special letter.

`小院守护者`（简体中文）
: 每天可免费点亮一盏24小时暖灯，并永久解锁纪念徽章和特别来信。

`小院守護者`（繁體中文）
: 每天可免費點亮一盞24小時暖燈，並永久解鎖紀念徽章與特別來信。

中英繁三语描述已固化在 `ios/Runner/PetopiaSupport.storekit`。商品审核截图应使用
支持页完整界面，不使用 TestFlight 标记、占位价格或本地调试提示。

守护者每日免费点灯按设备本地日历日判断，只在玩家主动进入支持页时展示；不发送
通知、不显示入口红点、不记录连续天数，也不会对漏点日期作任何提醒或补偿。

> 提审前人工项：App Store Connect 不会从本地 `.storekit` 自动同步。账号持有人必须
> 手动将四个商品的英文、简中、繁中描述全部更新为本节文本。

## 审核与 Sandbox 验收

1. 四个商品与 App 版本一同提交审核，Product ID、类型和价格与本文件一致。
2. 使用 Sandbox Apple Account 分别验证购买成功、用户取消、网络失败和重复回调。
3. 删除并重装 App，确认只能恢复“小院守护者”，三个 Consumable 不会被恢复。
4. 验证购买前后宠物经验、暖绒余额、冷却、图鉴和概率数据完全不变。
5. 在 iPhone、iPad 11 英寸和 iPad 13 英寸检查价格完整显示、按钮可触达、
   拆礼动画和结果弹框无裁切、明信片保持 3:2 构图。

本地调试使用 `ios/Runner/PetopiaSupport.storekit`；该文件不会代替 App Store
Connect 商品创建与审核。
