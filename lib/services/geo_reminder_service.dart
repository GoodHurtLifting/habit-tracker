import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/geo_reminder_config.dart';
import '../models/habit.dart';
import 'database_service.dart';
import 'local_preferences_service.dart';

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

  @pragma('vm:entry-point')
  static Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
    await GeoReminderService.instance._handleGeofenceCallback(params);
  }


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

    print('Geo config loaded: '
        'enabled=${config.geoReminderEnabled}, '
        'lat=${config.homebaseLatitude}, '
        'lng=${config.homebaseLongitude}, '
        'radius=${config.homebaseRadiusMeters}, '
        'habit=${config.protectedAvoidHabitId}, '
        'complete=${config.isCompleteForMonitoring}');

    if (!config.isCompleteForMonitoring) {
      print('Geo monitoring not started: config incomplete');
      await unregisterHomebaseMonitoring();
      return;
    }

    final Habit? habit = await DatabaseService.instance.getHabitById(
      config.protectedAvoidHabitId!,
    );

    if (habit == null || habit.type != HabitType.avoid || habit.isArchived) {
      print('Geo monitoring not started: selected habit invalid '
          '(habitNull=${habit == null}, '
          'isAvoid=${habit?.type == HabitType.avoid}, '
          'isArchived=${habit?.isArchived})');
      await unregisterHomebaseMonitoring();
      return;
    }

    final bool hasPermission = await _ensureLocationPermissionForGeofence();
    if (!hasPermission) {
      print('Geo monitoring not started: background location permission not granted');
      await unregisterHomebaseMonitoring();
      return;
    }

    try {
      print('Removing any existing homebase geofence: $_homebaseGeofenceId');
      await NativeGeofenceManager.instance.removeGeofenceById(_homebaseGeofenceId);

      print('Registering geofence: '
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
        geofenceTriggered,
      );

      final List<ActiveGeofence> registeredGeofences =
      await NativeGeofenceManager.instance.getRegisteredGeofences();

      print('Geofence registration complete. '
          'Registered geofences count=${registeredGeofences.length}');
      for (final geofence in registeredGeofences) {
        print('Registered geofence id=${geofence.id}');
      }
    } on NativeGeofenceException catch (e) {
      print('Geofence registration failed: '
          'code=${e.code}, message=${e.message}');
      await unregisterHomebaseMonitoring();
    } catch (e, stackTrace) {
      print('Unexpected geofence registration error: $e');
      print(stackTrace);
      await unregisterHomebaseMonitoring();
    }
  }

  Future<void> unregisterHomebaseMonitoring() async {
    await NativeGeofenceManager.instance.removeGeofenceById(_homebaseGeofenceId);
    await _notifications.cancel(_followUpNotificationId);
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

  Future<bool> _ensureLocationPermissionForGeofence() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('Initial location permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('Location permission after request: $permission');
    }

    if (permission != LocationPermission.always) {
      permission = await Geolocator.requestPermission();
      print('Location permission after always-request attempt: $permission');
    }

    final bool granted = permission == LocationPermission.always;
    print('Background geofence permission granted=$granted');

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

  Future<void> _handleGeofenceCallback(GeofenceCallbackParams params) async {
    await _ensureNotificationsInitialized();

    print('Geofence callback fired: '
        'event=${params.event}, geofenceCount=${params.geofences.length}');

    if (params.event == GeofenceEvent.enter) {
      print('Homebase enter event confirmed');
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

    print('Homebase exit event confirmed');

    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();

    if (!config.isCompleteForMonitoring) {
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
      await unregisterHomebaseMonitoring();
      return;
    }

    final ({String title, String body}) message = buildMessage(habit);
    final NotificationDetails details = _defaultNotificationDetails();

    await requestNotificationPermission();

    print('Sending immediate geo reminder notification');

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

    print('Scheduling follow-up reminder in '
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
}
