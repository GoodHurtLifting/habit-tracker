class GeoReminderConfig {
  final bool geoReminderEnabled;
  final double? homebaseLatitude;
  final double? homebaseLongitude;
  final double homebaseRadiusMeters;
  final String? protectedAvoidHabitId;
  final bool followUpReminderEnabled;
  final int followUpReminderDelayMinutes;

  const GeoReminderConfig({
    required this.geoReminderEnabled,
    required this.homebaseLatitude,
    required this.homebaseLongitude,
    required this.homebaseRadiusMeters,
    required this.protectedAvoidHabitId,
    required this.followUpReminderEnabled,
    required this.followUpReminderDelayMinutes,
  });

  const GeoReminderConfig.defaults()
      : geoReminderEnabled = false,
        homebaseLatitude = null,
        homebaseLongitude = null,
        homebaseRadiusMeters = 400,
        protectedAvoidHabitId = null,
        followUpReminderEnabled = true,
        followUpReminderDelayMinutes = 60;

  bool get isCompleteForMonitoring {
    return geoReminderEnabled &&
        homebaseLatitude != null &&
        homebaseLongitude != null &&
        protectedAvoidHabitId != null &&
        protectedAvoidHabitId!.trim().isNotEmpty;
  }

  GeoReminderConfig copyWith({
    bool? geoReminderEnabled,
    double? homebaseLatitude,
    bool clearHomebaseLatitude = false,
    double? homebaseLongitude,
    bool clearHomebaseLongitude = false,
    double? homebaseRadiusMeters,
    String? protectedAvoidHabitId,
    bool clearProtectedAvoidHabitId = false,
    bool? followUpReminderEnabled,
    int? followUpReminderDelayMinutes,
  }) {
    return GeoReminderConfig(
      geoReminderEnabled: geoReminderEnabled ?? this.geoReminderEnabled,
      homebaseLatitude: clearHomebaseLatitude
          ? null
          : homebaseLatitude ?? this.homebaseLatitude,
      homebaseLongitude: clearHomebaseLongitude
          ? null
          : homebaseLongitude ?? this.homebaseLongitude,
      homebaseRadiusMeters: homebaseRadiusMeters ?? this.homebaseRadiusMeters,
      protectedAvoidHabitId: clearProtectedAvoidHabitId
          ? null
          : protectedAvoidHabitId ?? this.protectedAvoidHabitId,
      followUpReminderEnabled:
          followUpReminderEnabled ?? this.followUpReminderEnabled,
      followUpReminderDelayMinutes:
          followUpReminderDelayMinutes ?? this.followUpReminderDelayMinutes,
    );
  }
}
