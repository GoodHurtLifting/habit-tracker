import 'package:flutter/material.dart';

import '../models/geo_reminder_config.dart';
import '../models/habit.dart';
import '../services/database_service.dart';
import '../services/geo_reminder_service.dart';
import '../services/local_preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final GeoReminderService _geoReminderService = GeoReminderService.instance;

  GeoReminderConfig _config = const GeoReminderConfig.defaults();
  List<Habit> _avoidHabits = const [];
  bool _isLoading = true;

  static const List<double> _radiusOptions = [100, 200, 300];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();
    final List<Habit> habits = await _databaseService.getHabits();

    if (!mounted) {
      return;
    }

    setState(() {
      _config = config;
      _avoidHabits = habits
          .where((habit) => habit.type == HabitType.avoid && !habit.isArchived)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _updateConfig(GeoReminderConfig newConfig) async {
    setState(() {
      _config = newConfig;
    });

    await LocalPreferencesService.setGeoReminderConfig(newConfig);
    await _geoReminderService.requestNotificationPermission();
    await _geoReminderService.refreshMonitoringFromPreferences();
  }

  Future<void> _setHomebaseFromCurrentLocation() async {
    final position = await _geoReminderService.captureCurrentLocationForHomebase();
    if (position == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not capture location. Check device location settings and permissions.',
          ),
        ),
      );
      return;
    }

    await _updateConfig(
      _config.copyWith(
        homebaseLatitude: position.latitude,
        homebaseLongitude: position.longitude,
      ),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Homebase updated from current location.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Logging rules'),
                  const _RuleText('• Weeks run Monday through Sunday.'),
                  const _RuleText('• You can log for the current week only.'),
                  const _RuleText(
                    '• The previous week locks at midnight between Sunday and Monday.',
                  ),
                  const _RuleText(
                    '• Weekly summaries appear the first time you open the app on Monday.',
                  ),
                  const _RuleText('• Future dates cannot be logged.'),
                  const SizedBox(height: 16),
                  const _SectionTitle('Avoid-habit geo reminder'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable geo reminder'),
                    subtitle: const Text(
                      'Uses OS geofence exit detection: one reminder on homebase exit and one follow-up later.',
                    ),
                    value: _config.geoReminderEnabled,
                    onChanged: (value) {
                      _updateConfig(_config.copyWith(geoReminderEnabled: value));
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _config.protectedAvoidHabitId,
                    decoration: const InputDecoration(
                      labelText: 'Protected avoid habit',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Select an avoid habit'),
                      ),
                      ..._avoidHabits.map(
                        (habit) => DropdownMenuItem<String?>(
                          value: habit.id,
                          child: Text(habit.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _updateConfig(_config.copyWith(protectedAvoidHabitId: value));
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _setHomebaseFromCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Set homebase from current location'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _config.homebaseLatitude == null ||
                            _config.homebaseLongitude == null
                        ? 'Homebase: not set'
                        : 'Homebase: ${_config.homebaseLatitude!.toStringAsFixed(5)}, ${_config.homebaseLongitude!.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    initialValue: _config.homebaseRadiusMeters,
                    decoration: const InputDecoration(
                      labelText: 'Homebase radius',
                      border: OutlineInputBorder(),
                    ),
                    items: _radiusOptions
                        .map(
                          (radius) => DropdownMenuItem<double>(
                            value: radius,
                            child: Text('${radius.toStringAsFixed(0)} meters'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      _updateConfig(_config.copyWith(homebaseRadiusMeters: value));
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Follow-up reminder'),
                    subtitle: Text(
                      'Send one follow-up after ${_config.followUpReminderDelayMinutes} minutes.',
                    ),
                    value: _config.followUpReminderEnabled,
                    onChanged: (value) {
                      _updateConfig(
                        _config.copyWith(
                          followUpReminderEnabled: value,
                          followUpReminderDelayMinutes: 60,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const _RuleText(
                    'Background location/notification delivery can vary by OS power settings.',
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Habit rules'),
                  const _RuleText('• Build habits count only when logged.'),
                  const _RuleText('• Avoid habits count as clean only when logged.'),
                  const _RuleText('• Missing a past avoid day counts as a slip.'),
                  const _RuleText(
                    '• Paused habits do not count against your streaks.',
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('About'),
                  const _RuleText('Habit Tracker'),
                  const _RuleText('Version: TBD'),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RuleText extends StatelessWidget {
  final String text;

  const _RuleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text),
    );
  }
}
