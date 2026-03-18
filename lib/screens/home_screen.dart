import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import '../services/habit_stats_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Habit> habits;
  late List<HabitLog> logs;

  @override
  void initState() {
    super.initState();

    habits = [
      Habit(
        id: '1',
        name: 'Drink Water',
        description: 'Finish your daily water goal.',
        type: HabitType.build,
        createdAt: DateTime.now(),
      ),
      Habit(
        id: '2',
        name: 'Smoking',
        description: 'Avoid cigarettes for the day.',
        type: HabitType.avoid,
        createdAt: DateTime.now(),
      ),
      Habit(
        id: '3',
        name: 'Read',
        description: 'Read for at least 10 minutes.',
        type: HabitType.build,
        createdAt: DateTime.now(),
      ),
    ];

    logs = [];
  }

  void _toggleHabitToday(Habit habit) {
    final DateTime today = DateTime.now();

    final bool hasLogForToday = logs.any((log) {
      return log.habitId == habit.id &&
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
    });

    setState(() {
      if (hasLogForToday) {
        logs.removeWhere((log) {
          return log.habitId == habit.id &&
              log.date.year == today.year &&
              log.date.month == today.month &&
              log.date.day == today.day;
        });
      } else {
        logs.add(
          HabitLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            habitId: habit.id,
            date: today,
            status: habit.type == HabitType.build
                ? HabitLogStatus.success
                : HabitLogStatus.failure,
          ),
        );
      }
    });
  }

  void _deleteHabit(String habitId) {
    setState(() {
      habits = habits.where((habit) => habit.id != habitId).toList();
      logs = logs.where((log) => log.habitId != habitId).toList();
    });
  }

  Future<void> _goToAddHabitScreen() async {
    final Habit? newHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditHabitScreen(),
      ),
    );

    if (newHabit != null) {
      setState(() {
        habits = [...habits, newHabit];
      });
    }
  }

  Future<void> _goToEditHabitScreen(Habit habit) async {
    final Habit? updatedHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditHabitScreen(existingHabit: habit),
      ),
    );

    if (updatedHabit != null) {
      setState(() {
        habits = habits.map((existingHabit) {
          return existingHabit.id == updatedHabit.id
              ? updatedHabit
              : existingHabit;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: habits.isEmpty
          ? const Center(
        child: Text(
          'No habits yet.\nTap + to add your first habit.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          final DateTime today = DateTime.now();

          final bool isMarkedToday = logs.any((log) {
            return log.habitId == habit.id &&
                log.date.year == today.year &&
                log.date.month == today.month &&
                log.date.day == today.day;
          });

          final int streakCount = HabitStatsService.getCurrentStreak(habit, logs);
          final int totalCount = HabitStatsService.getTotalCount(habit, logs);

          return HabitCard(
            habit: habit,
            isMarkedToday: isMarkedToday,
            streakCount: streakCount,
            totalCount: totalCount,
            onPressed: () => _toggleHabitToday(habit),
            onDelete: () => _deleteHabit(habit.id),
            onTap: () => _goToEditHabitScreen(habit),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}