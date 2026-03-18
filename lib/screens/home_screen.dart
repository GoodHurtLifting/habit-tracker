import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';
import '../services/habit_stats_service.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Habit> habits = [];
  List<HabitLog> logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedHabits = await _databaseService.getHabits();
    final loadedLogs = await _databaseService.getHabitLogs();

    if (!mounted) {
      return;
    }

    setState(() {
      habits = loadedHabits;
      logs = loadedLogs;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabitToday(Habit habit) async {
    final DateTime today = DateTime.now();

    final bool hasLogForToday = logs.any((log) {
      return log.habitId == habit.id &&
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
    });

    if (hasLogForToday) {
      await _databaseService.deleteHabitLogByDate(habit.id, today);
      setState(() {
        logs = logs.where((log) {
          return !(log.habitId == habit.id &&
              log.date.year == today.year &&
              log.date.month == today.month &&
              log.date.day == today.day);
        }).toList();
      });
    } else {
      final newLog = HabitLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habit.id,
        date: today,
        status: habit.type == HabitType.build
            ? HabitLogStatus.success
            : HabitLogStatus.failure,
      );

      await _databaseService.insertHabitLog(newLog);
      setState(() {
        logs = [...logs, newLog];
      });
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    await _databaseService.deleteHabit(habitId);

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
      await _databaseService.insertHabit(newHabit);

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
      await _databaseService.updateHabit(updatedHabit);

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

                final int streakCount = HabitStatsService.getCurrentStreak(
                  habit,
                  logs,
                );
                final int totalCount = HabitStatsService.getTotalCount(
                  habit,
                  logs,
                );

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
