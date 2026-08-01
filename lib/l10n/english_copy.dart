/// Curated English UI copy for the legacy source-string bridge.
///
/// Keep entries concise enough for compact iPhone layouts. Narrative content
/// belongs in the content-localization layer and should not be added here.
abstract final class EnglishCopy {
  static String translate(String source) {
    final exact = _copy[source];
    if (exact != null) return exact;
    final term = _terms[source];
    if (term != null) return term;
    final decorated = RegExp(r'^(\s*[·•]\s*)(.+)$').firstMatch(source);
    if (decorated != null) {
      return '${decorated[1]}${translate(decorated[2]!)}';
    }
    return _translatePattern(source) ?? source;
  }

  static String _term(String source) =>
      _terms[source] ?? _copy[source] ?? source;

  static String? _translatePattern(String source) {
    Match? match;

    match = RegExp(r'^(\d+)月(\d+)日$').firstMatch(source);
    if (match != null) return '${match[1]}/${match[2]}';

    match = RegExp(r'^(\d+)年(\d+)月(\d+)日$').firstMatch(source);
    if (match != null) return '${match[2]}/${match[3]}/${match[1]}';

    match = RegExp(r'^第 (\d+) 页，共 (\d+) 页$').firstMatch(source);
    if (match != null) return 'Page ${match[1]} of ${match[2]}';

    match = RegExp(r'^(\d+) / (\d+) 已达成$').firstMatch(source);
    if (match != null) return '${match[1]} of ${match[2]} completed';

    match = RegExp(r'^(\d+) 张$').firstMatch(source);
    if (match != null) return '${match[1]} postcards';

    match = RegExp(r'^库存 (\d+)$').firstMatch(source);
    if (match != null) return '${match[1]} in stock';

    match = RegExp(r'^位置 (\d+)$').firstMatch(source);
    if (match != null) return 'Slot ${match[1]}';

    match = RegExp(r'^第 (\d+) 种花色$').firstMatch(source);
    if (match != null) return 'Color ${match[1]}';

    match = RegExp(r'^相伴 (\d+) 天$').firstMatch(source);
    if (match != null) return '${match[1]} days together';

    match = RegExp(r'^经验 (\d+) / (\d+)$').firstMatch(source);
    if (match != null) return 'XP ${match[1]} / ${match[2]}';

    match = RegExp(r'^暖绒 \+(\d+)$').firstMatch(source);
    if (match != null) return '+${match[1]} Sunfluff';

    match = RegExp(r'^经验 \+(\d+)$').firstMatch(source);
    if (match != null) return '+${match[1]} XP';

    match = RegExp(r'^(喂食|摸头|玩具|洗澡) \+(\d+)$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} +${match[2]}';

    match = RegExp(r'^(.+)的旅程$').firstMatch(source);
    if (match != null) return "${_term(match[1]!)}'s Journey";

    match = RegExp(r'^查看(.+)的详情$').firstMatch(source);
    if (match != null) return 'View ${_term(match[1]!)}';

    match = RegExp(r'^摸摸(.+)$').firstMatch(source);
    if (match != null) return 'Pet ${_term(match[1]!)}';

    match = RegExp(r'^到访 (\d+) 次$').firstMatch(source);
    if (match != null) return '${match[1]} visits';

    match = RegExp(r'^已收录 (\d+) / (\d+)$').firstMatch(source);
    if (match != null) return '${match[1]} of ${match[2]} discovered';

    match = RegExp(r'^第 (\d+) 站 · (.+)$').firstMatch(source);
    if (match != null) return 'Stop ${match[1]} · ${match[2]}';

    match = RegExp(r'^(.+)，(.+)后可用$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} · Ready in ${match[2]}';
    }

    match = RegExp(r'^(.+)，今天已经满足，仍可继续陪伴$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} · You can still spend time together';
    }

    match = RegExp(r'^(.+)，今天更合它心意，增加(\d+)点经验$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} was just right today · +${match[2]} XP';
    }

    match = RegExp(r'^(.+)，今日次数已完成$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} · Done for today';

    match = RegExp(r'^(.+)，增加(\d+)点经验$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} · +${match[2]} XP';

    match = RegExp(r'^(.+)来客，还没留下脚印。$').firstMatch(source);
    if (match != null) {
      return 'No ${_term(match[1]!).toLowerCase()} visitor has left a footprint yet.';
    }

    match = RegExp(r'^(.+)的旅行风景$').firstMatch(source);
    if (match != null) return 'A travel view from ${_term(match[1]!)}';

    match = RegExp(r'^(.+) · 第 (\d+) 站$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} · Stop ${match[2]}';

    match = RegExp(r'^(.+) 从远方寄来 (\d+) 张明信片$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} sent ${match[2]} postcards from afar';
    }

    match = RegExp(r'^(.+) 从远方寄来一张明信片$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} sent a postcard from afar';

    match = RegExp(r'^(.+)的来访手账$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} · Visitor Notes';

    match = RegExp(r'^(.+)，查看来客回忆$').firstMatch(source);
    if (match != null) return 'View memories with ${_term(match[1]!)}';

    match = RegExp(r'^(.+)的水彩小景$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} watercolor scene';

    match = RegExp(r'^(\d+) 件小物$').firstMatch(source);
    if (match != null) {
      return match[1] == '1' ? '1 item' : '${match[1]} items';
    }

    match = RegExp(r'^(.+) · 原价 (\d+)$').firstMatch(source);
    if (match != null) return '${match[1]} · Usually ${match[2]}';

    match = RegExp(r'^(.+) 已收进手账。$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} is now in your journal.';

    match = RegExp(r'^(.+) 已收进手账，已使用(.+)。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is now in your journal · ${match[2]} applied.';
    }

    match = RegExp(r'^(\d+) 暖绒$').firstMatch(source);
    if (match != null) return '${match[1]} Sunfluff';

    match = RegExp(r'^(.+) 等 (\d+) 项$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} + ${match[2]} items';

    match = RegExp(r'^(\d+) / (\d+) 站 · 已寄回 (\d+) 张$').firstMatch(source);
    if (match != null) {
      return '${match[1]} of ${match[2]} stops · ${match[3]} postcards';
    }

    match = RegExp(r'^(.+)正在享用小点心$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} is enjoying a treat';

    match = RegExp(r'^(.+)的旅程，已走过 (\d+) / (\d+) 站，$').firstMatch(source);
    if (match != null) {
      return "${_term(match[1]!)}'s journey · ${match[2]} of ${match[3]} stops,";
    }

    match = RegExp(r'^(.+) 回家看看了$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} came home for a visit';

    match = RegExp(r'^(.+)来到院子$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} came to the garden';

    match = RegExp(r'^(.+)正在院子里歇脚$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} is resting in the garden';

    match = RegExp(r'^(.+)正等你打个招呼$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} is waiting to say hello';

    match = RegExp(r'^(.+)睡饱了，又来蹭蹭你$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} woke up and came for a cuddle';
    }

    match = RegExp(r'^(.+)睡饱了，蹭蹭你 \+(\d+)$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} woke up and cuddled close · +${match[2]} XP';
    }

    match = RegExp(r'^(.+)睡饱后回到你身边$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} woke up and came back to you';
    }

    match = RegExp(r'^「(.+)」出发了$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} has set off';

    match = RegExp(r'^「(.+)」长大了，是时候去看看外面的世界$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is all grown up and ready to see the world';
    }

    match = RegExp(r'^伙伴经验 \+(\d+)$').firstMatch(source);
    if (match != null) return 'Friend XP +${match[1]}';

    match = RegExp(r'^和 (.+)$').firstMatch(source);
    if (match != null) return 'With ${_term(match[1]!)}';

    match = RegExp(r'^回访伙伴 (.+)，点按查看近况$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is visiting · Tap to catch up';
    }

    match = RegExp(r'^它会在院子里歇一歇，接下来约 (\d+) 天都能看见这个熟悉的身影。$').firstMatch(source);
    if (match != null) {
      return 'This familiar friend will rest in the garden for about ${match[1]} days.';
    }

    match = RegExp(r'^它把一小包暖绒放进你手里：暖绒 \+(\d+)。$').firstMatch(source);
    if (match != null) {
      return 'They left a little pouch in your hand · +${match[1]} Sunfluff.';
    }

    match = RegExp(r'^已养过 (\d+) / (\d+)    可领养 (\d+)$').firstMatch(source);
    if (match != null) {
      return '${match[1]} of ${match[2]} met · ${match[3]} available';
    }

    match = RegExp(r'^已寄回 (\d+) 张明信片$').firstMatch(source);
    if (match != null) return '${match[1]} postcards sent home';

    match = RegExp(r'^已应用「(.+)」。$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} applied.';

    match = RegExp(r'^已收下 · (.+)$').firstMatch(source);
    if (match != null) return 'Received · ${translate(match[1]!)}';

    match = RegExp(r'^已走过 (\d+) / (\d+) 站 · 已寄回 (\d+) 张$').firstMatch(source);
    if (match != null) {
      return '${match[1]} of ${match[2]} stops · ${match[3]} postcards';
    }

    match = RegExp(
      r'^(.+)的旅程，已走过 (\d+) / (\d+) 站，已寄回 (\d+) 张明信片$',
    ).firstMatch(source);
    if (match != null) {
      return "${_term(match[1]!)}'s journey · ${match[2]} of ${match[3]} stops · "
          '${match[4]} postcards';
    }

    match = RegExp(r'^当前等级进度 (\d+)%$').firstMatch(source);
    if (match != null) return 'Level progress ${match[1]}%';

    match = RegExp(r'^打开(.+)从(.+)寄来的第 (\d+) 张明信片$').firstMatch(source);
    if (match != null) {
      return 'Open postcard ${match[3]} from ${_term(match[1]!)} in ${_term(match[2]!)}';
    }

    match = RegExp(r'^打开支持小院，(.+)$').firstMatch(source);
    if (match != null) return 'Support the Garden · ${translate(match[1]!)}';

    match = RegExp(r'^接下来约 (\d+) 天，它会留在院子里。$').firstMatch(source);
    if (match != null) {
      return 'They will stay in the garden for about ${match[1]} days.';
    }

    match = RegExp(r'^收到(.+)从远方寄来的明信片$').firstMatch(source);
    if (match != null) return 'A postcard from ${_term(match[1]!)}';

    match = RegExp(r'^新伙伴也和它聊了很久，经验 \+(\d+)。$').firstMatch(source);
    if (match != null) {
      return 'Your friend stayed for a long chat · +${match[1]} XP.';
    }

    match = RegExp(r'^来客 (.+)，点按查看互动$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is visiting · Tap to say hello';
    }

    match = RegExp(r'^毕业于 (.+)$').firstMatch(source);
    if (match != null) return 'Graduated ${match[1]}';

    match = RegExp(r'^第一次见面：(\d{4})\.(\d{2})\.(\d{2})$').firstMatch(source);
    if (match != null) {
      return 'First met: ${int.parse(match[2]!)}/${int.parse(match[3]!)}/${match[1]!.substring(2)}';
    }

    match = RegExp(r'^第一次见面：(.+)$').firstMatch(source);
    if (match != null) return 'First met: ${match[1]}';

    match = RegExp(r'^第一程：(.+) · (.+)$').firstMatch(source);
    if (match != null) return 'First route: ${_term(match[1]!)} · ${match[2]}';

    match = RegExp(r'^暖绒 (\d+)，打开商店$').firstMatch(source);
    if (match != null) return '${match[1]} Sunfluff · Open shop';

    match = RegExp(r'^绒光 (\d+)，打开商店$').firstMatch(source);
    if (match != null) return '${match[1]} Sunfluff · Open shop';

    match = RegExp(r'^(.+)来客缘分 \+(\d+)%$').firstMatch(source);
    if (match != null) {
      return '+${match[2]}% chance for ${_term(match[1]!).toLowerCase()} visitors';
    }

    match = RegExp(r'^下一次使用时，经验提升至 (\d+) 点$').firstMatch(source);
    if (match != null) return 'Raises the next care action to ${match[1]} XP';

    match = RegExp(r'^永久拥有，玩耍经验提升至 (\d+) 点$').firstMatch(source);
    if (match != null) return 'Permanent · Play actions grant ${match[1]} XP';

    match = RegExp(r'^达成成就：(.+)$').firstMatch(source);
    if (match != null) return 'Achievement unlocked: ${_term(match[1]!)}';

    match = RegExp(r'^进度 (\d+) / (\d+)，奖励 (.+)$').firstMatch(source);
    if (match != null) {
      return 'Progress ${match[1]} of ${match[2]} · Reward: ${translate(match[3]!)}';
    }

    match = RegExp(r'^陪伴经验 \+(\d+)$').firstMatch(source);
    if (match != null) return 'Friendship XP +${match[1]}';

    match = RegExp(r'^首次 (\d{4})\.(\d{2})\.(\d{2})$').firstMatch(source);
    if (match != null) {
      return 'First seen ${int.parse(match[2]!)}/${int.parse(match[3]!)}';
    }

    match = RegExp(r'^首次 (.+)$').firstMatch(source);
    if (match != null) return 'First seen ${match[1]}';

    match = RegExp(r'^再送 (\d+) 只毕业就能遇见它$').firstMatch(source);
    if (match != null) {
      return 'Help ${match[1]} more friends graduate to meet this one';
    }

    match = RegExp(r'^摸摸(.+)，听听今天的心情$').firstMatch(source);
    if (match != null) return 'Pet ${_term(match[1]!)} and see how today feels';

    match = RegExp(r'^(.+)好像想尝点好吃的$').firstMatch(source);
    if (match != null) return '${_term(match[1]!)} seems ready for a treat';

    match = RegExp(r'^把玩具滚到(.+)身边$').firstMatch(source);
    if (match != null) return 'Roll a toy over to ${_term(match[1]!)}';

    match = RegExp(r'^给(.+)洗个舒服的澡$').firstMatch(source);
    if (match != null) return 'Give ${_term(match[1]!)} a relaxing bath';

    match = RegExp(r'^和(.+)打个招呼$').firstMatch(source);
    if (match != null) return 'Say hello to ${_term(match[1]!)}';

    match = RegExp(r'^三种陪伴都收到了，(.+)今天已经很满足。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} felt cared for in every way today.';
    }

    match = RegExp(r'^(.+)最喜欢这样，默契让这次陪伴更特别。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} loved that. Your bond made it extra special.';
    }

    match = RegExp(r'^这正合(.+)的心意，默契正在一点点累积。$').firstMatch(source);
    if (match != null) {
      return 'That was just right for ${_term(match[1]!)}. Your bond is growing.';
    }

    match = RegExp(r'^(.+)已经很满足，也喜欢你继续陪在身边。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is content and still loves having you nearby.';
    }

    match = RegExp(r'^(.+)认真吃完，又抬头看了看你。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} finished every bite, then looked up at you.';
    }

    match = RegExp(r'^(.+)慢慢放松下来，往你的手心靠近了一点。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} relaxed and leaned a little closer to your hand.';
    }

    match = RegExp(r'^(.+)追着玩具跑了一圈，又开心地回到你身边。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} chased the toy, then happily came back to you.';
    }

    match = RegExp(r'^(.+)洗得干干净净，身上还带着温热的水汽。$').firstMatch(source);
    if (match != null) {
      return '${_term(match[1]!)} is clean, warm, and freshly bathed.';
    }

    match = RegExp(
      r'^它会先往(.+)走，旅途大约经过 (\d+) 个地方。\n每隔些日子就会寄一张明信片回来 💌\n院子空出来了，去迎接下一位小伙伴吧。$',
    ).firstMatch(source);
    if (match != null) {
      return 'The first route leads toward ${_term(match[1]!).toLowerCase()}, '
          'with about ${match[2]} stops along the way.\nA postcard will arrive '
          'every few days.\nThe garden is ready to welcome a new friend.';
    }

    match = RegExp(r'^(.+?)\s+·\s+(.+)$').firstMatch(source);
    if (match != null) {
      return '${translate(match[1]!)} · ${translate(match[2]!)}';
    }

    return null;
  }

  /// Localized display names for content records. IDs and save data remain
  /// language-neutral; only the final presentation passes through this map.
  static const Map<String, String> _terms = <String, String>{
    // Species.
    '橘猫': 'Orange Tabby',
    '柴犬': 'Shiba Inu',
    '垂耳兔': 'Lop Rabbit',
    '仓鼠': 'Hamster',
    '乌龟': 'Tortoise',
    '鹦鹉': 'Parrot',
    '玉米蛇': 'Corn Snake',
    '变色龙': 'Chameleon',
    '小火龙': 'Emberling',
    '独角兔尼可': 'Niko the Uni-Rabbit',
    '小幽灵噗噗': 'Boo the Little Ghost',
    '星星虫': 'Starbug',

    // Personalities and action labels.
    '贪吃': 'Foodie',
    '慵懒': 'Laid-back',
    '好奇': 'Curious',
    '胆小': 'Shy',
    '活力': 'Spirited',
    '黏人': 'Affectionate',
    '高冷': 'Aloof',
    '淘气': 'Playful',
    '温柔': 'Gentle',
    '爱幻想': 'Dreamy',
    '慵懒、贪吃、晒太阳': 'Laid-back · Foodie · Sunbather',
    '忠诚、傻乐、拆家未遂': 'Loyal · Cheerful · Lovably Mischievous',
    '软糯、胆小、爱啃': 'Soft · Shy · Loves to Nibble',
    '囤货、腮帮、跑轮': 'Collector · Chubby Cheeks · Wheel Runner',
    '慢悠悠、长情、缩壳': 'Unhurried · Devoted · Shell-Shy',
    '话痨、学舌、显摆': 'Chatty · Mimic · Show-Off',
    '高冷、蜷缩、蜕皮': 'Aloof · Coiled · Ever-Changing',
    '慢动作、变色、伪装': 'Unhurried · Colorful · Camouflaged',
    '怕生的小暖炉': 'A shy, warm-hearted companion',
    '独角兽幼体': 'A young unicorn rabbit',
    '害羞的白团子幽灵': 'A shy, cloud-soft ghost',
    '会眨眼的草丛': 'A twinkling friend from the grass',
    '喂食': 'Feed',
    '摸头': 'Pet',
    '玩具': 'Play',
    '洗澡': 'Bathe',

    // Achievements and hidden clues.
    '第一次目送': 'First Farewell',
    '三段相伴': 'Three Shared Journeys',
    '五段相伴': 'Five Shared Journeys',
    '八次启程': 'Eight Departures',
    '十二段相伴': 'Twelve Shared Journeys',
    '第一次长大': 'First Growth Spurt',
    '初见成年': 'First Grown-Up Form',
    '六十个早安': 'Sixty Good Mornings',
    '图鉴点灯人': 'Compendium Lamplighter',
    '三次相遇': 'Three Times Together',
    '五色斑斓': 'Every Shade of Friendship',
    '童话住进了院子': 'A Fairytale Moved In',
    '第一位客人': 'First Visitor',
    '好客之家': 'Open-Door Garden',
    '六次难得相遇': 'Six Rare Encounters',
    '稀客常来': 'Rare Guests, Warm Welcome',
    '门庭若市': 'A Garden Full of Friends',
    '远方的第一声问候': 'First Hello from Afar',
    '集邮爱好者': 'Stamp Collector',
    '一抽屉的远方': 'A Drawer Full of Faraway Places',
    '邮戳收藏家': 'Postmark Collector',
    '盖满整个世界': 'Stamps Around the World',
    '八方来信': 'Letters from Every Direction',
    '五段旅程': 'Five Journeys',
    '十次归来': 'Ten Returns',
    '院子永远留着位置': 'A Place to Return To',
    '朋友带朋友': 'Friends Bring Friends',
    '远方的二十份心意': 'Twenty Gifts from Afar',
    '一百次问候': 'One Hundred Hellos',
    '熟悉的手心': 'A Familiar Touch',
    '饭点守时人': 'Always on Time for Meals',
    '千顿饭的交情': 'A Thousand Meals Together',
    '泡泡专家': 'Bubble Expert',
    '泡泡浴大师': 'Bubble Bath Master',
    '两百次游戏': 'Two Hundred Games',
    '院子里的游乐场': 'The Garden Playground',
    '树荫初成': 'First Patch of Shade',
    '满庭花光': 'Garden Aglow',
    '传说中的院子': 'Garden of Legends',
    '换新装': 'A Fresh Look',
    '百变小院': 'Garden of Many Moods',
    '八种院景': 'Eight Garden Views',
    '四季来信': 'Letters Through the Seasons',
    '晴雨雪来信': 'Letters in Every Weather',
    '雨天的一顿饭': 'A Rainy-Day Meal',
    '七次日安': 'Seven Good Mornings',
    '三十次日安': 'Thirty Good Mornings',
    '一百个日安': 'One Hundred Good Mornings',
    '故事收集者': 'Story Collector',
    '一本写满的故事书': 'A Storybook Filled to the Last Page',
    '温柔的决定': 'A Gentle Choice',
    '守夜人': 'Night Watch',
    '听雨的人': 'Rain Listener',
    '火焰的朋友': 'Friend of the Flame',
    '老朋友': 'Old Friend',
    '热闹的一天': 'A Lively Day',
    '彩虹留下的脚印': 'Rainbow Footprints',
    '午夜的朋友': 'Midnight Friend',
    '草丛里的星星': 'A Star in the Grass',
    '初雪的脚注': 'First Snow Footnote',
    '愿望回音': 'Echo of a Wish',
    '什么也没发生的一天': 'A Day When Nothing Happened',
    '名字的重量': 'The Weight of a Name',
    '等日出的人': 'Waiting for Sunrise',
    '雷雨里的怀抱': 'Held Through the Storm',
    '听雪的人': 'Snow Listener',
    '月亮的常客': 'A Regular Under the Moon',
    '传说的收信人': 'Keeper of Legendary Letters',
    '深夜公开课': 'Midnight Lecture',
    '一路来信': 'Letters All Along',
    '同学会': 'Reunion',
    '朋友的朋友': 'A Friend of a Friend',
    '四季的目送': 'Farewells Through Four Seasons',
    '向着朝阳出发': 'Setting Out at Sunrise',
    '完整的一天': 'A Complete Day',
    '一岁又一岁': 'Year After Year',
    '会飞的花': 'A Flower in Flight',
    '雨后的白影': 'White Shadow After Rain',
    '旧手账的读者': 'Reader of Old Journals',
    '夜航信': 'A Letter on the Night Wind',
    '口是心非观察员': 'Mixed-Signals Expert',
    '有人在星星最亮时来过。': 'Someone passed by when the stars were brightest.',
    '雨声也是一种陪伴。': 'Rain can be a kind of company.',
    '它记得那盏灯。': 'It remembers that light.',
    '有些告别只是换个方式见面。': 'Some goodbyes simply become another way to meet.',
    '那天院子里挤满了故事。': 'That day, the garden was full of stories.',
    '雨停之后，有人没急着收伞。':
        'After the rain, someone lingered beneath an open umbrella.',
    '院子最安静的时候，也有人陪你。': 'Even at its quietest, the garden keeps you company.',
    '有一盏灯，是为会眨眼的草丛点的。': 'One light was left on for the blinking grass.',
    '雪地记得每一串脚印。': 'The snow remembers every trail of footprints.',
    '有些话说给流星听，流星会替你带到。':
        'Tell a wish to a shooting star, and it may carry the words for you.',
    '其实什么都发生了，只是很轻。': 'Everything happened that day. It was simply very quiet.',
    '每个名字都被认真念过。': 'Every name was spoken with care.',
    '天亮之前的院子，只有一盏灯醒着。': 'Before dawn, only one garden light was awake.',
    '雷声很大，但有人的心跳更近。': 'The thunder was loud, but a heartbeat was closer.',
    '雪落下来的声音，其实听得见。': 'If you listen closely, falling snow has a sound.',
    '圆月夜的院子，会多摆一副茶杯。':
        'On full-moon nights, the garden sets out one more teacup.',
    '四个传说，都路过了同一个院子。': 'Four legends all passed through the same garden.',
    '教授的课，只在会眨眼的草丛边开讲。':
        "The professor's class begins only beside the blinking grass.",
    '每一封信，都在相册里找到了位置。': 'Every letter found its place in the album.',
    '老同学们像是约好了似的。':
        'Old friends returned as though they had planned it together.',
    '它的朋友，也想来看看你的院子。':
        'A friend of your friend would like to visit the garden too.',
    '院子送走过四个季节的背影。': 'The garden has watched a traveler leave in every season.',
    '有一场告别，选在了日出时分。': 'One farewell was saved for sunrise.',
    '那一天，每一种陪伴都刚刚好。': 'That day, every kind of care felt just right.',
    '新年的第一声问候，先给了它。': "The year's first hello belonged to your friend.",
    '有一朵会飞的花，找到了最安稳的枝头。': 'A flower in flight found the safest branch.',
    '雨停以后，彩虹落下的地方闪过一抹白。':
        'After the rain, a white shape flashed where the rainbow touched down.',
    '有人常常翻起旧照片。': 'Someone often returns to the old photographs.',
    '夜深时，邮箱里也会亮起一盏小灯。':
        'Late at night, a light can still appear in the mailbox.',
    '它说不在意，却总记得回头。':
        'They pretend not to care, yet always remember to look back.',

    // Travel locations.
    '猫背礁': "Cat's Back Reef",
    '灯塔海湾': 'Lighthouse Bay',
    '贝壳镇': 'Seashell Town',
    '退潮沙洲': 'Low-Tide Sandbar',
    '海雾码头': 'Sea Mist Pier',
    '云顶垭口': 'Cloudtop Pass',
    '温泉猴谷': 'Monkey Hot Springs',
    '枫火岭': 'Maplefire Ridge',
    '雪线木屋': 'Snowline Cabin',
    '回声峡谷': 'Echo Canyon',
    '电车老街': 'Old Tram Street',
    '屋顶水塔城': 'Rooftop Water Tower City',
    '深夜面馆街': 'Midnight Noodle Street',
    '旧书坊巷': 'Old Bookshop Alley',
    '摩天轮码头': 'Ferris Wheel Wharf',
    '麦浪邮局': 'Wheatfield Post Office',
    '向日葵车站': 'Sunflower Station',
    '萤火稻田': 'Firefly Rice Fields',
    '苹果坡农场': 'Apple Hill Farm',
    '风车塘': 'Windmill Pond',
    '蘑菇环林地': 'Mushroom Ring Grove',
    '千年橡树邮筒': 'Ancient Oak Postbox',
    '松果集市': 'Pinecone Market',
    '雾中吊桥': 'Misty Rope Bridge',
    '伐木温居': "Woodcutter's Lodge",
    '星空盐湖': 'Starlit Salt Lake',
    '驼铃绿洲': 'Camel Bell Oasis',
    '彩绘集市': 'Painted Bazaar',
    '风蚀石林': 'Wind-Carved Stone Forest',
    '热气球营地': 'Hot-Air Balloon Camp',
    '极光渔村': 'Aurora Fishing Village',
    '浮冰灯塔': 'Ice-Floe Lighthouse',
    '蓝洞泉': 'Blue Grotto Spring',
    '运河小城': 'Canal Town',
    '汽船栈桥': 'Steamboat Pier',
    '云端牧场': 'Cloudtop Ranch',
    '月亮背面的邮局': 'Far-Side Moon Post Office',
    '糖霜火山': 'Frosting Volcano',
    '会走路的岛': 'Wandering Island',
    '星星修理铺': 'Star Repair Shop',

    // Visitors.
    '麻雀啾啾': 'Chirpy the Sparrow',
    '流浪三花猫': 'Wandering Calico',
    '蜗牛慢递员': 'Slow-Mail Snail',
    '白粉蝶': 'Cabbage White',
    '小刺猬球球': 'Pip the Hedgehog',
    '鸽子咕咕': 'Coo the Pigeon',
    '松鼠栗栗': 'Chestnut the Squirrel',
    '乌鸦亮亮': 'Shiny the Crow',
    '青蛙呱太': 'Ribbit the Frog',
    '萤火虫群': 'Firefly Parade',
    '橘色狸猫': 'Ginger Tanuki',
    '白鹭先生': 'Mr. Egret',
    '狐狸小茜': 'Sienna the Fox',
    '猫头鹰教授': 'Professor Owl',
    '小鹿': 'Little Fawn',
    '雪兔': 'Snow Hare',
    '篝火夜的火光': 'Campfire Glow',
    '彩虹边的白影': 'The Rainbow\'s White Shadow',
    '深夜白团子': 'Midnight Puff',

    // Shop.
    '樱花小径': 'Cherry Blossom Path',
    '星夜帐篷': 'Starlit Tent',
    '海风假日': 'Seaside Holiday',
    '秋日果酱': 'Autumn Jam',
    '雪屋暖灯': 'Snowy Cabin Glow',
    '雨季青苔': 'Rainy Moss Garden',
    '糖果焙房': 'Candy Bakehouse',
    '四季花园': 'Four Seasons Garden',
    '青竹茶亭': 'Bamboo Tea Pavilion',
    '月光温室': 'Moonlit Greenhouse',
    '麦浪风筝': 'Wheatfield Kites',
    '陶瓷小水碗': 'Ceramic Water Bowl',
    '夜灯': 'Night-Light',
    '暖炉': 'Cozy Fireplace',
    '亮闪闪风铃': 'Shimmering Wind Chime',
    '野花花坛箱': 'Wildflower Planter',
    '蘑菇石凳': 'Mushroom Stone Seat',
    '稻草人邮差': 'Scarecrow Postie',
    '星星风向标': 'Star Weather Vane',
    '木牌门号「1号院」': 'Wooden Sign · Garden No. 1',
    '谷粒袋 ×3 盘': 'Grain Pouch ×3',
    '小鱼干 ×3 盘': 'Dried Fish ×3',
    '坚果罐 ×3 盘': 'Nut Jar ×3',
    '苹果片 ×3 盘': 'Apple Slices ×3',
    '三文鱼小饼干 ×5': 'Salmon Biscuits ×5',
    '彩虹果冻 ×3': 'Rainbow Jelly ×3',
    '蜂蜜燕麦圈 ×5': 'Honey Oat Rings ×5',
    '泡泡浴皂 ×2': 'Bubble Bath Soap ×2',
    '会咕咕叫的毛线球': 'Cooing Yarn Ball',
    '发条小鸭': 'Wind-Up Duck',
    '藤编逗猫棒': 'Wicker Teaser Wand',
    '软木飞盘': 'Cork Flying Disc',
    '相册皮肤·牛皮纸': 'Album Cover · Kraft Paper',
    '相册皮肤·蓝格纹野餐布': 'Album Cover · Blue Picnic Check',
    '相册皮肤·干花押纸': 'Album Cover · Pressed Flowers',
    '图鉴皮肤·星图夜航': 'Compendium Cover · Star Chart',

    // Content categories.
    '乡野': 'Countryside',
    '山地': 'Highlands',
    '奇幻': 'Wonderlands',
    '极地水域': 'Polar Waters',
    '沙漠异域': 'Desert Lands',
    '夜间': 'nighttime',
    '清晨': 'morning',
    '雨天': 'rainy-day',
    '秋日': 'autumn',
    '季节限定': 'seasonal',
    '鸟类': 'bird',
    '猫与白鹭': 'cat and egret',
    '兔与小鹿': 'rabbit and deer',
  };

  static const Map<String, String> _copy = <String, String>{
    '设置': 'Settings',
    '收藏与设置': 'Collection & Settings',
    '声音': 'Sound',
    '背景音乐': 'Music',
    '互动音效': 'Interaction Sounds',
    '轻柔触感': 'Gentle Haptics',
    '画面': 'Visuals',
    '画面质量': 'Visual Quality',
    '自动': 'Auto',
    '精致': 'Detailed',
    '省电': 'Saver',
    '温柔提醒': 'Gentle Reminders',
    '允许通知': 'Allow Notifications',
    '存档与隐私': 'Saves & Privacy',
    '导出存档': 'Export Save',
    '导入存档': 'Import Save',
    '隐私说明': 'Privacy',
    '支持小院': 'Support the Garden',
    '帮助与支持': 'Help & Support',
    '开源许可': 'Open-Source Licenses',
    '版本': 'Version',
    '语言': 'Language',
    '跟随系统': 'Use Device Language',
    '简体中文': 'Simplified Chinese',
    '英语': 'English',
    '系统': 'Device',
    '简中': '简中',
    '跟随设备语言，也可以在应用内固定选择。':
        'Follow your device, or choose a language just for Petopia.',
    '使用设备语言；暂不支持的语言会显示英语。':
        'Uses your device language. Unsupported languages fall back to English.',
    '固定使用简体中文。': 'Always use Simplified Chinese.',
    'Use English throughout the app.': 'Use English throughout the app.',
    '关闭': 'Close',
    '取消': 'Cancel',
    '继续': 'Continue',
    '确认': 'Confirm',
    '再试一次': 'Try Again',
    '读取中': 'Loading',
    '正在连接': 'Connecting',
    '测试：推进一天': 'Testing: advance one day',
    '正在推进内测时间': 'Advancing test time',
    '内测时间已推进 1 天': 'Test time advanced by 1 day',
    '设置暂时没有翻开': 'Settings are temporarily unavailable',
    '音乐和互动音效可以分别保留。': 'Choose music and interaction sounds separately.',
    '院子、相册和毕业旅程的情境音乐。': 'Music for the garden, album, and journeys.',
    '保留铃声、升级和点击的柔和声音。': 'Soft chimes for taps, growth, and special moments.',
    '摸摸、成长和告别时的轻触反馈，可独立关闭。': 'A gentle tap for care, growth, and goodbyes.',
    '自动档会保持完整质感，并在系统内存紧张时安静降级。':
        'Keeps the full look, then eases the load when needed.',
    '推荐。优先预热常用互动，系统有压力时自动保护。':
        'Recommended. Preloads common actions and adapts when needed.',
    '优先预热全部互动；内存紧张时仍会暂时降低负载。':
        'Preloads every action, with safeguards under memory pressure.',
    '保留宠物和互动反馈，减少背景动态且不预热动作。':
        'Keeps pets and feedback crisp while reducing background motion.',
    '只提醒真实发生的事情，每天最多一条。':
        'Only for real arrivals and moments, at most once a day.',
    '不会发送连续登录、催促回来或倒计时提醒。': 'No streaks, return nudges, or countdown alerts.',
    '系统没有允许通知；需要时可在系统设置中重新开启。':
        'Notifications are off. You can enable them in iOS Settings anytime.',
    '进度默认只保存在当前设备。': 'Your progress stays on this device by default.',
    '生成带完整性校验的备份文件，可存到“文件”或其他位置。':
        'Create a verified backup for Files or another safe location.',
    '导入前会验证格式、校验码和经验/暖绒流水。':
        'Checks the file, checksum, XP, and Sunfluff history first.',
    '查看本地存档、通知和第三方服务的说明。':
        'See how saves, notifications, and third-party services work.',
    '查看常见问题，或通过支持页面联系我们。':
        'Read common answers or contact us through the support page.',
    '查看 Flutter 与第三方开源组件的许可证。':
        'View licenses for Flutter and other open-source components.',
    '导出诊断信息': 'Export Diagnostics',
    '仅分享版本与运行状态，不包含昵称、明信片正文或设备标识。':
        'Includes app status only—not names, postcard text, or device IDs.',
    '存档已经准备好，可选择保存位置。': 'Your backup is ready. Choose where to save it.',
    '存档已经恢复。': 'Your garden has been restored.',
    '存档未通过校验，当前院子保持不变。':
        'That backup could not be verified. Your current garden is unchanged.',
    '导入没有完成，当前院子保持不变。':
        'Import did not finish. Your current garden is unchanged.',
    '这次没有导出成功，当前存档没有受到影响。': 'Export did not finish. Your save is safe.',
    '这次没有导出成功，请稍后再试。': 'Export did not finish. Please try again.',
    '诊断信息已经准备好，可发送给支持人员。': 'Diagnostics are ready to share with support.',
    '暂时无法打开网页，请稍后再试。': 'That page could not open. Please try again.',
    '导入这份院子存档？': 'Restore this garden backup?',
    '导入会替换当前进度。文件会先完整校验；任何一步失败都会保留现在的院子。':
        'This replaces current progress after a full verification. If any check fails, your garden stays untouched.',
    '校验并导入': 'Verify & Import',
    '正在校验存档…': 'Verifying backup…',
    'Petopia 存档': 'Petopia Save',
    'Petopia 存档备份': 'Petopia Save Backup',
    'Petopia 诊断信息': 'Petopia Diagnostics',
    '关于': 'About',
    '本地保存 · 无账号 · 无广告追踪': 'Saved locally · No account · No ad tracking',
    '商店': 'Shop',
    '暖绒商店': 'Sunfluff Shop',
    '暖绒余额': 'Sunfluff Balance',
    '今天的暖绒余额': "Today's Sunfluff",
    '去商店看看': 'Visit the Shop',
    '兑换': 'Get',
    '兑换中': 'Getting…',
    '可兑换': 'Available',
    '已拥有': 'Owned',
    '使用中': 'In Use',
    '应用': 'Use',
    '暖绒不够': 'Not Enough Sunfluff',
    '全部': 'All',
    '院子主题': 'Garden Themes',
    '装饰小物': 'Decor',
    '特殊食粮': 'Special Treats',
    '特殊玩具': 'Special Toys',
    '相册装帧': 'Album Covers',
    '商店暂时没有开门': 'The shop is temporarily unavailable',
    '商店货架还在整理': 'The shelves are still being arranged',
    '等新商品上架后，这里会变得热闹起来。': 'New finds will appear here soon.',
    '换一点小院会喜欢的东西。': 'Pick out something lovely for the garden.',
    '暖绒不足，或这件物品已经拥有。': 'You may need more Sunfluff, or already own this item.',
    '这次没有兑换成功，暖绒和物品都没有变化。': 'Nothing changed. Please try again.',
    '成就': 'Achievements',
    '成就册暂时没有翻开': 'Achievements are temporarily unavailable',
    '成就册还没有页签': 'Your achievement book is still blank',
    '等小院发生更多故事，这里会贴上新的印章。':
        'New stamps will appear as your garden story grows.',
    '已达成': 'Completed',
    '进行中': 'In Progress',
    '未记录': 'Not Yet',
    '纪念收藏': 'Keepsake',
    '主题折扣券': 'Theme Coupon',
    '纪念贴纸': 'Keepsake Sticker',
    '纪念章': 'Keepsake Badge',
    '累计': 'Total',
    '线索': 'Clue',
    '隐藏': 'Hidden',
    '隐藏成就还没有露出线索。': 'This hidden achievement has not revealed a clue yet.',
    '线索还藏在院子的某一页。': 'The clue is still tucked somewhere in the garden.',
    '线索几乎完整：那团火光已经记住院子，再相遇一次也许就会留下。':
        'The clue is nearly complete: the flame remembers this garden and may stay after one more meeting.',
    '线索几乎完整：雨后的白色身影已经很近了，下一场彩虹里也许会再靠近。':
        'The clue is nearly complete: the white shape may come closer with the next rainbow.',
    '线索几乎完整：午夜的空食盘旁，只差最后一次轻轻的脚步。':
        'The clue is nearly complete: one more midnight visit may leave tracks beside the empty dish.',
    '线索几乎完整：草丛里的星光正试着认出这座院子。':
        'The clue is nearly complete: the starlight in the grass is beginning to recognize this garden.',
    '线索已经很清晰了，也许下一次相遇就会有答案。':
        'The clue is clear now. The next meeting may bring an answer.',
    '寒夜里的火光不只是路过，它似乎在寻找一座愿意为来客留灯的院子。':
        'The flame in the winter night seems to be looking for a garden with a lantern for visitors.',
    '那道白色身影常在雨停后、彩虹刚出现时靠近。':
        'The white shape often draws near just after the rain, when a rainbow first appears.',
    '夜深以后，安静又空着的食盘会让害羞的脚步更靠近。':
        'Late at night, a quiet, empty dish may draw shy footsteps closer.',
    '晴朗夜里，温柔的灯和不被打扰的草丛会让星光停得更久。':
        'On clear nights, a warm lantern and undisturbed grass invite the starlight to linger.',
    '这一页已经盖上完成章。': 'This page now has its completion stamp.',
    '宠物图鉴': 'Pet Compendium',
    '宠物图鉴暂时没有翻开': 'The pet compendium is temporarily unavailable',
    '图鉴还是空白页': 'The compendium is still blank',
    '已养过': 'Met Before',
    '可领养': 'Available',
    '未遇见': 'Not Met',
    '来客图鉴': 'Visitor Compendium',
    '来客图鉴暂时没有翻开': 'The visitor book is temporarily unavailable',
    '来客册还是空白页': 'The visitor book is still blank',
    '等院子里有访客停留，这里会贴上第一张小贴纸。':
        'Your first visitor sticker will appear after someone stops by.',
    '尚未收录的来客': 'Undiscovered Visitor',
    '常见': 'Common',
    '不常见': 'Uncommon',
    '稀有': 'Rare',
    '传说': 'Legendary',
    '常见来客': 'Common visitor',
    '不常见来客': 'Uncommon visitor',
    '稀有来客': 'Rare visitor',
    '传说来客': 'Legendary visitor',
    '相遇回忆': 'Shared Memory',
    '翻看相遇回忆': 'Read This Memory',
    '成长手账': 'Growth Journal',
    '成长手账暂时没有翻开': 'The growth journal is temporarily unavailable',
    '成长记录暂时没有翻开': 'Growth notes are temporarily unavailable',
    '还没有写下成长脚印': 'No growth notes yet',
    '每一天的相处，都会悄悄写进属于你们的手账。':
        'Every day together leaves a quiet note in your shared journal.',
    '成长进度': 'Growth',
    '慢慢长大的时刻': 'Milestones Along the Way',
    '幼年 A 档': 'Stage A · Young',
    '少年 B 档': 'Stage B · Growing',
    '成年 C 档': 'Stage C · Adult',
    '旅装 D 档': 'Stage D · Travel Ready',
    '已达到最高等级': 'Maximum level reached',
    '已经准备好背起行囊': 'Ready to pack for the journey',
    '翻开成长手账': 'Open Growth Journal',
    '相册': 'Album',
    '默认手账': 'Classic Journal',
    '牛皮纸': 'Kraft Paper',
    '蓝格野餐': 'Blue Picnic Check',
    '干花押纸': 'Pressed Flowers',
    '星图夜航': 'Star Chart',
    '旧船票': 'Old Ferry Ticket',
    '环球邮差': 'World Postie',
    '岁月手账': 'Keepsake Journal',
    '明信片': 'Postcards',
    '旅行明信片': 'Travel Postcards',
    '旅行伙伴': 'Traveling Friends',
    '全部伙伴': 'All Friends',
    '全部地点': 'All Places',
    '这组筛选还没有明信片\n换一位伙伴或地点看看':
        'No postcards match this view.\nTry another friend or place.',
    '这里会收好旅途中寄回的每一封信。': 'Every letter from the road will be kept here.',
    '还没有毕业的旅行伙伴\n把宠物养到毕业，它就会踏上旅途 🎒':
        'No traveling friends yet.\nHelp a pet grow, and a journey will begin.',
    '也许很快会有新信': 'A new letter may arrive soon',
    '这几天也许会有新信': 'A new letter may arrive in a few days',
    '会在合适的时候来信': 'A letter will arrive when the time is right',
    '它正在慢慢走下一段路': 'Wandering toward the next stop',
    '收进相册': 'Save to Album',
    '先拆开最新一张，其余已经收进相册':
        'Open the newest one first. The rest are safe in your album.',
    '领养': 'Adopt',
    '领养新伙伴': 'Welcome a New Friend',
    '伙伴名字': "Friend's Name",
    '给它取个名字': 'Choose a Name',
    '挑一只想要陪伴的小伙伴，给它取个名字吧': 'Choose a friend to share the garden with.',
    '去迎接第一位伙伴': 'Welcome Your First Friend',
    '正在迎接…': 'Welcoming…',
    '开启下一段安静的陪伴': 'Begin a New Chapter Together',
    '院子在等新朋友': 'The garden is waiting for a new friend',
    '这里总会为一位小伙伴，留下一片柔软的草地。':
        'The garden keeps a welcoming patch of grass for each new friend.',
    '先摸摸头': 'Start with a pat',
    '再喂点东西': 'Offer a treat',
    '陪它吃点东西、摸摸头，手账就会慢慢写下新的故事。':
        'Share a snack and a pat. Your journal will soon have a new story.',
    '跳过': 'Skip',
    '知道了': 'Got It',
    '今日院子': "Today's Garden",
    '今天': 'Today',
    '昨天': 'Yesterday',
    '今日': 'Today',
    '今日已完成': 'Done for Today',
    '随心完成': 'At Your Own Pace',
    '今天也慢慢来。': 'Take today at your own pace.',
    '摸头': 'Pet',
    '喂食': 'Feed',
    '玩具': 'Play',
    '洗澡': 'Bathe',
    '摸摸宠物': 'Pet your friend',
    '在院子里好好休息': 'Rest in the garden',
    '再陪它一会儿': 'Stay a While',
    '陪它慢慢长大': 'Grow Together',
    '准备启程 · 举行毕业典礼': 'Celebrate Graduation',
    '毕业不是告别。它会背起行囊，从旅途中继续给你写信。':
        'Graduation is not goodbye. Your friend will pack for the journey and keep writing from the road.',
    '第一程，想让它往哪里走？': 'Where should the first journey lead?',
    '海滨': 'Coast',
    '森林': 'Forest',
    '城市': 'Town',
    '有海风的地方': 'Where the sea breeze wanders',
    '树影深处': 'Beneath the forest shade',
    '热闹的街灯': 'Toward the glowing streets',
    '送它去旅行  🎒': 'Send Them Off',
    '正在收拾行囊…': 'Packing for the journey…',
    '回到小院': 'Back to the Garden',
    '回到院子': 'Back to the Garden',
    '毕业了': 'Graduated',
    '欢迎回家': 'Welcome Home',
    '院子醒来了': 'The garden is awake',
    '小院正在醒来': 'Waking the garden…',
    '小院暂时没有醒来': 'The garden could not open',
    '先歇一下再试，院子里的记录都还在。': 'Please try again shortly. Your garden data is safe.',
    '手账': 'Journal',
    '打开手账': 'Open Journal',
    '关闭手账': 'Close Journal',
    '院子记住的事': 'Garden Memories',
    '等第一位朋友入住后，这里会贴上新的小标签。':
        'New notes will appear after your first friend moves in.',
    '今天的来客': "Today's Visitor",
    '访客': 'Visitor',
    '院子里来了新朋友': 'A New Friend Stopped By',
    '和它打个招呼': 'Say Hello',
    '收进来客图鉴': 'Save to Visitor Book',
    '这段相遇已经收进来客图鉴。': 'This meeting is now tucked into your visitor book.',
    '老朋友回访': 'An Old Friend Returns',
    '回访': 'Returning Friend',
    '远方': 'From Afar',
    '离线陪伴': 'While You Were Away',
    '日常事件': 'Daily Moment',
    '特别事件': 'Special Moment',
    '本次收获': 'Rewards',
    '记进手账': 'Save to Journal',
    '慢慢来，进度已经记在手账里。': 'No rush. Your progress is safely noted in the journal.',
    '达成成就': 'Achievement Unlocked',
    '支持页面暂时没有打开。\n请稍后再试。':
        'Support is temporarily unavailable.\nPlease try again shortly.',
    '自愿支持与装饰回礼。': 'Optional support and cosmetic thank-yous.',
    '支持选项': 'Ways to Support',
    '支持完全自愿，装饰回礼不会影响成长与收集。':
        'Support is optional. Cosmetic thank-yous do not affect growth or collecting.',
    '自愿支持 Petopia': 'Support Petopia',
    '支持完全自愿。所有回礼都只是装饰，不会影响成长、收集或概率。':
        'Support is optional. Every thank-you is cosmetic and does not affect progression, collecting, or odds.',
    '一份小点心': 'A Treat',
    '点心会在院子里保留 24 小时，伙伴也会来尝一口。':
        'A treat will stay in the garden for 24 hours, and your friend will stop by for a bite.',
    '点心已经放进院子，将保留 24 小时。感谢你的支持。':
        'The treat is now in the garden and will remain for 24 hours. Thank you for supporting Petopia.',
    '点亮一盏暖灯': 'A Warm Lantern',
    '暖灯会在院子里亮 24 小时。': 'The lantern will glow in the garden for 24 hours.',
    '暖灯已经点亮，将持续 24 小时。感谢你的支持。':
        'The lantern is lit for the next 24 hours. Thank you for supporting Petopia.',
    '送来一篮花': 'Garden Bouquet',
    '花篮会在院子里展示七天。':
        'The bouquet will be displayed in the garden for seven days.',
    '花篮已经放进院子，会展示七天。感谢你的支持。':
        'The bouquet is in the garden and will be displayed for seven days. Thank you for supporting Petopia.',
    '小院守护者': 'Garden Keeper',
    '永久点亮守护灯，并解锁纪念徽章和一张特别来信。':
        'Keep the garden lantern lit permanently and unlock a keepsake badge and special letter.',
    '所有回礼均为装饰性内容，不会改变成长、暖绒、冷却、稀有度或可玩内容。':
        'All thank-yous are cosmetic. They do not affect growth, Sunfluff, cooldowns, rarity, or playable content.',
    '购买由 App Store 处理。前三项是有固定展示时长的可重复装饰；小院守护者为一次性购买，可恢复。':
        'Purchases are handled by the App Store. The first three are repeatable decorations with fixed display durations; Garden Keeper is a one-time, restorable purchase.',
    '暂不可用': 'Unavailable',
    '可重复': 'Repeatable',
    '小院守护者已解锁': 'Garden Keeper Unlocked',
    '已解锁': 'Unlocked',
    '恢复“小院守护者”': 'Restore Garden Keeper',
    '正在恢复': 'Restoring…',
    '感谢你支持 Petopia。守护灯、纪念徽章和特别来信已经解锁。':
        'Thank you for supporting Petopia. The garden lantern, keepsake badge, and special letter are now unlocked.',
    '感谢你的支持': 'Thank You for Your Support',
    '小院的灯': 'The Garden Light',
    '守护灯已点亮': 'Garden Lantern Unlocked',
    '小院守护者特别感谢明信片': 'A Special Garden Keeper Postcard',
    '守护灯已永久解锁': 'Permanent Lantern Unlocked',
    '暖灯正在院子里亮着': 'The lantern is glowing in the garden',
    '点心正在院子里': 'A treat is in the garden',
    '鲜花正在院子里盛开': 'Fresh flowers are blooming in the garden',
    '小院守护者已恢复': 'Garden Keeper Restored',
    '完成': 'Done',
    '暂时无法写入记录，稍后会自动重试。':
        'The note could not be saved yet. We will try again automatically.',
    '小院记录已经安全补上。': 'The garden note is safely up to date.',
    'App Store 暂时没有回应，请稍后再试。':
        'The App Store did not respond. Please try again soon.',
    '当前设备暂时无法连接 App Store。':
        'This device cannot reach the App Store right now.',
    '购买没有开始，请稍后再试。': 'The purchase did not start. Please try again soon.',
    '购买没有完成，请检查 App Store 后重试。':
        'The purchase did not finish. Check the App Store and try again.',
    '小院守护者已经恢复。': 'Garden Keeper has been restored.',
    '恢复完成，没有找到新的永久权益。': 'Restore complete. No new permanent unlock was found.',
    '暂时无法恢复购买，请稍后再试。':
        'Purchases could not be restored. Please try again soon.',
    '心意已经收到，但回礼暂时没有保存好。请保持网络连接后重试。':
        'Your support was received, but the thank-you could not be saved. Stay online and try again.',
    '购买已取消，没有产生费用。': 'Purchase canceled. You were not charged.',
    '购买没有完成，请稍后再试。': 'The purchase did not finish. Please try again soon.',
    'App Store 正在确认这次支持，权益不会重复发放。':
        'The App Store is confirming your support. Your thank-you will only be granted once.',
    '数据': 'Data',
    '通知由你决定': 'Notifications Are Your Choice',
    '你的院子只留在设备上': 'Your Garden Stays on Your Device',
    '第三方服务': 'Third-Party Services',
    '删除数据': 'Deleting Your Data',
    '查看完整隐私政策': 'View Full Privacy Policy',
    '联系支持': 'Contact Support',
    '生效日期：2026 年 7 月 27 日': 'Effective July 27, 2026',
    '源代码使用 Apache-2.0；美术与音频为 Petopia 专有素材。':
        'Source code uses Apache-2.0. Petopia artwork and audio are proprietary.',
    'Petopia 专有素材 · 禁止单独转载':
        'Petopia proprietary assets · Redistribution prohibited',
    'App 只在设备上保存回礼类型、交易幂等键和有效期，用于防止重复发放并展示装饰。普通支持不会写入可导出的游戏存档，也不会改变经验、暖绒、冷却或概率。':
        'Petopia keeps only the thank-you type, transaction key, and expiry on this device so rewards are never granted twice. Regular support never enters your exported save or changes XP, Sunfluff, cooldowns, or odds.',
    'Petopia 不要求注册账号，也不会把宠物、明信片、互动记录或设备标识上传到服务器。游戏进度保存在当前设备的应用沙盒中。':
        'Petopia needs no account and does not upload pets, postcards, interactions, or device identifiers. Progress stays in the app sandbox on this device.',
    '一只刚来到院子的奶油橘色小猫': 'A cream-orange kitten, newly arrived in the garden',
    '以后会在邮箱收到它从远方寄来的信': 'Letters from the road will arrive in your mailbox',
    '伙伴毕业后会背上行囊，慢慢走过不同地方。先翻开一张旅行样片看看。':
        'After graduation, your friend packs for the road and wanders from place to place. Here is a glimpse of the journey ahead.',
    '再多陪几位朋友毕业，就能遇见它。': 'Help a few more friends graduate to meet this one.',
    '写给小院守护者': 'For a Garden Keeper',
    '准备旅行的奶油橘色小猫': 'A cream-orange kitten ready for the road',
    '卸载 App 会删除本机游戏数据和固定时长回礼记录。建议卸载或换机前导出存档；重新安装后，可从支持页恢复一次性永久的“小院守护者”。':
        'Deleting the app removes local game data and fixed-duration thank-yous. Export a save before changing devices. The permanent Garden Keeper unlock can be restored from the support page.',
    '只有在你主动开启后，App 才会请求本地通知权限。提醒仅用于明信片、老朋友回访和纪念日；可随时在设置中分类关闭，也不会使用广告追踪。':
        'Petopia asks for notification access only after you turn it on. Alerts are limited to postcards, returning friends, and anniversaries. Each category can be disabled anytime, and no ad tracking is used.',
    '存档备份': 'Save Backups',
    '它从旅途中回来串门。欢迎它回家，听听这次带回了什么故事。':
        'A traveling friend has come home for a visit. Welcome them back and hear what the road has brought.',
    '它会一路旅行，常寄明信片回来。\n院子空出来了，去迎接下一位小伙伴吧。':
        'Your friend will keep traveling and writing home.\nThe garden is ready to welcome someone new.',
    '它会在小窝附近待到明天。和它打个招呼，就能留下这次相遇。':
        'This visitor will stay near the shelter until tomorrow. Say hello to remember the meeting.',
    '它已经在路上了\n第一封信会在合适的时候寄回来':
        'The journey has begun.\nThe first letter will arrive when the time is right.',
    '它的性格': 'Personality',
    '守护灯和纪念徽章已解锁，特别来信会保存在这里。':
        'The garden lantern and keepsake badge are unlocked, and the special postcard is saved here.',
    '导出存档时，文件由你选择保存或分享的位置。导入会先校验文件完整性和数据流水，校验失败不会覆盖当前院子。':
        'You choose where exported saves are stored or shared. Imports verify file integrity and game history before replacing anything.',
    '小橘': 'Tangerine',
    '小院已安全恢复': 'Garden Restored',
    '支持与回礼': 'Support and Thank-Yous',
    '已经长大的奶油橘色小猫': 'A grown cream-orange cat',
    '当前版本不包含广告、第三方分析、跨 App 追踪、社交登录或联网内容服务。只有在你主动支持小院时，购买和恢复购买会由 Apple App Store 处理；Petopia 不会接触支付卡或 Apple ID。':
        'Petopia contains no ads, third-party analytics, cross-app tracking, social login, or online content service. If you choose to support the garden, Apple handles purchases and restores; Petopia never receives card details or your Apple ID.',
    '抱抱它': 'Give a Hug',
    '支持小院的本地记录': 'Local Support Records',
    '明写': 'Open Goals',
    '明写成就还在装订中。': 'Open goals are still being bound into the book.',
    '未知宠物': 'Unknown Pet',
    '海边': 'Seaside',
    '海风': 'Sea Breeze',
    '海风把草坡吹得软软的。我在灯塔下面坐了很久，替你看了一场很亮的日落。等真正出发以后，也会把沿途的小事一封封寄回来。':
        'The sea breeze softened the grassy hill. I sat beneath the lighthouse and watched a bright sunset for you. Once the real journey begins, I will send moments from the road home.',
    '清空': 'Clear',
    '清除筛选': 'Clear Filters',
    '灯塔湾': 'Lighthouse Bay',
    '素材': 'Assets',
    '纪念日与特殊事件': 'Anniversaries & Special Moments',
    '街灯': 'City Lights',
    '贴纸册正在慢慢填满': 'The sticker book is slowly filling up',
    '还没有可摆放的小物。去商店买到装饰后，就能指定到院子的固定位置。':
        'No decor is ready to place yet. Find something in the shop, then choose its garden spot.',
    '这是一份 Petopia 院子存档备份。': 'This is a Petopia garden save backup.',
    '远处还跟着一位害羞的旅行伙伴。': 'A shy traveling friend is following in the distance.',
    '远方也会寄回回忆': 'Memories Still Arrive from Afar',
    '选择一个槽位，再点已拥有的小物；同一个小物只会出现在一个位置。':
        'Choose a spot, then select owned decor. Each item can appear in only one place.',
    '道具加成': 'Item Bonus',
    '院子布置': 'Garden Layout',
    '院子布置暂时没有打开': 'Garden layout is temporarily unavailable',
    '院子来客贴纸册': 'Garden Visitor Sticker Book',
    '预览旅行明信片': 'Preview a Travel Postcard',
    '四季花园 5 折券': 'Four Seasons Garden · 50% Off',
    '糖果焙房 8 折券': 'Candy Bakehouse · 20% Off',
    '任意主题 5 折券': 'Any Garden Theme · 50% Off',
    '翻开今天刚写下的新故事': "Read today's new story",
    '旅行者': 'Traveler',
    '完整更换院子的季节、光影与景色': "Transforms the garden's season, light, and scenery",
    '可自由摆进院子，也可能吸引特别来客':
        'Place it anywhere in the garden. A special visitor may notice',
    '更换相册纸张与收藏页的整体气氛': 'Changes the paper and mood throughout your album',
  };
}
