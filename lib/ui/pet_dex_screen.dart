import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import 'adaptive_layout.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'pet_art.dart';

/// 宠物图鉴：以四态贴纸卡展示可养与未解锁宠物。
class PetDexScreen extends ConsumerWidget {
  const PetDexScreen({super.key});

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
      error: (error, stackTrace) {
        logUiError('pet dex', error, stackTrace);
        return _WarmFrame(
          child: AppLoadError(
            title: '宠物图鉴暂时没有翻开',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        final entries = ctrl.petDex();
        return _WarmFrame(child: _DexGrid(entries: entries));
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
      backgroundColor: PetDexScreen._bg,
      appBar: AppBar(
        backgroundColor: PetDexScreen._bg,
        foregroundColor: PetDexScreen._ink,
        elevation: 0,
        title: const Text(
          '宠物图鉴',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

class _DexGrid extends StatelessWidget {
  final List<DexEntryView> entries;

  const _DexGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyState();
    }

    final owned = entries
        .where((entry) => entry.state == DexState.ownedBefore)
        .length;
    final available = entries
        .where((entry) => entry.state == DexState.available)
        .length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
            final ratio = width >= 600 ? 0.86 : 0.62;
            final margin = PetopiaAdaptive.sideMargin(context);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(margin, 8, margin, 14),
                    child: _DexSummary(
                      total: entries.length,
                      owned: owned,
                      available: available,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(margin, 0, margin, 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DexCard(entry: entries[index]),
                      childCount: entries.length,
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
            );
          },
        ),
      ),
    );
  }
}

class _DexSummary extends StatelessWidget {
  final int total;
  final int owned;
  final int available;

  const _DexSummary({
    required this.total,
    required this.owned,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const AppIcon(
            'nav_codex',
            size: 30,
            fallback: Icons.menu_book_rounded,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '贴纸册正在慢慢填满',
                  style: TextStyle(
                    color: PetDexScreen._ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '已养过 $owned / $total    可领养 $available',
                  style: const TextStyle(
                    color: PetDexScreen._muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DexCard extends StatelessWidget {
  final DexEntryView entry;

  const _DexCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final state = entry.state;
    final lockedHidden = state == DexState.lockedHidden;
    final lockedKnown = state == DexState.lockedKnown;
    final colored =
        state == DexState.ownedBefore || state == DexState.available;
    final accent = colored ? _accentFor(entry) : const Color(0xFFB8B0A6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _StateBadge(state: state),
          ),
          const Spacer(),
          Center(
            child: _DexMark(
              entry: entry,
              accent: accent,
              lockedKnown: lockedKnown,
              lockedHidden: lockedHidden,
            ),
          ),
          const Spacer(),
          Text(
            lockedHidden ? '？？？' : entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PetDexScreen._ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _descriptionFor(entry),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PetDexScreen._muted,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _descriptionFor(DexEntryView entry) {
    return switch (entry.state) {
      DexState.ownedBefore => entry.baseTone,
      DexState.available => entry.baseTone,
      DexState.lockedKnown => entry.hint ?? '再多陪几位朋友毕业，就能遇见它。',
      DexState.lockedHidden => entry.hint ?? '？？？',
    };
  }
}

class _DexMark extends StatelessWidget {
  final DexEntryView entry;
  final Color accent;
  final bool lockedKnown;
  final bool lockedHidden;

  const _DexMark({
    required this.entry,
    required this.accent,
    required this.lockedKnown,
    required this.lockedHidden,
  });

  @override
  Widget build(BuildContext context) {
    if (lockedHidden) {
      return Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xFFE6DFD0),
          shape: BoxShape.circle,
          border: Border.all(color: PetDexScreen._line, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image.asset(
              _assetFor(entry),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.question_mark_rounded,
                color: PetDexScreen._muted,
                size: 46,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: lockedKnown ? 0.12 : 0.20),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: lockedKnown
              ? PetDexScreen._line
              : accent.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _assetFor(entry),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _fallbackFor(
                    entry.category,
                    lockedKnown ? const Color(0xFF9C948A) : accent,
                  ),
                ),
              ),
            ),
          ),
          if (lockedKnown)
            const Positioned(
              right: 12,
              bottom: 12,
              child: Icon(
                Icons.lock_outline_rounded,
                color: PetDexScreen._muted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  static Widget _fallbackFor(PetCategory category, Color color) {
    return switch (category) {
      PetCategory.real => Center(
        child: Icon(Icons.pets_rounded, color: color, size: 54),
      ),
      PetCategory.fantasy => const Center(
        child: AppIcon(
          'ach_hidden_q',
          size: 54,
          fallback: Icons.auto_awesome_rounded,
        ),
      ),
    };
  }

  static String _assetFor(DexEntryView entry) {
    // 已解锁：用干净单只头像（避免图鉴合成卡的探头第二只/徽章裁切）。
    if (entry.state == DexState.ownedBefore ||
        entry.state == DexState.available) {
      return PetArt.portrait(entry.speciesId);
    }
    // 未解锁：剪影 / 问号渍（单色，无第二只之虞）。
    final suffix = entry.state == DexState.lockedKnown
        ? 'silhouette'
        : 'mystery';
    // speciesId 已含 pet_ 前缀（pet_cat）；文件名即 <id>_dex_<suffix>.png。
    return 'assets/art/pets/dex/${entry.speciesId}_dex_$suffix.png';
  }
}

class _StateBadge extends StatelessWidget {
  final DexState state;

  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      DexState.ownedBefore => PetDexScreen._green,
      DexState.available => PetDexScreen._accent,
      DexState.lockedKnown => const Color(0xFFB8B0A6),
      DexState.lockedHidden => const Color(0xFF9C948A),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelFor(state),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _labelFor(DexState state) {
    return switch (state) {
      DexState.ownedBefore => '已养过',
      DexState.available => '可领养',
      DexState.lockedKnown => '未遇见',
      DexState.lockedHidden => '线索',
    };
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
                fallback: Icons.menu_book_outlined,
              ),
              SizedBox(height: 14),
              Text(
                '图鉴还是空白页',
                style: TextStyle(
                  color: PetDexScreen._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '等第一位朋友入住后，这里会贴上新的小标签。',
                textAlign: TextAlign.center,
                style: TextStyle(color: PetDexScreen._muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _accentFor(DexEntryView entry) {
  const palette = [
    Color(0xFFE8A15C),
    Color(0xFFA7C4A0),
    Color(0xFF84A9C0),
    Color(0xFFD88F7A),
    Color(0xFFB6A3CF),
    Color(0xFFE0BE66),
  ];
  final hash = entry.speciesId.hashCode & 0x7fffffff;
  return palette[hash % palette.length];
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: PetDexScreen._paper,
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
