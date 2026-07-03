# Petopia 美术资产全局 Review（QA 报告 + UI 重做规格）

> 审查范围：`assets/art/` 全部 1393 个文件，按类抽样开原图审（接触表拼图 + 关键原图放大）。
> 对照标准：`spec-art-overview.md` §1（奶油卡通可爱 + 清晰色块可读轮廓）、§1.2（成品水彩渲染、清晰可辨、可上架）、§2.1（满幅无框）、§1.0 Golden Set。
> 日期：2026-07-03。

## 一、总结论

**大件美术一线水准，小件图标偷懒。** 详细/大尺寸资产（背景、宠物、场景、摆件、访客）达到可上架标准；**小尺寸图标类**（UI 图标/按钮/徽章、明信片贴纸、部分姿态/摆件）是**模糊色团、不可辨、不区分**，需重做。

**关键反证**：摆件里的食盆能画出清晰区分的「鱼干/谷粒/坚果/苹果」餐盘，但 UI 食物图标却全是同一个蓝碗+点——管线有能力，只是小图标那批没做到位。重做时应对齐大件的完成度。

---

## 二、✅ 合格（可直接用）

| 类别 | 数量 | 评价 |
|---|---|---|
| 明信片背景 `pc_bg_*` | 40 | **最强**。丰富精致、各具氛围、满幅无框、无文字 |
| 宠物立绘 `pet_*`（12 种 × 5 变体 × A/B/C/D） | ~240 | 奶油卡通、圆钝可爱、风格统一；**D 档全部带旅装配件** |
| 宠物图鉴 `pet_*_dex_{color,silhouette,mystery}` | 28 | 四态系统完全对；彩蛋问号渍按物种调色 |
| 宠物动作序列帧 `pet_*_stage*_{idle,eat,...}` | ~192 | 序列帧条，结构正确 |
| 院子主题 `yard_theme_*_{bg,props}` | 25 | 满幅无框、季节区分、分层正确 |
| 院子布局 `yard_luxury0N_layout` | 6+delta | 随豪华度自然长大，精致 |
| 院子摆件 `deco_*`（**除下方少数**） | ~78 | **优秀**：食盆/餐盘（鱼/谷/坚果/苹果各异）、邮箱、暖炉、蘑菇灯、石灯、家具 |
| 访客 `visitor_*_{portrait,yard,yard_base}` | 62 | 有角色感（蜗牛慢递员/狐狸/刺猬…）；棕色系略沉但有配件点缀 |
| 明信片姿态 `pc_pose_*_{eat,gaze,run,sleep,soak,surprise}` | ~72 | 表情生动、一致 |

---

## 三、❌ 不合格（需重做）

| # | 资产范围 | 数量 | 问题 |
|---|---|---|---|
| 1 | **`ui_icon_*`** | 61 | **洗白、模糊、不可辨、不区分**。5 个食物图标(apple/fish/grain/nut/empty)**全是同一个蓝碗+点**；动作图标(bath/photo/toy)读不出功能；成就图标多是淡黄小方块/糊团；nav 图标含混 |
| 2 | **`ui_btn_*`** | 22 | 扁橙色块 + 角落极小极淡图标 + 大片留白，廉价占位感，非成品水彩 |
| 3 | **`ui_badge_*`** | 18 | 等级纹概念对(花朵=C✓)但**太淡、细节不足**；稀有度徽章几乎看不出分级 |
| 4 | **`pc_sticker_*`** | ~61（多数） | 碰撞贴纸多是模糊色团/椭圆，读不出所指（camel_bell→三角、charsiu→红条、desert_mist/cloud_gap→无形块）。少数可辨(rolling_apples/pinecone/heart_postmark/ring_glow) |
| 5 | **`pc_pose_*_hat`** | 12 | **坏图**：宠物头顶漂着 T 形支架上的米色方块**占位**，不是真帽子 |
| 6 | **`pc_pose_*_photo`** | 12 | 偏空，只有小闪光，缺相机/拍照元素 |
| 7 | 部分摆件 `deco_doorplate_no1` / `deco_pinwheel_paper*` | ~4 | 扁平色块/占位，非成品水彩 |

---

## 四、重做规格（可直接喂给绘图工具）

> 统一要求：**奶油卡通可爱风、成品水彩渲染、清晰可辨、居中构图、透明背景 PNG、无文字/水印**；对齐 `assets/art/samples/` Golden Set 与摆件（`deco_plate_*`）的完成度；提高对比/饱和，**禁止洗白到看不清、禁止大片留白、禁止扁平色团**。每个图标即使缩到 96px 也要一眼认出。

### A. UI 动作图标 `ui_icon_act_*`（5，各自清晰不同）
- `feed`：一碗满满的猫粮（可点缀小鱼干）
- `pat`：一只温柔的手/爪印 + 小爱心
- `toy`：带线头的毛线球（或逗猫棒）
- `bath`：浴缸 + 泡泡 + 水滴
- `photo`：复古小相机

### B. UI 食物图标 `ui_icon_food_*`（5，**必须明显不同**，可参考 `deco_plate_*` 缩小）
- `apple`：红苹果切片　`fish`：一撮小鱼干　`grain`：金黄谷粒/麦穗　`nut`：坚果堆　`empty`：空盘

### C. UI 导航图标 `ui_icon_nav_*`（5）
- `yard`：开花小屋/院子　`album`：相册本(丝带)　`codex`：图鉴书(书签)　`shop`：购物袋/店铺遮阳篷　`menu`：手账本

### D. UI 成就图标 `ui_icon_ach_*`（各自可辨）
- `care`：爱心+爪印　`firstadopt`：蛋壳/新生　`firstgrad`：毕业帽/小背包　`postcard`：明信片/信封　`revisit`：门铃/老友重逢　`visitor`：脚印+小鸟　`yard`：小屋　`hidden_q`：水彩问号渍

### E. UI 杂项图标
- `bell`铃铛　`gift`礼物盒　`dice`骰子　`flip`翻页　`hourglass_wc`水彩沙漏　`close`✕　`back`←（后两个现状可接受）

### F. UI 徽章 `ui_badge_*`（**分成两套、清晰分级、提高饱和**）
- **等级 4 档**：`level_stageA`=蛋壳纹　`stageB`=嫩芽纹　`stageC`=花朵纹　`stageD`=翅膀纹（四种纹样明显不同）
- **稀有度 4 档**：`rarity_common`(素净灰白)　`uncommon`(嫩蓝)　`rare`(金)　`legend`(彩虹/星光)——色彩+纹样明显分级
- 其余 `graduate/owned/young/new_soft/personality/raising_now/revisit_pat/departure_sticker/ach_stamp/levelup_entry`：各给一个清晰小图形，别只是淡圈

### G. UI 按钮 `ui_btn_*`（22）
- 胶带/贴纸风底 + **图标居中、清晰、成品水彩**；去掉大片空橙块与角落糊点；`tape_disabled` 明确置灰态；`sticker_round`/`tape_*` 保持手账质感

### H. 明信片贴纸 `pc_sticker_*`（重画不可辨的那批，~50+）
- 每个是**小而清晰的水彩物件**，一眼认出：`charsiu`=一块油亮叉烧、`camel_bell`=驼铃、`creased_map`=展开的旧地图、`desert_mist`=沙丘薄雾一角、`firefly_band`=一串萤火、`flying_hats`=飞起的草帽…（按文件名语义画具体物件，禁止抽象色团）

### I. 明信片姿态修复
- `pc_pose_*_hat`（12）：**删掉 T 形占位方块**，改画宠物戴/顶一顶真实旅行帽（草帽/贝雷帽/旅行帽）
- `pc_pose_*_photo`（12）：加相机或「咔嚓」闪光/取景框元素，别只有小闪光

### J. 摆件补画
- `deco_doorplate_no1`（门牌）、`deco_pinwheel_paper*`（纸风车 + 2 帧）：重画成成品水彩，对齐其余 `deco_*` 完成度

---

## 五、附：审查用接触表

抽样拼图存于 `~/cs_*.png`（cat/themes/visitors/ui/icons/dex/species/poses/stickers/decor/layouts/pcbg）。生成脚本 `~/cs.py`。可复现放大复核。
