import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/overview_service.dart';
import '../utils/date_formatter.dart';

class HabitDayLogSheet extends StatefulWidget {
  final DateTime selectedDate;
  final OverviewService overviewService;

  const HabitDayLogSheet({
    super.key,
    required this.selectedDate,
    required this.overviewService,
  });

  @override
  State<HabitDayLogSheet> createState() => _HabitDayLogSheetState();
}

class _HabitDayLogSheetState extends State<HabitDayLogSheet> {
  List<DayHabitLogState> _states = const [];
  bool _isLoading = true;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoading = true;
    });

    final states = await widget.overviewService.getDayLogStates(widget.selectedDate);

    if (!mounted) {
      return;
    }

    setState(() {
      _states = states;
      _isLoading = false;
    });
  }

  Future<void> _toggle(DayHabitLogState state) async {
    if (!state.canLog) {
      return;
    }

    await widget.overviewService.toggleLogForDay(
      habit: state.habit,
      date: widget.selectedDate,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _didChange = true;
      _states = _states.map((existing) {
        if (existing.habit.id != state.habit.id) {
          return existing;
        }
        return DayHabitLogState(
          habit: existing.habit,
          isLogged: !existing.isLogged,
          canLog: existing.canLog,
          isPaused: existing.isPaused,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime day = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    final bool canEditDay = widget.overviewService.canEditDate(day);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormatter.weekdayMonthDay(day),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(_didChange),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!canEditDay)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'This date is locked. You can only log days in the current week.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else if (_states.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No habits yet.'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _states.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final state = _states[index];
                    final bool isBuild = state.habit.type == HabitType.build;
                    final bool isEnabled = canEditDay && state.canLog;
                    final String actionText = state.isLogged
                        ? 'Undo'
                        : (state.canLog ? (isBuild ? 'Done' : 'Slip') : 'Paused');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(state.habit.name),
                      subtitle: Text(
                        state.isPaused
                            ? 'Paused'
                            : (isBuild ? 'Build habit' : 'Avoid habit'),
                      ),
                      trailing: TextButton(
                        onPressed: isEnabled ? () => _toggle(state) : null,
                        child: Text(actionText),
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
}
