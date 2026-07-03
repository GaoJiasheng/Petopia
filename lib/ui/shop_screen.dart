import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import 'app_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(
          child: CircularProgressIndicator(color: ShopScreen._accent),
        ),
      ),
      error: (e, _) => _WarmFrame(child: _ErrorState(message: '商店暂时开不了门：$e')),
      data: (view) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        return _WarmFrame(
          child: _ShopContent(
            wallet: view.wallet,
            items: ctrl.shopItems(),
            buyingId: _buyingId,
            onBuy: _buy,
          ),
        );
      },
    );
  }

  Future<void> _buy(ShopItemView item) async {
    if (_buyingId != null || item.owned || !item.affordable) return;
    setState(() => _buyingId = item.id);
    try {
      await ref.read(gameControllerProvider.notifier).buy(item.id);
      if (!mounted) return;
      _showMessage('${item.name} 已收进手账。');
    } catch (e) {
      if (!mounted) return;
      _showMessage('这次没有兑换成功：$e');
    } finally {
      if (mounted) {
        setState(() => _buyingId = null);
      }
    }
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
  final ValueChanged<ShopItemView> onBuy;

  const _ShopContent({
    required this.wallet,
    required this.items,
    required this.buyingId,
    required this.onBuy,
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
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
              disabledByAnotherBuy: buyingId != null && buyingId != item.id,
              onBuy: onBuy,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
        ],
      ],
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

  const _ShopItemCard({
    required this.item,
    required this.busy,
    required this.disabledByAnotherBuy,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canBuy =
        !busy && !disabledByAnotherBuy && !item.owned && item.affordable;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        if (item.consumable)
                          const _TinyTag(
                            icon: Icons.refresh_rounded,
                            label: '可重复',
                            color: ShopScreen._green,
                          ),
                      ],
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
              onPressed: canBuy ? () => onBuy(item) : null,
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
    if (item.owned) return Icons.check_rounded;
    if (!item.affordable) return Icons.lock_outline_rounded;
    return Icons.shopping_bag_rounded;
  }

  String get _buttonLabel {
    if (busy) return '兑换中';
    if (item.owned) return '已拥有';
    if (!item.affordable) return '暖绒不够';
    return '兑换';
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

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ShopScreen._ink),
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
