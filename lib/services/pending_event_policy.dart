import '../domain/enums.dart';
import '../domain/models/game_state.dart';

/// Caps the presentation backlog without letting routine stories evict a
/// rare special event that the player has not seen yet.
void trimPendingEventQueue(List<PendingGameEvent> events, {int maximum = 6}) {
  while (events.length > maximum) {
    final dailyIndex = events.indexWhere(
      (item) => item.type == EventType.daily,
    );
    events.removeAt(dailyIndex >= 0 ? dailyIndex : 0);
  }
}
