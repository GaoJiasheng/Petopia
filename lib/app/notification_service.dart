import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum PetopiaNotificationKind { postcard, revisit, event, anniversary }

class PetopiaNotificationCandidate {
  const PetopiaNotificationCandidate({
    required this.key,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
  });

  final String key;
  final PetopiaNotificationKind kind;
  final DateTime at;
  final String title;
  final String body;
}

class PetopiaNotificationPreferences {
  const PetopiaNotificationPreferences({
    required this.enabled,
    required this.postcards,
    required this.visitors,
    required this.events,
  });

  final bool enabled;
  final bool postcards;
  final bool visitors;
  final bool events;

  bool allows(PetopiaNotificationKind kind) => switch (kind) {
    PetopiaNotificationKind.postcard => postcards,
    PetopiaNotificationKind.revisit => visitors,
    PetopiaNotificationKind.event ||
    PetopiaNotificationKind.anniversary => events,
  };
}

class PlannedNotification {
  const PlannedNotification(this.candidate, this.at);

  final PetopiaNotificationCandidate candidate;
  final DateTime at;
}

/// Pure planning policy: content-driven, one notification per local day, and
/// only inside the calm 09:00-21:00 window.
abstract final class NotificationPlanner {
  static List<PlannedNotification> plan({
    required List<PetopiaNotificationCandidate> candidates,
    required PetopiaNotificationPreferences preferences,
    required DateTime now,
    int limit = 32,
  }) {
    if (!preferences.enabled) return const <PlannedNotification>[];

    final sorted =
        candidates
            .where(
              (item) => preferences.allows(item.kind) && item.at.isAfter(now),
            )
            .toList()
          ..sort((a, b) {
            final date = a.at.compareTo(b.at);
            return date != 0
                ? date
                : _priority(a.kind).compareTo(_priority(b.kind));
          });

    final byDay = <String, PlannedNotification>{};
    for (final candidate in sorted) {
      final local = candidate.at.toLocal();
      final scheduled = _withinQuietWindow(local);
      if (!scheduled.isAfter(now.toLocal())) continue;
      final day = _dayKey(scheduled);
      final existing = byDay[day];
      if (existing == null ||
          _priority(candidate.kind) < _priority(existing.candidate.kind)) {
        byDay[day] = PlannedNotification(candidate, scheduled);
      }
    }

    final result = byDay.values.toList()..sort((a, b) => a.at.compareTo(b.at));
    return result.take(limit).toList(growable: false);
  }

  static DateTime _withinQuietWindow(DateTime local) {
    if (local.hour < 9) {
      return DateTime(local.year, local.month, local.day, 9);
    }
    if (local.hour >= 21) {
      return DateTime(local.year, local.month, local.day + 1, 9);
    }
    return local;
  }

  static int _priority(PetopiaNotificationKind kind) => switch (kind) {
    PetopiaNotificationKind.postcard => 0,
    PetopiaNotificationKind.revisit => 1,
    PetopiaNotificationKind.event => 2,
    PetopiaNotificationKind.anniversary => 3,
  };

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class NotificationService {
  static const _firstManagedId = 1200;
  static const _lastManagedId = 1299;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inited = false;
  bool _timezoneReady = false;

  Future<bool?> sync({
    required List<PetopiaNotificationCandidate> candidates,
    required PetopiaNotificationPreferences preferences,
    bool requestPermission = false,
  }) async {
    try {
      await _ensureInit();
      await _cancelManaged();
      if (!preferences.enabled) return null;
      final permissionGranted = requestPermission
          ? await _requestPermission()
          : null;
      if (permissionGranted == false) return false;
      await _ensureTimezone();

      final planned = NotificationPlanner.plan(
        candidates: candidates,
        preferences: preferences,
        now: DateTime.now(),
      );
      for (var index = 0; index < planned.length; index++) {
        final item = planned[index];
        await _plugin.zonedSchedule(
          id: _firstManagedId + index,
          title: item.candidate.title,
          body: item.candidate.body,
          scheduledDate: tz.TZDateTime.from(item.at, tz.local),
          payload: item.candidate.key,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'petopia_moments',
              '院子里的新消息',
              channelDescription: '明信片、老朋友回访与纪念日',
              importance: Importance.low,
              priority: Priority.low,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: false,
              presentBadge: false,
              presentBanner: false,
              presentList: false,
              presentSound: false,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      return permissionGranted;
    } catch (error, stackTrace) {
      debugPrint('Petopia notification sync skipped: $error\n$stackTrace');
      return null;
    }
  }

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

  Future<void> _ensureTimezone() async {
    if (_timezoneReady) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    _timezoneReady = true;
  }

  Future<bool?> _requestPermission() async {
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: false);
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return ios ?? android;
  }

  Future<void> _cancelManaged() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= _firstManagedId && request.id <= _lastManagedId) {
        await _plugin.cancel(id: request.id);
      }
    }
    // Remove the legacy generic daily reminder from pre-release builds.
    await _plugin.cancel(id: 0);
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
