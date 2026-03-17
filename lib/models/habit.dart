enum HabitType {
  build,
  avoid,
}

class Habit {
  final String id;
  final String name;
  final String? description;
  final HabitType type;
  final DateTime createdAt;
  final bool isMarkedToday;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdAt,
    this.isMarkedToday = false,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitType? type,
    DateTime? createdAt,
    bool? isMarkedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isMarkedToday: isMarkedToday ?? this.isMarkedToday,
    );
  }
}