import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Habit> habits;

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
  }

  void _toggleHabitToday(String habitId) {
    setState(() {
      habits = habits.map((habit) {
        if (habit.id == habitId) {
          return habit.copyWith(
            isMarkedToday: !habit.isMarkedToday,
          );
        }
        return habit;
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];

          return HabitCard(
            habit: habit,
            onPressed: () => _toggleHabitToday(habit.id),
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