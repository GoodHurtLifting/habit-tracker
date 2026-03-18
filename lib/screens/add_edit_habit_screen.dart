import 'package:flutter/material.dart';
import '../models/habit.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? existingHabit;

  const AddEditHabitScreen({super.key, this.existingHabit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  HabitType _selectedType = HabitType.build;
  bool get _isEditMode => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();

    final existingHabit = widget.existingHabit;
    if (existingHabit != null) {
      _nameController.text = existingHabit.name;
      _descriptionController.text = existingHabit.description ?? '';
      _selectedType = existingHabit.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name.')),
      );
      return;
    }

    final Habit savedHabit = Habit(
      id:
          widget.existingHabit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description.isEmpty ? null : description,
      type: _selectedType,
      createdAt: widget.existingHabit?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, savedHabit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Habit' : 'Add Habit')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Habit Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: HabitType.build, child: Text('Build')),
                DropdownMenuItem(value: HabitType.avoid, child: Text('Avoid')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
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
