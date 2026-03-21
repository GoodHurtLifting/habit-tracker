import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _weekdayMonthDayFormat = DateFormat('EEE, MMM d');

  static String weekdayMonthDay(DateTime date) {
    return _weekdayMonthDayFormat.format(date);
  }

  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}