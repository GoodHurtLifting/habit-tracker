import '../data/habit_milestone_definitions.dart';
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

  static int _getBuildStreak(
      Habit habit,
      List<HabitLog> logs,
      DateTime today,
      ) {
    int streak = 0;
    DateTime day = today;

    while (true) {
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
    final DateTime createdDay = _dateOnly(habit.createdAt);

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

    while (!day.isBefore(createdDay)) {
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