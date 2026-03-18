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
  final String? milestoneTrackId;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdAt,
    this.milestoneTrackId,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitType? type,
    DateTime? createdAt,
    String? milestoneTrackId,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      milestoneTrackId: milestoneTrackId ?? this.milestoneTrackId,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'milestone_track_id': milestoneTrackId,
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: HabitType.values.firstWhere(
        (habitType) => habitType.name == map['type'],
        orElse: () => HabitType.build,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      milestoneTrackId: map['milestone_track_id'] as String?,
    );
  }
}
