import 'package:flutter/material.dart';

import '../models/habit.dart';

class HabitColorUtils {
  static const List<String> _buildPaletteKeys = <String>[
    'cool_blue',
    'cool_teal',
    'cool_indigo',
    'cool_cyan',
    'cool_blue_grey',
  ];

  static const List<String> _avoidPaletteKeys = <String>[
    'warm_orange',
    'warm_deep_orange',
    'warm_amber',
    'warm_red',
    'warm_rust',
  ];

  static String defaultAccentColorKeyForType(HabitType type) {
    return type == HabitType.avoid
        ? Habit.defaultAvoidAccentColorKey
        : Habit.defaultBuildAccentColorKey;
  }

  static String accentColorKeyForTypeIndex(HabitType type, int index) {
    final List<String> palette =
        type == HabitType.avoid ? _avoidPaletteKeys : _buildPaletteKeys;
    if (palette.isEmpty) {
      return defaultAccentColorKeyForType(type);
    }
    return palette[index % palette.length];
  }

  static String accentColorKeyForNewHabit({
    required HabitType type,
    required List<Habit> existingHabits,
  }) {
    final int familyCount =
        existingHabits.where((habit) => habit.type == type).length;
    return accentColorKeyForTypeIndex(type, familyCount);
  }

  static Color resolveAccentColor(String key) {
    switch (key) {
      case 'cool_teal':
        return const Color(0xFF26A69A);
      case 'cool_indigo':
        return const Color(0xFF5C6BC0);
      case 'cool_cyan':
        return const Color(0xFF26C6DA);
      case 'cool_blue_grey':
        return const Color(0xFF78909C);
      case 'warm_deep_orange':
        return const Color(0xFFFF7043);
      case 'warm_amber':
        return const Color(0xFFFFB74D);
      case 'warm_red':
        return const Color(0xFFEF5350);
      case 'warm_rust':
        return const Color(0xFF8D6E63);
      case 'cool_blue':
        return const Color(0xFF42A5F5);
      case 'warm_orange':
        return const Color(0xFFFFA726);
      default:
        return key.startsWith('warm_')
            ? const Color(0xFFFFA726)
            : const Color(0xFF42A5F5);
    }
  }

  static Color getAccentColorForHabit(Habit habit) {
    return resolveAccentColor(habit.accentColorKey);
  }
}
