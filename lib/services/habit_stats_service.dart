import '../data/habit_benefit_definitions.dart';
import '../data/habit_milestone_definitions.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_milestone.dart';
import '../utils/date_rules.dart';

class NextMilestoneProgress {
  final HabitMilestone milestone;
  final int daysRemaining;

  const NextMilestoneProgress({
    required this.milestone,
    required this.daysRemaining,
  });
}

class HabitStatSummary {
  final Habit habit;
  final int currentStreak;
  final int bestStreak;
  final int totalLoggedDays;
  final DateTime? lastLoggedDate;
  final int totalCompletions;
  final int totalSlips;
  final bool isPaused;

  const HabitStatSummary({
    required this.habit,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalLoggedDays,
    required this.lastLoggedDate,
    required this.totalCompletions,
    required this.totalSlips,
    required this.isPaused,
  });
}

class HabitStatsService {
  static bool isWeeklyBuildHabit(Habit habit) {
    return habit.type == HabitType.build &&
        isWeeklyMilestoneTrack(habit.milestoneTrackId);
  }

  static int? getWeeklyTargetCount(Habit habit) {
    return getWeeklyTargetCountForTrack(habit.milestoneTrackId);
  }

  static int getCurrentWeekCompletionCount(Habit habit, List<HabitLog> logs) {
    final int? weeklyTarget = getWeeklyTargetCount(habit);
    if (weeklyTarget == null) {
      return 0;
    }

    final Set<DateTime> successDays = _getHabitSuccessDays(habit, logs);
    final DateTime weekStart = DateRules.startOfWeekMonday(_dateOnly(DateTime.now()));
    return _countSuccessDaysInWeek(successDays, weekStart);
  }

  static bool isHabitArchived(Habit habit) {
    return habit.isArchived;
  }

  static List<Habit> getVisibleHabits(List<Habit> habits) {
    return habits.where((habit) => !isHabitArchived(habit)).toList();
  }

  static bool isHabitCurrentlyPaused(Habit habit) {
    return habit.isPaused;
  }

  static DateTime getEffectiveStreakStartBoundary(Habit habit) {
    final DateTime createdDay = _dateOnly(habit.createdAt);
    final DateTime? resumedDay = habit.resumedAt == null
        ? null
        : _dateOnly(habit.resumedAt!);

    if (resumedDay == null || resumedDay.isBefore(createdDay)) {
      return createdDay;
    }

    return resumedDay;
  }

  static bool isHabitPausedOnDate(Habit habit, DateTime date) {
    final DateTime day = _dateOnly(date);

    if (habit.isPaused) {
      final DateTime pausedDay = habit.pausedAt == null
          ? _dateOnly(DateTime.now())
          : _dateOnly(habit.pausedAt!);
      return !day.isBefore(pausedDay);
    }

    final DateTime? pausedDay =
        habit.pausedAt == null ? null : _dateOnly(habit.pausedAt!);
    final DateTime? resumedDay =
        habit.resumedAt == null ? null : _dateOnly(habit.resumedAt!);

    if (pausedDay == null || resumedDay == null) {
      return false;
    }

    return !day.isBefore(pausedDay) && day.isBefore(resumedDay);
  }

  static bool canLogHabitForDate(Habit habit, DateTime date) {
    if (isHabitArchived(habit)) {
      return false;
    }

    if (isHabitCurrentlyPaused(habit)) {
      return false;
    }

    return !isHabitPausedOnDate(habit, date);
  }

  static int getCurrentStreak(Habit habit, List<HabitLog> logs) {
    final DateTime today = _dateOnly(DateTime.now());

    if (isWeeklyBuildHabit(habit)) {
      return _getWeeklyBuildStreak(habit, logs, today);
    } else if (habit.type == HabitType.build) {
      return _getBuildStreak(habit, logs, today);
    } else {
      return _getAvoidStreak(habit, logs, today);
    }
  }

  static int getTotalCount(Habit habit, List<HabitLog> logs) {
    if (habit.type == HabitType.build) {
      return logs.where((log) {
        return log.habitId == habit.id && log.status == HabitLogStatus.success;
      }).length;
    } else {
      return logs.where((log) {
        return log.habitId == habit.id && log.status == HabitLogStatus.failure;
      }).length;
    }
  }

  static int getBestStreak(Habit habit, List<HabitLog> logs) {
    if (isWeeklyBuildHabit(habit)) {
      return _getBestWeeklyBuildStreak(habit, logs);
    } else if (habit.type == HabitType.build) {
      return _getBestBuildStreak(logs);
    } else {
      return _getBestAvoidStreak(habit, logs);
    }
  }

  static HabitStatSummary getHabitStatSummary(Habit habit, List<HabitLog> logs) {
    final List<HabitLog> habitLogs = logs.where((log) => log.habitId == habit.id).toList();
    final Map<String, DateTime> lastLoggedDates = getLastLoggedDatesByHabit(habitLogs);
    final Set<DateTime> loggedDays = habitLogs.map((log) => _dateOnly(log.date)).toSet();

    final int totalCompletions = habitLogs.where((log) {
      return log.status == HabitLogStatus.success;
    }).length;
    final int totalSlips = habitLogs.where((log) {
      return log.status == HabitLogStatus.failure;
    }).length;

    return HabitStatSummary(
      habit: habit,
      currentStreak: getCurrentStreak(habit, habitLogs),
      bestStreak: getBestStreak(habit, habitLogs),
      totalLoggedDays: loggedDays.length,
      lastLoggedDate: lastLoggedDates[habit.id],
      totalCompletions: totalCompletions,
      totalSlips: totalSlips,
      isPaused: habit.isPaused,
    );
  }

  static List<HabitStatSummary> getAllHabitStatSummaries(
    List<Habit> habits,
    List<HabitLog> logs,
  ) {
    return habits.map((habit) => getHabitStatSummary(habit, logs)).toList();
  }

  static Map<String, DateTime> getLastLoggedDatesByHabit(List<HabitLog> logs) {
    final Map<String, DateTime> latestByHabitId = {};

    for (final log in logs) {
      final DateTime logDay = _dateOnly(log.date);
      final DateTime? existing = latestByHabitId[log.habitId];

      if (existing == null || logDay.isAfter(existing)) {
        latestByHabitId[log.habitId] = logDay;
      }
    }

    return latestByHabitId;
  }

  static NextMilestoneProgress? getNextMilestoneProgress(
      Habit habit,
      int currentStreak,
      ) {
    final String? trackId = habit.milestoneTrackId;

    if (trackId == null || trackId.isEmpty) {
      return null;
    }

    final List<HabitMilestone> trackMilestones = getMilestonesForTrack(trackId);

    if (trackMilestones.isEmpty) {
      return null;
    }

    for (final milestone in trackMilestones) {
      if (milestone.targetDays > currentStreak) {
        return NextMilestoneProgress(
          milestone: milestone,
          daysRemaining: milestone.targetDays - currentStreak,
        );
      }
    }

    return null;
  }

  static HabitMilestone? getCurrentMilestone(
    Habit habit,
    int currentStreak,
  ) {
    final String? trackId = habit.milestoneTrackId;

    if (trackId == null || trackId.isEmpty) {
      return null;
    }

    final List<HabitMilestone> trackMilestones = getMilestonesForTrack(trackId);

    if (trackMilestones.isEmpty) {
      return null;
    }

    HabitMilestone? currentMilestone;

    for (final milestone in trackMilestones) {
      if (milestone.targetDays <= currentStreak) {
        currentMilestone = milestone;
      } else {
        break;
      }
    }

    return currentMilestone;
  }

  static HabitBenefitMessage? getDailyBenefitMessage(
    Habit habit,
    int currentStreak,
  ) {
    final String? trackId = habit.milestoneTrackId;

    if (trackId == null || trackId.isEmpty) {
      return null;
    }

    final List<HabitBenefitMessage> trackBenefits = getBenefitsForTrack(trackId);

    if (trackBenefits.isEmpty) {
      return null;
    }

    final int selectedIndex = currentStreak % trackBenefits.length;
    return trackBenefits[selectedIndex];
  }

  static int _getBuildStreak(
      Habit habit,
      List<HabitLog> logs,
      DateTime today,
      ) {
    final DateTime streakStartBoundary = getEffectiveStreakStartBoundary(habit);

    int streak = 0;
    DateTime day = today;

    while (!day.isBefore(streakStartBoundary)) {
      final bool hasSuccess = logs.any((log) {
        final DateTime logDate = _dateOnly(log.date);
        return log.habitId == habit.id &&
            log.status == HabitLogStatus.success &&
            logDate.year == day.year &&
            logDate.month == day.month &&
            logDate.day == day.day;
      });

      if (hasSuccess) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static int _getAvoidStreak(
      Habit habit,
      List<HabitLog> logs,
      DateTime today,
      ) {
    final DateTime streakStartBoundary = getEffectiveStreakStartBoundary(habit);

    final bool hasFailureToday = logs.any((log) {
      final DateTime logDate = _dateOnly(log.date);
      return log.habitId == habit.id &&
          log.status == HabitLogStatus.failure &&
          logDate.year == today.year &&
          logDate.month == today.month &&
          logDate.day == today.day;
    });

    if (hasFailureToday) {
      return 0;
    }

    int streak = 0;
    DateTime day = today.subtract(const Duration(days: 1));

    while (!day.isBefore(streakStartBoundary)) {
      final bool hasFailure = logs.any((log) {
        final DateTime logDate = _dateOnly(log.date);
        return log.habitId == habit.id &&
            log.status == HabitLogStatus.failure &&
            logDate.year == day.year &&
            logDate.month == day.month &&
            logDate.day == day.day;
      });

      if (hasFailure) {
        break;
      }

      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int _getBestBuildStreak(List<HabitLog> logs) {
    final List<DateTime> successDays = logs
        .where((log) => log.status == HabitLogStatus.success)
        .map((log) => _dateOnly(log.date))
        .toSet()
        .toList()
      ..sort();

    if (successDays.isEmpty) {
      return 0;
    }

    int best = 1;
    int current = 1;

    for (int i = 1; i < successDays.length; i++) {
      final int dayGap = successDays[i].difference(successDays[i - 1]).inDays;
      if (dayGap == 1) {
        current++;
      } else {
        current = 1;
      }

      if (current > best) {
        best = current;
      }
    }

    return best;
  }

  static int _getWeeklyBuildStreak(
    Habit habit,
    List<HabitLog> logs,
    DateTime today,
  ) {
    final int? weeklyTarget = getWeeklyTargetCount(habit);
    if (weeklyTarget == null) {
      return 0;
    }

    final Set<DateTime> successDays = _getHabitSuccessDays(habit, logs);
    final DateTime startBoundary =
        DateRules.startOfWeekMonday(getEffectiveStreakStartBoundary(habit));
    final DateTime thisWeekStart = DateRules.startOfWeekMonday(today);

    DateTime weekStart = thisWeekStart;
    if (_countSuccessDaysInWeek(successDays, thisWeekStart) < weeklyTarget) {
      weekStart = thisWeekStart.subtract(const Duration(days: 7));
    }

    int streak = 0;
    while (!weekStart.isBefore(startBoundary)) {
      final int completions = _countSuccessDaysInWeek(successDays, weekStart);
      if (completions < weeklyTarget) {
        break;
      }

      streak++;
      weekStart = weekStart.subtract(const Duration(days: 7));
    }

    return streak;
  }

  static int _getBestWeeklyBuildStreak(Habit habit, List<HabitLog> logs) {
    final int? weeklyTarget = getWeeklyTargetCount(habit);
    if (weeklyTarget == null) {
      return 0;
    }

    final Set<DateTime> successDays = _getHabitSuccessDays(habit, logs);
    final DateTime startWeek =
        DateRules.startOfWeekMonday(getEffectiveStreakStartBoundary(habit));
    final DateTime currentWeek = DateRules.startOfWeekMonday(_dateOnly(DateTime.now()));

    int best = 0;
    int current = 0;
    DateTime weekStart = startWeek;
    while (!weekStart.isAfter(currentWeek)) {
      final int completions = _countSuccessDaysInWeek(successDays, weekStart);
      if (completions >= weeklyTarget) {
        current++;
        if (current > best) {
          best = current;
        }
      } else {
        current = 0;
      }

      weekStart = weekStart.add(const Duration(days: 7));
    }

    return best;
  }

  static Set<DateTime> _getHabitSuccessDays(Habit habit, List<HabitLog> logs) {
    return logs
        .where((log) => log.habitId == habit.id && log.status == HabitLogStatus.success)
        .map((log) => _dateOnly(log.date))
        .toSet();
  }

  static int _countSuccessDaysInWeek(Set<DateTime> successDays, DateTime weekStart) {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final DateTime day = weekStart.add(Duration(days: i));
      if (successDays.contains(day)) {
        count++;
      }
    }
    return count;
  }

  static int _getBestAvoidStreak(Habit habit, List<HabitLog> logs) {
    final DateTime start = _dateOnly(habit.createdAt);
    final DateTime today = _dateOnly(DateTime.now());
    final Set<DateTime> failureDays = logs
        .where((log) => log.status == HabitLogStatus.failure)
        .map((log) => _dateOnly(log.date))
        .toSet();

    int best = 0;
    int current = 0;
    DateTime day = start;

    while (!day.isAfter(today)) {
      if (failureDays.contains(day)) {
        current = 0;
      } else {
        current++;
        if (current > best) {
          best = current;
        }
      }

      day = day.add(const Duration(days: 1));
    }

    return best;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
