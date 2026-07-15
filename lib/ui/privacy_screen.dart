import 'package:flutter/material.dart';

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
        title: const Text(
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
              children: const [
                _PolicySection(
                  title: '你的院子只留在设备上',
                  body:
                      'Petopia 不要求注册账号，也不会把宠物、明信片、互动记录或设备标识上传到服务器。游戏进度保存在当前设备的应用沙盒中。',
                ),
                _PolicySection(
                  title: '通知由你决定',
                  body:
                      '只有在你主动开启后，App 才会请求本地通知权限。提醒仅用于明信片、老朋友回访和纪念日；可随时在设置中分类关闭，也不会使用广告追踪。',
                ),
                _PolicySection(
                  title: '存档备份',
                  body: '导出存档时，文件由你选择保存或分享的位置。导入会先校验文件完整性和数据流水，校验失败不会覆盖当前院子。',
                ),
                _PolicySection(
                  title: '第三方服务',
                  body:
                      '当前版本不包含广告、第三方分析、跨 App 追踪、社交登录或联网内容服务。系统分享面板和文件选择器仅在你主动操作时打开。',
                ),
                _PolicySection(
                  title: '删除数据',
                  body: '卸载 App 会删除保存在本机的游戏数据。建议在卸载或换机前，从设置页导出一份存档备份。',
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    '生效日期：2026 年 7 月 14 日',
                    style: TextStyle(
                      color: Color(0xFF8A7A6A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
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
