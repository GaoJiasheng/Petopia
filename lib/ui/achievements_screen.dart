import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import 'adaptive_layout.dart';
import 'app_icons.dart';

/// 成就页：明写目标与隐藏线索分组展示。
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

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
      error: (e, _) => _WarmFrame(child: _ErrorState(message: '成就册暂时翻不开：$e')),
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
        title: const Text('成就', style: TextStyle(fontWeight: FontWeight.w800)),
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            PetopiaAdaptive.sideMargin(context),
            8,
            PetopiaAdaptive.sideMargin(context),
            28,
          ),
          children: [
            _SectionHeader(title: '明写', subtitle: _progressText(visible)),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              const _SectionEmpty(text: '明写成就还在装订中。')
            else
              for (final entry in visible) ...[
                _AchievementCard(entry: entry),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 8),
            _SectionHeader(title: '隐藏', subtitle: _progressText(hidden)),
            const SizedBox(height: 10),
            if (hidden.isEmpty)
              const _SectionEmpty(text: '隐藏成就还没有露出线索。')
            else
              for (final entry in hidden) ...[
                _AchievementCard(entry: entry),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  static String _progressText(List<AchievementView> entries) {
    final done = entries.where((entry) => entry.unlocked).length;
    return '$done / ${entries.length} 已达成';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AchievementsScreen._ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AchievementsScreen._accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AchievementIcon(entry: entry, veiled: veiled),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    Text(
                      _subtitleFor(entry, veiled),
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
          ),
          if (!veiled) ...[
            const SizedBox(height: 14),
            _ProgressLine(entry: entry),
            const SizedBox(height: 10),
            _RewardLine(rewardFluff: entry.rewardFluff),
          ],
        ],
      ),
    );
  }

  static String _subtitleFor(AchievementView entry, bool veiled) {
    if (veiled) {
      return entry.clueText ?? '线索还藏在院子的某一页。';
    }
    if (entry.unlocked) return '这一页已经贴上亮亮的完成章。';
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
        Text(
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
  final int rewardFluff;

  const _RewardLine({required this.rewardFluff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
            'gift',
            size: 17,
            fallback: Icons.card_giftcard_rounded,
          ),
          const SizedBox(width: 6),
          Text(
            rewardFluff > 0 ? '暖绒 +$rewardFluff' : '特别奖励',
            style: const TextStyle(
              color: AchievementsScreen._ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
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
      child: Text(
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
              Text(
                '成就册还没有页签',
                style: TextStyle(
                  color: AchievementsScreen._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
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
          style: const TextStyle(color: AchievementsScreen._ink),
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
