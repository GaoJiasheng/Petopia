import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import '../domain/models/logs.dart';
import '../l10n/petopia_localizations.dart';
import 'adaptive_layout.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'petopia_theme.dart';
import "../l10n/petopia_text.dart";

/// 成长手账：按天回看当前宠物的经验流水。
class GrowthJournalScreen extends ConsumerStatefulWidget {
  const GrowthJournalScreen({super.key});

  static const _bg = PetopiaColors.background;
  static const _paper = PetopiaColors.paper;
  static const _ink = PetopiaColors.ink;
  static const _muted = PetopiaColors.mutedText;
  static const _accent = PetopiaColors.actionAccent;
  static const _green = PetopiaColors.green;
  static const _line = PetopiaColors.line;

  @override
  ConsumerState<GrowthJournalScreen> createState() =>
      _GrowthJournalScreenState();
}

class _GrowthJournalScreenState extends ConsumerState<GrowthJournalScreen> {
  Future<List<ExpLogEntry>>? _entriesFuture;
  GameController? _entriesController;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        title: '成长手账',
        child: Center(
          child: CircularProgressIndicator(color: GrowthJournalScreen._accent),
        ),
      ),
      error: (error, stackTrace) {
        logUiError('growth journal', error, stackTrace);
        return _WarmFrame(
          title: '成长手账',
          child: AppLoadError(
            title: '成长手账暂时没有翻开',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        if (!identical(_entriesController, ctrl)) {
          _entriesController = ctrl;
          _entriesFuture = ctrl.growthJournal();
        }
        return _WarmFrame(
          title: '成长手账',
          child: FutureBuilder<List<ExpLogEntry>>(
            future: _entriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: GrowthJournalScreen._accent,
                  ),
                );
              }
              if (snapshot.hasError) {
                logUiError(
                  'growth journal entries',
                  snapshot.error!,
                  snapshot.stackTrace ?? StackTrace.current,
                );
                return AppLoadError(
                  title: '成长记录暂时没有翻开',
                  onRetry: () {
                    setState(() {
                      _entriesFuture = ctrl.growthJournal();
                    });
                  },
                );
              }
              return _JournalContent(
                entries: snapshot.data ?? const [],
                milestones: ctrl.growthMemories(),
                noteEn: ctrl.growthJournalNoteEn,
              );
            },
          ),
        );
      },
    );
  }
}

class _WarmFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _WarmFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowthJournalScreen._bg,
      appBar: AppBar(
        backgroundColor: GrowthJournalScreen._bg,
        foregroundColor: GrowthJournalScreen._ink,
        elevation: 0,
        title: AppText(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

class _JournalContent extends StatelessWidget {
  final List<ExpLogEntry> entries;
  final List<YardMemoryView> milestones;
  final String Function(ExpLogEntry entry) noteEn;

  const _JournalContent({
    required this.entries,
    required this.milestones,
    required this.noteEn,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = [...entries]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final grouped = <DateTime, List<ExpLogEntry>>{};
    for (final entry in ordered) {
      final local = entry.timestamp.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(day, () => []).add(entry);
    }

    final now = DateTime.now();
    final todayGain = entries
        .where((entry) => _sameDay(entry.timestamp.toLocal(), now))
        .fold<int>(0, (sum, entry) => sum + entry.delta);
    final totalGain = entries.fold<int>(0, (sum, entry) => sum + entry.delta);

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
            _SummaryCard(todayGain: todayGain, totalGain: totalGain),
            if (milestones.isNotEmpty) ...[
              const SizedBox(height: 16),
              _GrowthMoments(memories: milestones),
            ],
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const _EmptyState()
            else
              for (final group in grouped.entries) ...[
                _DaySection(
                  day: group.key,
                  entries: group.value,
                  noteEn: noteEn,
                ),
                const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _GrowthMoments extends StatelessWidget {
  final List<YardMemoryView> memories;
  const _GrowthMoments({required this.memories});

  @override
  Widget build(BuildContext context) {
    final recent = memories.reversed.take(3).toList(growable: false);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.spa_rounded, color: GrowthJournalScreen._green),
              SizedBox(width: 8),
              Expanded(
                child: AppText(
                  '慢慢长大的时刻',
                  style: TextStyle(
                    color: GrowthJournalScreen._ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final memory in recent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: GrowthJournalScreen._accent,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppText(
                      context.l10n.bilingual(
                        zhHans: memory.text,
                        en: memory.textEn.isEmpty ? memory.text : memory.textEn,
                      ),
                      style: const TextStyle(
                        color: GrowthJournalScreen._muted,
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
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

class _SummaryCard extends StatelessWidget {
  final int todayGain;
  final int totalGain;

  const _SummaryCard({required this.todayGain, required this.totalGain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack =
              MediaQuery.textScalerOf(context).scale(14) > 16 &&
              constraints.maxWidth < 560;
          final today = _StatPill(
            icon: Icons.wb_sunny_outlined,
            label: '今日',
            value: '+$todayGain',
          );
          final total = _StatPill(
            icon: Icons.auto_stories_outlined,
            iconName: 'nav_menu',
            label: '累计',
            value: '+$totalGain',
          );
          if (stack) {
            return Column(children: [today, const SizedBox(height: 12), total]);
          }
          return Row(
            children: [
              Expanded(child: today),
              const SizedBox(width: 12),
              Expanded(child: total),
            ],
          );
        },
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String? iconName;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    this.iconName,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (iconName == null)
            Icon(icon, color: GrowthJournalScreen._accent, size: 22)
          else
            AppIcon(iconName!, size: 22, fallback: icon),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              label,
              style: const TextStyle(
                color: GrowthJournalScreen._muted,
                fontSize: 13,
              ),
            ),
          ),
          AppText(
            value,
            style: const TextStyle(
              color: GrowthJournalScreen._ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<ExpLogEntry> entries;
  final String Function(ExpLogEntry entry) noteEn;

  const _DaySection({
    required this.day,
    required this.entries,
    required this.noteEn,
  });

  @override
  Widget build(BuildContext context) {
    final dayGain = entries.fold<int>(0, (sum, entry) => sum + entry.delta);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              AppText(
                _dayLabel(day),
                style: const TextStyle(
                  color: GrowthJournalScreen._ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GrowthJournalScreen._accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AppText(
                  '+$dayGain',
                  style: const TextStyle(
                    color: GrowthJournalScreen._accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final entry in entries)
          _LogTile(entry: entry, noteEn: noteEn(entry)),
      ],
    );
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return '今天';
    if (day == yesterday) return '昨天';
    if (day.year == now.year) return '${day.month}月${day.day}日';
    return '${day.year}年${day.month}月${day.day}日';
  }
}

class _LogTile extends StatelessWidget {
  final ExpLogEntry entry;
  final String noteEn;

  const _LogTile({required this.entry, required this.noteEn});

  @override
  Widget build(BuildContext context) {
    final local = entry.timestamp.toLocal();
    final note = _noteFor(entry);
    final displayNote = context.l10n.isEnglish && noteEn.isNotEmpty
        ? noteEn
        : note;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1DF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    _sourceIconName(entry.sourceType),
                    size: 21,
                    fallback: _sourceFallbackIcon(entry.sourceType),
                  ),
                ),
              ),
              Container(width: 2, height: 38, color: GrowthJournalScreen._line),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          displayNote,
                          style: const TextStyle(
                            color: GrowthJournalScreen._ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        '+${entry.delta}',
                        style: const TextStyle(
                          color: GrowthJournalScreen._accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _TinyTag(
                        icon: Icons.schedule_rounded,
                        label: _timeLabel(local),
                      ),
                      _TinyTag(
                        icon: Icons.star_border_rounded,
                        label: 'Lv ${entry.levelAt}',
                      ),
                      _TinyTag(
                        icon: Icons.bookmark_border_rounded,
                        label: _sourceLabel(entry.sourceType),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _noteFor(ExpLogEntry entry) {
    final raw = entry.note?.trim();
    if (raw == null || raw.isEmpty) return _sourceLabel(entry.sourceType);
    return raw;
  }

  static String _timeLabel(DateTime time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _TinyTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TinyTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: GrowthJournalScreen._green.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: GrowthJournalScreen._muted),
          const SizedBox(width: 4),
          AppText(
            label,
            style: const TextStyle(
              color: GrowthJournalScreen._muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          AppIcon('nav_menu', size: 44, fallback: Icons.auto_stories_outlined),
          SizedBox(height: 14),
          AppText(
            '还没有写下成长脚印',
            style: TextStyle(
              color: GrowthJournalScreen._ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          AppText(
            '陪它吃点东西、摸摸头，手账就会慢慢写下新的故事。',
            textAlign: TextAlign.center,
            style: TextStyle(color: GrowthJournalScreen._muted),
          ),
        ],
      ),
    );
  }
}

String _sourceIconName(ExpSource source) {
  return switch (source) {
    ExpSource.feed => 'src_feed',
    ExpSource.pat => 'src_pat',
    ExpSource.toy => 'src_toy',
    ExpSource.bath => 'src_bath',
    ExpSource.offline => 'src_offline',
    ExpSource.eventDaily => 'src_event',
    ExpSource.eventSpecial => 'src_event',
    ExpSource.visitor => 'src_visitor',
    ExpSource.revisit => 'src_revisit',
    ExpSource.itemBonus => 'gift',
  };
}

IconData _sourceFallbackIcon(ExpSource source) {
  return switch (source) {
    ExpSource.feed => Icons.restaurant_rounded,
    ExpSource.pat => Icons.pets_rounded,
    ExpSource.toy => Icons.sports_baseball_rounded,
    ExpSource.bath => Icons.bathtub_rounded,
    ExpSource.offline => Icons.nightlight_round,
    ExpSource.eventDaily => Icons.event_note_rounded,
    ExpSource.eventSpecial => Icons.auto_awesome_rounded,
    ExpSource.visitor => Icons.emoji_people_rounded,
    ExpSource.revisit => Icons.home_rounded,
    ExpSource.itemBonus => Icons.card_giftcard_rounded,
  };
}

String _sourceLabel(ExpSource source) {
  return switch (source) {
    ExpSource.feed => '喂食',
    ExpSource.pat => '摸头',
    ExpSource.toy => '玩具',
    ExpSource.bath => '洗澡',
    ExpSource.offline => '离线陪伴',
    ExpSource.eventDaily => '日常事件',
    ExpSource.eventSpecial => '特别事件',
    ExpSource.visitor => '访客',
    ExpSource.revisit => '回访',
    ExpSource.itemBonus => '道具加成',
  };
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: GrowthJournalScreen._paper,
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
