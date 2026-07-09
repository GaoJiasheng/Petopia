# Petopia 实现规格 · 技术 · v0.3 · 配套 DESIGN.md

> 本文档是面向实现的技术规格（implementation spec），目标：让开发者（后续由 Codex CLI 实现）无需再猜测即可照做。
> 上游依据：`docs/DESIGN.md`（v0.2 框架版）。凡与本文冲突处，以本文（实现口径）为准；凡本文未覆盖处，回退到 DESIGN.md。
> Dart/Flutter 口径；纯本地存储、无后端；持久化建议 Isar（对象）+ SQLite（流水表）。
> 标记：`[待细化]` = 确需后续决定；数值类已尽量给确定初值（标 `锁定` 或 `可调`）。

---

## 目录

- 0. 术语与全局约定
- 1. 终版数据模型 Schema（§10 钉死）
- 2. 配置常量清单 Game Config
- 3. 核心算法与服务契约（Service Contracts）
- 4. 离线防作弊
- 5. 工程目录结构与内容库消费约定
- 6. 各系统验收标准（Acceptance Criteria）
- 7. 测试策略

---

## 0. 术语与全局约定

- **时间**：所有持久化时间戳统一存 UTC `DateTime`（`isUtc == true`），展示层再转本地时区。
- **单调时钟**：`Stopwatch` / `Duration` 语义的进程内递增时钟（不受用户改系统时间影响）。见 §4。
- **ID**：所有实体主键为 `String`，UUID v4（`uuid` 包）。内容库定义的静态实体（物种、地点、访客、事件、成就、商品）主键为**稳定字符串 ID**（如 `pet_cat`），不用 UUID。
- **枚举**：Dart `enum`，持久化为 `String`（枚举 name），不用 index（避免重排序破坏存档）。
- **金额/经验**：一律 `int`，恒为非负。
- **不变量前缀**：本文用 `INV-x` 标注关键不变量，供测试引用。
- **自然日边界**：以**设备本地时区的 00:00** 为「跨日」判定基准（§3 各每日上限重置、事件生成均以本地日为单位）。

全局关键不变量（源自 §10）：
- `INV-1`：`pet.exp == Σ(ExpLogEntry.delta where petId==pet.id)` —— 启动时校验。
- `INV-2`：全局处于 `RAISING` 的 Pet ≤ 1；处于 `REVISITING` 的 Pet ≤ 1。
- `INV-3`：`ExpLogEntry` / `CurrencyLog` 只追加，永不 update/delete。
- `INV-4`：`CurrencyWallet.balance == Σ(CurrencyLog.delta)` —— 启动时校验。
- `INV-5`：`exp` 单调不减；`ExpLogEntry.delta > 0` 恒成立（离线也绝不倒扣，见 §4）。

---

## 1. 终版数据模型 Schema

> 存储方案总纲：
> - **Isar collection（对象型，可查询/更新）**：`Pet`、`CurrencyWallet`、`YardState`、`Journey`、`ClueCounter`、`AchievementProgress`、`Settings`、`VisitorLogEntry`、`ScheduledJob`。
> - **SQLite（追加型流水大表，只 INSERT）**：`ExpLogEntry`、`CurrencyLog`、`Postcard`、`EventLogEntry`。理由：生命周期长、量大、只追加、需按时间/petId 范围扫描。
> - **静态内容（只读，assets 加载）**：`PetSpecies`、`PersonalityTag`、`Location`、`Visitor`、`VisitorPetInteraction`、`Event`(定义)、`Achievement`(定义)、`ShopItem`。运行期常驻内存 `ContentRepository`。见 §5。
> - 所有可迁移存储带全局 `schemaVersion`（存于 `Settings`）。

Dart 类型口径：`String` / `int` / `double` / `bool` / `DateTime`(UTC) / `List<T>` / `Map<K,V>` / `enum` / `?`(可空)。

### 1.1 枚举全集（钉死）

```dart
enum PetCategory { REAL, FANTASY }
enum PetStage { A, B, C, D }              // 幼崽/少年/成年/旅装
enum PetState { RAISING, TRAVELING, ROAMING, REVISITING, GRADUATED }
enum ExpSource { FEED, PAT, TOY, BATH, OFFLINE, EVENT_DAILY, EVENT_SPECIAL, VISITOR, REVISIT, ITEM_BONUS }
enum CurrencyReason { GRADUATION, DAILY_FIRST_CARE, LEVEL_UP, ACHIEVEMENT, REVISIT_GIFT, SHOP_PURCHASE, EVENT_REWARD, IMPORT_ADJUST }
enum EventType { DAILY, SPECIAL, REVISIT, GRADUATION }
enum VisitorRarity { COMMON, UNCOMMON, RARE, LEGENDARY }
enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum TimeOfDay_ { DAWN, MORNING, NOON, AFTERNOON, EVENING, NIGHT }   // 命名避开 Flutter TimeOfDay
enum Weather { CLEAR, CLOUDY, RAIN, THUNDER, SNOW, FOG, RAINBOW }
enum DexState { OWNED_BEFORE, AVAILABLE, LOCKED_KNOWN, LOCKED_HIDDEN }  // §1.2 图鉴四态
enum UnlockRuleType { INITIAL, GRAD_COUNT, HIDDEN_CLUE }             // §1.1 补全
enum EffectType { THEME_SKIN, DECOR, FEED_BONUS, TOY_PERMANENT_BONUS, ALBUM_SKIN, VISITOR_PROB }
enum AchievementCondType { GRAD_COUNT, SPECIES_COLLECTED, POSTCARD_COUNT, VISITOR_DEX_COUNT,
                           ACTION_COUNT, REVISIT_COUNT, LOGIN_STREAK, SPECIAL_EVENT_COUNT,
                           YARD_STAGE, THEME_COUNT, STAMP_COUNT, SEASON_POSTCARD, UNLOCK_PET,
                           CUSTOM }   // CUSTOM = 需专用判定器的隐藏成就
enum JobType { DAILY_EVENT_GEN, VISITOR_CHECK, REVISIT_DUE, POSTCARD_DUE, SPECIAL_EVENT_EVAL }
enum JourneyState { ACTIVE, WANDERING, DONE }
```

### 1.2 静态内容实体（只读）

#### PetSpecies
| 字段 | 类型 | 可空 | 约束/说明 |
|---|---|---|---|
| id | String | 否 | 稳定 ID，如 `pet_cat` |
| name | String | 否 | |
| category | PetCategory | 否 | |
| baseTone | String | 否 | 基调关键词（展示） |
| unlockRule | UnlockRule | 否 | 见下 variant |
| variantIds | List\<String\> | 否 | 长度=5（`INV`：MVP 至少 3 物种×3 变体，其余可 `[待细化]`） |
| dexArtRef | String | 否 | 彩色插画 |
| dexSilhouetteRef | String | 否 | 铅笔剪影 |
| dexMysteryRef | String? | 是 | 问号渍（仅彩蛋宠需要） |

**UnlockRule（补全 §10 `[待细化]`，三 variant，判别字段 `type`）：**
```dart
sealed class UnlockRule { UnlockRuleType type; }

class InitialUnlock  extends UnlockRule {}                       // type=INITIAL；初始可养
class GradCountUnlock extends UnlockRule { int threshold; }      // type=GRAD_COUNT；累计毕业数≥threshold
class HiddenClueUnlock extends UnlockRule {                      // type=HIDDEN_CLUE；彩蛋
  String clueId;          // 关联 ClueCounter，如 "clue_ember"
  int threshold;          // 达标计数
  String clueText;        // LOCKED_HIDDEN 状态显示的谜语句
  String visitorPrereqId; // 访客前置：必须先以此访客形态出现过（两段式线索开关）
  List<HiddenStep> hiddenSteps;  // 真实条件步骤（内部判定，见下）
}

class HiddenStep {        // 单条隐藏条件（供 UnlockService 逐条累计）
  String stepId;
  AchievementCondType condType;  // 复用条件类型枚举
  Map<String,dynamic> params;    // 如 {timeWindow:"23:00-02:00", requireEmptyFood:true, count:5}
}
```
初始值（对应 §1.1）：
- `pet_cat/pet_shiba/pet_rabbit` → `InitialUnlock`
- `pet_hamster..pet_chameleon` → `GradCountUnlock{threshold: 1..5}`
- `pet_ember/pet_uni/pet_boo/pet_starbug` → `HiddenClueUnlock`（`clueId=clue_ember/clue_uni/clue_boo/clue_starbug`，threshold 见 §2 常量，clueText 用 §1.1 斜体句，visitorPrereqId 用 §8.1 传说访客 ID）。

#### PersonalityTag
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | 如 `p_glutton`（10 个，§2.2 全集） |
| name | String | 否 | |
| persona | String | 否 | 一句话人设 |
| eventWeightMap | Map\<String,double\> | 否 | key=事件 tag（如 `food`,`sleep`），value=乘数 |
| actionExpBonus | Map\<ExpSource,double\> | 否 | 如 `{FEED:0.10}`（贪吃）；默认空 |
| actionSetId | String | 否 | 专属动作库引用 |
| postcardStyleId | String | 否 | 文风模板库引用 |
| specialFlags | List\<String\> | 否 | 特例，如 `["lazy_offline_cap"]`（慵懒离线上限特例）、`["aloof_pat_reject"]`（高冷摸头 30% 嫌弃） |

#### Location
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | ~40 个 |
| name | String | 否 | |
| category | String | 否 | 海滨/山地/城市/乡野/森林/沙漠异域/极地水域/奇幻 |
| climate | String | 否 | |
| vibeTags | List\<String\> | 否 | 用于 incidentPool 选择 |
| photoStyle | String | 否 | 背景板资产键 |
| encounterPoolId | String | 否 | 遭遇池引用 |
| personalityWeight | Map\<String,double\> | 否 | 性格→抽取权重（奇幻类对 `p_dreamy` >1） |
| stampId | String | 否 | 邮戳徽章（集邮） |

#### Visitor
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | 20 种，§8.1 |
| name | String | 否 | |
| rarity | VisitorRarity | 否 | |
| activeTime | List\<TimeOfDay_\> | 否 | 空=不限 |
| weatherPref | Map\<Weather,double\> | 否 | M_weather，缺省=1.0 |
| foodPref | Map\<String,double\> | 否 | key=foodType，M_food |
| seasonPref | Map\<Season,double\> | 否 | 缺省=1.0 |
| decorReq | List\<String\> | 否 | 必要装饰（如夜灯→星星虫）；空=无 |
| clueRole | String? | 是 | 关联 clueId（传说访客） |
| artRef | String | 否 | 肖像 |

#### VisitorPetInteraction（§8.4）
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | |
| visitorId | String | 否 | |
| petSpeciesId | String | 否 | `"*"` = 兜底 |
| personalityBias | List\<String\>? | 是 | 命中某性格替换 |
| script | String | 否 | |
| animRef | String | 否 | |
| expReward | int | 否 | 约束 3..6 |
| unlockClue | String? | 是 | clueId+1 |

选取优先级：`exact(visitor,species,personality) > exact(visitor,species) > fallback(visitor,"*")`。

#### Event（定义，§9.1）
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | `ev_dNN`/`ev_sNN` |
| type | EventType | 否 | |
| title | String | 否 | |
| script | String | 否 | |
| animRef | String? | 是 | |
| illustrationRef | String? | 是 | 特殊事件插画 |
| expReward | int | 否 | DAILY 2..8 / SPECIAL 8..20 |
| currencyReward | int? | 是 | |
| weights | EventWeights | 否 | 见下 |
| cooldownDays | int | 否 | 同事件最小间隔，默认 0 |
| oncePerPet | bool | 否 | 默认 false |
| choices | List\<EventChoice\>? | 是 | 二选一分支 |

```dart
class EventWeights {
  Map<String,double> personality;   // tagId -> mult
  Map<Weather,double> weather;
  Map<TimeOfDay_,double> timeOfDay;
  Map<Season,double> season;
  String? requiresVisitor;          // visitorId 在场
  String? requiresDecor;            // decorId 存在
  int? minLevel;                    // 如 ev_s04 Lv6+
  int? minLuxuryStage;              // 如 ev_d23 豪华度④+
}
class EventChoice { String text; String resultScript; int expDelta; }
```

#### Achievement（定义，§1.5）
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | |
| name | String | 否 | 达成后可见名 |
| hidden | bool | 否 | true=隐藏成就 |
| clueText | String? | 是 | 隐藏成就未达成时显示谜语 |
| condition | AchievementCond | 否 | 见下 |
| reward | RewardSpec | 否 | 见下 |

```dart
class AchievementCond { AchievementCondType type; int target; Map<String,dynamic> params; }
class RewardSpec { int fluff; String? decorItemId; String? couponId; String? stickerId; }
```
隐藏成就统一 reward：`fluff:40 + stickerId`（§1.5）。

#### ShopItem（§4.3）
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | |
| category | String | 否 | 院子主题/装饰小物/特殊食粮/特殊玩具/明信片 |
| name | String | 否 | |
| price | int | 否 | 暖绒 |
| effect | ItemEffect | 否 | 见下 |
| artRef | String | 否 | |
| consumable | bool | 否 | 食粮=true |
| stackCount | int? | 是 | 如「×5」 |

**ItemEffect（补全 §10 `effect{type,params}`）：**
```dart
class ItemEffect { EffectType type; Map<String,dynamic> params; }
```
各 EffectType 的 params 结构（钉死）：
- `THEME_SKIN`：`{themeId:String}`（可附带 `visitorProbBonus:{scope,delta}`，如星夜帐篷夜间 +5%）
- `DECOR`：`{decorId:String}`（装饰放置产生的访客加成由 Visitor.decorReq / VISITOR_PROB 效果驱动）
- `FEED_BONUS`：`{expFrom:3, expTo:6}`（该次喂食经验改写；消耗品）
- `TOY_PERMANENT_BONUS`：`{expFrom:4, expTo:6}`（永久，写玩家档 `ownedPerks`）
- `ALBUM_SKIN`：`{skinId:String}`
- `VISITOR_PROB`：`{scope:"night"|"legendary"|"birds"|..., delta:0.05}`

### 1.3 运行期可变实体

#### Pet（Isar）
| 字段 | 类型 | 可空 | 默认 | 约束/不变量 |
|---|---|---|---|---|
| id | String | 否 | uuid | |
| speciesId | String | 否 | | 引用 PetSpecies |
| variantId | String | 否 | | 加权随机自 species.variantIds |
| name | String | 否 | | 领养时取名，非空 |
| personality | List\<String\> | 否 | | 长度=2，10 选 2 不重复均匀随机 |
| bornAt | DateTime | 否 | now | UTC |
| level | int | 否 | 1 | 1..10 |
| exp | int | 否 | 0 | ≥0；`INV-1`/`INV-5` |
| stage | PetStage | 否 | A | 由 level 派生（1-4=A,5-7=B,8-9=C,10=D） |
| state | PetState | 否 | RAISING | `INV-2` |
| lastOnlineAt | DateTime | 否 | now | renew 锚点（§3.2/§4） |
| offlineExpGrantedToday | int | 否 | 0 | 0..dailyCap；跨日归零 |
| offlineDayKey | String | 否 | 本地日 | `yyyy-MM-dd`，判定跨日归零用 |
| wishId | String? | 是 | null | ev_s03 写入 |
| graduatedAt | DateTime? | 是 | null | |
| journeyId | String? | 是 | null | |
| nextRevisitAt | DateTime? | 是 | null | ROAMING 时设置 |
| pastNames | List\<String\> | 否 | [] | 用于「名字不重复」隐藏成就判定支持 |

`stage` 冗余存储但以 level 为准（换模演出触发靠 level 跨阈）。

#### CurrencyWallet（Isar，单例）
| 字段 | 类型 | 默认 | 约束 |
|---|---|---|---|
| balance | int | 0 | ≥0；`INV-4` |

#### YardState（Isar，单例）
| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| luxuryStage | int | 1 | 1..6；由累计毕业数派生（0→①,1→②,3→③,5→④,8→⑤,12→⑥） |
| gradCount | int | 0 | 累计毕业数（驱动 luxuryStage + GradCountUnlock） |
| activeThemeId | String | `theme_default` | |
| ownedThemeIds | List\<String\> | [`theme_default`] | |
| slots | List\<YardSlot\> | 见下 | 格位数随 luxuryStage：4/6/8/10/12/14 |
| foodTray | FoodTray | 空 | |
| ownedPerks | List\<String\> | [] | 永久强化（如 `toy_yarn_perm`）|
| ownedDecorIds | List\<String\> | [] | 已购装饰（驱动访客加成） |

```dart
class YardSlot { int pos; String? itemId; }
class FoodTray { String? foodType; DateTime? placedAt; }   // foodType: grain/fishdry/nuts/apple/null
```

#### Journey（Isar）
| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| id | String | uuid | |
| petId | String | | |
| stops | List\<String\> | | 25 个主旅程 locationId，去重，性格加权 |
| wanderStops | List\<String\> | [] | 剩余地点补完队列；40 张地点全集中未进 stops 的地点 |
| currentIdx | int | 0 | 0..stops.length |
| wanderIdx | int | 0 | 0..wanderStops.length |
| longTermSeq | int | 0 | 40 张完成后的长期循环寄片序号 |
| nextPostcardAt | DateTime | | 下次寄片时间 |
| state | JourneyState | ACTIVE | ACTIVE(25 张主旅程)→WANDERING(补完剩余地点)→永久 WANDERING |

#### ClueCounter（Isar）
| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| clueId | String | | 主键，如 `clue_ember` |
| count | int | 0 | 单调递增 |
| threshold | int | | 达标值（源 §2） |
| visitorSeen | bool | false | 访客前置是否已达成（控制线索两段式显示） |

#### AchievementProgress（Isar）
| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| achievementId | String | | 主键 |
| progress | int | 0 | 当前进度 |
| unlockedAt | DateTime? | null | 非空=已解锁 |
| rewardClaimed | bool | false | 防重复发奖 |

#### VisitorLogEntry（Isar，来客图鉴数据源）
| 字段 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | String | 否 | uuid |
| visitorId | String | 否 | |
| date | DateTime | 否 | 到访日 |
| interactionId | String? | 是 | 命中的互动 |
| withPetId | String? | 是 | 当时在养宠 |

#### ScheduledJob（Isar，统一日程队列，§3.EventScheduler）
| 字段 | 类型 | 可空 | 默认 | 说明 |
|---|---|---|---|---|
| id | String | 否 | uuid | |
| type | JobType | 否 | | |
| dueAt | DateTime | 否 | | 到期时间（本地日粒度或精确时刻） |
| priority | int | 否 | 见 §3 | 数值小=优先 |
| payloadRef | String? | 是 | | 如 petId/visitorId/eventId |
| consumed | bool | 否 | false | 处理后置 true（不删，便于审计），或直接删除 `[待细化]` |

#### Settings（Isar，单例）
| 字段 | 类型 | 默认 | 说明 |
|---|---|---|---|
| notifications | bool | true | |
| sound | bool | true | |
| schemaVersion | int | 1 | 迁移用 |
| createdAt | DateTime | now | |
| lastMonotonicRef | int | 0 | 单调时钟基准（§4，毫秒） |
| lastWallClockAt | DateTime | now | 上次记录的真实时钟（§4 交叉校验） |
| loginStreakCurrent | int | 0 | 连续登录 |
| loginStreakMax | int | 0 | 历史最长连续段 |
| lastLoginDay | String | "" | `yyyy-MM-dd` |

### 1.4 流水表（SQLite，只追加）

#### exp_log（ExpLogEntry，§3.4）
| 列 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | TEXT PK | 否 | uuid |
| pet_id | TEXT | 否 | |
| timestamp | INTEGER | 否 | epoch ms UTC |
| source_type | TEXT | 否 | ExpSource.name |
| source_ref | TEXT | 是 | |
| delta | INTEGER | 否 | >0 |
| level_at | INTEGER | 否 | |
| exp_after | INTEGER | 否 | 冗余校验 |
| note | TEXT | 是 | 展示短语 |

索引：`idx_explog_pet (pet_id)`、`idx_explog_pet_ts (pet_id, timestamp)`。

#### currency_log（CurrencyLog）
| 列 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | TEXT PK | 否 | uuid |
| timestamp | INTEGER | 否 | epoch ms |
| delta | INTEGER | 否 | 可正可负（负=消费） |
| reason | TEXT | 否 | CurrencyReason.name |
| ref | TEXT | 是 | 商品/成就/petId |
| balance_after | INTEGER | 否 | 冗余校验 |

索引：`idx_curlog_ts (timestamp)`。

#### postcard（Postcard，§6.3）
| 列 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | TEXT PK | 否 | |
| pet_id | TEXT | 否 | |
| journey_id | TEXT | 否 | |
| location_id | TEXT | 否 | |
| seq | INTEGER | 否 | 第几站 |
| sent_at | INTEGER | 否 | |
| received_at | INTEGER | 是 | |
| season | TEXT | 否 | |
| time_of_day | TEXT | 否 | |
| weather | TEXT | 否 | |
| encounter_id | TEXT | 是 | |
| incident_id | TEXT | 是 | |
| body_text | TEXT | 否 | 渲染定稿（保证回看一致） |
| photo_asset_id | TEXT | 否 | |
| stamp_id | TEXT | 否 | |
| clue_to_pet | TEXT | 是 | 彩蛋线索载体 |
| clue_to_visitor | TEXT | 是 | |

索引：`idx_postcard_pet (pet_id)`、`idx_postcard_recv (received_at)`、`idx_postcard_loc (location_id)`。

#### event_log（EventLogEntry，§9.1）
| 列 | 类型 | 可空 | 说明 |
|---|---|---|---|
| id | TEXT PK | 否 | |
| event_id | TEXT | 否 | |
| pet_id | TEXT | 是 | |
| date | INTEGER | 否 | |
| choice_idx | INTEGER | 是 | |
| exp_granted | INTEGER | 否 | |

索引：`idx_eventlog_event_date (event_id, date)`（冷却判定）、`idx_eventlog_pet (pet_id)`（oncePerPet 判定）。

---

## 2. 配置常量清单（Game Config）

> 建议承载：`lib/config/game_config.dart` —— 一个不可变常量类 `GameConfig`（`static const`），或从 `assets/data/game_config.json` 加载（便于策划改数不改码）。**推荐 JSON + 强类型解析**，实现阶段可 `[待细化]` 二选一，但字段与初值如下钉死。
> 「锁定」= 改动会破坏节奏/审计承诺，需评审；「可调」= playtest 可校准。

### 2.1 经验与动作（§3.1）
| 常量 | 初值 | 属性 | 含义 |
|---|---|---|---|
| feedExp | 3 | 可调 | 喂食经验 |
| feedCooldownMin | 15 | 锁定 | 喂食冷却（分钟） |
| feedDailyCap | 12 | 锁定 | 每日喂食次数上限 |
| patExp | 1 | 可调 | 摸头经验 |
| patCooldownMin | 10 | 锁定 | |
| patDailyCap | 16 | 锁定 | |
| toyExp | 4 | 可调 | 玩玩具经验 |
| toyCooldownMin | 20 | 锁定 | |
| toyDailyCap | 8 | 锁定 | |
| bathExp | 6 | 可调 | 洗澡经验 |
| bathDailyCap | 1 | 锁定 | 每日 1 次（无分钟冷却，按自然日） |
| gluttonFeedBonus | 0.10 | 可调 | 贪吃喂食 +10% |
| energeticToyBonus | 0.10 | 可调 | 活力玩具 +10% |
| bonusRounding | "floor" | 锁定 | 加成取整规则：向下取整（避免通胀） |

### 2.2 离线（§3.2 / §4）
| 常量 | 初值 | 属性 | 含义 |
|---|---|---|---|
| offlineExpPerHour | 1 | 锁定 | 离线每满 1h +1 |
| offlineSingleCap | 12 | 锁定 | 单段结算封顶 |
| offlineDailyCap | 12 | 锁定 | 自然日累计上限 |
| lazyOfflineDailyCap | 13 | 可调 | 慵懒标签特例（§2.3 「离线经验上限 +1/天」） |
| clockDriftForgiveSec | 120 | 锁定 | 真实时钟回拨容忍窗（§4） |

### 2.3 经验曲线（§3.3，锁定；累计 800）
`levelUpCost`（升到下一级所需）：
```
Lv1→2: 30   Lv2→3: 45   Lv3→4: 60   Lv4→5: 75
Lv5→6: 90   Lv6→7: 105  Lv7→8: 120  Lv8→9: 130  Lv9→10: 145
```
`cumExpAtLevel`（进入该级的累计门槛，冗余便于二分）：
```
Lv1:0  Lv2:30  Lv3:75  Lv4:135  Lv5:210  Lv6:300  Lv7:405  Lv8:525  Lv9:655  Lv10:800(毕业)
```
- stage 阈值：Lv5→B、Lv8→C、Lv10→D（换模演出）。属性：锁定。

### 2.4 经济 / 暖绒（§4.2）
| 常量 | 初值 | 属性 |
|---|---|---|
| gradBaseFluff | 200 | 锁定 |
| gradPerEventFluff | 2 | 可调 |
| gradEventCapFluff | 100 | 可调 |
| gradPerVisitorFluff | 3 | 可调 |
| gradVisitorCapFluff | 60 | 可调 |
| gradEasterEggBonus | 80 | 可调 |
| dailyFirstCareFluff | 5 | 可调 |
| levelUpFluff | 10 | 可调 | 每升 1 级 |
| revisitGiftMin / Max | 10 / 20 | 可调 |

### 2.5 访客（§8.2/8.3）
| 常量 | 初值 | 属性 |
|---|---|---|
| baseProbCommon | 0.35 | 可调 |
| baseProbUncommon | 0.15 | 可调 |
| baseProbRare | 0.06 | 可调 |
| baseProbLegendary | 0.015 | 可调 |
| dayWindow | 06:00–09:00 | 锁定 | 生成白天访客 |
| nightWindow | 18:00–21:00 | 锁定 | 生成夜间访客 |
| emptyTrayMult | 0.8 | 可调 | 空盘全体 ×0.8（不惩罚） |
| luxuryStage2AllBonus | +0.05 | 可调 | 阶段②起全体绝对值 |
| luxuryStage5LegendaryBonus | +0.02 | 可调 | 阶段⑤起传说绝对值 |
| revisitBringFriendProb | 0.20 | 可调 | 回访带旅伴（§7.3） |

修正系数（M_time/M_weather/M_food/M_decor/M_season）由各 `Visitor` 静态数据承载，初值见 §8.3 表；缺省 1.0。

### 2.6 事件（§9）
| 常量 | 初值 | 属性 |
|---|---|---|
| dailyEventMin / Max | 1 / 3 | 可调 | 每日生成 DAILY 数 |
| specialEventDailyCap | 1 | 锁定 | |
| defaultCooldownDays | 0 | 可调 | |

### 2.7 明信片 / 旅行（§6）
| 常量 | 初值 | 属性 |
|---|---|---|
| journeyStopsMin / Max | 25 / 25 | 可调 | 毕业主旅程从 40 张地点中抽 25 张 |
| postcardIntervalMinDays / MaxDays | 3 / 5 | 可调 | 主旅程寄片间隔 |
| wanderPostcardMinDays / MaxDays | 10 / 15 | 可调 | 剩余 15 张补完寄片间隔 |
| longTermPostcardMinDays / MaxDays | 18 / 22 | 可调 | 40 张完成后约 20 天随机回信 |

### 2.8 回访（§7）
| 常量 | 初值 | 属性 |
|---|---|---|
| revisitWindowMinDays / MaxDays | 7 / 14 | 锁定 | 回访窗口 |
| revisitStayMinDays / MaxDays | 1 / 2 | 可调 | 停留时长 |
| revisitPatPerDay | 1 | 锁定 | 摸头 1 次/天 |
| revisitPetExp | 5 | 可调 | 在养宠获经验（source=REVISIT） |
| maxConcurrentRevisit | 1 | 锁定 | `INV-2` |

### 2.9 彩蛋 ClueCounter 阈值（§1.1 真实条件）
| clueId | threshold | 说明 |
|---|---|---|
| clue_ember | 3 | 火光访客遇见 3 次（+暖炉+冬夜前置） |
| clue_uni | 2 | 雨后点击彩虹 2 次 |
| clue_boo | 5 | 深夜(23:00–02:00)上线且院子无食物累计 5 次 |
| clue_starbug | 3 | 星星虫访客 3 次（+夜灯） |

### 2.10 存档
| 常量 | 初值 | 属性 |
|---|---|---|
| autoSaveDebounceMs | 1500 | 可调 | 状态变更后延迟落盘 |
| backupSlots | 2 | 锁定 | 双备份（A/B 轮换） |
| currentSchemaVersion | 1 | 锁定 | |

---

## 3. 核心算法与服务契约

> 所有 Service 位于逻辑层（`lib/services`），无 Flutter/Flame 依赖，可纯单测。DI 通过构造注入 repository + `Clock`（可注入假时钟）。方法签名为 Dart 口径。

### 3.1 ClockService
**职责**：提供权威「现在」时间、离线时长结算、防调表。是所有时间相关逻辑的唯一时间源。

```dart
class ClockService {
  /// 返回可信 now（UTC）。内部用单调时钟推进 + 真实时钟交叉校验。
  DateTime now();

  /// 应用从后台恢复/冷启动时调用。返回本次可结算的离线时长（钳制后）。
  Duration resolveOfflineElapsed({required DateTime lastOnlineAt});

  /// 记录心跳锚点（写 Settings.lastMonotonicRef / lastWallClockAt）。
  void markHeartbeat();
}
```

**防调表算法（核心）**——见 §4 详述。要点伪代码：
```pseudo
resolveOfflineElapsed(lastOnlineAt):
    wallElapsed = wallClockNow() - lastOnlineAt         # 可能被用户改表污染
    monoElapsed = monotonicNow() - lastMonotonicRef     # 单调，仅进程存活期有效
    # 若单调时钟仍有效（进程未被杀），取二者较小值（宁可少给）
    if monotonicValid:
        elapsed = min(wallElapsed, monoElapsed)
    else:
        elapsed = wallElapsed
    if elapsed < 0: elapsed = 0                          # 时钟回拨 → 归零，绝不倒扣
    return elapsed                                        # 上限钳制交给 ExpEngine（offlineSingleCap）
```

**不变量**：`resolveOfflineElapsed` 永不返回负值；改表向前（未来）最多按上限给经验；改表向后（回拨）给 0。

### 3.2 ExpEngine
**职责**：唯一的加经验入口；负责升级、换档、写审计流水。任何经验变动必须经此。

```dart
class ExpResult {
  int deltaApplied;      // 实际加的经验（加成/取整后）
  int levelBefore, levelAfter;
  bool leveledUp;
  bool evolved;          // 是否跨 stage 阈值
  bool graduated;        // 是否达 Lv10
}

class ExpEngine {
  /// 统一加经验。会写 ExpLogEntry；触发升级/换档/毕业事件。
  ExpResult addExp({
    required Pet pet,
    required int baseDelta,
    required ExpSource source,
    String? sourceRef,
    String? note,
    bool applyPersonalityBonus = true,  // OFFLINE/EVENT 等不吃动作加成时传 false
  });

  /// 结算离线经验（供 ClockService 结果调用）。内部含单段+自然日双上限。
  ExpResult grantOffline({required Pet pet, required Duration elapsed});
}
```

**addExp 算法**：
```pseudo
addExp(pet, baseDelta, source, ...):
    assert baseDelta >= 0
    delta = baseDelta
    if applyPersonalityBonus:
        for tag in pet.personality:
            b = tag.actionExpBonus[source] ?? 0
            delta += floor(baseDelta * b)      # bonusRounding=floor
    if delta == 0: return noop
    pet.exp += delta
    pet.level = deriveLevel(pet.exp)           # 用 cumExpAtLevel 二分
    newStage = deriveStage(pet.level)
    write ExpLogEntry{delta, levelAt: levelBefore, expAfter: pet.exp, source, sourceRef, note, ts: clock.now()}
    if pet.level == 10 and not graduatedFlag: mark graduated (触发 GRADUATION 事件, 交 GraduationService)
    return ExpResult{...}
```
**不变量**：`INV-1`（每次 addExp 后 pet.exp 恰等于流水和，因 exp_after 冗余可即时自检）；`INV-5`（delta≥0）。升级/换档不重复计费（deriveLevel 幂等）。

**grantOffline 算法**（§3.2 renew）：
```pseudo
grantOffline(pet, elapsed):
    rollDailyResetIfCrossedMidnight(pet)        # offlineDayKey != today → offlineExpGrantedToday=0
    cap = isLazy(pet) ? lazyOfflineDailyCap : offlineDailyCap
    elapsedH = floor(elapsed.inHours)
    gain = min(elapsedH, offlineSingleCap)      # 单段封顶
    gain = min(gain, cap - pet.offlineExpGrantedToday)   # 自然日总上限
    gain = max(gain, 0)
    if gain > 0:
        addExp(pet, gain, OFFLINE, note:"${elapsedH}h offline", applyPersonalityBonus:false)
        pet.offlineExpGrantedToday += gain
    pet.lastOnlineAt = clock.now()              # ★ renew：无论是否给经验都重置
```

### 3.3 AuditService
**职责**：流水（ExpLog/CurrencyLog）追加写入 + 启动完整性校验。

```dart
class AuditService {
  Future<void> appendExpLog(ExpLogEntry e);         // INSERT only
  Future<void> appendCurrencyLog(CurrencyLog e);    // INSERT only
  Future<AuditReport> verifyOnStartup();            // 校验 INV-1 / INV-4
}
class AuditReport { bool ok; List<String> discrepancies; }  // 记录 petId + 期望/实际
```
**verifyOnStartup 算法**：
```pseudo
for each pet: assert pet.exp == SELECT SUM(delta) FROM exp_log WHERE pet_id=pet.id
assert wallet.balance == SELECT SUM(delta) FROM currency_log
不一致处理：不静默修复；记 discrepancy 并按「宁可少给不误伤」原则——
  以流水为真相源（trust log），把 pet.exp/wallet.balance 回正为 Σdelta（因流水只追加不可篡改），并写一条 note 标记修正。绝不反向删流水。
```
`[待细化]`：不一致是否上报 UI（治愈向，倾向静默回正 + debug 日志）。

### 3.4 EventScheduler
**职责**：事件 / 访客 / 回访 / 明信片统一日程队列（`ScheduledJob`）的调度与优先级仲裁。每次上线（onResume）与每日首次 tick 驱动。

**优先级（priority，小=先）**：
```
GRADUATION(0) > REVISIT_DUE(1) > SPECIAL_EVENT(2) > VISITOR_CHECK(3) > DAILY_EVENT_GEN(4) > POSTCARD_DUE(5)
```
**每日调度规则**：
```pseudo
onDailyTick(today):
    # 1. 补种当日 job（若尚未为 today 生成）
    if not generatedFor(today):
        n = randInt(dailyEventMin, dailyEventMax)     # 1..3
        enqueue n×DAILY_EVENT_GEN (dueAt=today)
        enqueue VISITOR_CHECK ×2 (dayWindow, nightWindow)
        enqueue SPECIAL_EVENT_EVAL (today)
    # 2. 回访：见 RevisitService.dailyTick
    # 3. 明信片：见 PostcardGenerator.dailyTick

onResume(now):
    catchUp: 对所有 dueAt<=now 且未 consumed 的 job，按 priority 升序、dueAt 升序处理
    演出串行：同一次上线最多演出 1 组（避免弹窗轰炸，§11.2）——其余标记「待演出」下次上线补
```
**约束**：SPECIAL 日上限 1；DAILY 演出上线时触发；REVISIT 唯一（`INV-2`）。事件命中用 §8/§9 权重轮盘（见 VisitorService.roulette 复用）。

**事件权重最终值**（§2.3）：`finalWeight = baseWeight × Π(personalityMult) × weatherMult × timeMult × seasonMult`，无关标签系数 = 1.0；不满足 `requiresVisitor/requiresDecor/minLevel/minLuxuryStage` 则权重=0（不参与）；`cooldownDays` 内（查 event_log）与 `oncePerPet` 已触发则排除。

### 3.5 PostcardGenerator
**职责**：实现 §6.3 生成管线；旅程寄片调度。

```dart
class PostcardGenerator {
  Postcard generate({required Pet pet, required Journey journey});
  void dailyTick({required Pet pet, required Journey journey});  // 判定是否到寄片时刻
}
```
**generate 管线**（§6.3 钉死）：
```pseudo
generate(pet, journey):
    location = content.location(journey.stops[journey.currentIdx])
    timeCtx  = { season: seasonOf(clock.now()) 弱同步真实日期,
                 timeOfDay: randTimeOfDay(), weather: randWeather(location.climate) }
    encounter = weightedPick(location.encounterPool, pet.personality)
    incident  = weightedPick(incidentPool[location.vibeTags], pet.personality)
    body = render(templateBank[mainPersonality(pet)], {location, timeCtx, encounter, incident, ownerName})
    photoId = composePhoto(location.photoStyle, pet.speciesId, incident.poseHint)  # §6.5 分层合成
    stampId = location.stampId
    cluesTo = maybeAttachClue(location, pet)   # 可选彩蛋线索载体
    persist Postcard (SQLite), 双入册（明信片相册 + 旅行相册均为视图，仅存一份实体，§6.6）
    return postcard
```
**dailyTick**：毕业后第 1 天寄首张；`ACTIVE` 阶段按 `stops[currentIdx]` 寄 25 张主旅程明信片，间隔 3–5 天；主旅程完成后进入 `WANDERING`，按 `wanderStops[wanderIdx]` 补完剩余 15 张，间隔 10–15 天；40 张地点全集完成后保持 `WANDERING`，约 20 天（18–22 天）从 40 张中随机抽一张寄回。发本地通知（若 Settings.notifications）。

### 3.6 VisitorService
**职责**：§8 到访判定（概率轮盘）+ 互动选取 + 来客图鉴收录。

```dart
class VisitorService {
  Visitor? rollWindow({required TimeWindow window, required YardState yard,
                       required Weather weather, required Season season, required DateTime now});
  Visitor? rollLegendary({...});   // 传说单独判定，可与普通同日
  VisitorPetInteraction pickInteraction(Visitor v, Pet? pet);
  void recordVisit(Visitor v, Pet? pet, VisitorPetInteraction? it);  // 写 VisitorLogEntry + clueCounter++
}
```
**概率轮盘算法**（§8.2）：
```pseudo
P(v) = Base(v.rarity) × M_time × M_weather × M_food × M_decor × M_luxury × M_season
    Base: 用 §2.5 baseProb*
    M_time    = v.activeTime 命中当前时段则用其乘数（默认表：夜行白天×0，麻雀夜×0.2 等，见 §8.3）
    M_weather = v.weatherPref[weather] ?? 1.0
    M_food    = v.foodPref[yard.foodTray.foodType] ?? (空盘 emptyTrayMult=0.8)
    M_decor   = v.decorReq 若未满足 → 0（硬门槛，如夜灯之于星星虫）；满足则用装饰加成乘数
    M_luxury  = 阶段②起全体 +0.05（绝对，加在 P 上而非乘）；⑤起传说 +0.02
    M_season  = v.seasonPref[season] ?? 1.0
候选集 = 该窗口所有 P>0 的普通访客
每窗口最多命中 1 只：weightedRoulette(候选, P)；miss 概率 = 1 - Σclamp(P)
传说访客：各自独立 rollLegendary（伯努利 P），可与普通同日
```
**约束**：`M_luxury` 的 +0.05/+0.02 是绝对值加到最终 P（DESIGN §8.3 口径），实现时先乘后加，最后 clamp 到 [0,1]。

### 3.7 UnlockService
**职责**：图鉴四态计算、成就进度/解锁、ClueCounter 彩蛋链、隐藏成就判定。

```dart
class UnlockService {
  DexState dexStateOf(PetSpecies s);                       // §1.2 四态
  void bumpClue(String clueId, {int by = 1});              // ClueCounter++；达标→解锁彩蛋物种可养
  void trackEvent(GameSignal signal);                      // 统一信号入口，推进成就/隐藏成就/彩蛋 hiddenSteps
  List<Achievement> checkAchievements(GameSignal signal);  // 返回本次新解锁
  void claimReward(String achievementId);                  // 发奖（经 EconomyService），置 rewardClaimed
}
```
**dexStateOf 算法**（§1.2 四态）：
```pseudo
if species 曾被养过 (存在 graduated Pet of species): OWNED_BEFORE
elif unlockRule is InitialUnlock: AVAILABLE
elif unlockRule is GradCountUnlock:
    AVAILABLE if yard.gradCount >= threshold else LOCKED_KNOWN(progress: gradCount/threshold)
elif unlockRule is HiddenClueUnlock:
    if clueCounter[clueId].count >= threshold: AVAILABLE
    else: LOCKED_HIDDEN(clueText 两段式: visitorSeen ? clueText : "？？？")
```
**彩蛋链**：`GameSignal`（如「遇见火光访客」「深夜无食物上线」）经 `trackEvent` 累加到对应 `HiddenStep`，全部 step 达成才 `bumpClue`；`bumpClue` 使 count 达 threshold → 该 FANTASY 物种转 AVAILABLE。访客前置达成时置 `visitorSeen=true`（线索由「？？？」变谜语句）。
**成就**：进度型（ACTION_COUNT/POSTCARD_COUNT/…）直接累加比对 target；CUSTOM 型（守夜人/听雨的人/名字的重量/什么也没发生的一天）需专用判定器（`Map<achId, Predicate>`），`[待细化]` 各判定器细节但条件已由 §1.5 给定。解锁只发一次奖（`rewardClaimed` 幂等）。

### 3.8 EconomyService
**职责**：暖绒收支唯一入口（写 CurrencyLog）、毕业结算、商店购买、发奖。

```dart
class EconomyService {
  int get balance;
  void earn(int amount, CurrencyReason reason, {String? ref});   // amount>0
  bool spend(int amount, CurrencyReason reason, {String? ref});  // 余额不足返回 false，不透支
  int settleGraduation(Pet pet);                                 // §4.2 公式
  PurchaseResult purchase(ShopItem item);                        // 扣费 + 应用 effect
}
```
**settleGraduation 算法**（§4.2）：
```pseudo
fluff = gradBaseFluff(200)
      + min(events参与数 × 2, 100)
      + min(visitors互动次数 × 3, 60)
      + (pet.species.category==FANTASY ? 80 : 0)
earn(fluff, GRADUATION, ref: pet.id)   # 预期 260..380
```
**purchase**：`spend(price)` 成功后按 `ItemEffect.type` 应用（THEME→ownedThemeIds；DECOR→ownedDecorIds+slot；TOY_PERMANENT→ownedPerks；ALBUM→settings；食粮→背包计数 `[待细化]` 背包结构）。**不变量** `INV-4`：任何变动写 CurrencyLog 且 balance_after 冗余。

### 3.9 SaveService
**职责**：自动存档、双备份、schemaVersion 迁移、导入导出。

```dart
class SaveService {
  Future<void> autoSave();                       // debounce autoSaveDebounceMs，写当前 slot 后切换
  Future<void> load();                           // 优先 slot，校验失败回退备份 slot
  Future<int> migrateIfNeeded(int fromVersion);  // 顺序执行 migrations[from..current]
  Future<File> export();                         // 打包 Isar+SQLite 为单文件（含 checksum）
  Future<ImportResult> import(File f);           // 校验 checksum + schemaVersion → 迁移 → 校验 INV
}
```
**双备份**：A/B 两 slot 轮换写；load 时先读较新 slot，若反序列化/校验失败读另一 slot（`[待细化]` slot 元数据含写入时间+crc）。
**迁移**：`migrations: List<Migration>`，每个 `Migration{fromVersion, up(db)}`；`migrateIfNeeded` 从 stored version 顺序 up 到 `currentSchemaVersion`，成功后更新 `Settings.schemaVersion`。迁移全程事务；失败回滚并回退备份。
**导入导出**：导入后必跑 `AuditService.verifyOnStartup`（`INV-1/4`）；校验不通过则拒绝导入并保留原档。导入是**覆盖式**（单宠位游戏，无合并语义）。

---

## 4. 离线防作弊

**总原则（治愈支柱 §0.3）：宁可少给，绝不误伤；绝不倒扣；绝不惩罚离线。** 反作弊只用于「不给超额」，从不用于「扣已得」。

### 4.1 时间源
- **真实时钟**（wall clock）：`DateTime.now().toUtc()`。可被用户改系统时间污染。
- **单调时钟**（monotonic）：进程内递增，来源优先级：
  1. `Stopwatch`（进程存活期内单调，杀进程即失效）；
  2. 平台单调计时（Android `SystemClock.elapsedRealtime()` / iOS `mach_absolute_time` / `CLOCK_MONOTONIC`）经 platform channel 暴露——**推荐**，可跨越 app 后台但同一开机周期内单调，重启设备失效。`[待细化]` 是否引入原生通道；MVP 可先仅用 `Stopwatch` + wall clock 交叉。

### 4.2 结算策略（在 ClockService.resolveOfflineElapsed，见 §3.1）
```
wallElapsed = wallNow - lastOnlineAt
若单调时钟自 lastOnlineAt 起仍连续有效：
    monoElapsed = monoNow - monoRefAtLastOnline
    elapsed = min(wallElapsed, monoElapsed)     # 改表往前时 mono 更小 → 取 mono，少给
否则（进程被杀/设备重启，mono 失效）：
    elapsed = wallElapsed                        # 只能信 wall
if elapsed < 0: elapsed = 0                       # 改表回拨 → 0，绝不倒扣
```
- **改表往未来**（想多领）：`min(wall, mono)` 或纯上限钳制拦截；即便纯 wall，`offlineSingleCap=12` + 自然日 `offlineDailyCap=12` 使单日最多领 12（慵懒 13），无套利空间。
- **改表往过去**（负 elapsed）：钳制到 0，不倒扣、不惩罚，`lastOnlineAt` 仍 renew 为 now。
- **合理性钳制**：单段 ≤ offlineSingleCap；自然日累计 ≤ dailyCap。二者在 `ExpEngine.grantOffline` 再次强制（防御式双保险）。

### 4.3 交叉校验与容忍
- 每次 `markHeartbeat` 记录 `(wallClockNow, monotonicNow)` 到 `Settings`。
- 若检测到 wall 相对 mono 异常跳变（|Δwall − Δmono| > clockDriftForgiveSec=120s）→ 认定改表，本段以 mono 为准。
- 容忍窗 120s 吸收正常时区/NTP 微调，避免误伤。
- **绝不因检测到改表而扣经验或封禁**——最坏情况就是本段离线收益为 0（少给）。

---

## 5. 工程目录结构与内容库消费约定

### 5.1 目录树
```
petopia/
├─ assets/
│  ├─ data/                      # 结构化内容（由 content-*.md 转换而来，程序消费的真相源）
│  │  ├─ game_config.json        # §2 常量（或用 lib/config/game_config.dart）
│  │  ├─ species.json            # PetSpecies[]
│  │  ├─ personalities.json      # PersonalityTag[]
│  │  ├─ locations.json          # Location[]
│  │  ├─ visitors.json           # Visitor[]
│  │  ├─ visitor_interactions.json
│  │  ├─ events.json             # Event 定义[]
│  │  ├─ achievements.json
│  │  ├─ shop_items.json
│  │  ├─ postcard_templates.json # 文风骨架 + 遭遇/碰撞词条池
│  │  └─ clue_defs.json          # ClueCounter 阈值 + 彩蛋链
│  ├─ images/ … spine/ …         # 美术资产（§11.3）
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                   # 启动编排：load→migrate→audit→schedule
│  ├─ config/
│  │  └─ game_config.dart        # GameConfig（常量类或 JSON 解析器）
│  ├─ data/                      # 持久化层（Isar/SQLite）+ repository 实现
│  │  ├─ isar/ (collections, schemas)
│  │  ├─ sqlite/ (dao: exp_log, currency_log, postcard, event_log)
│  │  ├─ content/ (ContentRepository：加载 assets/data/*.json 到内存)
│  │  └─ save/ (SaveService, migrations/)
│  ├─ domain/                    # 纯模型 + 枚举 + 值对象（无 IO）
│  │  ├─ models/ (Pet, Journey, Postcard, …)
│  │  ├─ enums.dart
│  │  └─ unlock_rule.dart / item_effect.dart / …
│  ├─ services/                  # §3 全部 Service（纯逻辑，可单测）
│  │  ├─ clock_service.dart
│  │  ├─ exp_engine.dart
│  │  ├─ audit_service.dart
│  │  ├─ event_scheduler.dart
│  │  ├─ postcard_generator.dart
│  │  ├─ visitor_service.dart
│  │  ├─ revisit_service.dart
│  │  ├─ unlock_service.dart
│  │  ├─ economy_service.dart
│  │  └─ graduation_service.dart
│  ├─ scenes/                    # Flame
│  │  ├─ yard_scene.dart         # 分层：主题背景/豪华度布局/宠物/天气粒子
│  │  ├─ pet_component.dart      # Spine/序列帧，stage 换模
│  │  └─ weather_layer.dart
│  ├─ ui/                        # Flutter 手账 UI
│  │  ├─ dex/ album/ shop/ growth_journal/ postcard_view/ …
│  │  └─ widgets/ (纸质手账组件库)
│  └─ notifications/             # flutter_local_notifications 封装
└─ test/                         # §7
```
分层依赖方向（单向）：`ui`/`scenes` → `services` → `domain`；`services` → `data`(接口)。`domain` 不依赖任何上层。

### 5.2 内容库（content-*.md）落地转换约定
- **现状**：内容以 markdown 设计文档形式存在（DESIGN.md 及未来的 content-*.md）。**本规格不修改任何 content 文件。**
- **约定**：实现阶段将 markdown 中的表格/条目**抽取为 `assets/data/*.json`**（上表），作为程序唯一消费源。markdown 保留为人类可读的设计真相源。
- **转换脚本**：建议 `tool/gen_content.dart`（一次性/半自动），解析 content-*.md 表格 → 生成 JSON。人工校对后入库。转换是**单向 md→json**，不回写 md。
- **建议 JSON 格式**：每文件顶层 `{ "schemaVersion": 1, "items": [ … ] }`；字段名与 §1 静态实体一一对应；枚举用字符串名。示例（species.json 单条）：
```json
{ "id":"pet_hamster", "name":"仓鼠", "category":"REAL", "baseTone":"囤货、腮帮、跑轮",
  "unlockRule":{"type":"GRAD_COUNT","threshold":1},
  "variantIds":["pet_hamster_v1","pet_hamster_v2","pet_hamster_v3","pet_hamster_v4","pet_hamster_v5"],
  "dexArtRef":"...", "dexSilhouetteRef":"..." }
```
- **加载**：启动时 `ContentRepository.loadAll()` 读全部 JSON 到不可变内存 map，`schemaVersion` 与代码期望不符则报错（内容与代码版本对齐）。

---

## 6. 各系统验收标准（Acceptance Criteria）

> 每条可测试（AT-x）。「给定/当/则」结构。

### 6.1 养育 / 经验
- AT-育1：给定 Lv1 宠物 exp=0，喂食 1 次，则 exp=3、写 1 条 `FEED` ExpLogEntry、按钮进入 15min 冷却且置灰。
- AT-育2：贪吃宠喂食，baseDelta=3，则实加 `3+floor(3×0.10)=3`（floor 后 +0），累计到 baseDelta 使加成生效时体现 +10%（如特饼干 6→+floor(0.6)=0，需用整数敏感用例校准）。`[待细化]` 若希望小值也吃到加成，改 bonus 结算为「按累计动作数摊算」——当前锁定 floor。
- AT-育3：exp 从 25 加 10 至 35，跨越 Lv2 门槛(30)，则 level=2、leveledUp=true、发 levelUpFluff=10、ExpLogEntry.levelAt 记变动前等级。
- AT-育4：exp 达 210/525/800 时分别 evolved=true(stage B/C)、graduated=true(D)，触发换模/毕业演出。
- AT-育5：每日喂食第 13 次被拒（feedDailyCap=12），无 ExpLogEntry 写入。

### 6.2 离线结算
- AT-离1：lastOnlineAt=now-5h，上线，则 gain=5、offlineExpGrantedToday=5、lastOnlineAt renew=now。
- AT-离2：lastOnlineAt=now-100h，上线，则 gain=min(100,12)=12（单段封顶）。
- AT-离3：同日先离线 5h（+5），再离线 10h（应受日上限）：第二次 gain=min(min(10,12),12-5)=7，累计=12，第三次同日=0。
- AT-离4：慵懒宠日上限=13。
- AT-离5：改表回拨（now < lastOnlineAt），则 gain=0，lastOnlineAt renew=now，**exp 不减**。
- AT-离6：跨本地午夜后首次上线，offlineExpGrantedToday 归零。

### 6.3 旅行 / 明信片
- AT-片1：毕业即生成 Journey，stops 长度=25、wanderStops 长度=15（地点库 40 张时），两者合并去重且按性格加权随机。
- AT-片2：到 nextPostcardAt 生成 1 张 Postcard（body_text 定稿存库、photo_asset_id 非空、stamp_id=location.stampId）；currentIdx 前进。
- AT-片3：25 张主旅程走完 journey.state=WANDERING；剩余 15 张按 10–15 天寄片；40 张完成后按 18–22 天随机回信。
- AT-片4：同一 Postcard 在两相册视图可见但库中仅 1 行（`INV`：无数据复制）。
- AT-片5：ev_s03 许愿的宠，其某张明信片 clue/body 呼应 wishId。

### 6.4 回访
- AT-访回1：毕业进 ROAMING 时 nextRevisitAt=now+rand(7,14d)。
- AT-访回2：due 且当前无回访者，spawn REVISIT，停留 rand(1,2d)；多只 due 按 earliest 排队，同时仅 1（`INV-2`）。
- AT-访回3：回访期在养宠可摸头 1 次/天，获 +5(REVISIT) 写流水；不占在养 slot、不吃动作冷却。
- AT-访回4：20% 概率带旅伴 → 记 VisitorLogEntry + 对应 clueCounter++。
- AT-访回5：onRevisitEnd 重排 nextRevisitAt=now+rand(7,14d)。

### 6.5 访客
- AT-客1：晨窗生成白天访客、夜窗生成夜间访客；每窗口≤1 只。
- AT-客2：夜行访客白天 M_time=0 不出现；青蛙雨天权重×3；空盘全体×0.8。
- AT-客3：星星虫无「夜灯」装饰则 P=0（decorReq 硬门槛）。
- AT-客4：传说访客独立判定，可与普通同日命中。
- AT-客5：首次到访自动写 VisitorLogEntry（收录来客图鉴）。

### 6.6 事件
- AT-事1：每日生成 1–3 个 DAILY，上线演出并写 EventLogEntry(+exp 入 ExpLog source=EVENT_DAILY)。
- AT-事2：SPECIAL 日上限 1；cooldownDays 内不重复；oncePerPet 只触发一次。
- AT-事3：不满足 requiresVisitor/Decor/minLevel/minLuxuryStage 的事件权重=0，不入轮盘。
- AT-事4：二选一事件记录 choice_idx 与对应 expDelta。

### 6.7 经济 / 商店
- AT-经1：毕业结算 fluff=200+min(ev×2,100)+min(vis×3,60)+(彩蛋?80:0)，落在 260..380 区间（常规上界 360、彩蛋 440 亦允许，视参与数）。
- AT-经2：购买扣费写 CurrencyLog(delta<0)，余额不足返回 false 且不透支（balance≥0）。
- AT-经3：永久玩具强化购买后 toyExp 生效 4→6；食粮为消耗品。
- AT-经4：`INV-4` balance==Σdelta 恒成立。

### 6.8 存档迁移
- AT-存1：状态变更 debounce 后自动落盘；崩溃后能从最近有效 slot 恢复。
- AT-存2：schemaVersion 落后时按序迁移到 current，迁移事务化、失败回滚。
- AT-存3：导出文件含 checksum；导入校验 checksum+版本+INV，任一失败拒绝并保留原档。
- AT-存4：启动 AuditService 校验 `INV-1/4`；不一致以流水回正对象值。

### 6.9 成就 / 彩蛋
- AT-彩1：图鉴四态正确：初始 3 种 AVAILABLE、GradCount 型显示进度条(x/threshold)=LOCKED_KNOWN、彩蛋未见访客=LOCKED_HIDDEN 显「？？？」、见访客后显谜语。
- AT-彩2：彩蛋 hiddenSteps 全达成 → bumpClue 至 threshold → 物种转 AVAILABLE。
- AT-彩3：明写成就进度累加到 target 解锁，发奖幂等（rewardClaimed 防重复）。
- AT-彩4：隐藏成就达成前仅显 clueText；彩蛋宠解锁各触发对应隐藏成就（如 ach_h_ember）。

---

## 7. 测试策略

> 框架：`flutter_test` + `mocktail`（mock repo）+ 注入 `Clock`（假时钟）。逻辑层 100% 可离线单测（无 Flame/UI）。目标覆盖：services 高覆盖 + 关键不变量属性测试。

### 7.1 经验审计不变量（最高优先）
- 随机序列：随机 N 次 addExp（各种 source/加成），断言 `INV-1`（pet.exp==Σdelta）恒成立、每条 exp_after 冗余与重算一致。
- `INV-5`：无论输入，delta≥0、exp 单调不减。
- AuditService.verifyOnStartup：构造流水与对象不一致的档，断言回正到 Σdelta，且不删/改流水。
- `INV-4`：随机 earn/spend 序列后 balance==Σdelta，且 spend 从不透支。

### 7.2 离线 renew 边界
- 参数化：elapsed = {-1h, 0, 59min, 1h, 11h59m, 12h, 100h}，断言 gain 与封顶正确、lastOnlineAt 必 renew。
- 多段同日累计到 dailyCap 后归零逻辑（AT-离3/离6）。
- 慵懒特例 13。
- 改表：wall 向前跳（mono 有效/无效两分支）、wall 回拨（gain=0，不倒扣）。

### 7.3 概率分布
- VisitorService.rollWindow：固定种子 RNG，跑 10⁴ 次，断言各访客命中频率落在期望 P±ε（ε 由样本量定）。
- 修正因子：验证 M_time=0/decorReq=0 使 P=0、空盘×0.8、传说独立判定与普通同日可共存。
- 事件权重轮盘同理（personality×weather×time 乘积、门槛过滤）。
- 经验曲线：断言 cumExpAtLevel 与 levelUpCost 前缀和一致、deriveLevel 在每个边界值正确（29/30/31…799/800）。

### 7.4 存档迁移
- 构造 v(current-1) 档，跑 migrateIfNeeded，断言升到 current 且数据等价、事务失败可回滚。
- 导出→导入往返（round-trip）：断言数据完全一致 + INV 通过。
- 损坏 slot：主 slot 反序列化失败时回退备份 slot。
- checksum/版本不符：导入被拒、原档不变。

### 7.5 调度与彩蛋
- EventScheduler catch-up：多 job 过期时按 priority/dueAt 顺序处理，单次上线只演出 1 组。
- Revisit：唯一性（`INV-2`）、排队顺延、重排。
- Postcard：dailyTick 到点生成、主旅程结束转 WANDERING、补完后长期随机回信、双相册单实体。
- UnlockService：dexStateOf 四态全分支、hiddenSteps 累计→bumpClue→AVAILABLE、成就发奖幂等。

### 7.6 集成冒烟（对齐 MVP 验收 §12）
- 端到端脚本（假时钟快进）：领养→17±3 天照料（触发 Lv5/8/10 三次换模）→毕业→收 ≥5 张明信片→1 次回访→领养第二只→院子 luxuryStage 进化，全程 `INV-1..5` 不破。

---

## 附：待细化清单（汇总）

- 彩蛋宠最终 3–5 种（当前 4）；隐藏成就专属贴纸资产 ID。
- AuditService 不一致是否上报 UI（倾向静默回正）。
- ScheduledJob consumed 保留 vs 删除策略。
- 原生单调时钟通道（MVP 可仅 Stopwatch+wall）。
- 加成 floor 对小基值不敏感问题（是否改摊算）。
- 商店食粮背包数据结构。
- SaveService slot 元数据格式（时间戳+crc）。
- game_config 承载二选一：Dart 常量类 vs JSON。
- CUSTOM 型隐藏成就各判定器实现细节（条件已定）。
- 目的地库补齐至 40（奇幻 +1）、访客补至 20（常见 +1）。
```
