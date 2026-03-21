import '../models/calendar_day_summary.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../utils/date_formatter.dart';
import '../utils/date_rules.dart';
import 'database_service.dart';
import 'habit_stats_service.dart';
import 'weekly_summary_service.dart';

class OverviewService {
  OverviewService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance,
        _weeklySummaryService = WeeklySummaryService(
          databaseService: databaseService ?? DatabaseService.instance,
        );

  final DatabaseService _databaseService;
  final WeeklySummaryService _weeklySummaryService;
  Set<DateTime> _lockedWeekStarts = <DateTime>{};

  Future<void> ensureWeeklySummariesUpToDate() async {
    await _weeklySummaryService.ensureWeeklySummariesUpToDate();
    _lockedWeekStarts = await _weeklySummaryService.getLockedWeekStarts();
  }

  bool canEditDate(DateTime date, {DateTime? now}) {
    final DateTime day = DateRules.normalizeDate(date);
    final DateTime weekStart = DateRules.startOfWeekMonday(day);
    final bool isWeekLocked = _lockedWeekStarts.contains(weekStart);
    return !isWeekLocked && DateRules.canEditDate(day, now: now);
  }

  Future<List<DayHabitLogState>> getDayLogStates(DateTime date) async {
    await ensureWeeklySummariesUpToDate();

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
        canLog: HabitStatsService.canLogHabitForDate(habit, day),
        isPaused: HabitStatsService.isHabitPausedOnDate(habit, day),
      );
    }).toList();
  }

  Future<void> toggleLogForDay({
    required Habit habit,
    required DateTime date,
  }) async {
    await ensureWeeklySummariesUpToDate();
    final DateTime day = DateTime(date.year, date.month, date.day);

    if (!canEditDate(day)) {
      return;
    }

    if (!HabitStatsService.canLogHabitForDate(habit, day)) {
      return;
    }

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
    await ensureWeeklySummariesUpToDate();
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

    final DateTime normalizedMonth = DateFormatter.normalize(monthStart);
    final int daysInMonth = DateTime(
      normalizedMonth.year,
      normalizedMonth.month + 1,
      0,
    ).day;

    for (int i = 0; i < daysInMonth; i++) {
      allDays.add(
        DateTime(normalizedMonth.year, normalizedMonth.month, i + 1),
      );
    }

    for (final day in allDays) {
      final List<String> goalHits = (goalsByDay[day] ?? <String>{}).toList()
        ..sort();
      final List<String> slips = (slipsByDay[day] ?? <String>{}).toList()..sort();
      final bool hasActivity = goalHits.isNotEmpty || slips.isNotEmpty;
      final bool hasLoggableHabit = habits.any(
        (habit) => HabitStatsService.canLogHabitForDate(habit, day),
      );

      summaries[day] = CalendarDaySummary(
        date: day,
        goalHitHabitNames: goalHits,
        slipHabitNames: slips,
        hasMissedOpportunity:
            !hasActivity &&
            hasLoggableHabit &&
            DateRules.isEligiblePastLoggingDate(day),
      );
    }

    return summaries;
  }
}

class DayHabitLogState {
  final Habit habit;
  final bool isLogged;
  final bool canLog;
  final bool isPaused;

  const DayHabitLogState({
    required this.habit,
    required this.isLogged,
    required this.canLog,
    required this.isPaused,
  });
}
