import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../app/app_info.dart';
import '../app/game_controller.dart';
import 'adaptive_layout.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'privacy_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backupBusy = false;
  String? _status;

  static const _bg = Color(0xFFFAF3E3);
  static const _paper = Color(0xFFFFFDF7);
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _WarmFrame(
        child: Center(child: CircularProgressIndicator(color: _accent)),
      ),
      error: (error, stackTrace) {
        logUiError('settings', error, stackTrace);
        return _WarmFrame(
          child: AppLoadError(
            title: '设置暂时没有翻开',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (_) {
        final ctrl = ref.read(gameControllerProvider.notifier);
        final appInfo = ref.watch(appInfoProvider).valueOrNull;
        return _WarmFrame(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  PetopiaAdaptive.sideMargin(context),
                  8,
                  PetopiaAdaptive.sideMargin(context),
                  40,
                ),
                children: [
                  if (_status != null) ...[
                    _StatusStrip(message: _status!),
                    const SizedBox(height: 14),
                  ],
                  const _SectionTitle(
                    iconName: 'set_music',
                    fallbackIcon: Icons.tune_rounded,
                    title: '声音',
                    subtitle: '音乐和互动音效可以分别保留。',
                  ),
                  const SizedBox(height: 10),
                  _SwitchCard(
                    iconName: 'set_music',
                    fallbackIcon: Icons.music_note_rounded,
                    title: '背景音乐',
                    subtitle: '院子、相册和毕业旅程的情境音乐。',
                    value: ctrl.musicOn,
                    onChanged: (_) => ctrl.toggleMusic(),
                  ),
                  const SizedBox(height: 12),
                  _SwitchCard(
                    iconName: 'set_sound',
                    fallbackIcon: Icons.volume_up_rounded,
                    title: '互动音效',
                    subtitle: '保留铃声、升级和点击的柔和声音。',
                    value: ctrl.effectsOn,
                    onChanged: (_) => ctrl.toggleEffects(),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    iconName: 'set_notif',
                    fallbackIcon: Icons.notifications_active_rounded,
                    title: '温柔提醒',
                    subtitle: '只提醒真实发生的事情，每天最多一条。',
                  ),
                  const SizedBox(height: 10),
                  _SwitchCard(
                    iconName: 'set_notif',
                    fallbackIcon: Icons.notifications_active_rounded,
                    title: '允许通知',
                    subtitle: '不会发送连续登录、催促回来或倒计时提醒。',
                    value: ctrl.notificationsOn,
                    onChanged: (_) async {
                      final granted = await ctrl.toggleNotifications();
                      if (!granted && mounted) {
                        setState(() {
                          _status = '系统没有允许通知；需要时可在系统设置中重新开启。';
                        });
                      }
                    },
                  ),
                  if (ctrl.notificationsOn) ...[
                    const SizedBox(height: 10),
                    _NotificationCategories(ctrl: ctrl),
                  ],
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    iconName: 'set_about',
                    fallbackIcon: Icons.shield_outlined,
                    title: '存档与隐私',
                    subtitle: '进度默认只保存在当前设备。',
                  ),
                  const SizedBox(height: 10),
                  _CommandCard(
                    icon: Icons.ios_share_rounded,
                    title: '导出存档',
                    subtitle: '生成带完整性校验的备份文件，可存到“文件”或其他位置。',
                    enabled: !_backupBusy,
                    onTap: () => _exportSave(ctrl),
                  ),
                  const SizedBox(height: 12),
                  _CommandCard(
                    icon: Icons.file_open_rounded,
                    title: '导入存档',
                    subtitle: '导入前会验证格式、校验码和经验/暖绒流水。',
                    enabled: !_backupBusy,
                    onTap: () => _importSave(ctrl),
                  ),
                  const SizedBox(height: 12),
                  _CommandCard(
                    icon: Icons.privacy_tip_outlined,
                    title: '隐私说明',
                    subtitle: '查看本地存档、通知和第三方服务的说明。',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _AboutCard(version: appInfo?.displayVersion ?? '读取中'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportSave(GameController ctrl) async {
    setState(() {
      _backupBusy = true;
      _status = null;
    });
    try {
      final file = await ctrl.exportSave();
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(file.path, mimeType: 'application/octet-stream'),
          ],
          fileNameOverrides: <String>[p.basename(file.path)],
          subject: 'Petopia 存档备份',
          text: '这是一份 Petopia 院子存档备份。',
          sharePositionOrigin: origin,
        ),
      );
      if (mounted) setState(() => _status = '存档已经准备好，可选择保存位置。');
    } catch (error, stackTrace) {
      logUiError('save export', error, stackTrace);
      if (mounted) setState(() => _status = '这次没有导出成功，当前存档没有受到影响。');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importSave(GameController ctrl) async {
    const type = XTypeGroup(
      label: 'Petopia 存档',
      extensions: <String>['petopia-save'],
      uniformTypeIdentifiers: <String>['public.data'],
    );
    final selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[type],
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入这份院子存档？'),
        content: const Text('导入会替换当前进度。文件会先完整校验；任何一步失败都会保留现在的院子。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('校验并导入'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _backupBusy = true;
      _status = '正在校验存档…';
    });
    try {
      final result = await ctrl.importSave(File(selected.path));
      if (!mounted) return;
      if (!result.success) {
        setState(() => _status = '存档未通过校验，当前院子保持不变。');
        return;
      }
      setState(() {
        _backupBusy = false;
        _status = '存档已经恢复。';
      });
      ref.invalidate(gameControllerProvider);
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      logUiError('save import', error, stackTrace);
      if (mounted) setState(() => _status = '导入没有完成，当前院子保持不变。');
    } finally {
      if (mounted && _backupBusy) setState(() => _backupBusy = false);
    }
  }
}

class _WarmFrame extends StatelessWidget {
  const _WarmFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsScreenState._bg,
      appBar: AppBar(
        backgroundColor: _SettingsScreenState._bg,
        foregroundColor: _SettingsScreenState._ink,
        elevation: 0,
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.iconName,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
  });

  final String iconName;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;

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
                  color: _SettingsScreenState._ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _SettingsScreenState._muted,
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
  const _SwitchCard({
    required this.iconName,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String iconName;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    final copy = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _SettingsScreenState._ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: _SettingsScreenState._muted,
              height: 1.35,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    final toggle = Switch.adaptive(value: value, onChanged: onChanged);

    return Semantics(
      toggled: value,
      label: title,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: largeText
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingIcon(
                        iconName: iconName,
                        fallbackIcon: fallbackIcon,
                        active: value,
                      ),
                      const SizedBox(width: 14),
                      copy,
                    ],
                  ),
                  Align(alignment: Alignment.centerRight, child: toggle),
                ],
              )
            : Row(
                children: [
                  _SettingIcon(
                    iconName: iconName,
                    fallbackIcon: fallbackIcon,
                    active: value,
                  ),
                  const SizedBox(width: 14),
                  copy,
                  const SizedBox(width: 10),
                  toggle,
                ],
              ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({
    required this.iconName,
    required this.fallbackIcon,
    required this.active,
  });

  final String iconName;
  final IconData fallbackIcon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color:
            (active
                    ? _SettingsScreenState._accent
                    : _SettingsScreenState._muted)
                .withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: AppIcon(iconName, size: 24, fallback: fallbackIcon)),
    );
  }
}

class _NotificationCategories extends StatelessWidget {
  const _NotificationCategories({required this.ctrl});

  final GameController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _MiniToggle(
            label: '旅行明信片',
            value: ctrl.postcardNotificationsOn,
            onChanged: ctrl.togglePostcardNotifications,
          ),
          const Divider(height: 1),
          _MiniToggle(
            label: '老朋友回访',
            value: ctrl.visitorNotificationsOn,
            onChanged: ctrl.toggleVisitorNotifications,
          ),
          const Divider(height: 1),
          _MiniToggle(
            label: '纪念日与特殊事件',
            value: ctrl.eventNotificationsOn,
            onChanged: ctrl.toggleEventNotifications,
          ),
        ],
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            color: _SettingsScreenState._ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Switch.adaptive(value: value, onChanged: (_) => onChanged()),
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _SettingsScreenState._paper,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: _SettingsScreenState._accent, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _SettingsScreenState._ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _SettingsScreenState._muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (!enabled)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _SettingsScreenState._muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
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
                  color: _SettingsScreenState._ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _InfoLine(label: '应用', value: 'Petopia'),
          const SizedBox(height: 10),
          _InfoLine(label: '版本', value: version),
          const SizedBox(height: 10),
          const _InfoLine(label: '数据', value: '本地保存 · 无账号 · 无广告追踪'),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              color: _SettingsScreenState._muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _SettingsScreenState._ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFA7C4A0).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: _SettingsScreenState._ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _SettingsScreenState._paper,
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
