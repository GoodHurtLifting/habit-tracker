import 'package:flutter/material.dart';

import '../models/calendar_day_summary.dart';
import '../services/overview_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final OverviewService _overviewService = OverviewService();

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<DateTime, CalendarDaySummary> _daySummaries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      _isLoading = true;
    });

    final summaries = await _overviewService.getMonthSummaries(_visibleMonth);

    if (!mounted) {
      return;
    }

    setState(() {
      _daySummaries = summaries;
      _isLoading = false;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
    _loadMonth();
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
    _loadMonth();
  }

  void _showDayDetails(CalendarDaySummary summary) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${summary.date.year}-${summary.date.month.toString().padLeft(2, '0')}-${summary.date.day.toString().padLeft(2, '0')}',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summary.hasGoalHits) ...[
                  const Text(
                    'Goal hit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...summary.goalHitHabitNames.map(
                    (habitName) => Text('• $habitName'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (summary.hasSlips) ...[
                  const Text(
                    'Slip',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...summary.slipHabitNames.map((habitName) => Text('• $habitName')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth =
        DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final DateTime firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final int leadingBlanks = firstOfMonth.weekday % 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _goToPreviousMonth,
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous month',
                      ),
                      Text(
                        '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _goToNextMonth,
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next month',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _WeekdayLabel('Sun'),
                      _WeekdayLabel('Mon'),
                      _WeekdayLabel('Tue'),
                      _WeekdayLabel('Wed'),
                      _WeekdayLabel('Thu'),
                      _WeekdayLabel('Fri'),
                      _WeekdayLabel('Sat'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: GridView.builder(
                      itemCount: leadingBlanks + daysInMonth,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        if (index < leadingBlanks) {
                          return const SizedBox.shrink();
                        }

                        final int dayNumber = index - leadingBlanks + 1;
                        final DateTime day = DateTime(
                          _visibleMonth.year,
                          _visibleMonth.month,
                          dayNumber,
                        );

                        final CalendarDaySummary? summary = _daySummaries[day];
                        final bool isActive = summary?.hasActivity ?? false;

                        return InkWell(
                          onTap: isActive ? () => _showDayDetails(summary!) : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: isActive
                                  ? Colors.blue.withValues(alpha: 0.06)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                if (summary?.hasGoalHits == true ||
                                    summary?.hasSlips == true)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (summary?.hasGoalHits == true)
                                        _buildDot(Colors.blue),
                                      if (summary?.hasGoalHits == true &&
                                          summary?.hasSlips == true)
                                        const SizedBox(width: 6),
                                      if (summary?.hasSlips == true)
                                        _buildDot(Colors.orange),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _monthName(int month) {
    const List<String> names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return names[month - 1];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
