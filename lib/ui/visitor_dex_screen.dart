import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import 'app_icons.dart';

/// 来客图鉴：按稀有度整理院子里出现过的访客记录。
class VisitorDexScreen extends ConsumerWidget {
  const VisitorDexScreen({super.key});

  static const _bg = Color(0xFFFAF3E3);
  static const _paper = Color(0xFFFFFDF7);
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);
  static const _green = Color(0xFFA7C4A0);
  static const _line = Color(0xFFEDE4D3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(child: CircularProgressIndicator(color: _accent)),
      ),
      error: (e, _) => _WarmFrame(child: _ErrorState(message: '来客册暂时翻不开：$e')),
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        return _WarmFrame(child: _VisitorDexGrid(entries: ctrl.visitorDex()));
      },
    );
  }
}

class _WarmFrame extends StatelessWidget {
  final Widget child;

  const _WarmFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisitorDexScreen._bg,
      appBar: AppBar(
        backgroundColor: VisitorDexScreen._bg,
        foregroundColor: VisitorDexScreen._ink,
        elevation: 0,
        title: const Text(
          '来客图鉴',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

class _VisitorDexGrid extends StatelessWidget {
  final List<VisitorDexView> entries;

  const _VisitorDexGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyState();
    }

    final collected = entries.where((entry) => entry.collected).length;
    final grouped = {
      for (final rarity in VisitorRarity.values)
        rarity: entries.where((entry) => entry.rarity == rarity).toList(),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
        final ratio = width >= 900 ? 0.88 : (width >= 600 ? 0.74 : 0.62);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: _SummaryCard(
                  collected: collected,
                  total: entries.length,
                ),
              ),
            ),
            for (final group in grouped.entries)
              if (group.value.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                    child: _RarityHeader(
                      rarity: group.key,
                      collected: group.value
                          .where((entry) => entry.collected)
                          .length,
                      total: group.value.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _VisitorCard(entry: group.value[index]),
                      childCount: group.value.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: ratio,
                    ),
                  ),
                ),
              ],
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int collected;
  final int total;

  const _SummaryCard({required this.collected, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : collected / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: VisitorDexScreen._accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: AppIcon(
                    'nav_codex',
                    size: 24,
                    fallback: Icons.people_alt_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '院子来客贴纸册',
                      style: TextStyle(
                        color: VisitorDexScreen._ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '已收录 $collected / $total',
                      style: const TextStyle(
                        color: VisitorDexScreen._muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 9,
              backgroundColor: VisitorDexScreen._line,
              color: VisitorDexScreen._green,
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityHeader extends StatelessWidget {
  final VisitorRarity rarity;
  final int collected;
  final int total;

  const _RarityHeader({
    required this.rarity,
    required this.collected,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(rarity);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          _rarityLabel(rarity),
          style: const TextStyle(
            color: VisitorDexScreen._ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$collected / $total',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorDexView entry;

  const _VisitorCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.collected
        ? _rarityColor(entry.rarity)
        : const Color(0xFFB8B0A6);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _RarityBadge(
              rarity: entry.rarity,
              collected: entry.collected,
            ),
          ),
          const Spacer(),
          Center(
            child: _VisitorMark(
              id: entry.id,
              collected: entry.collected,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            entry.collected ? entry.name : '？',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: entry.collected ? VisitorDexScreen._ink : color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (entry.collected) ...[
            _InfoTag(
              icon: Icons.repeat_rounded,
              label: '到访 ${entry.count} 次',
              color: VisitorDexScreen._accent,
            ),
            const SizedBox(height: 6),
            _InfoTag(
              icon: Icons.today_rounded,
              label: '首次 ${_dateLabel(entry.firstSeen)}',
              color: VisitorDexScreen._green,
            ),
          ] else
            _LockedHint(rarity: entry.rarity),
        ],
      ),
    );
  }
}

class _VisitorMark extends StatelessWidget {
  final String id;
  final bool collected;
  final Color color;

  const _VisitorMark({
    required this.id,
    required this.collected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = collected
        ? const Center(
            child: AppIcon(
              'ach_visitor',
              size: 44,
              fallback: Icons.emoji_nature_rounded,
            ),
          )
        : Icon(Icons.question_mark_rounded, color: color, size: 40);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color.withValues(alpha: collected ? 0.20 : 0.13),
        borderRadius: BorderRadius.circular(collected ? 26 : 38),
        border: Border.all(
          color: collected
              ? color.withValues(alpha: 0.40)
              : VisitorDexScreen._line,
          width: 2,
        ),
      ),
      child: collected
          ? Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  // id 已含 visitor_ 前缀；文件名即 <id>_portrait.png。
                  'assets/art/world/visitors/${id}_portrait.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => icon,
                ),
              ),
            )
          : icon,
    );
  }
}

class _RarityBadge extends StatelessWidget {
  final VisitorRarity rarity;
  final bool collected;

  const _RarityBadge({required this.rarity, required this.collected});

  @override
  Widget build(BuildContext context) {
    final color = collected ? _rarityColor(rarity) : const Color(0xFF9C948A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _rarityLabel(rarity),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.color,
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
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  final VisitorRarity rarity;

  const _LockedHint({required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(rarity);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${_rarityLabel(rarity)}来客，还没留下脚印。',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: VisitorDexScreen._muted,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
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
                'nav_codex',
                size: 44,
                fallback: Icons.people_outline_rounded,
              ),
              SizedBox(height: 14),
              Text(
                '来客册还是空白页',
                style: TextStyle(
                  color: VisitorDexScreen._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '等院子里有访客停留，这里会贴上第一张小贴纸。',
                textAlign: TextAlign.center,
                style: TextStyle(color: VisitorDexScreen._muted),
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
          style: const TextStyle(color: VisitorDexScreen._ink),
        ),
      ),
    );
  }
}

String _rarityLabel(VisitorRarity rarity) {
  return switch (rarity) {
    VisitorRarity.common => '常见',
    VisitorRarity.uncommon => '不常见',
    VisitorRarity.rare => '稀有',
    VisitorRarity.legendary => '传说',
  };
}

Color _rarityColor(VisitorRarity rarity) {
  return switch (rarity) {
    VisitorRarity.common => VisitorDexScreen._green,
    VisitorRarity.uncommon => VisitorDexScreen._accent,
    VisitorRarity.rare => const Color(0xFF84A9C0),
    VisitorRarity.legendary => const Color(0xFFB6A3CF),
  };
}

String _dateLabel(DateTime? value) {
  if (value == null) return '未记录';
  final local = value.toLocal();
  return '${local.year}.${_two(local.month)}.${_two(local.day)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: VisitorDexScreen._paper,
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
