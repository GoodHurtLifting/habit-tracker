import '../models/calendar_day_summary.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'database_service.dart';

class OverviewService {
  OverviewService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<List<DayHabitLogState>> getDayLogStates(DateTime date) async {
    final DateTime day = DateTime(date.year, date.month, date.day);
    final List<Habit> habits = await _databaseService.getHabits();
    final List<HabitLog> dayLogs = await _databaseService.getHabitLogsForDate(day);

    final Map<String, HabitLog> logsByHabitId = {
      for (final log in dayLogs) log.habitId: log,
    };

    return habits.map((habit) {
      return DayHabitLogState(
        habit: habit,
        isLogged: logsByHabitId.containsKey(habit.id),
      );
    }).toList();
  }

  Future<void> toggleLogForDay({
    required Habit habit,
    required DateTime date,
  }) async {
    final DateTime day = DateTime(date.year, date.month, date.day);
    final List<HabitLog> dayLogs = await _databaseService.getHabitLogsForDate(day);

    final bool hasLog = dayLogs.any((log) => log.habitId == habit.id);

    if (hasLog) {
      await _databaseService.deleteHabitLogByDate(habit.id, day);
      return;
    }

    await _databaseService.upsertHabitLogForDate(
      habitId: habit.id,
      date: day,
      status: habit.type == HabitType.build
          ? HabitLogStatus.success
          : HabitLogStatus.failure,
    );
  }

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

class DayHabitLogState {
  final Habit habit;
  final bool isLogged;

  const DayHabitLogState({
    required this.habit,
    required this.isLogged,
  });
}
