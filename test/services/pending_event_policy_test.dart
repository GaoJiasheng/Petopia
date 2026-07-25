import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/domain/models/game_state.dart';
import 'package:petopia/services/pending_event_policy.dart';

PendingGameEvent _event(String id, EventType type) {
  return PendingGameEvent(
    id: id,
    eventId: id,
    petId: 'pet',
    title: id,
    script: id,
    type: type,
    expReward: 1,
    currencyReward: 0,
    createdAt: DateTime(2026, 7, 23),
  );
}

void main() {
  test('daily backlog is evicted before unseen special moments', () {
    final events = <PendingGameEvent>[
      _event('special-old', EventType.special),
      for (var index = 0; index < 6; index++)
        _event('daily-$index', EventType.daily),
    ];

    trimPendingEventQueue(events);

    expect(events, hasLength(6));
    expect(events.map((item) => item.id), contains('special-old'));
    expect(events.map((item) => item.id), isNot(contains('daily-0')));
  });

  test('an incoming special event displaces the oldest daily event', () {
    final events = <PendingGameEvent>[
      for (var index = 0; index < 6; index++)
        _event('daily-$index', EventType.daily),
      _event('special-new', EventType.special),
    ];

    trimPendingEventQueue(events);

    expect(events.map((item) => item.id), contains('special-new'));
    expect(events.map((item) => item.id), isNot(contains('daily-0')));
  });
}
