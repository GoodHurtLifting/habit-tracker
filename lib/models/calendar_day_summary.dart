class CalendarDaySummary {
  final DateTime date;
  final List<String> goalHitHabitNames;
  final List<String> slipHabitNames;
  final bool hasMissedOpportunity;

  const CalendarDaySummary({
    required this.date,
    required this.goalHitHabitNames,
    required this.slipHabitNames,
    this.hasMissedOpportunity = false,
  });

  bool get hasGoalHits => goalHitHabitNames.isNotEmpty;
  bool get hasSlips => slipHabitNames.isNotEmpty;
  bool get hasActivity => hasGoalHits || hasSlips;
}
