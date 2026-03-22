import 'habit.dart';

class PredefinedHabitOption {
  final String id;
  final String displayName;
  final HabitType type;
  final String? milestoneTrackId;

  const PredefinedHabitOption({
    required this.id,
    required this.displayName,
    required this.type,
    required this.milestoneTrackId,
  });
}
