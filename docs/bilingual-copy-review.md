# Petopia 中英文文案总审阅表

> 本文档由 `tools/generate_bilingual_copy_review.py` 从当前运行时本地化代码和
> `assets/data/*.json` 自动生成。中文是现有存档与内容的基准文案；英文是 App
> 当前实际展示的文案。玩家自定义宠物名保持原样。

## 审阅总览

| 领域 | 数量 | 当前英文策略 | 审阅重点 |
| --- | --- | --- | --- |
| 固定 UI | 375 | 逐条人工英文 | 按钮、标题、说明、空状态 |
| 名称与短语 | 261 | 逐条人工英文 | 物种、性格、商店、成就、地点 |
| 动态 UI | 97 | 98 条参数化规则 | 数字、宠物名、日期、进度 |
| 事件 | 120 | 120 个事件逐条英文 | 标题、正文、30 个选择及结果 |
| 明信片 | 240 | 240 个中文模板映射到 30 个英文性格模板 | 英文保留性格，但未逐张直译中文梗 |
| 旅途片段 | 120 | 120 条逐条英文 | 遭遇与小插曲 |
| 来客互动 | 244 | 20 个来客动作 × 12 个物种回应，4 条传说专稿 | 英文按来客和物种组合，不逐句直译 |
| 成长、离线与院子记忆 | 41 | 按等级/性格/状态写作 | 变量以占位符展示 |

## 本轮审校结论

本表中的运行时文案已按 `docs/copy-tone-guide.md` 逐条复核。
固定 UI 必须事实一致；组合式叙事允许独立写作，但场景输入、情绪强度和角色态度必须一致。

| 检查项 | 结论 | 执行标准 |
| --- | --- | --- |
| 措辞得体 | 通过 | 系统状态直接；叙事保留一个清晰意象 |
| 温馨但不索取 | 通过 | 不要求玩家回信、上线、等待或付费 |
| 可爱但不幼稚 | 通过 | 不用连续标点、叠词或默认幼态形容词支撑语气 |
| 中英文对应 | 通过 | 名称统一；场景输入、情绪强度与角色态度一致 |
| 付费克制 | 通过 | 自愿、纯装饰、时长、重复购买与恢复范围均明示 |
| 运行时洁净 | 通过 | 无规格编号、等级、线索数值或编辑标记泄漏 |

## 优先审阅：跨场景英文命名不一致

当前共有 0 处名称在列表/短 UI 与叙事中使用了不同英文。
所有地点和来客名称已在列表、短 UI、叙事与明信片中保持一致。

| 领域 | ID | 中文 | 列表/短 UI | 叙事/明信片 |
| --- | --- | --- | --- | --- |

## 1. 固定 UI 文案

这些文案由 `AppText` / `EnglishCopy` 直接逐条匹配。

| 中文 | English |
| --- | --- |
| 设置 | Settings |
| 收藏与设置 | Collection & Settings |
| 声音 | Sound |
| 背景音乐 | Music |
| 互动音效 | Interaction Sounds |
| 轻柔触感 | Gentle Haptics |
| 画面 | Visuals |
| 画面质量 | Visual Quality |
| 自动 | Auto |
| 精致 | Detailed |
| 省电 | Saver |
| 温柔提醒 | Gentle Reminders |
| 允许通知 | Allow Notifications |
| 存档与隐私 | Saves & Privacy |
| 导出存档 | Export Save |
| 导入存档 | Import Save |
| 隐私说明 | Privacy |
| 支持小院 | Support the Garden |
| 帮助与支持 | Help & Support |
| 开源许可 | Open-Source Licenses |
| 版本 | Version |
| 语言 | Language |
| 跟随系统 | Use Device Language |
| 简体中文 | Simplified Chinese |
| 英语 | English |
| 系统 | Device |
| 简中 | 简中 |
| 跟随设备语言，也可以在应用内固定选择。 | Follow your device, or choose a language just for Petopia. |
| 使用设备语言；暂不支持的语言会显示英语。 | Uses your device language. Unsupported languages fall back to English. |
| 固定使用简体中文。 | Always use Simplified Chinese. |
| Use English throughout the app. | Use English throughout the app. |
| 关闭 | Close |
| 取消 | Cancel |
| 继续 | Continue |
| 确认 | Confirm |
| 再试一次 | Try Again |
| 这次没有顺利出发，旅程还没有开始。请稍后再试。 | The journey has not started yet. Please try again. |
| 小院暂时没能记下这一步，请再试一次。 | The garden could not save that step. Please try again. |
| 这次没能迎接它进院子，请再试一次。 | Your new friend could not move in yet. Please try again. |
| 读取中 | Loading |
| 正在连接 | Connecting |
| 测试：推进一天 | Testing: advance one day |
| 正在推进内测时间 | Advancing test time |
| 内测时间已推进 1 天 | Test time advanced by 1 day |
| 设置暂时没有翻开 | Settings are temporarily unavailable |
| 音乐和互动音效可以分别保留。 | Choose music and interaction sounds separately. |
| 院子、相册和毕业旅程的情境音乐。 | Music for the garden, album, and journeys. |
| 保留铃声、升级和点击的柔和声音。 | Soft chimes for taps, growth, and special moments. |
| 摸摸、成长和告别时的轻触反馈，可独立关闭。 | A gentle tap for care, growth, and goodbyes. |
| 自动档会保持完整质感，并在系统内存紧张时安静降级。 | Keeps the full look, then eases the load when needed. |
| 推荐。优先预热常用互动，系统有压力时自动保护。 | Recommended. Preloads common actions and adapts when needed. |
| 优先预热全部互动；内存紧张时仍会暂时降低负载。 | Preloads every action, with safeguards under memory pressure. |
| 保留宠物和互动反馈，减少背景动态且不预热动作。 | Keeps pets and feedback crisp while reducing background motion. |
| 只提醒真实发生的事情，每天最多一条。 | Only for real arrivals and moments, at most once a day. |
| 不会发送连续登录、催促回来或倒计时提醒。 | No streaks, return nudges, or countdown alerts. |
| 系统没有允许通知；需要时可在系统设置中重新开启。 | Notifications are off. You can enable them in iOS Settings anytime. |
| 进度默认只保存在当前设备。 | Your progress stays on this device by default. |
| 生成带完整性校验的备份文件，可存到“文件”或其他位置。 | Create a verified backup for Files or another safe location. |
| 导入前会验证格式、校验码和经验/暖绒流水。 | Checks the file, checksum, XP, and Sunfluff history first. |
| 查看本地存档、通知和第三方服务的说明。 | See how saves, notifications, and third-party services work. |
| 查看常见问题，或通过支持页面联系我们。 | Read common answers or contact us through the support page. |
| 查看 Flutter 与第三方开源组件的许可证。 | View licenses for Flutter and other open-source components. |
| 导出诊断信息 | Export Diagnostics |
| 仅分享版本与运行状态，不包含昵称、明信片正文或设备标识。 | Includes app status only—not names, postcard text, or device IDs. |
| 存档已经准备好，可选择保存位置。 | Your backup is ready. Choose where to save it. |
| 存档已经恢复。 | Your garden has been restored. |
| 存档未通过校验，当前院子保持不变。 | That backup could not be verified. Your current garden is unchanged. |
| 导入没有完成，当前院子保持不变。 | Import did not finish. Your current garden is unchanged. |
| 这次没有导出成功，当前存档没有受到影响。 | Export did not finish. Your save is safe. |
| 这次没有导出成功，请稍后再试。 | Export did not finish. Please try again. |
| 诊断信息已经准备好，可发送给支持人员。 | Diagnostics are ready to share with support. |
| 暂时无法打开网页，请稍后再试。 | That page could not open. Please try again. |
| 导入这份院子存档？ | Restore this garden backup? |
| 导入会替换当前进度。文件会先完整校验；任何一步失败都会保留现在的院子。 | This replaces current progress after a full verification. If any check fails, your garden stays untouched. |
| 校验并导入 | Verify & Import |
| 正在校验存档… | Verifying backup… |
| Petopia 存档 | Petopia Save |
| Petopia 存档备份 | Petopia Save Backup |
| Petopia 诊断信息 | Petopia Diagnostics |
| 关于 | About |
| 本地保存 · 无账号 · 无广告追踪 | Saved locally · No account · No ad tracking |
| 商店 | Shop |
| 暖绒商店 | Sunfluff Shop |
| 暖绒余额 | Sunfluff Balance |
| 今天的暖绒余额 | Today's Sunfluff |
| 去商店看看 | Visit the Shop |
| 兑换 | Get |
| 兑换中 | Getting… |
| 可兑换 | Available |
| 已拥有 | Owned |
| 使用中 | In Use |
| 应用 | Use |
| 应用名称 | App |
| 暖绒不足 | Not Enough Sunfluff |
| 全部 | All |
| 院子主题 | Garden Themes |
| 装饰小物 | Decor |
| 特殊食粮 | Special Treats |
| 特殊玩具 | Special Toys |
| 相册装帧 | Album Covers |
| 商店暂时没有开门 | The shop is temporarily unavailable |
| 商店货架还在整理 | The shelves are still being arranged |
| 等新商品上架后，这里会变得热闹起来。 | New finds will appear here soon. |
| 换一点小院会喜欢的东西。 | Pick out something lovely for the garden. |
| 暖绒不足，或这件物品已经拥有。 | You may need more Sunfluff, or already own this item. |
| 这次没有兑换成功，暖绒和物品都没有变化。 | Nothing changed. Please try again. |
| 成就 | Achievements |
| 成就册暂时没有翻开 | Achievements are temporarily unavailable |
| 成就册还没有页签 | Your achievement book is still blank |
| 等小院发生更多故事，这里会贴上新的印章。 | New stamps will appear as your garden story grows. |
| 已达成 | Completed |
| 进行中 | In Progress |
| 未记录 | Not Yet |
| 纪念收藏 | Keepsake |
| 主题折扣券 | Theme Coupon |
| 纪念贴纸 | Keepsake Sticker |
| 纪念章 | Keepsake Badge |
| 累计 | Total |
| 线索 | Clue |
| 隐藏 | Hidden |
| 隐藏成就还没有露出线索。 | This hidden achievement has not revealed a clue yet. |
| 线索还藏在院子的某一页。 | The clue is still tucked somewhere in the garden. |
| 线索几乎完整：那团火光已经记住院子，再相遇一次也许就会留下。 | The clue is nearly complete: the flame remembers this garden and may stay after one more meeting. |
| 线索几乎完整：雨后的白色身影已经很近了，下一场彩虹里也许会再靠近。 | The clue is nearly complete: the white shape may come closer with the next rainbow. |
| 线索几乎完整：午夜的空食盘旁，只差最后一次轻轻的脚步。 | The clue is nearly complete: one more midnight visit may leave tracks beside the empty dish. |
| 线索几乎完整：草丛里的星光正试着认出这座院子。 | The clue is nearly complete: the starlight in the grass is beginning to recognize this garden. |
| 线索已经很清晰了，也许下一次相遇就会有答案。 | The clue is clear now. The next meeting may bring an answer. |
| 寒夜里的火光不只是路过，它似乎在寻找一座愿意为来客留灯的院子。 | The flame in the winter night seems to be looking for a garden with a lantern for visitors. |
| 那道白色身影常在雨停后、彩虹刚出现时靠近。 | The white shape often draws near just after the rain, when a rainbow first appears. |
| 夜深以后，安静又空着的食盘会让害羞的脚步更靠近。 | Late at night, a quiet, empty dish may draw shy footsteps closer. |
| 晴朗夜里，温柔的灯和不被打扰的草丛会让星光停得更久。 | On clear nights, a warm lantern and undisturbed grass invite the starlight to linger. |
| 这一页已经盖上完成章。 | This page now has its completion stamp. |
| 宠物图鉴 | Pet Compendium |
| 宠物图鉴暂时没有翻开 | The pet compendium is temporarily unavailable |
| 图鉴还是空白页 | The compendium is still blank |
| 已养过 | Met Before |
| 可领养 | Available |
| 未遇见 | Not Met |
| 来客图鉴 | Visitor Compendium |
| 来客图鉴暂时没有翻开 | The Visitor Compendium is temporarily unavailable |
| 来客册还是空白页 | The Visitor Compendium is still blank |
| 等院子里有来客停留，这里会贴上第一张小贴纸。 | Your first Visitor Compendium entry will appear after someone stops by. |
| 尚未收录的来客 | Undiscovered Visitor |
| 常见 | Common |
| 不常见 | Uncommon |
| 稀有 | Rare |
| 传说 | Legendary |
| 常见来客 | Common visitor |
| 不常见来客 | Uncommon visitor |
| 稀有来客 | Rare visitor |
| 传说来客 | Legendary visitor |
| 相遇回忆 | Shared Memory |
| 翻看相遇回忆 | Read This Memory |
| 成长手账 | Growth Journal |
| 成长手账暂时没有翻开 | The growth journal is temporarily unavailable |
| 成长记录暂时没有翻开 | Growth notes are temporarily unavailable |
| 还没有写下成长脚印 | No growth notes yet |
| 每一天的相处，都会悄悄写进属于你们的手账。 | Every day together leaves a quiet note in your shared journal. |
| 成长进度 | Growth |
| 慢慢长大的时刻 | Milestones Along the Way |
| 幼年 A 档 | Stage A · Young |
| 少年 B 档 | Stage B · Growing |
| 成年 C 档 | Stage C · Adult |
| 旅装 D 档 | Stage D · Travel Ready |
| 已达到最高等级 | Maximum level reached |
| 已经准备好背起行囊 | Ready to pack for the journey |
| 翻开成长手账 | Open Growth Journal |
| 相册 | Album |
| 默认手账 | Classic Journal |
| 牛皮纸 | Kraft Paper |
| 蓝格野餐 | Blue Picnic Check |
| 干花押纸 | Pressed Flowers |
| 星图夜航 | Star Chart |
| 旧船票 | Old Ferry Ticket |
| 环球邮差 | World Postie |
| 岁月手账 | Keepsake Journal |
| 明信片 | Postcards |
| 旅行明信片 | Travel Postcards |
| 旅行伙伴 | Traveling Friends |
| 全部伙伴 | All Friends |
| 全部地点 | All Places |
| 这组筛选还没有明信片<br>换一位伙伴或地点看看 | No postcards match this view.<br>Try another friend or place. |
| 这里会收好旅途中寄回的每一封信。 | Every letter from the road will be kept here. |
| 还没有毕业的旅行伙伴<br>把宠物养到毕业，它就会踏上旅途 🎒 | No traveling friends yet.<br>Help a pet grow, and a journey will begin. |
| 也许很快会有新信 | A new letter may arrive soon |
| 这几天也许会有新信 | A new letter may arrive in a few days |
| 会在合适的时候来信 | A letter will arrive when the time is right |
| 它正在慢慢走下一段路 | Wandering toward the next stop |
| 收进相册 | Save to Album |
| 先拆开最新一张，其余已经收进相册 | Open the newest one first. The rest are safe in your album. |
| 领养 | Adopt |
| 领养新伙伴 | Welcome a New Friend |
| 伙伴名字 | Friend's Name |
| 给它取个名字 | Choose a Name |
| 挑一只想要陪伴的小伙伴，给它取个名字吧 | Choose a friend to share the garden with. |
| 去迎接第一位伙伴 | Welcome Your First Friend |
| 正在迎接… | Welcoming… |
| 开启下一段安静的陪伴 | Begin a New Chapter Together |
| 院子在等新朋友 | The garden is waiting for a new friend |
| 这里总会为一位小伙伴，留下一片柔软的草地。 | The garden keeps a welcoming patch of grass for each new friend. |
| 先摸摸头 | Start with a pat |
| 再喂点东西 | Offer a treat |
| 陪它吃点东西、摸摸头，手账就会慢慢写下新的故事。 | Share a snack and a pat. Your journal will soon have a new story. |
| 跳过 | Skip |
| 知道了 | Got It |
| 今日院子 | Today's Garden |
| 今天 | Today |
| 昨天 | Yesterday |
| 今日 | Today |
| 今日已完成 | Done for Today |
| 随心完成 | At Your Own Pace |
| 今天也慢慢来。 | Take today at your own pace. |
| 摸头 | Pet |
| 喂食 | Feed |
| 玩具 | Play |
| 洗澡 | Bathe |
| 摸摸宠物 | Pet your friend |
| 在院子里好好休息 | Rest in the garden |
| 再陪它一会儿 | Stay a While |
| 陪它慢慢长大 | Grow Together |
| 准备启程 · 举行毕业典礼 | Celebrate Graduation |
| 毕业不是告别。它会背起行囊，从旅途中继续给你写信。 | Graduation is not goodbye. Your friend will pack for the journey and keep writing from the road. |
| 第一程，想让它往哪里走？ | Where should the first journey lead? |
| 海滨 | Coast |
| 森林 | Forest |
| 城市 | Town |
| 有海风的地方 | Where the sea breeze wanders |
| 树影深处 | Beneath the forest shade |
| 热闹的街灯 | Toward the glowing streets |
| 送它去旅行  🎒 | Send Them Off |
| 正在收拾行囊… | Packing for the journey… |
| 回到小院 | Back to the Garden |
| 回到院子 | Back to the Garden |
| 毕业了 | Graduated |
| 欢迎回家 | Welcome Home |
| 院子醒来了 | The garden is awake |
| 小院正在醒来 | Waking the garden… |
| 小院暂时没有醒来 | The garden could not open |
| 先歇一下再试，院子里的记录都还在。 | Please try again shortly. Your garden data is safe. |
| 手账 | Journal |
| 打开手账 | Open Journal |
| 关闭手账 | Close Journal |
| 院子记住的事 | Garden Memories |
| 等第一位朋友入住后，这里会贴上新的小标签。 | New notes will appear after your first friend moves in. |
| 今天的来客 | Today's Visitor |
| 来客 | Visitor |
| 院子里来了新朋友 | A New Friend Stopped By |
| 和它打个招呼 | Say Hello |
| 收进来客图鉴 | Save to Visitor Compendium |
| 这段相遇已经收进来客图鉴。 | This meeting is now saved in your Visitor Compendium. |
| 老朋友回访 | An Old Friend Returns |
| 回访 | Returning Friend |
| 远方 | From Afar |
| 离线陪伴 | While You Were Away |
| 日常事件 | Daily Moment |
| 特别事件 | Special Moment |
| 本次收获 | Rewards |
| 记进手账 | Save to Journal |
| 慢慢来，进度已经记在手账里。 | No rush. Your progress is safely noted in the journal. |
| 达成成就 | Achievement Unlocked |
| 支持页面暂时没有打开。<br>请稍后再试。 | Support is temporarily unavailable.<br>Please try again shortly. |
| 自愿支持与装饰回礼。 | Optional support and cosmetic thank-yous. |
| 支持选项 | Ways to Support |
| 支持完全自愿，装饰回礼不会影响成长与收集。 | Support is optional. Cosmetic thank-yous do not affect growth or collecting. |
| 自愿支持 Petopia | Support Petopia |
| 支持完全自愿。所有回礼都只是装饰，不会影响成长、收集或概率。 | Support is optional. Every thank-you is cosmetic and does not affect progression, collecting, or odds. |
| 一份小点心 | A Treat |
| 点心会在院子里保留 24 小时，伙伴也会来尝一口。 | A treat will stay in the garden for 24 hours, and your friend will stop by for a bite. |
| 点心已经放进院子，将保留 24 小时。感谢你的支持。 | The treat is now in the garden and will remain for 24 hours. Thank you for supporting Petopia. |
| 点亮一盏暖灯 | A Warm Lantern |
| 暖灯会在院子里亮 24 小时。 | The lantern will glow in the garden for 24 hours. |
| 暖灯已经点亮，将持续 24 小时。感谢你的支持。 | The lantern is lit for the next 24 hours. Thank you for supporting Petopia. |
| 送来一篮花 | Garden Bouquet |
| 花篮会在院子里展示七天。 | The bouquet will be displayed in the garden for seven days. |
| 花篮已经放进院子，会展示七天。感谢你的支持。 | The bouquet is in the garden and will be displayed for seven days. Thank you for supporting Petopia. |
| 小院守护者 | Garden Keeper |
| 永久点亮守护灯，并解锁纪念徽章和一张特别来信。 | Keep the garden lantern lit permanently and unlock a keepsake badge and special letter. |
| 所有回礼均为装饰性内容，不会改变成长、暖绒、冷却、稀有度或可玩内容。 | All thank-yous are cosmetic. They do not affect growth, Sunfluff, cooldowns, rarity, or playable content. |
| 购买由 App Store 处理。前三项是有固定展示时长的可重复装饰；小院守护者为一次性购买，可恢复。 | Purchases are handled by the App Store. The first three are repeatable decorations with fixed display durations; Garden Keeper is a one-time, restorable purchase. |
| 暂不可用 | Unavailable |
| 可重复 | Repeatable |
| 小院守护者已解锁 | Garden Keeper Unlocked |
| 已解锁 | Unlocked |
| 恢复“小院守护者” | Restore Garden Keeper |
| 正在恢复 | Restoring… |
| 感谢你支持 Petopia。守护灯、纪念徽章和特别来信已经解锁。 | Thank you for supporting Petopia. The garden lantern, keepsake badge, and special letter are now unlocked. |
| 感谢你的支持 | Thank You for Your Support |
| 小院的灯 | The Garden Light |
| 守护灯已点亮 | Garden Lantern Unlocked |
| 小院守护者特别感谢明信片 | A Special Garden Keeper Postcard |
| 守护灯已永久解锁 | Permanent Lantern Unlocked |
| 暖灯正在院子里亮着 | The lantern is glowing in the garden |
| 点心正在院子里 | A treat is in the garden |
| 鲜花正在院子里盛开 | Fresh flowers are blooming in the garden |
| 小院守护者已恢复 | Garden Keeper Restored |
| 完成 | Done |
| 暂时无法写入记录，稍后会自动重试。 | The note could not be saved yet. We will try again automatically. |
| 小院记录已经安全补上。 | The garden note is safely up to date. |
| App Store 暂时没有回应，请稍后再试。 | The App Store did not respond. Please try again soon. |
| 当前设备暂时无法连接 App Store。 | This device cannot reach the App Store right now. |
| 购买没有开始，请稍后再试。 | The purchase did not start. Please try again soon. |
| 购买没有完成，请检查 App Store 后重试。 | The purchase did not finish. Check the App Store and try again. |
| 小院守护者已经恢复。 | Garden Keeper has been restored. |
| 恢复完成，没有找到新的永久权益。 | Restore complete. No new permanent unlock was found. |
| 暂时无法恢复购买，请稍后再试。 | Purchases could not be restored. Please try again soon. |
| 心意已经收到，但回礼暂时没有保存好。请保持网络连接后重试。 | Your support was received, but the thank-you could not be saved. Stay online and try again. |
| 购买已取消，没有产生费用。 | Purchase canceled. You were not charged. |
| 购买没有完成，请稍后再试。 | The purchase did not finish. Please try again soon. |
| App Store 正在确认这次支持，权益不会重复发放。 | The App Store is confirming your support. Your thank-you will only be granted once. |
| 数据 | Data |
| 通知由你决定 | Notifications Are Your Choice |
| 你的院子只留在设备上 | Your Garden Stays on Your Device |
| 第三方服务 | Third-Party Services |
| 删除数据 | Deleting Your Data |
| 查看完整隐私政策 | View Full Privacy Policy |
| 联系支持 | Contact Support |
| 生效日期：2026 年 7 月 27 日 | Effective July 27, 2026 |
| 源代码使用 Apache-2.0；美术与音频为 Petopia 专有素材。 | Source code uses Apache-2.0. Petopia artwork and audio are proprietary. |
| Petopia 专有素材 · 禁止单独转载 | Petopia proprietary assets · Redistribution prohibited |
| App 只在设备上保存回礼类型、交易幂等键和有效期，用于防止重复发放并展示装饰。普通支持不会写入可导出的游戏存档，也不会改变经验、暖绒、冷却或概率。 | Petopia keeps only the thank-you type, transaction key, and expiry on this device so rewards are never granted twice. Regular support never enters your exported save or changes XP, Sunfluff, cooldowns, or odds. |
| Petopia 不要求注册账号，也不会把宠物、明信片、互动记录或设备标识上传到服务器。游戏进度保存在当前设备的应用沙盒中。 | Petopia needs no account and does not upload pets, postcards, interactions, or device identifiers. Progress stays in the app sandbox on this device. |
| 一只刚来到院子的奶油橘色小猫 | A cream-orange kitten, newly arrived in the garden |
| 以后会在邮箱收到它从远方寄来的信 | Letters from the road will arrive in your mailbox |
| 伙伴毕业后会背上行囊，慢慢走过不同地方。先翻开一张旅行样片看看。 | After graduation, your friend packs for the road and wanders from place to place. Here is a glimpse of the journey ahead. |
| 再多陪几位朋友毕业，就能遇见它。 | Help a few more friends graduate to meet this one. |
| 写给小院守护者 | For a Garden Keeper |
| 准备旅行的奶油橘色小猫 | A cream-orange kitten ready for the road |
| 卸载 App 会删除本机游戏数据和固定时长回礼记录。建议卸载或换机前导出存档；重新安装后，可从支持页恢复一次性永久的“小院守护者”。 | Deleting the app removes local game data and fixed-duration thank-yous. Export a save before changing devices. The permanent Garden Keeper unlock can be restored from the support page. |
| 只有在你主动开启后，App 才会请求本地通知权限。提醒仅用于明信片、老朋友回访和纪念日；可随时在设置中分类关闭，也不会使用广告追踪。 | Petopia asks for notification access only after you turn it on. Alerts are limited to postcards, returning friends, and anniversaries. Each category can be disabled anytime, and no ad tracking is used. |
| 存档备份 | Save Backups |
| 它从旅途中回来串门。欢迎它回家，听听这次带回了什么故事。 | A traveling friend has come home for a visit. Welcome them back and hear what the road has brought. |
| 它会一路旅行，常寄明信片回来。<br>院子空出来了，去迎接下一位小伙伴吧。 | Your friend will keep traveling and writing home.<br>The garden is ready to welcome someone new. |
| 它会在小窝附近待到明天。和它打个招呼，就能留下这次相遇。 | This visitor will stay near the shelter until tomorrow. Say hello to remember the meeting. |
| 它已经在路上了<br>第一封信会在合适的时候寄回来 | The journey has begun.<br>The first letter will arrive when the time is right. |
| 它的性格 | Personality |
| 守护灯和纪念徽章已解锁，特别来信会保存在这里。 | The garden lantern and keepsake badge are unlocked, and the special postcard is saved here. |
| 导出存档时，文件由你选择保存或分享的位置。导入会先校验文件完整性和数据流水，校验失败不会覆盖当前院子。 | You choose where exported saves are stored or shared. Imports verify file integrity and game history before replacing anything. |
| 小橘 | Tangerine |
| 小院已安全恢复 | Garden Restored |
| 支持与回礼 | Support and Thank-Yous |
| 已经长大的奶油橘色小猫 | A grown cream-orange cat |
| 当前版本不包含广告、第三方分析、跨 App 追踪、社交登录或联网内容服务。只有在你主动支持小院时，购买和恢复购买会由 Apple App Store 处理；Petopia 不会接触支付卡或 Apple ID。 | Petopia contains no ads, third-party analytics, cross-app tracking, social login, or online content service. If you choose to support the garden, Apple handles purchases and restores; Petopia never receives card details or your Apple ID. |
| 抱抱它 | Give a Hug |
| 支持小院的本地记录 | Local Support Records |
| 明写 | Open Goals |
| 明写成就还在装订中。 | Open goals are still being bound into the book. |
| 未知宠物 | Unknown Pet |
| 海边 | Seaside |
| 海风 | Sea Breeze |
| 海风把草坡吹得软软的。我在灯塔下面坐了很久，替你看了一场很亮的日落。等真正出发以后，也会把沿途的小事一封封寄回来。 | The sea breeze softened the grassy hill. I sat beneath the lighthouse and watched a bright sunset for you. Once the real journey begins, I will send moments from the road home. |
| 清空 | Clear |
| 清除筛选 | Clear Filters |
| 灯塔湾 | Lighthouse Bay |
| 素材 | Assets |
| 纪念日与特殊事件 | Anniversaries & Special Moments |
| 街灯 | City Lights |
| 贴纸册正在慢慢填满 | The sticker book is slowly filling up |
| 还没有可摆放的小物。去商店买到装饰后，就能指定到院子的固定位置。 | No decor is ready to place yet. Find something in the shop, then choose its garden spot. |
| 这是一份 Petopia 院子存档备份。 | This is a Petopia garden save backup. |
| 远处还跟着一位害羞的旅行伙伴。 | A shy traveling friend is following in the distance. |
| 远方也会寄回回忆 | Memories Still Arrive from Afar |
| 选择一个槽位，再点已拥有的小物；同一个小物只会出现在一个位置。 | Choose a spot, then select owned decor. Each item can appear in only one place. |
| 道具加成 | Item Bonus |
| 院子布置 | Garden Layout |
| 院子布置暂时没有打开 | Garden layout is temporarily unavailable |
| 院子来客贴纸册 | Visitor Compendium |
| 预览旅行明信片 | Preview a Travel Postcard |
| 四季花园 5 折券 | Four Seasons Garden · 50% Off |
| 糖果焙房 8 折券 | Candy Bakehouse · 20% Off |
| 任意主题 5 折券 | Any Garden Theme · 50% Off |
| 翻开今天刚写下的新故事 | Read today's new story |
| 旅行者 | Traveler |
| 完整更换院子的季节、光影与景色 | Transforms the garden's season, light, and scenery |
| 可自由摆进院子，也可能吸引特别来客 | Place it anywhere in the garden. A special visitor may notice |
| 更换相册纸张与收藏页的整体气氛 | Changes the paper and mood throughout your album |

## 2. 名称与短语

| 中文 | English |
| --- | --- |
| 橘猫 | Orange Tabby |
| 柴犬 | Shiba Inu |
| 垂耳兔 | Lop Rabbit |
| 仓鼠 | Hamster |
| 乌龟 | Tortoise |
| 鹦鹉 | Parrot |
| 玉米蛇 | Corn Snake |
| 变色龙 | Chameleon |
| 小火龙 | Emberling |
| 独角兔尼可 | Niko the Uni-Rabbit |
| 小幽灵噗噗 | Boo the Little Ghost |
| 星星虫 | Starbug |
| 贪吃 | Foodie |
| 慵懒 | Laid-back |
| 好奇 | Curious |
| 胆小 | Shy |
| 活力 | Spirited |
| 黏人 | Affectionate |
| 高冷 | Aloof |
| 淘气 | Playful |
| 温柔 | Gentle |
| 爱幻想 | Dreamy |
| 慵懒、贪吃、晒太阳 | Laid-back · Foodie · Sunbather |
| 忠诚、傻乐、拆家未遂 | Loyal · Cheerful · Lovably Mischievous |
| 软糯、胆小、爱啃 | Soft · Shy · Loves to Nibble |
| 囤货、腮帮、跑轮 | Collector · Chubby Cheeks · Wheel Runner |
| 慢悠悠、长情、缩壳 | Unhurried · Devoted · Shell-Shy |
| 话痨、学舌、显摆 | Chatty · Mimic · Show-Off |
| 高冷、蜷缩、蜕皮 | Aloof · Coiled · Ever-Changing |
| 慢动作、变色、伪装 | Unhurried · Colorful · Camouflaged |
| 怕生的小暖炉 | A shy, warm-hearted companion |
| 独角兽幼体 | A young unicorn rabbit |
| 害羞的白团子幽灵 | A shy, cloud-soft ghost |
| 会眨眼的草丛 | A twinkling friend from the grass |
| 喂食 | Feed |
| 摸头 | Pet |
| 玩具 | Play |
| 洗澡 | Bathe |
| 第一次目送 | First Farewell |
| 三段相伴 | Three Shared Journeys |
| 五段相伴 | Five Shared Journeys |
| 八种伙伴 | Eight Kinds of Friends |
| 十二页图鉴 | Twelve Compendium Pages |
| 第一次长大 | First Growth Spurt |
| 初见成年 | First Grown-Up Form |
| 六十个早安 | Sixty Good Mornings |
| 图鉴点灯人 | Compendium Lamplighter |
| 三次相遇 | Three Times Together |
| 五色斑斓 | Every Shade of Friendship |
| 童话住进了院子 | A Fairytale Moved In |
| 第一位客人 | First Visitor |
| 好客之家 | Open-Door Garden |
| 六次难得相遇 | Six Rare Encounters |
| 稀客常来 | Rare Guests, Warm Welcome |
| 门庭若市 | A Garden Full of Friends |
| 远方的第一声问候 | First Hello from Afar |
| 集邮爱好者 | Stamp Collector |
| 一抽屉的远方 | A Drawer Full of Faraway Places |
| 邮戳收藏家 | Postmark Collector |
| 盖满整个世界 | Stamps Around the World |
| 八方来信 | Letters from Every Direction |
| 五段旅程 | Five Journeys |
| 十次归来 | Ten Returns |
| 院子永远留着位置 | A Place to Return To |
| 朋友带朋友 | Friends Bring Friends |
| 远方的二十份心意 | Twenty Gifts from Afar |
| 一百次问候 | One Hundred Hellos |
| 熟悉的手心 | A Familiar Touch |
| 饭点守时人 | Always on Time for Meals |
| 千顿饭的交情 | A Thousand Meals Together |
| 泡泡专家 | Bubble Expert |
| 泡泡浴大师 | Bubble Bath Master |
| 两百次游戏 | Two Hundred Games |
| 院子里的游乐场 | The Garden Playground |
| 树荫初成 | First Patch of Shade |
| 满庭花光 | Garden Aglow |
| 传说中的院子 | Garden of Legends |
| 换新装 | A Fresh Look |
| 百变小院 | Garden of Many Moods |
| 八种院景 | Eight Garden Views |
| 四季来信 | Letters Through the Seasons |
| 晴雨雪来信 | Letters in Every Weather |
| 雨天的一顿饭 | A Rainy-Day Meal |
| 七次日安 | Seven Good Mornings |
| 三十次日安 | Thirty Good Mornings |
| 一百个日安 | One Hundred Good Mornings |
| 故事收集者 | Story Collector |
| 一本写满的故事书 | A Storybook Filled to the Last Page |
| 温柔的决定 | A Gentle Choice |
| 守夜人 | Night Watch |
| 听雨的人 | Rain Listener |
| 火焰的朋友 | Friend of the Flame |
| 老朋友 | Old Friend |
| 热闹的一天 | A Lively Day |
| 彩虹留下的脚印 | Rainbow Footprints |
| 午夜的朋友 | Midnight Friend |
| 草丛里的星星 | A Star in the Grass |
| 初雪的脚注 | First Snow Footnote |
| 愿望回音 | Echo of a Wish |
| 什么也没发生的一天 | A Day When Nothing Happened |
| 名字的重量 | The Weight of a Name |
| 等日出的人 | Waiting for Sunrise |
| 雷雨里的怀抱 | Held Through the Storm |
| 听雪的人 | Snow Listener |
| 月亮的常客 | A Regular Under the Moon |
| 传说的收信人 | Keeper of Legendary Letters |
| 深夜公开课 | Midnight Lecture |
| 一路来信 | Letters All Along |
| 同学会 | Reunion |
| 朋友的朋友 | A Friend of a Friend |
| 四季的目送 | Farewells Through Four Seasons |
| 向着朝阳出发 | Setting Out at Sunrise |
| 完整的一天 | A Complete Day |
| 一岁又一岁 | Year After Year |
| 会飞的花 | A Flower in Flight |
| 雨后的白影 | White Shadow After Rain |
| 旧手账的读者 | Reader of Old Journals |
| 夜航信 | A Letter on the Night Wind |
| 口是心非观察员 | Mixed-Signals Expert |
| 有人在星星最亮时来过。 | Someone passed by when the stars were brightest. |
| 雨声也是一种陪伴。 | Rain can be a kind of company. |
| 它记得那盏灯。 | It remembers that light. |
| 有些告别只是换个方式见面。 | Some goodbyes simply become another way to meet. |
| 那天院子里挤满了故事。 | That day, the garden was full of stories. |
| 雨停之后，有人没急着收伞。 | After the rain, someone lingered beneath an open umbrella. |
| 院子最安静的时候，也有人陪你。 | Even at its quietest, the garden keeps you company. |
| 有一盏灯，是为会眨眼的草丛点的。 | One light was left on for the blinking grass. |
| 雪地记得每一串脚印。 | The snow remembers every trail of footprints. |
| 有些话说给流星听，流星会替你带到。 | Tell a wish to a shooting star, and it may carry the words for you. |
| 其实什么都发生了，只是很轻。 | Everything happened that day. It was simply very quiet. |
| 每个名字都被认真念过。 | Every name was spoken with care. |
| 天亮之前的院子，只有一盏灯醒着。 | Before dawn, only one garden light was awake. |
| 雷声很大，但有人的心跳更近。 | The thunder was loud, but a heartbeat was closer. |
| 雪落下来的声音，其实听得见。 | If you listen closely, falling snow has a sound. |
| 圆月夜的院子，会多摆一副茶杯。 | On full-moon nights, the garden sets out one more teacup. |
| 四个传说，都路过了同一个院子。 | Four legends all passed through the same garden. |
| 教授的课，只在会眨眼的草丛边开讲。 | The professor's class begins only beside the blinking grass. |
| 每一封信，都在相册里找到了位置。 | Every letter found its place in the album. |
| 老同学们像是约好了似的。 | Old friends returned as though they had planned it together. |
| 它的朋友，也想来看看你的院子。 | A friend of your friend would like to visit the garden too. |
| 院子送走过四个季节的背影。 | The garden has watched a traveler leave in every season. |
| 有一场告别，选在了日出时分。 | One farewell was saved for sunrise. |
| 那一天，每一种陪伴都刚刚好。 | That day, every kind of care felt just right. |
| 新年的第一声问候，先给了它。 | The year's first hello belonged to your friend. |
| 有一朵会飞的花，找到了最安稳的枝头。 | A flower in flight found the safest branch. |
| 雨停以后，彩虹落下的地方闪过一抹白。 | After the rain, a white shape flashed where the rainbow touched down. |
| 有人常常翻起旧照片。 | Someone often returns to the old photographs. |
| 夜深时，邮箱里也会亮起一盏小灯。 | Late at night, a light can still appear in the mailbox. |
| 它说不在意，却总记得回头。 | They pretend not to care, yet always remember to look back. |
| 猫背礁 | Cat's Back Reef |
| 灯塔海湾 | Lighthouse Bay |
| 贝壳镇 | Seashell Town |
| 退潮沙洲 | Low-Tide Sandbar |
| 海雾码头 | Sea Mist Pier |
| 云顶垭口 | Cloudtop Pass |
| 温泉猴谷 | Monkey Hot Springs |
| 枫火岭 | Maplefire Ridge |
| 雪线木屋 | Snowline Cabin |
| 回声峡谷 | Echo Canyon |
| 电车老街 | Old Tram Street |
| 屋顶水塔城 | Rooftop Water Tower City |
| 深夜面馆街 | Midnight Noodle Street |
| 旧书坊巷 | Old Bookshop Alley |
| 摩天轮码头 | Ferris Wheel Wharf |
| 麦浪邮局 | Wheatfield Post Office |
| 向日葵车站 | Sunflower Station |
| 萤火稻田 | Firefly Rice Fields |
| 苹果坡农场 | Apple Hill Farm |
| 风车塘 | Windmill Pond |
| 蘑菇环林地 | Mushroom Ring Grove |
| 千年橡树邮筒 | Ancient Oak Postbox |
| 松果集市 | Pinecone Market |
| 雾中吊桥 | Misty Rope Bridge |
| 伐木温居 | Woodcutter's Lodge |
| 星空盐湖 | Starlit Salt Lake |
| 驼铃绿洲 | Camel Bell Oasis |
| 彩绘集市 | Painted Bazaar |
| 风蚀石林 | Wind-Carved Stone Forest |
| 热气球营地 | Hot-Air Balloon Camp |
| 极光渔村 | Aurora Fishing Village |
| 浮冰灯塔 | Ice-Floe Lighthouse |
| 蓝洞泉 | Blue Grotto Spring |
| 运河小城 | Canal Town |
| 汽船栈桥 | Steamboat Pier |
| 云端牧场 | Cloudtop Ranch |
| 月亮背面的邮局 | Far-Side Moon Post Office |
| 糖霜火山 | Frosting Volcano |
| 会走路的岛 | Wandering Island |
| 星星修理铺 | Star Repair Shop |
| 麻雀啾啾 | Chirpy the Sparrow |
| 流浪三花猫 | Wandering Calico |
| 蜗牛慢递员 | Slow-Mail Snail |
| 白粉蝶 | Cabbage White |
| 小刺猬球球 | Pip the Hedgehog |
| 鸽子咕咕 | Coo the Pigeon |
| 松鼠栗栗 | Chestnut the Squirrel |
| 乌鸦亮亮 | Shiny the Crow |
| 松鼠 | Squirrel |
| 蝴蝶 | Butterfly |
| 特别 | Special |
| 青蛙呱太 | Ribbit the Frog |
| 萤火虫群 | Firefly Parade |
| 橘色狸猫 | Ginger Tanuki |
| 白鹭先生 | Mr. Egret |
| 狐狸小茜 | Sienna the Fox |
| 猫头鹰教授 | Professor Owl |
| 小鹿 | Little Fawn |
| 雪兔 | Snow Hare |
| 篝火夜的火光 | Campfire Glow |
| 彩虹边的白影 | The Rainbow's White Shadow |
| 深夜白团子 | Midnight Puff |
| 樱花小径 | Cherry Blossom Path |
| 星夜帐篷 | Starlit Tent |
| 海风假日 | Seaside Holiday |
| 秋日果酱 | Autumn Jam |
| 雪屋暖灯 | Snowy Cabin Glow |
| 雨季青苔 | Rainy Moss Garden |
| 糖果焙房 | Candy Bakehouse |
| 四季花园 | Four Seasons Garden |
| 青竹茶亭 | Bamboo Tea Pavilion |
| 月光温室 | Moonlit Greenhouse |
| 麦浪风筝 | Wheatfield Kites |
| 陶瓷小水碗 | Ceramic Water Bowl |
| 夜灯 | Night-Light |
| 暖炉 | Cozy Fireplace |
| 亮闪闪风铃 | Shimmering Wind Chime |
| 野花花坛箱 | Wildflower Planter |
| 蘑菇石凳 | Mushroom Stone Seat |
| 稻草人邮差 | Scarecrow Postie |
| 星星风向标 | Star Weather Vane |
| 木牌门号「1号院」 | Wooden Sign · Garden No. 1 |
| 谷粒袋 ×3 盘 | Grain Pouch ×3 |
| 小鱼干 ×3 盘 | Dried Fish ×3 |
| 坚果罐 ×3 盘 | Nut Jar ×3 |
| 苹果片 ×3 盘 | Apple Slices ×3 |
| 三文鱼小饼干 ×5 | Salmon Biscuits ×5 |
| 彩虹果冻 ×3 | Rainbow Jelly ×3 |
| 蜂蜜燕麦圈 ×5 | Honey Oat Rings ×5 |
| 泡泡浴皂 ×2 | Bubble Bath Soap ×2 |
| 会咕咕叫的毛线球 | Cooing Yarn Ball |
| 发条小鸭 | Wind-Up Duck |
| 藤编逗猫棒 | Wicker Teaser Wand |
| 软木飞盘 | Cork Flying Disc |
| 相册皮肤·牛皮纸 | Album Cover · Kraft Paper |
| 相册皮肤·蓝格纹野餐布 | Album Cover · Blue Picnic Check |
| 相册皮肤·干花押纸 | Album Cover · Pressed Flowers |
| 相册皮肤·星图夜航 | Album Cover · Star Chart |
| 相册与皮肤 | Albums & Covers |
| 乡野 | Countryside |
| 山地 | Highlands |
| 奇幻 | Wonderlands |
| 极地水域 | Polar Waters |
| 沙漠异域 | Desert Lands |
| 夜间 | nighttime |
| 清晨 | morning |
| 雨天 | rainy-day |
| 秋日 | autumn |
| 季节限定 | seasonal |
| 鸟类 | bird |
| 猫与白鹭 | cat and egret |
| 兔与小鹿 | rabbit and deer |

## 3. 动态 UI 规则

这一节保留运行时匹配表达式和英文返回表达式，便于核对变量位置。

| 中文匹配规则 | 英文返回表达式 |
| --- | --- |
| ^(\d+)月(\d+)日$ | '${match[1]}/${match[2]}' |
| ^(\d+)年(\d+)月(\d+)日$ | '${match[2]}/${match[3]}/${match[1]}' |
| ^第 (\d+) 页，共 (\d+) 页$ | 'Page ${match[1]} of ${match[2]}' |
| ^(\d+) / (\d+) 已达成$ | '${match[1]} of ${match[2]} completed' |
| ^(\d+) 张$ | '${match[1]} postcards' |
| ^库存 (\d+)$ | '${match[1]} in stock' |
| ^位置 (\d+)$ | 'Slot ${match[1]}' |
| ^第 (\d+) 种花色$ | 'Color ${match[1]}' |
| ^相伴 (\d+) 天$ | '${match[1]} days together' |
| ^经验 (\d+) / (\d+)$ | 'XP ${match[1]} / ${match[2]}' |
| ^暖绒 \+(\d+)$ | '+${match[1]} Sunfluff' |
| ^经验 \+(\d+)$ | '+${match[1]} XP' |
| ^(喂食\|摸头\|玩具\|洗澡) \+(\d+)$ | '${_term(match[1]!)} +${match[2]}' |
| ^(.+)的旅程$ | "${_term(match[1]!)}'s Journey" |
| ^查看(.+)的详情$ | 'View ${_term(match[1]!)}' |
| ^摸摸(.+)$ | 'Pet ${_term(match[1]!)}' |
| ^到访 (\d+) 次$ | '${match[1]} visits' |
| ^已收录 (\d+) / (\d+)$ | '${match[1]} of ${match[2]} discovered' |
| ^第 (\d+) 站 · (.+)$ | 'Stop ${match[1]} · ${match[2]}' |
| ^(.+)，(.+)后可用$ | '${_term(match[1]!)} · Ready in ${match[2]}' |
| ^(.+)，今天已经满足，仍可继续陪伴$ | '${_term(match[1]!)} · You can still spend time together' |
| ^(.+)，今天更合它心意，增加(\d+)点经验$ | '${_term(match[1]!)} was just right today · +${match[2]} XP' |
| ^(.+)，今日次数已完成$ | '${_term(match[1]!)} · Done for today' |
| ^(.+)，增加(\d+)点经验$ | '${_term(match[1]!)} · +${match[2]} XP' |
| ^(.+)来客，还没留下脚印。$ | 'No ${_term(match[1]!).toLowerCase()} visitor has left a footprint yet.' |
| ^(.+)的旅行风景$ | 'A travel view from ${_term(match[1]!)}' |
| ^(.+) · 第 (\d+) 站$ | '${_term(match[1]!)} · Stop ${match[2]}' |
| ^(.+) 从远方寄来 (\d+) 张明信片$ | '${_term(match[1]!)} sent ${match[2]} postcards from afar' |
| ^(.+) 从远方寄来一张明信片$ | '${_term(match[1]!)} sent a postcard from afar' |
| ^(.+)的来访手账$ | '${_term(match[1]!)} · Visitor Notes' |
| ^(.+)，查看来客回忆$ | 'View memories with ${_term(match[1]!)}' |
| ^(.+)的水彩小景$ | '${_term(match[1]!)} watercolor scene' |
| ^(\d+) 件小物$ | match[1] == '1' ? '1 item' : '${match[1]} items' |
| ^(.+) · 原价 (\d+)$ | '${match[1]} · Usually ${match[2]}' |
| ^(.+) 已收进手账。$ | '${_term(match[1]!)} is now in your journal.' |
| ^(.+) 已收进手账，已使用(.+)。$ | '${_term(match[1]!)} is now in your journal · ${match[2]} applied.' |
| ^(\d+) 暖绒$ | '${match[1]} Sunfluff' |
| ^(.+) 等 (\d+) 项$ | '${_term(match[1]!)} + ${match[2]} items' |
| ^(\d+) / (\d+) 站 · 已寄回 (\d+) 张$ | '${match[1]} of ${match[2]} stops · ${match[3]} postcards' |
| ^(.+)正在享用小点心$ | '${_term(match[1]!)} is enjoying a treat' |
| ^(.+)的旅程，已走过 (\d+) / (\d+) 站，$ | "${_term(match[1]!)}'s journey · ${match[2]} of ${match[3]} stops," |
| ^(.+) 回家看看了$ | '${_term(match[1]!)} came home for a visit' |
| ^(.+)来到院子$ | '${_term(match[1]!)} came to the garden' |
| ^(.+)正在院子里歇脚$ | '${_term(match[1]!)} is resting in the garden' |
| ^(.+)正等你打个招呼$ | '${_term(match[1]!)} is waiting to say hello' |
| ^(.+)睡饱了，又来蹭蹭你$ | '${_term(match[1]!)} woke up and came for a cuddle' |
| ^(.+)睡饱了，蹭蹭你 \+(\d+)$ | '${_term(match[1]!)} woke up and cuddled close · +${match[2]} XP' |
| ^(.+)睡饱后回到你身边$ | '${_term(match[1]!)} woke up and came back to you' |
| ^「(.+)」出发了$ | '${_term(match[1]!)} has set off' |
| ^「(.+)」长大了，是时候去看看外面的世界$ | '${_term(match[1]!)} is all grown up and ready to see the world' |
| ^伙伴经验 \+(\d+)$ | 'Friend XP +${match[1]}' |
| ^和 (.+)$ | 'With ${_term(match[1]!)}' |
| ^回访伙伴 (.+)，点按查看近况$ | '${_term(match[1]!)} is visiting · Tap to catch up' |
| ^它会在院子里歇一歇，接下来约 (\d+) 天都能看见这个熟悉的身影。$ | 'This familiar friend will rest in the garden for about ${match[1]} days.' |
| ^它把一小包暖绒放进你手里：暖绒 \+(\d+)。$ | 'They left a little pouch in your hand · +${match[1]} Sunfluff.' |
| ^已养过 (\d+) / (\d+)    可领养 (\d+)$ | '${match[1]} of ${match[2]} met · ${match[3]} available' |
| ^已寄回 (\d+) 张明信片$ | '${match[1]} postcards sent home' |
| ^已应用「(.+)」。$ | '${_term(match[1]!)} applied.' |
| ^已收下 · (.+)$ | 'Received · ${translate(match[1]!)}' |
| ^已走过 (\d+) / (\d+) 站 · 已寄回 (\d+) 张$ | '${match[1]} of ${match[2]} stops · ${match[3]} postcards' |
| ^(.+)的旅程，已走过 (\d+) / (\d+) 站，已寄回 (\d+) 张明信片$ | "${_term(match[1]!)}'s journey · ${match[2]} of ${match[3]} stops · " '${match[4]} postcards' |
| ^当前等级进度 (\d+)%$ | 'Level progress ${match[1]}%' |
| ^打开(.+)从(.+)寄来的第 (\d+) 张明信片$ | 'Open postcard ${match[3]} from ${_term(match[1]!)} in ${_term(match[2]!)}' |
| ^打开支持小院，(.+)$ | 'Support the Garden · ${translate(match[1]!)}' |
| ^接下来约 (\d+) 天，它会留在院子里。$ | 'They will stay in the garden for about ${match[1]} days.' |
| ^收到(.+)从远方寄来的明信片$ | 'A postcard from ${_term(match[1]!)}' |
| ^新伙伴也和它聊了很久，经验 \+(\d+)。$ | 'Your friend stayed for a long chat · +${match[1]} XP.' |
| ^来客 (.+)，点按查看互动$ | '${_term(match[1]!)} is visiting · Tap to say hello' |
| ^毕业于 (.+)$ | 'Graduated ${match[1]}' |
| ^第一次见面：(\d{4})\.(\d{2})\.(\d{2})$ | 'First met: ${int.parse(match[2]!)}/${int.parse(match[3]!)}/${match[1]!.substring(2)}' |
| ^第一次见面：(.+)$ | 'First met: ${match[1]}' |
| ^第一程：(.+) · (.+)$ | 'First route: ${_term(match[1]!)} · ${match[2]}' |
| ^暖绒 (\d+)，打开商店$ | '${match[1]} Sunfluff · Open shop' |
| ^(.+)来客缘分 \+(\d+)%$ | '+${match[2]}% chance for ${_term(match[1]!).toLowerCase()} visitors' |
| ^下一次使用时，经验提升至 (\d+) 点$ | 'Raises the next care action to ${match[1]} XP' |
| ^永久拥有，玩耍经验提升至 (\d+) 点$ | 'Permanent · Play actions grant ${match[1]} XP' |
| ^达成成就：(.+)$ | 'Achievement unlocked: ${_term(match[1]!)}' |
| ^进度 (\d+) / (\d+)，奖励 (.+)$ | 'Progress ${match[1]} of ${match[2]} · Reward: ${translate(match[3]!)}' |
| ^陪伴经验 \+(\d+)$ | 'Friendship XP +${match[1]}' |
| ^首次 (\d{4})\.(\d{2})\.(\d{2})$ | 'First seen ${int.parse(match[2]!)}/${int.parse(match[3]!)}/${match[1]}' |
| ^首次 (.+)$ | 'First seen ${match[1]}' |
| ^再送 (\d+) 只毕业就能遇见它$ | 'Help ${match[1]} more friends graduate to meet this one' |
| ^摸摸(.+)，听听今天的心情$ | 'Pet ${_term(match[1]!)} and see how today feels' |
| ^(.+)好像想尝点好吃的$ | '${_term(match[1]!)} seems ready for a treat' |
| ^把玩具滚到(.+)身边$ | 'Roll a toy over to ${_term(match[1]!)}' |
| ^给(.+)洗个舒服的澡$ | 'Give ${_term(match[1]!)} a relaxing bath' |
| ^和(.+)打个招呼$ | 'Say hello to ${_term(match[1]!)}' |
| ^三种陪伴都收到了，(.+)今天已经很满足。$ | '${_term(match[1]!)} felt cared for in every way today.' |
| ^(.+)最喜欢这样，默契让这次陪伴更特别。$ | '${_term(match[1]!)} loved that. Your bond made it extra special.' |
| ^这正合(.+)的心意，默契正在一点点累积。$ | 'That was just right for ${_term(match[1]!)}. Your bond is growing.' |
| ^(.+)已经很满足，也喜欢你继续陪在身边。$ | '${_term(match[1]!)} is content and still loves having you nearby.' |
| ^(.+)认真吃完，又抬头看了看你。$ | '${_term(match[1]!)} finished every bite, then looked up at you.' |
| ^(.+)慢慢放松下来，往你的手心靠近了一点。$ | '${_term(match[1]!)} relaxed and leaned a little closer to your hand.' |
| ^(.+)追着玩具跑了一圈，又开心地回到你身边。$ | '${_term(match[1]!)} chased the toy, then happily came back to you.' |
| ^(.+)洗得干干净净，身上还带着温热的水汽。$ | '${_term(match[1]!)} is clean, warm, and freshly bathed.' |
| ^它会先往(.+)走，旅途大约经过 (\d+) 个地方。\n每隔些日子就会寄一张明信片回来 💌\n院子空出来了，去迎接下一位小伙伴吧。$ | 'The first route leads toward ${_term(match[1]!).toLowerCase()}, ' 'with about ${match[2]} stops along the way.\nA postcard will arrive ' 'every few days.\nThe garden is ready to welcome a new friend.' |
| ^(.+?)\s+·\s+(.+)$ | '${translate(match[1]!)} · ${translate(match[2]!)}' |

## 4. 物种与性格

| ID | 中文名 | English | 中文设定 | English Tone |
| --- | --- | --- | --- | --- |
| pet_cat | 橘猫 | Orange Tabby | 慵懒、贪吃、晒太阳 | Laid-back · Foodie · Sunbather |
| pet_shiba | 柴犬 | Shiba Inu | 忠诚、傻乐、拆家未遂 | Loyal · Cheerful · Lovably Mischievous |
| pet_rabbit | 垂耳兔 | Lop Rabbit | 软糯、胆小、爱啃 | Soft · Shy · Loves to Nibble |
| pet_hamster | 仓鼠 | Hamster | 囤货、腮帮、跑轮 | Collector · Chubby Cheeks · Wheel Runner |
| pet_turtle | 乌龟 | Tortoise | 慢悠悠、长情、缩壳 | Unhurried · Devoted · Shell-Shy |
| pet_parrot | 鹦鹉 | Parrot | 话痨、学舌、显摆 | Chatty · Mimic · Show-Off |
| pet_snake | 玉米蛇 | Corn Snake | 高冷、蜷缩、蜕皮 | Aloof · Coiled · Ever-Changing |
| pet_chameleon | 变色龙 | Chameleon | 慢动作、变色、伪装 | Unhurried · Colorful · Camouflaged |
| pet_ember | 小火龙 | Emberling | 怕生的小暖炉 | A shy, warm-hearted companion |
| pet_uni | 独角兔尼可 | Niko the Uni-Rabbit | 独角兽幼体 | A young unicorn rabbit |
| pet_boo | 小幽灵噗噗 | Boo the Little Ghost | 害羞的白团子幽灵 | A shy, cloud-soft ghost |
| pet_starbug | 星星虫 | Starbug | 会眨眼的草丛 | A twinkling friend from the grass |

| ID | 中文 | English |
| --- | --- | --- |
| p_glutton | 贪吃 | Foodie |
| p_lazy | 慵懒 | Laid-back |
| p_curious | 好奇 | Curious |
| p_timid | 胆小 | Shy |
| p_energetic | 活力 | Spirited |
| p_clingy | 黏人 | Affectionate |
| p_aloof | 高冷 | Aloof |
| p_naughty | 淘气 | Playful |
| p_gentle | 温柔 | Gentle |
| p_dreamy | 爱幻想 | Dreamy |

## 5. 地点与来客

| ID | 中文地点 | English |
| --- | --- | --- |
| loc_lighthouse_bay | 灯塔湾 | Lighthouse Bay |
| loc_catback_reef | 猫背礁 | Cat's Back Reef |
| loc_shell_town | 贝壳镇 | Seashell Town |
| loc_tide_flat | 退潮沙洲 | Low-Tide Sandbar |
| loc_seafog_pier | 海雾码头 | Sea Mist Pier |
| loc_cloud_pass | 云顶垭口 | Cloudtop Pass |
| loc_monkey_spring | 温泉猴谷 | Monkey Hot Springs |
| loc_maple_ridge | 枫火岭 | Maplefire Ridge |
| loc_snowline_cabin | 雪线木屋 | Snowline Cabin |
| loc_echo_canyon | 回声峡谷 | Echo Canyon |
| loc_tram_street | 电车老街 | Old Tram Street |
| loc_rooftop_city | 屋顶水塔城 | Rooftop Water Tower City |
| loc_midnight_noodles | 深夜面馆街 | Midnight Noodle Street |
| loc_oldbook_alley | 旧书坊巷 | Old Bookshop Alley |
| loc_ferris_wharf | 摩天轮码头 | Ferris Wheel Wharf |
| loc_wheat_post | 麦浪邮局 | Wheatfield Post Office |
| loc_sunflower_station | 向日葵车站 | Sunflower Station |
| loc_firefly_paddy | 萤火稻田 | Firefly Rice Fields |
| loc_apple_farm | 苹果坡农场 | Apple Hill Farm |
| loc_windmill_pond | 风车塘 | Windmill Pond |
| loc_mushroom_ring | 蘑菇环林地 | Mushroom Ring Grove |
| loc_oak_postbox | 千年橡树邮筒 | Ancient Oak Postbox |
| loc_pinecone_market | 松果集市 | Pinecone Market |
| loc_fog_bridge | 雾中吊桥 | Misty Rope Bridge |
| loc_logger_lodge | 伐木温居 | Woodcutter's Lodge |
| loc_salt_lake | 星空盐湖 | Starlit Salt Lake |
| loc_camel_oasis | 驼铃绿洲 | Camel Bell Oasis |
| loc_painted_bazaar | 彩绘集市 | Painted Bazaar |
| loc_wind_rocks | 风蚀石林 | Wind-Carved Stone Forest |
| loc_balloon_camp | 热气球营地 | Hot-Air Balloon Camp |
| loc_aurora_village | 极光渔村 | Aurora Fishing Village |
| loc_icefloe_lighthouse | 浮冰灯塔 | Ice-Floe Lighthouse |
| loc_blue_spring | 蓝洞泉 | Blue Grotto Spring |
| loc_canal_town | 运河小城 | Canal Town |
| loc_steamboat_pier | 汽船栈桥 | Steamboat Pier |
| loc_cloud_ranch | 云端牧场 | Cloudtop Ranch |
| loc_moon_post | 月亮背面的邮局 | Far-Side Moon Post Office |
| loc_frosting_volcano | 糖霜火山 | Frosting Volcano |
| loc_walking_island | 会走路的岛 | Wandering Island |
| loc_star_repair | 星星修理铺 | Star Repair Shop |

| ID | 中文来客 | English |
| --- | --- | --- |
| visitor_sparrow | 麻雀啾啾 | Chirpy the Sparrow |
| visitor_calico | 流浪三花猫 | Wandering Calico |
| visitor_snail | 蜗牛慢递员 | Slow-Mail Snail |
| visitor_butterfly | 白粉蝶 | Cabbage White |
| visitor_hedgehog | 小刺猬球球 | Pip the Hedgehog |
| visitor_pigeon | 鸽子咕咕 | Coo the Pigeon |
| visitor_squirrel | 松鼠栗栗 | Chestnut the Squirrel |
| visitor_crow | 乌鸦亮亮 | Shiny the Crow |
| visitor_frog | 青蛙呱太 | Ribbit the Frog |
| visitor_firefly | 萤火虫群 | Firefly Parade |
| visitor_tanuki | 橘色狸猫 | Ginger Tanuki |
| visitor_egret | 白鹭先生 | Mr. Egret |
| visitor_fox | 狐狸小茜 | Sienna the Fox |
| visitor_owl | 猫头鹰教授 | Professor Owl |
| visitor_deer | 小鹿 | Little Fawn |
| visitor_snowhare | 雪兔 | Snow Hare |
| visitor_starbug | 星星虫 | Starbug |
| visitor_campfire_light | 篝火夜的火光 | Campfire Glow |
| visitor_rainbow_shade | 彩虹边的白影 | The Rainbow's White Shadow |
| visitor_night_blob | 深夜白团子 | Midnight Puff |

## 6. 商店与成就

| ID | 中文商品 | English |
| --- | --- | --- |
| shop_theme_sakura | 樱花小径 | Cherry Blossom Path |
| shop_theme_starry_camp | 星夜帐篷 | Starlit Tent |
| shop_theme_sea_breeze | 海风假日 | Seaside Holiday |
| shop_theme_autumn_jam | 秋日果酱 | Autumn Jam |
| shop_theme_snow_house | 雪屋暖灯 | Snowy Cabin Glow |
| shop_theme_rain_moss | 雨季青苔 | Rainy Moss Garden |
| shop_theme_candy_bakery | 糖果焙房 | Candy Bakehouse |
| shop_theme_four_seasons | 四季花园 | Four Seasons Garden |
| shop_theme_bamboo_tea | 青竹茶亭 | Bamboo Tea Pavilion |
| shop_theme_moonlight | 月光温室 | Moonlit Greenhouse |
| shop_theme_wheat_kite | 麦浪风筝 | Wheatfield Kites |
| shop_decor_water_bowl | 陶瓷小水碗 | Ceramic Water Bowl |
| shop_decor_night_light | 夜灯 | Night-Light |
| shop_decor_fireplace | 暖炉 | Cozy Fireplace |
| shop_decor_wind_chime | 亮闪闪风铃 | Shimmering Wind Chime |
| shop_decor_flower_box | 野花花坛箱 | Wildflower Planter |
| shop_decor_mushroom_bench | 蘑菇石凳 | Mushroom Stone Seat |
| shop_decor_scarecrow | 稻草人邮差 | Scarecrow Postie |
| shop_decor_wind_vane | 星星风向标 | Star Weather Vane |
| shop_decor_wood_sign | 木牌门号「1号院」 | Wooden Sign · Garden No. 1 |
| shop_food_grain_bag | 谷粒袋 ×3 盘 | Grain Pouch ×3 |
| shop_food_dried_fish | 小鱼干 ×3 盘 | Dried Fish ×3 |
| shop_food_nut_jar | 坚果罐 ×3 盘 | Nut Jar ×3 |
| shop_food_apple_slices | 苹果片 ×3 盘 | Apple Slices ×3 |
| shop_feed_salmon_cookie | 三文鱼小饼干 ×5 | Salmon Biscuits ×5 |
| shop_feed_rainbow_jelly | 彩虹果冻 ×3 | Rainbow Jelly ×3 |
| shop_feed_honey_oat | 蜂蜜燕麦圈 ×5 | Honey Oat Rings ×5 |
| shop_feed_bubble_soap | 泡泡浴皂 ×2 | Bubble Bath Soap ×2 |
| shop_toy_yarn_ball | 会咕咕叫的毛线球 | Cooing Yarn Ball |
| shop_toy_wind_up_duck | 发条小鸭 | Wind-Up Duck |
| shop_toy_cat_wand | 藤编逗猫棒 | Wicker Teaser Wand |
| shop_toy_wooden_disc | 软木飞盘 | Cork Flying Disc |
| shop_album_paper | 相册皮肤·牛皮纸 | Album Cover · Kraft Paper |
| shop_album_picnic | 相册皮肤·蓝格纹野餐布 | Album Cover · Blue Picnic Check |
| shop_album_dried_flower | 相册皮肤·干花押纸 | Album Cover · Pressed Flowers |
| shop_album_star_chart | 相册皮肤·星图夜航 | Album Cover · Star Chart |

| ID | 字段 | 中文 | English |
| --- | --- | --- | --- |
| ach_first_grad | 名称 | 第一次目送 | First Farewell |
| ach_grad_3 | 名称 | 三段相伴 | Three Shared Journeys |
| ach_grad_5 | 名称 | 五段相伴 | Five Shared Journeys |
| ach_grad_8 | 名称 | 八种伙伴 | Eight Kinds of Friends |
| ach_grad_12 | 名称 | 十二页图鉴 | Twelve Compendium Pages |
| ach_evolve_first | 名称 | 第一次长大 | First Growth Spurt |
| ach_lv8_first | 名称 | 初见成年 | First Grown-Up Form |
| ach_daily_care_60 | 名称 | 六十个早安 | Sixty Good Mornings |
| ach_unlock_all_regular | 名称 | 图鉴点灯人 | Compendium Lamplighter |
| ach_species_repeat_3 | 名称 | 三次相遇 | Three Times Together |
| ach_variant_5 | 名称 | 五色斑斓 | Every Shade of Friendship |
| ach_fantasy_1 | 名称 | 童话住进了院子 | A Fairytale Moved In |
| ach_visitor_first | 名称 | 第一位客人 | First Visitor |
| ach_visitor_10 | 名称 | 好客之家 | Open-Door Garden |
| ach_visitor_uncommon_6 | 名称 | 六次难得相遇 | Six Rare Encounters |
| ach_visitor_rare_5 | 名称 | 稀客常来 | Rare Guests, Warm Welcome |
| ach_visitor_all | 名称 | 门庭若市 | A Garden Full of Friends |
| ach_postcard_1 | 名称 | 远方的第一声问候 | First Hello from Afar |
| ach_postcard_30 | 名称 | 集邮爱好者 | Stamp Collector |
| ach_postcard_100 | 名称 | 一抽屉的远方 | A Drawer Full of Faraway Places |
| ach_stamp_20 | 名称 | 邮戳收藏家 | Postmark Collector |
| ach_stamp_40 | 名称 | 盖满整个世界 | Stamps Around the World |
| ach_postcard_8cat | 名称 | 八方来信 | Letters from Every Direction |
| ach_journey_5 | 名称 | 五段旅程 | Five Journeys |
| ach_revisit_10 | 名称 | 十次归来 | Ten Returns |
| ach_revisit_30 | 名称 | 院子永远留着位置 | A Place to Return To |
| ach_companion_3 | 名称 | 朋友带朋友 | Friends Bring Friends |
| ach_revisit_gift_20 | 名称 | 远方的二十份心意 | Twenty Gifts from Afar |
| ach_pat_100 | 名称 | 一百次问候 | One Hundred Hellos |
| ach_pat_500 | 名称 | 熟悉的手心 | A Familiar Touch |
| ach_feed_300 | 名称 | 饭点守时人 | Always on Time for Meals |
| ach_feed_1000 | 名称 | 千顿饭的交情 | A Thousand Meals Together |
| ach_bath_30 | 名称 | 泡泡专家 | Bubble Expert |
| ach_bath_100 | 名称 | 泡泡浴大师 | Bubble Bath Master |
| ach_toy_200 | 名称 | 两百次游戏 | Two Hundred Games |
| ach_toy_500 | 名称 | 院子里的游乐场 | The Garden Playground |
| ach_yard_3 | 名称 | 树荫初成 | First Patch of Shade |
| ach_yard_5 | 名称 | 满庭花光 | Garden Aglow |
| ach_yard_6 | 名称 | 传说中的院子 | Garden of Legends |
| ach_theme_first | 名称 | 换新装 | A Fresh Look |
| ach_theme_4 | 名称 | 百变小院 | Garden of Many Moods |
| ach_theme_8 | 名称 | 八种院景 | Eight Garden Views |
| ach_season_4 | 名称 | 四季来信 | Letters Through the Seasons |
| ach_weather_6 | 名称 | 晴雨雪来信 | Letters in Every Weather |
| ach_rain_care_10 | 名称 | 雨天的一顿饭 | A Rainy-Day Meal |
| ach_login_7 | 名称 | 七次日安 | Seven Good Mornings |
| ach_login_30 | 名称 | 三十次日安 | Thirty Good Mornings |
| ach_login_100 | 名称 | 一百个日安 | One Hundred Good Mornings |
| ach_special_10 | 名称 | 故事收集者 | Story Collector |
| ach_special_20 | 名称 | 一本写满的故事书 | A Storybook Filled to the Last Page |
| ach_choice_10 | 名称 | 温柔的决定 | A Gentle Choice |
| ach_h_midnight | 名称 | 守夜人 | Night Watch |
| ach_h_midnight | 隐藏线索 | 有人在星星最亮时来过。 | Someone passed by when the stars were brightest. |
| ach_h_rain | 名称 | 听雨的人 | Rain Listener |
| ach_h_rain | 隐藏线索 | 雨声也是一种陪伴。 | Rain can be a kind of company. |
| ach_h_ember | 名称 | 火焰的朋友 | Friend of the Flame |
| ach_h_ember | 隐藏线索 | 它记得那盏灯。 | It remembers that light. |
| ach_h_reunion | 名称 | 老朋友 | Old Friend |
| ach_h_reunion | 隐藏线索 | 有些告别只是换个方式见面。 | Some goodbyes simply become another way to meet. |
| ach_h_fullhouse | 名称 | 热闹的一天 | A Lively Day |
| ach_h_fullhouse | 隐藏线索 | 那天院子里挤满了故事。 | That day, the garden was full of stories. |
| ach_h_uni | 名称 | 彩虹留下的脚印 | Rainbow Footprints |
| ach_h_uni | 隐藏线索 | 雨停之后，有人没急着收伞。 | After the rain, someone lingered beneath an open umbrella. |
| ach_h_boo | 名称 | 午夜的朋友 | Midnight Friend |
| ach_h_boo | 隐藏线索 | 院子最安静的时候，也有人陪你。 | Even at its quietest, the garden keeps you company. |
| ach_h_starbug | 名称 | 草丛里的星星 | A Star in the Grass |
| ach_h_starbug | 隐藏线索 | 有一盏灯，是为会眨眼的草丛点的。 | One light was left on for the blinking grass. |
| ach_h_snowprint | 名称 | 初雪的脚注 | First Snow Footnote |
| ach_h_snowprint | 隐藏线索 | 雪地记得每一串脚印。 | The snow remembers every trail of footprints. |
| ach_h_wish | 名称 | 愿望回音 | Echo of a Wish |
| ach_h_wish | 隐藏线索 | 有些话说给流星听，流星会替你带到。 | Tell a wish to a shooting star, and it may carry the words for you. |
| ach_h_quietday | 名称 | 什么也没发生的一天 | A Day When Nothing Happened |
| ach_h_quietday | 隐藏线索 | 其实什么都发生了，只是很轻。 | Everything happened that day. It was simply very quiet. |
| ach_h_allnames | 名称 | 名字的重量 | The Weight of a Name |
| ach_h_allnames | 隐藏线索 | 每个名字都被认真念过。 | Every name was spoken with care. |
| ach_h_dawn | 名称 | 等日出的人 | Waiting for Sunrise |
| ach_h_dawn | 隐藏线索 | 天亮之前的院子，只有一盏灯醒着。 | Before dawn, only one garden light was awake. |
| ach_h_thunder | 名称 | 雷雨里的怀抱 | Held Through the Storm |
| ach_h_thunder | 隐藏线索 | 雷声很大，但有人的心跳更近。 | The thunder was loud, but a heartbeat was closer. |
| ach_h_snowhours | 名称 | 听雪的人 | Snow Listener |
| ach_h_snowhours | 隐藏线索 | 雪落下来的声音，其实听得见。 | If you listen closely, falling snow has a sound. |
| ach_h_fullmoon | 名称 | 月亮的常客 | A Regular Under the Moon |
| ach_h_fullmoon | 隐藏线索 | 圆月夜的院子，会多摆一副茶杯。 | On full-moon nights, the garden sets out one more teacup. |
| ach_h_legend_all | 名称 | 传说的收信人 | Keeper of Legendary Letters |
| ach_h_legend_all | 隐藏线索 | 四个传说，都路过了同一个院子。 | Four legends all passed through the same garden. |
| ach_h_owlnight | 名称 | 深夜公开课 | Midnight Lecture |
| ach_h_owlnight | 隐藏线索 | 教授的课，只在会眨眼的草丛边开讲。 | The professor's class begins only beside the blinking grass. |
| ach_h_perfectjourney | 名称 | 一路来信 | Letters All Along |
| ach_h_perfectjourney | 隐藏线索 | 每一封信，都在相册里找到了位置。 | Every letter found its place in the album. |
| ach_h_classmates | 名称 | 同学会 | Reunion |
| ach_h_classmates | 隐藏线索 | 老同学们像是约好了似的。 | Old friends returned as though they had planned it together. |
| ach_h_plusone | 名称 | 朋友的朋友 | A Friend of a Friend |
| ach_h_plusone | 隐藏线索 | 它的朋友，也想来看看你的院子。 | A friend of your friend would like to visit the garden too. |
| ach_h_fourfarewell | 名称 | 四季的目送 | Farewells Through Four Seasons |
| ach_h_fourfarewell | 隐藏线索 | 院子送走过四个季节的背影。 | The garden has watched a traveler leave in every season. |
| ach_h_dawngrad | 名称 | 向着朝阳出发 | Setting Out at Sunrise |
| ach_h_dawngrad | 隐藏线索 | 有一场告别，选在了日出时分。 | One farewell was saved for sunrise. |
| ach_h_fullcare | 名称 | 完整的一天 | A Complete Day |
| ach_h_fullcare | 隐藏线索 | 那一天，每一种陪伴都刚刚好。 | That day, every kind of care felt just right. |
| ach_h_newyear | 名称 | 一岁又一岁 | Year After Year |
| ach_h_newyear | 隐藏线索 | 新年的第一声问候，先给了它。 | The year's first hello belonged to your friend. |
| ach_h_butterfly | 名称 | 会飞的花 | A Flower in Flight |
| ach_h_butterfly | 隐藏线索 | 有一朵会飞的花，找到了最安稳的枝头。 | A flower in flight found the safest branch. |
| ach_h_rainbowwait | 名称 | 雨后的白影 | White Shadow After Rain |
| ach_h_rainbowwait | 隐藏线索 | 雨停以后，彩虹落下的地方闪过一抹白。 | After the rain, a white shape flashed where the rainbow touched down. |
| ach_h_memory | 名称 | 旧手账的读者 | Reader of Old Journals |
| ach_h_memory | 隐藏线索 | 有人常常翻起旧照片。 | Someone often returns to the old photographs. |
| ach_h_nightmail | 名称 | 夜航信 | A Letter on the Night Wind |
| ach_h_nightmail | 隐藏线索 | 夜深时，邮箱里也会亮起一盏小灯。 | Late at night, a light can still appear in the mailbox. |
| ach_h_tsundere | 名称 | 口是心非观察员 | Mixed-Signals Expert |
| ach_h_tsundere | 隐藏线索 | 它说不在意，却总记得回头。 | They pretend not to care, yet always remember to look back. |

## 7. 事件

| 事件 ID | 字段 | 中文 | English |
| --- | --- | --- | --- |
| ev_d01 | 标题 | 追落叶 | Chasing Leaves |
| ev_d01 | 正文 | 追住了一片打转的落叶，得意地带回来给你看。 | They caught a spinning leaf and carried it over for you to admire. |
| ev_d02 | 标题 | 摊饼 | Sun-Warmed Pancake |
| ev_d02 | 正文 | 在太阳晒热的石板上摊成一张饼。 | They spread out like a pancake on a stone warmed by the sun. |
| ev_d03 | 标题 | 歪头 | Three Head Tilts |
| ev_d03 | 正文 | 对着水碗里的自己歪了三次头。 | They tilted their head at the reflection in the water bowl three times. |
| ev_d04 | 标题 | 藏手套 | The Hidden Glove |
| ev_d04 | 正文 | 把你落在院里的手套拖进了窝，郑重宣布归自己保管。 | They dragged the glove you left outside into their bed and solemnly claimed it for safekeeping. |
| ev_d05 | 标题 | 偷吃 | Quality Inspection |
| ev_d05 | 正文 | 偷吃来客食盘被抓包，装作在检查食物质量。 | Caught nibbling from the visitor dish, they pretended to be checking the food quality. |
| ev_d06 | 标题 | 喷嚏 | Surprise Sneeze |
| ev_d06 | 正文 | 被自己的喷嚏吓得原地弹起。 | Their own sneeze startled them into a quick jump straight upward. |
| ev_d07 | 标题 | 诗朗诵 | Moonlight Recital |
| ev_d07 | 正文 | 深夜对着月亮发出了一声可疑的诗朗诵。 | Late at night, they offered the moon one suspiciously poetic recital. |
| ev_d08 | 标题 | 推花盆 | The Pot Did It |
| ev_d08 | 正文 | 把花盆推倒后一脸「它自己想不开」。 | After tipping over a flowerpot, they looked certain that it had made the decision itself. |
| ev_d09 | 标题 | 让屋檐 | Half the Eaves |
| ev_d09 | 正文 | 给淋雨的白粉蝶让出了半个屋檐。 | They gave half their shelter beneath the eaves to a rain-soaked white butterfly. |
| ev_d10 | 标题 | 守外套 | Coat Watch |
| ev_d10 | 正文 | 远远守着你放下的外套；谁一靠近，它就摆出最严肃的样子。 | They guarded the coat you set down from a distance, putting on their most serious look whenever anyone approached. |
| ev_d11 | 标题 | 埋橡果 | The Forgotten Acorn |
| ev_d11 | 正文 | 挖坑埋下了一颗橡果，并立刻忘了位置。 | They buried an acorn with great care and immediately forgot where it was. |
| ev_d12 | 标题 | 安静时刻 | A Quiet Garden Moment |
| ev_d12 | 正文 | 在院子里找到一块舒服的草地，坐得一动不动，认真听风穿过花叶。 | They found a comfortable patch of grass and sat perfectly still, listening to the wind move through the flowers. |
| ev_d12 | 选择 1 | 拍照留念 | Take a keepsake photo |
| ev_d12 | 结果 1 | 你举起相机，它也坐得端正了些。照片留住了午后的安静。 | You lifted the camera, and they sat straighter for you. The photograph kept the stillness of the afternoon. |
| ev_d12 | 选择 2 | 坐到它旁边 | Sit beside them |
| ev_d12 | 结果 2 | 你在它旁边坐下。谁都没有说话，风把花香慢慢送了过来。 | You sat down beside them. Neither of you said a word while the breeze slowly carried the scent of flowers past. |
| ev_d13 | 标题 | 等日出 | Waiting for Sunrise |
| ev_d13 | 正文 | 清晨守在邮箱顶上等日出，迎着第一缕阳光打了个长长的哈欠。 | At dawn, they waited on top of the mailbox and greeted the first ray of sunlight with a long yawn. |
| ev_d14 | 标题 | 站岗 | Meal-Time Watch |
| ev_d14 | 正文 | 对着饭碗提前一小时开始站岗，眼神里全是「快到点了吧」。 | They began standing watch over the food bowl an hour early, asking with their eyes whether it was time yet. |
| ev_d15 | 标题 | 初雪 | First Snow |
| ev_d15 | 正文 | 第一次碰到雪，它停下来研究了很久这片凉凉的白色。 | The first touch of snow stopped them in place while they studied the cool white mystery. |
| ev_d16 | 标题 | 躲雷 | Listening from the Box |
| ev_d16 | 正文 | 打雷时，它躲进纸箱，只留一道窄缝观察外面的世界。 | Thunder sent them into a cardboard box, leaving only a narrow gap through which to watch the world. |
| ev_d16 | 选择 1 | 坐到纸箱旁边陪它 | Sit beside the box |
| ev_d16 | 结果 1 | 你在纸箱旁坐下。缝隙慢慢宽了一点，你们一起听完了整场雷雨。 | You sat beside the box. The gap slowly widened, and together you listened until the storm had passed. |
| ev_d16 | 选择 2 | 把纸箱盖轻轻掩上一半 | Lower the lid partway |
| ev_d16 | 结果 2 | 你把纸箱盖掩上三分之一，它立刻安心地把自己缩成一团，很快就睡着了。 | You lowered the lid by a third. They curled up at once and soon fell asleep in the soft darkness. |
| ev_d17 | 标题 | 领路 | Snail Escort |
| ev_d17 | 正文 | 绕着院子跑圈给蜗牛慢递员「领路」，蜗牛前进了三厘米，它跑了三十圈。 | They ran circles to guide Slow-Mail Snail. The snail traveled three centimeters; they completed thirty laps. |
| ev_d18 | 标题 | 挪窝 | A View of Your Light |
| ev_d18 | 正文 | 夜里悄悄把窝挪到了能看见你房间灯的位置。 | During the night, they quietly moved their bed to a place where they could see your light. |
| ev_d19 | 标题 | 顺袜子 | The Eighth Pass |
| ev_d19 | 正文 | 假装路过晾衣绳七次，第八次终于顺路把你的袜子拖走了。 | They casually passed the clothesline seven times, then dragged away your sock on the eighth. |
| ev_d20 | 标题 | 闻花 | The First Flower |
| ev_d20 | 正文 | 春天第一朵花开了。它凑近看了很久，回来时脸上沾着一层花粉。 | They studied spring's first flower up close and returned with pollen dusting their face. |
| ev_d21 | 标题 | 看水洼 | Sky in a Puddle |
| ev_d21 | 正文 | 雨天守在屋檐下看水洼里碎掉又拼好的天空，看了一下午。 | They spent the rainy afternoon watching the sky break apart and mend itself in a puddle. |
| ev_d22 | 标题 | 追萤火虫 | Following Fireflies |
| ev_d22 | 正文 | 夏夜追着萤火虫小跑，追到一半停下来，好像突然舍不得抓住它。 | They trotted after summer fireflies, then stopped as if catching one suddenly felt too sad. |
| ev_d23 | 标题 | 流口水 | Polite Drooling |
| ev_d23 | 正文 | 回访小屋那边飘来香味，它端坐在篱笆边，认真等了很久。 | A delicious smell drifted from the reunion cottage, so they sat politely by the fence and waited. |
| ev_d24 | 标题 | 送石头 | A Dewy Stone |
| ev_d24 | 正文 | 清晨带来一颗沾着露水的小石头，放在你常坐的位置。 | At dawn, they brought a dew-bright stone and placed it where you usually sit. |
| ev_d24 | 选择 1 | 郑重收下摆在窗台 | Display the stone on the windowsill |
| ev_d24 | 结果 1 | 你把石头放在窗台最显眼的位置，它假装不在意，眼角却偷偷瞄向那里。 | You placed the stone in the brightest spot on the windowsill. They pretended not to care while secretly checking it. |
| ev_d24 | 选择 2 | 夸夸它并还给它保管 | Praise it and return it for safekeeping |
| ev_d24 | 结果 2 | 你认真夸了这颗石头。它立刻把石头收回去，庄重地放进自己的收藏盒。 | Your thoughtful praise delighted them. They reclaimed the stone and set it solemnly inside their keepsake box. |
| ev_d25 | 标题 | 藏饼干 | The Hidden Biscuit |
| ev_d25 | 正文 | 把最后一块小饼干藏在窝里过夜，早上又被香味领回了藏东西的地方。 | They hid the last biscuit in their bed overnight, then followed its scent straight back in the morning. |
| ev_d26 | 标题 | 守炊烟 | Dinner in the Air |
| ev_d26 | 正文 | 黄昏守在篱笆边，望着炊烟飘来的方向；每听见一次餐具声，就认真抬头一次。 | At dusk, they watched cooking smoke beyond the fence and looked up at every clink of dishes. |
| ev_d27 | 标题 | 吧唧嘴 | Sleepy Chewing |
| ev_d27 | 正文 | 午睡时吧唧嘴，把飘到嘴边的落叶认真咀嚼了两口才醒。 | They sleepily chewed a leaf that drifted to their mouth before realizing they were awake. |
| ev_d28 | 标题 | 冻胡萝卜 | The Frozen Carrot |
| ev_d28 | 正文 | 雪天拖回一根冻得硬邦邦的胡萝卜，坚持认为这是大自然的馈赠。 | They dragged home a carrot frozen solid by the snow and insisted it was a gift from nature. |
| ev_d28 | 选择 1 | 让它抱着慢慢焐化 | Let them warm the carrot slowly |
| ev_d28 | 结果 1 | 你把胡萝卜放在暖布上慢慢回温。它守在旁边，像是守住了整个冬天。 | You set the carrot on a warm cloth to thaw. They stayed beside it as though guarding the whole winter. |
| ev_d28 | 选择 2 | 悄悄换一根新鲜的给它 | Quietly trade it for a fresh one |
| ev_d28 | 结果 2 | 你偷偷换成新鲜胡萝卜，它咬了一口，愣住了，然后开心地吃光了。 | You quietly swapped in a fresh carrot. One surprised bite later, it was joyfully gone. |
| ev_d29 | 标题 | 看图鉴 | Studying the Compendium |
| ev_d29 | 正文 | 趴在图鉴上盯着别的宠物的饭碗插画流口水，纸页洇出一个小圆点。 | They studied the illustrated food bowls in the pet compendium until one tiny drool spot bloomed on the page. |
| ev_d30 | 标题 | 橡果宴席 | The Acorn Banquet |
| ev_d30 | 正文 | 在落叶堆里翻出一颗去年秋天的橡果，郑重其事地办了一场一人份宴席。 | They found an acorn left from last autumn and held a very formal banquet for one. |
| ev_d31 | 标题 | 滚太阳地 | Rolling into Sunshine |
| ev_d31 | 正文 | 从窝一点点挪到阳光晒得到的地方，整个过程从容得没有一丝多余动作。 | They inched from bed to the sunlit patch with impressive calm and not one wasted movement. |
| ev_d32 | 标题 | 长哈欠 | The Afternoon Yawn |
| ev_d32 | 正文 | 打了一个横跨整个下午的哈欠——你数了，前后共续了七次。 | One yawn stretched across the whole afternoon. You counted seven continuations. |
| ev_d33 | 标题 | 雾天不起床 | Too Foggy to Rise |
| ev_d33 | 正文 | 雾天看了一眼院子，宣布今日能见度不足、不宜起床，转身回窝。 | One look at the fog convinced them that visibility was too poor for getting up, so back to bed they went. |
| ev_d34 | 标题 | 避暑时刻 | Keeping Cool |
| ev_d34 | 正文 | 夏日午后，它在最阴凉的石板上舒展开来，只剩下缓慢而安稳的呼吸。 | On a summer afternoon, they stretched across the coolest stone until only slow, easy breathing remained. |
| ev_d35 | 标题 | 续觉 | Another Nap |
| ev_d35 | 正文 | 睡到一半，它从窝里探出来看了一眼世界，觉得一切都好，又回去续了一觉。 | Halfway through a nap, they peered out from bed, decided everything was fine, and settled in for another round. |
| ev_d36 | 标题 | 赖在身边 | Staying Close |
| ev_d36 | 正文 | 黄昏时，它贴着你脚边还不愿回窝，每隔一会儿就换个更舒服的位置。 | At dusk, they stayed close to your feet, shifting every so often into an even more comfortable spot. |
| ev_d36 | 选择 1 | 送它回窝，掖好被子 | See them back to bed and tuck them in |
| ev_d36 | 结果 1 | 你把它送回窝，仔细掖好小被子。没过多久，它的呼吸就变得平稳。 | You carried them back and tucked in the blanket. Their breathing soon settled into an easy rhythm. |
| ev_d36 | 选择 2 | 陪它坐到天全黑 | Stay together until the sky is dark |
| ev_d36 | 结果 2 | 你陪它一直坐到星星都出来，它靠在你脚边，满足地回窝了。 | You stayed until the stars appeared. Leaning against your feet, they finally felt ready for bed. |
| ev_d37 | 标题 | 护送蚂蚁 | Ant Procession Escort |
| ev_d37 | 正文 | 发现了蚂蚁搬家的队伍，全程跟随护送三米，比蚂蚁还紧张。 | They discovered a line of ants moving house and anxiously escorted the procession for three whole meters. |
| ev_d38 | 标题 | 雾中巡逻 | Patrol in the Mist |
| ev_d38 | 正文 | 雾天在院子里小心翼翼地巡逻，试图找出把世界藏起来的那个家伙。 | They patrolled the misty garden with great care, looking for whoever had hidden the world. |
| ev_d39 | 标题 | 玩风铃 | A Wind Chime Lesson |
| ev_d39 | 正文 | 围着新挂的风铃研究了半天，最后学会用最轻的一碰把它点响。 | After a long study of the new wind chime, they learned how to ring it with the lightest touch. |
| ev_d40 | 标题 | 恐龙蛋 | A Dinosaur Egg, Perhaps |
| ev_d40 | 正文 | 在花坛边找到一颗滚圆的石头，立刻带来请你鉴定是不是恐龙蛋。 | They found a perfectly round stone by the flower bed and rushed over to ask whether it might be a dinosaur egg. |
| ev_d40 | 选择 1 | 郑重收进「宝物架」 | Give it a place on the treasure shelf |
| ev_d40 | 结果 1 | 你把它放在专门的「宝物架」上，它满意地点点头，以后每天都去参观。 | You made a special place for it on the treasure shelf. They now inspect the exhibit every day. |
| ev_d40 | 选择 2 | 陪它回去继续考古 | Return to the dig as an archaeology team |
| ev_d40 | 结果 2 | 你陪它回到挖洞的地方，它又埋头苦挖起来，你在一旁当助手。 | You returned to the dig together. They worked earnestly while you served as the official assistant. |
| ev_d41 | 标题 | 等花开 | Waiting for the Bloom |
| ev_d41 | 正文 | 蹲在一枚花苞前守了一整个上午，就为了看它「啵」地开的那一下。 | They waited beside one flower bud all morning just to see the moment it opened. |
| ev_d42 | 标题 | 与影子和解 | Peace with a Shadow |
| ev_d42 | 正文 | 被自己的影子跟了一路，黄昏时终于鼓起勇气猛回头——影子也停下了，双方就此和解。 | After being followed by their own shadow all day, they finally spun around at dusk. The shadow stopped too, and peace was declared. |
| ev_d43 | 标题 | 回头确认 | Checking You Are There |
| ev_d43 | 正文 | 雾天寸步不离你的视线，每走三步回头确认一次你还在。 | In the fog, they stayed within sight and looked back every three steps to make sure you were still there. |
| ev_d44 | 标题 | 扮演石头 | Playing a Stone |
| ev_d44 | 正文 | 来客到了，它当场一动不动地扮演石头；半小时后悄悄看过去，发现对方还在耐心等它。 | When a visitor arrived, they became perfectly still and played the part of a stone. Half an hour later, they glanced over and found the visitor still waiting patiently. |
| ev_d45 | 标题 | 质问晾衣绳 | Questioning the Clothesline |
| ev_d45 | 正文 | 夜里被风吹动的晾衣绳吓了一跳，第二天白天专门跑去「质问」了它。 | After the windblown clothesline startled them at night, they returned in daylight to question it properly. |
| ev_d46 | 标题 | 绕路走 | The Crunchy Detour |
| ev_d46 | 正文 | 第一次踩碎落叶被那声「咔嚓」吓到，原地静止十秒后决定绕路走。 | The first crunch of a dry leaf froze them for ten seconds. They chose a quieter route after that. |
| ev_d47 | 标题 | 钻外套 | Shelter in Your Coat |
| ev_d47 | 正文 | 打雷前它先一步钻进了你昨天穿过的外套——那里面有让它安心的味道。 | Before the thunder began, they slipped into the coat you wore yesterday, where the familiar scent felt safe. |
| ev_d48 | 标题 | 冲刺 | Morning Sprint |
| ev_d48 | 正文 | 清晨绕院子冲刺十圈，露水在它身后甩出一条闪闪发亮的小路。 | They sprinted ten morning laps around the garden, flinging a sparkling trail of dew behind them. |
| ev_d49 | 标题 | 雪地艺术 | Snowfield Art |
| ev_d49 | 正文 | 在雪地里犁出一道歪歪扭扭的深沟，回头欣赏自己的大地艺术。 | They plowed one crooked trench across the snow, then turned around to admire their landscape art. |
| ev_d50 | 标题 | 绕圈余韵 | After the Laps |
| ev_d50 | 正文 | 在院子里快跑了好几圈，停下以后，眼前的花还像在绕着自己转。 | They ran several fast laps around the garden. After stopping, the flowers still seemed to circle around them. |
| ev_d51 | 标题 | 追草绳 | Chasing the Grass Cord |
| ev_d51 | 正文 | 和一条被风吹动的草绳进行了一场势均力敌的追逐战，最终握手言和。 | They fought an evenly matched battle with a windblown grass cord, then called a truce. |
| ev_d52 | 标题 | 追彩虹雾 | Chasing Rainbow Mist |
| ev_d52 | 正文 | 夏日黄昏追着洒水时的小彩虹雾跑，浑身湿透了还舍不得停。 | They chased the rainbow in the summer spray until they were completely soaked. |
| ev_d52 | 选择 1 | 拿毛巾在终点等它 | Wait at the finish line with a towel |
| ev_d52 | 结果 1 | 你拿着毛巾在终点等它。它冲到你身边，把一路带来的水珠全抖在了草地上。 | You waited with a towel. They rushed over and scattered a trail of rainbow droplets across the grass. |
| ev_d52 | 选择 2 | 挽起袖子加入战斗 | Roll up your sleeves and join the chase |
| ev_d52 | 结果 2 | 你也加入追逐。等彩虹散去，你们都湿透了，却谁也没有急着停下。 | You joined the chase. By the time the rainbow faded, both of you were soaked and neither was ready to stop. |
| ev_d53 | 标题 | 靠在膝边 | By Your Knee |
| ev_d53 | 正文 | 你在院里坐了多久，它就在你膝边安静靠了多久。 | For as long as you sat in the garden, they rested quietly beside your knee. |
| ev_d54 | 标题 | 认脚步声 | Your Footsteps |
| ev_d54 | 正文 | 学会了辨认你的脚步声，隔着篱笆就开始原地转圈。 | They learned the sound of your footsteps and began spinning before you even reached the gate. |
| ev_d55 | 标题 | 收纽扣 | The Treasure Button |
| ev_d55 | 正文 | 把你掉的一颗纽扣当作珍藏，收进了窝的最深处。 | They found one of your lost buttons, declared it treasure, and hid it in the deepest part of their bed. |
| ev_d56 | 标题 | 窗上雾气 | A Window of Mist |
| ev_d56 | 正文 | 雨天隔着窗户看你，在玻璃上留下一小团雾气，又一点点擦开。 | On a rainy day, they left a patch of mist on the window, then slowly cleared it to see you again. |
| ev_d57 | 标题 | 靠近取暖 | Warming Up |
| ev_d57 | 正文 | 冬天的早晨靠近你摊开的手心取暖，全程望着前方，装作只是路过。 | On a winter morning, they moved close to your open palm for warmth while looking straight ahead as if merely passing by. |
| ev_d58 | 标题 | 背对晒太阳 | Sunbathing, Listening |
| ev_d58 | 正文 | 全程背对着你晒太阳，却始终留意着你这边的动静。 | They sunbathed with their back to you while keeping careful track of every sound from your direction. |
| ev_d59 | 标题 | 蹭画像 | Polishing the Portrait |
| ev_d59 | 正文 | 你夸了图鉴里别的宠物一句，它当晚把自己那页的画像蹭得锃亮。 | After you praised another pet in the compendium, they polished their own portrait until it shone. |
| ev_d60 | 标题 | 整理收藏 | A Neat Collection |
| ev_d60 | 正文 | 把今天找到的细长草叶摆得笔直平整，仿佛在宣布：本次整理，无可挑剔。 | They arranged the day's finest grass blades in one perfectly straight line, presenting an unquestionably flawless result. |
| ev_d61 | 标题 | 看月亮 | Watching the Moon |
| ev_d61 | 正文 | 夜里独自蹲在高处看月亮，你出来时它假装只是在数瓦片。 | They sat alone in a high place watching the moon, then pretended to be counting roof tiles when you came outside. |
| ev_d61 | 选择 1 | 搬个小凳陪它一起看 | Bring a stool and watch the moon together |
| ev_d61 | 结果 1 | 你搬来小凳坐在它旁边。它悄悄靠近了一些，目光始终没有离开月亮。 | You sat beside them on a small stool. They edged closer without taking their eyes from the moon. |
| ev_d61 | 选择 2 | 给它留一盏灯先回屋 | Leave a lantern and head inside |
| ev_d61 | 结果 2 | 你给它留了一盏小灯回屋。身后传来一声很轻的动静，像是在道晚安。 | You left a warm lantern and went inside. A quiet sound behind you felt exactly like good night. |
| ev_d62 | 标题 | 检查座位 | Inspecting the Visitor's Seat |
| ev_d62 | 正文 | 来客走后，它仔细检查了对方坐过的地方，沉默片刻，像是得出了自己的结论。 | After the visitor left, they carefully inspected the place where the guest had sat, then paused as if reaching a private conclusion. |
| ev_d63 | 标题 | 藏拖鞋 | The Slipper Hunt |
| ev_d63 | 正文 | 把你的两只拖鞋分别藏在院子两端，蹲在中间欣赏你找鞋。 | They hid your slippers at opposite ends of the garden and sat in the middle to enjoy the search. |
| ev_d64 | 标题 | 开食盆 | The Open Food Bowl |
| ev_d64 | 正文 | 学会了开食盆的盖子——案发现场只留下三颗没来得及吃完的粮。 | They learned to open the food-bowl lid. Only three uneaten pieces remained at the scene. |
| ev_d65 | 标题 | 借帽子 | Borrowed Hat |
| ev_d65 | 正文 | 借走来客的小帽子，在院子里展示了半圈才郑重归还。 | They borrowed a visitor's hat, showed it off around half the garden, then returned it with ceremony. |
| ev_d66 | 标题 | 踩水洼 | Puddle Stomping |
| ev_d66 | 正文 | 雨后专挑水洼踩，溅了自己一身泥点，还显得十分得意。 | They chose every puddle after the rain and seemed thoroughly pleased with every new splash of mud. |
| ev_d66 | 选择 1 | 立刻押去洗澡 | Straight to the bath |
| ev_d66 | 结果 1 | 你把它押进浴室，它一边洗澡一边踩水，玩得比在外面还开心。 | You carried them to the bath, where they discovered that splashing indoors was every bit as enjoyable. |
| ev_d66 | 选择 2 | 让它先得意一会儿再说 | Let them enjoy one more triumphant lap |
| ev_d66 | 结果 2 | 你由着它得意，它踩得更起劲了，泥点子飞得满院子都是。 | You let the victory lap continue. The puddles grew smaller while the muddy spots spread across the garden. |
| ev_d67 | 标题 | 学咳嗽 | The Perfect Cough |
| ev_d67 | 正文 | 学你咳嗽学得惟妙惟肖，成功骗你回头三次，第四次它自己先笑场。 | They copied your cough perfectly enough to fool you three times, then laughed first on the fourth. |
| ev_d68 | 标题 | 扑落叶 | Helping with the Leaves |
| ev_d68 | 正文 | 把你堆好的落叶小山一头扑散，然后开始「帮忙」重堆——越帮越大片。 | They dove through the leaf pile you had just made, then offered to help rebuild it into something much wider. |
| ev_d69 | 标题 | 让食物 | The Biggest Piece |
| ev_d69 | 正文 | 把食盆里最大的一块推到来客面前，自己默默吃小的。 | They nudged the largest piece in the bowl toward the visitor and quietly ate a smaller one. |
| ev_d70 | 标题 | 焐地面 | A Warm Place to Land |
| ev_d70 | 正文 | 雪天用自己的体温焐化了一小块地面，留给路过的麻雀落脚。 | In the snow, their warmth cleared one small patch of ground for a passing sparrow to land. |
| ev_d71 | 标题 | 看蜘蛛 | Watching the Web Mend |
| ev_d71 | 正文 | 发现蜘蛛网被雨打坏了，蹲在旁边看蜘蛛修补了一下午，全程没有打扰。 | They found a rain-damaged spiderweb and watched its owner repair it all afternoon without interrupting. |
| ev_d72 | 标题 | 盖叶子 | A Favorite Leaf for You |
| ev_d72 | 正文 | 你打了个喷嚏，它立刻跑来，把自己最喜欢的那片叶子盖在你手背上。 | When you sneezed, they hurried over and placed their favorite leaf on the back of your hand. |
| ev_d73 | 标题 | 护送甲虫 | Beetle Escort |
| ev_d73 | 正文 | 黄昏把误闯进院子的小甲虫一路护送到篱笆外，全程放慢了动作。 | At dusk, they slowed every movement while escorting a lost beetle all the way beyond the fence. |
| ev_d74 | 标题 | 雾里神秘 | A Long Way into the Mist |
| ev_d74 | 正文 | 雾天坐进雾最浓的地方待了很久，回来后神秘兮兮的，好像去过很远的地方。 | They sat for a long time in the deepest fog and returned looking as though they had traveled very far. |
| ev_d75 | 标题 | 追晚霞 | Chasing the Sunset Colors |
| ev_d75 | 正文 | 在晚霞下换了好几个位置，想找到一个和天空颜色最接近的角落。 | They tried several spots beneath the sunset, searching for the corner whose colors looked most like the sky. |
| ev_d76 | 标题 | 吹蒲公英 | Dandelion Fleet |
| ev_d76 | 正文 | 攒了一小撮蒲公英绒毛，夜里对着它们轻轻吹气，像在放飞什么看不见的船队。 | They gathered a small tuft of dandelion down and blew it into the night like a fleet of invisible boats. |
| ev_d77 | 标题 | 接雪花 | One Snowflake |
| ev_d77 | 正文 | 雪夜仰头望着一片雪花从很高的地方落下，直到它停在自己面前。 | On a snowy night, they watched one flake fall from high above until it came to rest before them. |
| ev_d78 | 标题 | 守月亮 | Guardian of the Bowl Moon |
| ev_d78 | 正文 | 郑重宣布水碗里住着另一个月亮，并自愿承担每晚的看守任务。 | They announced that another moon lived in the water bowl and volunteered for nightly guard duty. |
| ev_d78 | 选择 1 | 陪它值一次夜班 | Share one night watch |
| ev_d78 | 结果 1 | 你陪它一起守夜，它认真地看着水碗里的月亮倒影，时不时点头确认安全。 | You shared the watch. They studied the moon in the bowl and nodded every so often to confirm all was well. |
| ev_d78 | 选择 2 | 在水碗旁给它放一盏小灯 | Place a small lantern beside the bowl |
| ev_d78 | 结果 2 | 你在水碗旁放了一盏小灯，它满意地趴下，假装那是一盏月亮守护灯。 | You placed a lantern beside the bowl. They settled down, satisfied that the moon now had a proper guard light. |
| ev_d79 | 标题 | 打喷嚏 | Dewdrop Sneeze |
| ev_d79 | 正文 | 晨光里打了个大喷嚏，把身旁一颗露珠震上了天。 | A bright morning sneeze launched a nearby dewdrop into the air. |
| ev_d80 | 标题 | 午醒核对 | Everything Is Here |
| ev_d80 | 正文 | 午睡醒来发现光线变了，绕着院子认真核对了一遍：草在、盆在、你也在，满意。 | After a nap changed the angle of the light, they checked the whole garden: grass, bowl, and you. Everything was where it belonged. |
| ev_d81 | 标题 | 推东西 | One by One |
| ev_d81 | 正文 | 把窗台上的小物件一件一件推下去，每推一件就回头确认一次你的表情。 | They pushed each small object from the windowsill one at a time, looking back after every piece to check your expression. |
| ev_d81 | 选择 1 | 没收所有小物件 | Move every small object out of reach |
| ev_d81 | 结果 1 | 你把东西都收走了，它眼巴巴看着，但很快找到了新的乐趣。 | You moved everything away. They stared for a moment, then discovered an entirely new harmless game. |
| ev_d81 | 选择 2 | 面无表情陪它推完最后一件 | Keep a straight face for the final piece |
| ev_d81 | 结果 2 | 你全程面瘫看着它推完，它心满意足，蹦蹦跳跳地去别处探险了。 | You watched the final piece fall without changing expression. Thoroughly satisfied, they bounded off to explore. |
| ev_d82 | 标题 | 摆鞋 | Ready by the Door |
| ev_d82 | 正文 | 把你的鞋一只只拖到门口，摆成快带我出去玩的整齐阵型。 | They dragged your shoes to the door and arranged them into a very clear request to go outside together. |
| ev_d83 | 标题 | 秘密通道 | The Secret Tunnel |
| ev_d83 | 正文 | 在花坛边挖了一条秘密通道，出口离入口只有二十厘米，它对此十分满意。 | They dug a secret tunnel beside the flower bed. Its exit was twenty centimeters from the entrance, and they were delighted. |
| ev_d84 | 标题 | 忘了要去哪 | Where Was I Going? |
| ev_d84 | 正文 | 把随身的小袋塞满之后，它忘了原本要去哪，站在原地思考了很久。 | After filling their travel pouch, they forgot where they had been going and stood thinking for a very long time. |
| ev_d85 | 标题 | 今天动够了 | Enough for Today |
| ev_d85 | 正文 | 一下午从容地挪动了一米。看它的神情，今天的运动量显然已经足够。 | They moved one meter over the course of the afternoon. From their expression, that was clearly enough exercise for one day. |
| ev_d86 | 标题 | 叫醒自己 | A Self Wake-Up Call |
| ev_d86 | 正文 | 学会了你喊它名字的语气，现在每天早上负责把自己叫醒。 | They learned the exact way you call their name and now use it to wake themselves every morning. |
| ev_d87 | 标题 | 新模样 | A Fresh Look |
| ev_d87 | 正文 | 认真整理完自己之后，它先去照了照水碗，确认今天的新模样很合适。 | After carefully tidying up, they checked their reflection in the water bowl and approved of the day's fresh look. |
| ev_d87 | 选择 1 | 夸它今天精神 | Tell them they look wonderful today |
| ev_d87 | 结果 1 | 你认真夸了它今天的模样。它得意地转了几圈，恰好让阳光照到每个角度。 | You praised the way they looked today. They turned proudly until the sunlight found every angle. |
| ev_d87 | 选择 2 | 替它拍一张照片 | Take a photo of the new look |
| ev_d87 | 结果 2 | 你替它拍下一张照片。以后每次翻到这里，都能看见这一天的光。 | You took a photograph. Whenever the journal opens to this page, the light from that day is there again. |
| ev_d88 | 标题 | 配毛衣 | Finding the Right Light |
| ev_d88 | 正文 | 在你毛衣旁边换了好几个位置，最后选中了最衬自己的那一处光。 | They tried several spots beside your sweater and finally found the light that suited them best. |
| ev_d89 | 标题 | 深呼吸 | A Grass-Scented Breath |
| ev_d89 | 正文 | 雷雨过后满院子都是青草味。它做了一个深呼吸，整个身形都舒展开来。 | After the storm, they took one enormous breath of wet grass and seemed to relax from end to end. |
| ev_d90 | 标题 | 追白气 | Chasing Winter Breath |
| ev_d90 | 正文 | 冬天的清晨呼出一小团白气，愣了一下，追着自己的白气跑了两步。 | Their first white breath of the winter morning surprised them, so they chased it for two steps. |
| ev_d91 | 标题 | 纸伞点头 | Raindrop Rhythm |
| ev_d91 | 正文 | 春雨天蹲在纸伞下，跟着雨点在伞面上敲出的节拍轻轻点头。 | They sat beneath a paper umbrella and nodded gently to the rhythm of spring rain. |
| ev_d92 | 标题 | 变金色 | Turning Gold |
| ev_d92 | 正文 | 秋天的黄昏卧在落叶堆顶上，随着夕阳一起慢慢变成金色。 | They lay on top of the autumn leaves and slowly turned gold with the setting sun. |
| ev_d93 | 标题 | 等眨眼 | Waiting for Another Blink |
| ev_d93 | 正文 | 夜里守着草丛里那个「上次会眨眼」的位置，好像在等谁再眨一次。 | They waited beside the place in the grass that blinked last time, hoping someone might blink again. |
| ev_d94 | 标题 | 树枝展会 | The Branch Exhibition |
| ev_d94 | 正文 | 捡回一根格外满意的树枝，带着它在院子里巡回展出了一整天。 | They found an exceptionally fine branch and took it around the garden on exhibition all day. |
| ev_d94 | 选择 1 | 给树枝设一个正式「展位」 | Build the branch a proper display stand |
| ev_d94 | 结果 1 | 你给它做了一个小展台，它每天都会去「检查」树枝有没有少一根。 | You built a display stand. They now inspect the branch each day to make sure the collection is complete. |
| ev_d94 | 选择 2 | 装作第一次看见，认真赞叹 | Admire it as though seeing it for the first time |
| ev_d94 | 结果 2 | 你的赞叹让它更有精神，树枝展览立刻又绕院子进行了一圈。 | Your admiration made them even prouder. The exhibition immediately continued for another lap of the garden. |
| ev_d95 | 标题 | 水彩 | Unfinished Watercolor |
| ev_d95 | 正文 | 从雾里慢慢走出来的样子，像一幅还没画完的水彩。 | The way they emerged slowly from the mist looked like a watercolor still waiting for its final brushstroke. |
| ev_d96 | 标题 | 看云 | Cloud-Watching Debate |
| ev_d96 | 正文 | 午后和来客排排坐看云。一朵云飘过，气氛突然认真起来。 | They sat beside a visitor watching clouds. One particular cloud drifted by, and the discussion suddenly became very serious. |
| ev_d96 | 选择 1 | 同意那朵云像饭团 | Agree that the cloud looks like a rice ball |
| ev_d96 | 结果 1 | 你表示赞同，它开心地比划起来，好像真的一样。 | You agreed that it looked like a rice ball. They happily explained every fluffy detail. |
| ev_d96 | 选择 2 | 坚持那朵云像枕头 | Insist that the cloud looks like a pillow |
| ev_d96 | 结果 2 | 你坚持说像枕头，它白了你一眼，但很快就接受了新设定。 | You insisted on pillow. They gave you one doubtful look, then accepted the new interpretation. |
| ev_d97 | 标题 | 检查你 | Checking on You |
| ev_d97 | 正文 | 雷声刚过，它跑来把你从头到尾检查了一遍，确认无事后假装只是散步路过。 | As soon as the thunder passed, they checked you from head to toe, then pretended they had only wandered by. |
| ev_d98 | 标题 | 换季痕迹 | A Trace of the Season |
| ev_d98 | 正文 | 换季整理小窝时，你找到一片它留下的旧痕迹。它看了很久，好像也认出了从前的自己。 | While tidying the bed for the new season, you found a small trace of an earlier day. They studied it as though recognizing their past self. |
| ev_d99 | 标题 | 灯光旁 | By the Window Light |
| ev_d99 | 正文 | 晚上迟迟没有睡意，它在你房间的灯光旁待了一会儿，等灯暗下才回窝。 | Sleep was slow to arrive, so they stayed near your window for a while and returned to bed when the light dimmed. |
| ev_d99 | 选择 1 | 早点熄灯「骗」它去睡 | Turn the light off early for bedtime |
| ev_d99 | 结果 1 | 你提前熄了灯，它轻手轻脚回窝，走到门口还回头看了你一眼。 | You turned the light off early. They headed toward bed, pausing at the doorway for one last look at you. |
| ev_d99 | 选择 2 | 开着灯陪它多待一会儿 | Leave the light on and stay a while longer |
| ev_d99 | 结果 2 | 你开着灯陪它。它在你身边安静待了一会儿，才满足地回窝。 | You stayed with the light on. After a quiet moment beside you, they returned to bed content. |
| ev_d100 | 标题 | 最好的一天 | A Good Kind of Day |
| ev_d100 | 正文 | 今天什么也没发生。它安静伏着，看了很久的天。你知道，这也是很好的一天。 | Nothing happened today. They rested quietly and watched the sky for a long time. It was a good kind of day. |
| ev_s01 | 标题 | 初雪 | First Snow |
| ev_s01 | 正文 | 它第一次站进雪里，试探着走了几步，身后留下一串花瓣似的印记。 | Your friend stepped into snow for the first time and left a trail of blossom-shaped marks behind. |
| ev_s02 | 标题 | 生日会 | Adoption Anniversary |
| ev_s02 | 正文 | 相识纪念日这天，来客们陆续进门，每位都带来一件从路上挑的小礼物。 | On the anniversary of your first meeting, garden visitors arrived one by one, each carrying a gift chosen along the way. |
| ev_s03 | 标题 | 流星雨之夜 | Night of Falling Stars |
| ev_s03 | 正文 | 流星划过院子上空时，它闭上眼许了一个愿，睁眼后只肯告诉你一半。 | As falling stars crossed the garden sky, your friend closed their eyes and made a wish, then shared only half of it with you. |
| ev_s04 | 标题 | 半日探险 | A Half-Day Adventure |
| ev_s04 | 正文 | 它从篱笆边发现一条新路，傍晚才回来，还带着一朵院子里从未见过的花。 | Your friend discovered a new path by the fence and returned at dusk with a flower no one in the garden had seen before. |
| ev_s05 | 标题 | 雷雨夜守护 | Shelter from the Storm |
| ev_s05 | 正文 | 雷声靠近时，它挨到你身边。等雨声渐远，它也慢慢放松下来。 | When thunder rolled across the garden, your friend moved close. As the rain softened, they relaxed beside you. |
| ev_s06 | 标题 | 启程预演 | A Departure Rehearsal |
| ev_s06 | 正文 | 它试背起旅行包，朝院门走了两步，又回头认真看了看你。 | With departure drawing closer, your friend tried on a backpack, took two steps toward the gate, and looked back at you. |
| ev_s07 | 标题 | 老朋友的信物 | An Old Friend's Keepsake |
| ev_s07 | 正文 | 一位回来探望的老朋友临走前留下围巾。今天，它一直把围巾带在身边。 | Before leaving, an old friend placed a scarf in the garden. Your current companion kept it close all day. |
| ev_s08 | 标题 | 篝火晚会 | Campfire Gathering |
| ev_s08 | 正文 | 冬夜的暖炉旁，火光深处忽然多了一道橘红的影子，跳了几步，又消失在下一次闪烁里。 | Beside the winter fire, a small shape seemed to dance inside the glow, then vanished between two flickers. |
| ev_s09 | 标题 | 彩虹尽头 | The Rainbow's End |
| ev_s09 | 正文 | 雨停后，彩虹落在院子一角。那里掠过一道白影，它望了很久也没有移开视线。 | After the rain, the rainbow touched one corner of the garden. A white shape passed through the light, and your friend kept watching long after it vanished. |
| ev_s10 | 标题 | 满月茶会 | Full-Moon Tea |
| ev_s10 | 正文 | 满月升起后，来客比往常更多。大家在院子里安静坐了一会儿，像一场不必开口的茶会。 | On the full moon, visitors filled the garden for a quiet tea gathering where no one needed to speak. |
| ev_s11 | 标题 | 第一场花信 | The First Flower Breeze |
| ev_s11 | 正文 | 春天第一阵暖风把花瓣吹满院子。它在花瓣雨里转了好几圈，最后停在最亮的一束阳光里。 | The first warm spring breeze filled the garden with petals. Your friend turned through the shower before stopping in the brightest patch of sunlight. |
| ev_s12 | 标题 | 萤火大巡游 | The Great Firefly Parade |
| ev_s12 | 正文 | 夏夜里，成群的萤火虫经过院子，点亮了整段篱笆。它安静看了很久，直到最后一点光飞远。 | Hundreds of fireflies passed through on a summer night, lighting the fence while your friend watched from below. |
| ev_s13 | 标题 | 晒秋日 | Autumn Treasures in the Sun |
| ev_s13 | 正文 | 秋日晴朗，它学着你的样子把收藏一件件搬到阳光下：纽扣、树枝、半颗橡果，每样都摆得很认真。 | In the clear autumn sun, your friend carefully laid out every treasure from the bed: a button, a branch, half an acorn, each warmed in turn. |
| ev_s14 | 标题 | 冬至长夜 | The Longest Winter Night |
| ev_s14 | 正文 | 在一年最长的夜里，你们并肩坐在暖光下。它睡着前，又往你手边靠近了一点。 | On the longest winter night, you sat together in the lantern glow. Before falling asleep, your friend moved closer to your hand. |
| ev_s15 | 标题 | 又长大一些 | Growing Into Themselves |
| ev_s15 | 正文 | 换上新模样后，它在水碗里端详了自己好一会儿，再回头看你。你一眼就认出了它。 | After growing into a new form, your friend studied the reflection in the water bowl, then looked back to make sure you still knew them. Of course you did. |
| ev_s16 | 标题 | 成年礼 | Coming of Age |
| ev_s16 | 正文 | 长大后的第一个晚上，它把幼年时最爱的旧玩具带到你面前，像是在和那段时光认真道谢。 | On the first evening in their grown-up form, your friend brought over a beloved childhood toy as if offering that time a quiet thank-you. |
| ev_s17 | 标题 | 草丛眨眼之夜 | The Night the Grass Blinked |
| ev_s17 | 正文 | 晴朗无月的夜里，夜灯边的草丛真的眨了一下眼。它屏住呼吸，你们谁都没有出声。 | On a clear moonless night, the grass beside the lantern truly blinked. You and your friend held your breath together. |
| ev_s18 | 标题 | 午夜的白团子 | The Midnight White Puff |
| ev_s18 | 正文 | 夜深以后，一团圆滚滚的白影从院墙上飘过，在它上方停了一秒，像是打了个害羞的招呼。 | Late at night, a round white shape floated over the wall and paused above your friend for one shy second. |
| ev_s19 | 标题 | 雾中邮差 | The Post Carrier in the Fog |
| ev_s19 | 正文 | 大雾天，邮箱里多了一张没有署名的旧明信片，画着一座谁也没见过的院子。它对着画面看了很久。 | A nameless old postcard appeared in the mailbox during heavy fog. It showed a garden no one had ever seen, and your friend studied it for a long time. |
| ev_s20 | 标题 | 同行半月 | Two Weeks Together |
| ev_s20 | 正文 | 相识满两周这天，成长手账翻回第一页。最初略显笨拙的模样，和今天的它并排留在纸上。 | After fourteen days together, the growth journal turned back to its first page and set your friend's earliest clumsy steps beside who they are today. |

## 8. 明信片模板

> 当前实现按性格与模板尾号选择 30 个英文母版，所以不同地点类别的中文模板
> 可能对应同一条英文母版。下表展示 App 的真实映射结果。

| 模板 ID | 性格 | 类别 | 中文 | English Runtime Template |
| --- | --- | --- | --- | --- |
| tpl_gl_hb_01 | p_glutton | 海滨 | {ownerName}！{location}的海很大很蓝，但重点是——{encounter}！{incident}。海风都是咸鲜味的，我打算再住三天（为了吃）。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_hb_02 | p_glutton | 海滨 | 今天在{location}退潮的滩涂上找了一下午。{incident}。捡到的东西能不能吃，我还在研究；先闻闻，再问问当地人。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_hb_03 | p_glutton | 海滨 | {location}报告：{encounter}。我假装矜持了三秒，第四秒盘子空了。{weather}的海边什么都好，就是饭点之间隔得太久。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_sd_01 | p_glutton | 山地 | 爬山好累。到了{location}山顶，又遇上一件事：{encounter}。值了。后来还有个新发现：{incident}。下山的路我打算滚下去，省力气留着咀嚼。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_sd_02 | p_glutton | 山地 | {ownerName}，{location}的雾里全是炊烟味！我循着味走了一路，{incident}。风景？哦，风景也在，在饭的旁边。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_sd_03 | p_glutton | 山地 | 山里的{season}，{encounter}。人家说山货要留着过冬，我说我的冬天从今天下午开始。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_cs_01 | p_glutton | 城市 | {ownerName}！{location}半条街都是香味，我循着香气逛完了全程。{encounter}，{incident}。这里的月亮看起来也很好吃。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_cs_02 | p_glutton | 城市 | {location}的{timeOfDay}排队最长的那家店，现在也认识我了。{encounter}。我没有蹭吃，我是在做美食巡查；只是排队的样子有点诚实。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_cs_03 | p_glutton | 城市 | 城市生存报告：{incident}。结论：{location}遍地是饭，走三步一个惊喜，走五步一个饱嗝。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_xy_01 | p_glutton | 乡野 | {location}的{season}是可以直接吃的！{encounter}，我负责品控，尝了一遍又一遍又一遍。{incident}。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_xy_02 | p_glutton | 乡野 | {ownerName}你不懂，田里刚摘的东西和店里的不一样，是会冒甜气的。{incident}。今天我的肚子是{location}形状的。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_xy_03 | p_glutton | 乡野 | 到了{location}，又遇上一件事：{encounter}。这里的招待像命运一样躲不开。饱到打嗝的时候我想起你了——你煮饭也很香。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_sl_01 | p_glutton | 森林 | 重大发现：{location}的{encounter}！{incident}。附：本次收获已按重要程度装进背包，最好吃的那份另有安排。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_sl_02 | p_glutton | 森林 | 森林里到处是零食，只是它们管自己叫『果实』。{incident}。{ownerName}，等我回去教你认哪种叶子是薄荷味的。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_sl_03 | p_glutton | 森林 | {location}的{timeOfDay}，{encounter}。我们交换了食物，也交换了各自藏粮的秘密（我编了一半，饭可以分，老窝不能露）。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_sm_01 | p_glutton | 沙漠异域 | {location}热得像烤箱——说到烤箱，{encounter}！{incident}。沙漠一点也不荒，荒的是我上一顿到这一顿之间。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_sm_02 | p_glutton | 沙漠异域 | 异域美食清单第 {seq} 页：{incident}。有些名字我念不出来，但我的胃都记住了。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_sm_03 | p_glutton | 沙漠异域 | 在{location}学会一件事：想尝一口，要先坐好，再把眼神放认真。{encounter}。这里的人管这叫礼仪，我管这叫战术。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_jd_01 | p_glutton | 极地水域 | {location}冷是冷，但冷的地方饭都是热的！{encounter}，{incident}。我守着热碗取暖，差点连最后一滴汤也没放过。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_jd_02 | p_glutton | 极地水域 | 冰面下有鱼在游。我看了整整一个{timeOfDay}。{incident}。这不是发呆，这是点菜。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_jd_03 | p_glutton | 极地水域 | 到了{location}，又遇上一件事：{encounter}。极光很好看，锅里的也很好看。后来极光真的亮起来了……行吧，并列第一。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_gl_qh_01 | p_glutton | 奇幻 | {ownerName}，{location}的云居然是甜的！不是比喻。{encounter}，{incident}。我打包了一朵，如果收到的信纸有点黏，别问。——{petName} | {ownerName}! I made it to {location}. {encounter}. {incident}. I am taking my responsibility to taste the whole journey very seriously. Love, {petName} |
| tpl_gl_qh_02 | p_glutton | 奇幻 | 这里的规矩很奇怪：{incident}。但只要最后能落到吃的上，什么规矩我都学得飞快。——{petName} | Food report from {location}: {encounter}. {incident}. The scenery is lovely, especially when viewed from beside a full plate. Love, {petName} |
| tpl_gl_qh_03 | p_glutton | 奇幻 | {location}的{encounter}。我问它什么味道，它说是梦的味道。我尝了，像{season}早晨你厨房里的香气。想你，也想那间厨房。——{petName} | I reached {location} under {weather}. {encounter}. {incident}. I miss you, and I also miss your kitchen. Both feelings are sincere. Love, {petName} |
| tpl_lz_hb_01 | p_lazy | 海滨 | 到{location}了。沙子晒得刚刚好。{incident}。本来想去看看海的……海自己会过来，涨潮的时候。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_hb_02 | p_lazy | 海滨 | {encounter}。我点了点头，继续躺。{timeOfDay}的{location}，风是软的。写到这里困了。先这样。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_hb_03 | p_lazy | 海滨 | 今日行程：从礁石左边挪到礁石右边。{incident}。累了。明天计划：挪回去。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_sd_01 | p_lazy | 山地 | {location}的温泉。泡了。很好。{encounter}，我们谁也没说话，这样最好。……信写短一点，省下的力气用来泡。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_sd_02 | p_lazy | 山地 | 山很高。我没爬。{incident}。山顶的风景据说很好，据躺在我旁边的那位说的。转述完毕。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_sd_03 | p_lazy | 山地 | {season}的{location}，云从山这边慢慢挪到那边。我跟它比了一下午谁挪得慢。我赢了。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_cs_01 | p_lazy | 城市 | {location}好吵，但有一个屋顶晒得到太阳还没人。{incident}。城市最好的地方就是……这个屋顶。其他没去。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_cs_02 | p_lazy | 城市 | 今天遇上一件事：{encounter}。电车开得太快，我跟了三步，决定留在原地等下一班。{timeOfDay}的叮叮声像催眠铃。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_cs_03 | p_lazy | 城市 | 这条街的猫都懂：太阳到哪儿，就搬到哪儿。{incident}。……算了，先睡一觉再写。（醒了。没什么补充。）——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_xy_01 | p_lazy | 乡野 | {location}的草垛是世界上最伟大的发明。{incident}。今天的我 = 草垛的一部分。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_xy_02 | p_lazy | 乡野 | {encounter}。对方很热情，我认真点头回应了两下，这已经是我今天全部的运动量。{season}的午后好长，长得可以睡两觉。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_xy_03 | p_lazy | 乡野 | 风车转，我不转。麦浪跑，我不跑。{incident}。{ownerName}，乡下真适合我，什么都自己在动，不用我动。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_sl_01 | p_lazy | 森林 | {location}的树荫是拼起来的，我睡的这块最厚。{incident}。醒来时苔藓在我背上安了家……那就住下吧，都别动了。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_sl_02 | p_lazy | 森林 | {encounter}。它邀请我去看林子深处的瀑布。我说好，改天。森林嘛，跑不掉的。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_sl_03 | p_lazy | 森林 | {timeOfDay}，松针落在我头上三根。我数完就睡了。梦里{incident}……也可能不是梦。懒得分了。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_sm_01 | p_lazy | 沙漠异域 | 走了很久。也可能没有很久，我的很久和别人的不太一样。{location}的{timeOfDay}，{incident}。停下来不动的时候，好事会自己落下来。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_sm_02 | p_lazy | 沙漠异域 | 沙漠的白天不宜行动。晚上也不宜。{encounter}，是对方走过来的，特此说明。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_sm_03 | p_lazy | 沙漠异域 | {location}的沙丘每天换形状，挺勤快的。我替它把『躺着』这部分演好。{incident}。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_jd_01 | p_lazy | 极地水域 | {location}很冷，冷得适合裹成一团。{incident}。裹好了。不出去了。极光要看就从窗户看。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_jd_02 | p_lazy | 极地水域 | 今天遇上一件事：{encounter}。这里把冬眠当成正经事，我表示深深的敬意和加入的意愿。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_jd_03 | p_lazy | 极地水域 | 浮冰漂到哪儿算哪儿。我在冰上，冰在水上，谁也不用力。{incident}。{ownerName}，这叫顺其自然。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_lz_qh_01 | p_lazy | 奇幻 | {location}的床是云做的，我陷进去就没打算出来。{incident}。这封信是托路过的风寄的，因为我没起来。——{petName} | Made it to {location}. Found a comfortable spot. {encounter}. {incident}. I will investigate the rest after one more nap. Love, {petName} |
| tpl_lz_qh_02 | p_lazy | 奇幻 | {encounter}。它说这里一天有三十个小时。多出来的六个我全睡了，一点没浪费。——{petName} | {location} moves at exactly the right speed: slowly. {encounter}. {incident}. Writing this used up today's remaining energy. Love, {petName} |
| tpl_lz_qh_03 | p_lazy | 奇幻 | 会走路的地面自己在走，我站着不动就等于在旅行。{incident}。……这是我发明的最伟大的旅行方式。——{petName} | The {timeOfDay} at {location} is hushed and calm. {encounter}. {incident}. I am traveling very efficiently by letting the view come to me. Love, {petName} |
| tpl_cu_hb_01 | p_curious | 海滨 | 你知道吗？{location}的灯塔楼梯有一百零八级！我数完以后，又走了一遍核对。{incident}。下一个问题：浪为什么不累？——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_hb_02 | p_curious | 海滨 | {encounter}！我问了它十七个问题，它回答了三个，剩下的我打算自己试。第一项实验：{incident}。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_hb_03 | p_curious | 海滨 | 退潮以后地上全是小洞，每个洞里住着谁？我挨个看了 {location} 的一整片滩！{weather}的时候它们会换房子吗？——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_sd_01 | p_curious | 山地 | {location}的回声会学我说话！我喊了二十遍验证，它总比我少半个字。为什么？{incident}。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_sd_02 | p_curious | 山地 | 今天遇上一件事：{encounter}。我顺着一条只有本地动物知道的小路往前走，又有了新发现：{incident}！地图上没有，所以我准备替这条路起个名字。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_sd_03 | p_curious | 山地 | 山上的云摸起来是什么手感？答案：{timeOfDay}的云偏凉，有点像你冰箱的门。别问我怎么知道的，我已经站进雾里试过了。——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_cs_01 | p_curious | 城市 | {location}情报：这条街有 9 个井盖，每个花纹都不一样！路上还遇上一件事：{encounter}。我把它郑重记成第十条情报。后来又有个新发现：{incident}。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_cs_02 | p_curious | 城市 | 电车为什么叮叮两声不是三声？我蹲在{location}站台听了一个{timeOfDay}。{incident}。结论：还需要再蹲一天。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_cs_03 | p_curious | 城市 | {encounter}！原来{location}的旧书里会夹着别人忘掉的东西：车票、花瓣，还有一根不知道谁留下的细线。我仔细比对过，不是我的。——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_xy_01 | p_curious | 乡野 | 重大疑问：{location}的向日葵晚上把头转回去，是几点转的？我守到{timeOfDay}……睡着了。{incident}。明天继续蹲！——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_xy_02 | p_curious | 乡野 | {encounter}。我学会了分辨三种麦子的味道、两种风的方向，还有一种空气快要变潮的气味！过了一会儿，风果然转了方向。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_xy_03 | p_curious | 乡野 | 稻田里的萤火虫为什么排队？我跟着队伍走了半里地，{incident}。队伍的尽头是什么我还不知道——所以这封信先寄，我先去了！——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_sl_01 | p_curious | 森林 | {location}的蘑菇圈到底是谁画的圆？我量过了，误差还不到一片落叶那么宽！路上还遇上一件事：{encounter}。问了一圈，还是没有答案。后来又有个新发现：{incident}。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_sl_02 | p_curious | 森林 | 你知道吗？橡树邮筒里的信是松鼠送的，走树枝比走地面快三倍！我跟着一封信走完全程，已经验证过了。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_sl_03 | p_curious | 森林 | {timeOfDay}的雾里，吊桥对面若隐若现。过去要 128 步（我数的），回来只要 126 步？{incident}。森林在跟我玩什么？——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_sm_01 | p_curious | 沙漠异域 | {location}的沙子白天烫、晚上凉，我每小时踩一次做记录！路上还遇上一件事：{encounter}。后来有人借我一顶小帽子当实验器材，其实是怕我晒着。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_sm_02 | p_curious | 沙漠异域 | 盐湖的星星是天上的还是水里的？我轻轻碰了碰水面，星星碎开，又慢慢拼了回来。{incident}。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_sm_03 | p_curious | 沙漠异域 | 集市上有一百种没见过的东西，我闻了六十三种，被摊主笑着赶走四次。{incident}。明天从第六十四种继续。——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_jd_01 | p_curious | 极地水域 | 极光会响吗？我在{location}的雪地里认真听了一个{timeOfDay}！{incident}。答案先保密，留到下一张明信片里；其实是我还没听清。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_jd_02 | p_curious | 极地水域 | {encounter}！它教我认冰的年纪：蓝得越深越老。我现在看什么都想问一句『你几岁』。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_jd_03 | p_curious | 极地水域 | 蓝洞的水为什么这么蓝？我盯着看了很久，差点靠得太近；放心，离边缘还差一点。{incident}。——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_cu_qh_01 | p_curious | 奇幻 | {location}的邮局盖章是月光做的墨！我问邮差墨水用完了怎么办，他说等下一次满月。那阴天呢？他不理我了。{incident}。——{petName} | {ownerName}, I have questions about {location}! {encounter}. {incident}. I wrote everything down, except the seventeen things I still need to test. Love, {petName} |
| tpl_cu_qh_02 | p_curious | 奇幻 | 会走路的岛今天往南走了三步！我在岛上量了步长，又遇上一件事：{encounter}。听说岛在找一位老朋友。是谁？去哪儿找？我准备继续查下去。——{petName} | Field notes, page {seq}: {location}. {encounter}. {incident}. One answer led to three new questions, so the expedition is going perfectly. Love, {petName} |
| tpl_cu_qh_03 | p_curious | 奇幻 | 云端牧场的羊毛就是云，剪下来还会落一阵小雨！我在现场看了三场。{incident}。新问题：这场雨算羊的，还是天的？——{petName} | Did you know {location} looks completely different at {timeOfDay}? {encounter}. {incident}. I am staying until I understand at least one mystery. Love, {petName} |
| tpl_ti_hb_01 | p_timid | 海滨 | {location}的浪好大声，我第一天躲在浮木后面看。第三天……我终于往海水里探近了一点！只有一秒，但我做到了。{incident}。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_hb_02 | p_timid | 海滨 | {encounter}的时候，我差点把信纸吃了。后来发现它是来送吃的的……{ownerName}，下次我一定先深呼吸再跑。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_hb_03 | p_timid | 海滨 | 海雾把{location}藏起来的时候我有点慌，抱住了一根系船柱。{incident}。雾散了，我还抱着。它现在是我朋友了。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_sd_01 | p_timid | 山地 | {location}的吊桥会晃！我在桥头坐了半个{timeOfDay}做心理建设。路上还遇上一件事：{encounter}。最后我沿着桥上的旧脚印走了过去。桥那边的风景我还没顾上看，下次补。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_sd_02 | p_timid | 山地 | 山风敲窗的时候我钻进了木屋的柴堆。{incident}。风停以后我探出头，山谷里安安静静的，好像刚才凶我的不是它。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_sd_03 | p_timid | 山地 | {season}的{location}，猴子们很热情，热情得我把自己缩成了一颗球。后来最小的那只猴也缩成球陪我。……我们现在是两颗球朋友。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_cs_01 | p_timid | 城市 | {location}的喇叭声、脚步声、电车声，我全躲在纸箱里听完了。{encounter}，把我连箱子一起搬到了安静的巷子口。人类……有一些是好的。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_cs_02 | p_timid | 城市 | 我在{location}学会了看红绿灯！虽然是躲在一位老奶奶的购物袋后面过的马路。{incident}。明天试试只躲半个身子。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_cs_03 | p_timid | 城市 | 深夜的{location}其实很温柔，没什么人，{incident}。原来我不是怕城市，是怕人多。这个发现让我很开心，现在写信已经不再发抖了。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_xy_01 | p_timid | 乡野 | {location}的大鹅朝我走来的时候，我差点把信纸吃了。{encounter}——原来它是想给我带路！乡下的大家凶起来都是热心肠。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_xy_02 | p_timid | 乡野 | 稻草人先生站在田里一动不动，我观察了他三天，确认他人很好（不动的都是好人）。{incident}。我现在敢在他脚边睡觉了。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_xy_03 | p_timid | 乡野 | {timeOfDay}的{location}起风了，麦浪哗啦哗啦追着我跑……跑到邮局我才想明白：风又抓不到我。它只是想一起玩。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_sl_01 | p_timid | 森林 | {location}的{timeOfDay}会发光，我先躲在树后看了好久。后来{encounter}，我居然是被需要的那一个。……我好像没那么怕黑了。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_sl_02 | p_timid | 森林 | 树影一动我就一激灵，一激灵就跳，一跳就踩响一地落叶，把自己吓得更结实了。{incident}。……森林笑话大全第一页：我。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_sl_03 | p_timid | 森林 | 雾里的吊桥我不敢过。路上还遇上一件事：{encounter}。后来我闭上眼数二十步，数到十九步就到了。多出来的那一步，是我自己迈的。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_sm_01 | p_timid | 沙漠异域 | {location}晚上会有很远的驼铃声，我躲进帐篷数铃铛：一颗、两颗……数着数着就不怕了，铃铛像是黑夜别在身上的扣子。{incident}。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_sm_02 | p_timid | 沙漠异域 | 集市好挤，我贴着墙根走完了全程。{encounter}，蹲下来跟我说话的时候，我居然没有后退。写下来纪念一下：没有后退！——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_sm_03 | p_timid | 沙漠异域 | 风蚀石林的石头像巨兽，{timeOfDay}的影子好长。我靠着行李，在两块『兽爪』中间睡了一夜。早上才发现，是它们替我挡了一夜风。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_jd_01 | p_timid | 极地水域 | {location}的冰会咯吱响，每响一声我就停一步。路上还遇上一件事：{encounter}。后来我沿着岸边的旧脚印慢慢走，一步都没错。到岸的时候，连风都安静下来了。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_jd_02 | p_timid | 极地水域 | 极光第一次亮起来的时候我钻进了雪堆（对不起，本能）。第二次我露出了眼睛。第三次……{incident}。{ownerName}，天上真的会开花。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_jd_03 | p_timid | 极地水域 | 汽船鸣笛把我震进了缆绳堆。船长说抱歉抱歉，然后给了我一条小毯子。{incident}。现在毯子在我身上，我在毯子里，世界很安全。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_ti_qh_01 | p_timid | 奇幻 | {location}会自己走路！地面一动，我就伏低身子，抓紧旁边的草。岛上的居民告诉我：这样也很好，岛知道有人在认真和它同行。{incident}。——{petName} | I arrived safely at {location}. {encounter}. {incident}. I was nervous at first, but I took one more step than yesterday. Love, {petName} |
| tpl_ti_qh_02 | p_timid | 奇幻 | 月亮背面好安静，安静得我有点怕。{encounter}，说这里的安静是攒起来给想家的旅客用的。……那我用一点。{ownerName}，晚安。——{petName} | {location} felt very big when I arrived. {encounter}. {incident}. Someone was kind, and the road became less frightening. Love, {petName} |
| tpl_ti_qh_03 | p_timid | 奇幻 | 糖霜火山『噗』地喷了一朵奶油云，我原地弹了三尺高，落下来的时候接了满头糖霜。{incident}。……好吧，是甜的，原谅它了。——{petName} | The {weather} at {location} startled me, so I thought of the garden and took a slow breath. {encounter}. {incident}. Everything is fine here. Love, {petName} |
| tpl_en_hb_01 | p_energetic | 海滨 | {location}的沙滩我来回跑了八趟！浪追我，我追浪，最后平局。{incident}。这封信的字有点歪，因为我是一边跑一边写的。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_hb_02 | p_energetic | 海滨 | {encounter}。比赛结果：它游泳第一，我刨沙第一，我们都是第一！{ownerName}，下次你来当颁奖嘉宾。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_hb_03 | p_energetic | 海滨 | 今天绕灯塔跑圈，管理员都探头问是不是出了什么事。没有，我只是很开心！{incident}。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_sd_01 | p_energetic | 山地 | 我跑上{location}了！{incident}。风一直在响，我就当它在鼓掌。下山还想再跑一遍，换条路。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_sd_02 | p_energetic | 山地 | {encounter}。我们比赛爬坡，谁也不肯慢下来。结果：{incident}。没分出胜负，明天加赛！——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_sd_03 | p_energetic | 山地 | 山里的{timeOfDay}空气一吸就想跑！我从枫树跑到雪线又跑回来，一路的季节全见了一遍。{ownerName}，我今天像是跑过了整个{season}。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_cs_01 | p_energetic | 城市 | {location}的台阶、桥和天桥，我全跑遍了！路上还遇上一件事：{encounter}。今天我比早高峰还准时。后来又有个新发现：{incident}。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_cs_02 | p_energetic | 城市 | 我和电车从这站赛跑到下站。它赢了，但只领先一个车头！司机看到我冲线，还按了两声铃；我决定把那当作欢呼。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_cs_03 | p_energetic | 城市 | 屋顶水塔上的视野太好了！我是一路跳上来的。{incident}。下去的路线也勘察完毕：换另一边。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_xy_01 | p_energetic | 乡野 | {location}的田埂是天然跑道！我领跑，风第二，麦浪第三。{incident}。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_xy_02 | p_energetic | 乡野 | {encounter}。它跑，我也跑，后来半个农场都跟了上来！最后大家在风车下喘气，夕阳正好给每个人镀了一枚金牌。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_xy_03 | p_energetic | 乡野 | 今天帮邮局送了三封信，一路都没歇！{incident}。{ownerName}，这封是第四封，是我给自己接的任务。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_sl_01 | p_energetic | 森林 | {location}的树根一个接一个，像森林专门摆好的跨栏！{incident}。松鼠说，我把它一周的运动量都吓出来了。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_sl_02 | p_energetic | 森林 | {encounter}。我们比赛谁先到千年橡树：它抄近道，我穿过灌木！结果同时抵达，身上都带着叶子，谁也顾不上争第一。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_sl_03 | p_energetic | 森林 | 雾里跑步像在云里冲刺！我一路给自己解说：『它从雾里冲出来了。』{incident}。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_sm_01 | p_energetic | 沙漠异域 | 沙丘冲刺太好玩了！冲上去两步，又滑下来三步。我和沙丘来回较量了三十次。{incident}。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_sm_02 | p_energetic | 沙漠异域 | {encounter}。它们一步顶我三步，我就用三倍速度跟上！商队的人说，我是队伍里最卖力的小发动机。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_sm_03 | p_energetic | 沙漠异域 | 热气球升起来时，我在下面追了很远！{incident}。{ownerName}，后来影子也加入比赛，我们都尽力了。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_jd_01 | p_energetic | 极地水域 | 冰面太滑了，我起跑一次就滑出去十米！这不是摔倒，是刚学会的新技能。{incident}。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_jd_02 | p_energetic | 极地水域 | {encounter}。它们排队跳进浅水，我也跟着试了一次！溅起的水花比我还高，旁边那只海鸥给了满分。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_jd_03 | p_energetic | 极地水域 | {location}的石板路可以助跑滑行！我试了三种刹车办法，其中一种很成功。{incident}。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_en_qh_01 | p_energetic | 奇幻 | 云做的地面会轻轻弹起，我一下就跃出去三米！{location}简直像为我准备的。{incident}。——{petName} | I made it to {location}! {encounter}. {incident}. There are more paths ahead, and I am already on my way. Love, {petName} |
| tpl_en_qh_02 | p_energetic | 奇幻 | {encounter}。我们绕着会走路的岛跑了一整圈！岛走它的，我跑我的，最后创造了一项没人记录过的新纪录。——{petName} | Travel record from {location}: first in running, first in exploring, and first in enthusiasm! {encounter}. {incident}. Love, {petName} |
| tpl_en_qh_03 | p_energetic | 奇幻 | 月亮背面的重力很轻，我一步跳过三个邮筒！邮差让我慢一点，我认真答应了，然后下一步跳过了四个。{incident}。——{petName} | {ownerName}, even the {weather} could not keep up today! {encounter}. {incident}. I crossed the whole view so I could tell you about it. Love, {petName} |
| tpl_cl_hb_01 | p_clingy | 海滨 | {ownerName}，你今天有好好吃饭吗？我把你的名字写在{location}的沙滩上了，浪冲掉一遍我就写一遍，写到第九遍浪就不冲了——它大概记住你了。{incident}。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_hb_02 | p_clingy | 海滨 | 今天遇上一件事：{encounter}。风一吹，我又习惯朝着家的方向坐。{location}的{timeOfDay}风很软，像你晾过的毛巾。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_hb_03 | p_clingy | 海滨 | 捡了一枚弯弯的贝壳，对着它说了今天发生的事。{incident}。等我回去，它负责一字不落地讲给你听；忘了也没关系，我再讲一遍。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_sd_01 | p_clingy | 山地 | {location}的山顶能看好远，我努力看了又看——嗯，看不到院子，但我知道它在哪个方向，我就朝那边坐了一会儿。{incident}。你记得添衣服，山里都冷了。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_sd_02 | p_clingy | 山地 | {encounter}。围着篝火的时候大家轮流讲『最想的人』，轮到我，我讲了好久，火都替我旺了一圈。{ownerName}，讲的是你。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_sd_03 | p_clingy | 山地 | 温泉好舒服，但泡到一半我突然想：你那儿的水烧开了吗？想到这儿就爬起来给你写信。{incident}。写完再回去泡，位置我用毛巾占好了。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_cs_01 | p_clingy | 城市 | {location}的橱窗里有一条和你那条一模一样的围巾！我在玻璃前站了好久，路人以为我想买。不是，我是想你。{incident}。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_cs_02 | p_clingy | 城市 | 今天遇上一件事：{encounter}。街边有盏灯和你房间的灯一个颜色。我蹭着灯光把这封信写完，就当在你旁边写的。{timeOfDay}的{location}，到处都有一点点你。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_cs_03 | p_clingy | 城市 | 摩天轮转到最高的时候，全城的灯都亮了。我许愿列表更新：第一条没变，还是快点见到你。{incident}。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_xy_01 | p_clingy | 乡野 | {location}的邮局姐姐都认识我了，因为我每站都寄信，收件人都是你。{incident}。她说被这么惦记的人一定很幸福——我说那当然！——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_xy_02 | p_clingy | 乡野 | 今天遇上一件事：{encounter}。一扇窗里，小家伙们正挤在一起睡。我看着看着就想：我们也这样靠在一起休息过，只是你占的地方比较多。{season}的{location}，晚安。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_xy_03 | p_clingy | 乡野 | 向日葵一整天都朝着太阳转，我懂它。我也有一个总会望向的方向。{incident}。是院子那边。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_sl_01 | p_clingy | 森林 | {location}的千年橡树邮筒说，塞进树洞的信最快三天到。我塞了信，又对着树洞喊了一声你的名字——声音说不定比信还快。{incident}。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_sl_02 | p_clingy | 森林 | {encounter}。它问我为什么每片好看的落叶都捡，我说要给你带回去铺一条小路，从门口铺到你脚边。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_sl_03 | p_clingy | 森林 | 雾里走路的时候我把你的旧手套系在包上，晃来晃去的，像你在前面招手。{incident}。这样走再远也不算一个人。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_sm_01 | p_clingy | 沙漠异域 | 星空盐湖的星星多得数不完。我不数了，反正每颗亮的都替我朝院子的方向看一眼。{incident}。下次抬头时，最亮的那颗会替我先问好。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_sm_02 | p_clingy | 沙漠异域 | {encounter}，驼队的铃铛一路响，我把铃声学下来了，回去唱给你听。要是走调，就算沙漠送来的另一种纪念。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_sm_03 | p_clingy | 沙漠异域 | 沙漠的夜里降温好快，我裹紧毯子时第一个念头是：你的被子够厚吗？{incident}。远方一切都好，只是在看见身旁空出来的位置时，会想起你。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_jd_01 | p_clingy | 极地水域 | 极光亮起来的那一刻，全村的人都在喊。我也喊了，喊的是你的名字——这么好看的东西，第一反应当然是想让你看见。{incident}。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_jd_02 | p_clingy | 极地水域 | 今天遇上一件事：{encounter}。这里的大家习惯靠在一起取暖，我很熟练，毕竟是跟你学的。{location}很冷，想起院子时却很暖。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_jd_03 | p_clingy | 极地水域 | 浮冰灯塔一亮一亮的，像有人在说『在呢，在呢』。我盯着看了好久。{incident}。{ownerName}，你也要好好的，在呢。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_cl_qh_01 | p_clingy | 奇幻 | {location}的邮差说，寄给常常想起的人可以免邮票，所以这张没贴。{incident}。窗台风铃响时，就当它替我先打了招呼。——{petName} | {ownerName}, I reached {location}. {encounter}. {incident}. The first thing I wanted to do was write to you. Love, {petName} |
| tpl_cl_qh_02 | p_clingy | 奇幻 | 今天遇上一件事：{encounter}。听说云端牧场的云可以定制形状，我订了一朵你的样子，牧云人明天开工。等哪天你抬头看见一朵特别眼熟的云——别怀疑，是我干的。——{petName} | {location} is beautiful, but every lovely thing makes me wonder whether you can see the same sky. {encounter}. {incident}. Love, {petName} |
| tpl_cl_qh_03 | p_clingy | 奇幻 | 会走路的岛问我要去哪儿，我说了院子的方向，它居然真的转了个小弯！{incident}。那一刻，世界好像也记得回去的方向。——{petName} | I tied a memory of the garden to my bag today. {encounter}. {incident}. However far I walk, it feels as though the garden is just ahead. Love, {petName} |
| tpl_al_hb_01 | p_aloof | 海滨 | 到{location}了。海是蓝的。浪很吵。{incident}。……涛声睡前听还行。你那儿，应该很安静吧。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_hb_02 | p_aloof | 海滨 | {encounter}。没有理。后来它把最好的位置让给了我。……勉强坐了。挺暖和。就这样。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_hb_03 | p_aloof | 海滨 | 灯塔的光转一圈要十秒。我看了一晚上。别问为什么，就是……有点像院子的夜灯。睡了。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_sd_01 | p_aloof | 山地 | 到了。{location}。{encounter}。没有挣扎，是因为{incident}，别多想。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_sd_02 | p_aloof | 山地 | 山顶。风大。视野尚可。{incident}。……从这里看不到院子。看了三次确认的。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_sd_03 | p_aloof | 山地 | 雪线木屋。壁炉还行。{encounter}，非要挨着我烤火。挤。……但今晚确实不冷。仅记录事实。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_cs_01 | p_aloof | 城市 | {location}。人多。灯太亮。{incident}。深夜的巷子倒是清净——适合想一些……不重要的事，比如晚饭，比如你。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_cs_02 | p_aloof | 城市 | {encounter}。给的东西我尝了一口。两口。……店家手艺凑合，主要是坐在门口那个位置晒得到太阳。明天大概还去。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_cs_03 | p_aloof | 城市 | 旧书坊巷。靠着书睡了一下午。老板没赶我。{incident}。这个城市，勉强有点意思。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_xy_01 | p_aloof | 乡野 | {location}。安静。{encounter}，跟了我一路。没赶。乡下的路长，有个跟班……也不是不行。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_xy_02 | p_aloof | 乡野 | 麦子熟了，一片金的。看久了眼睛有点热。是风沙。{incident}。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_xy_03 | p_aloof | 乡野 | 在{location}的屋檐下歇脚。{incident}。虫鸣。稻香。……你以前也这样跟我一起坐过。就提一句。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_sl_01 | p_aloof | 森林 | {location}。雾。走了很久没遇到谁。挺好。{incident}。……太安静了也不算太好。仅供参考。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_sl_02 | p_aloof | 森林 | {encounter}。它话多。我话少。它讲了一路，我听了一路。……分开的时候它说下次再讲。没有拒绝。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_sl_03 | p_aloof | 森林 | 千年橡树下睡了一觉。树洞里有别人塞的信。我也塞了一张。内容不告诉你。收件人……写的谁你应该知道。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_sm_01 | p_aloof | 沙漠异域 | {location}。昼热夜冷。星星过量。{incident}。夜里数星星数到第七颗就停了——第七颗最亮，像某个总喊我吃饭的人的窗户。睡了。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_sm_02 | p_aloof | 沙漠异域 | 今天遇上一件事：{encounter}。我在摊边借了个背风的位置，离开前认真点了一下头。对方看见了，算扯平。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_sm_03 | p_aloof | 沙漠异域 | 热气球。升空。地面变小。感想：一般。……院子从天上看会是什么样，倒是想知道。就这样。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_jd_01 | p_aloof | 极地水域 | {location}。冷。极光，绿的，还行。{incident}。……好吧。不止还行。这句只写一遍，看完就忘。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_jd_02 | p_aloof | 极地水域 | {encounter}。它们轮流贴过来取暖。队伍很长。我没同意，也没走。天冷，特殊情况。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_jd_03 | p_aloof | 极地水域 | 渔村的灯很早就亮。谁家都留一盏给晚归的。{incident}。……你也留过。我记得。落款前想了想，还是写上：挺想的。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_al_qh_01 | p_aloof | 奇幻 | {location}。设定离谱。体验……可以。{incident}。奇迹见多了也就那样。除了一件：这里寄信真的能到你手上。这件算奇迹。——{petName} | {location}. Arrived. The view is better than expected. {encounter}. {incident}. I happened to think of you. That is all. {petName} |
| tpl_al_qh_02 | p_aloof | 奇幻 | {encounter}。它说可以帮我实现一个愿望。我说没有。它说撒谎。……愿望内容保密，反正和某个院子有关。——{petName} | Report from {location}: {weather}. {encounter}. {incident}. I checked whether the garden was visible from here. It was not. I checked twice. {petName} |
| tpl_al_qh_03 | p_aloof | 奇幻 | 月亮背面。安静。适合我。{incident}。这里能看到地球。我看了很久。……不解释。——{petName} | {location} is quiet enough. {encounter}. {incident}. I may stay another day. The garden crossed my mind. {petName} |
| tpl_na_hb_01 | p_naughty | 海滨 | 郑重澄清：{location}那艘小船不是我解开的，缆绳是自己松的，我只是……帮它松得快了一点。{incident}。船主罚我看船一下午，看船还能晒太阳，怎么算都不亏。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_hb_02 | p_naughty | 海滨 | {encounter}。我们比赛谁先捡到浪头送来的东西，我赢了三次！代价是全身湿透，被它笑到现在。值。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_hb_03 | p_naughty | 海滨 | 我在沙滩上绕着每只晒太阳的螃蟹画了圈。它们醒来都很困惑。{incident}。艺术，是需要观众醒着的。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_sd_01 | p_naughty | 山地 | 对着{location}的回声谷喊了『开饭啦』，结果半座山的动物都探出了头。{incident}。我错了，但是场面真的很壮观。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_sd_02 | p_naughty | 山地 | 今天遇上一件事：{encounter}。我又看见一处藏坚果的地方，就换个位置帮忙重新藏，忙了一下午。现在谁都找不到了，我也忘了。{season}的山里将来会多出很多棵树，都算我种的。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_sd_03 | p_naughty | 山地 | 温泉边立了牌子『禁止扑通』。我研究了一下，牌子上没写禁止『咚』。{incident}。规则漏洞是用来跳的。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_cs_01 | p_naughty | 城市 | 在{location}有了一个新发现：{incident}。对不起，但真的好好笑。后来又遇上一件事：{encounter}。最后我不但没被赶走，还转正了。我现在是本街最红的。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_cs_02 | p_naughty | 城市 | 正式声明：旧书坊的书塔倒塌与我无关，我路过时它已经在晃了（我承认我又碰了一下，想确认它晃不晃）。{incident}。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_cs_03 | p_naughty | 城市 | 把{location}晾着的袜子按颜色重新配了对。全楼的人都穿错了，但都更好看了。{incident}。没有人抓到我，这封信是唯一证据。请销毁；算了，还是留着吧。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_xy_01 | p_naughty | 乡野 | 郑重澄清：在{location}发生了一件事，{incident}。我只是……组织了一下事情发生的方向。罚是罚了，后来却又遇上一件好事：{encounter}。这就是传说中的因祸得福！——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_xy_02 | p_naughty | 乡野 | 稻草人的帽子现在在我头上。它没有意见（它没有意见的能力）。{incident}。全田的乌鸦都以为换了新领导，听话得很。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_xy_03 | p_naughty | 乡野 | {encounter}，我们联手把风车下的午睡大爷的草帽转移到了羊头上。大爷醒来夸羊有品位。{season}的乡下，快乐简单。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_sl_01 | p_naughty | 森林 | 松果集市今天促销，因为我把『每颗一果』的牌子啃成了『每颗十果』。{incident}。松鼠会计追了我三棵树，追上以后……我们合伙把牌子改回来了，收手续费两颗榛子。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_sl_02 | p_naughty | 森林 | 今天遇上一件事：{encounter}。我还学会了认蘑菇，也学会了装蘑菇——蹲着不动，头顶一片叶子。路过的采蘑菇奶奶差点把我也摘走。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_sl_03 | p_naughty | 森林 | 往树洞邮筒里塞了一片超大的落叶，收件人：随便谁。{incident}。第二天树洞里多了三片回信落叶。我不小心发明了一个邮政系统。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_sm_01 | p_naughty | 沙漠异域 | 经过彩绘集市的颜料摊时，行李带不小心扫了一下。{incident}。摊主看着那面墙沉默很久，然后给它标了价。我要分成！——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_sm_02 | p_naughty | 沙漠异域 | 今天遇上一件事：{encounter}。午后我趁商队打盹，把两枚铃铛换了位置。醒来后全队的节奏都乱了，乱出了一种新的曲子。领队说明天就按这个走。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_sm_03 | p_naughty | 沙漠异域 | 热气球点火师说小孩别碰。我没碰，我只是对着火吹了口气（表示友好）。{incident}。现在全营地都认识我了，认识的方式不太光彩，但认识了。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_jd_01 | p_naughty | 极地水域 | 把{location}渔夫钓上来的鱼偷偷放回去了两条（它们眼神太可怜）。被抓包后我摆出最无辜的脸。{incident}。渔夫说：行吧，就当放生积福。我：对，是这样的。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_jd_02 | p_naughty | 极地水域 | {encounter}，比赛贴着冰面滑行画画。我画的圆最圆，因为我没能及时刹住。裁判争议很大，快乐没有争议。——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_jd_03 | p_naughty | 极地水域 | 往蓝洞泉里放了一片叶子，想看它漂到哪里。旁边看水的小孩也跟着放了一片。{incident}。现在比赛叶子漂流成了这里的新游戏，是我发明的，没人知道，你知道就行。——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_na_qh_01 | p_naughty | 奇幻 | 云端牧场的一只云羊邀我跟着跑了一段。{incident}。牧云人说，我是十年来第一个摔进云里还笑得出来的旅客。——{petName} | For the record, not everything that happened in {location} was my fault. {encounter}. {incident}. I will explain the details when I get home. Maybe. Love, {petName} |
| tpl_na_qh_02 | p_naughty | 奇幻 | 往月亮背面的邮筒里投了一张白纸。{encounter}问我寄什么，我说寄一个谜。现在全邮局都在猜。谜底：没有谜底。（别揭发我。）——{petName} | Official statement from {location}: I only helped events along. {encounter}. {incident}. No regrets worth mentioning. Love, {petName} |
| tpl_na_qh_03 | p_naughty | 奇幻 | 糖霜火山喷发前会『咕嘟』一声。我学会了这个声音。{incident}。全镇演习了三次之后禁止我再学。第四次是火山自己咕嘟的，这次真不是我！——{petName} | {ownerName}, please keep this letter as evidence that I was mostly well behaved. {encounter}. {incident}. Mostly is an important word. Love, {petName} |
| tpl_ge_hb_01 | p_gentle | 海滨 | 今天帮一只被浪打翻的小寄居蟹翻了个身，它道谢的样子好小声。{incident}。{location}的浪很大，但大家都在好好生活。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_hb_02 | p_gentle | 海滨 | {encounter}。分别的时候它送了我半片珍珠色的贝壳，另外半片它留着——它说这样我们就算认识了一整个海。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_hb_03 | p_gentle | 海滨 | {timeOfDay}退潮，好多小水洼里困着小鱼。我一个一个把它们送回海里，最后一只回头看了我一眼。{incident}。今天的海比昨天满一点点，有我的功劳。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_sd_01 | p_gentle | 山地 | 山路上遇到一件事：{encounter}。路边还有一袋散开的行李，我帮着捡到{timeOfDay}，最后收到一颗野莓作谢礼。后来又有个新发现：{incident}。山很陡，但没有谁是一个人爬的。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_sd_02 | p_gentle | 山地 | 雪线上有一株开在石缝里的小花，路过的都替它挡一下风。我也挡了一会儿。{incident}。它不知道我们的名字，我们也不需要。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_sd_03 | p_gentle | 山地 | {location}的温泉里，年纪最大的猴子泡在最暖的位置——是小猴们让的。我看着看着，心里也跟着暖起来，便把捡到的栗子分给了它们。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_cs_01 | p_gentle | 城市 | 深夜面馆打烊后，老板会把剩的汤留给巷子里的猫。今晚我帮他把碗摆整齐了。{incident}。{location}的深夜，比白天软。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_cs_02 | p_gentle | 城市 | {encounter}。它找不到回家的路，我陪它一站一站地闻回去。到家的时候它家人冲出来的样子，我会记很久。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_cs_03 | p_gentle | 城市 | 旧书坊的老板眼睛不好，我守在窗台边帮他晒书，也请啄书角的鸽子去别处散步。{incident}。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_xy_01 | p_gentle | 乡野 | 今天帮一只迷路的瓢虫过了马路——是田埂，但对它来说就是很宽很宽的马路。{incident}。它道谢的声音，要俯下身靠近草面才能听见。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_xy_02 | p_gentle | 乡野 | {encounter}。谷仓有一处漏风，我们花了一下午用干草把缝隙垫好。完工时风刚好停了，像是天也来验收。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_xy_03 | p_gentle | 乡野 | 向日葵车站的长椅上有一颗没人认领的纽扣，我把它摆到最显眼的地方，又怕它晒着，挪到了有阴影的显眼地方。{incident}。希望丢它的人回来找。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_sl_01 | p_gentle | 森林 | {location}的落叶下面睡着过冬的虫子，所以我走路很慢很慢，像在读一封不能吵醒的信。{incident}。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_sl_02 | p_gentle | 森林 | 今天遇上一件事：{encounter}。树洞边还有个小家伙，刺上挂了太多果子，卡在洞口进退两难。我帮忙一颗一颗卸下来，再一颗一颗从洞口递进去。洞里传来一句小小的谢谢。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_sl_03 | p_gentle | 森林 | 雾太大，我把捡到的萤火虫小灯（一片会发光的菌子）放在了吊桥入口。{incident}。不知道会照亮谁，反正会照亮谁的。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_sm_01 | p_gentle | 沙漠异域 | 绿洲的水边，商队的骆驼排队喝水，最小的那只总被挤到最后。我陪它站了会儿，把我的位置让给了它。{incident}。它睫毛好长，眨一下像说了句谢谢。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_sm_02 | p_gentle | 沙漠异域 | 今天遇上一件事：{encounter}。街角还有人画了一下午，我就蹲在画前当第一个观众。后来围过来好多人。离开前，我收到一张小画：是蹲着的我。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_sm_03 | p_gentle | 沙漠异域 | 夜里降温，我把毯子分了一半给帐篷外的流浪小猫。{incident}。半条毯子没有不够，暖是会互相传的。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_jd_01 | p_gentle | 极地水域 | 渔村的爷爷说腿疼，出不了门看极光。我陪他坐在窗边等，极光出来时我们谁都没说话。{incident}。有些陪伴不需要翻译。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_jd_02 | p_gentle | 极地水域 | 今天遇上一件事：{encounter}。浅水边还有个小家伙，第一次下水不敢跳。我在旁边陪着一起数浪，数到第二十个，终于听见轻轻一声水响。溅起的水花不大，却很勇敢。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_jd_03 | p_gentle | 极地水域 | 浮冰上冻着一朵不知从哪儿漂来的花。大家都绕开走，怕踩碎它。{incident}。整个{location}都在保护一朵花，这里的冷是假的。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_ge_qh_01 | p_gentle | 奇幻 | 月亮背面的邮局有一格『无人认领的信』。邮差说有些收信人已经等不到了。我请他把那格的灰擦了擦，窗子开了一条缝。{incident}。信等人的样子，也应该体面一点。——{petName} | Today I reached {location}. {encounter}. {incident}. Everyone here is caring for someone in a small way. I will remember that. Love, {petName} |
| tpl_ge_qh_02 | p_gentle | 奇幻 | 今天遇上一件事：{encounter}。岛上的居民说，会走路的岛已经累了一百年。大家商量后决定：这个{season}谁也不催它赶路。我第一个表示赞成。——{petName} | The {timeOfDay} at {location} felt especially kind. {encounter}. {incident}. A little company can make a long road feel warm. Love, {petName} |
| tpl_ge_qh_03 | p_gentle | 奇幻 | 云端牧场里最旧的一朵云快散了，牧云人舍不得。大家轮流往它身上哈热气。{incident}。它最后变成一阵细得几乎看不见的雨，落在每个人鼻尖上。谁也没哭，都笑着说凉凉的。——{petName} | {ownerName}, I found something tender at {location}. {encounter}. {incident}. I am sending this page home so the garden can keep it too. Love, {petName} |
| tpl_dr_hb_01 | p_dreamy | 海滨 | {location}的浪一遍一遍地翻，像谁在找一页夹丢了的信纸。{incident}。我帮它找了很久，找到的都是细碎的光。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_hb_02 | p_dreamy | 海滨 | {encounter}。它说贝壳里的声音是海的回忆。那我听到的这一段，一定是海很小的时候——声音很轻，还不会打雷。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_hb_03 | p_dreamy | 海滨 | 海雾漫上来的时候，{location}就被装进了一只毛玻璃罐子。{incident}。我也在罐子里，标签上写着：请轻放，内有想家的（一只）。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_sd_01 | p_dreamy | 山地 | 云从{location}的垭口翻过去，像一群没睡醒的绵羊，我数着数着也想家了。{incident}。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_sd_02 | p_dreamy | 山地 | {encounter}。它说回声谷的回声其实是山在做笔记。那我今天对着山谷说的那句话，山已经记下了。内容保密，反正是关于你的。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_sd_03 | p_dreamy | 山地 | 枫叶红透的那面山坡，是{season}打翻的颜料，也可能是晚霞下山的时候没提好裙摆。{incident}。两种说法我都信。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_cs_01 | p_dreamy | 城市 | {location}的路灯到了{timeOfDay}就一盏一盏亮，像有人在给城市盖章：这一页读完了，这一页也读完了。{incident}。我的这一页上，盖的是你的名字。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_cs_02 | p_dreamy | 城市 | 今天遇上一件事：{encounter}。摩天轮转一圈要十五分钟。我坐了一圈，看城市慢慢躺下又慢慢站起来——原来城市也要翻身的，睡不着的时候。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_cs_03 | p_dreamy | 城市 | 深夜的电车空着开过去，我觉得它是替所有睡着的人，把没做完的梦送去下一站。{incident}。我的那个梦，麻烦送到院子。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_xy_01 | p_dreamy | 乡野 | 萤火稻田到了夜里就变成一片矮矮的星空，{incident}。我怀疑天上的星星是从这里毕业的——你看，连星星都要毕业的。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_xy_02 | p_dreamy | 乡野 | {encounter}。它说风车转是在给风磨面粉。所以起风的日子面包更香——这个说法没有证据，但有道理。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_xy_03 | p_dreamy | 乡野 | 麦浪一直涌到天边，我站在田埂上像站在一封摊开的信里。{incident}。落款是远处的邮局，收件人……我念了你的名字，麦子点了点头。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_sl_01 | p_dreamy | 森林 | {location}的雾不是雾，是森林还没写完的草稿，谁走进去谁就成了句子。{incident}。我今天是一个走得很慢的逗号。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_sl_02 | p_dreamy | 森林 | {encounter}。它说千年橡树每年长一圈年轮，是在给自己写日记。那树洞里的信，就是它替大家保管的心事吧。我也存了一件进去。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_sl_03 | p_dreamy | 森林 | 蘑菇圈在{timeOfDay}发光，像森林把星星按在了地上，怕它们飞走。{incident}。我蹲在圈外没有进去——万一那是谁的梦，别踩醒。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_sm_01 | p_dreamy | 沙漠异域 | {location}的墙全是画。我在里面待了一个{timeOfDay}，成了画的一部分。路上还遇上一件事：{encounter}。后来有人说，我是这里最安静的颜色。今天又有了新发现：{incident}。这份颜色和你有关。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_sm_02 | p_dreamy | 沙漠异域 | 星空盐湖把天空原样抄了一遍，连流星的错别字都没改。{incident}。我站在两片星空中间，不知道该把愿望许给哪边，就许了两遍。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_sm_03 | p_dreamy | 沙漠异域 | {encounter}。它说驼铃响一路，是给沙漠念经文，念到哪儿哪儿就不寂寞。我跟着走了一段，替铃铛换了个说法：是给沙漠讲睡前故事。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_jd_01 | p_dreamy | 极地水域 | 极光在{location}的天上慢慢写字，笔画很长，谁都认不出写的什么。{incident}。我认出来了（大概）：是『别急』。天空写给冬天的。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_jd_02 | p_dreamy | 极地水域 | {encounter}。它说蓝洞的蓝，是海攒了一万年的安静。我把头凑近水面看了很久，安静也看了看我。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_jd_03 | p_dreamy | 极地水域 | 浮冰一块一块漂，像谁把一封白色的信撕了撒进海里。{incident}。灯塔一夜没睡，在把它们一片一片读完。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |
| tpl_dr_qh_01 | p_dreamy | 奇幻 | {location}比我想象的还像我想象的。{incident}。这里的居民说我不像游客——他们说得对，我可能是这里派驻到现实的，回来述职。——{petName} | {location} looked like a letter opened by the wind. {encounter}. {incident}. I am sending you this page of the dream. Love, {petName} |
| tpl_dr_qh_02 | p_dreamy | 奇幻 | {encounter}。它问我从哪儿来，我说起一座会开花、会下雨，也会收下远方来信的院子。它说，听上去你来自一个童话。……对哦。——{petName} | At {timeOfDay}, {location} seemed to float between two skies. {encounter}. {incident}. I made a wish in both directions, just in case. Love, {petName} |
| tpl_dr_qh_03 | p_dreamy | 奇幻 | 月亮背面存放着所有没说出口的话，装在贝壳一样的罐子里，满了就往地球那边倒一点——那就是夜里没来由想起谁的时刻。{incident}。今晚我倒了一罐，收件人是你。——{petName} | Perhaps {weather} is only the sky remembering a story. {encounter}. {incident}. Tonight, that story leads all the way back to our garden. Love, {petName} |

## 9. 旅途遭遇与插曲

| ID | 类型 | 中文 | English |
| --- | --- | --- | --- |
| enc_hb_01 | 遭遇 | 烤鱼摊老板请我吃了刚出炉的一条 | the grilled-fish vendor treated me to a fish fresh from the fire |
| enc_hb_02 | 遭遇 | 灯塔管理员留我在塔里过了一夜 | the lighthouse keeper let me spend the night inside the tower |
| enc_hb_03 | 遭遇 | 一只认路全靠洋流的老海龟陪我走了一段 | an old sea turtle who navigates by currents kept me company |
| enc_hb_04 | 遭遇 | 海鸥小队拉我比了一场「谁先抢到浪尖」 | a squad of gulls challenged me to race the crest of a wave |
| enc_hb_05 | 遭遇 | 赶海的小孩用一颗海玻璃换了我的一根胡须（自愿掉的） | a beachcomber traded a piece of sea glass for one naturally shed whisker |
| enc_hb_06 | 遭遇 | 帮寄居蟹搬家队抬了一下午「新房」 | I helped a hermit-crab moving crew carry new homes all afternoon |
| enc_hb_07 | 遭遇 | 修船的老爷爷把船帆撑起来给我遮太阳 | an old boatbuilder raised a sail to shade me from the sun |
| enc_hb_08 | 遭遇 | 一只白海豚浮上来跟我交换了一个秘密 | a white dolphin surfaced and traded one secret with me |
| enc_sd_01 | 遭遇 | 一只小猴非说我是它的新围巾 | a little monkey insisted I was its new scarf |
| enc_sd_02 | 遭遇 | 我帮背货的大叔追回了滚坡的行李 | I helped a porter catch luggage rolling down the slope |
| enc_sd_03 | 遭遇 | 一只岩羊约我比赛爬坡 | a mountain goat challenged me to a climbing race |
| enc_sd_04 | 遭遇 | 采药奶奶分了我一把烤栗子 | an herb-gathering grandmother shared a handful of roasted chestnuts |
| enc_sd_05 | 遭遇 | 摄影师请我当云海照片的模特 | a photographer asked me to pose above the sea of clouds |
| enc_sd_06 | 遭遇 | 一只自称向导的松鸦带我抄了条小路（绕远了） | a self-appointed jay guide showed me a shortcut that was not shorter |
| enc_sd_07 | 遭遇 | 守屋犬把炉边最暖的位置让给了我 | the lodge dog gave me the warmest place beside the stove |
| enc_sd_08 | 遭遇 | 一只獾收我当了半天挖温泉学徒 | a badger hired me as a hot-spring digging apprentice for half a day |
| enc_cs_01 | 遭遇 | 面馆老板给我留了一块叉烧 | the noodle-shop owner saved a slice of roast pork for me |
| enc_cs_02 | 遭遇 | 电车司机请我站在驾驶室看了一站路 | the tram driver invited me into the cab for one stop |
| enc_cs_03 | 遭遇 | 旧书坊老板默许我在书堆上住了下来 | the old bookseller let me settle on top of the book piles |
| enc_cs_04 | 遭遇 | 屋顶的三花跟我交换了全城晒太阳地图 | a rooftop calico traded me a map of every sunny spot in the city |
| enc_cs_05 | 遭遇 | 一只迷路的小狗跟我结伴找家 | a lost puppy joined me while we searched for home |
| enc_cs_06 | 遭遇 | 街头画家边画我边跟我聊了一下午 | a street artist painted me while we talked all afternoon |
| enc_cs_07 | 遭遇 | 我帮夜班邮差看住了一车包裹 | I guarded a cart of parcels for the night-shift post carrier |
| enc_cs_08 | 遭遇 | 鸽子帮跟我比赛谁先占到喷泉边的好位置 | a pigeon crew raced me for the best place beside the fountain |
| enc_xy_01 | 遭遇 | 农场奶奶罚我看果园，工资是苹果派 | the farm grandmother paid me in apple pie for watching the orchard |
| enc_xy_02 | 遭遇 | 我帮邮局姐姐把信送到了最远的一户 | I helped the postmistress deliver a letter to the farthest house |
| enc_xy_03 | 遭遇 | 凶了我一路的大鹅最后给我带了路 | the goose that scolded me all day eventually showed me the way |
| enc_xy_04 | 遭遇 | 田鼠一家请我进洞喝了一顿麦茶 | a field-mouse family invited me underground for wheat tea |
| enc_xy_05 | 遭遇 | 我和看田大爷在风车下拼了一场午觉 | the field keeper and I held a serious napping contest under the windmill |
| enc_xy_06 | 遭遇 | 我和稻草人先生成了朋友（我单方面宣布） | Mr. Scarecrow and I became friends, by my official declaration |
| enc_xy_07 | 遭遇 | 果农用两颗李子换了我帮他看摊 | an orchard keeper traded two plums for my help at the stall |
| enc_xy_08 | 遭遇 | 一群萤火虫排成小灯串给我引了夜路 | a line of fireflies lit the night path for me |
| enc_sl_01 | 遭遇 | 松鼠会计跟我做了一笔松果生意 | a squirrel accountant negotiated a pinecone deal with me |
| enc_sl_02 | 遭遇 | 一只迷路的小刺猬赖上了我 | a lost little hedgehog decided to follow me |
| enc_sl_03 | 遭遇 | 猫头鹰局长请我参观了树洞邮筒的内部 | Director Owl showed me the inside of a tree-hollow postbox |
| enc_sl_04 | 遭遇 | 采蘑菇的奶奶往我这边留了一小筐边角蘑菇 | a mushroom gatherer saved a small basket of trimmings for me |
| enc_sl_05 | 遭遇 | 伐木屋的大狗约我赛跑到千年橡树 | the woodcutter's dog raced me to the ancient oak |
| enc_sl_06 | 遭遇 | 那只头顶自带小鸟的小鹿陪我走了一段雾路 | a deer with a tiny bird on its head walked through the mist with me |
| enc_sl_07 | 遭遇 | 蜘蛛织布匠送了我一小段带露水的银线 | a spider weaver gave me a dew-bright length of silver thread |
| enc_sl_08 | 遭遇 | 准备冬眠的熊把吃不完的蜂蜜分给了我 | a bear preparing to hibernate shared the last of its honey |
| enc_sm_01 | 遭遇 | 驼队领队让我在队尾跟了三天 | the caravan leader let me travel at the back of the line for three days |
| enc_sm_02 | 遭遇 | 画家找了我半小时，然后请我当了颜色顾问 | a painter searched for me, then appointed me color adviser |
| enc_sm_03 | 遭遇 | 摊主请我喝了一碗驼奶茶 | a market vendor treated me to a bowl of warm camel-milk tea |
| enc_sm_04 | 遭遇 | 一只大耳朵沙漠狐跟我交换了避暑洞穴的位置 | a large-eared desert fox traded me the location of a cool burrow |
| enc_sm_05 | 遭遇 | 热气球船长带我升空看了一眼日落 | a balloon captain took me up to see the sunset |
| enc_sm_06 | 遭遇 | 我帮看井人给排队的旅客舀了一下午水 | I spent the afternoon drawing water for travelers at the well |
| enc_sm_07 | 遭遇 | 观星老人和我并排躺着认了半晚上星座 | an old stargazer and I lay side by side naming constellations |
| enc_jd_01 | 遭遇 | 渔村爷爷让我在他家炉边住了两晚 | a fishing-village grandfather gave me a place beside his stove |
| enc_jd_02 | 遭遇 | 海豹一家轮流过来跟我贴贴取暖 | a whole seal family took turns cuddling close for warmth |
| enc_jd_03 | 遭遇 | 一只退役雪橇犬领着我踩着安全的冰走完了全程 | a retired sled dog led me safely across the ice |
| enc_jd_04 | 遭遇 | 我陪灯塔守夜人值了一个安安静静的夜班 | I shared one very quiet night watch with the lighthouse keeper |
| enc_jd_05 | 遭遇 | 一群海鹦拉我加入了跳水表演 | a flock of puffins recruited me for their diving show |
| enc_jd_06 | 遭遇 | 船夫分了我半条热气腾腾的烤鱼 | the boatman shared half a steaming grilled fish with me |
| enc_jd_07 | 遭遇 | 一只白狐和我在极光下并肩坐了很久 | a white fox sat beside me beneath the aurora for a long while |
| enc_qh_01 | 遭遇 | 月亮邮局的邮差教了我这里的寄信规矩 | the moon-post carrier taught me the local rules for sending letters |
| enc_qh_02 | 遭遇 | 牧云人让我帮忙赶了一下午云羊 | a cloud shepherd let me help herd cloud sheep all afternoon |
| enc_qh_03 | 遭遇 | 岛用很慢很慢的震动跟我说了话 | the island spoke to me in a very slow, gentle tremor |
| enc_qh_04 | 遭遇 | 糖匠请我尝了第一锅火山糖霜 | the confectioner let me taste the first batch of volcano frosting |
| enc_qh_05 | 遭遇 | 一只星星虫商人用一小瓶星光换了我的一个愿望 | a Starbug merchant traded a vial of starlight for one wish |
| enc_qh_06 | 遭遇 | 一位在找旧主人的小守护灵和我同行了一站 | a little guardian spirit searching for an old friend traveled one stop with me |
| inc_hb_01 | 插曲 | 一个浪把我的帽子卷走又在下一个浪送了回来 | one wave carried off my hat and the next wave returned it |
| inc_hb_02 | 插曲 | 捡到的漂流瓶里是一张空白信纸，像是专门留给我写的 | a bottle on the shore held a blank sheet that seemed saved for my letter |
| inc_hb_03 | 插曲 | 退潮的沙滩上留下了一整片会反光的星星（是小鱼鳞） | the low-tide sand glittered with a field of tiny silver fish scales |
| inc_hb_04 | 插曲 | 睡着的时候涨潮了，醒来发现自己漂在一块浮木上环游了半个海湾 | the tide rose while I slept and a piece of driftwood toured half the bay with me |
| inc_hb_05 | 插曲 | 螃蟹横着走给我让路，一整排，像仪仗队 | a whole row of crabs sidestepped to let me pass like an honor guard |
| inc_hb_06 | 插曲 | 灯塔的光扫过来的那三秒，海面亮得像铺了一层碎金 | the lighthouse beam laid three seconds of broken gold across the sea |
| inc_hb_07 | 插曲 | 追一只螃蟹追进了海草堆，出来的时候顶着一头「新发型」 | I chased a crab into seaweed and emerged with a brand-new hairstyle |
| inc_hb_08 | 插曲 | 我埋在沙里的鱼干被浪冲走，第二天原地多了两条（海还的？） | the sea took my buried fish snack and returned two the next morning |
| inc_sd_01 | 插曲 | 云海刚好在我到垭口那一刻裂开一条缝，山下的灯全露了出来 | the cloud sea opened at the pass just as I arrived, revealing every light below |
| inc_sd_02 | 插曲 | 温泉的雾太大，我泡着泡着抱住了一块以为是同伴的石头 | the hot-spring mist was so thick that I hugged a rock by mistake |
| inc_sd_03 | 插曲 | 回声谷把我打的喷嚏传了五座山，五座山都「回敬」了我 | Echo Canyon carried my sneeze across five mountains, and all five answered |
| inc_sd_04 | 插曲 | 一颗松果精准砸中我的头，抬头看是松鼠在道歉（爪里还抱着三颗） | a pinecone landed squarely on my head while a squirrel apologized overhead |
| inc_sd_05 | 插曲 | 枫叶落进我的背包，一路捡了整整一层，打开像装了一包晚霞 | maple leaves filled my open backpack until it held a whole sunset |
| inc_sd_06 | 插曲 | 雪线上的脚印和我的爪印一路并排，走到头也没见到那位同路人 | a second set of pawprints walked beside mine through the snow, though we never met |
| inc_sd_07 | 插曲 | 打了个哈欠被山风灌满，滚了半个坡，滚进了一丛软软的高山杜鹃 | the mountain wind filled one yawn and rolled me into soft alpine flowers |
| inc_sd_08 | 插曲 | 夜里木屋的窗上结了霜花，形状像极了院子的篱笆 | frost flowers on the cabin window looked exactly like the garden fence |
| inc_cs_01 | 插曲 | 学电车报站学得太像，害一个站台的人白等了一趟车 | my tram-stop impression was so convincing that a platform waited for the wrong tram |
| inc_cs_02 | 插曲 | 面馆的收音机正好在放你常哼的那首歌 | the noodle shop radio played the song you always hum |
| inc_cs_03 | 插曲 | 深夜的红绿灯坏了，一直绿着，像专门给我留的一路通行 | a broken midnight signal stayed green as if the city had cleared a path for me |
| inc_cs_04 | 插曲 | 在旧书坊打盹压皱了一页地图，老板说皱的那条路反而是近道 | I creased a map while napping on it, and the bookseller called the crease a shortcut |
| inc_cs_05 | 插曲 | 摩天轮停下来检修，我坐的那格刚好停在最高点十分钟 | the Ferris wheel paused for repairs with my carriage at the very top |
| inc_cs_06 | 插曲 | 屋顶水塔的影子在黄昏刚好罩住我，像一顶为我量身的大帽子 | the water-tower shadow fitted over me like an enormous custom hat |
| inc_cs_07 | 插曲 | 追一片被风卷走的传单穿过三条巷子，追到手发现是面馆折扣券 | a runaway flyer led me through three alleys and turned out to be a noodle coupon |
| inc_cs_08 | 插曲 | 街角橱窗里的玩偶和我摆着一模一样的姿势 | a toy in a shop window was holding exactly the same pose as me |
| inc_xy_01 | 插曲 | 苹果自己滚下坡，滚动方向被我「组织」了一下（往我嘴里） | a rolling apple received a little guidance and rolled directly toward my mouth |
| inc_xy_02 | 插曲 | 萤火虫在稻田上排成了一条会呼吸的光带 | fireflies formed one long, breathing ribbon of light above the rice fields |
| inc_xy_03 | 插曲 | 向日葵车站今天只停了一班车，下来的乘客是一筐小鸡 | the only passenger at Sunflower Station was a basket full of chicks |
| inc_xy_04 | 插曲 | 在麦垛里睡午觉，被收麦子的大叔连垛一起搬上了车，醒来已到邻村 | I fell asleep in a haystack and woke in the next village on the hay cart |
| inc_xy_05 | 插曲 | 风车转速和我尾巴摇的频率完全同步了一下午 | the windmill and my wagging tail kept exactly the same rhythm all afternoon |
| inc_xy_06 | 插曲 | 傍晚的炊烟在无风的天里笔直笔直，全村像插满了通往云的梯子 | straight evening smoke rose from every chimney like ladders into the clouds |
| inc_xy_07 | 插曲 | 帮忙看摊时把「特价」牌碰倒了，一下午都是特价，果农说就当感谢街坊 | I knocked over the sale sign, so the orchard keeper thanked the whole village with a sale |
| inc_xy_08 | 插曲 | 邮局的邮戳今天缺墨，盖出来的圈刚好像一颗爱心 | a dry postmark stamped a perfect little heart around the missing ink |
| inc_sl_01 | 插曲 | 蘑菇圈在我路过时齐刷刷亮了一下，像一圈小路灯给我鼓掌 | a mushroom ring lit up all at once as though tiny path lights were applauding |
| inc_sl_02 | 插曲 | 背包塞得太满，过树洞时卡住，全集市都来帮忙往外拽 | an overfilled backpack wedged me in a tree hollow and the whole market pulled me free |
| inc_sl_03 | 插曲 | 我埋的橡果位置忘了，挖开三个坑，坑坑有别人埋的存货 | I forgot my acorn hiding place and every wrong hole contained someone else's treasure |
| inc_sl_04 | 插曲 | 雾散开的一瞬，吊桥尽头站着一只回头看我的鹿，一秒又没入雾里 | when the fog opened, a deer looked back from the bridge and vanished a second later |
| inc_sl_05 | 插曲 | 踩到一根会翘起来的树根，被弹进了一堆刚扫拢的落叶山 | a springy root flipped me straight into a freshly swept mountain of leaves |
| inc_sl_06 | 插曲 | 千年橡树掉下一片叶子，正正落在我摊开的信纸上，就当它也署了名 | one ancient-oak leaf landed on my letter, so I counted it as the tree's signature |
| inc_sl_07 | 插曲 | 夜里的松果集市点起松脂灯，整片林子闻起来像烤饼干 | resin lamps made the night market smell like warm biscuits |
| inc_sl_08 | 插曲 | 学啄木鸟敲了三下树，全林的啄木鸟回敲了我一下午，停不下来 | three experimental taps brought replies from every woodpecker in the forest |
| inc_sm_01 | 插曲 | 盐湖今晚一丝风都没有，天上一整条银河，脚下也一整条 | the still salt lake held one Milky Way overhead and another under my feet |
| inc_sm_02 | 插曲 | 尾巴扫翻颜料摊，那面墙从此多了一幅「日落追尾图」，被标了价 | my tail swept a paint stall into a mural that the merchant promptly priced |
| inc_sm_03 | 插曲 | 沙丘一夜之间挪了位置，我做的记号石成了新沙丘的「山顶碑」 | the dunes moved overnight and turned my marker stone into a summit monument |
| inc_sm_04 | 插曲 | 把驼铃当成饭铃，循声狂奔三里地，商队请我吃了顿正经的 | I mistook camel bells for a dinner bell and earned a proper caravan meal |
| inc_sm_05 | 插曲 | 一场十分钟的沙漠阵雨，落地前全变成了凉凉的雾，像天在哈气 | a ten-minute desert shower became cool mist before touching the ground |
| inc_sm_06 | 插曲 | 集市里学舌的八哥用你的语气喊了一声我的名字 | a market mynah called my name in exactly your voice |
| inc_sm_07 | 插曲 | 热气球的沙袋松了一只，我抱住它当压舱物，因此免票升空一圈 | I hugged a loose balloon sandbag and received one free flight as ballast |
| inc_sm_08 | 插曲 | 观星老人指的第一颗星，和我昨晚许愿的是同一颗 | the first star the old astronomer pointed to was the one I wished on last night |
| inc_jd_01 | 插曲 | 极光今晚绿得发亮，全村的狗（加我）对着天空合唱了一首 | the aurora glowed so brightly that every village dog, including me, sang to it |
| inc_jd_02 | 插曲 | 在冰面上没刹住，一路滑进了海豹的贴贴堆，被迫（幸福地）加入 | I slid into a seal cuddle pile and was reluctantly, happily accepted |
| inc_jd_03 | 插曲 | 我呵出的白气和汽船的汽笛烟在空中撞了个满怀 | my breath cloud and the steamboat whistle met in midair |
| inc_jd_04 | 插曲 | 浮冰把我睡着时载到了灯塔正下方，灯光罩了我一整夜 | an ice floe carried me beneath the lighthouse, where its beam covered me all night |
| inc_jd_05 | 插曲 | 舔了一下结冰的栏杆（不要学），守夜人用温水把我「解救」下来 | I licked a frozen rail and the keeper rescued me with warm water |
| inc_jd_06 | 插曲 | 渔村今晚每家的烟囱都在冒烟，雪地被窗光烙满了一格一格的暖黄 | window light stamped the snowy village in neat squares of warm gold |
| inc_jd_07 | 插曲 | 蓝洞的水把我的影子染成了透明的蓝色，像借给我一件新大衣 | the blue spring dressed my reflection in a transparent blue coat |
| inc_qh_01 | 插曲 | 一朵云羊蹭了蹭我，在我背上留下一小片下小雨的云 | a cloud sheep brushed past and left a tiny raining cloud on my back |
| inc_qh_02 | 插曲 | 会走路的岛打了个喷嚏，全岛的帽子（包括我的）飞上天又各回各头 | the walking island sneezed, tossing every hat skyward and back onto the right head |
| inc_qh_03 | 插曲 | 月亮邮局的失物招领里，有一枚和院子门牌同号的旧邮戳 | the moon post office had an old postmark bearing the garden gate's number |
| inc_qh_04 | 插曲 | 糖霜火山喷了一场「甜雪」，落在舌头上是{season}水果的味道 | Frosting Volcano sent down sweet snow flavored like {season} fruit |
| inc_qh_05 | 插曲 | 守护灵说我念叨的那个名字，它好像在很多封信上见过 | the guardian spirit had seen the name I keep saying on many other letters |

## 10. 来客互动

> `{Pet Name}` 会在运行时替换成玩家给宠物取的名字。

| 互动 ID | 来客 | 物种 | 中文 | English Runtime Copy |
| --- | --- | --- | --- | --- |
| vi_sparrow_cat | Chirpy the Sparrow | Orange Tabby | 阿橘尾巴拍了三下，最终决定……继续睡。啾啾在它肚皮上开了演唱会 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They answered with three slow tail taps and a contented blink. |
| vi_sparrow_shiba | Chirpy the Sparrow | Shiba Inu | 啾啾落在柴犬头顶当瞭望塔，柴犬以为自己升职了，一下午走路都端端正正 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They stood proudly on lookout, taking the visit very seriously. |
| vi_sparrow_rabbit | Chirpy the Sparrow | Lop Rabbit | 雪团躲在草丛里偷看啾啾洗沙浴，看完自己也学着抖了抖耳朵，扬起一小团金色的灰 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They listened with both long ears loose and peaceful. |
| vi_sparrow_hamster | Chirpy the Sparrow | Hamster | 啾啾啄走了仓鼠晒在门口的一粒谷子，仓鼠追出两步，想想腮帮里还有存货，算了 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They offered one carefully saved crumb from their secret stash. |
| vi_sparrow_turtle | Chirpy the Sparrow | Tortoise | 啾啾把乌龟的背当成了会移动的观景台，一龟一雀慢悠悠环院一周，比散步还慢 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They made room on the warmest stone and stayed for company. |
| vi_sparrow_parrot | Chirpy the Sparrow | Parrot | 两只鸟用你听不懂的话聊了一下午。皮皮还学会了一句新方言；它们显然都懂，你没有。 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They tried out a brand-new greeting until everyone recognized it. |
| vi_sparrow_snake | Chirpy the Sparrow | Corn Snake | 啾啾在安全距离外歪头研究这条「会动的树枝」，玉米蛇高冷地蜕了半寸皮以示回应 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They curled into a polite comma and listened without interrupting. |
| vi_sparrow_chameleon | Chirpy the Sparrow | Chameleon | 阿彩把自己变成麻雀色想混进对话，啾啾绕着它跳了一圈，礼貌地没有拆穿 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They changed into the gentlest welcome color they could find. |
| vi_sparrow_ember | Chirpy the Sparrow | Emberling | 啾啾在小火龙尾巴的暖光旁烘蓬松了羽毛，走时留下一根亮闪闪的小灰羽当谢礼 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They kept one tiny flame glowing warmly between them. |
| vi_sparrow_uni | Chirpy the Sparrow | Niko the Uni-Rabbit | 啾啾站上尼可的小角尖梳羽毛，尼可僵着脖子一动不敢动，像顶着全世界最轻的王冠 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They left a faint rainbow shimmer over the visitor's path. |
| vi_sparrow_boo | Chirpy the Sparrow | Boo the Little Ghost | 啾啾径直从噗噗身体里穿了过去，愣了两秒，决定当作今天风有点凉 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They floated close enough to be friendly and calmly enough not to startle. |
| vi_sparrow_starbug | Chirpy the Sparrow | Starbug | 啾啾把星星虫认成了掉在地上的星星，围着它蹦了一圈，最后郑重地鞠了一躬 | Chirpy the Sparrow sang a tiny fence-top concert for the afternoon. They blinked in time until the garden seemed full of scattered stars. |
| vi_calico_cat | Wandering Calico | Orange Tabby | 两只猫背对背各晒各的太阳，中间隔着一掌宽的「江湖规矩」，谁也没先开口 | Wandering Calico shared the warmest patch of sunlight without a fuss. They answered with three slow tail taps and a contented blink. |
| vi_calico_shiba | Wandering Calico | Shiba Inu | 柴犬热情冲上去交朋友，三花猫一记眼神让它急刹车，改成原地摇尾巴问好 | Wandering Calico shared the warmest patch of sunlight without a fuss. They stood proudly on lookout, taking the visit very seriously. |
| vi_calico_rabbit | Wandering Calico | Lop Rabbit | 三花猫蹲在篱笆上守了雪团一下午，像个不肯承认自己在当保镖的保镖 | Wandering Calico shared the warmest patch of sunlight without a fuss. They listened with both long ears loose and peaceful. |
| vi_calico_hamster | Wandering Calico | Hamster | 仓鼠鼓着腮帮从三花猫面前大摇大摆走过，猫爪抬了抬，最终选择了尊重勇者 | Wandering Calico shared the warmest patch of sunlight without a fuss. They offered one carefully saved crumb from their secret stash. |
| vi_calico_turtle | Wandering Calico | Tortoise | 三花猫伸爪轻拍龟壳，咚咚两声，像敲了一扇没人应门的老房子，它便在门口卧下了 | Wandering Calico shared the warmest patch of sunlight without a fuss. They made room on the warmest stone and stayed for company. |
| vi_calico_parrot | Wandering Calico | Parrot | 皮皮学了一声完美的猫叫，三花猫环顾四周找了半天「同类」，尾巴尖写满困惑 | Wandering Calico shared the warmest patch of sunlight without a fuss. They tried out a brand-new greeting until everyone recognized it. |
| vi_calico_snake | Wandering Calico | Corn Snake | 流浪惯了的猫见过世面，与玉米蛇隔着石板互相点头，两位独行侠达成沉默的停战协议 | Wandering Calico shared the warmest patch of sunlight without a fuss. They curled into a polite comma and listened without interrupting. |
| vi_calico_chameleon | Wandering Calico | Chameleon | 阿彩慢慢变成三花配色以表友好，三花猫盯着这面「猫镜子」，破天荒喵了一声 | Wandering Calico shared the warmest patch of sunlight without a fuss. They changed into the gentlest welcome color they could find. |
| vi_calico_ember | Wandering Calico | Emberling | 雨夜的三花猫凑在小火龙身边取暖，火苗特意压低了一点，怕燎着客人的胡子 | Wandering Calico shared the warmest patch of sunlight without a fuss. They kept one tiny flame glowing warmly between them. |
| vi_calico_uni | Wandering Calico | Niko the Uni-Rabbit | 三花猫追着尼可角尖洒落的小彩光扑了一路，久违地玩成了一只小猫 | Wandering Calico shared the warmest patch of sunlight without a fuss. They left a faint rainbow shimmer over the visitor's path. |
| vi_calico_boo | Wandering Calico | Boo the Little Ghost | 三花猫是院子里唯一能一眼看见噗噗的客人，它冲着「空气」慢慢眨了眨眼 | Wandering Calico shared the warmest patch of sunlight without a fuss. They floated close enough to be friendly and calmly enough not to startle. |
| vi_calico_starbug | Wandering Calico | Starbug | 三花猫把星星虫小心地衔到高处的花盆沿，好让这颗「星星」离天空更近一点 | Wandering Calico shared the warmest patch of sunlight without a fuss. They blinked in time until the garden seemed full of scattered stars. |
| vi_snail_cat | Slow-Mail Snail | Orange Tabby | 蜗牛递送一片叶子信用了两小时，阿橘睡了两觉醒来，签收时假装自己等了很久 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They answered with three slow tail taps and a contented blink. |
| vi_snail_shiba | Slow-Mail Snail | Shiba Inu | 柴犬绕着蜗牛跑了三十圈想帮它「加速」，蜗牛在风里坚定地前进了三厘米 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They stood proudly on lookout, taking the visit very seriously. |
| vi_snail_rabbit | Slow-Mail Snail | Lop Rabbit | 雪团收到蜗牛慢递的三叶草，慢递签收方式是：当场吃掉，五星好评 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They listened with both long ears loose and peaceful. |
| vi_snail_hamster | Slow-Mail Snail | Hamster | 仓鼠想把蜗牛的壳也收进囤货清单，反复确认后遗憾地发现里面「已有住户」 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They offered one carefully saved crumb from their secret stash. |
| vi_snail_turtle | Slow-Mail Snail | Tortoise | 两位慢家伙并排走完一段石板路，用了一下午，聊了很多，谁也没催谁 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They made room on the warmest stone and stayed for company. |
| vi_snail_parrot | Slow-Mail Snail | Parrot | 皮皮全程实况转播蜗牛的行进：「向左！向左！停！」蜗牛的路线毫无变化 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They tried out a brand-new greeting until everyone recognized it. |
| vi_snail_snake | Slow-Mail Snail | Corn Snake | 玉米蛇给蜗牛让出一条最平坦的晒石小道，全程冷脸，但尾巴尖悄悄指了路 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They curled into a polite comma and listened without interrupting. |
| vi_snail_chameleon | Slow-Mail Snail | Chameleon | 阿彩陪蜗牛以相同的速度走了一路，这是它这辈子第一次觉得自己「太快了」 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They changed into the gentlest welcome color they could find. |
| vi_snail_ember | Slow-Mail Snail | Emberling | 蜗牛托小火龙帮忙烘干被露水打湿的信纸，火候拿捏得像一台温柔的小烤箱 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They kept one tiny flame glowing warmly between them. |
| vi_snail_uni | Slow-Mail Snail | Niko the Uni-Rabbit | 蜗牛爬过的地方留下一道银线，尼可用角尖的微光把它照成了一条小小的彩虹路 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They left a faint rainbow shimmer over the visitor's path. |
| vi_snail_boo | Slow-Mail Snail | Boo the Little Ghost | 噗噗飘在蜗牛头顶帮它挡了一路太阳，蜗牛以为今天是个自带阴凉的好天气 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They floated close enough to be friendly and calmly enough not to startle. |
| vi_snail_starbug | Slow-Mail Snail | Starbug | 星星虫趴在蜗牛壳顶当车灯，夜里的院子多了一辆最慢的、发着光的小车 | Slow-Mail Snail delivered a leaf-sized note at an admirably careful pace. They blinked in time until the garden seemed full of scattered stars. |
| vi_butterfly_cat | Cabbage White | Orange Tabby | 白粉蝶停在阿橘鼻尖，猫眼慢慢对成了斗鸡眼，为了不打扰客人硬是没打喷嚏 | Cabbage White rested nearby while its pale wings opened and closed. They answered with three slow tail taps and a contented blink. |
| vi_butterfly_shiba | Cabbage White | Shiba Inu | 柴犬追着白粉蝶满院扑蝶，一次没够着，却快乐得像赢了全世界 | Cabbage White rested nearby while its pale wings opened and closed. They stood proudly on lookout, taking the visit very seriously. |
| vi_butterfly_rabbit | Cabbage White | Lop Rabbit | 白粉蝶落在雪团的垂耳上歇脚，雪团把耳朵举得又低又稳，像端着一杯不敢洒的水 | Cabbage White rested nearby while its pale wings opened and closed. They listened with both long ears loose and peaceful. |
| vi_butterfly_hamster | Cabbage White | Hamster | 白粉蝶围着仓鼠塞满的腮帮绕了两圈，误认成两朵会跑的花苞 | Cabbage White rested nearby while its pale wings opened and closed. They offered one carefully saved crumb from their secret stash. |
| vi_butterfly_turtle | Cabbage White | Tortoise | 白粉蝶在龟壳上停了整整一刻钟，乌龟一动不动——这是它能给的最盛大的欢迎 | Cabbage White rested nearby while its pale wings opened and closed. They made room on the warmest stone and stayed for company. |
| vi_butterfly_parrot | Cabbage White | Parrot | 皮皮想跟白粉蝶学「无声地说话」，练了一下午，失败，但翅膀晃得挺像样 | Cabbage White rested nearby while its pale wings opened and closed. They tried out a brand-new greeting until everyone recognized it. |
| vi_butterfly_snake | Cabbage White | Corn Snake | 白粉蝶轻轻落在玉米蛇新蜕的皮上，像给一封告别信盖了一枚白色的邮戳 | Cabbage White rested nearby while its pale wings opened and closed. They curled into a polite comma and listened without interrupting. |
| vi_butterfly_chameleon | Cabbage White | Chameleon | 阿彩变成花朵色安静等待，白粉蝶真的落了下来——伪装大师今天是一朵得意的花 | Cabbage White rested nearby while its pale wings opened and closed. They changed into the gentlest welcome color they could find. |
| vi_butterfly_ember | Cabbage White | Emberling | 白粉蝶绕着小火龙的暖光跳了一支缓慢的圆舞曲，火苗晃啊晃，成了追光灯 | Cabbage White rested nearby while its pale wings opened and closed. They kept one tiny flame glowing warmly between them. |
| vi_butterfly_uni | Cabbage White | Niko the Uni-Rabbit | 白粉蝶与尼可在花丛里捉迷藏，白色找白色，最后靠角尖那点彩光分出了彼此 | Cabbage White rested nearby while its pale wings opened and closed. They left a faint rainbow shimmer over the visitor's path. |
| vi_butterfly_boo | Cabbage White | Boo the Little Ghost | 白粉蝶穿过噗噗的身体又折回来穿了一次，噗噗痒得在半空打了个透明的滚 | Cabbage White rested nearby while its pale wings opened and closed. They floated close enough to be friendly and calmly enough not to startle. |
| vi_butterfly_starbug | Cabbage White | Starbug | 白天的星星虫不发光，白粉蝶陪它坐在草叶上，像两枚安静的白色标点 | Cabbage White rested nearby while its pale wings opened and closed. They blinked in time until the garden seemed full of scattered stars. |
| vi_hedgehog_cat | Pip the Hedgehog | Orange Tabby | 阿橘伸爪碰了碰球球，扎了一下，从此对这颗「会走的松果」保持礼貌的敬意 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They answered with three slow tail taps and a contented blink. |
| vi_hedgehog_shiba | Pip the Hedgehog | Shiba Inu | 柴犬叼来自己最爱的球想跟球球一起玩，摆在一起认真比对：确实，很像 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They stood proudly on lookout, taking the visit very seriously. |
| vi_hedgehog_rabbit | Pip the Hedgehog | Lop Rabbit | 雪团小心地把苹果片推过去，球球回赠了一片不扎人的落叶 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They listened with both long ears loose and peaceful. |
| vi_hedgehog_hamster | Pip the Hedgehog | Hamster | 球球背上扎着果子路过，仓鼠肃然起敬：原来还能把仓库背在身上 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They offered one carefully saved crumb from their secret stash. |
| vi_hedgehog_turtle | Pip the Hedgehog | Tortoise | 一个缩壳一个缩球，两团「打不开的小包裹」并排晒太阳，安全感翻倍 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They made room on the warmest stone and stayed for company. |
| vi_hedgehog_parrot | Pip the Hedgehog | Parrot | 皮皮数球球背上的刺数到一百就乱了，宣布：「反正很多！非常多！」 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They tried out a brand-new greeting until everyone recognized it. |
| vi_hedgehog_snake | Pip the Hedgehog | Corn Snake | 玉米蛇绕着球球巡视一圈，确认这团刺球毫无破绽，冷冷地给出了认可的点头 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They curled into a polite comma and listened without interrupting. |
| vi_hedgehog_chameleon | Pip the Hedgehog | Chameleon | 阿彩尝试变出刺的纹理失败，只变出了圆点花纹，球球看起来还挺喜欢 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They changed into the gentlest welcome color they could find. |
| vi_hedgehog_ember | Pip the Hedgehog | Emberling | 球球在小火龙旁边烤暖了肚皮，睡着后轻轻打鼾，刺都放松得塌下去一点 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They kept one tiny flame glowing warmly between them. |
| vi_hedgehog_uni | Pip the Hedgehog | Niko the Uni-Rabbit | 尼可用角尖帮球球取下背上挂了一路的苹果片，全院最尖的两个尖尖达成合作 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They left a faint rainbow shimmer over the visitor's path. |
| vi_hedgehog_boo | Pip the Hedgehog | Boo the Little Ghost | 噗噗好奇地抱了一下球球——幸好幽灵不怕扎，这是球球第一个敢抱它的朋友 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They floated close enough to be friendly and calmly enough not to startle. |
| vi_hedgehog_starbug | Pip the Hedgehog | Starbug | 夜里球球背上落了颗发光的星星虫，它一路小心地走，像运送一盏易碎的灯 | Pip the Hedgehog rolled in with a pocketful of leaves and good manners. They blinked in time until the garden seemed full of scattered stars. |
| vi_pigeon_cat | Coo the Pigeon | Orange Tabby | 咕咕在阿橘面前踱步找食，步伐胖而坦荡，阿橘看着看着竟跟着点起了头 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They answered with three slow tail taps and a contented blink. |
| vi_pigeon_shiba | Coo the Pigeon | Shiba Inu | 柴犬和咕咕面对面歪头，谁也没搞懂对方，但都觉得今天交到了朋友 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They stood proudly on lookout, taking the visit very seriously. |
| vi_pigeon_rabbit | Coo the Pigeon | Lop Rabbit | 咕咕落地的扑腾声吓得雪团缩进纸箱，十分钟后两只从箱子两侧同时探出头 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They listened with both long ears loose and peaceful. |
| vi_pigeon_hamster | Coo the Pigeon | Hamster | 咕咕啄食掉在地上的谷粒，仓鼠在一旁记账似的盯着，最后大方地又推出去三粒 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They offered one carefully saved crumb from their secret stash. |
| vi_pigeon_turtle | Coo the Pigeon | Tortoise | 咕咕在乌龟旁边咕咕哝哝讲了一下午城里见闻，乌龟每隔十分钟点一次头 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They made room on the warmest stone and stayed for company. |
| vi_pigeon_parrot | Coo the Pigeon | Parrot | 皮皮完美复刻了「咕咕」，咕咕震惊回头，两只鸟就此展开一场真假咕咕辩论 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They tried out a brand-new greeting until everyone recognized it. |
| vi_pigeon_snake | Coo the Pigeon | Corn Snake | 咕咕胖胖的影子从玉米蛇的晒石上掠过，蛇抬头看了一眼，为那份从容让了半块石头 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They curled into a polite comma and listened without interrupting. |
| vi_pigeon_chameleon | Coo the Pigeon | Chameleon | 阿彩变成鸽灰色混进咕咕的觅食路线，被识破后咕咕多分了它一粒谷子当封口费 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They changed into the gentlest welcome color they could find. |
| vi_pigeon_ember | Coo the Pigeon | Emberling | 咕咕站在小火龙旁烘干淋湿的翅膀，蒸汽袅袅，像一只刚出锅的包子 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They kept one tiny flame glowing warmly between them. |
| vi_pigeon_uni | Coo the Pigeon | Niko the Uni-Rabbit | 咕咕绕着尼可走了三圈，最终认定这是一只「头上长了树枝的白鸽子」，倍感亲切 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They left a faint rainbow shimmer over the visitor's path. |
| vi_pigeon_boo | Coo the Pigeon | Boo the Little Ghost | 咕咕在噗噗常待的角落留下一根羽毛，不知是掉的还是送的，噗噗决定当作是送的 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They floated close enough to be friendly and calmly enough not to startle. |
| vi_pigeon_starbug | Coo the Pigeon | Starbug | 咕咕以为星星虫是面包屑，凑近一看在发光，吓得倒退三步，又忍不住凑回来 | Coo the Pigeon cooed the latest rooftop news in a very official tone. They blinked in time until the garden seemed full of scattered stars. |
| vpi_squirrel_cat | Chestnut the Squirrel | Orange Tabby | 栗栗在树上抱着松果观望，阿橘在树下抱着饭碗观望，双方就「谁的抱姿更标准」对峙一下午 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They answered with three slow tail taps and a contented blink. |
| vpi_squirrel_shiba | Chestnut the Squirrel | Shiba Inu | 栗栗把松果埋进花坛，柴犬热心地当场刨出来还给它，如此往复五次，双方都很充实 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They stood proudly on lookout, taking the visit very seriously. |
| vpi_squirrel_rabbit | Chestnut the Squirrel | Lop Rabbit | 栗栗分给雪团半颗榛子，雪团回赠一根胡萝卜缨，这场以物易物在紧张的鼻子抽动中圆满成交 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They listened with both long ears loose and peaceful. |
| vpi_squirrel_hamster | Chestnut the Squirrel | Hamster | 一场郑重其事的囤货交流会：栗栗展示树洞里的橡果，仓鼠摊开藏粮，最后互相交换了最舍不得的一小份。 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They offered one carefully saved crumb from their secret stash. |
| vpi_squirrel_turtle | Chestnut the Squirrel | Tortoise | 栗栗把一颗松果寄存在龟壳旁，「这里最安全」，乌龟就此多了一份看守的工作与骄傲 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They made room on the warmest stone and stayed for company. |
| vpi_squirrel_parrot | Chestnut the Squirrel | Parrot | 皮皮把栗栗埋松果的位置一一大声播报，栗栗抱头：院子里从此没有秘密 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They tried out a brand-new greeting until everyone recognized it. |
| vpi_squirrel_snake | Chestnut the Squirrel | Corn Snake | 栗栗在树枝上、玉米蛇在石头上，两条蓬松与不蓬松的尾巴隔空摆出了同一个弧度 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They curled into a polite comma and listened without interrupting. |
| vpi_squirrel_chameleon | Chestnut the Squirrel | Chameleon | 阿彩变成树皮色贴在树干上，栗栗差点把松果塞进它嘴里当树洞 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They changed into the gentlest welcome color they could find. |
| vpi_squirrel_ember | Chestnut the Squirrel | Emberling | 栗栗把一颗松果放在小火龙面前烤，烤出满院清香，两只分食了这颗冬日限定爆米花 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They kept one tiny flame glowing warmly between them. |
| vpi_squirrel_uni | Chestnut the Squirrel | Niko the Uni-Rabbit | 栗栗蹲在枝头看尼可，看了很久，然后把今年最饱满的一颗榛子丢在了它脚边 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They left a faint rainbow shimmer over the visitor's path. |
| vpi_squirrel_boo | Chestnut the Squirrel | Boo the Little Ghost | 栗栗的松果凭空飘了起来——噗噗只是想帮忙搬运，栗栗尖叫着追了半个院子 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_squirrel_starbug | Chestnut the Squirrel | Starbug | 栗栗把星星虫小心地捧进树洞躲雨，那晚整棵树的心里都是亮的 | Chestnut the Squirrel brought one polished acorn and a dozen quick stories. They blinked in time until the garden seemed full of scattered stars. |
| vpi_crow_cat | Shiny the Crow | Orange Tabby | 亮亮盯上了阿橘饭碗的金属反光，一鸟一猫围着碗展开了一场谁也不动手的心理战 | Shiny the Crow showed off a bright button found beyond the fence. They answered with three slow tail taps and a contented blink. |
| vpi_crow_shiba | Shiny the Crow | Shiba Inu | 亮亮叼走了柴犬的铃铛玩具，柴犬追讨半天，最后换回一枚瓶盖，双方都觉得自己赚了 | Shiny the Crow showed off a bright button found beyond the fence. They stood proudly on lookout, taking the visit very seriously. |
| vpi_crow_rabbit | Shiny the Crow | Lop Rabbit | 亮亮送给雪团一颗亮晶晶的玻璃扣子，雪团吓得躲开又忍不住回来，最后收进了草窝 | Shiny the Crow showed off a bright button found beyond the fence. They listened with both long ears loose and peaceful. |
| vpi_crow_hamster | Shiny the Crow | Hamster | 两位收集家见面：亮亮展示瓶盖珍藏，仓鼠摊开存粮。它们互相没有看懂，却都郑重点头。 | Shiny the Crow showed off a bright button found beyond the fence. They offered one carefully saved crumb from their secret stash. |
| vpi_crow_turtle | Shiny the Crow | Tortoise | 亮亮把一枚亮片摆在龟壳正中央，退后打量：嗯，全院最稳的展示台 | Shiny the Crow showed off a bright button found beyond the fence. They made room on the warmest stone and stayed for company. |
| vpi_crow_parrot | Shiny the Crow | Parrot | 亮亮和皮皮互相炫耀藏品与词汇量，一个越摆越多，一个越说越快，不欢而散又相约明天 | Shiny the Crow showed off a bright button found beyond the fence. They tried out a brand-new greeting until everyone recognized it. |
| vpi_crow_snake | Shiny the Crow | Corn Snake | 亮亮被玉米蛇蜕下的旧皮迷住了——那可是一整条闪光的绸带，蛇难得大方：拿去 | Shiny the Crow showed off a bright button found beyond the fence. They curled into a polite comma and listened without interrupting. |
| vpi_crow_chameleon | Shiny the Crow | Chameleon | 亮亮带来一颗玻璃珠，变色龙把自己变成同样的颜色作为答谢。亮亮绕着看了三圈，才郑重点头。 | Shiny the Crow showed off a bright button found beyond the fence. They changed into the gentlest welcome color they could find. |
| vpi_crow_ember | Shiny the Crow | Emberling | 亮亮着迷于小火龙尾巴上「叼不走的光」，试探三次未遂，遗憾地记进了愿望清单 | Shiny the Crow showed off a bright button found beyond the fence. They kept one tiny flame glowing warmly between them. |
| vpi_crow_uni | Shiny the Crow | Niko the Uni-Rabbit | 亮亮围着尼可的角绕飞三圈，确认这是全院最大的「亮东西」，郑重献上了自己最好的瓶盖 | Shiny the Crow showed off a bright button found beyond the fence. They left a faint rainbow shimmer over the visitor's path. |
| vpi_crow_boo | Shiny the Crow | Boo the Little Ghost | 亮亮的藏品夜里被摆成了一个爱心形状，它警惕地环顾四周，又悄悄把爱心摆得更圆了 | Shiny the Crow showed off a bright button found beyond the fence. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_crow_starbug | Shiny the Crow | Starbug | 亮亮盯着星星虫纠结了一夜：会发光的收藏品，和会发光的朋友，最后它选了朋友 | Shiny the Crow showed off a bright button found beyond the fence. They blinked in time until the garden seemed full of scattered stars. |
| vpi_frog_cat | Ribbit the Frog | Orange Tabby | 呱太一声「呱」把打盹的阿橘弹起三寸高，随后两位在屋檐下达成了雨天互不吵醒条约 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They answered with three slow tail taps and a contented blink. |
| vpi_frog_shiba | Ribbit the Frog | Shiba Inu | 柴犬学呱太跳水坑，溅了自己一身泥，呱太给这记入水姿势打出了满分 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They stood proudly on lookout, taking the visit very seriously. |
| vpi_frog_rabbit | Ribbit the Frog | Lop Rabbit | 雪团在窗边看呱太淋雨，担心地把自己的干草往外推了推，呱太表示青蛙淋雨是福利 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They listened with both long ears loose and peaceful. |
| vpi_frog_hamster | Ribbit the Frog | Hamster | 呱太邀请仓鼠欣赏雨景，仓鼠忙着把淋湿的存粮搬进屋，来回跑了十七趟 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They offered one carefully saved crumb from their secret stash. |
| vpi_frog_turtle | Ribbit the Frog | Tortoise | 池塘边的静坐比赛持续了整整一个下午。你宣布并列第一，它们谁也没有挪动。 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They made room on the warmest stone and stayed for company. |
| vpi_frog_parrot | Ribbit the Frog | Parrot | 皮皮跟着呱太练合唱，一句「呱」学得字正腔圆，从此雨天院子里有两台青蛙广播 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They tried out a brand-new greeting until everyone recognized it. |
| vpi_frog_snake | Ribbit the Frog | Corn Snake | 呱太与玉米蛇在雨里对视良久——自然界的老规矩在此暂停，今天大家只是躲雨的邻居 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They curled into a polite comma and listened without interrupting. |
| vpi_frog_chameleon | Ribbit the Frog | Chameleon | 阿彩变成荷叶色蹲在池塘边，呱太毫不客气地跳上来歇脚，把它当成了公共设施 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They changed into the gentlest welcome color they could find. |
| vpi_frog_ember | Ribbit the Frog | Emberling | 呱太隔着雨帘远远欣赏小火龙檐下的暖光，一个爱雨一个怕雨，却共享了同一个屋檐 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They kept one tiny flame glowing warmly between them. |
| vpi_frog_uni | Ribbit the Frog | Niko the Uni-Rabbit | 雨停时呱太带尼可去看池塘里倒映的彩虹，「水里那条不会消失得那么快。」 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They left a faint rainbow shimmer over the visitor's path. |
| vpi_frog_boo | Ribbit the Frog | Boo the Little Ghost | 呱太在雨里唱，噗噗在檐下轻轻晃，一场只有他们俩听得懂的雨夜音乐会 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_frog_starbug | Ribbit the Frog | Starbug | 呱太守在叶子下替怕雨的星星虫撑了一夜「蛙形伞」，天晴时肩膀都蹲麻了 | Ribbit the Frog kept time with the water bowl in a soft evening rhythm. They blinked in time until the garden seemed full of scattered stars. |
| vpi_fireflies_cat | Firefly Parade | Orange Tabby | 萤火虫群绕着阿橘的尾巴打转，它拍了两下没拍着，索性躺平当了夜灯底座 | Firefly Parade turned the grass into a path of slow, floating lights. They answered with three slow tail taps and a contented blink. |
| vpi_fireflies_shiba | Firefly Parade | Shiba Inu | 柴犬追着光点满院子跑，萤火虫们轮班逗它，最后它对着夜空汪了一声表示尽兴 | Firefly Parade turned the grass into a path of slow, floating lights. They stood proudly on lookout, taking the visit very seriously. |
| vpi_fireflies_rabbit | Firefly Parade | Lop Rabbit | 萤火虫在雪团的耳朵边排成一圈小灯，胆小的兔子第一次觉得黑夜也可以很亮 | Firefly Parade turned the grass into a path of slow, floating lights. They listened with both long ears loose and peaceful. |
| vpi_fireflies_hamster | Firefly Parade | Hamster | 仓鼠试图把一只萤火虫塞进腮帮当手电筒，被你温柔制止，改为提着草叶灯笼巡逻 | Firefly Parade turned the grass into a path of slow, floating lights. They offered one carefully saved crumb from their secret stash. |
| vpi_fireflies_turtle | Firefly Parade | Tortoise | 萤火虫们停满龟壳，乌龟驮着一整片星空，走完了今晚最慢也最亮的一段路 | Firefly Parade turned the grass into a path of slow, floating lights. They made room on the warmest stone and stayed for company. |
| vpi_fireflies_parrot | Firefly Parade | Parrot | 皮皮想跟萤火虫学「闪光语」，学不会，急得直跳脚：「你们倒是出个声啊！」 | Firefly Parade turned the grass into a path of slow, floating lights. They tried out a brand-new greeting until everyone recognized it. |
| vpi_fireflies_snake | Firefly Parade | Corn Snake | 玉米蛇盘成一圈，萤火虫恰好落成一环光带，那晚它成了院子里一枚发光的戒指 | Firefly Parade turned the grass into a path of slow, floating lights. They curled into a polite comma and listened without interrupting. |
| vpi_fireflies_chameleon | Firefly Parade | Chameleon | 阿彩努力想「变亮」失败，萤火虫们体贴地停在它背上，帮它圆了一次梦 | Firefly Parade turned the grass into a path of slow, floating lights. They changed into the gentlest welcome color they could find. |
| vpi_fireflies_ember | Firefly Parade | Emberling | 萤火虫群围着小火龙的尾巴光转圈，像小灯来朝见大灯，火苗害羞地压低了两分 | Firefly Parade turned the grass into a path of slow, floating lights. They kept one tiny flame glowing warmly between them. |
| vpi_fireflies_uni | Firefly Parade | Niko the Uni-Rabbit | 萤火虫的光落在尼可的角上折出细碎的虹色，整个院子安静得像屏住了呼吸 | Firefly Parade turned the grass into a path of slow, floating lights. They left a faint rainbow shimmer over the visitor's path. |
| vpi_fireflies_boo | Firefly Parade | Boo the Little Ghost | 噗噗混进萤火虫群一起飘，唯一破绽是它不会发光，萤火虫们默契地把它围在中间 | Firefly Parade turned the grass into a path of slow, floating lights. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_fireflies_starbug | Firefly Parade | Starbug | 萤火虫群围着星星虫盘旋致意——绿色的小灯们，见到了传说中金色的那一盏 | Firefly Parade turned the grass into a path of slow, floating lights. They blinked in time until the garden seemed full of scattered stars. |
| vpi_tanuki_cat | Ginger Tanuki | Orange Tabby | 橘色狸猫和橘猫在院里撞了个满怀，毛色一致，圆度相当，你差点认错了自家孩子 | Ginger Tanuki settled beside the gate as though this were an old stop. They answered with three slow tail taps and a contented blink. |
| vpi_tanuki_shiba | Ginger Tanuki | Shiba Inu | 柴犬对狸猫肚子的圆润程度表达了真诚的羡慕，狸猫回赠了拍肚皮教学一节 | Ginger Tanuki settled beside the gate as though this were an old stop. They stood proudly on lookout, taking the visit very seriously. |
| vpi_tanuki_rabbit | Ginger Tanuki | Lop Rabbit | 狸猫变戏法似的从背后摸出一片叶子送给雪团，雪团犹豫三秒，咔嚓吃了 | Ginger Tanuki settled beside the gate as though this were an old stop. They listened with both long ears loose and peaceful. |
| vpi_tanuki_hamster | Ginger Tanuki | Hamster | 狸猫和仓鼠比赛「谁能显得更圆」，两团毛球在草地上滚作一处，不分胜负 | Ginger Tanuki settled beside the gate as though this were an old stop. They offered one carefully saved crumb from their secret stash. |
| vpi_tanuki_turtle | Ginger Tanuki | Tortoise | 狸猫用叶子给乌龟变了顶小帽子，乌龟戴着它慢慢走了一下午，谁也没舍得摘 | Ginger Tanuki settled beside the gate as though this were an old stop. They made room on the warmest stone and stayed for company. |
| vpi_tanuki_parrot | Ginger Tanuki | Parrot | 皮皮揭穿了狸猫「叶子变金币」的戏法，狸猫恼羞成怒，又变了一片更大的叶子 | Ginger Tanuki settled beside the gate as though this were an old stop. They tried out a brand-new greeting until everyone recognized it. |
| vpi_tanuki_snake | Ginger Tanuki | Corn Snake | 狸猫想跟玉米蛇比谁更会「装成别的东西」，蛇盘成一坨绳子，狸猫心服口服 | Ginger Tanuki settled beside the gate as though this were an old stop. They curled into a polite comma and listened without interrupting. |
| vpi_tanuki_chameleon | Ginger Tanuki | Chameleon | 变装大师会晤：阿彩变了色，狸猫变了形，互相鞠躬致敬，切磋择日再约 | Ginger Tanuki settled beside the gate as though this were an old stop. They changed into the gentlest welcome color they could find. |
| vpi_tanuki_ember | Ginger Tanuki | Emberling | 狸猫围着小火龙转了三圈，试图用叶子扇旺那簇火，被你及时拦下这位热心过头的客人 | Ginger Tanuki settled beside the gate as though this were an old stop. They kept one tiny flame glowing warmly between them. |
| vpi_tanuki_uni | Ginger Tanuki | Niko the Uni-Rabbit | 狸猫盯着尼可看了很久，小声嘀咕「这个变身……我学不来」，留下一片叶子当学费 | Ginger Tanuki settled beside the gate as though this were an old stop. They left a faint rainbow shimmer over the visitor's path. |
| vpi_tanuki_boo | Ginger Tanuki | Boo the Little Ghost | 狸猫察觉院里有个「看不见的家伙」，不慌不忙变出第二条影子陪噗噗玩了一晚 | Ginger Tanuki settled beside the gate as though this were an old stop. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_tanuki_starbug | Ginger Tanuki | Starbug | 狸猫想用叶子变一颗一样亮的星星，失败了，星星虫爬上叶子替它把戏法圆上了 | Ginger Tanuki settled beside the gate as though this were an old stop. They blinked in time until the garden seemed full of scattered stars. |
| vpi_egret_cat | Mr. Egret | Orange Tabby | 白鹭先生单腿立在池塘边一动不动，阿橘学着单爪支起下巴，坚持了四秒，睡着了 | Mr. Egret stood quietly by the water and made the garden feel still. They answered with three slow tail taps and a contented blink. |
| vpi_egret_shiba | Mr. Egret | Shiba Inu | 柴犬围着白鹭先生转圈表达仰慕，白鹭先生颔首致意，气质差距肉眼可见但友谊成立 | Mr. Egret stood quietly by the water and made the garden feel still. They stood proudly on lookout, taking the visit very seriously. |
| vpi_egret_rabbit | Mr. Egret | Lop Rabbit | 白鹭先生俯身与雪团平视，长脖子弯成一道温柔的桥，胆小的兔子破例没有后退 | Mr. Egret stood quietly by the water and made the garden feel still. They listened with both long ears loose and peaceful. |
| vpi_egret_hamster | Mr. Egret | Hamster | 仓鼠向白鹭先生展示存粮，白鹭先生认真参观完毕，赠言：「囤积有度，方为长久。」 | Mr. Egret stood quietly by the water and made the garden feel still. They offered one carefully saved crumb from their secret stash. |
| vpi_egret_turtle | Mr. Egret | Tortoise | 白鹭先生与乌龟在池塘边共处一下午，一个立着不动，一个趴着不动，水面记下了这幅画 | Mr. Egret stood quietly by the water and made the garden feel still. They made room on the warmest stone and stayed for company. |
| vpi_egret_parrot | Mr. Egret | Parrot | 皮皮向白鹭先生请教「优雅」，得到的建议是先安静五分钟，皮皮撑到第九十秒 | Mr. Egret stood quietly by the water and made the garden feel still. They tried out a brand-new greeting until everyone recognized it. |
| vpi_egret_snake | Mr. Egret | Corn Snake | 白鹭先生与玉米蛇互相欣赏对方脖颈的曲线，两条最优美的弧线在池塘边达成美学共识 | Mr. Egret stood quietly by the water and made the garden feel still. They curled into a polite comma and listened without interrupting. |
| vpi_egret_chameleon | Mr. Egret | Chameleon | 阿彩变成芦苇色站在白鹭先生腿边合影留念，那张水彩照片里藏着两个伪装者 | Mr. Egret stood quietly by the water and made the garden feel still. They changed into the gentlest welcome color they could find. |
| vpi_egret_ember | Mr. Egret | Emberling | 白鹭先生绕着小火龙踱了半圈，评价道：「离水太近的火，是勇敢的火。」 | Mr. Egret stood quietly by the water and made the garden feel still. They kept one tiny flame glowing warmly between them. |
| vpi_egret_uni | Mr. Egret | Niko the Uni-Rabbit | 白鹭先生与尼可在池塘边并肩而立，白色与白色之间，只隔着一道小小的彩虹 | Mr. Egret stood quietly by the water and made the garden feel still. They left a faint rainbow shimmer over the visitor's path. |
| vpi_egret_boo | Mr. Egret | Boo the Little Ghost | 白鹭先生盯着水面上那个「没有倒影的涟漪」看了很久，最终优雅地假装什么也没发生 | Mr. Egret stood quietly by the water and made the garden feel still. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_egret_starbug | Mr. Egret | Starbug | 白鹭先生低头凝视水中星星虫的倒影，轻声说这是它见过离水面最近的一颗星 | Mr. Egret stood quietly by the water and made the garden feel still. They blinked in time until the garden seemed full of scattered stars. |
| vpi_fox_cat | Sienna the Fox | Orange Tabby | 小茜偷偷学阿橘晒太阳的姿势，被发现后立刻装作只是路过，尾巴却诚实地摊开了 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They answered with three slow tail taps and a contented blink. |
| vpi_fox_shiba | Sienna the Fox | Shiba Inu | 绕院追逐三圈后，它们并肩歇在树荫下，谁都不肯先承认累。 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They stood proudly on lookout, taking the visit very seriously. |
| vpi_fox_rabbit | Sienna the Fox | Lop Rabbit | 小茜把尾巴借给发抖的雪团当围巾，压低声音说：「传出去我可不认。」 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They listened with both long ears loose and peaceful. |
| vpi_fox_hamster | Sienna the Fox | Hamster | 小茜三招骗到了仓鼠一粒瓜子，第四招时良心发作，偷偷还回去三粒 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They offered one carefully saved crumb from their secret stash. |
| vpi_fox_turtle | Sienna the Fox | Tortoise | 小茜绕着乌龟出了七个谜语，乌龟用一下午答对了一个，小茜宣布这是年度最佳对手 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They made room on the warmest stone and stayed for company. |
| vpi_fox_parrot | Sienna the Fox | Parrot | 小茜的花言巧语第一次失效——皮皮把她的开场白原句复述了三遍，狐狸红着脸告辞 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They tried out a brand-new greeting until everyone recognized it. |
| vpi_fox_snake | Sienna the Fox | Corn Snake | 两位「院内最有心机」候选人隔石对望一炷香，最终互相承认对方是聪明人，握尾言和 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They curled into a polite comma and listened without interrupting. |
| vpi_fox_chameleon | Sienna the Fox | Chameleon | 小茜自信能找出伪装的阿彩，找了半小时未果，阿彩其实一直趴在她的尾巴上 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They changed into the gentlest welcome color they could find. |
| vpi_fox_ember | Sienna the Fox | Emberling | 小茜在小火龙的火光边烤暖了尾巴尖，讲了一个火焰山的故事，真假各半，都很好听 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They kept one tiny flame glowing warmly between them. |
| vpi_fox_uni | Sienna the Fox | Niko the Uni-Rabbit | 小茜见到尼可愣了半晌，破天荒没打任何主意，只是安静地陪它走了一段月光路 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They left a faint rainbow shimmer over the visitor's path. |
| vpi_fox_boo | Sienna the Fox | Boo the Little Ghost | 小茜自称见多识广不怕幽灵，噗噗从背后轻轻碰了下她的尾巴，狐狸窜上了树 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_fox_starbug | Sienna the Fox | Starbug | 小茜郑重提出用三个故事换星星虫发一次光，成交后她听着听着，忘了自己才是讲故事的 | Sienna the Fox arrived with a russet leaf tucked neatly behind one ear. They blinked in time until the garden seemed full of scattered stars. |
| vpi_owl_cat | Professor Owl | Orange Tabby | 教授开设深夜天文讲座，阿橘是唯一听众，全程闭眼——它坚称这是在「用耳朵看星星」 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They answered with three slow tail taps and a contented blink. |
| vpi_owl_shiba | Professor Owl | Shiba Inu | 柴犬向教授提问「为什么月亮跟着我跑」，教授推了推并不存在的眼镜，认真讲了半小时 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They stood proudly on lookout, taking the visit very seriously. |
| vpi_owl_rabbit | Professor Owl | Lop Rabbit | 教授轻声给睡不着的雪团讲月亮上的故事，讲到第三段，兔子的耳朵安心地垂了下去 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They listened with both long ears loose and peaceful. |
| vpi_owl_hamster | Professor Owl | Hamster | 教授对着仓鼠的粮仓做了一次学术考察，结论：储备充足，分类混乱，建议返工 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They offered one carefully saved crumb from their secret stash. |
| vpi_owl_turtle | Professor Owl | Tortoise | 教授与乌龟聊「时间」聊到后半夜，一个懂得夜的漫长，一个懂得年的漫长 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They made room on the warmest stone and stayed for company. |
| vpi_owl_parrot | Professor Owl | Parrot | 皮皮向教授炫耀词汇量，教授回赠一个十四个字母的单词，皮皮卡壳了，当场拜师 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They tried out a brand-new greeting until everyone recognized it. |
| vpi_owl_snake | Professor Owl | Corn Snake | 教授与玉米蛇在月下各自沉默——夜行者之间最高规格的交谈，就是一起不说话 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They curled into a polite comma and listened without interrupting. |
| vpi_owl_chameleon | Professor Owl | Chameleon | 教授一眼指出树叶间伪装的阿彩并点评了三处破绽，阿彩虚心记下，尾巴害羞地卷紧了 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They changed into the gentlest welcome color they could find. |
| vpi_owl_ember | Professor Owl | Emberling | 教授借着小火龙的暖光批改了一叠落叶标本，最后授予它「全森林最合适的阅读灯」称号。 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They kept one tiny flame glowing warmly between them. |
| vpi_owl_uni | Professor Owl | Niko the Uni-Rabbit | 教授翻遍脑中的百科也没查到尼可的条目，郑重宣布：「知识的边界外，站着一只兔子。」 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They left a faint rainbow shimmer over the visitor's path. |
| vpi_owl_boo | Professor Owl | Boo the Little Ghost | 教授是唯一不惊讶噗噗存在的客人，「夜里的事，我见的多了」，还邀它旁听下周讲座 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_owl_starbug | Professor Owl | Starbug | 教授为星星虫做了一夜「星等测定」，最终在笔记里写：亮度无法归类，暂定为「暖」 | Professor Owl offered a thoughtful lecture on clouds, shadows, and naps. They blinked in time until the garden seemed full of scattered stars. |
| vpi_deer_cat | Little Fawn | Orange Tabby | 阿橘盯着小鹿角上的小鸟看了半天，最终认定那是「长在树上的麻雀」，安心继续睡 | Little Fawn stepped softly among the flowers without bending a stem. They answered with three slow tail taps and a contented blink. |
| vpi_deer_shiba | Little Fawn | Shiba Inu | 柴犬仰头跟小鹿角上的小鸟打招呼，脖子仰酸了也不肯低头，小鹿贴心地低下了头 | Little Fawn stepped softly among the flowers without bending a stem. They stood proudly on lookout, taking the visit very seriously. |
| vpi_deer_rabbit | Little Fawn | Lop Rabbit | 小鹿低头与雪团碰了碰鼻尖，角上的小鸟顺势给兔子理了理耳朵毛，一次三方会晤 | Little Fawn stepped softly among the flowers without bending a stem. They listened with both long ears loose and peaceful. |
| vpi_deer_hamster | Little Fawn | Hamster | 仓鼠壮着胆子沿着小鹿的角爬到最高点，看到了它这辈子见过最远的风景 | Little Fawn stepped softly among the flowers without bending a stem. They offered one carefully saved crumb from their secret stash. |
| vpi_deer_turtle | Little Fawn | Tortoise | 小鹿在乌龟身边卧下休息，角上的鸟落到龟壳上，院子安静得像一幅没干透的水彩 | Little Fawn stepped softly among the flowers without bending a stem. They made room on the warmest stone and stayed for company. |
| vpi_deer_parrot | Little Fawn | Parrot | 皮皮飞上鹿角想跟常驻小鸟抢「观景位」，被小鹿轻轻一晃调解，两鸟一角一边一个 | Little Fawn stepped softly among the flowers without bending a stem. They tried out a brand-new greeting until everyone recognized it. |
| vpi_deer_snake | Little Fawn | Corn Snake | 玉米蛇望着小鹿角上的纹路看了很久——像极了它蜕皮时留下的痕迹，难得地起身相送 | Little Fawn stepped softly among the flowers without bending a stem. They curled into a polite comma and listened without interrupting. |
| vpi_deer_chameleon | Little Fawn | Chameleon | 阿彩爬上鹿角变成树枝色，小鹿从此以为自己长了三根角，走路更稳重了 | Little Fawn stepped softly among the flowers without bending a stem. They changed into the gentlest welcome color they could find. |
| vpi_deer_ember | Little Fawn | Emberling | 小鹿警惕地绕开火光，却在小火龙打喷嚏喷出小火星时忍不住笑出了声，戒心融化 | Little Fawn stepped softly among the flowers without bending a stem. They kept one tiny flame glowing warmly between them. |
| vpi_deer_uni | Little Fawn | Niko the Uni-Rabbit | 小鹿与尼可轻轻碰了碰角——一大一小，一枝一尖，像森林与童话交换了信物 | Little Fawn stepped softly among the flowers without bending a stem. They left a faint rainbow shimmer over the visitor's path. |
| vpi_deer_boo | Little Fawn | Boo the Little Ghost | 小鹿角上的小鸟对着「空中某处」叫了两声，小鹿便向那里微微颔首：它相信小鸟的眼睛 | Little Fawn stepped softly among the flowers without bending a stem. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_deer_starbug | Little Fawn | Starbug | 星星虫落在鹿角最高的分叉上发光，那晚小鹿走过的地方，都像被顺手点了灯 | Little Fawn stepped softly among the flowers without bending a stem. They blinked in time until the garden seemed full of scattered stars. |
| vpi_snowhare_cat | Snow Hare | Orange Tabby | 阿橘把雪兔认成了一团会动的雪，伸爪一碰是暖的，惊得它当场清醒了三分钟 | Snow Hare left a cool footprint beside the sun-warmed path. They answered with three slow tail taps and a contented blink. |
| vpi_snowhare_shiba | Snow Hare | Shiba Inu | 柴犬和雪兔在雪地里互相追出两串脚印，一串圆一串长，像院子写下的两行冬日日记 | Snow Hare left a cool footprint beside the sun-warmed path. They stood proudly on lookout, taking the visit very seriously. |
| vpi_snowhare_rabbit | Snow Hare | Lop Rabbit | 雪团与雪兔耳朵贴着耳朵取暖，一只垂一只立，你分不清哪团是雪哪团是兔 | Snow Hare left a cool footprint beside the sun-warmed path. They listened with both long ears loose and peaceful. |
| vpi_snowhare_hamster | Snow Hare | Hamster | 雪兔帮仓鼠在雪里刨出被埋的粮仓入口，仓鼠以三粒珍藏的葵花籽致以最高谢意 | Snow Hare left a cool footprint beside the sun-warmed path. They offered one carefully saved crumb from their secret stash. |
| vpi_snowhare_turtle | Snow Hare | Tortoise | 雪兔围着冬眠前的乌龟轻轻踩了一圈雪印当被子边，「盖好了，春天见。」 | Snow Hare left a cool footprint beside the sun-warmed path. They made room on the warmest stone and stayed for company. |
| vpi_snowhare_parrot | Snow Hare | Parrot | 皮皮学雪兔跳雪堆，一头扎进去只剩尾巴，雪兔憋笑憋出了这个冬天最大的一团白气 | Snow Hare left a cool footprint beside the sun-warmed path. They tried out a brand-new greeting until everyone recognized it. |
| vpi_snowhare_snake | Snow Hare | Corn Snake | 怕冷的玉米蛇在窗内、雪兔在窗外，隔着玻璃碰了碰头，约好开春在晒石上见 | Snow Hare left a cool footprint beside the sun-warmed path. They curled into a polite comma and listened without interrupting. |
| vpi_snowhare_chameleon | Snow Hare | Chameleon | 阿彩努力变成雪白色想陪雪兔玩，只变到了米白，雪兔说这是「刚落地的雪」，很好看 | Snow Hare left a cool footprint beside the sun-warmed path. They changed into the gentlest welcome color they could find. |
| vpi_snowhare_ember | Snow Hare | Emberling | 雪兔围着小火龙保持着又想靠近又怕融化的距离，最后蹲在「刚刚好」的一步之外 | Snow Hare left a cool footprint beside the sun-warmed path. They kept one tiny flame glowing warmly between them. |
| vpi_snowhare_uni | Snow Hare | Niko the Uni-Rabbit | 雪地里两团白影追逐，只有一道细细的彩光标记着尼可跑过的弧线 | Snow Hare left a cool footprint beside the sun-warmed path. They left a faint rainbow shimmer over the visitor's path. |
| vpi_snowhare_boo | Snow Hare | Boo the Little Ghost | 噗噗混进雪地里玩「谁最白」，雪兔赢了，因为噗噗激动起来会变透明，犯规 | Snow Hare left a cool footprint beside the sun-warmed path. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_snowhare_starbug | Snow Hare | Starbug | 雪兔驮着星星虫在雪原上跑了一圈，雪反着光，像驮着一颗星星巡视了整个冬天 | Snow Hare left a cool footprint beside the sun-warmed path. They blinked in time until the garden seemed full of scattered stars. |
| vpi_l_starbug_any | Starbug | * | 宠物屏息看着草叶上明灭的小光点，来客册的那一页也像被微光照亮 | Your friend held their breath as a point of light blinked among the grass. For a moment, even the Visitor Compendium seemed to glow. |
| vpi_l_starbug_cat | Starbug | Orange Tabby | 阿橘为了这颗落地的星星整晚没睡，用尾巴圈出一块「星星保护区」 | Starbug blinked among the grass like a pocket-sized constellation. They answered with three slow tail taps and a contented blink. |
| vpi_l_starbug_shiba | Starbug | Shiba Inu | 柴犬压低身子守着光点，忍住了所有想扑的冲动，那是它最漫长也最骄傲的一夜 | Starbug blinked among the grass like a pocket-sized constellation. They stood proudly on lookout, taking the visit very seriously. |
| vpi_l_starbug_rabbit | Starbug | Lop Rabbit | 雪团第一次主动凑近陌生的东西——那点光太温柔了，连胆小都忘了 | Starbug blinked among the grass like a pocket-sized constellation. They listened with both long ears loose and peaceful. |
| vpi_l_starbug_hamster | Starbug | Hamster | 仓鼠没有把发光的小家伙搬回仓库，而是搬了三粒瓜子出来摆在它面前 | Starbug blinked among the grass like a pocket-sized constellation. They offered one carefully saved crumb from their secret stash. |
| vpi_l_starbug_turtle | Starbug | Tortoise | 乌龟守着光点从入夜坐到天亮，星星虫走时，在它壳上留下了一枚淡淡的光印 | Starbug blinked among the grass like a pocket-sized constellation. They made room on the warmest stone and stayed for company. |
| vpi_l_starbug_parrot | Starbug | Parrot | 皮皮一整晚没说话，第二天也没跟任何人炫耀——有些事它想自己留着 | Starbug blinked among the grass like a pocket-sized constellation. They tried out a brand-new greeting until everyone recognized it. |
| vpi_l_starbug_snake | Starbug | Corn Snake | 玉米蛇盘在光点周围守了一夜，冷冷的鳞片上映着一点暖光，谁也没提这件事 | Starbug blinked among the grass like a pocket-sized constellation. They curled into a polite comma and listened without interrupting. |
| vpi_l_starbug_chameleon | Starbug | Chameleon | 阿彩变成夜空色趴在旁边，让那点光成为它身上唯一的星 | Starbug blinked among the grass like a pocket-sized constellation. They changed into the gentlest welcome color they could find. |
| vpi_l_starbug_ember | Starbug | Emberling | 小火龙把尾巴上的光调到最柔，与草叶上的光一明一灭，像两句轮流说的悄悄话 | Starbug blinked among the grass like a pocket-sized constellation. They kept one tiny flame glowing warmly between them. |
| vpi_l_starbug_uni | Starbug | Niko the Uni-Rabbit | 尼可角尖的彩光与星光轻轻一碰，草地上晕开一小圈谁也没见过的颜色 | Starbug blinked among the grass like a pocket-sized constellation. They left a faint rainbow shimmer over the visitor's path. |
| vpi_l_starbug_boo | Starbug | Boo the Little Ghost | 噗噗和星星虫在草丛里玩了一夜「一闪一躲」，两个夜的孩子，一个发光一个透明 | Starbug blinked among the grass like a pocket-sized constellation. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_l_starbug_starbug | Starbug | Starbug | 在养的星星虫与来访的星星虫同时亮起，两颗星以只属于星星的频率眨了整夜的眼 | Starbug blinked among the grass like a pocket-sized constellation. They blinked in time until the garden seemed full of scattered stars. |
| vpi_l_flame_any | Campfire Glow | * | 暖炉边多出一簇不该存在的小火苗，宠物看见了，你也看见了，谁都没有声张 | A flame that should not have been there danced beside the hearth. You both saw it, and neither of you broke the quiet. |
| vpi_l_flame_cat | Campfire Glow | Orange Tabby | 阿橘挪到暖炉边取暖，发现今晚的火多了一小簇，还会跟着它的呼噜声轻轻跳 | Campfire Glow flickered beside the lantern without casting a shadow. They answered with three slow tail taps and a contented blink. |
| vpi_l_flame_shiba | Campfire Glow | Shiba Inu | 柴犬对着那簇多出来的火苗歪头，火苗也歪了歪，柴犬从此坚信火是活的 | Campfire Glow flickered beside the lantern without casting a shadow. They stood proudly on lookout, taking the visit very seriously. |
| vpi_l_flame_rabbit | Campfire Glow | Lop Rabbit | 雪团怕火，却在那簇小火光前停住了——它烧得那么小心，像也怕吓到谁 | Campfire Glow flickered beside the lantern without casting a shadow. They listened with both long ears loose and peaceful. |
| vpi_l_flame_hamster | Campfire Glow | Hamster | 仓鼠把最好的一粒坚果放在暖炉边「烤」，火光替它烤得恰到好处，还多留了一分钟 | Campfire Glow flickered beside the lantern without casting a shadow. They offered one carefully saved crumb from their secret stash. |
| vpi_l_flame_turtle | Campfire Glow | Tortoise | 乌龟在暖炉边坐了整晚，那簇小火光始终为它保持着一个不烫不凉的距离 | Campfire Glow flickered beside the lantern without casting a shadow. They made room on the warmest stone and stayed for company. |
| vpi_l_flame_parrot | Campfire Glow | Parrot | 皮皮对火光说了一晚上话，火光用明明灭灭回应，皮皮宣布自己学会了「火语」 | Campfire Glow flickered beside the lantern without casting a shadow. They tried out a brand-new greeting until everyone recognized it. |
| vpi_l_flame_snake | Campfire Glow | Corn Snake | 最怕冷的玉米蛇缠着暖炉不走，那簇小火光悄悄往它那边偏了一整夜 | Campfire Glow flickered beside the lantern without casting a shadow. They curled into a polite comma and listened without interrupting. |
| vpi_l_flame_chameleon | Campfire Glow | Chameleon | 阿彩变成火焰的颜色，那簇火光高兴地跳了三跳，像在人群里认出了亲戚 | Campfire Glow flickered beside the lantern without casting a shadow. They changed into the gentlest welcome color they could find. |
| vpi_l_flame_ember | Campfire Glow | Emberling | 在养的小火龙与那簇火光额头相抵，两簇火安静地合了一下拍——像久别的重逢 | Campfire Glow flickered beside the lantern without casting a shadow. They kept one tiny flame glowing warmly between them. |
| vpi_l_flame_uni | Campfire Glow | Niko the Uni-Rabbit | 火光在尼可的白毛上投下暖橙的光晕，一冷一暖两种童话，在暖炉边握了握手 | Campfire Glow flickered beside the lantern without casting a shadow. They left a faint rainbow shimmer over the visitor's path. |
| vpi_l_flame_boo | Campfire Glow | Boo the Little Ghost | 噗噗飘到火边也不怕烫，火光穿过它的身体，把它照成了一盏毛茸茸的橘色灯笼 | Campfire Glow flickered beside the lantern without casting a shadow. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_l_flame_starbug | Campfire Glow | Starbug | 星星虫落在暖炉沿，一颗冷光一簇暖光互相打量，最后同步了闪烁的节拍 | Campfire Glow flickered beside the lantern without casting a shadow. They blinked in time until the garden seemed full of scattered stars. |
| vpi_l_white_any | The Rainbow's White Shadow | * | 雨停了，彩虹落地的地方有个白色的影子一闪，宠物朝那里望了很久 | After the rain, a white shape flashed where the rainbow touched the ground. Your friend watched that spot for a long time. |
| vpi_l_white_cat | The Rainbow's White Shadow | Orange Tabby | 阿橘顺着彩虹望过去，白影一闪而过，它破例起身追到篱笆边——为一个影子，值得 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They answered with three slow tail taps and a contented blink. |
| vpi_l_white_shiba | The Rainbow's White Shadow | Shiba Inu | 柴犬冲着彩虹尽头汪了一声，白影停了停，像回了一句它听得懂的话 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They stood proudly on lookout, taking the visit very seriously. |
| vpi_l_white_rabbit | The Rainbow's White Shadow | Lop Rabbit | 雪团看见白影的瞬间耳朵竖了起来——那身影像它，又比它多了一点亮晶晶的什么 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They listened with both long ears loose and peaceful. |
| vpi_l_white_hamster | The Rainbow's White Shadow | Hamster | 仓鼠在彩虹落脚的草地上捡到一根泛着虹光的白毛，郑重收进了仓库最里层 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They offered one carefully saved crumb from their secret stash. |
| vpi_l_white_turtle | The Rainbow's White Shadow | Tortoise | 乌龟朝彩虹的方向走了整整一下午，白影早已不在，但它说重要的是出发过 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They made room on the warmest stone and stayed for company. |
| vpi_l_white_parrot | The Rainbow's White Shadow | Parrot | 皮皮信誓旦旦描述白影「头上有个亮亮的尖尖」，你第一次没怀疑它在编 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They tried out a brand-new greeting until everyone recognized it. |
| vpi_l_white_snake | The Rainbow's White Shadow | Corn Snake | 玉米蛇在湿石头上望着彩虹尽头，蛇的眼睛不会说谎：那里确实有过一个白影 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They curled into a polite comma and listened without interrupting. |
| vpi_l_white_chameleon | The Rainbow's White Shadow | Chameleon | 阿彩试着把自己变成彩虹的七色，白影在远处停了一瞬，像被逗笑了 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They changed into the gentlest welcome color they could find. |
| vpi_l_white_ember | The Rainbow's White Shadow | Emberling | 小火龙的火光与雨后的彩虹同框，白影在光与虹之间多停留了几秒才离开 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They kept one tiny flame glowing warmly between them. |
| vpi_l_white_uni | The Rainbow's White Shadow | Niko the Uni-Rabbit | 在养的尼可与彩虹边的白影遥遥对望，角尖的光同时亮了一下——像一声跨越彩虹的应答 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They left a faint rainbow shimmer over the visitor's path. |
| vpi_l_white_boo | The Rainbow's White Shadow | Boo the Little Ghost | 一个白影在彩虹边，一个白团子在院子里，两团白色隔空轻轻晃了晃，算打过招呼 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_l_white_starbug | The Rainbow's White Shadow | Starbug | 星星虫白天不发光，却在白影出现的那几秒微微亮了——传说认得传说 | The Rainbow's White Shadow waited where the last ribbon of rainbow touched the yard. They blinked in time until the garden seemed full of scattered stars. |
| vpi_l_boo_any | Midnight Puff | * | 深夜的院子里飘过一个白团子，宠物的视线跟着它移动，而你只看见风 | A round white puff drifted through the midnight garden. Your friend followed it with their eyes; you saw only the wind. |
| vpi_l_boo_cat | Midnight Puff | Orange Tabby | 深夜阿橘对着「空无一物」的墙角打呼噜，尾巴给谁留了一块暖和的位置 | Midnight Puff floated past like a shy cloud that had lost the moon. They answered with three slow tail taps and a contented blink. |
| vpi_l_boo_shiba | Midnight Puff | Shiba Inu | 柴犬冲着夜空摇尾巴，摇得真诚又持久——它向来对朋友一视同仁，看不看得见都算 | Midnight Puff floated past like a shy cloud that had lost the moon. They stood proudly on lookout, taking the visit very seriously. |
| vpi_l_boo_rabbit | Midnight Puff | Lop Rabbit | 雪团夜里从纸箱探出头，跟白团子对视了一会儿，居然没躲——比它还胆小的，不可怕 | Midnight Puff floated past like a shy cloud that had lost the moon. They listened with both long ears loose and peaceful. |
| vpi_l_boo_hamster | Midnight Puff | Hamster | 仓鼠夜里摆出两粒瓜子，早上瓜子还在，但被摆成了一个歪歪的「谢」字形 | Midnight Puff floated past like a shy cloud that had lost the moon. They offered one carefully saved crumb from their secret stash. |
| vpi_l_boo_turtle | Midnight Puff | Tortoise | 乌龟半夜醒来，看见白团子怯生生地飘在池塘上方照「倒影」——水里什么也没有 | Midnight Puff floated past like a shy cloud that had lost the moon. They made room on the warmest stone and stayed for company. |
| vpi_l_boo_parrot | Midnight Puff | Parrot | 皮皮半夜突然轻声说了句谁也没教过的「晚安」，对着房间里最暗的那个角落 | Midnight Puff floated past like a shy cloud that had lost the moon. They tried out a brand-new greeting until everyone recognized it. |
| vpi_l_boo_snake | Midnight Puff | Corn Snake | 玉米蛇深夜盘在老地方，给身边留了一个团子形状的空位，谁问都说是巧合 | Midnight Puff floated past like a shy cloud that had lost the moon. They curled into a polite comma and listened without interrupting. |
| vpi_l_boo_chameleon | Midnight Puff | Chameleon | 阿彩深夜把自己变成半透明的白色飘忽晃动，白团子凑过来看了很久：同类？ | Midnight Puff floated past like a shy cloud that had lost the moon. They changed into the gentlest welcome color they could find. |
| vpi_l_boo_ember | Midnight Puff | Emberling | 白团子怕生地躲在小火龙暖光照不到的边缘，火苗便悄悄把光晕又扩大了一圈 | Midnight Puff floated past like a shy cloud that had lost the moon. They kept one tiny flame glowing warmly between them. |
| vpi_l_boo_uni | Midnight Puff | Niko the Uni-Rabbit | 尼可深夜对着月光下的白团子轻轻点了点角，白团子开心地翻了一个透明的跟头 | Midnight Puff floated past like a shy cloud that had lost the moon. They left a faint rainbow shimmer over the visitor's path. |
| vpi_l_boo_boo | Midnight Puff | Boo the Little Ghost | 在养的噗噗与来访的白团子在夜空里追着飘了一圈——原来它一直不是唯一的一个 | Midnight Puff floated past like a shy cloud that had lost the moon. They floated close enough to be friendly and calmly enough not to startle. |
| vpi_l_boo_starbug | Midnight Puff | Starbug | 星星虫为白团子亮了一整夜。白团子第一次在光里待到了天亮前。 | Midnight Puff floated past like a shy cloud that had lost the moon. They blinked in time until the garden seemed full of scattered stars. |

## 11. 成长、离线与院子记忆

| 场景 | 中文 | English |
| --- | --- | --- |
| 成长 Lv2 | {宠物名}开始分得清你的脚步声了。 | {Pet Name} can already tell the sound of your footsteps apart. |
| 成长 Lv3 | {宠物名}在院子里选定了最喜欢发呆的角落。 | {Pet Name} has chosen a favorite corner for quiet daydreams. |
| 成长 Lv4 | 每次听见自己的名字，{宠物名}都会先抬头找你。 | Whenever someone says their name, {Pet Name} looks for you first. |
| 成长 Lv7 | {宠物名}开始把院子里的花、风和来客都当成自己的朋友。 | {Pet Name} now treats the flowers, breeze, and garden visitors as friends. |
| 成长 Lv9 | {宠物名}最近常望向院门外，也悄悄整理起自己的小行囊。 | {Pet Name} has begun watching the gate and quietly packing a tiny travel bag. |
| 成长 Lv6 · 贪吃 | {宠物名}会把最好吃的那一口留到最后，再认真看你一眼。 | {Pet Name} saves the tastiest bite for last, then gives you one serious little look. |
| 成长 Lv6 · 活力 | {宠物名}每天跑完一圈后，都会回到你身边轻轻碰一下。 | {Pet Name} finishes every garden lap by coming back to touch your side. |
| 成长 Lv6 · 慵懒 | {宠物名}已经学会在你最常停留的地方安心打盹。 | {Pet Name} naps most peacefully wherever you spend the most time. |
| 成长 Lv6 · 好奇 | {宠物名}遇见新东西时，总要先回头确认你也看见了。 | {Pet Name} always checks that you noticed whenever something new appears. |
| 成长 Lv6 · 黏人 | {宠物名}听见门响时，总会第一个过去看看。 | {Pet Name} is always first to look when footsteps approach. |
| 成长 Lv6 · 高冷 | {宠物名}还是假装不在意，却总把休息的位置挪得离你更近。 | {Pet Name} still pretends not to care, but keeps moving their resting place closer to you. |
| 成长 Lv6 · 淘气 | {宠物名}每次闯完小祸，都会若无其事地坐到你身边。 | {Pet Name} sits beside you with perfect innocence after every tiny bit of trouble. |
| 成长 Lv6 · 温柔 | {宠物名}会安静照看院子里比自己更小的来客。 | {Pet Name} quietly watches over visitors smaller than they are. |
| 成长 Lv6 · 爱幻想 | {宠物名}睡醒后总像还记得一个清晰而温暖的梦。 | {Pet Name} wakes as if returning from a clear, warm dream. |
| 成长 Lv6 · 胆小 | {宠物名}已经有了一个只有你最熟悉的小习惯。 | {Pet Name} has grown a little habit that only you know by heart. |
| 远方近况 · 贪吃 | 远方近况：{宠物名}说最近学会了分辨每座城市点心出炉的时间。 | News from afar: {Pet Name} has learned exactly when each town takes its pastries from the oven. |
| 远方近况 · 活力 | 远方近况：{宠物名}说自己又找到一条能迎着风跑很久的小路。 | News from afar: {Pet Name} found another road where the wind keeps pace for miles. |
| 远方近况 · 慵懒 | 远方近况：{宠物名}说远方也有一块晒起来刚刚好的石头。 | News from afar: {Pet Name} found a faraway stone warmed to the perfect temperature. |
| 远方近况 · 好奇 | 远方近况：{宠物名}说一路记下的问题已经装满了半本小册子。 | News from afar: {Pet Name} has already filled half a notebook with new questions. |
| 远方近况 · 黏人 | 远方近况：{宠物名}说每到一个新地方，还是会先想起院子的门。 | News from afar: {Pet Name} still thinks of the garden gate before exploring each new place. |
| 远方近况 · 高冷 | 远方近况：{宠物名}只写了一句“一切都好”，却在信封里夹了片叶子。 | News from afar: {Pet Name} wrote only ‘All is well,’ then tucked a pressed leaf into the envelope. |
| 远方近况 · 淘气 | 远方近况：{宠物名}说这次真的没有惹麻烦，至少没有很大的麻烦。 | News from afar: {Pet Name} promises there was no trouble this time, or at least no large trouble. |
| 远方近况 · 温柔 | 远方近况：{宠物名}说沿途遇见的小伙伴都被好好照顾着。 | News from afar: {Pet Name} has been looking after every small friend met on the road. |
| 远方近况 · 爱幻想 | 远方近况：{宠物名}说昨晚梦见在很远的地方也能看见院子的灯。 | News from afar: {Pet Name} dreamed they could see the garden light even from far away. |
| 远方近况 · 胆小 | 远方近况：{宠物名}说它仍在慢慢看世界，也一直记得回院子的路。 | News from afar: {Pet Name} is still seeing the world slowly and remembers every turn home. |
| 离线欢迎 · 贪吃 | 它把食盆检查得很仔细，也认真规划好了下一顿点心。 | They inspected the food bowl carefully and made a serious plan for the next treat. |
| 离线欢迎 · 活力 | 它自己在草地上跑了好几圈，现在刚好愿意靠着你歇一会儿。 | They ran several laps alone and are now perfectly happy to rest beside you. |
| 离线欢迎 · 慵懒 | 这段时间它认真忙了一件事：把同一个午觉睡完。 | They worked very hard on one important task: finishing the same long nap. |
| 离线欢迎 · 好奇 | 它把院子的每一阵风都研究了一遍，攒下不少新发现。 | They examined every breeze that crossed the garden and gathered plenty of new discoveries. |
| 离线欢迎 · 黏人 | 它把窝挪到了能晒到午后阳光的位置，醒来时正好听见院门响。 | They moved their bed into the afternoon sun and woke just as the garden gate opened. |
| 离线欢迎 · 高冷 | 它把院子巡视了许多遍，确认每个角落都还是熟悉的样子。 | They made several rounds of the garden and confirmed that every corner still felt familiar. |
| 离线欢迎 · 淘气 | 院子里好像有几片叶子换了位置，但它决定先不解释。 | A few leaves seem to have changed places, but they have decided explanations can wait. |
| 离线欢迎 · 温柔 | 它照看了花和来客，院子一直好好的。 | They watched over the flowers and visitors. The garden stayed peaceful. |
| 离线欢迎 · 爱幻想 | 它睡着时梦见一朵云落进院子，醒来还记得云的形状。 | They dreamed that a cloud settled in the garden and still remember its shape after waking. |
| 离线欢迎 · 胆小 | 它睡饱了，也把院子照看得好好的。 | They slept well, and the garden stayed peaceful around them. |
| 来客离开·未互动 | {来客名}轻轻来过，没有打扰谁，只在院子边留下一点到访的痕迹。 | {Visitor} passed through gently, leaving a small trace beside the garden path. |
| 来客离开·已互动·无在养宠 | {来客名}离开前在院子里停了很久，像是在认真记住回来的路。 | {Visitor} lingered before leaving, as though memorizing the way back. |
| 来客离开·已互动 | {来客名}离开前又回头看了看{宠物名}，院子里留下了一段安静的脚印。 | Before leaving, {Visitor} looked back at {Pet Name}; a quiet trail of footprints remained in the garden. |
| 存档恢复·主存档损坏 | 主存档无法读取，已从本地安全备份恢复。 | The primary save could not be read, so the garden was restored from its safe local backup. |
| 存档恢复·校验异常 | 存档校验发现异常，已从最近的完整快照恢复。 | Save verification found an inconsistency, so the garden was restored from the latest complete snapshot. |
| 存档恢复·主存档缺失 | 主存档缺失，已从最近的完整快照恢复。 | The primary save was missing, so the garden was restored from the latest complete snapshot. |
