import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import 'adaptive_layout.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'yard_art.dart';

/// 暖绒商店：按分类展示商品，并通过 GameController 完成兑换。
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  static const _bg = Color(0xFFFAF3E3);
  static const _paper = Color(0xFFFFFDF7);
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);
  static const _green = Color(0xFFA7C4A0);
  static const _line = Color(0xFFEDE4D3);

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _buyingId;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(
          child: CircularProgressIndicator(color: ShopScreen._accent),
        ),
      ),
      error: (error, stackTrace) {
        logUiError('shop', error, stackTrace);
        return _WarmFrame(
          child: AppLoadError(
            title: '商店暂时没有开门',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (view) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        return _WarmFrame(
          child: _ShopContent(
            wallet: view.wallet,
            items: ctrl.shopItems(),
            buyingId: _buyingId,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (value) =>
                setState(() => _selectedCategory = value),
            onBuy: _buy,
            onApply: _apply,
          ),
        );
      },
    );
  }

  Future<void> _buy(ShopItemView item) async {
    if (_buyingId != null || item.owned || !item.affordable) return;
    setState(() => _buyingId = item.id);
    try {
      final success = await ref
          .read(gameControllerProvider.notifier)
          .buy(item.id);
      if (!mounted) return;
      final discount = item.discountLabel;
      _showMessage(
        success
            ? discount == null
                  ? '${item.name} 已收进手账。'
                  : '${item.name} 已收进手账，已使用$discount。'
            : '暖绒不足，或这件物品已经拥有。',
      );
    } catch (error, stackTrace) {
      logUiError('shop purchase', error, stackTrace);
      if (!mounted) return;
      _showMessage('这次没有兑换成功，暖绒和物品都没有变化。');
    } finally {
      if (mounted) {
        setState(() => _buyingId = null);
      }
    }
  }

  void _apply(ShopItemView item) {
    final themeId = item.themeId;
    final albumSkinId = item.albumSkinId;
    if (!item.owned || item.active) return;
    final ctrl = ref.read(gameControllerProvider.notifier);
    if (themeId != null) {
      ctrl.applyTheme(themeId);
    } else if (albumSkinId != null) {
      ctrl.applyAlbumSkin(albumSkinId);
    } else {
      return;
    }
    _showMessage('已应用「${item.name}」。');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ShopScreen._ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _WarmFrame extends StatelessWidget {
  final Widget child;

  const _WarmFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopScreen._bg,
      appBar: AppBar(
        backgroundColor: ShopScreen._bg,
        foregroundColor: ShopScreen._ink,
        elevation: 0,
        title: const Text(
          '暖绒商店',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

class _ShopContent extends StatelessWidget {
  final int wallet;
  final List<ShopItemView> items;
  final String? buyingId;
  final String? selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<ShopItemView> onBuy;
  final ValueChanged<ShopItemView> onApply;

  const _ShopContent({
    required this.wallet,
    required this.items,
    required this.buyingId,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onBuy,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState();
    }

    final grouped = <String, List<ShopItemView>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final selected = grouped.containsKey(selectedCategory)
            ? selectedCategory!
            : grouped.keys.first;
        if (wide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  PetopiaAdaptive.sideMargin(context),
                  8,
                  PetopiaAdaptive.sideMargin(context),
                  24,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 224,
                      child: ListView(
                        children: [
                          _CompactWalletCard(wallet: wallet),
                          const SizedBox(height: 14),
                          for (final entry in grouped.entries) ...[
                            _CategoryButton(
                              category: entry.key,
                              count: entry.value.length,
                              selected: selected == entry.key,
                              onTap: () => onCategoryChanged(entry.key),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: ListView(
                        children: [
                          _SectionHeader(
                            title: selected,
                            subtitle: '${grouped[selected]!.length} 件小物',
                            iconName: _categoryIconName(selected),
                            fallbackIcon: _categoryFallbackIcon(selected),
                          ),
                          const SizedBox(height: 12),
                          _ShopItemWrap(
                            items: grouped[selected]!,
                            buyingId: buyingId,
                            onBuy: onBuy,
                            onApply: onApply,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                PetopiaAdaptive.sideMargin(context),
                8,
                PetopiaAdaptive.sideMargin(context),
                28,
              ),
              children: [
                _WalletCard(wallet: wallet),
                const SizedBox(height: 18),
                for (final group in grouped.entries) ...[
                  _SectionHeader(
                    title: group.key,
                    subtitle: '${group.value.length} 件小物',
                    iconName: _categoryIconName(group.key),
                    fallbackIcon: _categoryFallbackIcon(group.key),
                  ),
                  const SizedBox(height: 10),
                  for (final item in group.value) ...[
                    _ShopItemCard(
                      item: item,
                      busy: buyingId == item.id,
                      disabledByAnotherBuy:
                          buyingId != null && buyingId != item.id,
                      onBuy: onBuy,
                      onApply: onApply,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShopItemWrap extends StatelessWidget {
  final List<ShopItemView> items;
  final String? buyingId;
  final ValueChanged<ShopItemView> onBuy;
  final ValueChanged<ShopItemView> onApply;

  const _ShopItemWrap({
    required this.items,
    required this.buyingId,
    required this.onBuy,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820 ? 3 : 2;
        final cardWidth = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _ShopItemCard(
                  item: item,
                  busy: buyingId == item.id,
                  disabledByAnotherBuy: buyingId != null && buyingId != item.id,
                  onBuy: onBuy,
                  onApply: onApply,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CompactWalletCard extends StatelessWidget {
  final int wallet;

  const _CompactWalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '暖绒余额',
            style: TextStyle(
              color: ShopScreen._muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const WarmfluffIcon(size: 22),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  '$wallet',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ShopScreen._accent,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ShopScreen._accent.withValues(alpha: 0.16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              AppIcon(
                _categoryIconName(category),
                size: 22,
                fallback: _categoryFallbackIcon(category),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? ShopScreen._accent : ShopScreen._ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  color: ShopScreen._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final int wallet;

  const _WalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: ShopScreen._accent,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今天的暖绒余额',
                  style: TextStyle(
                    color: ShopScreen._ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '换一点小院会喜欢的东西。',
                  style: TextStyle(
                    color: ShopScreen._muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WarmfluffIcon(size: 18),
              const SizedBox(width: 4),
              Text(
                '$wallet',
                style: const TextStyle(
                  color: ShopScreen._accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final IconData fallbackIcon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(iconName, size: 20, fallback: fallbackIcon),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: ShopScreen._ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ShopScreen._accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: ShopScreen._accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItemView item;
  final bool busy;
  final bool disabledByAnotherBuy;
  final ValueChanged<ShopItemView> onBuy;
  final ValueChanged<ShopItemView> onApply;

  const _ShopItemCard({
    required this.item,
    required this.busy,
    required this.disabledByAnotherBuy,
    required this.onBuy,
    required this.onApply,
  });

  /// 已拥有但未装备的主题 → 可「应用」。
  bool get _canApply =>
      (item.themeId != null || item.albumSkinId != null) &&
      item.owned &&
      !item.active &&
      !busy;

  @override
  Widget build(BuildContext context) {
    final canBuy =
        !busy && !disabledByAnotherBuy && !item.owned && item.affordable;
    final onPressed = _canApply
        ? () => onApply(item)
        : (canBuy ? () => onBuy(item) : null);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemPreview(item: item),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ItemIcon(category: item.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ShopScreen._ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(item: item),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _TinyTag(
                          icon: Icons.cloud_rounded,
                          label: '${item.price} 暖绒',
                          color: ShopScreen._accent,
                          warmfluff: true,
                        ),
                        if (item.discountLabel != null)
                          _TinyTag(
                            icon: Icons.discount_outlined,
                            label:
                                '${item.discountLabel} · 原价 ${item.originalPrice}',
                            color: ShopScreen._green,
                          ),
                        if (item.consumable)
                          _TinyTag(
                            icon: Icons.refresh_rounded,
                            label: item.quantity > 0
                                ? '库存 ${item.quantity}'
                                : '可重复',
                            color: ShopScreen._green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.effectSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ShopScreen._muted,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: busy
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_buttonIcon),
              label: Text(_buttonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: ShopScreen._accent,
                disabledBackgroundColor: ShopScreen._line,
                disabledForegroundColor: ShopScreen._muted,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _buttonIcon {
    if (item.active) return Icons.check_circle_rounded; // 使用中
    if (_canApply) return Icons.brush_rounded; // 应用
    if (item.owned) return Icons.check_rounded;
    if (!item.affordable) return Icons.lock_outline_rounded;
    return Icons.shopping_bag_rounded;
  }

  String get _buttonLabel {
    if (busy) return '兑换中';
    if (item.active) return '使用中';
    if (_canApply) return '应用';
    if (item.owned) return '已拥有';
    if (!item.affordable) return '暖绒不够';
    return '兑换';
  }
}

class _ItemPreview extends StatelessWidget {
  final ShopItemView item;

  const _ItemPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeId = item.themeId;
    final decorId = item.decorId;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 112,
        child: ColoredBox(
          color: _categoryColor(item.category).withValues(alpha: 0.12),
          child: themeId != null
              ? Image.asset(
                  YardArt.themeBg(themeId),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  cacheWidth: 480,
                  errorBuilder: (_, _, _) => _ProductIcon(item: item),
                )
              : decorId != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    YardArt.decor(decorId),
                    fit: BoxFit.contain,
                    cacheWidth: 260,
                    errorBuilder: (_, _, _) => _ProductIcon(item: item),
                  ),
                )
              : _ProductIcon(item: item),
        ),
      ),
    );
  }
}

class _ProductIcon extends StatelessWidget {
  final ShopItemView item;

  const _ProductIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    final asset = switch (item.id) {
      final id when id.contains('grain') =>
        'assets/art/ui/ui_icon_food_grain.png',
      final id when id.contains('dried_fish') =>
        'assets/art/ui/ui_icon_food_fish.png',
      final id when id.contains('nut') => 'assets/art/ui/ui_icon_food_nut.png',
      final id when id.contains('apple') =>
        'assets/art/ui/ui_icon_food_apple.png',
      _ when item.effectType == EffectType.toyPermanentBonus =>
        'assets/art/ui/ui_icon_shop_toy.png',
      _ when item.effectType == EffectType.albumSkin =>
        'assets/art/ui/ui_icon_shop_albumskin.png',
      _ => 'assets/art/ui/ui_icon_shop_food.png',
    };
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        cacheWidth: 180,
        errorBuilder: (_, _, _) => Icon(
          _categoryFallbackIcon(item.category),
          size: 44,
          color: _categoryColor(item.category),
        ),
      ),
    );
  }
}

class _ItemIcon extends StatelessWidget {
  final String category;

  const _ItemIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: AppIcon(
          _categoryIconName(category),
          size: 27,
          fallback: _categoryFallbackIcon(category),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ShopItemView item;

  const _StatusBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.owned
        ? ShopScreen._green
        : (!item.affordable ? const Color(0xFF9C948A) : ShopScreen._accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String get _label {
    if (item.owned) return '已拥有';
    if (!item.affordable) return '买不起';
    return '可兑换';
  }
}

class _TinyTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool warmfluff;

  const _TinyTag({
    required this.icon,
    required this.label,
    required this.color,
    this.warmfluff = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (warmfluff)
            const WarmfluffIcon(size: 14)
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          decoration: _cardDecoration(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                'nav_shop',
                size: 44,
                fallback: Icons.storefront_outlined,
              ),
              SizedBox(height: 14),
              Text(
                '商店货架还在整理',
                style: TextStyle(
                  color: ShopScreen._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '等新商品上架后，这里会变得热闹起来。',
                textAlign: TextAlign.center,
                style: TextStyle(color: ShopScreen._muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryIconName(String category) {
  return switch (category.trim().toLowerCase()) {
    'theme' || '院子主题' => 'shop_theme',
    'decor' || 'deco' || '装饰小物' => 'shop_deco',
    'food' || '特殊食粮' => 'shop_food',
    'toy' || '特殊玩具' => 'shop_toy',
    'albumskin' || '明信片' => 'shop_albumskin',
    _ => 'shop_deco',
  };
}

IconData _categoryFallbackIcon(String category) {
  return switch (category.trim().toLowerCase()) {
    'theme' || '院子主题' => Icons.landscape_rounded,
    'decor' || 'deco' || '装饰小物' => Icons.yard_rounded,
    'food' || '特殊食粮' => Icons.restaurant_menu_rounded,
    'toy' || '特殊玩具' => Icons.sports_baseball_rounded,
    'albumskin' || '明信片' => Icons.local_post_office_rounded,
    _ => Icons.sell_rounded,
  };
}

Color _categoryColor(String category) {
  return switch (category) {
    '院子主题' => const Color(0xFF84A9C0),
    '装饰小物' => ShopScreen._green,
    '特殊食粮' => ShopScreen._accent,
    '特殊玩具' => const Color(0xFFD88F7A),
    '明信片' => const Color(0xFFB6A3CF),
    _ => ShopScreen._accent,
  };
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: ShopScreen._paper,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
