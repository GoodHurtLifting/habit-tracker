enum HabitLogStatus {
  success,
  failure,
}

class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final HabitLogStatus status;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
  });
}