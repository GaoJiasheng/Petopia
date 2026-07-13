import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/models/game_state.dart';

void main() {
  test('care ledger renews daily counts but preserves cooldown history', () {
    final last = DateTime.utc(2026, 7, 12, 23, 59);
    final ledger = CareLedger(
      dayKey: '2026-07-12',
      counts: <String, int>{'feed': 12},
      lastAt: <String, DateTime>{'feed': last},
      firstCareRewarded: true,
    );

    ledger.renew('2026-07-13');

    expect(ledger.counts, isEmpty);
    expect(ledger.firstCareRewarded, isFalse);
    expect(ledger.lastAt['feed'], last);
  });
}
