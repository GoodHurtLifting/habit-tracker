import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/habit_milestone_definitions.dart';
import '../data/predefined_habit_options.dart';
import '../models/habit.dart';
import '../utils/habit_color_utils.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? existingHabit;

  const AddEditHabitScreen({super.key, this.existingHabit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trigger1Controller = TextEditingController();
  final TextEditingController _trigger2Controller = TextEditingController();
  final TextEditingController _trigger3Controller = TextEditingController();
  final TextEditingController _motivation1Controller = TextEditingController();
  final TextEditingController _motivation2Controller = TextEditingController();
  final TextEditingController _motivation3Controller = TextEditingController();

  HabitType _selectedType = HabitType.build;
  String? _selectedMilestoneTrackId;
  String? _selectedPredefinedHabitId;
  bool get _isEditMode => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();

    final existingHabit = widget.existingHabit;
    if (existingHabit != null) {
      _nameController.text = existingHabit.name;
      _descriptionController.text = existingHabit.description ?? '';
      _selectedType = existingHabit.type;
      _selectedMilestoneTrackId = existingHabit.milestoneTrackId;
      _trigger1Controller.text = existingHabit.trigger1 ?? '';
      _trigger2Controller.text = existingHabit.trigger2 ?? '';
      _trigger3Controller.text = existingHabit.trigger3 ?? '';
      _motivation1Controller.text = existingHabit.motivation1 ?? '';
      _motivation2Controller.text = existingHabit.motivation2 ?? '';
      _motivation3Controller.text = existingHabit.motivation3 ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _trigger1Controller.dispose();
    _trigger2Controller.dispose();
    _trigger3Controller.dispose();
    _motivation1Controller.dispose();
    _motivation2Controller.dispose();
    _motivation3Controller.dispose();
    super.dispose();
  }

  HabitType get _currentType {
    if (_isEditMode) {
      return _selectedType;
    }

    final selectedOption = getPredefinedHabitOptionById(_selectedPredefinedHabitId);
    return selectedOption?.type ?? HabitType.build;
  }

  String? _normalizedOptional(TextEditingController controller) {
    final String value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _saveHabit() {
    final String description = _descriptionController.text.trim();
    final bool shouldSaveAvoidQuestionnaire = _currentType == HabitType.avoid;

    String name = _nameController.text.trim();

    if (_isEditMode) {
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a habit name.')),
        );
        return;
      }
    } else {
      final selectedOption = getPredefinedHabitOptionById(
        _selectedPredefinedHabitId,
      );

      if (selectedOption == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a habit.')),
        );
        return;
      }

      name = selectedOption.displayName;
      _selectedType = selectedOption.type;
      _selectedMilestoneTrackId = selectedOption.milestoneTrackId;
    }

    final Habit savedHabit = Habit(
      id:
          widget.existingHabit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description.isEmpty ? null : description,
      type: _selectedType,
      createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
      milestoneTrackId: _selectedMilestoneTrackId,
      isPaused: widget.existingHabit?.isPaused ?? false,
      pausedAt: widget.existingHabit?.pausedAt,
      resumedAt: widget.existingHabit?.resumedAt,
      isArchived: widget.existingHabit?.isArchived ?? false,
      archivedAt: widget.existingHabit?.archivedAt,
      sortOrder: widget.existingHabit?.sortOrder ?? 0,
      accentColorKey: widget.existingHabit?.accentColorKey ??
          HabitColorUtils.defaultAccentColorKeyForType(_selectedType),
      trigger1: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_trigger1Controller)
          : widget.existingHabit?.trigger1,
      trigger2: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_trigger2Controller)
          : widget.existingHabit?.trigger2,
      trigger3: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_trigger3Controller)
          : widget.existingHabit?.trigger3,
      motivation1: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_motivation1Controller)
          : widget.existingHabit?.motivation1,
      motivation2: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_motivation2Controller)
          : widget.existingHabit?.motivation2,
      motivation3: shouldSaveAvoidQuestionnaire
          ? _normalizedOptional(_motivation3Controller)
          : widget.existingHabit?.motivation3,
    );

    Navigator.pop(context, savedHabit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Habit' : 'Add Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isEditMode) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Habit Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: HabitType.build,
                    child: Text('Build'),
                  ),
                  DropdownMenuItem(
                    value: HabitType.avoid,
                    child: Text('Avoid'),
                  ),
                ],
                onChanged: null,
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Habit type cannot be changed after creation.',
                  style: TextStyle(fontSize: 12, color: AppTheme.metaText),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedMilestoneTrackId,
                decoration: const InputDecoration(
                  labelText: 'Milestone Track',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...milestoneTrackOptions.map(
                    (trackId) => DropdownMenuItem<String?>(
                      value: trackId,
                      child: Text(getMilestoneTrackLabel(trackId)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMilestoneTrackId = value;
                  });
                },
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedPredefinedHabitId,
                decoration: const InputDecoration(
                  labelText: 'Choose a habit',
                  border: OutlineInputBorder(),
                ),
                items: predefinedHabitOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPredefinedHabitId = value;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (_currentType == HabitType.avoid) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Triggers',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What situations, people, places, or feelings tend to pull you toward this?',
                  style: TextStyle(fontSize: 12, color: AppTheme.metaText),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _trigger1Controller,
                decoration: const InputDecoration(
                  labelText: 'Trigger 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _trigger2Controller,
                decoration: const InputDecoration(
                  labelText: 'Trigger 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _trigger3Controller,
                decoration: const InputDecoration(
                  labelText: 'Trigger 3',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Motivation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What are the biggest reasons you want to stop?',
                  style: TextStyle(fontSize: 12, color: AppTheme.metaText),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motivation1Controller,
                decoration: const InputDecoration(
                  labelText: 'Motivation 1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motivation2Controller,
                decoration: const InputDecoration(
                  labelText: 'Motivation 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _motivation3Controller,
                decoration: const InputDecoration(
                  labelText: 'Motivation 3',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                child: Text(_isEditMode ? 'Save Changes' : 'Save Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
