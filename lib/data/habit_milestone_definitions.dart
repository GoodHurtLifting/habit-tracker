import '../models/habit_milestone.dart';

class HabitMilestoneTracks {
  HabitMilestoneTracks._();

  static const String quitSmoking = 'quit_smoking';
  static const String dailyWalk = 'daily_walk';
  static const String quitCocaine = 'quit_cocaine';
}

const Map<String, String> milestoneTrackLabels = {
  HabitMilestoneTracks.quitSmoking: 'Quit Smoking',
  HabitMilestoneTracks.dailyWalk: 'Daily Walk',
  HabitMilestoneTracks.quitCocaine: 'Quit Cocaine',
};

const List<String> milestoneTrackOptions = [
  HabitMilestoneTracks.quitSmoking,
  HabitMilestoneTracks.dailyWalk,
  HabitMilestoneTracks.quitCocaine,
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
    expectation: 'Cravings may come in waves today. Keep the day simple and avoid strong triggers.',
    benefit: 'Your body has already started recovering, including improved oxygen levels and lower carbon monoxide.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_2',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 2,
    title: 'Day 2 push',
    expectation: 'Irritability, cravings, and headaches may feel stronger around this point.',
    benefit: 'Nicotine is being cleared from your body, and your senses may begin to sharpen.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_3',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 3,
    title: 'Day 3 breakthrough',
    expectation: 'This can be one of the hardest stretches mentally, so lean on simple routines and distractions.',
    benefit: 'Breathing may begin to feel easier as your body continues adjusting.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_7',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 7,
    title: 'One smoke-free week',
    expectation: 'Triggers tied to meals, stress, or routines may still hit unexpectedly.',
    benefit: 'You are building separation from the old pattern and strengthening a new routine.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_14',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 14,
    title: 'Two-week milestone',
    expectation: 'Physical withdrawal may ease, but mental habits can still pull at you.',
    benefit: 'Your circulation and lung function may already be improving.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_30',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 30,
    title: 'One month smoke-free',
    expectation: 'The challenge now is often staying consistent when motivation dips.',
    benefit: 'Many people notice easier breathing, less coughing, and a stronger sense of momentum.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_90',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 90,
    title: 'Three-month milestone',
    expectation: 'At this stage, overconfidence or old situations can still create risk.',
    benefit: 'Circulation and lung function may be meaningfully better than when you started.',
  ),
  HabitMilestone(
    id: 'quit_smoking_day_365',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 365,
    title: 'One year smoke-free',
    expectation: 'Protect the habits that got you here so this becomes your new normal.',
    benefit: 'You have built a major long-term health and identity shift over the past year.',
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
  HabitMilestone(
    id: 'quit_cocaine_day_1',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 1,
    title: 'Initial crash phase',
    expectation: 'Fatigue, low mood, irritability, and strong cravings can hit early.',
    benefit: 'Getting through the first day is an important break from the cycle of use.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_4',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 4,
    title: 'Early withdrawal',
    expectation: 'Cravings may intensify, and sleep, appetite, and mood can still feel unstable.',
    benefit: 'Your body is continuing to adjust without cocaine.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_7',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 7,
    title: 'One week clear',
    expectation: 'This stretch can still feel mentally rough, even if the first crash has passed.',
    benefit: 'Many people begin noticing better sleep, appetite, or steadier energy around this stage.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_14',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 14,
    title: 'Peak withdrawal window',
    expectation: 'Cravings, anxiety, irritability, and low mood may still feel intense.',
    benefit: 'You are moving through one of the hardest early phases of recovery.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_30',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 30,
    title: 'One month milestone',
    expectation: 'Emotional ups and downs can still show up, especially under stress.',
    benefit: 'Clearer thinking, better routines, and improved stability may start to feel more real.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_90',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 90,
    title: 'Three months strong',
    expectation: 'Cravings can still appear unexpectedly, so structure and support still matter.',
    benefit: 'This is meaningful long-term momentum and a strong foundation for recovery.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_180',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 180,
    title: 'Six-month milestone',
    expectation: 'Some psychological symptoms may linger, but they often become easier to manage over time.',
    benefit: 'You have built real distance from active use and strengthened a new direction.',
  ),
];

List<HabitMilestone> getMilestonesForTrack(String trackId) {
  final milestones =
  habitMilestones.where((m) => m.trackId == trackId).toList();

  milestones.sort((a, b) => a.targetDays.compareTo(b.targetDays));
  return milestones;
}