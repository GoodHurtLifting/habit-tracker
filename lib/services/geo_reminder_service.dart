import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/geo_reminder_config.dart';
import '../models/habit.dart';
import 'database_service.dart';
import 'local_preferences_service.dart';

@pragma('vm:entry-point')
Future<void> geoReminderGeofenceTriggered(GeofenceCallbackParams params) async {
  await GeoReminderService.instance.handleGeofenceCallback(params);
}
@pragma('vm:entry-point')
class GeoReminderService {
  GeoReminderService._();

  static final GeoReminderService instance = GeoReminderService._();

  static const String _notificationChannelId = 'geo_avoid_habit_reminder';
  static const int _immediateNotificationId = 711001;
  static const int _followUpNotificationId = 711002;
  static const String _homebaseGeofenceId = 'geo_homebase_exit';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _notificationsInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _ensureNotificationsInitialized();
    await NativeGeofenceManager.instance.initialize();

    _isInitialized = true;

    await refreshMonitoringFromPreferences();
  }

  Future<void> refreshMonitoringFromPreferences() async {
    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();

    await _debugLog('Geo config loaded: '
        'enabled=${config.geoReminderEnabled}, '
        'lat=${config.homebaseLatitude}, '
        'lng=${config.homebaseLongitude}, '
        'radius=${config.homebaseRadiusMeters}, '
        'habit=${config.protectedAvoidHabitId}, '
        'complete=${config.isCompleteForMonitoring}');

    if (!config.isCompleteForMonitoring) {
      await _debugLog('Geo monitoring not started: config incomplete');
      await unregisterHomebaseMonitoring();
      return;
    }

    final Habit? habit = await DatabaseService.instance.getHabitById(
      config.protectedAvoidHabitId!,
    );

    if (habit == null || habit.type != HabitType.avoid || habit.isArchived) {
      await _debugLog('Geo monitoring not started: selected habit invalid '
          '(habitNull=${habit == null}, '
          'isAvoid=${habit?.type == HabitType.avoid}, '
          'isArchived=${habit?.isArchived})');
      await unregisterHomebaseMonitoring();
      return;
    }

    final bool hasPermission = await _ensureLocationPermissionForGeofence();
    if (!hasPermission) {
      await _debugLog(
        'Geo monitoring not started: background location permission not granted',
      );
      await unregisterHomebaseMonitoring();
      return;
    }

    try {
      await _debugLog('Geofence registration started');
      await NativeGeofenceManager.instance.removeGeofenceById(_homebaseGeofenceId);

      await _debugLog('Registering geofence: '
          'id=$_homebaseGeofenceId, '
          'lat=${config.homebaseLatitude}, '
          'lng=${config.homebaseLongitude}, '
          'radius=${config.homebaseRadiusMeters}');

      await NativeGeofenceManager.instance.createGeofence(
        Geofence(
          id: _homebaseGeofenceId,
          location: Location(
            latitude: config.homebaseLatitude!,
            longitude: config.homebaseLongitude!,
          ),
          radiusMeters: config.homebaseRadiusMeters,
          triggers: const {GeofenceEvent.enter, GeofenceEvent.exit},
          iosSettings: const IosGeofenceSettings(
            initialTrigger: false,
          ),
          androidSettings: const AndroidGeofenceSettings(
            initialTriggers: {GeofenceEvent.enter},
            expiration: Duration(days: 7),
            loiteringDelay: Duration.zero,
            notificationResponsiveness: Duration(minutes: 1),
          ),
        ),
        geoReminderGeofenceTriggered,
      );

      final List<ActiveGeofence> registeredGeofences =
          await NativeGeofenceManager.instance.getRegisteredGeofences();

      await _debugLog('Geofence registration succeeded. '
          'Registered geofences count=${registeredGeofences.length}');
      for (final geofence in registeredGeofences) {
        await _debugLog('Registered geofence id=${geofence.id}');
      }
    } on NativeGeofenceException catch (e) {
      await _debugLog('Geofence registration failed: '
          'code=${e.code}, message=${e.message}');
      await unregisterHomebaseMonitoring();
    } catch (e, stackTrace) {
      await _debugLog('Unexpected geofence registration error: $e');
      print(stackTrace);
      await unregisterHomebaseMonitoring();
    }
  }

  Future<void> unregisterHomebaseMonitoring() async {
    await NativeGeofenceManager.instance.removeGeofenceById(_homebaseGeofenceId);
    await _notifications.cancel(_followUpNotificationId);
    await _debugLog('Monitoring unregistered');
  }

  Future<Position?> captureCurrentLocationForHomebase() async {
    final bool hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      return null;
    }

    final bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> requestNotificationPermission() async {
    await _ensureNotificationsInitialized();

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> sendTestNotification() async {
    await _ensureNotificationsInitialized();
    await requestNotificationPermission();

    await _notifications.show(
      _immediateNotificationId,
      'Geo test notification',
      'If you see this, local notifications are working.',
      _defaultNotificationDetails(),
    );

    await _debugLog('Manual test notification sent');
  }

  Future<bool> _ensureLocationPermissionForGeofence() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _debugLog('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    await _debugLog('Initial location permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      await _debugLog('Location permission after request: $permission');
    }

    if (permission != LocationPermission.always) {
      permission = await Geolocator.requestPermission();
      await _debugLog(
        'Location permission after always-request attempt: $permission',
      );
    }

    final bool granted = permission == LocationPermission.always;
    await _debugLog('Background geofence permission granted=$granted');

    return granted;
  }

  Future<bool> _ensureLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_notificationsInitialized) {
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _notificationsInitialized = true;
  }

  Future<void> handleGeofenceCallback(GeofenceCallbackParams params) async {
    await _ensureNotificationsInitialized();

    await _debugLog('Geofence callback fired: '
        'event=${params.event}, geofenceCount=${params.geofences.length}');

    if (params.event == GeofenceEvent.enter) {
      await _debugLog('Homebase enter event confirmed');
      return;
    }

    if (params.event != GeofenceEvent.exit) {
      return;
    }

    final bool isOurHomebaseEvent = params.geofences.any(
      (geofence) => geofence.id == _homebaseGeofenceId,
    );
    if (!isOurHomebaseEvent) {
      return;
    }

    await _debugLog('Homebase exit event confirmed');

    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();

    if (!config.isCompleteForMonitoring) {
      await _debugLog('Monitoring skipped: config incomplete on callback');
      await unregisterHomebaseMonitoring();
      return;
    }

    await _handleExitEvent(config);
  }

  Future<void> _handleExitEvent(GeoReminderConfig config) async {
    final Habit? habit = await DatabaseService.instance.getHabitById(
      config.protectedAvoidHabitId!,
    );

    if (habit == null || habit.type != HabitType.avoid || habit.isArchived) {
      await _debugLog('Invalid selected habit on exit callback');
      await unregisterHomebaseMonitoring();
      return;
    }

    final ({String title, String body}) message = buildMessage(habit);
    final NotificationDetails details = _defaultNotificationDetails();

    await requestNotificationPermission();

    await _debugLog('Immediate notification send attempted');

    await _notifications.show(
      _immediateNotificationId,
      message.title,
      message.body,
      details,
    );

    await _notifications.cancel(_followUpNotificationId);
    if (!config.followUpReminderEnabled) {
      return;
    }

    await _debugLog('Follow-up scheduled in '
        '${config.followUpReminderDelayMinutes} minutes');

    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(
      Duration(minutes: config.followUpReminderDelayMinutes),
    );

    await _notifications.zonedSchedule(
      _followUpNotificationId,
      'Check in before you go further',
      message.body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static ({String title, String body}) buildMessage(Habit habit) {
    final List<String> triggers = [habit.trigger1, habit.trigger2, habit.trigger3]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final List<String> motivations = [
      habit.motivation1,
      habit.motivation2,
      habit.motivation3,
    ].whereType<String>().map((value) => value.trim()).where((value) => value.isNotEmpty).toList();

    final String triggerText =
        triggers.isEmpty ? '' : 'Trigger: ${triggers.first}';
    final String motivationText =
        motivations.isEmpty ? '' : 'Why: ${motivations.first}';

    final String body = [triggerText, motivationText]
        .where((part) => part.isNotEmpty)
        .join(' • ');

    return (
      title: 'Stay sharp',
      body: body.isEmpty
          ? 'You left your homebase. Take a breath and choose your next move.'
          : body,
    );
  }

  NotificationDetails _defaultNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        'Geo avoid habit reminders',
        channelDescription:
            'Reminds you to stay on-track for your selected avoid habit after leaving homebase.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> _debugLog(String message) async {
    print(message);
    await LocalPreferencesService.appendGeoDebugLog(message);
  }
}
