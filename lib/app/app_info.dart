import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppUrls {
  static const String supportEmail = 'gaojiasheng.him@foxmail.com';
  static final Uri home = Uri.parse('https://blog.gavingao.cn/petopia/');
  static final Uri privacy = Uri.parse(
    'https://blog.gavingao.cn/petopia/privacy.html',
  );
  static final Uri support = Uri.parse(
    'https://blog.gavingao.cn/petopia/support.html',
  );

  static Uri supportEmailUri({required String subject, required String body}) {
    return Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: <String, String>{'subject': subject, 'body': body},
    );
  }
}

class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  String get displayVersion =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';
}

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final package = await PackageInfo.fromPlatform();
  return AppInfo(version: package.version, buildNumber: package.buildNumber);
});
