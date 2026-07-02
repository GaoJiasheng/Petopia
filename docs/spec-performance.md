# Petopia 实现规格 · 性能与资产预算 · v0.3 · 配套 DESIGN.md / spec-devices.md / spec-gamefeel.md

> 本文件是给开发（Flutter + Flame，后续 Codex CLI 实现）、美术、发布工程看的**性能预算与资产交付/包体策略**权威规格。目标：在「~900–1100 项顶级水彩资产（运行时文件更多）+ 最新四代 iPhone/Android + 纯离线可玩 + AAA 渲染红线」这组约束下，给出**可照做、可测、可验收**的预算与降级方案。
>
> **上游约束（不改，仅引用并回吐）**：
> - `DESIGN.md` §0.3 治愈零焦虑三支柱、§0.2 纯本地无后端可离线。
> - `spec-art-overview.md` §1.2 顶级渲染红线（AAA 成品水彩，禁扁平占位）、§2.1 全屏 full-bleed / 参考画布 `1290×2796`。
> - `spec-devices.md` §0 三条几何红线（**无黑边 / 不变形 / 不遮挡**）、§1 设备矩阵、§1.2.1 最低硬件档、§7 `DeviceTier` 分档钩子（本文件落成权威阈值）。
> - `spec-gamefeel.md` §5 零焦虑手感红线、§6 High/Mid/Low 降级占位（本文件落成权威阈值）、§0.1 时长档、§0.2 帧率节拍。
> - `spec-technical.md` §2 Game Config、§3 Service 契约、§3.9 SaveService、§1 Isar/SQLite 存储、`spec-cloudsave.md`。
>
> **仲裁顺序（冲突时）**：三红线（零焦虑 / 无黑边不变形不遮挡）> 情感关键帧 > 顶级渲染红线 > 本文件性能预算。即：**降级只降华丽度，绝不动三红线、绝不删情感关键帧**（毕业目送、换模凝出）。
>
> **本文件与 devices §7 / gamefeel §6 的接线关系**：devices §7 与 gamefeel §6 均标 `[待细化]` 并显式指向本文件。本文件 §4 给出 `DeviceTier` 三档判定与全部降级阈值的**权威表**；那两份文档无需回改，读者以本文件为准。
>
> **标记**：`[待细化]` = 结构已定、细节/清单待补；`[待验证]` = 数值为初版估计，需真机 profiling 校准。数值属性：`锁定` = 破坏红线/承诺需评审；`可调` = 可校准。

---

## 目录

- 0. 术语与预算总原则
- 1. 性能预算（帧率 / 冷启动 / 内存 / 电量发热 / 包体）
- 2. 资产交付与包体策略（纹理压缩 / 图集 / 按需加载 / LRU / Spine vs 序列帧）
- 3. Flame / 渲染层预算（draw call / image cache / 粒子 / full-bleed 内存）
- 4. DeviceTier 分档系统（判定 + High/Mid/Low 阈值权威表）
- 5. 加载与内存生命周期（场景切换 / 内容 JSON / 存档 IO）
- 6. 性能测试与验收（可测指标 / 测试点 / CI 回归 / 泄漏排查）
- 7. 可调常量汇总 + 待细化/待验证汇总

---

# 0. 术语与预算总原则

## 0.1 术语

- **档（Tier）**：`DeviceTier ∈ {HIGH, MID, LOW}`，运行期设备性能分档（§4）。
- **DPR**：`devicePixelRatio`（iPhone 多为 3，Android 2.0–3.5）。资产 @1x/@2x/@3x 与 DPR 挂钩（§2.2）。
- **首包（base bundle）**：安装即带、离线首启即可玩的资产集合（§2.4）。
- **按需包（on-demand pack）**：首启后补下、下载后即缓存到本地、之后**永久离线可用**的资产集合（§2.4）。
- **常驻纹理（resident texture）**：当前必须在 GPU/内存中的解码后纹理（当前宠物 + 当前主题 + 当前场景层）。
- **驻留预算（memory budget）**：某档设备允许的运行期纹理 + 堆内存上限（§1.3）。
- **P（性能）指标锚点**：`min-spec` = §1「保底档」机型（RAM 3–4GB、GLES3.0），所有硬指标以它为验收下限。

## 0.2 预算总原则（五条）

1. **离线优先于一切**：任何按需加载策略都不得破坏「已下载即可离线玩」（DESIGN §0.2）。首包必须让核心循环（领养→照料→升级→毕业→收明信片）在完全断网下闭环。
2. **红线恒定、华丽度弹性**：性能不足时，只降粒子 / 帧率 / 分辨率 / 特效层（§4），三红线与情感关键帧在所有档恒定。
3. **懒加载 + 及时驱逐**：一次只养一只、单一院子场景——**运行期常驻的应是「当前这一只 + 当前这一屏」**，其余按 LRU 驱逐（§2.5）。这是本项目内存可控的结构性红利。
4. **宁可少给不误伤**：预算超限时优先降画质、卸载非可见资产，绝不因性能牺牲存档完整性或数据审计（`INV-1/4`，spec-technical §0）。
5. **可测即验收**：每条预算都有 §6 的可测口径与 min-spec 验收线；无法测的预算视为未定义。

---

# 1. 性能预算

> 分设备档给初值；均可 playtest / profiling 校准。min-spec 为验收下限，target 为体验目标。

## 1.1 目标帧率

| 场景 | HIGH | MID | LOW（保底） | 属性 |
|---|---|---|---|---|
| 主屏 YardScene（idle + 微动 §gamefeel §4） | 60fps | 60fps | **30fps** | 锁定下限 30 |
| 演出层（毕业/换模/回访/特殊事件 §gamefeel §3） | 60fps | 60fps | 30fps（保留情感关键帧） | 锁定 |
| UI 层 / 二级屏（图鉴/相册/商店滚动） | 60fps | 60fps | **60fps**（触摸跟手优先，gamefeel §6.2） | 锁定 |
| 序列帧/骨骼角色动画本体 | 8–12fps（风格帧率，非渲染帧率，art §2.3） | 同 | Low 可降至 8fps | 锁定风格 |

- **口径**：渲染帧率（Flutter/Flame raster+UI 线程）与角色动画帧率是两回事——角色刻意 8–12fps「一顿一顿」（gamefeel §0.2），但**合成/滚动/转场必须达上表渲染帧率**。
- **掉帧容忍**：min-spec 上，主屏稳定态 5 分钟内**掉帧率（frame >「预算帧时长」）≤ 1%**；演出期允许瞬时尖峰但不得连续掉帧 > 3 帧 `[待验证]`。
- **UI 层永不降到 30**：即使 LOW 档场景层 30fps，UI/触摸反馈线程保持 60fps（gamefeel §6.2「保证触摸跟手」）。

## 1.2 冷启动时间（app 图标点击 → 主屏可交互首帧）

| 阶段 | HIGH | MID | LOW（保底上限） | 说明 |
|---|---|---|---|---|
| 引擎 + Flutter 首帧（splash） | ≤ 0.8s | ≤ 1.2s | ≤ 1.8s | 含 Isar/SQLite open |
| 启动编排（load→migrate→audit→schedule，spec-technical §app.dart） | ≤ 0.5s | ≤ 0.8s | ≤ 1.5s | 见 §5.3 |
| 首屏资产就绪（当前宠物 Spine + 当前主题背景 + 顶栏 UI） | ≤ 1.0s | ≤ 1.5s | ≤ 2.5s | 懒加载其余 |
| **合计冷启动（可交互）** | **≤ 2.0s** | **≤ 3.0s** | **≤ 5.0s（硬上限）** | `[待验证]` |
| 热启动（后台恢复 onResume） | ≤ 0.5s | ≤ 0.8s | ≤ 1.2s | 含离线结算演出前 |

- **不阻塞首帧**：`AuditService.verifyOnStartup`（`INV-1/4` 全表扫描，spec-technical §3.3）可能随流水增长变慢——**移出关键路径**：先渲染主屏，audit 在后台 isolate 跑，发现不一致再静默回正（§5.3）。
- **splash 即 full-bleed**：启动画面本身遵守 devices §0 无黑边（避免冷启动首帧露黑边）。

## 1.3 内存占用上限（运行期峰值 RSS，分档）

| 档 | 目标设备 RAM | 运行期峰值 RSS 上限 | 其中纹理驻留预算 | 属性 |
|---|---|---|---|---|
| LOW（保底） | 3–4GB | **≤ 400 MB** | ≤ 180 MB | 锁定上限 `[待验证]` |
| MID | 6GB | ≤ 650 MB | ≤ 320 MB | 可调 |
| HIGH | ≥ 8GB | ≤ 1.0 GB | ≤ 550 MB | 可调 |

- **驱逐触发**：接近纹理预算 85% 时 LRU 驱逐非可见纹理（§2.5）；接近 RSS 上限 90% 时额外降 tier（`[待细化]` 发热/内存双触发）。
- **iOS Jetsam 保护**：iOS 无硬 RAM 数，按机型 Jetsam 限（旧机 ~2GB app 限）——LOW 档 400MB 留足余量避免被系统杀（导致 Spine 单调时钟失效影响离线结算，spec-technical §4.1）。
- **单场景常驻估算（min-spec）**：见 §3.4；结论是「当前宠物 Spine（~15–30MB 解码）+ 主题背景 cover（~20–40MB）+ UI 图集（~20MB）+ 粒子/摆件（~30MB）」应落在 180MB 纹理预算内。

## 1.4 电量与发热约束

- **主屏 idle 稳态**：治愈放置类，玩家常「挂着看」——idle 态必须**低功耗**：
  - idle 微动（呼吸/眨眼/fidget，gamefeel §4）复用少量骨骼 + 随机时钟，**不满帧重绘**：静态区脏矩形局部重绘，无动区不触发 raster `[待细化]` Flame 局部重绘策略。
  - **无操作 60s** 后，主屏渲染节流到 **30fps**（LOW 已 30，MID/HIGH 从 60 降 30），呼吸/视差幅度不变、观感无损（gamefeel §4.4 呼吸周期 8s，30fps 足够）。`可调`
  - **完全后台**：暂停 Flame ticker、停止所有粒子/动画时钟，仅保留 onResume 结算钩子。
- **发热保护（thermal throttling）**：监听平台热状态（iOS `ProcessInfo.thermalState` / Android `PowerManager.getThermalHeadroom`）：达 `serious/critical` 自动降一档 tier（关粒子/视差/降帧），恢复后回升。`[待细化]` 阈值与回滞窗口。
- **验收锚**：min-spec 机型主屏 idle 挂机 **30 分钟机身温升 ≤ 阈值、无 thermal 降频告警** `[待验证]`；连续互动 10 分钟不触发 critical。

## 1.5 包体大小目标（呼应 §2 交付策略）

| 项 | 目标 | 属性 | 说明 |
|---|---|---|---|
| **首包下载体积（App Store / Play 商店页显示）** | **iOS ≤ 200 MB / Android ≤ 150 MB（首包 AAB base）** | 可调 `[待验证]` | 低于 iOS 蜂窝下载软红线区，Android base + 首个 dynamic feature |
| 安装后首包磁盘占用 | ≤ 350 MB | 可调 | 解压后 |
| 全量资产（含所有按需包，全下载后） | **≈ 1.2–1.8 GB** | `[待验证]` | 见 §2.6 估算 |
| 首包资产预算（MVP 核心） | ≤ 120 MB 纹理（压缩后） | 可调 | 对齐 DESIGN §12 MVP：3 物种×3 变体、地点 12、访客 8、主题 2、成长档 4 |

- **首包必须自足离线**：包含 §2.4 「首包资产集」——引擎 + 全部内容 JSON + 核心 UI + **首只可养宠物所需 Spine + 默认主题 + 教程/毕业演出资产**，断网可完成第一只宠物完整生命周期。

---

# 2. 资产交付与包体策略（重点：解决 ~1000+ 顶级水彩资产 × @1x/@2x/@3x 的包体矛盾）

> **矛盾陈述**：art-overview §3 估 ~900–1100 交付项，运行时文件更多（Spine 部件切图、序列帧展开、@1x/@2x/@3x 三套）。若全部未压缩 PNG 三套进首包 → 数 GB，撑爆包体与内存。本节给出五层解法：**纹理压缩 → 图集打包 → 按需加载/卸载 → 运行期 LRU 驱逐 → Spine/序列帧内存取舍**。

## 2.1 纹理压缩（GPU 压缩纹理，替代运行期解码大 PNG）

- **问题**：PNG 进包省包体，但运行期解码为 RGBA8888 极占内存（1290×2796 全屏 ≈ 14MB/张解码）。GPU 压缩纹理**磁盘小 + 显存小 + 无需 CPU 解码**。
- **方案：统一 ASTC 为主，ETC2 兜底。**

| 平台 | 主格式 | 兜底 | 说明 |
|---|---|---|---|
| iOS（全目标机 A9+，GLES3/Metal） | **ASTC**（8×8 或 6×6 block，随资产精度） | — | 全支持，压缩率高、质量好 |
| Android 主流（GLES3.0+，devices §1.2.1 最低档） | **ASTC**（GLES3.2 / KHR_texture_compression_astc_ldr 扩展） | **ETC2**（GLES3.0 保证支持） | 运行期查扩展，ASTC 不可用回退 ETC2 |

- **block size 策略**（质量 vs 大小，`[待细化]` 逐类定档）：
  - 全屏背景 / 明信片背景板（大面积水彩渐变）：ASTC 8×8（省），可接受轻微色带。
  - 宠物/访客 Spine 部件、UI 图标徽章（边缘锐利、透明通道关键）：ASTC 6×6（保边缘与 alpha）。
  - 邮戳/贴纸小图：ASTC 6×6 或 5×5。
- **交付流水**：美术仍交付 @1x/@2x/@3x PNG（art §2.2 终稿），构建期离线转 ASTC/ETC2（工具如 `astcenc` / `etc2comp`），打进包的是压缩纹理容器（`.ktx2` 首选，含 mipmap）。**源 PNG 不进包**。
- **AAA 渲染红线兼容**：ASTC 高 bitrate（4×4/5×5/6×6）质检对比原图无肉眼可辨劣化方可放行（art §1.2 交付即终稿）；大背景用 8×8 时须过「4:3~21:9 裁切预览 + 无色带」质检（devices §6.2）。`[待验证]` 逐类 bitrate。
- **DPR 挑档**：运行期按 `devicePixelRatio` 只加载对应密度一套（DPR≤2 → @2x，DPR≈3 → @3x；LOW 档强制 @2x，§4）。**不把三套都进内存**。

## 2.2 图集打包（TexturePacker，减少 draw call + 减少文件/纹理切换）

- **工具**：TexturePacker（或 Flame `SpriteSheet` + 自建打包），输出图集 PNG/KTX2 + JSON atlas 描述。
- **分组策略（按「同屏同时可见 + 同生命周期」聚簇，最大化批处理、最小化驻留浪费）**：

| 图集组 | 内容 | 常驻时机 | 说明 |
|---|---|---|---|
| `atlas_ui_core` | 手账 UI 套件、常驻图标/徽章、TapeButton/ClipTab/沙漏 | 全程常驻 | ~2048² 一张，几乎每帧参与 |
| `atlas_ui_secondary` | 图鉴/相册/商店二级屏专用元素 | 进入对应屏加载、退出可驱逐 | |
| `atlas_pet_<species>_<stage>` | 单物种单成长档 Spine 部件切图 | 当前宠物当前档常驻；换档预取下一档 | Spine 天然按骨骼打图集 |
| `atlas_yard_<theme>` | 当前主题 bg + props 贴图集 | 当前主题常驻，切主题时换 | world §W1.2 props 已是 1024² sheet |
| `atlas_yard_luxury<N>` | 当前豪华度布局层设施 | 当前豪华度常驻 | 随毕业进阶才变 |
| `atlas_visitors_common` | 高频常见访客院内立绘 | 常驻（小体积，命中率高） | world §W4 |
| `atlas_visitors_rare` | 稀有/传说访客立绘 | 命中时按需加载 | |
| `atlas_postcard_pose` | 12 物种 × 8 姿态贴层 | 仅收信/相册屏加载 | postcard §分层合成 |
| `atlas_postcard_bg` | 40 地点背景板（1080×720） | 逐张按需（看某张才加载对应背景） | 见 §2.4 |
| `atlas_fx_particles` | 爱心/星屑/雪雨/泡泡粒子帧 | 常驻（小、频繁） | 对象池复用（§3.3） |

- **规则**：单图集 ≤ **2048×2048**（min-spec GLES3.0 保证的最大纹理尺寸，避免超限被降采样或拒绝）；大背景（1290×2796 / 1080×720）**单独成纹理不入图集**（太大无法进 2048² 图集）。
- **收益**：同屏元素来自同一图集 → Flame 可合并为一次 draw call（§3.1）；同组同加载同卸载 → 驻留精确。

## 2.3 首启后台补下 vs 平台按需交付（保离线）

三种交付通道，混合使用：

| 通道 | 用途 | 离线保证 |
|---|---|---|
| **首包内嵌** | §2.4 首包资产集（核心循环所需） | 安装即离线可玩 ✅ |
| **首启后台补下（自建 CDN / 商店托管资源）** | 非首只宠物、非默认主题、明信片背景板、稀有访客、其余成长档等 | 联网时后台静默补下，**下载后写入本地缓存目录，之后永久离线可用** ✅ |
| **平台按需（iODR / Play Asset Delivery）** | 大体积可选资产分包（可选主题、彩蛋宠特效、全量明信片背景板） | iOS **On-Demand Resources**（tag 化，下载后本地保留至系统清理）；Android **Play Asset Delivery**（`install-time`/`fast-follow`/`on-demand`）——均**下载后本地可离线** ✅ |

- **离线红线的技术保证**：任何「尚未下载」的按需资产在游戏内**不作为核心循环的阻塞项**——它们对应的内容（后续宠物、可选主题、后续明信片地点）在未下载时于 UI 上呈现为「可探索但需联网解锁一次」，一次下载后永久离线。**当前正在养的宠物 + 当前主题 + 当前旅程正在寄的明信片背景**必须已在本地（生成明信片前预取其背景板，§5.1）。
- **Android 交付分档**：base（首包核心）+ `fast-follow`（首安装后自动补下的高频资产：其余 MVP 物种、常见访客）+ `on-demand`（低频：全量地点背景、稀有访客、可选主题）。
- **iOS 交付分档**：主 bundle（首包）+ ODR tag 组（`pet_<species>`、`theme_<id>`、`postcard_bg_<region>`、`visitor_rare`）。
- **补下策略**：仅在 **Wi-Fi + 充电 或 用户主动触发**时后台补下大包（不偷跑流量/耗电，呼应零焦虑）；下载全程无「催促/进度焦虑」文案（gamefeel §5），失败静默重试。`[待细化]` 补下调度器。

## 2.4 首包资产集（自足离线的最小闭环，对齐 DESIGN §12 MVP + 首启体验）

首包 **必带**（安装即离线可完成第一只宠物完整生命周期）：
- 引擎 + Flutter + 全部 **内容 JSON**（`assets/data/*.json`，spec-technical §5.1；文本类极小，全带）。
- `atlas_ui_core` + `atlas_ui_secondary`（全 UI，用户随时进任意屏）。
- 首批可养 3 物种（cat/shiba/rabbit）× MVP 3 变体 × 4 成长档 Spine（DESIGN §12 / art-pets §5：36 形态 = 9 骨骼套 + 3 组旅装配件）+ 24 通用动作 + 40×3 性格动作适配。
- 默认主题 `theme_default` + 豪华度 ①② 布局层。
- 常见访客立绘（`atlas_visitors_common`）。
- 首批地点背景板：**首只宠物毕业后旅程 5–8 站**所需的背景板（可保守全带 MVP 地点 12 张，postcard 域）+ 12 物种×8 姿态贴层（`atlas_postcard_pose`）+ 6 滤镜 + 邮戳。
- 全部**演出资产**（毕业/换模/收信/回访/初雪·流星雨·满月三特殊事件，gamefeel §3 MVP 子集）+ 粒子帧图集。

首包 **不带**（按需补下，§2.3）：第 4 只起解锁物种（hamster..chameleon）、彩蛋宠、非默认可选主题（樱花/星夜/…）、全量 40 地点背景板中非首程部分、稀有/传说访客立绘、豪华度 ③–⑥ 高级布局层（毕业推进后才需要，有充足时间补下）。

## 2.5 内存中纹理的懒加载 / 驱逐（LRU）

- **懒加载**：纹理**首次可见前不解码进显存**。进入某屏/切某主题/切某成长档时按需加载对应图集；离开后标记可驱逐。
- **LRU 驱逐器**（Flame `Images` cache 之上的策略层）：
  - 维护 `resident set`（当前屏必需）+ `lru cache`（最近用过、可能复用）。
  - 每帧末检查纹理内存，超 §1.3 预算 85% → 从 lru 尾部驱逐最久未用、非 resident 的纹理（`images.clear(key)` / evict）。
  - **永不驱逐 resident**：当前宠物当前档 Spine、当前主题背景、`atlas_ui_core`、当前可见粒子。
  - 换成长档（Lv5/8/10）时**预取下一档**再驱逐上一档（避免换模演出中途 hitch，gamefeel §3.2 情感关键帧）。
- **单宠位红利**：因「一次只养一只 + 单一院子场景」（DESIGN §0.3），resident set 天然很小——这是本项目区别于开放世界手游、内存可压到 LOW 档 180MB 的结构性原因。
- **预算超限的降级顺序**（先低情感成本，后高）：驱逐非可见二级屏图集 → 降未来预取 → 降粒子密度（§4）→ 降背景到 @2x（§4）→ 触发降 tier。**绝不驱逐**情感关键帧资产。

## 2.6 Spine vs 序列帧的内存取舍

| 维度 | Spine 骨骼（art §2.2 首选） | 序列帧 sprite sheet |
|---|---|---|
| 磁盘/包体 | **小**（一套部件切图 + 骨骼数据，动作复用切图） | 大（每帧独立像素，帧数 × 画布） |
| 内存驻留 | **小**（部件图集常驻，动作靠骨骼数据驱动） | 大（整张 sheet 常驻） |
| 变体成本 | **极省**（5 变体 = Spine skin 换色，复用同骨骼，art-pets §开篇） | 贵（每变体重出全帧） |
| 运行期 CPU | 略高（骨骼变换/网格） | 低（只切帧） |
| 适用 | **宠物 / 访客 / 回访**（多变体、多动作、需 attachment 配件插槽如旅装） | 特效 / 天气粒子 / 个别难骨骼化演出（爆发式一次性） |

- **决策规则（钉死）**：
  - **角色类（宠物/访客/回访）一律 Spine**——变体靠 skin 换色（art-pets：5 变体复用 1 套骨骼绑定），动作靠动作库复用，是 240 形态 / 196 动画能装进预算的关键。
  - **特效/天气/粒子**用序列帧或 Flame 引擎粒子（art §2.2）——短、少帧、对象池复用（§3.3）。
  - 个别一次性演出（如毕业目送镜头特效）可序列帧，但帧数受 tier 预算约束。
- **内存换算示例（min-spec）**：单物种单档 Spine 部件图集（~22–26 层，512×512 画布内切片打成 ~1024² 图集，ASTC 6×6）≈ **3–6 MB 显存**；序列帧同等表现（8fps×1.5s×多动作，512×512）可达 30–50MB。**Spine 省 ~8–10 倍**。

---

# 3. Flame / 渲染层预算

## 3.1 Draw call / 精灵批处理

- **目标 draw call（主屏稳态，min-spec）**：**≤ 80 draw calls/帧** `[待验证]`；二级屏（网格滚动）≤ 60。
- **批处理手段**：
  - 同图集元素合批（§2.2 图集分组即为此服务）——UI 一批、当前主题一批、粒子一批、当前宠物 Spine 一批。
  - Flame `SpriteBatch` 用于同纹理大量小精灵（粒子、贴纸、明信片姿态合成）。
  - 层间避免频繁纹理切换：按 z 层（devices §3.1 z0–z7）分组渲染，同层同图集连续提交。
  - 减少半透明叠层数量（水彩多为半透明，overdraw 是本项目主要 GPU 成本，见 §3.4）。

## 3.2 Flame image cache 策略

- **单一 `Images` 实例 + 显式 key 管理**：所有加载走统一路径，key = 图集/纹理 asset_id，便于 §2.5 LRU 精确驱逐。
- **预算钳制**：Flame 默认无上限缓存——**外挂 §2.5 LRU 层**，`images.clearCache()` 用于粗粒度（切大场景/退二级屏），`images.clear(key)` 用于细粒度驱逐。
- **预加载编排**：`app.dart` 启动只预加载首屏 resident set（§1.2）；进屏/切主题/换档时按需 `images.load` 对应图集；**绝不启动全量预加载**（会撑爆冷启动与内存）。
- **KTX2/压缩纹理加载**：走自定义 loader 直传 GPU 压缩纹理（不经 Flutter `dart:ui` RGBA 解码路径），`[待细化]` Flame 压缩纹理插件/通道方案（可能需 platform channel 或 `flutter_gpu`）。

## 3.3 粒子上限（呼应 gamefeel §5 峰值封顶 + §6 降级）

> 粒子密度是华丽度的主要弹性项，按 tier 钳制（§4）。所有粒子走**对象池复用，不每次新建**（gamefeel §6.2）。

| 粒子类别 | HIGH 上限 | MID（×0.6） | LOW（×0.3 或关） | 属性 | 来源 |
|---|---|---|---|---|---|
| 微交互（摸头爱心/升级星屑/暖绒屑） | 8 | 5 | 3 | 可调 | gamefeel §2 |
| 洗澡泡泡 | 12 | 8 | 4 | 可调 | gamefeel §2.1 |
| 天气·雪/雨/花瓣（同屏活跃粒子） | 120 | 72 | **36 或改静态滤镜** | 可调 | gamefeel §4.3 |
| 演出·彩带/花瓣（换模/毕业） | 60 | 36 | 18（不削情感关键帧本身） | 可调 | gamefeel §3.2 |
| 环境·萤火虫/星点 | 40 | 24 | 12 | 可调 | gamefeel §4.3 |
| **同屏活跃粒子总数硬上限** | **300** | 180 | **90** | 锁定上限 | 防 overdraw 失控 |

- **峰值频率封顶（所有档恒定，gamefeel §5）**：任何脉冲/闪烁 ≤ 0.67Hz、镜头缩放 ≤ 1%/帧——这是零焦虑红线，**不随 tier 变化**。
- LOW 档天气特效**降级为静态/半静态滤镜层**（devices §7、gamefeel §6.1）而非活跃粒子——省 GPU 且观感仍成立（水彩雾/雨罩本就柔和）。

## 3.4 全屏 full-bleed 背景的分辨率与内存权衡

- **约束**：devices §3.2 要求背景 cover 到物理屏且带 overscan 溢出余量（美术交付 ≈ 1680×3350 大画布，devices §6.1）。若按大画布 @3x RGBA 常驻 ≈ 1680×3350×4 ≈ **22MB/张未压缩**；压缩后（ASTC 8×8）≈ **2.8MB**。
- **策略**：
  - 背景纹理**用 ASTC 8×8 压缩纹理常驻**（§2.1），非解码 RGBA——单主题背景显存 ≈ 3–4MB，可接受。
  - **按 DeviceTier 选背景分辨率**：HIGH @3x、MID @2x/@3x（按 DPR）、**LOW 强制 @2x**（devices §7 明列「背景纹理 @2x」）——LOW 背景显存再省 ~2.25×。
  - **只常驻当前主题 1 张背景**（+ 切主题时短暂双持做 WashTransition，gamefeel §2.2）；豪华度布局层是透明 PNG（world §W1.2），单独薄层。
  - **overdraw 控制**：full-bleed 背景 + 半透明主题层 + 天气罩 + 粒子 → 多层半透叠加是主要 GPU 成本。min-spec 目标**平均 overdraw ≤ 2.5×** `[待验证]`；LOW 档合并天气罩到背景、减半透层数。
  - **cover 缩放不改纹理内存**：cover 是采样时的缩放（devices §3.2 公式），不额外生成大纹理；溢出裁切区不产生额外像素成本。

---

# 4. DeviceTier 分档系统（接线 devices §7 + gamefeel §6 → 权威阈值表）

> **本节是 devices §7 与 gamefeel §6 中所有 `[待细化]` 降级项的权威落地。** 那两份文档指向本节，无需回改。
> **总红线（恒定，不随 tier 变化）**：devices §0 无黑边/不变形/不遮挡三红线；gamefeel §5 零焦虑（沙漏/柔光/无红点/峰值频率封顶）；情感关键帧（毕业目送、换模凝出）。**降级只降华丽度。**

## 4.1 分档判定（统一定义）

启动时探测 → 归 `DeviceTier`，写入运行期（可设置页手动降档，gamefeel §6 / devices §7）。

| 因子 | 来源 | LOW | MID | HIGH |
|---|---|---|---|---|
| **物理内存 RAM** | 平台 API（`ActivityManager.MemoryInfo` / `os_proc` / `device_info_plus`） | 3–4 GB | 6 GB | ≥ 8 GB |
| **GPU / 图形能力** | GLES 版本 + ASTC 支持 | GLES3.0（ASTC 或 ETC2） | GLES3.1+，ASTC | GLES3.2 / Vulkan，ASTC |
| **机型年代 / SoC** | 机型白名单 + 年代 | 近四年入门/中端（devices §1.2.1 最低档下限） | 近三年中端 | 近两年旗舰 |
| **DPR** | `MediaQuery.devicePixelRatio` | 任意（LOW 仍可能 DPR3，但强制 @2x 纹理省内存） | — | — |

- **判定算法（保守取低）**：三因子（RAM / GPU / 年代）各映射一档，**取最低档**（宁可少给不误伤发热/卡顿）。SoC 白名单命中优先于粗略年代。`[待细化]` 白名单清单 + `device_info_plus` 字段映射。
- **iOS 归档**：iOS 16 最低（devices §1.2.1），按机型（A 系列芯片 + RAM）静态表归档；A15+ 旗舰 → HIGH，中端近三年 → MID，最低支持机 → LOW。
- **Android 归档**：RAM + GLES/ASTC + SoC 白名单三取低；碎片化兜底：探测失败或未知机型 → **默认 MID**（不默认 HIGH，避免弱机烫机）。
- **动态降级**：运行期掉帧自适应 + 发热保护（§1.4）可临时降一档；恢复后回升（回滞窗防抖动）。`[待细化]` 自适应算法。
- **手动档**：设置页允许「省电/流畅」手动降档（gamefeel §6 MVP 至少提供 High/Low 手动切换占位）。

## 4.2 三档降级阈值权威表（落成 gamefeel §6 + devices §7 全部占位项）

| 维度 | HIGH | MID | LOW（保底） | 恒定红线 |
|---|---|---|---|---|
| **场景层渲染帧率** | 60fps | 60fps | 30fps | UI 层恒 60fps |
| **角色动画帧率** | 10–12fps | 10fps | 8fps | 风格「一顿一顿」恒定 |
| **同屏活跃粒子总上限**（§3.3） | 300 | 180 | 90 | 峰值频率 ≤0.67Hz 恒定 |
| **各类粒子密度系数** | ×1.0 | ×0.6 | ×0.3 | — |
| **并发动画数**（同屏同时播放的独立骨骼/序列动画：宠物 + 访客 + 回访 + 事件动画） | 6 | 4 | **3**（当前宠 1 + 访客/回访 1 + 事件/微交互 1） | 情感关键帧不受此限（毕业/换模独占屏） |
| **背景分辨率** | @3x（按 DPR） | @2x/@3x（按 DPR） | **强制 @2x** | full-bleed cover 无黑边恒定 |
| **UI/角色纹理密度** | @3x | 按 DPR | @2x | — |
| **天气/环境特效** | 全粒子 + 体积感 | 粒子中密度 | **降为静态/半静态滤镜层** | 柔和不刺眼恒定 |
| **陀螺仪视差**（devices/gamefeel §4.4） | 开（幅度 ≤6px） | 开 | **关**（纯静态分层） | — |
| **镜头呼吸**（gamefeel §4.4） | 开（±0.5%） | 开 | 关或幅度减半 | — |
| **景深 / 体积光叠层** | 开 | 关 | 关 | — |
| **idle 微动（呼吸/眨眼/fidget）** | 全开 | 全开 | **保留**（低成本、定义治愈基调，gamefeel §6.1/§7.4） | 必进所有档 |
| **音频 stem / 层数**（呼应 spec-audio 自适应 BGM） | 全 stem（自适应多层混音） | 全 stem | **减层：关环境音层，保留交互 SFX + 单层 BGM** | 无尖锐/大音量、可全关 恒定 |
| **演出特效**（毕业/换模） | 满特效 | 满特效 | **保留核心晕染 + 情感关键帧，削环境粒子/彩带密度** | 情感关键帧绝不削（gamefeel §6.2） |
| **纹理驻留预算**（§1.3） | 550 MB | 320 MB | 180 MB | — |
| **RSS 峰值上限**（§1.3） | 1.0 GB | 650 MB | 400 MB | — |

- **音频 stem 说明**：spec-audio 定义自适应 BGM（多 stem 按状态混音）——LOW 档减到单层 BGM + 交互 SFX，关环境音层（gamefeel §6.2「Low tier 关闭环境音层，保留交互音效」）。全档「可全关、无尖锐、20ms 淡入」红线恒定（gamefeel §0.4）。
- **并发动画数**：LOW 档若同窗口触发 > 3 个动画（如满月茶会多访客，gamefeel §3.5），按「当前宠 + 最近交互对象 + 1」保留，其余降为静态立绘或错峰延后播放（gamefeel §1.3 错峰本就串行，天然契合）。
- **本表与 devices/gamefeel 的对齐**：devices §7 表「关粒子上限、天气降静态滤镜、骨骼降 8fps、背景 @2x、限并发动画」→ 本表逐项给阈值；gamefeel §6.1 High/Mid/Low + §6.2 降级手段 → 本表逐项给数值。

---

# 5. 加载与内存生命周期

## 5.1 场景切换的资产加载 / 释放

- **主屏 YardScene（常驻宿主）**：resident = 当前宠物 Spine + 当前主题背景 + 当前豪华度布局 + `atlas_ui_core` + 常见访客图集 + 粒子池。永不整体卸载（onResume 快恢复）。
- **进二级屏（图鉴/相册/商店，WashTransition，gamefeel §2.2）**：
  - 加载 `atlas_ui_secondary` + 该屏专用图集（相册进 `atlas_postcard_pose`；商店进商品图；图鉴进物种彩图/剪影）。
  - 退出时标记这些图集可驱逐（LRU，非立即释放——用户常来回切）。
- **明信片背景板（40 张，大且低命中）**：**逐张按需**——看某张明信片时加载对应 `pc_bg_*`，看完可驱逐。生成明信片（PostcardGenerator，spec-technical §3.5）时**提前预取下一站背景板**（趁旅程中有 1–3 天间隔，§2.3 离线保证）。
- **换主题**：加载新 `atlas_yard_<theme>` → WashTransition 双持一瞬 → 驱逐旧主题。
- **换成长档（Lv5/8/10 换模，gamefeel §3.2）**：预取下一档 `atlas_pet_<species>_<stage>` → 演出「新形态凝出」→ 驱逐上一档骨骼图集（保留当前档常驻）。
- **访客/回访出现**：常见访客常驻图集直接用；稀有/传说访客首次出现时按需加载（可能触发一次联网补下，§2.3），加载完成再播「晕染显形」演出（gamefeel §2.3），避免空帧。

## 5.2 内容 JSON 的懒加载 vs 预载

> 内容 JSON（spec-technical §5.1）是文本，**体积远小于美术**，策略偏预载但大表懒解析。

| 内容 | 体积量级 | 策略 |
|---|---|---|
| `game_config.json` / `species.json` / `personalities.json` / `visitors.json` / `locations.json` / `shop_items.json` / `achievements.json` / `clue_defs.json` | 小（KB–数百 KB） | **启动预载**进 `ContentRepository` 常驻（spec-technical §1「运行期常驻内存」） |
| `events.json`（日常 100 + 特殊 20） | 中 | 启动预载（事件调度每日高频用，spec-technical §3.4） |
| `visitor_interactions.json`（~256 条矩阵，DESIGN §8.4） | 中 | **懒加载 + 索引**：启动只建 `(visitorId, speciesId)` 索引，命中互动时按需取 script（避免全 256 条常驻） `[待细化]` |
| `postcard_templates.json`（240 骨架 + 60+60 词条，content-postcards） | 中大 | **懒加载**：生成明信片时按「主性格 × 地点类别」取对应模板段，不全量常驻 `[待细化]` |

- **运行期动态数据**（Pet / ExpLog / Postcard / CurrencyLog 等）走 Isar/SQLite（spec-technical §1），非 JSON——按需查询，不预载全历史（相册按分页/时间窗查，§5.3）。

## 5.3 存档读写性能（呼应 spec-technical §3.9 SaveService / spec-cloudsave）

- **自动存档 debounce**：`autoSaveDebounceMs = 1500`（spec-technical §2.10）——状态变更后延迟落盘，避免每次摸头都写盘。写在后台 isolate，不阻塞 UI。
- **流水表增长（长期性能风险）**：`exp_log` / `currency_log` / `postcard` / `event_log` 只追加（`INV-3`），随游戏时长线性增长（多只宠物 × 全生命周期）。
  - **索引已定**（spec-technical §1.4）：按 `pet_id` / `timestamp` / `received_at` 建索引，成长手账/相册按 petId + 时间窗查，**不全表扫描**。
  - **启动 audit 移出关键路径**：`AuditService.verifyOnStartup`（`INV-1/4` 全表 SUM）随流水增长变慢——在后台 isolate 跑，主屏先可交互（§1.2）；不一致静默回正（spec-technical §3.3）。`[待细化]` 大流水下 audit 可增量校验（只校验上次校验点之后的新增）。
  - **归档**：毕业宠的成长手账「归档进旅行相册」（DESIGN §3.4）——归档后其 exp_log 可移入冷表/懒查，减小热表 `[待细化]`。
- **存档体积**：Isar 对象 + SQLite 流水，长期上限 `[待验证]`（多宠物几百明信片 + 数千流水条 → 预估数 MB–数十 MB，远小于美术）。
- **双备份 A/B + 迁移**（spec-technical §3.9）：写当前 slot 后切换；load 校验失败回退备份。迁移全程事务。这些是正确性机制，性能上：备份写同样后台 isolate、debounce 内合并。
- **云存档同步（spec-cloudsave）**：iCloud/Google 同步是**流水并集去重**，网络 IO 全后台、失败不阻塞离线游玩（DESIGN §0.2 离线优先恒定）。同步不在冷启动关键路径。`[待细化]` 同步节流与冲突解决性能。

---

# 6. 性能测试与验收

## 6.1 关键指标可测验收（min-spec 机型为下限，见 §6.4 机型）

| 指标 | 验收线（min-spec / LOW 档） | 测量方式 |
|---|---|---|
| 主屏稳态帧率 | 掉帧率 ≤ 1%（30fps 预算），UI 层 60fps | Flutter DevTools Timeline / `dart:developer` 帧回调；真机 profiling |
| 冷启动（可交互首帧） | ≤ 5.0s（硬上限，§1.2） | 冷启动打点（app 图标 → 首帧可交互回调） |
| 热启动（onResume） | ≤ 1.2s | onResume 打点 |
| 运行期峰值 RSS | ≤ 400 MB | Xcode Instruments (Allocations/VM) / Android Studio Memory Profiler |
| 纹理驻留 | ≤ 180 MB | 自建 texture cache 计数器 + GPU 内存工具 |
| Draw call（主屏稳态） | ≤ 80/帧 | Flame 调试 overlay / GPU 抓帧（Xcode GPU / Android GPU Inspector） |
| Overdraw（主屏） | 平均 ≤ 2.5× | Android「调试 GPU 过度绘制」/ GPU 抓帧 |
| idle 挂机温升 | 30 分钟无 thermal critical 告警 | 平台 thermalState 监听 + 机身测温 `[待验证]` |
| 首包下载体积 | iOS ≤ 200MB / Android base ≤ 150MB | 商店 App size report / AAB 分析 |
| 离线可玩闭环 | 断网可完成首只宠物领养→毕业→收 ≥1 明信片 | 断网手测（飞行模式全流程） |

## 6.2 性能测试点（profiling 场景清单）

1. **冷启动** / 热启动（各机型 × 各 tier）。
2. **主屏 idle 挂机**（30 分钟，测帧率/RSS/温升/无内存增长）。
3. **连续互动**（喂食/摸头/玩/洗澡循环 10 分钟，测 GC 抖动、纹理是否泄漏）。
4. **场景切换压力**（图鉴↔相册↔商店↔主屏反复切 100 次，测 LRU 驱逐是否稳态、RSS 是否单调上涨=泄漏）。
5. **换主题 / 换成长档 / 换宠物**（测大图集加载 hitch、驱逐是否及时）。
6. **满负载演出**：满月茶会（多访客并发，gamefeel §3.5）+ 毕业典礼（§3.1）——测并发动画上限（§4.2）与演出期掉帧。
7. **明信片背景板逐张浏览**（相册翻 40 张，测按需加载/驱逐、无累积）。
8. **长期流水**：模拟数千条 exp_log/postcard，测启动 audit 耗时、相册查询、成长手账加载。
9. **极端比例**：最方（4:3/折叠内屏）+ 最长（21:9）full-bleed cover（devices §8.2），测背景内存与无黑边（性能 × 几何红线交叉）。
10. **发热/低电量**：触发 thermal serious，验证自动降 tier 生效且恢复。

## 6.3 CI 性能回归

- **自动化帧率/内存基线**：CI 跑 integration_test 在模拟器/固定真机上采集关键场景（§6.2 的 1/2/4/5）的帧率与 RSS，**与基线比对，回归超阈值（如帧时长 +15% / RSS +10%）则失败** `[待细化]` 阈值与基线机型。
- **包体回归**：CI 构建后检查首包体积，超 §1.5 目标则告警/失败（防资产误进首包）。
- **纹理预算断言**：单测/集成测断言 resident set 在各典型场景不超 §1.3 驻留预算（自建 cache 计数器可断言）。
- **draw call 断言**：主屏稳态 draw call 上限断言（防新增图集分组破坏批处理）。
- **接入 devices §8.2 截图矩阵**：多尺寸截图 + 无黑边检测（几何红线）与性能回归同一 CI 流水 `[待细化]`。

## 6.4 内存泄漏排查点

- **纹理未驱逐**：切屏/换主题/换档后，对应图集是否从 cache 消失（LRU 生效）；反复切 100 次 RSS 应回稳态非单调上涨（§6.2-4）。
- **Spine/动画控制器未 dispose**：宠物毕业/访客离开后骨骼实例、`AnimationController`、`Ticker` 是否释放。
- **粒子对象池泄漏**：粒子是否归池复用而非无限新建（§3.3）。
- **监听器/定时器**：idle fidget 时钟、心跳（spec-technical §4.3 markHeartbeat）、云同步订阅是否在页面/宠物生命周期结束时取消。
- **SQLite 游标 / Isar watcher**：相册分页查询游标、Isar `watch` 订阅是否关闭。
- **Image cache 无上限**：确认 Flame `Images` 外挂了 LRU 上限（§3.2），未回退到默认无限缓存。
- **isolate**：后台 audit/存档 isolate 用后是否回收。

---

# 7. 可调常量汇总 + 待细化/待验证汇总

## 7.1 性能可调常量（与 spec-technical §2 Game Config 对齐；数值权威在此，Config 承载引用不重复）

> 建议承载：`lib/config/perf_config.dart`（`PerfConfig` 常量类）或 `assets/data/perf_config.json`，与 spec-technical §2 `GameConfig` 同机制（推荐 JSON + 强类型解析）。**本表定义性能域常量的初值与属性；spec-technical §2 若需引用，引用键名不重复承载值。**

| 常量 key | 初值 | 属性 | 含义 / 出处 |
|---|---|---|---|
| `targetFpsScene[HIGH/MID/LOW]` | 60/60/30 | 锁定 LOW=30 | §1.1 场景层帧率 |
| `targetFpsUi` | 60 | 锁定 | §1.1 UI 层恒 60 |
| `charAnimFps[HIGH/MID/LOW]` | 12/10/8 | 锁定风格 | §4.2 角色动画帧率 |
| `idleThrottleAfterSec` | 60 | 可调 | §1.4 无操作降 30fps |
| `coldStartBudgetMs[HIGH/MID/LOW]` | 2000/3000/5000 | 可调 `[待验证]` | §1.2 |
| `memRssCapMB[HIGH/MID/LOW]` | 1024/650/400 | 锁定上限 | §1.3 |
| `texResidentCapMB[HIGH/MID/LOW]` | 550/320/180 | 锁定上限 | §1.3 |
| `lruEvictThresholdPct` | 0.85 | 可调 | §2.5 驻留超 85% 驱逐 |
| `tierDowngradeRssPct` | 0.90 | 可调 | §1.3 超 90% 降 tier |
| `particleTotalCap[HIGH/MID/LOW]` | 300/180/90 | 锁定上限 | §3.3 同屏活跃粒子硬上限 |
| `particleDensityMult[HIGH/MID/LOW]` | 1.0/0.6/0.3 | 可调 | §3.3/§4.2 |
| `concurrentAnimCap[HIGH/MID/LOW]` | 6/4/3 | 可调 | §4.2 并发动画数 |
| `drawCallBudgetScene` | 80 | 可调 `[待验证]` | §3.1 |
| `overdrawBudget` | 2.5 | 可调 `[待验证]` | §3.4 |
| `bgTextureDensity[HIGH/MID/LOW]` | @3x / byDPR / @2x | 锁定 LOW=@2x | §3.4/§4.2 |
| `baseBundleTexBudgetMB` | 120 | 可调 `[待验证]` | §1.5 首包纹理预算 |
| `baseBundleDownloadCapMB[iOS/Android]` | 200/150 | 可调 `[待验证]` | §1.5 首包下载体积 |
| `astcBlock[bg/char/icon]` | 8×8 / 6×6 / 6×6 | 可调 `[待验证]` | §2.1 纹理压缩 block |
| `maxAtlasSize` | 2048 | 锁定 | §2.2 GLES3.0 兜底 |
| `thermalDowngradeState` | serious | 可调 | §1.4 发热降 tier |
| `assetPrefetchOnWifiChargingOnly` | true | 可调 | §2.3 补下策略 |
| `parallaxEnabled[HIGH/MID/LOW]` | true/true/false | 可调 | §4.2 视差 |
| `audioStemsFull[HIGH/MID/LOW]` | true/true/false | 可调 | §4.2 音频 stem |

> **恒定红线（不可调、无 tier）**：脉冲/闪烁频率 ≤ 0.67Hz、镜头缩放 ≤ 1%/帧、haptic ≤ `haptic_warm`（gamefeel §5 峰值封顶）；full-bleed 无黑边 cover 逻辑、safe-area 逻辑（devices §2/§3）；情感关键帧完整（gamefeel §6.2）；离线可玩闭环（DESIGN §0.2）。这些**不进可调表**。

## 7.2 `[待细化]` 汇总

- §1.1 掉帧连续尖峰容忍具体值；§1.2 冷启动各阶段实测校准。
- §1.4 idle 局部重绘（脏矩形）Flame 实现；发热降级阈值 + 回滞窗口；内存/发热双触发降 tier。
- §2.1 逐类 ASTC block size 定档 + 质检 bitrate。
- §2.3 后台补下调度器（Wi-Fi/充电判定、失败重试、iODR tag 组 / PAD feature 划分清单）。
- §3.2 Flame 压缩纹理（KTX2/ASTC）加载通道（platform channel / flutter_gpu 方案选型）。
- §4.1 DeviceTier SoC 白名单清单 + `device_info_plus` 字段映射；自适应降级/回升算法与回滞窗。
- §5.2 `visitor_interactions.json` / `postcard_templates.json` 懒加载索引结构。
- §5.3 大流水增量 audit；毕业宠 exp_log 归档冷表策略；云同步节流与冲突解决性能。
- §6.3 CI 帧率/内存基线机型 + 回归阈值；接入 devices §8.2 截图矩阵 + 黑边检测同流水。
- §7.1 `perf_config` 承载方式（JSON vs Dart 常量类）二选一，与 spec-technical §2 对齐。

## 7.3 `[待验证]` 汇总（需真机 profiling 校准）

- §1.2 冷启动/热启动各档预算实测。
- §1.3 LOW 400MB / MID 650MB / HIGH 1.0GB RSS 上限与纹理驻留实测；单场景常驻纹理换算。
- §1.4 idle 挂机温升阈值。
- §1.5 首包 200/150MB 下载体积、全量 1.2–1.8GB 总资产估算、首包 120MB 纹理预算。
- §2.1 ASTC 各 block bitrate 对顶级渲染红线的质检结论（无肉眼劣化）。
- §2.6 Spine vs 序列帧内存换算示例的真机数值。
- §3.1 draw call ≤80 / §3.4 overdraw ≤2.5× 目标真机验证。

---

## 附：与全屏参考画布的口径提示（供实现/美术核对）

- `spec-art-overview.md §2.1` 与 `spec-devices.md` 以 **`1290×2796`** 为全屏参考画布（本文件性能估算、背景内存换算均以此为准，含 overscan 后 ≈ `1680×3350` 大画布，devices §6.1）。
- `spec-art-world.md` / `spec-art-postcards.md` / `spec-art-ui.md` 内文标注 **`1080×1920`**（院子/UI）与 `1080×720`（明信片）为其局部尺寸口径。二者为**同一比例族（≈19.5:9 / 3:2）的不同标注基准**——实现时以 overview/devices 的 `1290×2796` 为渲染基准，美术域内文尺寸按 @1x 逻辑 px 等比映射。此为口径提示，非本文件裁决项，`[待细化]` 由美术总纲统一（本文件不改那几份）。

---

*—— 配套 DESIGN.md v0.3 / spec-devices.md / spec-gamefeel.md；顶级渲染是承诺，三红线是底线，性能靠「一次只养一只」的结构红利与「降华丽度不降红线」的弹性预算实现。*
