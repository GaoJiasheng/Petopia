import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../l10n/petopia_localizations.dart';
import '../l10n/petopia_text.dart';
import 'adaptive_layout.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'petopia_theme.dart';

/// 成就页：明写目标与隐藏线索分组展示。
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static const _bg = PetopiaColors.background;
  static const _paper = PetopiaColors.paper;
  static const _ink = PetopiaColors.ink;
  static const _muted = PetopiaColors.mutedText;
  static const _accent = PetopiaColors.actionAccent;
  static const _green = PetopiaColors.green;
  static const _line = PetopiaColors.line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(child: CircularProgressIndicator(color: _accent)),
      ),
      error: (error, stackTrace) {
        logUiError('achievements', error, stackTrace);
        return _WarmFrame(
          child: AppLoadError(
            title: '成就册暂时没有翻开',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        final achievements = ctrl.achievementsView();
        return _WarmFrame(child: _AchievementList(achievements: achievements));
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
      backgroundColor: AchievementsScreen._bg,
      appBar: AppBar(
        backgroundColor: AchievementsScreen._bg,
        foregroundColor: AchievementsScreen._ink,
        elevation: 0,
        title: const AppText(
          '成就',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

class _AchievementList extends StatelessWidget {
  final List<AchievementView> achievements;

  const _AchievementList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const _EmptyState();
    }

    final visible = achievements.where((entry) => !entry.hidden).toList();
    final hidden = achievements.where((entry) => entry.hidden).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= 1000 &&
            constraints.maxWidth > constraints.maxHeight;
        final margin = PetopiaAdaptive.sideMargin(context);
        if (wide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: EdgeInsets.fromLTRB(margin, 8, margin, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _AchievementColumn(
                        title: '明写',
                        entries: visible,
                        emptyText: '明写成就还在装订中。',
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: _AchievementColumn(
                        title: '隐藏',
                        entries: hidden,
                        emptyText: '隐藏成就还没有露出线索。',
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
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: EdgeInsets.fromLTRB(margin, 8, margin, 28),
              children: [
                ..._sectionChildren(
                  title: '明写',
                  entries: visible,
                  emptyText: '明写成就还在装订中。',
                ),
                const SizedBox(height: 8),
                ..._sectionChildren(
                  title: '隐藏',
                  entries: hidden,
                  emptyText: '隐藏成就还没有露出线索。',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _progressText(List<AchievementView> entries) {
    final done = entries.where((entry) => entry.unlocked).length;
    return '$done / ${entries.length} 已达成';
  }

  static List<Widget> _sectionChildren({
    required String title,
    required List<AchievementView> entries,
    required String emptyText,
  }) {
    return <Widget>[
      _SectionHeader(title: title, subtitle: _progressText(entries)),
      const SizedBox(height: 10),
      if (entries.isEmpty)
        _SectionEmpty(text: emptyText)
      else
        for (final entry in entries) ...[
          _AchievementCard(entry: entry),
          const SizedBox(height: 12),
        ],
    ];
  }
}

class _AchievementColumn extends StatelessWidget {
  const _AchievementColumn({
    required this.title,
    required this.entries,
    required this.emptyText,
  });

  final String title;
  final List<AchievementView> entries;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _AchievementList._sectionChildren(
        title: title,
        entries: entries,
        emptyText: emptyText,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText(
          title,
          style: const TextStyle(
            color: AchievementsScreen._ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AchievementsScreen._accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: AppText(
            subtitle,
            style: const TextStyle(
              color: AchievementsScreen._accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementView entry;

  const _AchievementCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final veiled = entry.hidden && !entry.unlocked;
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 28;
    final subtitle = _subtitleFor(entry, veiled);
    final status = entry.unlocked ? '已达成' : (veiled ? '线索' : '进行中');
    final heading = largeText
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AchievementIcon(entry: entry, veiled: veiled),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      entry.name,
                      style: const TextStyle(
                        color: AchievementsScreen._ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppText(
                subtitle,
                style: const TextStyle(
                  color: AchievementsScreen._muted,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _StatusBadge(unlocked: entry.unlocked, veiled: veiled),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AchievementIcon(entry: entry, veiled: veiled),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AchievementsScreen._ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      subtitle,
                      style: const TextStyle(
                        color: AchievementsScreen._muted,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(unlocked: entry.unlocked, veiled: veiled),
            ],
          );

    return Semantics(
      container: true,
      label: veiled
          ? '${context.tr(entry.name)}, ${context.tr(status)}, '
                '${context.tr(subtitle)}'
          : '${context.tr(entry.name)}, ${context.tr(status)}, '
                '${context.tr(subtitle)}, '
                '${context.tr('进度 ${entry.progress} / ${entry.target}，奖励 ${entry.rewardSummary}')}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              if (!veiled) ...[
                const SizedBox(height: 14),
                _ProgressLine(entry: entry),
                const SizedBox(height: 10),
                _RewardLine(
                  summary: entry.rewardSummary,
                  claimed: entry.rewardClaimed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _subtitleFor(AchievementView entry, bool veiled) {
    if (veiled) {
      return entry.clueText ?? '线索还藏在院子的某一页。';
    }
    if (entry.unlocked) return '这一页已经盖上完成章。';
    return '慢慢来，进度已经记在手账里。';
  }
}

class _AchievementIcon extends StatelessWidget {
  final AchievementView entry;
  final bool veiled;

  const _AchievementIcon({required this.entry, required this.veiled});

  @override
  Widget build(BuildContext context) {
    final color = veiled
        ? const Color(0xFFB8B0A6)
        : (entry.unlocked
              ? AchievementsScreen._green
              : AchievementsScreen._accent);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: veiled
          ? const Center(
              child: AppIcon(
                'ach_hidden_q',
                size: 24,
                fallback: Icons.help_outline_rounded,
              ),
            )
          : Icon(
              entry.unlocked ? Icons.emoji_events_rounded : Icons.flag_rounded,
              color: color,
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool unlocked;
  final bool veiled;

  const _StatusBadge({required this.unlocked, required this.veiled});

  @override
  Widget build(BuildContext context) {
    final color = unlocked
        ? AchievementsScreen._green
        : (veiled ? const Color(0xFF9C948A) : AchievementsScreen._accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText(
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
    if (unlocked) return '已达成';
    if (veiled) return '线索';
    return '进行中';
  }
}

class _ProgressLine extends StatelessWidget {
  final AchievementView entry;

  const _ProgressLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final ratio = entry.target <= 0
        ? (entry.unlocked ? 1.0 : 0.0)
        : (entry.progress / entry.target).clamp(0.0, 1.0).toDouble();
    final shown = entry.target <= 0
        ? entry.progress
        : (entry.progress > entry.target ? entry.target : entry.progress);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 9,
            backgroundColor: AchievementsScreen._line,
            color: entry.unlocked
                ? AchievementsScreen._green
                : AchievementsScreen._accent,
          ),
        ),
        const SizedBox(height: 6),
        AppText(
          '$shown / ${entry.target}',
          style: const TextStyle(
            color: AchievementsScreen._muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RewardLine extends StatelessWidget {
  final String summary;
  final bool claimed;

  const _RewardLine({required this.summary, required this.claimed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const AppIcon(
            'gift',
            size: 17,
            fallback: Icons.card_giftcard_rounded,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AppText(
              claimed ? '已收下 · $summary' : summary,
              style: const TextStyle(
                color: AchievementsScreen._ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String text;

  const _SectionEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: AppText(
        text,
        style: const TextStyle(color: AchievementsScreen._muted),
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
                'ach_care',
                size: 44,
                fallback: Icons.emoji_events_outlined,
              ),
              SizedBox(height: 14),
              AppText(
                '成就册还没有页签',
                style: TextStyle(
                  color: AchievementsScreen._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              AppText(
                '等小院发生更多故事，这里会贴上新的印章。',
                textAlign: TextAlign.center,
                style: TextStyle(color: AchievementsScreen._muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AchievementsScreen._paper,
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
