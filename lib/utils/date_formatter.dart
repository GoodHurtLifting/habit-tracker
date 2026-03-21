import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _weekdayMonthDayFormat = DateFormat('EEE, MMM d');
  static final DateFormat _monthDayFormat = DateFormat('MMM d');

  static String weekdayMonthDay(DateTime date) {
    return _weekdayMonthDayFormat.format(date);
  }

  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String monthDay(DateTime date) {
    return _monthDayFormat.format(date);
  }

  static String weekRange(DateTime start, DateTime end) {
    return '${monthDay(start)} – ${monthDay(end)}';
  }
}
