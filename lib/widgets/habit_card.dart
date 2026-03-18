import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isMarkedToday;
  final int streakCount;
  final int totalCount;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isMarkedToday,
    required this.streakCount,
    required this.totalCount,
    required this.onPressed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBuildHabit = habit.type == HabitType.build;
    final Color accentColor = isBuildHabit ? Colors.blue : Colors.orange;

    final String streakText = isBuildHabit
        ? 'Streak: $streakCount days • Total: $totalCount'
        : 'Avoidance Streak: $streakCount days • Slips: $totalCount';

    final String milestoneText = isBuildHabit
        ? 'Next milestone: Day 7'
        : 'Next milestone: Day 3';

    final String buttonText = isMarkedToday
        ? 'Undo'
        : (isBuildHabit ? 'Done' : 'Slip');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: 5,
            ),
          ),
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
                    if (habit.description != null &&
                        habit.description!.trim().isNotEmpty) ...[
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
                    Text(
                      streakText,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      milestoneText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isBuildHabit
                          ? (isMarkedToday
                          ? 'Completed today'
                          : 'Not completed today')
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
    );
  }
}