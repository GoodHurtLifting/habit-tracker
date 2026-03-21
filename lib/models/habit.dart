enum HabitType {
  build,
  avoid,
}

class Habit {
  static const Object _unset = Object();

  final String id;
  final String name;
  final String? description;
  final HabitType type;
  final DateTime createdAt;
  final String? milestoneTrackId;
  final bool isPaused;
  final DateTime? pausedAt;
  final DateTime? resumedAt;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdAt,
    this.milestoneTrackId,
    this.isPaused = false,
    this.pausedAt,
    this.resumedAt,
  });

  Habit copyWith({
    String? id,
    String? name,
    Object? description = _unset,
    HabitType? type,
    DateTime? createdAt,
    Object? milestoneTrackId = _unset,
    bool? isPaused,
    Object? pausedAt = _unset,
    Object? resumedAt = _unset,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
      description == _unset ? this.description : description as String?,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      milestoneTrackId: milestoneTrackId == _unset
          ? this.milestoneTrackId
          : milestoneTrackId as String?,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt == _unset ? this.pausedAt : pausedAt as DateTime?,
      resumedAt: resumedAt == _unset ? this.resumedAt : resumedAt as DateTime?,
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
      'is_paused': isPaused ? 1 : 0,
      'paused_at': pausedAt?.toIso8601String(),
      'resumed_at': resumedAt?.toIso8601String(),
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
      isPaused: (map['is_paused'] as int? ?? 0) == 1,
      pausedAt: map['paused_at'] == null
          ? null
          : DateTime.parse(map['paused_at'] as String),
      resumedAt: map['resumed_at'] == null
          ? null
          : DateTime.parse(map['resumed_at'] as String),
    );
  }
}
