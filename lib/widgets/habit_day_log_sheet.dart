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
                    final String actionText = state.isLogged
                        ? 'Undo'
                        : (isBuild ? 'Done' : 'Slip');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(state.habit.name),
                      subtitle: Text(isBuild ? 'Build habit' : 'Avoid habit'),
                      trailing: TextButton(
                        onPressed: () => _toggle(state),
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
