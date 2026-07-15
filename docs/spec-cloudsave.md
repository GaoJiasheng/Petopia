# Petopia 实现规格 · 云端存档同步 · v0.3 · 配套 DESIGN.md / spec-technical.md

> **状态：未来方案，当前 App Store 版本未接入云同步。** 当前生产存档为
> Session JSON + SQLite 的本地可携带归档；实施本规格时，应以该归档作为
> SavePayload 真相源。下文 `isar` 字段仅为旧版 payload 兼容名，不代表重新引入 Isar。

> 本文档是面向实现的**云端存档同步规格**（cloud save sync spec）。目标：让开发者（后续由 Codex CLI 实现）无需再猜测即可照做。
> 上游依据：`docs/DESIGN.md`（§10 数据模型、§0.3 治愈支柱）、`docs/spec-technical.md`（§1 Schema、§3 Service 契约、§4 离线防作弊、INV-1..5）。凡与本文冲突处：数据模型/不变量以 spec-technical.md 为准；同步策略以本文为准。凡本文未覆盖处回退到 spec-technical.md。
> **核心约束（不可动摇）**：纯本地存储、**无自建后端**；同步仅用**平台原生**能力——iOS 用 Apple iCloud，Android 用 Google（Play Games Saved Games / Drive AppData）。数据只存在用户自己的云空间，开发者不部署、不收集、不经手任何服务器。
> **设计支柱对齐（DESIGN §0.3）**：治愈、零焦虑。同步永远是后台静默行为，**绝不阻塞游戏、绝不弹错误焦虑、绝不丢玩家进度、绝不倒扣**。无网/未登录/配额满时纯本地照常可玩。
> 标记：`[待细化]` = 确需后续决定的实现细节；数值类已尽量给确定初值。

---

## 目录

- 0. 术语与全局约定
- 1. 平台方案选型（iCloud / Google）
- 2. 同步数据范围与打包格式（SavePayload）
- 3. 同步触发与频率（offline-first）
- 4. 冲突解决（重点：以审计流水为真相源重算）
- 5. 与 ClockService 协作（跨设备时钟差、离线收益去重）
- 6. 失败与降级
- 7. 隐私与合规
- 8. 验收标准（AT-云-x）
- 附. 待细化清单

---

## 0. 术语与全局约定

- **CloudSaveService**：新增逻辑层 Service（`lib/services/cloud_save_service.dart`），本文定义其契约。它是同步的唯一编排入口，依赖注入 `CloudBackend`（平台抽象）+ 复用 `SaveService`/`AuditService`/`ClockService`（spec-technical §3.1/3.3/3.9）。
- **CloudBackend**：平台抽象接口。两个实现：`ICloudBackend`（iOS）、`GoogleBackend`（Android）。UI/逻辑层只面向接口，平台差异下沉到 platform channel。
- **SavePayload**：一次同步的存档包（对象 + 流水 + 元信息），见 §2。
- **本地档 / 云档**：`local` = 设备 Isar+SQLite 当前档；`remote` = 云端最近一次上传的 SavePayload。
- **设备 ID `deviceId`**：首次启动生成的 UUID v4，存 `Settings`（新增字段，见 §2.4），用于冲突时标注"哪台设备写的"。永不跨设备复用。
- **同步纪元 `syncEpoch`**：单调递增整数（每次成功上传 +1），用于快速判断"云比本地新"。
- **真相源原则（继承 spec-technical §3.3）**：`ExpLogEntry` / `CurrencyLog` **只追加、不可篡改**（INV-3）。合并冲突时，**流水（logs）是真相源**，标量对象（pet.exp / wallet.balance / level / stage）永远可由流水重算得出。这是本规格全部冲突策略的地基。
- **不变量前缀**：本文用 `INV-C-x` 标注云同步专属不变量。继承 spec-technical 的 `INV-1..5`。

**云同步关键不变量：**
- `INV-C-1`：任何合并结果都必须满足 spec-technical 的 `INV-1`（`pet.exp == Σ delta`）与 `INV-4`（`wallet.balance == Σ delta`）——合并后**必须重算校验**，不通过则拒绝落地（保留本地档）。
- `INV-C-2`：合并对流水表只做**并集去重（union）**，永不删除任一侧已有日志条目（呼应 INV-3、"绝不丢进度"）。
- `INV-C-3`：合并后的任一标量（exp/level/balance/gradCount…）**不小于**本地侧与云侧各自的值——"绝不倒扣、绝不回退进度"。
- `INV-C-4`：同步失败、冲突未解、无网、未登录——**本地档保持完全可玩且不被破坏**；同步在后台重试，不阻塞任何游戏操作。

---

## 1. 平台方案选型（iCloud / Google）

> 原则：优先选**免账号登录门槛最低、容量足够、隐私范围最小**的原生方案。Petopia 单档体积很小（见 §2.5，压缩后预计 < 100 KB），不需要大容量方案。

### 1.1 iOS —— Apple iCloud

三条候选路径与取舍：

| 方案 | 机制 | 容量 | 是否需账号登录 | 取舍 |
|---|---|---|---|---|
| **A. iCloud Documents（推荐）** | 把 SavePayload 单文件写入 App 的 iCloud 容器 `Documents/`，由 iCloud 自动同步 | 计入用户 iCloud 总配额（GB 级，档案 <100KB 可忽略） | **无需显式登录**：用户系统级已登录 iCloud 即可；App 不弹登录 | 文件粒度、可整包读写、天然离线优先（本地副本先落地、系统择机上传）。最贴合"单文件存档"模型。**首选** |
| B. CloudKit（Private Database） | 把存档结构化为 CKRecord 存私有库 | 每用户私有库 1 GB+（免费额度充足） | 无需显式登录（用系统 iCloud 账号） | 记录级同步、支持 subscription 推送变更。但引入 CloudKit schema 维护成本，且更接近"后端"心智——**不必要，除非未来要跨记录查询**。MVP 不用 |
| C. NSUbiquitousKeyValueStore（KVS） | 键值小状态自动同步（上限 1 MB / 单键 1 MB） | 1 MB 总量 | 无需登录 | **仅适合极小状态**（如"最近同步纪元""是否开启云同步"这类标志）。存档主体会超限或臃肿。**仅用于同步元信息旁路**，不承载存档主体 |

**决策**：
- **存档主体走方案 A（iCloud Documents）**。
- **可选**用方案 C（KVS）承载一个轻量"云同步指针"（`{syncEpoch, deviceId, updatedAt}`），让 App 无需下载整档就能快速判断"云端是否有更新"（省流量、加速冷启动判定）。`[待细化]` KVS 指针是否引入，MVP 可直接读 Documents 文件元数据判断。

**Flutter 落地方案与取舍：**
- 首选社区插件 **`icloud_storage`**（封装 `NSFileManager` iCloud 容器 API：upload/download/list/watch）。取舍：省去手写 channel；需评估维护活跃度与 API 稳定性。`[待细化]` 锁定插件版本或 fork。
- 兜底/更可控：**自建 platform channel**（`MethodChannel('petopia/icloud')`）直接调 `FileManager.default.url(forUbiquityContainerIdentifier:)` + `NSMetadataQuery` 监听。取舍：可控但需写 Swift，工作量大。
- **Entitlement 要求**：`com.apple.developer.icloud-container-identifiers` + `com.apple.developer.icloud-services = CloudDocuments`（若用 A）/ `CloudKit`（若用 B）；在 Xcode 开 iCloud capability，容器 ID 形如 `iCloud.com.<org>.petopia`。`[待细化]` 容器 ID。

**隐私范围（iOS）**：数据存于**用户自己的 iCloud 私有空间**（App 私有容器，其他 App 不可见，开发者无法通过任何后端读取）。无需 App 内账号、无需登录 UI。

### 1.2 Android —— Google

两条候选路径与取舍：

| 方案 | 机制 | 容量 | 是否需账号登录 | 取舍 |
|---|---|---|---|---|
| **A. Play Games Services — Saved Games（Snapshots，推荐）** | 存档作为"快照"（snapshot）存入 Google Play Games 云；自带描述、封面图、playedTime 元数据 | 每快照 ≤ 3 MB（数据）+ 800 KB 封面；多快照 | **需要 Google Play Games 登录**（一次性授权，静默重登） | 专为游戏存档设计、自带冲突检测 API（返回 conflict + base/remote 两份让 App 合并）。最贴合游戏心智。**首选**。取舍：需接入 Play Games SDK、需玩家有 Google 账号 |
| B. Google Drive — AppData folder | 存档写入 Drive 隐藏的 `appDataFolder`（App 专属、用户不可见、卸载可留存/清理） | AppData 计入用户 Drive 配额，App 专属区 ~ 无实际压力 | 需 Google 账号 + Drive AppData scope 授权 | 更通用、不依赖 Play Games。取舍：需 OAuth 同意 Drive scope（隐私提示更重），无游戏专属冲突 API，需自管冲突 |

**决策**：
- **首选方案 A（Play Games Saved Games / Snapshots）**：与"游戏存档"语义最契合，且**自带冲突返回机制**（open snapshot 时若检测到冲突，SDK 返回两份数据交由 App 合并——正好喂给我们 §4 的合并器）。
- **方案 B 作为 `[待细化]` 备选**：若不想强依赖 Play Games（如为出海无 GMS 设备预留），可切 Drive AppData。二者都实现同一 `CloudBackend` 接口。

**Flutter 落地方案与取舍：**
- Play Games：社区插件 **`games_services`**（封装 Saved Games：saveGame / loadGame / getSavedGames）或自建 channel 调 `com.google.android.gms.games.SnapshotsClient`。取舍：插件对 snapshot 冲突解析支持深度需评估，冲突分支很可能要自建 channel 暴露 `SnapshotConflict`。`[待细化]`。
- Drive AppData（若走 B）：`googleapis` + `google_sign_in`（scope `drive.appdata`）。
- **配置要求**：Play Console 配置 Play Games Services、OAuth client、SHA-1 指纹；App 内 Play Games 登录流程。`[待细化]` 具体配置项。

**隐私范围（Android）**：Saved Games 存于**用户自己的 Google Play Games 云空间**（App 专属、开发者无后端读取）。需一次 Google Play Games 登录授权（比 iCloud 多一步，属平台约束）；Drive AppData 方案则需 Drive AppData scope。

### 1.3 跨平台对照小结

| 维度 | iOS（iCloud Documents） | Android（Play Games Snapshots） |
|---|---|---|
| 容量 | 用户 iCloud 配额（档 <100KB 无压力） | ≤3 MB/快照（充足） |
| 显式登录 | **不需要**（系统级 iCloud） | **需要**（Play Games 一次性登录） |
| 冲突检测 | App 自管（比对元信息 + §4 合并） | SDK 返回 conflict base/remote，App 合并 |
| 隐私 | App 私有 iCloud 容器 | Play Games 云 / Drive AppData |
| 兜底 | KVS 指针（可选） | Drive AppData（可选） |

> **不做**：不搭任何自建服务器；不做 iOS↔Android 跨生态同步（Apple 与 Google 云不互通，跨生态迁移走 §6 的本地导入/导出兜底文件）。

---

## 2. 同步数据范围与打包格式（SavePayload）

### 2.1 同步什么（进云）

同步的是**完整可重建存档**，即 spec-technical §1 的全部持久化状态：

**Isar 对象型（§1.3）——全部同步：**
- `Pet`（当前在养 + 所有历史宠物：level/exp/state/personality/pastNames/nextRevisitAt…）
- `CurrencyWallet`（balance）
- `YardState`（luxuryStage/gradCount/主题/装饰/格位/foodTray/ownedPerks）
- `Journey`（旅程与漫游状态）
- `ClueCounter`（彩蛋线索计数，含 visitorSeen）
- `AchievementProgress`（成就进度/解锁/发奖标志）
- `VisitorLogEntry`（来客图鉴）
- `ScheduledJob`（日程队列——`[待细化]` 是否同步：见下"边界讨论"）
- `Settings`（**部分字段**同步，见 §2.3 拆分）

**SQLite 流水型（§1.4）——全部同步（合并核心）：**
- `exp_log`（ExpLogEntry，**只追加**，冲突并集去重的主力）
- `currency_log`（CurrencyLog，**只追加**）
- `postcard`（明信片，追加型，视为不可变记录）
- `event_log`（EventLogEntry，追加型）

### 2.2 不同步什么（设备本地，留在本机）

- **纯设备偏好**：`Settings.notifications`、`Settings.sound`（每台设备独立，换机不该被覆盖）——归入"本地设置分区"，不进 SavePayload。
- **反作弊时钟锚点**：`Settings.lastMonotonicRef`、`lastMonotonicRef` 相关的单调时钟基准（§4：单调时钟是**进程/设备本地**概念，跨设备无意义，同步会污染）。**绝不同步**。见 §5。
- **运行期缓存**：`ContentRepository` 内存内容（来自只读 assets，不属存档）、Flame 场景状态、已渲染图片缓存、通知 pending 队列。
- **静态内容 assets**（species.json 等）：随 App 包分发，非玩家数据。

### 2.3 Settings 字段的同步/本地拆分（钉死）

| 字段 | 同步? | 理由 |
|---|---|---|
| schemaVersion | ✅ | 迁移对齐必须 |
| createdAt | ✅ | 存档身份 |
| loginStreakCurrent / Max / lastLoginDay | ✅ | 属玩家进度（成就 ach_login_30 依赖） |
| notifications / sound | ❌ | 设备偏好 |
| lastMonotonicRef / lastWallClockAt | ❌ | 设备本地时钟锚点（§4/§5） |
| deviceId（新增） | ❌ | 每设备唯一 |
| cloudSyncEnabled（新增） | ❌ | 每设备开关 |

> **实现建议**：把 `Settings` 拆成"可同步子集"与"设备本地子集"两块，序列化 SavePayload 时只取可同步子集，避免设备偏好被覆盖。`[待细化]` 拆表或加字段标注。

**边界讨论 —— `ScheduledJob` 是否同步**：`[待细化]`。倾向**不同步**或**同步但落地后重建**：日程是"当天将发生什么"的调度快照，跨设备/跨时刻语义弱，且 EventScheduler 在 `onResume` 会 catch-up 补种（spec-technical §3.4）。保守做法：同步 SavePayload 时**丢弃对方的 ScheduledJob，以本地 catch-up 重建**，避免同一天事件在两设备双发。这不破坏任何流水真相（事件是否真的发生以 `event_log` 为准）。

### 2.4 SavePayload 打包格式

```jsonc
// SavePayload（顶层）
{
  "manifest": {
    "payloadSchemaVersion": 1,          // 本 payload 结构版本（独立于 game schemaVersion）
    "gameSchemaVersion": 1,             // = Settings.schemaVersion（迁移对齐）
    "deviceId": "uuid",                 // 写入此包的设备
    "syncEpoch": 42,                    // 该设备上传时的纪元（单调递增）
    "createdAt": "ISO8601 UTC",         // 存档创建时间（身份）
    "uploadedAt": "ISO8601 UTC",        // 本次上传时刻（ClockService.now，仅参考不作真相）
    "logCounts": { "exp":1234, "currency":88, "postcard":57, "event":301 },  // 快速校验
    "checksum": "sha256(payload.body)"  // body 完整性校验（复用 SaveService.export 的 checksum 口径）
  },
  "body": {
    "isar": {
      "pets": [ /* Pet[] */ ],
      "wallet": { /* CurrencyWallet */ },
      "yard": { /* YardState */ },
      "journeys": [ /* Journey[] */ ],
      "clueCounters": [ /* ClueCounter[] */ ],
      "achievements": [ /* AchievementProgress[] */ ],
      "visitorLog": [ /* VisitorLogEntry[] */ ],
      "settingsSyncable": { /* §2.3 可同步子集 */ }
      // scheduledJobs: 见 §2.3 边界讨论，默认不含
    },
    "logs": {
      "exp": [ /* ExpLogEntry rows，含 id(uuid) */ ],
      "currency": [ /* CurrencyLog rows */ ],
      "postcard": [ /* Postcard rows */ ],
      "event": [ /* EventLogEntry rows */ ]
    }
  }
}
```

- **格式**：JSON（UTF-8）→ **gzip 压缩** → 上传（iCloud 文件名 `petopia_save.json.gz`；Play Games 作为 snapshot bytes）。
- **checksum**：沿用 spec-technical §3.9 `SaveService.export` 的 checksum 机制，保证下载完整性。
- **id 稳定性**：所有流水行主键为 UUID v4（spec-technical §0），**跨设备天然不碰撞**——这是 §4 并集去重的前提（同一条日志在两设备有相同 id 当且仅当它是同一条被上传下载复制的记录；不同设备各自产生的新日志 id 必不同）。

### 2.5 体积估算

| 部分 | 估算 | 说明 |
|---|---|---|
| Pet[] | ~1–2 KB × 历史只数 | 12 只满图鉴 ≈ 20 KB |
| YardState/Journey/Clue/Achievement/VisitorLog | ~10–20 KB | 中期存档 |
| exp_log | 每条 ~120 B；单只全生命周期 ~200–400 条 → ~40 KB/只 | **最大项**。12 只 ≈ 300–500 KB 原始 |
| currency/event/postcard log | ~50–100 KB | postcard body_text 定稿是文本大头 |
| **合计原始** | **~0.4–0.7 MB**（重度多宠存档） | 早期单宠存档仅几十 KB |
| **gzip 后** | **~80–150 KB**（文本高压缩比） | 远低于 iCloud 无压力 / Play Games 3 MB 上限 |

> 结论：单文件方案完全够用，无需分片。若未来极重度存档逼近上限：`[待细化]` 对历史宠物流水做"归档冷分片"（毕业宠 log 单独打包、按需下载）。MVP 不做。

---

## 3. 同步触发与频率（offline-first）

**总纲：offline-first。** 本地永远是权威工作副本；写操作先落本地（复用 spec-technical §3.9 `SaveService.autoSave`，debounce 1500ms），云同步是**其后**的异步后台动作。网络恢复后补传。任何同步失败都不回滚本地、不弹错。

### 3.1 触发点（钉死）

| 触发 | 动作 | 说明 |
|---|---|---|
| **冷启动 / 从后台恢复（onResume）** | 先 `pullAndMerge()`（拉云端→合并→重算校验），再照常进游戏 | 先拉后玩，尽量用最新档；拉取失败则直接用本地（不阻塞，见 §6） |
| **关键事件后**（毕业结算 / 领养新宠 / 商店购买 / 成就解锁 / 彩蛋解锁 / 收到明信片） | 触发一次 `pushDebounced()` | 这些是"心疼丢失"的进度节点，尽快上云 |
| **进入后台（onPause / AppLifecycleState.paused）** | `flush()` 立即 push 当前档 | 用户切走时把最新状态推上去，是最重要的一次上传窗口 |
| **周期性**（前台每 `periodicPushMinutes` 分钟） | 若自上次成功 push 后本地有变更，push | 兜底，防长时间前台不触发关键事件 |
| **网络恢复**（connectivity 从无到有） | 若有 pending 上传，补传；并 `pull` 一次 | offline-first 的"补传"环节 |

**常量（新增，建议并入 game_config §2.10 存档区）：**

| 常量 | 初值 | 属性 | 含义 |
|---|---|---|---|
| cloudSyncEnabled | true | 可调 | 全局开关（用户可关，见 §6/§7） |
| pushDebounceMs | 3000 | 可调 | 关键事件后合并抖动窗（比本地 autoSave 1500ms 长，减少上传次数） |
| periodicPushMinutes | 10 | 可调 | 前台周期兜底上传间隔 |
| pullOnResume | true | 锁定 | 恢复时先拉 |
| maxPushRetry | ∞（指数退避封顶） | 锁定 | 失败静默重试，永不放弃，永不弹错 |
| pushRetryBackoffSec | 5→10→30→60→300（封顶） | 可调 | 指数退避 |

### 3.2 CloudSaveService 契约

```dart
class CloudSaveService {
  /// 是否已具备同步条件（iCloud 可用 / Play Games 已登录 + 有网 + 开关开）。
  Future<bool> isAvailable();

  /// 拉云端并合并到本地。返回合并结果（含是否发生冲突合并、重算是否通过）。
  Future<SyncResult> pullAndMerge();

  /// 把当前本地档打包上传（debounce）。失败进重试队列，不抛给调用方。
  Future<void> pushDebounced();

  /// 立即上传（onPause 用）。
  Future<void> flush();

  /// 网络恢复回调：补传 + pull。
  Future<void> onConnectivityRestored();

  Stream<CloudSyncStatus> statusStream;   // UI 只读展示：idle/syncing/offline/conflictMerged/error
}

class SyncResult {
  bool pulled;             // 是否成功拉到云档
  bool merged;             // 是否执行了合并（本地与云存在差异）
  bool recomputed;         // 是否触发了流水重算（INV-C-1）
  bool invariantsOk;       // 重算后 INV-1/4 是否通过
  int  newExpLogs;         // 本次并入的新 exp 日志条数
  int  newCurrencyLogs;
  List<String> notes;      // debug
}

enum CloudSyncStatus { idle, syncing, offline, conflictMerged, error }
```

> **UI 约束（DESIGN §0.3 零焦虑）**：`statusStream` 仅供一个**极轻量、非模态**的指示（如设置页一行"上次同步：3 分钟前"或角标小云朵）。**绝不**弹同步失败对话框、绝不红字、绝不阻塞。`error` 态在 UI 上表现为"稍后自动重试"，不惊扰玩家。

### 3.3 CloudBackend 抽象接口

```dart
abstract class CloudBackend {
  Future<bool> isAvailable();                       // iCloud on / Play Games signed-in
  Future<RemoteMeta?> readMeta();                   // 只读元信息（syncEpoch/deviceId/uploadedAt/checksum），省流量
  Future<SavePayload?> download();                  // 下载整包（含平台冲突分支处理，见下）
  Future<void> upload(SavePayload payload);         // 上传整包
  Stream<void> remoteChanges();                     // 可选：iCloud NSMetadataQuery / Play Games 无则轮询
}
```
- **iOS `ICloudBackend`**：download/upload = iCloud Documents 文件读写；readMeta 读文件属性或 KVS 指针；remoteChanges = `NSMetadataQuery`。无平台层冲突分支（靠 §4 自管）。
- **Android `GoogleBackend`**：download = open snapshot——**若 SDK 报 conflict**，把 base/remote 两份都取回，交 §4 合并后 `resolveConflict` 回写；upload = commit snapshot。

---

## 4. 冲突解决（重点）

> **心法（对齐 DESIGN §0.3、spec-technical §3.3）**：**宁可保守合并，绝不丢玩家进度，绝不倒扣。** 冲突不是"二选一覆盖"，而是"把两台设备发生过的事都保留下来，再以审计流水为真相源重算标量"。这正是 Petopia 数据模型的红利——**只追加的流水（INV-3）让合并变成可交换的并集运算**。

### 4.1 冲突为什么可解：流水即真相源

- `pet.exp` / `wallet.balance` 从来不是"权威数字"——它们是**流水的派生投影**（INV-1：`exp==Σdelta`；INV-4：`balance==Σdelta`）。
- 因此合并两台设备时，**不比较 exp 数字谁大**，而是**合并两侧的 exp_log 并集，然后重算 exp**。两台设备各自离线赚的经验都会被完整保留、相加，天然"绝不丢进度、绝不倒扣"。
- 流水行 id 是 UUID v4（跨设备不碰撞），所以**并集去重 = 按 id 去重的 union**，幂等、可交换、可结合——多设备任意顺序合并结果一致。

### 4.2 三类数据的合并策略

| 数据类 | 合并策略 |
|---|---|
| **只追加流水**（exp_log / currency_log / postcard / event_log） | **按 id 并集去重（union-by-id）**。`merged = local ∪ remote`，同 id 取任一份（内容相同）。绝不删除（INV-C-2）。 |
| **派生标量**（pet.exp / level / stage / wallet.balance） | **不直接合并**——合并完流水后**从流水重算**（复用 `ExpEngine.deriveLevel` / `deriveStage`、`AuditService` 的 Σ 逻辑）。得到的值必 ≥ 两侧（INV-C-3）。 |
| **非流水标量状态**（YardState.gradCount/luxuryStage、ClueCounter.count、AchievementProgress.progress、loginStreak、Journey.currentIdx、Pet.state/nextRevisitAt/pastNames…） | **带设备时钟的字段级规则**，见 §4.3。核心：**取"进度更大/更靠前"的一侧**，宁可多不可少。 |

### 4.3 非流水标量的字段级合并规则（钉死）

原则：**每个字段选"代表更多进度"的值**（monotonic-merge），冲突时偏向玩家。

| 字段 | 规则 | 理由 |
|---|---|---|
| `YardState.gradCount` | **max(local, remote)** | 毕业数只增；派生 luxuryStage 也随之 max（INV-C-3） |
| `YardState.luxuryStage` | 由合并后 gradCount 重新派生（spec-technical §1.3 阶段表） | 保持派生一致，不独立存 |
| `YardState.ownedThemeIds / ownedDecorIds / ownedPerks` | **并集（union）** | 拥有物只增不减；两设备各买的都保留 |
| `YardState.activeThemeId / slots / foodTray` | 取 `uploadedAt` **更晚**一侧（末次写入者胜，LWW） | 布置类偏好，用 payload 元信息时间裁决；无进度损失 |
| `ClueCounter.count` | **max**；`visitorSeen` = **OR** | 彩蛋进度只增 |
| `AchievementProgress.progress` | **max**；`unlockedAt` = 取非空且更早者；`rewardClaimed` = **OR** | 进度只增；已解锁不回退；发奖幂等（防两设备重复发→见 §4.5） |
| `Settings.loginStreakCurrent` | **max**；`loginStreakMax` = **max**；`lastLoginDay` = 更晚 | 连续登录取更优 |
| `Pet.exp/level/stage` | **由重算得出**（不字段合并） | §4.2 |
| `Pet.state` | 状态机择优：`GRADUATED > REVISITING > ROAMING > TRAVELING > RAISING`（更"晚期"胜）；但**在养唯一性**须满足 INV-2 | 毕业不可逆；避免把已毕业宠拉回在养 |
| `Pet.pastNames` | **并集去重** | 名字记录只增（ach_h_allnames 依赖） |
| `Pet.nextRevisitAt` | 取更晚 payload 一侧 | 回访调度，无进度含义 |
| `Journey.currentIdx / state` | currentIdx = **max**；state 择"更靠后"（DONE/WANDERING > ACTIVE） | 旅程只前进 |
| `Journey.stops` | 若同 journeyId 则以 createdAt 早的一份为准（旅程生成即固定） | 旅程站点在毕业时定稿，不该变 |

> **INV-2 在养唯一性的守护**：合并后若出现 >1 只 `RAISING`（例如：设备 A 还在养旧宠、设备 B 已让它毕业并领养了新宠），按"更晚期状态胜"：被判定已 `GRADUATED` 的那只置毕业，另一只（新领养）保留在养。若两侧各领养了**不同**新宠（罕见：都在毕业后离线领养），`[待细化]` 保守策略：保留 `uploadedAt` 更晚一侧的在养宠为当前在养，另一只转为"待处理"并**不丢弃其流水**（其 exp_log 仍并入，重算保留其进度），下次由玩家在 UI 选择或自动按 bornAt 归档。**绝不删任何一只宠物或其流水。**

### 4.4 合并算法（伪代码）

```pseudo
mergeSaves(local: SavePayload, remote: SavePayload) -> MergedSave:
    # ── 1. 流水并集去重（真相源）──
    expLogs  = unionById(local.logs.exp,  remote.logs.exp)
    curLogs  = unionById(local.logs.currency, remote.logs.currency)
    postcards= unionById(local.logs.postcard, remote.logs.postcard)
    eventLogs= unionById(local.logs.event, remote.logs.event)

    # ── 2. 对象按 id 配对合并 ──
    pets = {}
    for id in keys(local.pets) ∪ keys(remote.pets):
        pets[id] = mergePet(local.pets[id], remote.pets[id])   # 字段级 §4.3；exp/level 先占位，第3步重算
    wallet = { }   # balance 占位，第3步重算
    yard   = mergeYard(local.yard, remote.yard)                # §4.3
    clues  = mergeByKey(local.clues, remote.clues, max+OR)
    achs   = mergeByKey(local.achs,  remote.achs,  max+earliestUnlock+OR)
    journeys = mergeJourneys(local.journeys, remote.journeys)
    visitorLog = unionById(local.visitorLog, remote.visitorLog)
    settings = mergeSyncableSettings(local, remote)            # loginStreak max 等
    # scheduledJobs: 丢弃两侧，落地后由 EventScheduler.catchUp 重建（§2.3）

    # ── 3. 以流水为真相源重算派生标量（INV-C-1 / INV-1 / INV-4）──
    for pet in pets.values:
        pet.exp   = Σ(expLogs where pet_id==pet.id).delta
        pet.level = ExpEngine.deriveLevel(pet.exp)
        pet.stage = ExpEngine.deriveStage(pet.level)
        assert pet.exp >= max(local.pets[id]?.exp ?? 0, remote.pets[id]?.exp ?? 0)  # INV-C-3
    wallet.balance = Σ(curLogs).delta
    assert wallet.balance == Σ(curLogs).delta                  # INV-4

    merged = assemble(pets, wallet, yard, clues, achs, journeys, visitorLog, settings,
                      expLogs, curLogs, postcards, eventLogs)

    # ── 4. 最终不变量校验（复用 AuditService.verifyOnStartup 口径）──
    report = AuditService.verify(merged)                       # INV-1 / INV-4
    if not report.ok:
        # 极端：重算后仍不一致（理论不应发生）→ 保守：以 Σlog 为准强制回正（trust log），记 note
        merged = coerceToLogs(merged); assert AuditService.verify(merged).ok
    return merged
```

**`unionById`**：
```pseudo
unionById(a, b):
    m = {}
    for row in a: m[row.id] = row
    for row in b: m.putIfAbsent(row.id, row)   # 同 id 取已有（内容一致，幂等）
    return m.values
```

### 4.5 冲突场景枚举与处理

| # | 场景 | 处理 | 保证 |
|---|---|---|---|
| C1 | **换机迁移**（旧机停用，新机首次登录同款云） | 新机 `pullAndMerge`：本地空档 ∪ 云档 = 云档；重算校验通过 | 完整迁移，进度一字不差 |
| C2 | **双设备交替**（A 玩→上传→B 拉→玩→上传→A 拉） | 每次 pull 都 union 双方新增流水 + 重算 | 两设备的进度累加，INV 全过 |
| C3 | **离线后并发编辑**（A/B 都离线各玩各的，先后上线上传） | 后上传者的 remote 与本地 union；exp_log 各自的离线段都保留、相加 | **两段离线经验都不丢**（受各自每日上限约束，见 §5） |
| C4 | **同一动作在两设备被记两次**（网络分区下重复操作） | 不同设备产生不同 id → union 后是**两条**合法流水（确实做了两次动作） | 不是 bug：玩家确实在两台设备各喂了一次。绝不去重误伤 |
| C5 | **成就在两设备各自解锁并发奖** | AchievementProgress.rewardClaimed=OR；发奖走 currency_log——若两设备各写了一条 ACHIEVEMENT earn（不同 id），union 后是两条 → **重复发奖** | `[待细化]` 见下"发奖去重" |
| C6 | **一台已让宠物毕业，另一台还在养同一只** | Pet.state 择"更晚期"→ 该宠置 GRADUATED；毕业结算的 currency_log（若两侧各结算过）见 C5 处理 | 毕业不可逆，进度不丢 |
| C7 | **两设备各领养了不同新宠** | §4.3 INV-2 守护：保留晚上传一方为在养，另一只归档不删流水 | 绝不删宠、不删流水 |
| C8 | **schemaVersion 不一致**（一设备已升级 App） | 低版本设备**拒绝合并高版本 payload**（manifest.gameSchemaVersion > 本地支持）→ 提示"请更新 App"，纯本地继续玩 | 不因版本错位破坏档 |
| C9 | **checksum 校验失败 / 下载损坏** | 视为"无云档"，跳过合并用本地，静默重试下载 | 不破坏本地 |

**发奖去重（C5，重要，`[待细化]` 落地）**：
- 问题根因：**同一逻辑发奖事件**在两设备各生成了一条 `id` 不同的 currency_log，union 无法识别其为"同一次奖励"。
- 方案：为**幂等性敏感的收入类流水**（ACHIEVEMENT / GRADUATION / LEVEL_UP）在 `CurrencyLog.ref` 上写**确定性去重键**（如 `ach:<achievementId>`、`grad:<petId>`、`levelup:<petId>:<level>`）。合并时对这些 reason 的行**按 (reason, ref) 二次去重**（保留一条），而非仅按 id。
- 这需要 spec-technical §3.8 `EconomyService.earn` 在发这些奖时**填稳定 ref**（目前 §3.8 已支持 `ref` 参数——本规格要求：成就/毕业/升级发奖必须写稳定 ref）。`[待细化]` 在 spec-technical 侧确认 ref 命名约定；本文先钉死"幂等奖励按 (reason,ref) 去重"这一合并规则。
- 消费类（SHOP_PURCHASE）与动作类经验（FEED/PAT…）**不做二次去重**——它们本就是"每次真实发生"的独立事件（对应 C4）。

---

## 5. 与 ClockService 协作

> 跨设备同步引入两个时间风险：①两设备系统时钟不一致（时钟差）；②离线收益在两设备重复结算。核心防护仍是 spec-technical §3.1/§4 的既有机制，本节明确同步语境下的增量规则。

### 5.1 单调时钟锚点绝不同步（钉死）

- `Settings.lastMonotonicRef` / 单调计时基准是**设备/进程本地**概念（`Stopwatch` 杀进程即失效、平台单调时钟重启失效——spec-technical §4.1）。**它在另一台设备上毫无意义**。
- 因此（§2.2/§2.3）**这些字段绝不进 SavePayload**。合并后每台设备**用自己的**单调锚点结算离线，互不干扰。
- `lastOnlineAt`（Pet 字段，§1.3）：它**是**存档的一部分（renew 锚点），会随 Pet 同步。但离线结算的**可信时长**由本机 `ClockService.resolveOfflineElapsed(min(wall, mono))` 决定（§4.2）——即便同步进来的 `lastOnlineAt` 来自另一台时钟不同的设备，本机也用"wall 与本机 mono 取小 + 上限钳制"防超发。

### 5.2 离线收益重复结算的防护

风险：设备 A 离线 5h 领了 +5，把档同步到 B；B 也从这个 `lastOnlineAt` 再算一次离线 → 重复发。

**防护链（多重、纵深）：**
1. **每日上限硬顶（最强防线，既有 spec-technical §3.2/§4）**：离线经验受 `offlineDailyCap=12`（慵懒 13）约束，且 `offlineExpGrantedToday` + `offlineDayKey` 随 Pet 同步（属存档）。合并时 `offlineExpGrantedToday` 取 **max**（§4.3 追加规则）、`offlineDayKey` 取更晚——**同一自然日内，两设备离线经验合计不超过 12**。这从根上封死"同一时段重复结算"的收益。
2. **合并即 renew**：合并落地后，把当前在养宠的 `lastOnlineAt` renew 为 `ClockService.now()`（本机可信 now），使"上次同步前的离线时段"不会被本机再次计入（§3.2 renew 语义）。
3. **流水真相源兜底**：即使某条离线 exp_log 被并入两次的错觉——实际上它是**同一条 id**（若来自同步复制）→ union 去重掉；若是两设备**各自独立**产生的离线 log（不同 id、不同时段），那是两段真实离线，理应保留，但被防线 1 的每日上限钳住总量。

**合并时 offline 相关字段规则（补 §4.3）：**
| 字段 | 规则 |
|---|---|
| `Pet.offlineExpGrantedToday` | **max(local, remote)**（同日内更保守，防重复领满后又领） |
| `Pet.offlineDayKey` | 取更晚（更晚日 = 更接近当前，配合 §3.2 跨日归零） |
| `Pet.lastOnlineAt` | 合并落地后 **renew 为本机 now**（不取两侧值，避免用他机时钟污染本机离线判定） |

### 5.3 时钟差的容忍

- payload `manifest.uploadedAt` 仅作**参考排序**（判断哪份"更晚写"用于 LWW 字段 §4.3），**绝不**作为发经验/发奖的时间真相。
- 一切离线时长仍由本机 `ClockService` 用本机 wall+mono 交叉校验得出（spec-technical §4.2），`clockDriftForgiveSec=120s` 容忍窗照旧生效。
- **结论**：跨设备时钟差不会导致超发——因为经验从不按"两设备时间戳之差"计算，只按本机可信时长 + 每日硬上限。

---

## 6. 失败与降级

> **铁律（DESIGN §0.3 零焦虑 / INV-C-4）**：同步永远可失败、可缺席；**纯本地照常可玩，同步静默重试，绝不阻塞游戏、绝不弹错。**

### 6.1 降级矩阵

| 情形 | 表现 | 玩家可感知度 |
|---|---|---|
| **无 iCloud**（iOS 未登录系统 iCloud / 关了本 App 的 iCloud） | `isAvailable()=false`；不上传不下载；纯本地玩 | 设置页一行灰字"iCloud 未开启，进度仅存本机"；无弹窗 |
| **未登录 Google**（Android 未登录 Play Games） | 同上；可在设置页提供"登录以启用云同步"按钮（用户主动点才走登录流程） | 不主动弹登录；不打扰 |
| **无网络** | push 进重试队列（指数退避）；pull 跳过用本地；连上后补传（§3.1 网络恢复） | `status=offline`，轻角标；无弹窗 |
| **配额满**（iCloud 满 / Play Games 异常） | 上传失败 → 重试队列静默退避重试；本地不受影响 | 长期失败时设置页可显"云空间可能已满"轻提示；不阻塞 |
| **checksum / 反序列化失败** | 视为无云档（C9）；用本地；静默重试下载 | 无感知 |
| **schemaVersion 过高**（C8） | 拒绝合并，纯本地玩，提示更新 App | 温和提示"更新后可同步"，非阻塞 |

### 6.2 本地导入/导出兜底（必须保留）

- **完整保留** spec-technical §3.9 `SaveService.export()` / `import()` 的本地文件导入导出。
- 用途：①**跨生态迁移**（iOS↔Android，两云不互通，唯一桥）；②云同步彻底不可用时的**手动搬档**；③给不想用云的隐私敏感玩家的兜底。
- 导入语义仍为**覆盖式**（spec-technical §3.9：单宠位无合并语义）——但导入后必跑 `AuditService.verifyOnStartup`（INV-1/4）。
- `[待细化]`：是否提供"从导入文件与本地/云三方合并"的高级选项——MVP **不做**，导入即覆盖，简单可预期。

### 6.3 失败不破坏本地的实现约束

- `pushDebounced` / `flush` 失败**绝不回滚本地档**、绝不抛异常给游戏逻辑层（吞掉→进重试队列→`status=error` 仅供 UI 轻展示）。
- `pullAndMerge` 中，合并结果**先在内存/临时事务中重算校验 INV**，**通过后才原子替换本地档**；不通过则**丢弃合并结果、保留本地档**（INV-C-4）。合并落地复用 `SaveService` 的双备份 + 事务（spec-technical §3.9），失败回滚到合并前。

---

## 7. 隐私与合规

- **无自建后端、不收集数据**：Petopia 不部署任何服务器，不设 App 内账号体系。玩家存档**只存在于玩家自己的 iCloud（Apple 私有容器）或 Google（Play Games 云 / Drive AppData）空间**。开发者**无任何技术手段**读取、聚合、分析这些数据。
- **数据流向单一**：设备 ↔ 用户自己的云，端到端在用户账号私域内，不经开发者中转。
- **上架隐私声明（对齐应用商店要求）**：
  - App Store「App 隐私」/ Google Play「数据安全」表单：可如实声明**不收集用户数据**（No data collected）；云存档属"用户自有云空间的本地功能扩展"，非"开发者收集"。`[待细化]` 按最新审核口径确认 iCloud/Play Games 存档是否需在表单单列（通常归为"App 功能"而非"数据收集"）。
  - 无需隐私政策中的"数据共享/第三方 SDK 收集"条目（除 Play Games SDK 本身的 Google 条款——引用 Google 既有政策即可）。
- **用户可控**：`cloudSyncEnabled` 开关让玩家随时关闭云同步（关闭仅停止上传下载，不删本地档、不删云档）；提供"仅本地"模式，尊重隐私敏感玩家。`[待细化]` 是否提供"删除云端存档"入口（走平台 API 删除用户自己云里的文件）。
- **最小权限**：iOS 仅申请 iCloud 容器 entitlement；Android 仅申请 Play Games（或 Drive AppData 单一 scope），不申请通讯录/位置等无关权限。

---

## 8. 验收标准（AT-云-x）

> 每条可测试。逻辑层（合并器、重算、去重）100% 可离线单测（注入假 `CloudBackend` + 假 `Clock`，复用 spec-technical §7 测试基建）。

### 8.1 迁移与基本同步
- **AT-云1（换机迁移）**：新机空档 `pullAndMerge` 一份重度云档 → 本地 = 云档完整还原；`INV-1/4` 通过；宠物数/明信片数/暖绒/成就与云档逐字段一致。
- **AT-云2（上传往返 round-trip）**：本地档 `flush` 上传 → 另一实例 `download` → payload checksum 校验通过、logCounts 匹配、反序列化后数据等价。
- **AT-云3（关键事件触发上传）**：毕业结算后 `pushDebounced` 在 debounce 窗内触发一次 upload（用假 backend 断言 upload 被调用 1 次）。

### 8.2 双设备与合并
- **AT-云4（双设备交替）**：A 玩得 +100exp 上传；B 拉取合并后再 +80exp 上传；A 再拉取 → A 本地 exp = 两段之和（重算自 union 流水）；`INV-1` 通过、值 ≥ 两侧（`INV-C-3`）。
- **AT-云5（离线后并发合并）**：A、B 各离线产生一段 offline exp_log（不同 id）→ 合并 union 后两条都在；但同一自然日内 `offlineExpGrantedToday` 取 max、离线经验总量 ≤ 每日上限（`AT-离3` 口径不被击穿）。
- **AT-云6（流水并集幂等/可交换）**：`merge(merge(A,B),C) == merge(A,merge(B,C))`；重复 `merge(A,A)==A`（同 id 去重，幂等）。
- **AT-云7（重复动作不误删）**：两设备各产生一条 FEED exp_log（不同 id）→ 合并保留两条（C4，确为两次真实动作）。

### 8.3 冲突不丢档 / 不变量
- **AT-云8（冲突合并后 INV 恒成立）**：随机构造两份有交叠与分叉的 payload，合并后断言 `INV-1`（每宠 exp==Σdelta）、`INV-4`（balance==Σdelta）恒成立；任一标量 ≥ 两侧（`INV-C-3`）；无流水被删（`INV-C-2`）。
- **AT-云9（毕业不可逆）**：A 已让宠毕业、B 仍在养该宠 → 合并后该宠 state=GRADUATED，其 exp_log 全保留，in-养唯一性 `INV-2` 满足。
- **AT-云10（两设备各领养新宠）**：合并后无 >1 只 RAISING（`INV-2`）；两只宠及其全部流水都保留、不删。
- **AT-云11（发奖去重）**：同一成就在两设备各写一条 `reason=ACHIEVEMENT, ref=ach:<id>` 的 currency_log（不同行 id）→ 合并按 (reason,ref) 二次去重，仅保留一条，暖绒不翻倍；balance==Σ(去重后 delta)。
- **AT-云12（消费不被误去重）**：两次真实 SHOP_PURCHASE（同商品、不同时刻）→ 合并保留两条，暖绒正确扣两次。

### 8.4 时钟协作
- **AT-云13（跨设备时钟差不超发）**：合并进来的 `lastOnlineAt` 来自快 3 小时的设备 → 本机离线结算仍按本机 wall+mono 取小 + 上限钳制，不超发；改表回拨分支 gain=0（复用 `AT-离5`）。
- **AT-云14（单调锚点不同步）**：断言 SavePayload 不含 `lastMonotonicRef`/`lastWallClockAt`/`deviceId`/`notifications`/`sound`（§2.2/§2.3）；合并后本机这些字段保持本机值。

### 8.5 失败与降级
- **AT-云15（无网不阻塞）**：`isAvailable()=false`/网络异常时，所有游戏操作正常、本地存档正常；push 进重试队列，`status=offline`，无异常抛到逻辑层（`INV-C-4`）。
- **AT-云16（合并校验失败保留本地）**：注入一份会导致重算 INV 不通过的损坏云档 → `pullAndMerge` 丢弃合并结果、保留本地档、`invariantsOk=false`、本地可玩。
- **AT-云17（checksum 失败）**：下载包 checksum 不符 → 视为无云档，用本地，静默重试，不破坏本地。
- **AT-云18（schemaVersion 过高）**：云 payload `gameSchemaVersion` > 本地支持 → 拒绝合并，纯本地继续，给非阻塞更新提示。
- **AT-云19（本地导入导出兜底）**：云不可用时 `SaveService.export`→`import` 往返数据等价 + INV 通过（复用 `AT-存3`），作为跨生态迁移路径。

### 8.6 集成冒烟
- **AT-云20（端到端多设备）**：假时钟 + 双假 backend：设备 A 领养→养到毕业→上传；设备 B 拉取→领养第二只→养若干天→上传；设备 A 再拉取合并 → 全程 `INV-1..5`、`INV-C-1..4` 不破；两只宠物、双份明信片、暖绒总额、成就进度全部正确合并。

---

## 附. 待细化清单（汇总）

- iCloud 方案二选一细节：`icloud_storage` 插件锁版 vs 自建 platform channel；iCloud 容器 ID；是否引入 KVS 云指针加速判定。
- Android 方案二选一：Play Games Saved Games（首选）vs Drive AppData（无 GMS 备选）；`games_services` 插件对 snapshot conflict 分支支持深度，是否需自建 channel 暴露 `SnapshotConflict`。
- Play Console / OAuth / SHA-1 具体配置项；iCloud entitlement 具体配置。
- `ScheduledJob` 是否进 SavePayload（倾向不进、落地后 catch-up 重建）。
- `Settings` 可同步子集的拆分实现（拆表 vs 字段标注）。
- **发奖去重的稳定 ref 命名约定**（需与 spec-technical §3.8 EconomyService 对齐：成就/毕业/升级发奖必须写 `ach:<id>` / `grad:<petId>` / `levelup:<petId>:<level>`）。
- 两设备各领养不同新宠时的"待处理宠"归档/玩家选择 UI。
- 是否提供"删除云端存档"入口。
- App Store / Google Play 隐私表单中 iCloud/Play Games 存档的申报归类（按最新审核口径）。
- 极重度存档的历史宠物流水冷分片（MVP 不做）。
- `status` 指示在 UI 的最终呈现形态（要求：非模态、零焦虑）。
- 云同步相关常量是否并入 `game_config.json` 存档区 vs 独立配置。
