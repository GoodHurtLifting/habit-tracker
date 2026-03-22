import '../models/habit.dart';
import '../models/predefined_habit_option.dart';
import 'habit_milestone_definitions.dart';

class PredefinedHabitIds {
  PredefinedHabitIds._();

  static const String quitSmoking = 'quit_smoking';
  static const String quitDrinking = 'quit_drinking';
  static const String quitCocaine = 'quit_cocaine';
  static const String dailyWalk = 'daily_walk';
  static const String readTwentyMinutes = 'read_twenty_minutes';
  static const String exercise = 'exercise';
}

const List<PredefinedHabitOption> predefinedHabitOptions = [
  PredefinedHabitOption(
    id: PredefinedHabitIds.quitSmoking,
    displayName: 'Quit Smoking',
    type: HabitType.avoid,
    milestoneTrackId: HabitMilestoneTracks.quitSmoking,
  ),
  PredefinedHabitOption(
    id: PredefinedHabitIds.quitDrinking,
    displayName: 'Quit Drinking',
    type: HabitType.avoid,
    milestoneTrackId: HabitMilestoneTracks.quitDrinking,
  ),
  PredefinedHabitOption(
    id: PredefinedHabitIds.quitCocaine,
    displayName: 'Quit Cocaine',
    type: HabitType.avoid,
    milestoneTrackId: HabitMilestoneTracks.quitCocaine,
  ),
  PredefinedHabitOption(
    id: PredefinedHabitIds.dailyWalk,
    displayName: 'Daily Walk',
    type: HabitType.build,
    milestoneTrackId: HabitMilestoneTracks.dailyWalk,
  ),
  PredefinedHabitOption(
    id: PredefinedHabitIds.readTwentyMinutes,
    displayName: 'Read 20 Minutes',
    type: HabitType.build,
    milestoneTrackId: HabitMilestoneTracks.readTwentyMinutes,
  ),
  PredefinedHabitOption(
    id: PredefinedHabitIds.exercise,
    displayName: 'Exercise',
    type: HabitType.build,
    milestoneTrackId: HabitMilestoneTracks.exerciseThreePerWeek,
  ),
];

PredefinedHabitOption? getPredefinedHabitOptionById(String? id) {
  if (id == null) {
    return null;
  }

  for (final option in predefinedHabitOptions) {
    if (option.id == id) {
      return option;
    }
  }

  return null;
}
