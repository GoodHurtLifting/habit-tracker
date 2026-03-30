import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/habit.dart';
import '../models/habit_benefit_message.dart';
import '../models/habit_log.dart';
import '../models/habit_milestone.dart';
import '../models/weekly_summary.dart';
import '../services/database_service.dart';
import '../services/habit_stats_service.dart';
import '../services/local_preferences_service.dart';
import '../services/weekly_summary_service.dart';
import '../utils/date_formatter.dart';
import '../utils/habit_color_utils.dart';
import '../utils/date_rules.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'overview_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

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
  String? _lastSeenWeeklySummaryId;
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
    final String? lastSeenWeeklySummaryId =
        await LocalPreferencesService.getLastSeenWeeklySummaryId();

    if (!mounted) {
      return;
    }

    setState(() {
      habits = loadedHabits;
      logs = loadedLogs;
      _mostRecentWeeklySummary = mostRecentWeeklySummary;
      _lastSeenWeeklySummaryId = lastSeenWeeklySummaryId;
      _isLoading = false;
    });
  }

  bool get _shouldShowWeeklySummary {
    final WeeklySummary? summary = _mostRecentWeeklySummary;
    if (summary == null) {
      return false;
    }

    return summary.id != _lastSeenWeeklySummaryId;
  }

  Future<void> _dismissWeeklySummary() async {
    final WeeklySummary? summary = _mostRecentWeeklySummary;
    if (summary == null) {
      return;
    }

    await LocalPreferencesService.setLastSeenWeeklySummaryId(summary.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _lastSeenWeeklySummaryId = summary.id;
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
      final int nextSortOrder = habits
              .where((habit) => !habit.isArchived && !habit.isPaused)
              .fold<int>(
                -1,
                (currentMax, habit) =>
                    habit.sortOrder > currentMax ? habit.sortOrder : currentMax,
              ) +
          1;
      final String accentColorKey = HabitColorUtils.accentColorKeyForNewHabit(
        type: newHabit.type,
        existingHabits: habits,
      );
      final Habit habitToInsert = newHabit.copyWith(
        sortOrder: nextSortOrder,
        accentColorKey: accentColorKey,
      );
      await _databaseService.insertHabit(habitToInsert);

      if (!mounted) {
        return;
      }

      setState(() {
        habits = [...habits, habitToInsert];
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

  Future<void> _goToSettingsScreen() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
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
          color: AppTheme.secondaryText,
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
        key: ValueKey(habit.id),
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

  Future<void> _reorderHabitsInSection({
    required bool isPausedSection,
    required int oldIndex,
    required int newIndex,
  }) async {
    final List<Habit> sectionHabits = habits
        .where((habit) => !habit.isArchived && habit.isPaused == isPausedSection)
        .toList()
      ..sort((a, b) {
        final int sortCompare = a.sortOrder.compareTo(b.sortOrder);
        if (sortCompare != 0) {
          return sortCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

    if (oldIndex < 0 ||
        oldIndex >= sectionHabits.length ||
        newIndex < 0 ||
        newIndex > sectionHabits.length) {
      return;
    }

    int targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }

    final Habit movedHabit = sectionHabits.removeAt(oldIndex);
    sectionHabits.insert(targetIndex, movedHabit);

    final List<Habit> reorderedSectionHabits = sectionHabits
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(sortOrder: entry.key))
        .toList();
    final Map<String, Habit> reorderedById = {
      for (final habit in reorderedSectionHabits) habit.id: habit,
    };

    if (!mounted) {
      return;
    }

    setState(() {
      habits = habits.map((habit) {
        return reorderedById[habit.id] ?? habit;
      }).toList();
    });

    await _databaseService.updateHabitSortOrders(reorderedSectionHabits);
  }

  Widget _buildReorderableHabitSection(
    List<Habit> sectionHabits,
    Map<String, DateTime> lastLoggedDatesByHabit, {
    required bool isPausedSection,
  }) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) => _reorderHabitsInSection(
        isPausedSection: isPausedSection,
        oldIndex: oldIndex,
        newIndex: newIndex,
      ),
      children: _buildHabitCards(sectionHabits, lastLoggedDatesByHabit),
    );
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

  ({int doneToday, int buildLeft, int avoidLeft, int activeToday})
      _getLiveDailySummary() {
    final DateTime today = DateRules.normalizeDate(DateTime.now());
    int doneToday = 0;
    int buildLeft = 0;
    int avoidLeft = 0;
    int activeToday = 0;

    for (final Habit habit in habits) {
      if (habit.isArchived) {
        continue;
      }

      if (!HabitStatsService.canLogHabitForDate(habit, today)) {
        continue;
      }

      activeToday++;
      final HabitLog? todayLog = _getHabitLogForDay(habit.id, today);
      final bool isSuccess = todayLog?.status == HabitLogStatus.success;

      if (isSuccess) {
        doneToday++;
      } else if (habit.type == HabitType.build) {
        buildLeft++;
      } else {
        avoidLeft++;
      }
    }

    return (
      doneToday: doneToday,
      buildLeft: buildLeft,
      avoidLeft: avoidLeft,
      activeToday: activeToday,
    );
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
    final List<Habit> visibleHabits =
        habits.where((habit) => !habit.isArchived).toList();
    int compareHabitsBySortOrder(Habit a, Habit b) {
      final int sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    }

    final List<Habit> activeHabits =
        visibleHabits.where((habit) => !habit.isPaused).toList()
          ..sort(compareHabitsBySortOrder);
    final List<Habit> pausedHabits =
        visibleHabits.where((habit) => habit.isPaused).toList()
          ..sort(compareHabitsBySortOrder);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whatcha Doin?'),
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
          IconButton(
            onPressed: _goToSettingsScreen,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings & About',
          ),
        ],
      ),
      body: visibleHabits.isEmpty
          ? const AppEmptyState(
              title: 'No habits yet',
              subtitle: 'Add your first habit to start tracking.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 120),
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
                  _buildReorderableHabitSection(
                    activeHabits,
                    lastLoggedDatesByHabit,
                    isPausedSection: false,
                  ),
                ],
                if (pausedHabits.isNotEmpty) ...[
                  _buildSectionHeader('Paused Habits'),
                  _buildReorderableHabitSection(
                    pausedHabits,
                    lastLoggedDatesByHabit,
                    isPausedSection: true,
                  ),
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
    if (!_shouldShowWeeklySummary) {
      final liveSummary = _getLiveDailySummary();
      final DateTime today = DateRules.normalizeDate(DateTime.now());

      return Card(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatter.weekdayMonthDay(today),
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildSummaryStat('Done today', liveSummary.doneToday),
                  _buildSummaryStat('Build left', liveSummary.buildLeft),
                  _buildSummaryStat('Avoid left', liveSummary.avoidLeft),
                  _buildSummaryStat('Active today', liveSummary.activeToday),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final WeeklySummary summary = _mostRecentWeeklySummary!;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Weekly Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _dismissWeeklySummary,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  tooltip: 'Dismiss weekly summary',
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Week of ${DateFormatter.weekRange(summary.weekStartDate, summary.weekEndDate)}',
              style: TextStyle(
                color: AppTheme.secondaryText,
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
                  summary.totalGoalHits,
                  valueColor: AppTheme.buildAccent,
                ),
                _buildSummaryStat(
                  'Slips',
                  summary.totalSlips,
                  valueColor: AppTheme.avoidAccent,
                ),
                _buildSummaryStat(
                  'Logged days',
                  summary.totalLoggedDays,
                  valueColor: AppTheme.buildAccent,
                ),
                _buildSummaryStat(
                  'Habits touched',
                  summary.totalLoggedHabits,
                  valueColor: AppTheme.primaryText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    int value, {
    Color? valueColor,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.metaText.withValues(alpha: 0.14),
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
                  color: AppTheme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: '$value',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
