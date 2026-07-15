import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
