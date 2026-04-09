import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/calendar_day_summary.dart';
import '../services/overview_service.dart';
import '../utils/habit_color_utils.dart';
import '../widgets/habit_day_log_sheet.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  static const int _maxVisibleActivityDots = 7;
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

  Future<void> _showDayLogSheet(DateTime day) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HabitDayLogSheet(
          selectedDate: day,
          overviewService: _overviewService,
        );
      },
    );

    if (mounted) {
      _loadMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth =
        DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final DateTime firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final int leadingBlanks = firstOfMonth.weekday - DateTime.monday;
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

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
                      _WeekdayLabel('Mon'),
                      _WeekdayLabel('Tue'),
                      _WeekdayLabel('Wed'),
                      _WeekdayLabel('Thu'),
                      _WeekdayLabel('Fri'),
                      _WeekdayLabel('Sat'),
                      _WeekdayLabel('Sun'),
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
                        childAspectRatio: 0.88,
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
                        final bool hasVisibleActivity =
                            summary?.activityMarkers.any(
                              (marker) => marker.isVisibleInCalendarOverview,
                            ) ??
                            false;
                        final bool isFutureDay = day.isAfter(todayDateOnly);
                        final bool isEditableDay = _overviewService.canEditDate(day);
                        final bool isLockedDay = !isFutureDay && !isEditableDay;

                        return InkWell(
                          onTap: !isFutureDay ? () => _showDayLogSheet(day) : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.divider),
                              borderRadius: BorderRadius.circular(8),
                              color: isFutureDay || isLockedDay
                                  ? AppTheme.metaText.withValues(alpha: 0.14)
                                  : hasVisibleActivity
                                  ? AppTheme.buildAccent.withValues(alpha: 0.14)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasVisibleActivity
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isFutureDay || isLockedDay
                                        ? AppTheme.metaText
                                        : null,
                                  ),
                                ),
                                const Spacer(),
                                if (summary != null && hasVisibleActivity)
                                  _buildActivityMarkers(summary!)
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

  Widget _buildActivityMarkers(CalendarDaySummary summary) {
    final List<CalendarDayActivityMarker> markers = summary.activityMarkers
        .where((marker) => marker.isVisibleInCalendarOverview)
        .toList();
    if (markers.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<CalendarDayActivityMarker> visibleMarkers = markers.take(
      _maxVisibleActivityDots,
    ).toList();
    final int remainingCount = markers.length - visibleMarkers.length;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 3,
      children: [
        for (final marker in visibleMarkers)
          _buildActivityDot(
            HabitColorUtils.resolveAccentColor(marker.accentColorKey),
            isSlip: marker.type == CalendarDayActivityType.slip,
          ),
        if (remainingCount > 0)
          Text(
            '+$remainingCount',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText,
            ),
          ),
      ],
    );
  }

  Widget _buildActivityDot(Color color, {required bool isSlip}) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSlip
            ? Border.all(color: AppTheme.avoidAccent, width: 1.4)
            : null,
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
            color: AppTheme.secondaryText,
          ),
        ),
      ),
    );
  }
}
