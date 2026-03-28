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
        loggedStatus: logsByHabitId[habit.id]?.status,
        canLog: HabitStatsService.canLogHabitForDate(habit, day),
        isPaused: HabitStatsService.isHabitPausedOnDate(habit, day),
      );
    }).toList();
  }

  Future<void> setLogForDay({
    required Habit habit,
    required DateTime date,
    required HabitLogStatus? status,
  }) async {
    await ensureWeeklySummariesUpToDate();
    final DateTime day = DateTime(date.year, date.month, date.day);

    if (!canEditDate(day)) {
      return;
    }

    if (!HabitStatsService.canLogHabitForDate(habit, day)) {
      return;
    }

    if (status == null) {
      await _databaseService.deleteHabitLogByDate(habit.id, day);
      return;
    }

    await _databaseService.upsertHabitLogForDate(
      habitId: habit.id,
      date: day,
      status: status,
    );
  }

  Future<Map<DateTime, CalendarDaySummary>> getMonthSummaries(
      DateTime month,
      ) async {
    await ensureWeeklySummariesUpToDate();
    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final DateTime nextMonthStart = DateTime(month.year, month.month + 1, 1);

    final List<Habit> allHabits = await _databaseService.getHabits();
    final List<HabitLog> logs = await _databaseService.getHabitLogsForDateRange(
      monthStart,
      nextMonthStart,
    );

    final Map<String, Habit> habitsById = {
      for (final habit in allHabits) habit.id: habit,
    };

    final Map<DateTime, Set<String>> goalsByDay = {};
    final Map<DateTime, Set<String>> slipsByDay = {};

    for (final log in logs) {
      final DateTime day = DateTime(log.date.year, log.date.month, log.date.day);
      final Habit? habit = habitsById[log.habitId];
      final String habitName = habit?.name ?? 'Unknown habit';

      if (log.status == HabitLogStatus.success) {
        goalsByDay.putIfAbsent(day, () => <String>{}).add(habitName);
      } else {
        slipsByDay.putIfAbsent(day, () => <String>{}).add(habitName);
      }
    }

    final DateTime normalizedMonth = DateFormatter.normalize(monthStart);
    final int daysInMonth = DateTime(
      normalizedMonth.year,
      normalizedMonth.month + 1,
      0,
    ).day;

    final Map<DateTime, CalendarDaySummary> summaries = {};

    for (int i = 0; i < daysInMonth; i++) {
      final DateTime day =
      DateTime(normalizedMonth.year, normalizedMonth.month, i + 1);

      final List<String> goalHits = (goalsByDay[day] ?? <String>{}).toList()..sort();
      final Set<String> slipNames = {...(slipsByDay[day] ?? <String>{})};

      bool hasMissedOpportunity = false;

      if (DateRules.isEligiblePastLoggingDate(day)) {
        for (final habit in allHabits) {
          if (!canEditDate(day)) {
            continue;
          }

          if (!HabitStatsService.canLogHabitForDate(habit, day)) {
            continue;
          }

          final bool alreadyHasExplicitLog =
              goalHits.contains(habit.name) || slipNames.contains(habit.name);

          if (alreadyHasExplicitLog) {
            continue;
          }

          if (habit.type == HabitType.avoid) {
            // Past unlogged avoid day counts as a slip.
            slipNames.add(habit.name);
          } else {
            // Build habit past unlogged stays a gray missed opportunity.
            hasMissedOpportunity = true;
          }
        }
      }

      final List<String> slips = slipNames.toList()..sort();
      final bool hasActivity = goalHits.isNotEmpty || slips.isNotEmpty;

      summaries[day] = CalendarDaySummary(
        date: day,
        goalHitHabitNames: goalHits,
        slipHabitNames: slips,
        hasMissedOpportunity: !hasActivity && hasMissedOpportunity,
      );
    }

    return summaries;
  }
}

class DayHabitLogState {
  final Habit habit;
  final HabitLogStatus? loggedStatus;
  final bool canLog;
  final bool isPaused;

  const DayHabitLogState({
    required this.habit,
    required this.loggedStatus,
    required this.canLog,
    required this.isPaused,
  });
}
