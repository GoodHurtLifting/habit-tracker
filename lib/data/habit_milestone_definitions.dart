import '../models/habit_milestone.dart';

class HabitMilestoneTracks {
  HabitMilestoneTracks._();

  static const String quitSmoking = 'quit_smoking';
  static const String dailyWalk = 'daily_walk';
  static const String readTwentyMinutes = 'read_twenty_minutes';
  static const String quitCocaine = 'quit_cocaine';
  static const String quitDrinking = 'quit_drinking';
}

const Map<String, String> milestoneTrackLabels = {
  HabitMilestoneTracks.quitSmoking: 'Quit Smoking',
  HabitMilestoneTracks.dailyWalk: 'Daily Walk',
  HabitMilestoneTracks.readTwentyMinutes: 'Read 20 Minutes',
  HabitMilestoneTracks.quitCocaine: 'Quit Cocaine',
  HabitMilestoneTracks.quitDrinking: 'Quit Drinking',
};

const List<String> milestoneTrackOptions = [
  HabitMilestoneTracks.quitSmoking,
  HabitMilestoneTracks.dailyWalk,
  HabitMilestoneTracks.readTwentyMinutes,
  HabitMilestoneTracks.quitCocaine,
  HabitMilestoneTracks.quitDrinking,
];

String getMilestoneTrackLabel(String? trackId) {
  if (trackId == null) return 'None';
  return milestoneTrackLabels[trackId] ?? trackId;
}

const List<HabitMilestone> habitMilestones = [
  HabitMilestone(
    id: 'quit_smoking_day_0',
    trackId: HabitMilestoneTracks.quitSmoking,
    targetDays: 0,
    title: 'Be smoke-free the rest of the day',
    expectation: 'Cravings will be tough. Stay focused and avoid strong triggers.',
    benefit: 'Your body has already started recovering, including improved oxygen levels and lower carbon monoxide.',
  ),
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
    id: 'daily_walk_day_0',
    trackId: HabitMilestoneTracks.dailyWalk,
    targetDays: 0,
    title: 'First day walking',
    expectation: 'Just get out there and do it but do not over do it.',
    benefit: 'Expect a mood boost when your are done.',
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
    id: 'read_twenty_minutes_day_0',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 0,
    title: 'Read for 20 minutes today',
    expectation: 'Keep it simple: choose something easy to start and just show up.',
    benefit: 'A short reading session can help your mind slow down and focus.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_3',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 3,
    title: 'Three days of reading',
    expectation: 'You may still be testing when and where reading fits best.',
    benefit: 'Early repetition builds consistency faster than perfect sessions.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_7',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 7,
    title: 'One-week reading streak',
    expectation: 'Some days may feel distracted; finishing the 20 minutes still counts.',
    benefit: 'A full week helps turn reading into a reliable part of your day.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_14',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 14,
    title: 'Two-week reading rhythm',
    expectation: 'Busy days can disrupt your routine, so keep your plan flexible.',
    benefit: 'Two weeks of practice can support stronger focus and follow-through.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_30',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 30,
    title: 'Thirty-day reading milestone',
    expectation: 'Protect this habit on low-energy days by keeping the goal realistic.',
    benefit: 'A month of daily reading can build momentum in attention and vocabulary.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_60',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 60,
    title: 'Two months consistent',
    expectation: 'Motivation may fluctuate now, so rely on routine more than mood.',
    benefit: 'Reading can start to feel more automatic when you repeat it this often.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_90',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 90,
    title: 'Three-month reading habit',
    expectation: 'Keep removing friction so this stays sustainable in real life.',
    benefit: 'You are shifting from trying to read to seeing yourself as a reader.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_180',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 180,
    title: 'Six-month milestone',
    expectation: 'Stay consistent through travel, stress, and schedule changes.',
    benefit: 'Long-term consistency like this can anchor a calmer, more intentional routine.',
  ),
  HabitMilestone(
    id: 'read_twenty_minutes_day_365',
    trackId: HabitMilestoneTracks.readTwentyMinutes,
    targetDays: 365,
    title: 'One year of daily reading',
    expectation: 'Keep guarding the time and environment that made this possible.',
    benefit: 'A year of reading is a meaningful identity shift and lasting personal investment.',
  ),
  HabitMilestone(
    id: 'quit_cocaine_day_0',
    trackId: HabitMilestoneTracks.quitCocaine,
    targetDays: 0,
    title: 'Make it through the day',
    expectation: 'Fatigue, low mood, irritability, and strong cravings can hit early.',
    benefit: 'Getting through the first day is an important break from the cycle of use.',
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
  HabitMilestone(
    id: 'quit_drinking_day_0',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 0,
    title: 'Do not have another drink',
    expectation: 'Sleep or mood may still feel uneven today as your body adjusts.',
    benefit: 'Your body is beginning to rehydrate and recover from recent alcohol use.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_1',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 1,
    title: 'First alcohol-free day',
    expectation: 'Sleep or mood may still feel uneven today as your body adjusts.',
    benefit: 'Your body is beginning to rehydrate and recover from recent alcohol use.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_7',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 7,
    title: 'One alcohol-free week',
    expectation: 'Cravings or social routines may still pull at you this week.',
    benefit: 'Many people notice less bloating, steadier energy, and better sleep starting here.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_21',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 21,
    title: 'Three-week milestone',
    expectation: 'Stress or familiar situations can still trigger urges, so keep your plan simple.',
    benefit: 'Digestion, blood pressure, and day-to-day stability may continue improving.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_30',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 30,
    title: 'One month alcohol-free',
    expectation: 'Consistency matters more than motivation as this becomes a real routine.',
    benefit: 'Clearer thinking, better concentration, and a healthier rhythm may feel more noticeable.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_90',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 90,
    title: 'Three-month milestone',
    expectation: 'Old environments and overconfidence can still create risk, so keep guardrails in place.',
    benefit: 'Cravings may decrease and your energy may feel more consistent.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_180',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 180,
    title: 'Six-month milestone',
    expectation: 'Protect the routines and support systems that helped you get here.',
    benefit: 'Long-term recovery benefits may start to feel more real and sustainable.',
  ),
  HabitMilestone(
    id: 'quit_drinking_day_365',
    trackId: HabitMilestoneTracks.quitDrinking,
    targetDays: 365,
    title: 'One year alcohol-free',
    expectation: 'Keep reinforcing the lifestyle choices that made this progress possible.',
    benefit: 'This marks a major identity shift and meaningful long-term progress.',
  ),
];

List<HabitMilestone> getMilestonesForTrack(String trackId) {
  final milestones =
  habitMilestones.where((m) => m.trackId == trackId).toList();

  milestones.sort((a, b) => a.targetDays.compareTo(b.targetDays));
  return milestones;
}
