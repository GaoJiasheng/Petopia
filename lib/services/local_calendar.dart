import '../domain/enums.dart';

/// Single source of truth for player-facing calendar semantics.
///
/// Persisted timestamps remain UTC, while natural days, seasons and time
/// windows are always evaluated in the device's current local timezone.
abstract final class LocalCalendar {
  static DateTime local(DateTime value) => value.toLocal();

  static DateTime date(DateTime value) {
    final localValue = local(value);
    return DateTime(localValue.year, localValue.month, localValue.day);
  }

  static String dayKey(DateTime value) {
    final localValue = local(value);
    return '${localValue.year.toString().padLeft(4, '0')}-'
        '${localValue.month.toString().padLeft(2, '0')}-'
        '${localValue.day.toString().padLeft(2, '0')}';
  }

  static String previousDayKey(DateTime value) {
    final localValue = local(value);
    return dayKey(
      DateTime(localValue.year, localValue.month, localValue.day - 1),
    );
  }

  /// Stable natural-week key using the local Monday date. Keeping the date
  /// instead of a week number avoids ISO week-year edge cases around New Year.
  static String weekKey(DateTime value) {
    final localValue = local(value);
    final monday = DateTime(
      localValue.year,
      localValue.month,
      localValue.day - (localValue.weekday - DateTime.monday),
    );
    return dayKey(monday);
  }

  static DateTime at(DateTime day, int hour, [int minute = 0]) {
    final localDay = local(day);
    return DateTime(localDay.year, localDay.month, localDay.day, hour, minute);
  }

  static bool isSameDay(DateTime left, DateTime right) =>
      dayKey(left) == dayKey(right);

  static Season season(DateTime value) {
    final month = local(value).month;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  static TimeOfDayOfDay timeOfDay(DateTime value) =>
      timeOfDayForHour(local(value).hour);

  static TimeOfDayOfDay timeOfDayForHour(int hour) {
    if (hour < 6) return TimeOfDayOfDay.night;
    if (hour < 9) return TimeOfDayOfDay.dawn;
    if (hour < 12) return TimeOfDayOfDay.morning;
    if (hour < 14) return TimeOfDayOfDay.noon;
    if (hour < 18) return TimeOfDayOfDay.afternoon;
    if (hour < 21) return TimeOfDayOfDay.evening;
    return TimeOfDayOfDay.night;
  }

  static bool isNight(DateTime value) {
    final hour = local(value).hour;
    return hour >= 18 || hour < 6;
  }
}
