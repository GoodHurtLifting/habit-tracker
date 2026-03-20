class CalendarDaySummary {
  final DateTime date;
  final List<String> goalHitHabitNames;
  final List<String> slipHabitNames;

  const CalendarDaySummary({
    required this.date,
    required this.goalHitHabitNames,
    required this.slipHabitNames,
  });

  bool get hasGoalHits => goalHitHabitNames.isNotEmpty;
  bool get hasSlips => slipHabitNames.isNotEmpty;
  bool get hasActivity => hasGoalHits || hasSlips;
}
