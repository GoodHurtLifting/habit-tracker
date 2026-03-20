import '../models/habit_benefit_message.dart';
import 'habit_milestone_definitions.dart';

const List<HabitBenefitMessage> habitBenefitMessages = [
  HabitBenefitMessage(
    id: 'quit_smoking_benefit_1',
    trackId: HabitMilestoneTracks.quitSmoking,
    text: 'Saving smoke-free money can add up faster than expected.',
  ),
  HabitBenefitMessage(
    id: 'quit_smoking_benefit_2',
    trackId: HabitMilestoneTracks.quitSmoking,
    text: 'Food and smells may become more noticeable over time.',
  ),
  HabitBenefitMessage(
    id: 'quit_smoking_benefit_3',
    trackId: HabitMilestoneTracks.quitSmoking,
    text: 'Each smoke-free day strengthens a new routine.',
  ),
  HabitBenefitMessage(
    id: 'quit_smoking_benefit_4',
    trackId: HabitMilestoneTracks.quitSmoking,
    text: 'Breathing may begin to feel easier as recovery continues.',
  ),
  HabitBenefitMessage(
    id: 'quit_smoking_benefit_5',
    trackId: HabitMilestoneTracks.quitSmoking,
    text: 'Cravings pass, but progress stays.',
  ),
  HabitBenefitMessage(
    id: 'daily_walk_benefit_1',
    trackId: HabitMilestoneTracks.dailyWalk,
    text: 'Short walks still count and keep the habit alive.',
  ),
  HabitBenefitMessage(
    id: 'daily_walk_benefit_2',
    trackId: HabitMilestoneTracks.dailyWalk,
    text: 'Daily movement can support mood and energy.',
  ),
  HabitBenefitMessage(
    id: 'daily_walk_benefit_3',
    trackId: HabitMilestoneTracks.dailyWalk,
    text: 'Repetition builds routine, even on low-motivation days.',
  ),
  HabitBenefitMessage(
    id: 'daily_walk_benefit_4',
    trackId: HabitMilestoneTracks.dailyWalk,
    text: 'Small walks are easier to repeat than perfect workouts.',
  ),
  HabitBenefitMessage(
    id: 'daily_walk_benefit_5',
    trackId: HabitMilestoneTracks.dailyWalk,
    text: 'A steady walking habit builds trust in yourself.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_1',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'Better sleep can return as your body stabilizes.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_2',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'Clearer thinking can make daily choices easier.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_3',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'Money not spent on cocaine can go toward real priorities.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_4',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'Recovery can help rebuild trust with people who matter.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_5',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'More steady energy can return over time.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_6',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'Each clean day creates more distance from active use.',
  ),
  HabitBenefitMessage(
    id: 'quit_cocaine_benefit_7',
    trackId: HabitMilestoneTracks.quitCocaine,
    text: 'A more stable routine can help life feel more manageable.',
  ),
];

List<HabitBenefitMessage> getBenefitsForTrack(String trackId) {
  return habitBenefitMessages
      .where((message) => message.trackId == trackId)
      .toList();
}
