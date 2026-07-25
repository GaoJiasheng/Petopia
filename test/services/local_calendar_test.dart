import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/domain/enums.dart';
import 'package:petopia/services/local_calendar.dart';

void main() {
  test('UTC persistence round-trips to the same player-facing natural day', () {
    final local = DateTime(2026, 7, 23, 0, 30);
    final persisted = local.toUtc();

    expect(LocalCalendar.local(persisted), local);
    expect(LocalCalendar.dayKey(persisted), '2026-07-23');
    expect(LocalCalendar.date(persisted), DateTime(2026, 7, 23));
    expect(LocalCalendar.previousDayKey(persisted), '2026-07-22');
  });

  test('season, time of day and visitor window share one local context', () {
    final dawn = DateTime(2026, 3, 1, 6, 30).toUtc();
    final night = DateTime(2026, 12, 1, 23, 30).toUtc();

    expect(LocalCalendar.season(dawn), Season.spring);
    expect(LocalCalendar.timeOfDay(dawn), TimeOfDayOfDay.dawn);
    expect(LocalCalendar.isNight(dawn), isFalse);
    expect(LocalCalendar.season(night), Season.winter);
    expect(LocalCalendar.timeOfDay(night), TimeOfDayOfDay.night);
    expect(LocalCalendar.isNight(night), isTrue);
  });

  test('scheduled local wall-clock time survives UTC conversion', () {
    final source = DateTime(2026, 7, 23, 16, 45).toUtc();
    final scheduled = LocalCalendar.at(source, 19, 30);

    expect(scheduled, DateTime(2026, 7, 23, 19, 30));
    expect(LocalCalendar.local(scheduled.toUtc()).hour, 19);
    expect(LocalCalendar.local(scheduled.toUtc()).minute, 30);
  });

  test('natural week key is the local Monday across New Year', () {
    expect(LocalCalendar.weekKey(DateTime(2026, 7, 23)), '2026-07-20');
    expect(LocalCalendar.weekKey(DateTime(2027, 1, 1)), '2026-12-28');
    expect(LocalCalendar.weekKey(DateTime(2027, 1, 4)), '2027-01-04');
  });
}
