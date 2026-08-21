import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_info.dart';
import 'petopia_theme.dart';
import "../l10n/petopia_text.dart";

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF3E3),
        foregroundColor: const Color(0xFF6B5445),
        elevation: 0,
        title: const AppText(
          '隐私说明',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              children: [
                const _PolicySection(
                  title: '你的院子只留在设备上',
                  body:
                      '暖绒小院不要求注册账号，也不会把宠物、明信片、互动记录或设备标识上传到服务器。游戏进度保存在当前设备的应用沙盒中。',
                ),
                const _PolicySection(
                  title: '通知由你决定',
                  body:
                      '只有在你主动开启后，App 才会请求本地通知权限。提醒仅用于明信片、老朋友回访和纪念日；可随时在设置中分类关闭，也不会使用广告追踪。',
                ),
                const _PolicySection(
                  title: '存档备份',
                  body: '导出存档时，文件由你选择保存或分享的位置。导入会先校验文件完整性和数据流水，校验失败不会覆盖当前院子。',
                ),
                const _PolicySection(
                  title: '第三方服务',
                  body:
                      '当前版本不包含广告、第三方分析、跨 App 追踪、社交登录或联网内容服务。只有在你主动支持小院时，购买和恢复购买会由 Apple App Store 处理；暖绒小院不会接触支付卡或 Apple ID。',
                ),
                const _PolicySection(
                  title: '支持小院的本地记录',
                  body:
                      'App 只在设备上保存回礼类型、交易幂等键和有效期，用于防止重复发放并展示装饰。普通支持不会写入可导出的游戏存档，也不会改变经验、暖绒、冷却或概率。',
                ),
                const _PolicySection(
                  title: '删除数据',
                  body:
                      '卸载 App 会删除本机游戏数据和固定时长回礼记录。建议卸载或换机前导出存档；重新安装后，可从支持页恢复一次性永久的“小院守护者”。',
                ),
                const _PolicySection(
                  title: '问题反馈与诊断信息',
                  body:
                      '只有在你主动选择“报告问题”时，App 才会打开邮件应用，并填入版本与运行状态摘要。发送前可自行查看和修改；内容不包含昵称、明信片正文、存档或设备标识。',
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: AppText(
                    '生效日期：2026 年 7 月 27 日',
                    style: TextStyle(
                      color: PetopiaColors.mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _PolicyLink(
                  icon: Icons.open_in_new_rounded,
                  label: '查看完整隐私政策',
                  uri: AppUrls.privacy,
                ),
                const SizedBox(height: 10),
                _PolicyLink(
                  icon: Icons.support_agent_rounded,
                  label: '联系支持',
                  uri: AppUrls.support,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink({
    required this.icon,
    required this.label,
    required this.uri,
  });

  final IconData icon;
  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        var opened = false;
        try {
          opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          opened = false;
        }
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: AppText('暂时无法打开网页，请稍后再试。')));
        }
      },
      icon: Icon(icon),
      label: AppText(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B5445),
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: Color(0xFFE3C8A7)),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            body,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 15,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
