enum HabitType {
  build,
  avoid,
}

class Habit {
  static const Object _unset = Object();
  static const String defaultBuildAccentColorKey = 'cool_blue';
  static const String defaultAvoidAccentColorKey = 'warm_orange';

  final String id;
  final String name;
  final String? description;
  final HabitType type;
  final DateTime createdAt;
  final String? milestoneTrackId;
  final bool isPaused;
  final DateTime? pausedAt;
  final DateTime? resumedAt;
  final bool isArchived;
  final DateTime? archivedAt;
  final int sortOrder;
  final String accentColorKey;
  final String? trigger1;
  final String? trigger2;
  final String? trigger3;
  final String? motivation1;
  final String? motivation2;
  final String? motivation3;

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
    this.isArchived = false,
    this.archivedAt,
    this.sortOrder = 0,
    required this.accentColorKey,
    this.trigger1,
    this.trigger2,
    this.trigger3,
    this.motivation1,
    this.motivation2,
    this.motivation3,
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
    bool? isArchived,
    Object? archivedAt = _unset,
    int? sortOrder,
    String? accentColorKey,
    Object? trigger1 = _unset,
    Object? trigger2 = _unset,
    Object? trigger3 = _unset,
    Object? motivation1 = _unset,
    Object? motivation2 = _unset,
    Object? motivation3 = _unset,
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
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt == _unset ? this.archivedAt : archivedAt as DateTime?,
      sortOrder: sortOrder ?? this.sortOrder,
      accentColorKey: accentColorKey ?? this.accentColorKey,
      trigger1: trigger1 == _unset ? this.trigger1 : trigger1 as String?,
      trigger2: trigger2 == _unset ? this.trigger2 : trigger2 as String?,
      trigger3: trigger3 == _unset ? this.trigger3 : trigger3 as String?,
      motivation1: motivation1 == _unset
          ? this.motivation1
          : motivation1 as String?,
      motivation2: motivation2 == _unset
          ? this.motivation2
          : motivation2 as String?,
      motivation3: motivation3 == _unset
          ? this.motivation3
          : motivation3 as String?,
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
      'is_archived': isArchived ? 1 : 0,
      'archived_at': archivedAt?.toIso8601String(),
      'sort_order': sortOrder,
      'accent_color_key': accentColorKey,
      'trigger1': trigger1,
      'trigger2': trigger2,
      'trigger3': trigger3,
      'motivation1': motivation1,
      'motivation2': motivation2,
      'motivation3': motivation3,
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
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      archivedAt: map['archived_at'] == null
          ? null
          : DateTime.parse(map['archived_at'] as String),
      sortOrder: map['sort_order'] as int? ?? 0,
      accentColorKey: (map['accent_color_key'] as String?) ??
          (map['type'] == HabitType.avoid.name
              ? defaultAvoidAccentColorKey
              : defaultBuildAccentColorKey),
      trigger1: map['trigger1'] as String?,
      trigger2: map['trigger2'] as String?,
      trigger3: map['trigger3'] as String?,
      motivation1: map['motivation1'] as String?,
      motivation2: map['motivation2'] as String?,
      motivation3: map['motivation3'] as String?,
    );
  }
}
