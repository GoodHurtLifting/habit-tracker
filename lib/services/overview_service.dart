import '../models/calendar_day_summary.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'database_service.dart';

class OverviewService {
  OverviewService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<Map<DateTime, CalendarDaySummary>> getMonthSummaries(
    DateTime month,
  ) async {
    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final DateTime nextMonthStart = DateTime(month.year, month.month + 1, 1);

    final List<Habit> habits = await _databaseService.getHabits();
    final List<HabitLog> logs = await _databaseService.getHabitLogsForDateRange(
      monthStart,
      nextMonthStart,
    );

    final Map<String, String> habitNameById = {
      for (final habit in habits) habit.id: habit.name,
    };

    final Map<DateTime, Set<String>> goalsByDay = {};
    final Map<DateTime, Set<String>> slipsByDay = {};

    for (final log in logs) {
      final DateTime day = DateTime(log.date.year, log.date.month, log.date.day);
      final String habitName = habitNameById[log.habitId] ?? 'Unknown habit';

      if (log.status == HabitLogStatus.success) {
        goalsByDay.putIfAbsent(day, () => <String>{}).add(habitName);
      } else {
        slipsByDay.putIfAbsent(day, () => <String>{}).add(habitName);
      }
    }

    final Set<DateTime> allDays = {
      ...goalsByDay.keys,
      ...slipsByDay.keys,
    };

    final Map<DateTime, CalendarDaySummary> summaries = {};

    for (final day in allDays) {
      final List<String> goalHits = (goalsByDay[day] ?? <String>{}).toList()
        ..sort();
      final List<String> slips = (slipsByDay[day] ?? <String>{}).toList()..sort();

      summaries[day] = CalendarDaySummary(
        date: day,
        goalHitHabitNames: goalHits,
        slipHabitNames: slips,
      );
    }

    return summaries;
  }
}
