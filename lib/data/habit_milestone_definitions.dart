import '../models/habit_milestone.dart';

class HabitMilestoneTracks {
  HabitMilestoneTracks._();

  static const String quitSmoking = 'quit_smoking';
  static const String dailyWalk = 'daily_walk';
}

const Map<String, String> milestoneTrackLabels = {
  HabitMilestoneTracks.quitSmoking: 'Quit Smoking',
  HabitMilestoneTracks.dailyWalk: 'Daily Walk',
};

const List<String> milestoneTrackOptions = [
  HabitMilestoneTracks.quitSmoking,
  HabitMilestoneTracks.dailyWalk,
];

String getMilestoneTrackLabel(String? trackId) {
  if (trackId == null) return 'None';
  return milestoneTrackLabels[trackId] ?? trackId;
}

const List<HabitMilestone> habitMilestones = [
  HabitMilestone(
    id: 'quit_smoking_day_1',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 1,
    title: 'First smoke-free day',
    expectation: 'Cravings can come in waves. Keep your day simple and steady.',
    benefit: 'A full day without smoking is a strong first win.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_3',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 3,
    title: 'Three-day momentum',
    expectation: 'Mood and energy may still shift. Plan short distractions.',
    benefit: 'You are proving to yourself that this change is possible.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_7',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 7,
    title: 'One smoke-free week',
    expectation: 'Triggers may still appear, especially during routines.',
    benefit: 'A full week builds confidence and a new daily rhythm.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_14',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 14,
    title: 'Two-week milestone',
    expectation: 'Some days feel easier than others, and that is normal.',
    benefit: 'Two weeks shows consistent progress through ups and downs.',
  ),
  HabitMilestone(
    id: 'daily_walk_day_3',
    trackId: HabitMilestoneTracks.dailyWalk,
    targetDays: 3,
    title: 'Three walking days',
    expectation: 'You may still be finding the best time of day to walk.',
    benefit: 'Early consistency helps turn walking into a routine.',
  ),
  HabitMilestone(
    id: 'daily_walk_day_7',
    trackId: HabitMilestoneTracks.dailyWalk,
    targetDays: 7,
    title: 'One-week walking streak',
    expectation: 'Some walks may be short; the habit matters most.',
    benefit: 'A week of movement can support mood and daily energy.',
  ),
  HabitMilestone(
    id: 'daily_walk_day_14',
    trackId: HabitMilestoneTracks.dailyWalk,
    targetDays: 14,
    title: 'Two-week walking streak',
    expectation: 'Weather or schedule changes may challenge your plan.',
    benefit: 'Two weeks strengthens your commitment to daily movement.',
  ),
  HabitMilestone(
    id: 'daily_walk_day_30',
    trackId: HabitMilestoneTracks.dailyWalk,
    targetDays: 30,
    title: 'Thirty-day walking milestone',
    expectation: 'Keep the goal realistic so it stays sustainable.',
    benefit: 'A month of walking is a meaningful long-term foundation.',
  ),
];

List<HabitMilestone> getMilestonesForTrack(String trackId) {
  final milestones =
  habitMilestones.where((m) => m.trackId == trackId).toList();

  milestones.sort((a, b) => a.targetDays.compareTo(b.targetDays));
  return milestones;
}