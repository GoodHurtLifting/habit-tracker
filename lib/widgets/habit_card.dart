import 'package:flutter/material.dart';

import '../data/habit_milestone_definitions.dart';
import '../models/habit.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit_milestone.dart';
import '../utils/date_formatter.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isMarkedToday;
  final int streakCount;
  final int totalCount;
  final HabitMilestone? currentMilestone;
  final HabitMilestone? nextMilestone;
  final int? milestoneDaysRemaining;
  final HabitBenefitMessage? dailyBenefitMessage;
  final DateTime? lastLoggedDate;
  final bool isExpanded;
  final bool canLogToday;
  final VoidCallback onPressed;
  final VoidCallback onEdit;
  final VoidCallback onPauseResume;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onToggleExpanded;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isMarkedToday,
    required this.streakCount,
    required this.totalCount,
    required this.currentMilestone,
    required this.nextMilestone,
    required this.milestoneDaysRemaining,
    required this.dailyBenefitMessage,
    required this.lastLoggedDate,
    required this.isExpanded,
    required this.canLogToday,
    required this.onPressed,
    required this.onEdit,
    required this.onPauseResume,
    required this.onArchive,
    required this.onDelete,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBuildHabit = habit.type == HabitType.build;
    final bool isWeeklyBuild =
        isBuildHabit && isWeeklyMilestoneTrack(habit.milestoneTrackId);
    final int? weeklyTarget = getWeeklyTargetCountForTrack(habit.milestoneTrackId);
    final Color accentColor = isBuildHabit ? Colors.blue : Colors.orange;

    final String streakText = isBuildHabit
        ? isWeeklyBuild
            ? 'Streak: $streakCount weeks at ${weeklyTarget ?? 3}+/week • Total workouts: $totalCount'
            : 'Streak: $streakCount days • Total: $totalCount'
        : 'Avoidance Streak: $streakCount days • Slips: $totalCount';

    final String buttonText = !canLogToday
        ? 'Paused'
        : isMarkedToday
            ? 'Undo'
            : (isBuildHabit
                ? (isWeeklyBuild ? 'Log workout' : 'Done')
                : 'Slip');

    final HabitMilestone? activeMilestone = currentMilestone;
    final HabitMilestone? upcomingMilestone = nextMilestone;
    final int? daysRemaining = milestoneDaysRemaining;
    final HabitBenefitMessage? perkMessage = dailyBenefitMessage;
    final String lastLoggedText = lastLoggedDate == null
        ? 'Not yet'
        : DateFormatter.weekdayMonthDay(lastLoggedDate!);

    final String? milestoneDaysText = daysRemaining == null
        ? null
        : isWeeklyBuild
            ? (daysRemaining == 1 ? '1 week to go' : '$daysRemaining weeks to go')
            : (daysRemaining == 1 ? '1 day to go' : '$daysRemaining days to go');

    final String todayStatusText = isBuildHabit
        ? (isMarkedToday ? 'Logged today' : 'Not logged today')
        : (isMarkedToday ? 'Slipped today' : 'No slip today');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 5)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onToggleExpanded,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (habit.isPaused)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Paused',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (activeMilestone != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                activeMilestone.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              streakText,
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (!isExpanded) ...[
                              const SizedBox(height: 2),
                              Text(
                                todayStatusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isMarkedToday ? accentColor : Colors.grey[700],
                                ),
                              ),
                            ],
                            if (isExpanded) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (habit.description != null &&
                                        habit.description!.trim().isNotEmpty) ...[
                                      Text(
                                        habit.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (activeMilestone != null) ...[
                                      Text(
                                        'What to expect: ${activeMilestone.expectation}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Why it matters: ${activeMilestone.benefit}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                    if (upcomingMilestone != null &&
                                        milestoneDaysText != null) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'Next milestone: ${upcomingMilestone.title}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        milestoneDaysText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                    if (perkMessage != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Today’s perk',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        perkMessage.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      'Last logged: $lastLoggedText',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      todayStatusText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isMarkedToday ? accentColor : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ElevatedButton(
                          onPressed: canLogToday ? onPressed : null,
                          child: Text(buttonText),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit habit',
                              ),
                              IconButton(
                                onPressed: onPauseResume,
                                icon: Icon(
                                  habit.isPaused
                                      ? Icons.play_circle_outline
                                      : Icons.pause_circle_outline,
                                ),
                                tooltip: habit.isPaused
                                    ? 'Resume habit'
                                    : 'Pause habit',
                              ),
                              IconButton(
                                onPressed: onArchive,
                                icon: const Icon(Icons.archive_outlined),
                                tooltip: 'Archive habit',
                              ),
                              IconButton(
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete habit',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
