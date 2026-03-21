import 'date_formatter.dart';

class DateRules {
  static DateTime startOfWeekSunday(DateTime date) {
    final DateTime day = DateFormatter.normalize(date);
    final int daysFromSunday = day.weekday % DateTime.daysPerWeek;
    return day.subtract(Duration(days: daysFromSunday));
  }

  static DateTime endOfWeekSaturday(DateTime date) {
    return startOfWeekSunday(date).add(const Duration(days: 6));
  }

  static bool isDateInCurrentEditableWeek(
    DateTime date, {
    DateTime? now,
  }) {
    final DateTime referenceNow = now ?? DateTime.now();
    final DateTime day = DateFormatter.normalize(date);
    final DateTime weekStart = startOfWeekSunday(referenceNow);
    final DateTime weekEnd = endOfWeekSaturday(referenceNow);

    return !day.isBefore(weekStart) && !day.isAfter(weekEnd);
  }

  static bool canEditDate(
    DateTime date, {
    DateTime? now,
  }) {
    final DateTime referenceNow = DateFormatter.normalize(now ?? DateTime.now());
    final DateTime day = DateFormatter.normalize(date);

    if (day.isAfter(referenceNow)) {
      return false;
    }

    return isDateInCurrentEditableWeek(day, now: referenceNow);
  }

  static bool isEligiblePastLoggingDate(
    DateTime date, {
    DateTime? now,
  }) {
    final DateTime referenceNow = DateFormatter.normalize(now ?? DateTime.now());
    final DateTime day = DateFormatter.normalize(date);
    return day.isBefore(referenceNow) && canEditDate(day, now: referenceNow);
  }
}
