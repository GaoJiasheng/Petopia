# Petopia 自愿支持 IAP 上架配置

## 产品原则

- App 免费，主页不展示付费入口、价格、红点或限时促销。
- 入口仅位于“设置 > 小院的灯 > 支持小院”；支持完成后，手账会留下安静的感谢记录。
- 所有回礼均为装饰和情绪反馈，不改变成长速度、暖绒、冷却、稀有概率、图鉴、
  明信片、访客或任何可玩内容。
- 不使用订阅、随机付费、付费加速、付费宠物、限时折扣或外部支付链接。

## App Store Connect 商品

| Product ID | 类型 | 美国基准价 | 英文名称 | 简体中文名称 |
| --- | --- | ---: | --- | --- |
| `com.petopia.petopia.support.treat` | Consumable | $0.99 | A Treat | 一份小点心 |
| `com.petopia.petopia.support.lantern` | Consumable | $2.99 | A Warm Lantern | 点亮一盏暖灯 |
| `com.petopia.petopia.support.bouquet` | Consumable | $4.99 | Garden Bouquet | 送来一篮花 |
| `com.petopia.petopia.support.guardian` | Non-Consumable | $6.99 | Garden Keeper | 小院守护者 |

其他国家和地区使用 App Store Connect 的等值价格，不在 App 内硬编码货币或
换算；界面始终显示 StoreKit 返回的本地价格。

## 回礼与恢复

| 商品 | 回礼 | 保存与恢复 |
| --- | --- | --- |
| 一份小点心 | 当前宠物播放约 5 秒进食反馈；点心在院子停留 24 小时 | 本地保存，可重复购买；消耗型商品不可恢复 |
| 点亮一盏暖灯 | 暖灯在院子点亮 24 小时 | 本地保存，可重复购买；消耗型商品不可恢复 |
| 送来一篮花 | 花篮在院子盛开 7 天 | 本地保存，可重复购买；消耗型商品不可恢复 |
| 小院守护者 | 永久徽章、永久暖灯、特别感谢明信片 | 永久权益，可通过“恢复‘小院守护者’”恢复 |

重复购买同一种固定时长回礼时，从当前有效期末尾继续顺延。交易按 App Store
transaction ID 幂等处理；本地权益成功落盘后才完成交易，避免付款成功但回礼丢失。
本地只保存 Product ID、交易幂等键和回礼到期时间，不保存支付卡、Apple ID、
订单金额或商店账号信息。

## 商品描述

`A Treat`
: A decorative treat that stays in the garden for 24 hours.

`A Warm Lantern`
: Keeps the garden lantern glowing for 24 hours.

`Garden Bouquet`
: Flowers bloom in the yard for seven days.

`Garden Keeper`
: A permanent lantern, keepsake badge, and special letter.

简体中文描述已固化在 `ios/Runner/PetopiaSupport.storekit`。商品审核截图应使用
支持页完整界面，不使用 TestFlight 标记、占位价格或本地调试提示。

## 审核与 Sandbox 验收

1. 四个商品与 App 版本一同提交审核，Product ID、类型和价格与本文件一致。
2. 使用 Sandbox Apple Account 分别验证购买成功、用户取消、网络失败和重复回调。
3. 删除并重装 App，确认只能恢复“小院守护者”，三个 Consumable 不会被恢复。
4. 验证购买前后宠物经验、暖绒余额、冷却、图鉴和概率数据完全不变。
5. 在 iPhone、iPad 11 英寸和 iPad 13 英寸检查价格完整显示、按钮可触达、
   感谢弹框无裁切、明信片保持 3:2 构图。

本地调试使用 `ios/Runner/PetopiaSupport.storekit`；该文件不会代替 App Store
Connect 商品创建与审核。
