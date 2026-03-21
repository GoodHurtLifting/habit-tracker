import '../data/habit_benefit_definitions.dart';
import '../data/habit_milestone_definitions.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/habit_milestone.dart';

class NextMilestoneProgress {
  final HabitMilestone milestone;
  final int daysRemaining;

  const NextMilestoneProgress({
    required this.milestone,
    required this.daysRemaining,
  });
}

class HabitStatsService {
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

    if (habit.type == HabitType.build) {
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

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
