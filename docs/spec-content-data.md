# Petopia · 内容数据格式契约（assets/data/*.json）

> **版本：v0.3** ｜ 配套 DESIGN.md / spec-technical.md §5.2 ｜ 本文件是 **content-*.md → JSON 转换的产出目标**（Minimax）与 **ContentRepository 解析契约**（Codex）的权威来源。

## 全局约定

1. **顶层结构**：每个文件 `{ "schemaVersion": 1, "items": [ ... ] }`。`schemaVersion` 与代码期望不符 → 启动报错。
2. **枚举串 = Dart 枚举的 `.name`（lowerCamel）**，解析用 `Enum.values.byName(s)`，**零映射**。对照设计文档里的 UPPER_SNAKE：
   - `PetCategory`: `real` / `fantasy`
   - `PetStage`: `a` `b` `c` `d`　`PetState`: `raising` `traveling` `roaming` `revisiting` `graduated`
   - `ExpSource`: `feed` `pat` `toy` `bath` `offline` `eventDaily` `eventSpecial` `visitor` `revisit` `itemBonus`
   - `CurrencyReason`: `graduation` `dailyFirstCare` `levelUp` `achievement` `revisitGift` `shopPurchase` `eventReward` `importAdjust`
   - `EventType`: `daily` `special` `revisit` `graduation`
   - `VisitorRarity`: `common` `uncommon` `rare` `legendary`
   - `Season`: `spring` `summer` `autumn` `winter`
   - `TimeOfDayOfDay`: `dawn` `morning` `noon` `afternoon` `evening` `night`
   - `Weather`: `clear` `cloudy` `rain` `thunder` `snow` `fog` `rainbow`
   - `UnlockRuleType`: `initial` `gradCount` `hiddenClue`
   - `EffectType`: `themeSkin` `decor` `feedBonus` `toyPermanentBonus` `albumSkin` `visitorProb`
   - `AchievementCondType`: `gradCount` `speciesCollected` `postcardCount` `visitorDexCount` `actionCount` `revisitCount` `loginStreak` `specialEventCount` `yardStage` `themeCount` `stampCount` `seasonPostcard` `unlockPet` `custom`
3. **ID 命名**：沿用设计文档既有 ID（`pet_cat`/`p_glutton`/`loc_*`/`ev_dNN`/`ev_sNN`/`ach_*`/`ach_h_*`/`clue_*`）。
4. **缺省**：可空字段可省略（解析为 null）；Map/List 缺省为空。
5. **枚举做 Map key** 时用 `.name` 字符串 key（如 `weatherPref: {"rain": 3.0}`）。
6. 字段名与 spec-technical §1.2 实体 **一一对应**（Dart 字段名，lowerCamel）。

## 文件清单与示例

### species.json（PetSpecies[]）
```json
{ "id":"pet_hamster", "name":"仓鼠", "category":"real", "baseTone":"囤货、腮帮、跑轮",
  "unlockRule":{ "type":"gradCount", "threshold":1 },
  "variantIds":["pet_hamster_v1","pet_hamster_v2","pet_hamster_v3","pet_hamster_v4","pet_hamster_v5"],
  "dexArtRef":"pet_hamster_var01_stageC", "dexSilhouetteRef":"pet_hamster_silhouette", "dexMysteryRef":null }
```
彩蛋 unlockRule 示例：
```json
{ "type":"hiddenClue", "clueId":"clue_ember", "threshold":3,
  "clueText":"有人说，寒夜里给院子留一盏灯，火焰会记得温暖它的人……",
  "visitorPrereqId":"visitor_campfire_light",
  "hiddenSteps":[ { "stepId":"ember_winter_night_fire", "condType":"custom",
                    "params":{ "visitorId":"visitor_campfire_light", "requireDecor":"deco_stove", "season":"winter", "count":3 } } ] }
```

### personalities.json（PersonalityTag[]）
```json
{ "id":"p_glutton", "name":"贪吃", "persona":"世界尽头是饭碗",
  "eventWeightMap":{ "food":2.0 }, "actionExpBonus":{ "feed":0.10 },
  "actionSetId":"act_glutton", "postcardStyleId":"style_glutton", "specialFlags":[] }
```

### locations.json（Location[]）
```json
{ "id":"loc_lighthouse_bay", "name":"灯塔湾", "category":"海滨", "climate":"温润多风",
  "vibeTags":["sea","calm"], "photoStyle":"pc_bg_seaside_lighthouse", "encounterPoolId":"enc_seaside",
  "personalityWeight":{ "p_dreamy":1.3 }, "stampId":"pc_stamp_lighthouse_bay" }
```

### visitors.json（Visitor[]）
```json
{ "id":"visitor_starbug", "name":"星星虫", "rarity":"legendary",
  "activeTime":["night"], "weatherPref":{ "clear":2.0, "rain":0.0 }, "foodPref":{},
  "seasonPref":{}, "decorReq":["deco_night_lamp"], "clueRole":"clue_starbug", "artRef":"visitor_starbug_portrait" }
```

### visitor_interactions.json（VisitorPetInteraction[]）
```json
{ "id":"vi_sparrow_cat", "visitorId":"visitor_sparrow", "petSpeciesId":"pet_cat",
  "personalityBias":null, "script":"阿橘尾巴拍了三下，最终决定……继续睡。啾啾在它肚皮上开了演唱会",
  "animRef":"anim_vi_sparrow_cat", "expReward":3, "unlockClue":null }
```
兜底：`"petSpeciesId":"*"`。传说访客带 `"unlockClue":"clue_starbug"`。

### events.json（Event[]）
```json
{ "id":"ev_d01", "type":"daily", "title":"追落叶", "script":"追住了一片打转的落叶，得意地叼来给你看",
  "animRef":null, "illustrationRef":null, "expReward":5, "currencyReward":null,
  "weights":{ "personality":{ "p_energetic":2.0 }, "weather":{}, "timeOfDay":{}, "season":{ "autumn":1.5 },
              "requiredWeather":[], "requiredTimeOfDay":[], "requiredSeason":[],
              "requiresVisitor":null, "requiresDecor":null, "minLevel":null, "minLuxuryStage":null, "minAgeDays":null },
  "cooldownDays":0, "oncePerPet":false, "choices":null }
```
带分支示例：`"choices":[ { "text":"拍照留念", "resultScript":"...", "expDelta":2 }, { "text":"帮它翻回来", "resultScript":"...", "expDelta":1 } ]`。

`weather/timeOfDay/season` 是命中后的**软权重乘数**；`requiredWeather/requiredTimeOfDay/requiredSeason` 是进入候选池前的**硬门槛数组**。`minAgeDays` 按领养日起算整日数。硬门槛不满足时事件权重为 0，不能用极低软权重替代。

### achievements.json（Achievement[]）
```json
{ "id":"ach_first_grad", "name":"第一次目送", "hidden":false, "clueText":null,
  "condition":{ "type":"gradCount", "target":1, "params":{} },
  "reward":{ "fluff":50, "decorItemId":null, "couponId":null, "stickerId":null } }
```
隐藏成就：`"hidden":true, "clueText":"有人在星星最亮时来过。", "condition":{"type":"custom","target":1,"params":{...}}, "reward":{"fluff":40,"stickerId":"sticker_xxx"}`。

### shop_items.json（ShopItem[]）
```json
{ "id":"shop_theme_sakura", "category":"院子主题", "name":"樱花小径", "price":400,
  "effect":{ "type":"themeSkin", "params":{ "themeId":"theme_sakura" } },
  "artRef":"ui_shop_theme_sakura", "consumable":false, "stackCount":null }
```
食粮示例：`"effect":{"type":"feedBonus","params":{"expFrom":3,"expTo":6}}, "consumable":true, "stackCount":5`。

### postcard_templates.json（明信片文风骨架 + 词条池）
> 结构承载 §6.3 生成管线所需：正文骨架（按性格×类别）、遭遇池、碰撞池。
```json
{ "schemaVersion":1,
  "templates":[ { "id":"tpl_glutton_seaside_01", "personalityId":"p_glutton", "category":"海滨",
                  "skeleton":"主人！{location}的{encounter}……{incident}。——{petName}", "slots":["encounter","incident"], "tone":"通篇讲吃的" } ],
  "encounters":[ { "id":"enc_seaside_01", "poolId":"enc_seaside", "phrase":"烤鱼摊老板", "verb":"请我吃", "personalityBias":{ "p_glutton":2.0 } } ],
  "incidents":[ { "id":"inc_sea_01", "vibe":"sea", "type":"小奇迹", "phrase":"浪花在脚边写了个字", "poseHint":"gaze", "personalityBias":{} } ] }
```
（此文件顶层用 `templates/encounters/incidents` 三数组，非通用 `items`。）

### clue_defs.json（彩蛋链定义）
```json
{ "schemaVersion":1,
  "items":[ { "clueId":"clue_ember", "threshold":3, "visitorPrereqId":"visitor_campfire_light",
              "unlocksSpeciesId":"pet_ember",
              "steps":[ { "stepId":"...", "condType":"custom", "params":{} } ] } ] }
```

## 加载约定
- `ContentRepository.loadAll()` 启动读全部文件到不可变内存；`schemaVersion != 期望` → 抛异常。
- 转换脚本单向 `md → json`，不回写 md。产物由 Claude 评审入库。
- Minimax 产出要求：**只输出合法 JSON**（无 Markdown 代码围栏、无 `<think>` 说明文字）。
