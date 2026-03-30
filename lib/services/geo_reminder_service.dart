import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
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

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionSubscription;
  bool? _wasInsideHomebase;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
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

    _isInitialized = true;

    await refreshMonitoringFromPreferences();
  }

  Future<void> refreshMonitoringFromPreferences() async {
    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();

    if (!config.isCompleteForMonitoring) {
      await unregisterHomebaseMonitoring();
      return;
    }

    final Habit? habit = await DatabaseService.instance.getHabitById(
      config.protectedAvoidHabitId!,
    );

    if (habit == null || habit.type != HabitType.avoid || habit.isArchived) {
      await unregisterHomebaseMonitoring();
      return;
    }

    final bool hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      await unregisterHomebaseMonitoring();
      return;
    }

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    final Position initialPosition = await Geolocator.getCurrentPosition();
    _wasInsideHomebase = _isInsideHomebase(config, initialPosition);

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((position) {
      _handlePositionUpdate(position);
    });
  }

  Future<void> unregisterHomebaseMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _wasInsideHomebase = null;
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
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
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

  bool _isInsideHomebase(GeoReminderConfig config, Position position) {
    final double lat = config.homebaseLatitude!;
    final double lng = config.homebaseLongitude!;

    final double distanceMeters = Geolocator.distanceBetween(
      lat,
      lng,
      position.latitude,
      position.longitude,
    );

    return distanceMeters <= config.homebaseRadiusMeters;
  }

  Future<void> _handlePositionUpdate(Position position) async {
    final GeoReminderConfig config =
        await LocalPreferencesService.getGeoReminderConfig();

    if (!config.isCompleteForMonitoring) {
      await unregisterHomebaseMonitoring();
      return;
    }

    final bool isInside = _isInsideHomebase(config, position);
    final bool wasInside = _wasInsideHomebase ?? isInside;

    if (wasInside && !isInside) {
      await _handleExitEvent(config);
    }

    _wasInsideHomebase = isInside;
  }

  Future<void> _handleExitEvent(GeoReminderConfig config) async {
    final Habit? habit = await DatabaseService.instance.getHabitById(
      config.protectedAvoidHabitId!,
    );

    if (habit == null || habit.type != HabitType.avoid || habit.isArchived) {
      return;
    }

    final ({String title, String body}) message = _buildMessage(habit);
    final NotificationDetails details = _defaultNotificationDetails();

    await requestNotificationPermission();

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

  ({String title, String body}) _buildMessage(Habit habit) {
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
