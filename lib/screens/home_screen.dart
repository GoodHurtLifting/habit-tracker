import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit_log.dart';
import '../models/habit_milestone.dart';
import '../models/weekly_summary.dart';
import '../services/database_service.dart';
import '../services/habit_stats_service.dart';
import '../services/weekly_summary_service.dart';
import '../utils/date_formatter.dart';
import '../utils/date_rules.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'overview_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final WeeklySummaryService _weeklySummaryService = WeeklySummaryService();

  List<Habit> habits = [];
  List<HabitLog> logs = [];
  WeeklySummary? _mostRecentWeeklySummary;
  bool _isLoading = true;
  final Set<String> _expandedHabitIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _weeklySummaryService.ensureWeeklySummariesUpToDate();
    final loadedHabits = await _databaseService.getHabits();
    final loadedLogs = await _databaseService.getHabitLogs();
    final mostRecentWeeklySummary =
        await _weeklySummaryService.getMostRecentWeeklySummary();

    if (!mounted) {
      return;
    }

    setState(() {
      habits = loadedHabits;
      logs = loadedLogs;
      _mostRecentWeeklySummary = mostRecentWeeklySummary;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabitToday(Habit habit) async {
    if (!HabitStatsService.canLogHabitForDate(habit, DateTime.now())) {
      return;
    }

    final DateTime today = DateRules.normalizeDate(DateTime.now());
    final DateTime weekStart = DateRules.startOfWeekMonday(today);
    final bool isWeekLocked = await _weeklySummaryService.isWeekLocked(weekStart);

    if (!DateRules.canEditDate(today) || isWeekLocked) {
      return;
    }

    final HabitLog? todayLog = _getHabitLogForDay(habit.id, today);

    final bool shouldUndo = habit.type == HabitType.build
        ? todayLog != null
        : todayLog?.status == HabitLogStatus.success;

    if (shouldUndo) {
      await _databaseService.deleteHabitLogByDate(habit.id, today);

      if (!mounted) {
        return;
      }

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
        status: HabitLogStatus.success,
      );

      await _databaseService.upsertHabitLogForDate(
        habitId: habit.id,
        date: today,
        status: HabitLogStatus.success,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        logs = [
          ...logs.where((log) {
            return !(log.habitId == habit.id &&
                log.date.year == today.year &&
                log.date.month == today.month &&
                log.date.day == today.day);
          }),
          newLog,
        ];
      });
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    await _databaseService.deleteHabit(habitId);

    if (!mounted) {
      return;
    }

    setState(() {
      habits = habits.where((habit) => habit.id != habitId).toList();
      logs = logs.where((log) => log.habitId != habitId).toList();
      _expandedHabitIds.remove(habitId);
    });
  }

  Future<void> _showDeleteConfirmation(Habit habit) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content: const Text(
            'Deleting this habit permanently removes it and its tracking history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteHabit(habit.id);
    }
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

      if (!mounted) {
        return;
      }

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

      if (!mounted) {
        return;
      }

      setState(() {
        habits = habits.map((existingHabit) {
          return existingHabit.id == updatedHabit.id
              ? updatedHabit
              : existingHabit;
        }).toList();
      });
    }
  }

  Future<void> _goToOverviewScreen() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const OverviewScreen(),
      ),
    );
    await _loadData();
  }

  Future<void> _goToStatsScreen() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const StatsScreen(),
      ),
    );
  }

  Future<void> _pauseHabit(Habit habit) async {
    await _databaseService.pauseHabit(habit.id, DateTime.now());

    if (!mounted) {
      return;
    }

    setState(() {
      habits = habits.map((existingHabit) {
        if (existingHabit.id != habit.id) {
          return existingHabit;
        }
        return existingHabit.copyWith(
          isPaused: true,
          pausedAt: DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> _resumeHabit(Habit habit) async {
    await _databaseService.resumeHabit(habit.id, DateTime.now());

    if (!mounted) {
      return;
    }

    setState(() {
      habits = habits.map((existingHabit) {
        if (existingHabit.id != habit.id) {
          return existingHabit;
        }
        return existingHabit.copyWith(
          isPaused: false,
          resumedAt: DateTime.now(),
        );
      }).toList();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  List<Widget> _buildHabitCards(
    List<Habit> sectionHabits,
    Map<String, DateTime> lastLoggedDatesByHabit,
  ) {
    return sectionHabits.map((habit) {
      final DateTime today = DateTime.now();
      final bool canLogToday = HabitStatsService.canLogHabitForDate(habit, today);

      final HabitLog? todayLog = _getHabitLogForDay(habit.id, today);

      final HabitLogStatus? todayLogStatus = todayLog?.status;

      final int streakCount = HabitStatsService.getCurrentStreak(
        habit,
        logs,
      );
      final int totalCount = HabitStatsService.getTotalCount(
        habit,
        logs,
      );
      final nextMilestoneProgress = HabitStatsService.getNextMilestoneProgress(
        habit,
        streakCount,
      );
      final HabitMilestone? currentMilestone = HabitStatsService.getCurrentMilestone(
        habit,
        streakCount,
      );
      final HabitBenefitMessage? dailyBenefitMessage =
          HabitStatsService.getDailyBenefitMessage(
        habit,
        streakCount,
      );

      return HabitCard(
        habit: habit,
        todayLogStatus: todayLogStatus,
        streakCount: streakCount,
        totalCount: totalCount,
        currentMilestone: currentMilestone,
        nextMilestone: nextMilestoneProgress?.milestone,
        milestoneDaysRemaining: nextMilestoneProgress?.daysRemaining,
        dailyBenefitMessage: dailyBenefitMessage,
        lastLoggedDate: lastLoggedDatesByHabit[habit.id],
        isExpanded: _expandedHabitIds.contains(habit.id),
        canLogToday: canLogToday,
        onPressed: () => _toggleHabitToday(habit),
        onEdit: () => _goToEditHabitScreen(habit),
        onPauseResume: () => habit.isPaused ? _resumeHabit(habit) : _pauseHabit(habit),
        onDelete: () => _showDeleteConfirmation(habit),
        onToggleExpanded: () {
          setState(() {
            if (_expandedHabitIds.contains(habit.id)) {
              _expandedHabitIds.remove(habit.id);
            } else {
              _expandedHabitIds.add(habit.id);
            }
          });
        },
      );
    }).toList();
  }

  HabitLog? _getHabitLogForDay(String habitId, DateTime date) {
    for (final HabitLog log in logs) {
      if (log.habitId == habitId &&
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day) {
        return log;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Habit Tracker'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final Map<String, DateTime> lastLoggedDatesByHabit =
        HabitStatsService.getLastLoggedDatesByHabit(logs);
    final List<Habit> activeHabits = habits.where((habit) => !habit.isPaused).toList();
    final List<Habit> pausedHabits = habits.where((habit) => habit.isPaused).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            onPressed: _goToStatsScreen,
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Stats',
          ),
          IconButton(
            onPressed: _goToOverviewScreen,
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Overview calendar',
          ),
        ],
      ),
      body: habits.isEmpty
          ? const AppEmptyState(
              title: 'No habits yet',
              subtitle: 'Add your first habit to start tracking.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _buildWeeklySummarySection(),
                if (activeHabits.isEmpty && pausedHabits.isNotEmpty)
                  const AppEmptyState(
                    title: 'All habits are paused',
                    subtitle: 'Resume a habit to continue tracking.',
                    compact: true,
                  ),
                if (activeHabits.isNotEmpty) ...[
                  _buildSectionHeader('Active Habits'),
                  ..._buildHabitCards(activeHabits, lastLoggedDatesByHabit),
                ],
                if (pausedHabits.isNotEmpty) ...[
                  _buildSectionHeader('Paused Habits'),
                  ..._buildHabitCards(pausedHabits, lastLoggedDatesByHabit),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddHabitScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeeklySummarySection() {
    if (_mostRecentWeeklySummary == null) {
      return Card(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: AppEmptyState(
            title: 'No weekly summary yet',
            subtitle: 'Complete a week to see your progress.',
            compact: true,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Week of ${DateFormatter.weekRange(_mostRecentWeeklySummary!.weekStartDate, _mostRecentWeeklySummary!.weekEndDate)}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSummaryStat(
                  'Goal hits',
                  _mostRecentWeeklySummary!.totalGoalHits,
                ),
                _buildSummaryStat(
                  'Slips',
                  _mostRecentWeeklySummary!.totalSlips,
                ),
                _buildSummaryStat(
                  'Logged days',
                  _mostRecentWeeklySummary!.totalLoggedDays,
                ),
                _buildSummaryStat(
                  'Habits touched',
                  _mostRecentWeeklySummary!.totalLoggedHabits,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, int value) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
