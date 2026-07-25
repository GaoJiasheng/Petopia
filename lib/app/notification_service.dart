import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../services/local_calendar.dart';

enum PetopiaNotificationKind { postcard, revisit, event, anniversary }

enum NotificationDestination { postcard, revisit, event, anniversary }

class NotificationOpenRequest {
  const NotificationOpenRequest({
    required this.destination,
    required this.targetId,
    required this.payload,
  });

  final NotificationDestination destination;
  final String targetId;
  final String payload;

  static NotificationOpenRequest? tryParse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final separator = payload.indexOf(':');
    if (separator <= 0 || separator == payload.length - 1) return null;
    final kind = payload.substring(0, separator);
    final value = payload.substring(separator + 1);
    final targetId = value.split(':').first;
    if (targetId.isEmpty) return null;
    final destination = switch (kind) {
      'postcard' => NotificationDestination.postcard,
      'revisit' => NotificationDestination.revisit,
      'event' => NotificationDestination.event,
      'anniversary' => NotificationDestination.anniversary,
      _ => null,
    };
    if (destination == null) return null;
    return NotificationOpenRequest(
      destination: destination,
      targetId: targetId,
      payload: payload,
    );
  }
}

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
      final local = LocalCalendar.local(candidate.at);
      final scheduled = _withinQuietWindow(local);
      if (!scheduled.isAfter(LocalCalendar.local(now))) continue;
      final day = LocalCalendar.dayKey(scheduled);
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
      return LocalCalendar.at(local, 9);
    }
    if (local.hour >= 21) {
      return LocalCalendar.at(
        DateTime(local.year, local.month, local.day + 1),
        9,
      );
    }
    return local;
  }

  static int _priority(PetopiaNotificationKind kind) => switch (kind) {
    PetopiaNotificationKind.postcard => 0,
    PetopiaNotificationKind.revisit => 1,
    PetopiaNotificationKind.event => 2,
    PetopiaNotificationKind.anniversary => 3,
  };
}

class NotificationService {
  static const _firstManagedId = 1200;
  static const _lastManagedId = 1299;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final void Function(NotificationOpenRequest request) onOpen;
  bool _inited = false;
  bool _timezoneReady = false;

  NotificationService({required this.onOpen});

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
      onDidReceiveNotificationResponse: (response) {
        final request = NotificationOpenRequest.tryParse(response.payload);
        if (request != null) onOpen(request);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final request = NotificationOpenRequest.tryParse(
        launch?.notificationResponse?.payload,
      );
      if (request != null) onOpen(request);
    }
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

final notificationOpenRequestProvider = StateProvider<NotificationOpenRequest?>(
  (ref) => null,
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    onOpen: (request) {
      ref.read(notificationOpenRequestProvider.notifier).state = request;
    },
  ),
);
