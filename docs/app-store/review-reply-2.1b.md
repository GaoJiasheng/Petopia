# App Review 回复草稿 — Guideline 2.1(b) Information Needed

提审单 `6b62baff-0055-4e5f-a8c9-32d0479288a6`，1.0 (40)，2026-09-01 被拒。
审核员找不到 4 个内购入口，要求提供定位步骤。**无需改代码、无需重打包。**

---

## 回复正文（英文，直接粘进 ASC 解决中心）

Hello,

Thank you for the review. Here are the exact steps to locate all four In-App Purchases.

**Steps to find the In-App Purchases**

1. Launch the app and complete the short one-time intro (choosing and naming your companion). This takes well under a minute.
2. On the main garden screen, tap the **journal button** — the small book icon in the upper-left corner of the screen.
3. In the journal that opens, tap **Settings**.
4. Scroll to the **bottom** of the Settings page to the section titled **"The Garden Light"**.
5. Tap **"Support the Garden"**.

All four In-App Purchases are listed on this screen:

- **A Treat** — `com.petopia.petopia.support.treat`
- **A Warm Lantern** — `com.petopia.petopia.support.lantern`
- **Garden Bouquet** — `com.petopia.petopia.support.bouquet`
- **Garden Keeper** — `com.petopia.petopia.support.guardian`

**Additional information**

- There are **no restrictions** on these In-App Purchases based on storefront, device configuration, account state, or player progress. They are available to every user immediately after the intro.
- Nothing needs to be unlocked or earned first. No progression gate applies.
- The Paid Applications Agreement is **active** on our account.
- Please note that the **"Shop"** item in the same journal menu is a separate, non-monetary feature: it spends "Sunfluff", a soft currency earned only through normal play. It contains **no** In-App Purchases and Sunfluff cannot be purchased with real money. We realize this naming may have caused confusion, and we are improving the discoverability of the "Support the Garden" screen in our next update.

Please let us know if you need anything else.

Best regards,
Gavin Gao

---

## 中文对照（自己核对用）

主界面 → 左上角手账按钮 → 设置 → 拉到最底 →「小院的灯」→「支持小院」

四个商品都在这一页。无任何解锁/进度/地区/设备限制。

---

## 根因（下个版本要修）

`_homeMenuItems`（`lib/ui/yard_home_screen.dart:3441`）**不包含 support**。
全新安装时通往支持页的唯一路径是设置页底部（`lib/ui/settings_screen.dart:248`），
藏在「导出诊断信息」「报告问题」下面，共 4 层。

另外两个入口都要求**已经买过**，构成先有鸡还是先有蛋：
- `yard_home_screen.dart:579` — 需要 `supportBenefits.hasPendingGifts`
- `_NotebookSupportMemoryCard`（`yard_home_screen.dart:4017`）— 需要已有权益记录

同时主菜单里有个显眼的「商店」通向暖绒软通货商店（满屏"暖绒不足"），
审核员几乎必然把它当成付费入口。这就是被拒的直接原因。

**1.0.1 建议**：把「支持小院」加进 `_homeMenuItems`，作为独立菜单项。

> 勘误（2026-09-02）：上文第 2 步写的是 "upper-left corner"，实际手账按钮位于顶部 HUD 胶囊的右端（暖绒余额旁）。审核已通过，此处仅备注，下次回复时改为 "the book icon at the right end of the top status bar"。
