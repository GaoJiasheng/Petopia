# Petopia 美术素材制作 TODO

> 范围：视觉美术素材全量制作，不只 MVP。依据 `spec-art-overview.md`、`spec-art-pets.md`、`spec-art-world.md`、`spec-art-postcards.md`、`spec-art-ui.md`。音频素材另见 `spec-audio.md`，不混入本文。
>
> 当前 session 执行边界：**只处理美术素材**，包括风格板、样张、资产清单、图片生成、素材入库与美术规格文档同步。代码实现、工程骨架、Flutter/Flame、数据转换、运行时逻辑由其他 session 处理，本 session 不改。
>
> 整体风格：**奶油卡通可爱风（creamy cartoon cute）**，顶级成品水彩渲染。圆润、柔软、明快、可亲近；色彩比 v2 样张更鲜艳，桃粉、嫩绿、天蓝、杏橙、奶油白均衡出现，避免整体偏黄；禁止扁平 SVG、廉价贴纸感、塑料亮面、荧光糖果风。
>
> 当前全量视觉规模：宠物约 468 项、院子/访客 121 项、明信片 272 项、UI 165 项，合计约 1026 个高层资产条目；动画帧、骨骼部件、@2x/@3x 导出不重复计数。

---

## 0. 开画前必须收口

- [ ] 统一画布口径：全局总纲/设备规格要求 full-bleed 参考 `1290x2796`，`spec-art-world.md` 多处写 `1080x1920 @1x`。开批量前确定：源文件按哪个尺寸绘制、运行时按哪个尺寸导出。
- [ ] 建资产索引表：字段至少包含 `asset_id`、域、规格文档、尺寸、格式、状态、批次、源文件路径、导出路径、负责人、备注。
- [ ] 建交付目录：`assets/art/pets/`、`assets/art/world/`、`assets/art/postcards/`、`assets/art/ui/`。
- [ ] 统一终稿格式：PNG 透明通道为主；动画优先 Spine/DragonBones，序列帧需提供 sprite sheet；所有静态/动画都要有首帧预览图。
- [ ] 明确 @1x/@2x/@3x 导出规则，9-patch 件必须附切线标注图。
- [ ] 明确源文件要求：背景、复杂 UI、角色定稿建议附 PSD/TIFF 分层源文件。
- [ ] 冻结“奶油卡通可爱风”风格板：圆润比例、明快奶油色、柔和水彩光影、纸质手账质感；整体比 v2 更鲜艳、更卡通，禁用大面积黄罩、荧光糖果色、塑料感、扁平图标。
- [ ] 修正 `spec-art-world.md` MVP 摆件数量：W5 写 13 项，但带星实际数到 12 项。
- [ ] 决定特邀访客“寄居蟹搬家队”是否进入美术全量：内容文档有设计，当前 `spec-art-world.md` 未给 `visitor_hermitcrabs_portrait/_yard` 条目。若“文档里有设计的都做”，需要补这组美术规格。
- [ ] 统一访客 ID 映射：内容为 `v_*`，互动矩阵为 `vst_*`，美术为 `visitor_*`，资产索引里要有映射列。
- [ ] 明确四季花园 `yard_theme_fourseasons_bg/props` 是按 1 套主题项还是 4 季变体分别交付。

---

## 1. 样张阶段

目标：先锁定风格、渲染质量、分层方式、动画规格、UI 手感，再批量生产。

### 1.1 全局风格样张

- [ ] 全局纸纹：`ui_tex_paper` 3 个变体，验证纸粒、纤维、夜蓝底。
- [ ] 色板样张：总纲 9 个核心色 + 1 组主题扩展色。
- [ ] 奶油卡通可爱风 moodboard：至少 1 张角色、1 张场景、1 组 UI，统一验证圆润比例、奶油柔光、明快色彩、卡通可读性。
- [ ] 线条/水彩边缘样张：验证 1-2px 出线、低对比阴影、纸纹叠加。
- [ ] 图标渲染样张：1 个 P 级图标、1 个 S 级图标，确认不是扁平 SVG 风。

### 1.2 院子样张

- [ ] `yard_luxury01_layout`：小小角落，含草皮、食盆锚点、旧邮箱锚点。
- [ ] `yard_theme_meadow_bg/props`：原野手账主题背景 + props。
- [ ] `deco_food_bowl`、`deco_mailbox_old`、`deco_night_lamp` 三件摆件。
- [ ] `yard_fx_day`、`yard_fx_dusk`、`yard_fx_night` 三个时段光效。
- [ ] 合成一张院子主屏样张：背景 + 布局 + 摆件 + 光效 + safe-area 标注。

### 1.3 宠物样张

- [ ] `pet_cat_var01_stageA-D`：橘猫 var01 四成长档。
- [ ] 橘猫通用动作 4 条样张：`idle`、`walk`、`eat`、`pat`。
- [ ] 橘猫性格动作 1 条样张：建议 `act_glu_01_cat`。
- [ ] 骨骼/序列帧交付样张：含部件切图、动作预览、首帧 PNG。
- [ ] 宠物在院子中合成样张：stageA 与 stageC 各一张，验证比例。

### 1.4 访客样张

- [ ] `visitor_sparrow_portrait`：图鉴肖像。
- [ ] `visitor_sparrow_yard`：院内立绘 + idle 4 帧 + 啄食 6 帧。
- [ ] 访客在院子 z 层合成样张。

### 1.5 明信片样张

- [ ] `pc_bg_lighthouse_bay`：地点背景板。
- [ ] `pc_pose_cat_gaze`：橘猫旅行姿态。
- [ ] `pc_filter_dusk`：黄昏滤镜。
- [ ] `pc_stamp_lighthouse_bay`：邮戳。
- [ ] `pc_chrome_*` 里先做卡纸、相角、通用邮票、邮戳压印区。
- [ ] 合成 1 张完整明信片正面样张。
- [ ] 合成 1 张完整明信片背面样张，验证 UI 与文字区域。

### 1.6 UI 样张

- [ ] `ui_btn_tape_primary`：4 色 × 常态/按下态。
- [ ] `ui_frame_clip_tab`：选中/未选中态。
- [ ] `ui_icon_hourglass_wc`：冷却动画 6 帧 + 化开 3 帧。
- [ ] `ui_frame_soft_toast`：经验/暖绒提示条。
- [ ] `ui_frame_mailbox_flag`：落下态 + 立起呼吸 4 帧。
- [ ] 主屏 UI 合成样张：顶栏、底栏、动作条、邮箱旗、SoftToast。

### 1.7 样张验收

- [ ] 样张达到总纲 AAA/商店级质量线，不允许草图、扁平图标、廉价占位。
- [ ] 样张符合奶油卡通可爱风：圆润、柔软、明快、温暖可亲；不偏黄、不灰、不塑料，不走荧光糖果风或硬边廉价卡通。
- [ ] 透明通道干净，无白边、毛边、锯齿。
- [ ] 放到浅色/深色/夜景底下都可读。
- [ ] @1x/@2x/@3x 导出清晰。
- [ ] 动画首尾循环自然，帧率符合 6-12fps 的治愈手感。
- [ ] 样张通过后冻结风格，不再大幅改画风。

---

## 2. 宠物全量生产

来源：`spec-art-pets.md`。

### 2.1 物种形态

每个物种交付 `5 变体 x 4 成长档 = 20 形态`，全量 12 物种共 240 形态。

- [ ] 橘猫 `pet_cat`：var01-var05，stageA-D。
- [ ] 柴犬 `pet_shiba`：var01-var05，stageA-D。
- [ ] 垂耳兔 `pet_rabbit`：var01-var05，stageA-D。
- [ ] 仓鼠 `pet_hamster`：var01-var05，stageA-D。
- [ ] 乌龟 `pet_turtle`：var01-var05，stageA-D。
- [ ] 鹦鹉 `pet_parrot`：var01-var05，stageA-D。
- [ ] 玉米蛇 `pet_snake`：var01-var05，stageA-D。
- [ ] 变色龙 `pet_cham`：var01-var05，stageA-D。
- [ ] 小火龙 `pet_ember`：var01-var05，stageA-D。
- [ ] 独角兔尼可 `pet_uni`：var01-var05，stageA-D；复用 rabbit 骨骼但必须交付角、鬃毛、柔光层。
- [ ] 小幽灵噗噗 `pet_boo`：var01-var05，stageA-D。
- [ ] 星星虫 `pet_starbug`：var01-var05，stageA-D。

### 2.2 通用基础动作

每个物种 8 条，全量 96 条。

- [ ] `walk`：移动。
- [ ] `sit`：坐姿。
- [ ] `sleep`：睡眠。
- [ ] `eat`：进食。
- [ ] `pat`：摸头。
- [ ] `bath`：洗澡。
- [ ] `play`：玩耍。
- [ ] `idle`：待机。
- [ ] 逐物种完成 8 动作：cat / shiba / rabbit / hamster / turtle / parrot / snake / cham / ember / uni / boo / starbug。

### 2.3 性格动作模板

全量 10 性格 x 10 动作 = 100 模板；每个模板需给物种适配说明，异构物种要二创而不是机械套骨骼。

- [ ] 贪吃 `act_glu_01-10`。
- [ ] 慵懒 `act_laz_01-10`。
- [ ] 好奇 `act_cur_01-10`。
- [ ] 胆小 `act_tim_01-10`。
- [ ] 活力 `act_ene_01-10`。
- [ ] 黏人 `act_cli_01-10`。
- [ ] 高冷 `act_alo_01-10`。
- [ ] 淘气 `act_nau_01-10`。
- [ ] 温柔 `act_gen_01-10`。
- [ ] 梦幻 `act_dre_01-10`。
- [ ] 补齐 turtle/parrot/snake/cham/starbug/boo 等异构物种逐条适配注释。

### 2.4 彩蛋宠专属特效

- [ ] 小火龙火花/尾焰特效组。
- [ ] 独角兔彩虹/流光特效组。
- [ ] 小幽灵穿墙/半透明特效组。
- [ ] 星星虫发光/光轨特效组。

### 2.5 图鉴插画

- [ ] 12 张彩色图鉴立绘：`pet_<species>_dex_color`。
- [ ] 12 张未解锁灰剪影：`pet_<species>_dex_silhouette`。
- [ ] 4 张彩蛋问号渍：`pet_ember/uni/boo/starbug_dex_mystery`。

---

## 3. 院子与访客全量生产

来源：`spec-art-world.md`。

### 3.1 豪华度布局层

- [ ] `yard_luxury01_layout`。
- [ ] `yard_luxury02_layout`。
- [ ] `yard_luxury03_layout`。
- [ ] `yard_luxury04_layout`。
- [ ] `yard_luxury05_layout`。
- [ ] `yard_luxury06_layout`。
- [ ] 每阶额外交付“相对上一阶增量图层 + 合成完整层”。
- [ ] 每阶附锚点 JSON：食盆、邮箱、摆件、树、池塘、纪念墙等。

### 3.2 主题风格层

每款主题交付 `bg + props`，全量 12 款 = 24 项；四季花园是否拆 4 季变体按 0 节收口结论执行。

- [ ] 原野手账 `yard_theme_meadow_bg/props`。
- [ ] 樱花小径 `yard_theme_sakura_bg/props`。
- [ ] 星夜帐篷 `yard_theme_starcamp_bg/props`。
- [ ] 海风假日 `yard_theme_seaside_bg/props`。
- [ ] 秋日果酱 `yard_theme_autumnjam_bg/props`。
- [ ] 雪屋暖灯 `yard_theme_snowhut_bg/props`。
- [ ] 雨季青苔 `yard_theme_mossrain_bg/props`。
- [ ] 糖果焙房 `yard_theme_candybake_bg/props`。
- [ ] 四季花园 `yard_theme_fourseasons_bg/props`。
- [ ] 青竹茶亭 `yard_theme_bambootea_bg/props`。
- [ ] 月光温室 `yard_theme_moongreen_bg/props`。
- [ ] 麦浪风筝 `yard_theme_wheatkite_bg/props`。

### 3.3 可放置摆件

全量 40 项。

- [ ] 功能物 7 项：食盆、水碗、旧铁皮邮箱、木信箱、红邮筒、相册架、纪念墙。
- [ ] 食物盘 4 项：谷粒盘、小鱼干盘、坚果盘、苹果片盘。
- [ ] 商店装饰 8 项：夜灯、暖炉、亮闪闪风铃、野花花坛箱、蘑菇石凳、稻草人邮差、星星风向标、木牌门号。
- [ ] 豪华度固定设施 10 项：木篱笆、小花坛、晾衣绳、季节树、轮胎秋千、小池塘、石板路、回访小屋、花藤门廊、阁楼小屋。
- [ ] 特殊玩具 4 项：毛线球、发条小鸭、藤编逗猫棒、软木飞盘。
- [ ] 成就/氛围补充件 7 项：迎宾铃、原木长凳、干花花环、手账路标、纸风车、石子小径灯、明信片小画架。

### 3.4 天气/时段光效

全量 11 项。

- [ ] `yard_fx_day`。
- [ ] `yard_fx_dusk`。
- [ ] `yard_fx_night`。
- [ ] `yard_fx_rain_overlay`。
- [ ] `yard_fx_rain_particle`。
- [ ] `yard_fx_snow_overlay`。
- [ ] `yard_fx_snow_particle`。
- [ ] `yard_fx_aurora`。
- [ ] `yard_fx_firefly`。
- [ ] `yard_fx_thunder_soft`。
- [ ] `yard_fx_petal_drift`。

### 3.5 访客美术

每个访客交付 `portrait + yard`，全量 20 种 = 40 项；传说访客的线索闪帧随 `yard` 一并交付。

- [ ] 常见 6：麻雀、流浪三花猫、蜗牛慢递员、白粉蝶、小刺猬、鸽子。
- [ ] 不常见 5：松鼠、乌鸦、青蛙、萤火虫群、橘色狸猫。
- [ ] 稀有 5：白鹭、狐狸、猫头鹰、小鹿、雪兔。
- [ ] 传说 4：星星虫、篝火夜的火光、彩虹边的白影、深夜白团子。
- [ ] 若确认补特邀访客：追加寄居蟹搬家队 `visitor_hermitcrabs_portrait/_yard`。

---

## 4. 明信片全量生产

来源：`spec-art-postcards.md`。

### 4.1 地点背景板

全量 40 张，8 类 x 5。

- [ ] 海滨 5：灯塔湾、猫背礁、贝壳镇、退潮沙洲、海雾码头。
- [ ] 山地 5：云顶垭口、温泉猴谷、枫火岭、雪线木屋、回声峡谷。
- [ ] 城市 5：电车老街、屋顶水塔城、深夜面馆街、旧书坊巷、摩天轮码头。
- [ ] 乡野 5：麦浪邮局、向日葵车站、萤火稻田、苹果坡农场、风车塘。
- [ ] 森林 5：蘑菇环林地、千年橡树邮筒、松果集市、雾中吊桥、伐木温居。
- [ ] 沙漠/异域 5：星空盐湖、驼铃绿洲、彩绘集市、风蚀石林、热气球营地。
- [ ] 极地/水域 5：极光渔村、浮冰灯塔、蓝洞泉、运河小城、汽船栈桥。
- [ ] 奇幻 5：云端牧场、月亮背面的邮局、糖霜火山、会走路的岛、星星修理铺。

### 4.2 宠物旅行姿态

全量 12 物种 x 8 姿态 = 96 个。

- [ ] 8 姿态母版：`_gaze`、`_run`、`_eat`、`_sleep`、`_photo`、`_surprise`、`_soak`、`_hat`。
- [ ] 12 物种适配：cat / shiba / rabbit / hamster / turtle / parrot / snake / chameleon / ember / uni / boo / starbug。
- [ ] `_eat` 标食物挂点，`_hat` 标帽位挂点，`_soak` 标水面遮罩线。

### 4.3 滤镜

- [ ] `pc_filter_sunny`。
- [ ] `pc_filter_rain`。
- [ ] `pc_filter_snow`。
- [ ] `pc_filter_dusk`。
- [ ] `pc_filter_night`。
- [ ] `pc_filter_aurora`。

### 4.4 碰撞/遭遇贴纸

全量 60 个。

- [ ] 海风咸咸 8。
- [ ] 云上辽阔 8。
- [ ] 市井烟火 8。
- [ ] 田园暖光 8。
- [ ] 林间幽绿 8。
- [ ] 炽烈异域 8。
- [ ] 清冽极北 7。
- [ ] 梦境边缘 5。
- [ ] 通用明星道具 `pc_sticker_charsiu`。
- [ ] 对需要叠背景的半透明贴纸标记 `⊥` 并测试混合模式。

### 4.5 邮戳徽章

- [ ] 40 个地点邮戳，与 40 张地点背景一一对应。
- [ ] 每枚 128x128，暖棕圆形邮戳框，必要时仅 1 个点缀色。

### 4.6 特例全手绘插画

全量 20 张。

- [ ] `pc_special_cheeks`。
- [ ] `pc_special_charsiu_moon`。
- [ ] `pc_special_flag_ears`。
- [ ] `pc_special_living_scarf`。
- [ ] `pc_special_star_shell`。
- [ ] `pc_special_tram_caller`。
- [ ] `pc_special_shy_color`。
- [ ] `pc_special_leaf_ears`。
- [ ] `pc_special_free_letter`。
- [ ] `pc_special_apple_roll`。
- [ ] `pc_special_ball_friends`。
- [ ] `pc_special_seal_pile`。
- [ ] `pc_special_sand_names`。
- [ ] `pc_special_aurora_chorus`。
- [ ] `pc_special_cloud_rider`。
- [ ] `pc_special_hat_typhoon`。
- [ ] `pc_special_belly_circle`。
- [ ] `pc_special_wish_receipt`。
- [ ] `pc_special_letter_field`。
- [ ] `pc_special_double_wish`。

### 4.7 明信片 chrome

全量 10 项。

- [ ] 明信片卡纸正面框。
- [ ] 明信片背面版式。
- [ ] 相角贴。
- [ ] 通用邮票。
- [ ] 邮戳压印区。
- [ ] 墨渍/盖印反馈。
- [ ] 信纸/落款区装饰。
- [ ] 翻面/阴影辅助件。
- [ ] 相册缩略边框适配件。
- [ ] 免邮票奇幻彩蛋状态件。

---

## 5. UI 全量生产

来源：`spec-art-ui.md`。全量图像资产 165 项。

### 5.1 手账基础套件

- [ ] 基础套件 22 项全量。
- [ ] 纸纹、撕边纸、胶带按钮、圆贴纸按钮、页签、图钉、气泡、事件卡、确认卡、沙漏、邮箱旗、SoftToast、经验条、进度条、抽屉、名牌、卡底、顶栏、底栏、院子键等全部完成。

### 5.2 字体视觉规格

- [ ] 标题体“铅笔手账体”候选与授权确认。
- [ ] 正文字体“圆润手写体”候选与授权确认。
- [ ] 字重、字号、字色、行高、可读性样张。

### 5.3 按屏 UI 元素

全量 S1-S16。

- [ ] S1 院子主屏。
- [ ] S2 宠物详情页。
- [ ] S3 成长手账页。
- [ ] S4 宠物图鉴。
- [ ] S5 来客图鉴。
- [ ] S6 明信片相册。
- [ ] S7 旅行相册。
- [ ] S8 明信片查看器/收信演出。
- [ ] S9 暖绒商店。
- [ ] S10 成就页。
- [ ] S11 设置页。
- [ ] S12 领养流程。
- [ ] S13 毕业典礼演出。
- [ ] S14 回访演出。
- [ ] S15 首次启动/新手引导。
- [ ] S16 Lv5/8/10 换模演出。

### 5.4 图标集

全量 60 个。

- [ ] 导航/入口图标 7。
- [ ] 照料动作图标 5。
- [ ] 货币与资源图标 2。
- [ ] 商店分类图标 5。
- [ ] 食盆放置食物图标 5。
- [ ] 手账流水来源图标 8。
- [ ] 天气/时段图标 8。
- [ ] 成就图标 8。
- [ ] 设置图标 6。
- [ ] 杂项功能图标 6。

### 5.5 徽章集

- [ ] 等级徽章 4 档。
- [ ] 访客/图鉴稀有度徽章 4 档。
- [ ] 其他徽章 3 项。

### 5.6 转场与反馈特效

- [ ] UI 特效 9 项全量。
- [ ] `ui_fx_wash_transition` 必须先完成并作为页面转场统一标准。
- [ ] 收信、邮戳、购买、暖绒、毕业飘瓣等反馈特效逐项导出。

---

## 6. 生产批次建议

### 6.1 Batch A：样张冻结

- [ ] 完成第 1 节全部样张。
- [ ] 输出一页风格规范板。
- [ ] 输出一张主屏合成图。
- [ ] 输出一张完整明信片合成图。
- [ ] 输出一段宠物动画预览。

### 6.2 Batch B：核心骨架

- [ ] UI 基础套件 22。
- [ ] 院子豪华度 1-3 + 原野/樱花主题。
- [ ] 初始 3 宠物 36 形态。
- [ ] 初始 3 宠物通用动作 24。
- [ ] 访客常见 6。
- [ ] 明信片 12 背景 + 24 姿态 + 12 邮戳 + chrome 10。

### 6.3 Batch C：系统闭环

- [ ] UI S1-S16 里闭环必需件。
- [ ] 毕业、换模、回访、收信演出所需 UI/特效。
- [ ] 事件/成就/商店/图鉴所需图标与徽章。
- [ ] 夜晚、雨、雪、极光等光效补齐。

### 6.4 Batch D：全量宠物扩展

- [ ] 后续 9 物种形态。
- [ ] 后续 9 物种通用动作。
- [ ] 全部 100 性格动作模板与物种适配。
- [ ] 彩蛋宠专属特效。

### 6.5 Batch E：全量世界扩展

- [ ] 豪华度 4-6。
- [ ] 主题 3-12。
- [ ] 摆件 40 全量。
- [ ] 访客 20 全量，若补寄居蟹则 21。

### 6.6 Batch F：全量明信片扩展

- [ ] 40 地点背景全量。
- [ ] 96 姿态全量。
- [ ] 60 贴纸全量。
- [ ] 40 邮戳全量。
- [ ] 20 特例插画全量。

### 6.7 Batch G：全量 UI polish

- [ ] 非核心 UI 元素补齐。
- [ ] 导入/导出、旅行相册、书架、相册皮肤、非 MVP 天气图标补齐。
- [ ] 所有 9-patch 和动态填充件做实机可读性检查。

---

## 7. 入库与 QA

- [ ] 每个资产文件名严格等于 `asset_id`。
- [ ] 所有资产登记到资产索引表。
- [ ] 所有 PNG 检查透明通道、边缘白边、尺寸、颜色空间。
- [ ] 所有 full-bleed 背景做 4:3、16:9、19.5:9、21:9 裁切预览。
- [ ] 所有 UI 组件在浅色、深色、夜景、雨天底下检查可读性。
- [ ] 所有动画导出首帧预览和 loop 预览。
- [ ] 所有宠物/访客动画检查锚点、脚底接地、比例、z 层遮挡。
- [ ] 所有明信片组件做至少 20 张随机合成测试。
- [ ] 所有图标禁用纯黑、纯红、硬感警告符号。
- [ ] 所有素材符合零焦虑红线：无红点轰炸、无强倒计时、无惊吓强闪、无尖锐高对比。
- [ ] 每批交付后更新资产索引和缺口清单。

---

## 8. 当前已知缺口

- [ ] `spec-art-world.md` 未覆盖内容文档里的特邀访客“寄居蟹搬家队”。
- [ ] `spec-art-world.md` W5 摆件数量 13 与实际列出的 12 项不一致。
- [ ] `spec-art-postcards.md` 水面遮罩、帽子覆盖遮罩仍有 `[待验证]`。
- [ ] `spec-art-pets.md` 异构物种性格动作适配表仍需补。
- [ ] 动画首帧预览规格仍是 `[待细化]`。
- [ ] 设备适配要求与 world 文档尺寸口径需统一。
