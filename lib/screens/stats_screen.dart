import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/database_service.dart';
import '../services/habit_stats_service.dart';
import '../utils/date_formatter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  bool _isLoading = true;
  List<HabitStatSummary> _summaries = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final List<Habit> habits = await _databaseService.getHabits();
    final logs = await _databaseService.getHabitLogs();

    if (!mounted) {
      return;
    }

    setState(() {
      _summaries = HabitStatsService.getAllHabitStatSummaries(habits, logs);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summaries.isEmpty
              ? const Center(
                  child: Text(
                    'No habits yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _summaries.length,
                  itemBuilder: (context, index) {
                    final HabitStatSummary summary = _summaries[index];
                    return _StatsCard(summary: summary);
                  },
                ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final HabitStatSummary summary;

  const _StatsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final Habit habit = summary.habit;
    final bool isWeeklyBuild = HabitStatsService.isWeeklyBuildHabit(habit);
    final String lastLoggedText = summary.lastLoggedDate == null
        ? 'Not yet'
        : DateFormatter.weekdayMonthDay(summary.lastLoggedDate!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (summary.isPaused)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Paused',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  )
                else
                  Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isWeeklyBuild
                  ? 'Current streak: ${summary.currentStreak} weeks meeting goal'
                  : 'Current streak: ${summary.currentStreak} days',
            ),
            Text(
              isWeeklyBuild
                  ? 'Best streak: ${summary.bestStreak} weeks meeting goal'
                  : 'Best streak: ${summary.bestStreak} days',
            ),
            Text('Total logged days: ${summary.totalLoggedDays}'),
            Text('Last logged: $lastLoggedText'),
            Text(
              habit.type == HabitType.build
                  ? 'Total completions: ${summary.totalCompletions}'
                  : 'Total slips: ${summary.totalSlips}',
            ),
          ],
        ),
      ),
    );
  }
}
