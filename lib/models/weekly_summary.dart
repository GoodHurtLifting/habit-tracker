class WeeklySummary {
  final String id;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final DateTime generatedAt;
  final int totalGoalHits;
  final int totalSlips;
  final int totalLoggedDays;
  final int totalLoggedHabits;

  const WeeklySummary({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.generatedAt,
    required this.totalGoalHits,
    required this.totalSlips,
    required this.totalLoggedDays,
    required this.totalLoggedHabits,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'week_start_date': weekStartDate.toIso8601String(),
      'week_end_date': weekEndDate.toIso8601String(),
      'generated_at': generatedAt.toIso8601String(),
      'total_goal_hits': totalGoalHits,
      'total_slips': totalSlips,
      'total_logged_days': totalLoggedDays,
      'total_logged_habits': totalLoggedHabits,
    };
  }

  factory WeeklySummary.fromMap(Map<String, Object?> map) {
    return WeeklySummary(
      id: map['id'] as String,
      weekStartDate: DateTime.parse(map['week_start_date'] as String),
      weekEndDate: DateTime.parse(map['week_end_date'] as String),
      generatedAt: DateTime.parse(map['generated_at'] as String),
      totalGoalHits: map['total_goal_hits'] as int? ?? 0,
      totalSlips: map['total_slips'] as int? ?? 0,
      totalLoggedDays: map['total_logged_days'] as int? ?? 0,
      totalLoggedHabits: map['total_logged_habits'] as int? ?? 0,
    );
  }
}
