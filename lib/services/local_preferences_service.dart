import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  static const String _lastSeenWeeklySummaryIdKey =
      'last_seen_weekly_summary_id';

  static Future<String?> getLastSeenWeeklySummaryId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSeenWeeklySummaryIdKey);
  }

  static Future<void> setLastSeenWeeklySummaryId(String summaryId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenWeeklySummaryIdKey, summaryId);
  }
}
