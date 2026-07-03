import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import '../domain/models/logs.dart';

/// 成长手账：按天回看当前宠物的经验流水。
class GrowthJournalScreen extends ConsumerWidget {
  const GrowthJournalScreen({super.key});

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
        title: '成长手账',
        child: Center(child: CircularProgressIndicator(color: _accent)),
      ),
      error: (e, _) => _WarmFrame(
        title: '成长手账',
        child: _ErrorState(message: '手账暂时翻不开：$e'),
      ),
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        return _WarmFrame(
          title: '成长手账',
          child: FutureBuilder<List<ExpLogEntry>>(
            future: ctrl.growthJournal(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: _accent),
                );
              }
              if (snapshot.hasError) {
                return _ErrorState(message: '手账暂时翻不开：${snapshot.error}');
              }
              return _JournalContent(entries: snapshot.data ?? const []);
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: child,
    );
  }
}

class _JournalContent extends StatelessWidget {
  final List<ExpLogEntry> entries;

  const _JournalContent({required this.entries});

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _SummaryCard(todayGain: todayGain, totalGain: totalGain),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const _EmptyState()
        else
          for (final group in grouped.entries) ...[
            _DaySection(day: group.key, entries: group.value),
            const SizedBox(height: 14),
          ],
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
      child: Row(
        children: [
          Expanded(
            child: _StatPill(
              icon: Icons.wb_sunny_outlined,
              label: '今日',
              value: '+$todayGain',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatPill(
              icon: Icons.auto_stories_outlined,
              label: '累计',
              value: '+$totalGain',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
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
          Icon(icon, color: GrowthJournalScreen._accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: GrowthJournalScreen._muted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
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

  const _DaySection({required this.day, required this.entries});

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
              Text(
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
                child: Text(
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
        for (final entry in entries) _LogTile(entry: entry),
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

  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final local = entry.timestamp.toLocal();
    final note = _noteFor(entry);
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
                child: Icon(
                  _sourceIcon(entry.sourceType),
                  color: GrowthJournalScreen._accent,
                  size: 21,
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
                        child: Text(
                          note,
                          style: const TextStyle(
                            color: GrowthJournalScreen._ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
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
          Text(
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
          Icon(
            Icons.auto_stories_outlined,
            color: GrowthJournalScreen._accent,
            size: 44,
          ),
          SizedBox(height: 14),
          Text(
            '还没有写下成长脚印',
            style: TextStyle(
              color: GrowthJournalScreen._ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '陪 TA 吃点东西、摸摸头，手账就会慢慢热闹起来。',
            textAlign: TextAlign.center,
            style: TextStyle(color: GrowthJournalScreen._muted),
          ),
        ],
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
          style: const TextStyle(color: GrowthJournalScreen._ink),
        ),
      ),
    );
  }
}

IconData _sourceIcon(ExpSource source) {
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
