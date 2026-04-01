import 'package:shared_preferences/shared_preferences.dart';

import '../models/geo_reminder_config.dart';

class LocalPreferencesService {
  static const String _lastSeenWeeklySummaryIdKey =
      'last_seen_weekly_summary_id';

  static const String _geoReminderEnabledKey = 'geo_reminder_enabled';
  static const String _homebaseLatitudeKey = 'geo_homebase_latitude';
  static const String _homebaseLongitudeKey = 'geo_homebase_longitude';
  static const String _homebaseRadiusMetersKey = 'geo_homebase_radius_meters';
  static const String _protectedAvoidHabitIdKey = 'geo_protected_avoid_habit_id';
  static const String _followUpReminderEnabledKey = 'geo_followup_enabled';
  static const String _followUpReminderDelayMinutesKey =
      'geo_followup_delay_minutes';
  static const String _geoDebugLogKey = 'geo_debug_log';
  static const int _geoDebugLogMaxEntries = 30;

  static Future<String?> getLastSeenWeeklySummaryId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSeenWeeklySummaryIdKey);
  }

  static Future<void> setLastSeenWeeklySummaryId(String summaryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenWeeklySummaryIdKey, summaryId);
  }

  static Future<GeoReminderConfig> getGeoReminderConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return GeoReminderConfig(
      geoReminderEnabled: prefs.getBool(_geoReminderEnabledKey) ?? false,
      homebaseLatitude: prefs.getDouble(_homebaseLatitudeKey),
      homebaseLongitude: prefs.getDouble(_homebaseLongitudeKey),
      homebaseRadiusMeters: prefs.getDouble(_homebaseRadiusMetersKey) ?? 200,
      protectedAvoidHabitId: prefs.getString(_protectedAvoidHabitIdKey),
      followUpReminderEnabled:
          prefs.getBool(_followUpReminderEnabledKey) ?? true,
      followUpReminderDelayMinutes:
          prefs.getInt(_followUpReminderDelayMinutesKey) ?? 60,
    );
  }

  static Future<void> setGeoReminderConfig(GeoReminderConfig config) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_geoReminderEnabledKey, config.geoReminderEnabled);

    if (config.homebaseLatitude == null) {
      await prefs.remove(_homebaseLatitudeKey);
    } else {
      await prefs.setDouble(_homebaseLatitudeKey, config.homebaseLatitude!);
    }

    if (config.homebaseLongitude == null) {
      await prefs.remove(_homebaseLongitudeKey);
    } else {
      await prefs.setDouble(_homebaseLongitudeKey, config.homebaseLongitude!);
    }

    await prefs.setDouble(_homebaseRadiusMetersKey, config.homebaseRadiusMeters);

    final String? protectedHabitId = config.protectedAvoidHabitId?.trim();
    if (protectedHabitId == null || protectedHabitId.isEmpty) {
      await prefs.remove(_protectedAvoidHabitIdKey);
    } else {
      await prefs.setString(_protectedAvoidHabitIdKey, protectedHabitId);
    }

    await prefs.setBool(
      _followUpReminderEnabledKey,
      config.followUpReminderEnabled,
    );
    await prefs.setInt(
      _followUpReminderDelayMinutesKey,
      config.followUpReminderDelayMinutes,
    );
  }

  static Future<List<String>> getGeoDebugLog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_geoDebugLogKey) ?? <String>[];
  }

  static Future<void> appendGeoDebugLog(String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existingEntries =
        prefs.getStringList(_geoDebugLogKey) ?? <String>[];

    final String timestamp = DateTime.now().toIso8601String();
    existingEntries.add('[$timestamp] $message');

    if (existingEntries.length > _geoDebugLogMaxEntries) {
      existingEntries.removeRange(
        0,
        existingEntries.length - _geoDebugLogMaxEntries,
      );
    }

    await prefs.setStringList(_geoDebugLogKey, existingEntries);
  }

  static Future<void> clearGeoDebugLog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geoDebugLogKey);
  }
}
