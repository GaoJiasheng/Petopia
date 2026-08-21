# v1.1 支持礼物自主拆开设计

状态：设计与资产准备完成后待 v1.1 实装。本文件不改变 1.0 运行逻辑。

## 目标与边界

- 点心、暖灯、花篮购买后先成为“待拆礼物”，玩家主动拆开时才开始计时。
- 拆礼是一次安静、可跳过等待但不催促的回礼时刻，不改变经验、暖绒、冷却、来客概率或稀有度。
- 不增加通知、红点、连续拆礼、过期提示或“还有礼物没拆”的催促。
- 小院仍由宠物主导；待拆礼物不得演变为新的常驻模块或装饰堆叠。

## 数据模型

在 `SupportBenefits` 增加三个非负整数：

```text
pendingTreat
pendingLantern
pendingBouquet
```

购买成功时只增加对应待拆数量，并记录交易去重信息；不得提前修改 `treatUntil`、`lanternUntil`、`bouquetUntil`。玩家确认拆开后，先原子地将对应数量减一，再复用现有 `_extend` 规则叠加有效期。

当前 S1 提交中的存档版本实际为 `version: 2`，因此直接实现时应升级为 `version: 3`，旧档缺失的三个数量按 0 处理。如果 v1.1 的其他迁移先占用了版本 3，则本功能顺延到版本 4，迁移语义不变。读取到负数或非整数时归零，避免损坏存档制造无限礼物。

守护者每日免费暖灯不进入 `pendingLantern`：玩家点击“免费点亮”本身已经是明确的主动开启动作。v1.1 可先播放 `support_open_lantern`，随后执行 S1 的免费点亮与持久化；失败时不消耗当日机会。

## 交易与恢复

1. StoreKit 验证通过并确认交易未处理。
2. 对应 `pending*` 加一，同时写入交易去重键并持久化。
3. 持久化成功后才完成 StoreKit transaction。
4. 恢复购买不重复增加消耗型礼物；守护者恢复仍只恢复非消耗权益。
5. 拆礼时先写入“数量减一 + 有效期延长”的单次存档；写入失败则保留礼物并显示温和重试文案。

这样可以保证崩溃、重复回调和快速连点都不会重复发放或丢失礼物。

## 入口与信息层级

### 支持页

- 已有商品卡保持原位置。
- 有库存时，价格按钮上方显示克制状态，例如“有 2 份礼物在这里”。
- 主按钮改为“拆开一份”；拆完最后一份后恢复价格按钮。
- 不显示倒计时、红点、闪烁或呼吸动画。

### 小院

- 最多显示一个小型、手绘的包裹提示，放在边缘预留地面位，不能遮挡宠物、来客、回访动物、饭盆、水盆或用户装饰。
- 多份礼物仍只显示一个包裹，不在院子叠数量角标；数量只在支持页可见。
- 点按包裹进入支持页的待拆区域，不直接弹付费页。

### 手账

- “支持小院”入口可在副标题中显示“有一份礼物在这里”，不使用红点或紧迫动词。
- 没有待拆礼物时完全保持现状。

## 开礼流程

1. 玩家主动点击“拆开一份”。
2. 在柔和遮罩上居中播放对应 8 帧手绘序列，宠物与院子仍隐约可见。
3. 动画非循环，建议 2.0–2.4 秒；按钮在播放期间防重复点击。
4. 第 8 帧与现有静态素材完全重合，并用不超过 120ms 的交叉淡化切到静态图。
5. 显示一句回礼结果与“收好”按钮；关闭后回到原滚动位置。

系统开启“减少动态效果”时，使用 180ms 淡入第 8 帧，不播放中间运动帧。应用进入后台时暂停；恢复后从当前帧继续。语音辅助读出礼物名称与效果时长，不逐帧播报。

## 动画资产契约

资产先存放在非运行时目录，v1.1 实装时再纳入清单：

```text
assets/art/support-open/support_open_treat.webp
assets/art/support-open/support_open_lantern.webp
assets/art/support-open/support_open_bouquet.webp
```

每条均为 4096×512、8 帧×512²、透明底、无损 WebP。播放参数固定为 `frameCount: 8`、`loop: false`；渲染只使用现有 `SpriteSheetPlayer`。禁止以 `Container`、`CustomPainter`、代码粒子或几何色块替代手绘帧。

第 8 帧分别以以下现有素材为视觉锚点：

- `assets/runtime/support/support_treat.webp`
- `assets/runtime/support/support_lantern.webp`
- `assets/runtime/support/support_bouquet.webp`

QA 接触表、逐帧透明边界检查和第 8 帧对照图统一放在 `assets/art/qa/support-open/`。

## 本单资产交付

三条序列帧已作为 v1.1 预备资产交付，但未加入 `pubspec.yaml`，1.0 不会打包或加载：

- `assets/art/support-open/support_open_treat.webp`
- `assets/art/support-open/support_open_lantern.webp`
- `assets/art/support-open/support_open_bouquet.webp`

原始手绘生成稿保存在 `assets/art/support-open/source/`。成品由
`tools/build_support_open_assets.py` 只做透明背景提取、逐帧分离、等比缩放与无损编码；不以代码图形替代任何动画画面。三条成品均为 4096×512、8 帧、透明底无损 WebP，主体长边为约 80%，四周安全边距不低于 10%。

每条动画的接触表与第 8 帧对照图位于 `assets/art/qa/support-open/`；`support_open_validation.json` 记录逐帧边界、占比与末帧像素差。第 8 帧直接从对应现有静态素材规范化得到，最大通道差为 0。v1.1 实装时，静态结果图也应使用相同的 80% 内部占比，避免动画结束后因不同画布留白产生缩放跳变。

复验命令：

```sh
python3 tools/build_support_open_assets.py --check
```

## 实装验收

- 购买不会提前开始时长，拆开后才叠加。
- 重复交易、快速连点、保存失败、进后台恢复均不丢礼物、不重复计时。
- 三项待拆数量与有效期存档往返正确，旧存档兼容。
- 免费守护者暖灯不调用 StoreKit、不进入待拆库存、不影响玩法数值。
- iPhone 与 iPad 上动画完整、不裁切；减少动态效果可用；中文、英文、繁体文案同步。
