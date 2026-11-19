import 'package:flutter/material.dart';

import '../l10n/petopia_localizations.dart';
import 'petopia_theme.dart';

/// 统一 UI 美术助手：把语义名映射到 assets/art/ui/ 下的水彩图标/徽章，
/// 缺图回落到 Material Icon，绝不崩。集中管理避免各屏散落 Image.asset。
///
/// 命名对应文件：`ui_icon_{name}.png` / `ui_badge_{name}.png`。
/// 常用 name：
///  - 动作 act_feed / act_pat / act_toy / act_bath / act_photo
///  - 食物 food_apple / food_fish / food_grain / food_nut / food_empty
///  - 导航 nav_yard / nav_album / nav_codex / nav_shop / nav_menu
///  - 成就 ach_care / ach_firstadopt / ach_firstgrad / ach_postcard /
///         ach_revisit / ach_visitor / ach_yard / ach_hidden_q
///  - 来源 src_feed / src_pat / src_toy / src_bath / src_event /
///         src_offline / src_revisit / src_visitor
///  - 事件 event_keepsake
///  - 设置 set_music / set_sound / set_notif / set_save / set_about / set_credits
///  - 商店 shop_theme / shop_deco / shop_food / shop_toy / shop_albumskin
///  - 天气 wx_sunny / wx_rain / wx_snow / wx_wind
///  - 时段 tm_morning / tm_noon / tm_dusk / tm_night
///  - 杂项 back / close / bell / gift / dice / flip / hourglass_wc /
///         warmfluff / warmfluff_lg
///
/// VoiceOver：图标默认视为装饰（旁边总有文字或按钮自带说明），不进入无障碍树，
/// 否则 VoiceOver 会念出一个没有名字的"图像"。图标本身承载信息时传
/// [semanticLabel]（中文源串，内部按当前语言翻译）。
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final IconData fallback;
  final String? semanticLabel;
  const AppIcon(
    this.name, {
    super.key,
    this.size = 28,
    this.fallback = Icons.circle,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel == null ? null : context.tr(semanticLabel!);
    return Image.asset(
      'assets/art/ui/ui_icon_$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      errorBuilder: (_, _, _) => Icon(
        fallback,
        size: size,
        color: PetopiaColors.mutedText,
        semanticLabel: label,
      ),
    );
  }
}

/// 水彩徽章（等级/稀有度/状态）：`ui_badge_{name}.png`。
class AppBadge extends StatelessWidget {
  final String name;
  final double size;
  final String? semanticLabel;
  const AppBadge(this.name, {super.key, this.size = 24, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel == null ? null : context.tr(semanticLabel!);
    return Image.asset(
      'assets/art/ui/ui_badge_$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

/// 软性货币「暖绒」图标（钱包展示）。
class WarmfluffIcon extends StatelessWidget {
  final double size;
  final String? semanticLabel;
  const WarmfluffIcon({super.key, this.size = 18, this.semanticLabel});
  @override
  Widget build(BuildContext context) => AppIcon(
    'warmfluff',
    size: size,
    fallback: Icons.cloud,
    semanticLabel: semanticLabel,
  );
}
