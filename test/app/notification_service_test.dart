import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/notification_service.dart';

void main() {
  const allOn = PetopiaNotificationPreferences(
    enabled: true,
    postcards: true,
    visitors: true,
    events: true,
  );

  PetopiaNotificationCandidate candidate(
    String key,
    PetopiaNotificationKind kind,
    DateTime at,
  ) {
    return PetopiaNotificationCandidate(
      key: key,
      kind: kind,
      at: at,
      title: key,
      body: key,
    );
  }

  test('master switch disables all scheduling', () {
    final result = NotificationPlanner.plan(
      candidates: [
        candidate(
          'card',
          PetopiaNotificationKind.postcard,
          DateTime(2026, 7, 15, 10),
        ),
      ],
      preferences: const PetopiaNotificationPreferences(
        enabled: false,
        postcards: true,
        visitors: true,
        events: true,
      ),
      now: DateTime(2026, 7, 14, 10),
    );

    expect(result, isEmpty);
  });

  test('category switches filter candidates', () {
    final result = NotificationPlanner.plan(
      candidates: [
        candidate(
          'card',
          PetopiaNotificationKind.postcard,
          DateTime(2026, 7, 15, 10),
        ),
        candidate(
          'visitor',
          PetopiaNotificationKind.revisit,
          DateTime(2026, 7, 16, 10),
        ),
      ],
      preferences: const PetopiaNotificationPreferences(
        enabled: true,
        postcards: false,
        visitors: true,
        events: false,
      ),
      now: DateTime(2026, 7, 14, 10),
    );

    expect(result.map((item) => item.candidate.key), ['visitor']);
  });

  test('only one notification is kept per day using emotional priority', () {
    final result = NotificationPlanner.plan(
      candidates: [
        candidate(
          'anniversary',
          PetopiaNotificationKind.anniversary,
          DateTime(2026, 7, 15, 9, 30),
        ),
        candidate(
          'visitor',
          PetopiaNotificationKind.revisit,
          DateTime(2026, 7, 15, 11),
        ),
        candidate(
          'card',
          PetopiaNotificationKind.postcard,
          DateTime(2026, 7, 15, 18),
        ),
      ],
      preferences: allOn,
      now: DateTime(2026, 7, 14, 10),
    );

    expect(result, hasLength(1));
    expect(result.single.candidate.key, 'card');
    expect(result.single.at, DateTime(2026, 7, 15, 18));
  });

  test(
    'early candidates wait until 09:00 and late candidates move to next day',
    () {
      final result = NotificationPlanner.plan(
        candidates: [
          candidate(
            'early',
            PetopiaNotificationKind.postcard,
            DateTime(2026, 7, 15, 6, 30),
          ),
          candidate(
            'late',
            PetopiaNotificationKind.postcard,
            DateTime(2026, 7, 16, 22, 30),
          ),
        ],
        preferences: allOn,
        now: DateTime(2026, 7, 14, 10),
      );

      expect(result.map((item) => item.at), [
        DateTime(2026, 7, 15, 9),
        DateTime(2026, 7, 17, 9),
      ]);
    },
  );

  test('past candidates are ignored and the schedule limit is respected', () {
    final now = DateTime(2026, 7, 14, 10);
    final result = NotificationPlanner.plan(
      candidates: [
        candidate(
          'past',
          PetopiaNotificationKind.postcard,
          DateTime(2026, 7, 14, 9),
        ),
        for (var day = 1; day <= 5; day++)
          candidate(
            'future-$day',
            PetopiaNotificationKind.postcard,
            DateTime(2026, 7, 14 + day, 10),
          ),
      ],
      preferences: allOn,
      now: now,
      limit: 3,
    );

    expect(result.map((item) => item.candidate.key), [
      'future-1',
      'future-2',
      'future-3',
    ]);
  });
}
