import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit_milestone.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isMarkedToday;
  final int streakCount;
  final int totalCount;
  final HabitMilestone? currentMilestone;
  final HabitMilestone? nextMilestone;
  final int? milestoneDaysRemaining;
  final HabitBenefitMessage? dailyBenefitMessage;
  final VoidCallback onPressed;
  final VoidCallback onDelete;
  final VoidCallback onTap;

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
    required this.onPressed,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBuildHabit = habit.type == HabitType.build;
    final Color accentColor = isBuildHabit ? Colors.blue : Colors.orange;

    final String streakText = isBuildHabit
        ? 'Streak: $streakCount days • Total: $totalCount'
        : 'Avoidance Streak: $streakCount days • Slips: $totalCount';

    final String buttonText = isMarkedToday ? 'Undo' : (isBuildHabit ? 'Done' : 'Slip');

    final HabitMilestone? activeMilestone = currentMilestone;
    final HabitMilestone? upcomingMilestone = nextMilestone;
    final int? daysRemaining = milestoneDaysRemaining;
    final HabitBenefitMessage? perkMessage = dailyBenefitMessage;

    final String? milestoneDaysText = daysRemaining == null
        ? null
        : daysRemaining == 1
            ? '1 day to go'
            : '$daysRemaining days to go';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete habit',
                          ),
                        ],
                      ),
                      if (habit.description != null && habit.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        isBuildHabit ? 'Build Habit' : 'Avoid Habit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(streakText, style: const TextStyle(fontSize: 14)),
                      if (activeMilestone != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current milestone: ${activeMilestone.title}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Why it matters: ${activeMilestone.benefit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (upcomingMilestone != null &&
                          daysRemaining != null &&
                          milestoneDaysText != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next milestone: ${upcomingMilestone.title}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                milestoneDaysText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'What to expect: ${upcomingMilestone.expectation}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Why it matters: ${upcomingMilestone.benefit}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (perkMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        isBuildHabit
                            ? (isMarkedToday ? 'Completed today' : 'Not completed today')
                            : (isMarkedToday ? 'Slipped today' : 'No slip today'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isMarkedToday ? accentColor : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          child: Text(buttonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
