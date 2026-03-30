class CalendarDaySummary {
  final DateTime date;
  final List<String> goalHitHabitNames;
  final List<String> slipHabitNames;
  final List<CalendarDayActivityMarker> activityMarkers;
  final bool hasMissedOpportunity;

  const CalendarDaySummary({
    required this.date,
    required this.goalHitHabitNames,
    required this.slipHabitNames,
    this.activityMarkers = const <CalendarDayActivityMarker>[],
    this.hasMissedOpportunity = false,
  });

  bool get hasGoalHits => goalHitHabitNames.isNotEmpty;
  bool get hasSlips => slipHabitNames.isNotEmpty;
  bool get hasActivity => hasGoalHits || hasSlips;
}

enum CalendarDayActivityType {
  buildSuccess,
  avoidSuccess,
  slip,
}

class CalendarDayActivityMarker {
  final String habitId;
  final String habitName;
  final String accentColorKey;
  final CalendarDayActivityType type;

  const CalendarDayActivityMarker({
    required this.habitId,
    required this.habitName,
    required this.accentColorKey,
    required this.type,
  });

  bool get isVisibleInCalendarOverview {
    return type == CalendarDayActivityType.buildSuccess ||
        type == CalendarDayActivityType.slip;
  }
}
