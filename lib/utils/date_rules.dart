import 'date_formatter.dart';

class DateRules {
  static const int _weeklyEditCutoffHour = 16;

  static DateTime normalizeDate(DateTime date) {
    return DateFormatter.normalize(date);
  }

  static DateTime startOfWeekMonday(DateTime date) {
    final DateTime day = normalizeDate(date);
    final int daysFromMonday = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: daysFromMonday));
  }

  static DateTime endOfWeekSunday(DateTime date) {
    return startOfWeekMonday(date).add(const Duration(days: 6));
  }

  static DateTime currentWeekCutoff(DateTime now) {
    final DateTime weekEnd = endOfWeekSunday(now);
    return DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
      _weeklyEditCutoffHour,
    );
  }

  static DateTime weekCutoffSunday4pm(DateTime weekStart) {
    final DateTime weekEnd = endOfWeekSunday(weekStart);
    return DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
      _weeklyEditCutoffHour,
    );
  }

  static DateTime? mostRecentEligibleCompletedWeekStart(DateTime now) {
    final DateTime thisWeekStart = startOfWeekMonday(now);
    final DateTime thisWeekCutoff = weekCutoffSunday4pm(thisWeekStart);

    if (!now.isBefore(thisWeekCutoff)) {
      return thisWeekStart;
    }

    return thisWeekStart.subtract(const Duration(days: 7));
  }

  static ({DateTime start, DateTime end}) getCurrentEditableWeekRange({
    DateTime? now,
  }) {
    final DateTime referenceNow = now ?? DateTime.now();
    final DateTime weekStart = startOfWeekMonday(referenceNow);
    final DateTime weekEnd = endOfWeekSunday(referenceNow);
    return (start: weekStart, end: weekEnd);
  }

  static bool isDateEditable(
    DateTime date, {
    DateTime? now,
  }) {
    final DateTime referenceNow = now ?? DateTime.now();
    final DateTime day = normalizeDate(date);
    final DateTime today = normalizeDate(referenceNow);

    if (day.isAfter(today)) {
      return false;
    }

    if (!referenceNow.isBefore(currentWeekCutoff(referenceNow))) {
      return false;
    }

    final ({DateTime start, DateTime end}) editableWeek =
        getCurrentEditableWeekRange(now: referenceNow);

    return !day.isBefore(editableWeek.start) && !day.isAfter(editableWeek.end);
  }

  static bool canEditDate(
    DateTime date, {
    DateTime? now,
  }) {
    return isDateEditable(date, now: now);
  }

  static bool isEligiblePastLoggingDate(
    DateTime date, {
    DateTime? now,
  }) {
    final DateTime referenceNow = now ?? DateTime.now();
    final DateTime day = normalizeDate(date);
    final DateTime today = normalizeDate(referenceNow);

    return day.isBefore(today) && isDateEditable(day, now: referenceNow);
  }
}
