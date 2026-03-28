import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/weekly_summary.dart';
import '../utils/date_rules.dart';
import 'database_service.dart';
import 'habit_stats_service.dart';

class WeeklySummaryService {
  WeeklySummaryService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<void> ensureWeeklySummariesUpToDate({DateTime? now}) async {
    final DateTime referenceNow = now ?? DateTime.now();
    final DateTime? latestEligibleWeekStart =
        DateRules.mostRecentEligibleCompletedWeekStart(referenceNow);

    if (latestEligibleWeekStart == null) {
      return;
    }

    final DateTime? firstWeekStart =
        await _databaseService.getEarliestTrackedWeekStartDate();

    if (firstWeekStart == null || firstWeekStart.isAfter(latestEligibleWeekStart)) {
      return;
    }

    DateTime weekStart = firstWeekStart;

    while (!weekStart.isAfter(latestEligibleWeekStart)) {
      await generateWeeklySummaryForWeek(weekStart);
      weekStart = weekStart.add(const Duration(days: 7));
    }
  }

  Future<WeeklySummary?> generateWeeklySummaryForWeek(DateTime weekStart) async {
    final DateTime normalizedWeekStart = DateRules.startOfWeekMonday(weekStart);
    final WeeklySummary? existing = await _databaseService
        .getWeeklySummaryForWeekStart(normalizedWeekStart);

    if (existing != null) {
      return existing;
    }

    final DateTime weekEnd = DateRules.endOfWeekSunday(normalizedWeekStart);
    final List<HabitLog> weekLogs = await _databaseService.getHabitLogsForDateRange(
      normalizedWeekStart,
      weekEnd.add(const Duration(days: 1)),
    );
    final List<Habit> habits = await _databaseService.getHabits();

    final int goalHits =
        weekLogs.where((log) => log.status == HabitLogStatus.success).length;

    final Map<String, Map<DateTime, HabitLogStatus>> statusByHabitByDay = {};

    for (final log in weekLogs) {
      final DateTime day = DateRules.normalizeDate(log.date);
      statusByHabitByDay.putIfAbsent(log.habitId, () => <DateTime, HabitLogStatus>{});
      statusByHabitByDay[log.habitId]![day] = log.status;
    }

    int slips = 0;

    // Count explicit failure logs first.
    slips += weekLogs.where((log) => log.status == HabitLogStatus.failure).length;

    // Add derived slips for avoid habits on past unlogged days.
    for (final habit in habits) {
      if (habit.type != HabitType.avoid) {
        continue;
      }

      for (int i = 0; i < 7; i++) {
        final DateTime day = normalizedWeekStart.add(Duration(days: i));

        if (!HabitStatsService.canLogHabitForDate(habit, day)) {
          continue;
        }

        final HabitLogStatus? status = statusByHabitByDay[habit.id]?[day];

        if (status == null) {
          slips++;
        }
      }
    }

    final Set<String> loggedDays = weekLogs
        .map((log) => DateRules.normalizeDate(log.date).toIso8601String())
        .toSet();
    final Set<String> loggedHabits = weekLogs.map((log) => log.habitId).toSet();

    final WeeklySummary summary = WeeklySummary(
      id: '${normalizedWeekStart.toIso8601String()}-${DateTime.now().millisecondsSinceEpoch}',
      weekStartDate: normalizedWeekStart,
      weekEndDate: weekEnd,
      generatedAt: DateTime.now(),
      totalGoalHits: goalHits,
      totalSlips: slips,
      totalLoggedDays: loggedDays.length,
      totalLoggedHabits: loggedHabits.length,
    );

    await _databaseService.insertWeeklySummary(summary);
    return summary;
  }

  Future<WeeklySummary?> getMostRecentWeeklySummary() {
    return _databaseService.getMostRecentWeeklySummary();
  }

  Future<bool> isWeekLocked(DateTime weekStart) async {
    final DateTime normalizedWeekStart = DateRules.startOfWeekMonday(weekStart);
    final WeeklySummary? summary =
        await _databaseService.getWeeklySummaryForWeekStart(normalizedWeekStart);
    return summary != null;
  }

  Future<Set<DateTime>> getLockedWeekStarts() async {
    final List<WeeklySummary> summaries = await _databaseService.getWeeklySummaries();
    return summaries.map((summary) => DateRules.startOfWeekMonday(summary.weekStartDate)).toSet();
  }
}
