import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 本地通知封装：温柔的每日一次「想你了」提醒（零焦虑，低优先级、不催促）。
/// 全程 try/catch 静默降级——通知失败绝不影响玩法。受 settings.notifications 门控。
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inited = false;

  Future<void> _ensureInit() async {
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _inited = true;
  }

  /// 开/关每日提醒（id=0）。开时请求权限并注册每日一次的低打扰通知。
  Future<void> setDailyReminder(bool on) async {
    try {
      await _ensureInit();
      if (on) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: false, sound: false);
        await _plugin.periodicallyShow(
          id: 0,
          title: '小院子有点想你',
          body: '你的小伙伴在等你回来看看它 🐾',
          repeatInterval: RepeatInterval.daily,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'petopia_daily',
              '日常提醒',
              channelDescription: '温柔的每日陪伴提醒',
              importance: Importance.low,
              priority: Priority.low,
            ),
            iOS: DarwinNotificationDetails(presentSound: false),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        await _plugin.cancel(id: 0);
      }
    } catch (e) {
      debugPrint('Petopia notification skipped: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
