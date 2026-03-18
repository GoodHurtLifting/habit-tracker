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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  factory HabitLog.fromMap(Map<String, Object?> map) {
    return HabitLog(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      date: DateTime.parse(map['date'] as String),
      status: HabitLogStatus.values.firstWhere(
        (logStatus) => logStatus.name == map['status'],
      ),
    );
  }
}
