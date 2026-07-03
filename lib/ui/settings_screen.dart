import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import 'app_icons.dart';

/// 设置页：轻量控制通知与音效开关。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _bg = Color(0xFFFAF3E3);
  static const _paper = Color(0xFFFFFDF7);
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);
  static const _line = Color(0xFFEDE4D3);
  static const _version = '1.0.0+1';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(child: CircularProgressIndicator(color: _accent)),
      ),
      error: (e, _) => _WarmFrame(child: _ErrorState(message: '设置暂时翻不开：$e')),
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        return _WarmFrame(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _SectionTitle(
                iconName: 'set_music',
                fallbackIcon: Icons.tune_rounded,
                title: '偏好',
                subtitle: '拨动后会立刻写进当前存档。',
              ),
              const SizedBox(height: 10),
              _SwitchCard(
                iconName: 'set_notif',
                fallbackIcon: Icons.notifications_active_rounded,
                title: '通知',
                subtitle: '明信片、回访和院子里的小事件会轻轻提醒你。',
                value: ctrl.notificationsOn,
                onChanged: (_) => ctrl.toggleNotifications(),
              ),
              const SizedBox(height: 12),
              _SwitchCard(
                iconName: 'set_sound',
                fallbackIcon: Icons.volume_up_rounded,
                title: '音效',
                subtitle: '保留翻纸、铃声和点击的柔和声音。',
                value: ctrl.soundOn,
                onChanged: (_) => ctrl.toggleSound(),
              ),
              const SizedBox(height: 22),
              const _AboutCard(),
            ],
          ),
        );
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
      backgroundColor: SettingsScreen._bg,
      appBar: AppBar(
        backgroundColor: SettingsScreen._bg,
        foregroundColor: SettingsScreen._ink,
        elevation: 0,
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String iconName;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.iconName,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(iconName, size: 22, fallback: fallbackIcon),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SettingsScreen._ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: SettingsScreen._muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String iconName;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.iconName,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (value ? SettingsScreen._accent : SettingsScreen._muted)
                  .withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: AppIcon(iconName, size: 24, fallback: fallbackIcon),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SettingsScreen._ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SettingsScreen._muted,
                    height: 1.25,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: SettingsScreen._accent,
            activeTrackColor: SettingsScreen._accent.withValues(alpha: 0.34),
            inactiveThumbColor: const Color(0xFFB8B0A6),
            inactiveTrackColor: SettingsScreen._line,
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                'set_about',
                size: 24,
                fallback: Icons.info_outline_rounded,
              ),
              SizedBox(width: 10),
              Text(
                '关于',
                style: TextStyle(
                  color: SettingsScreen._ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _InfoLine(label: '应用', value: 'Petopia'),
          SizedBox(height: 10),
          _InfoLine(label: '版本', value: SettingsScreen._version),
          SizedBox(height: 10),
          _InfoLine(label: '风格', value: '手账小院 · 暖绒收集'),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              color: SettingsScreen._muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SettingsScreen._ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
          style: const TextStyle(color: SettingsScreen._ink),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: SettingsScreen._paper,
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
