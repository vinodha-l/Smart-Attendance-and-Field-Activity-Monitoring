import '../data/models/attendance_record.dart';
import '../data/models/field_activity.dart';
import 'app_localizations.dart';

/// Localized label of an activity type.
String activityTypeLabel(AppLocalizations l10n, ActivityType type) =>
    switch (type) {
      ActivityType.streetSanitation => l10n.activityTypeStreetSanitation,
      ActivityType.toiletInspection => l10n.activityTypeToiletInspection,
      ActivityType.drainageInspection => l10n.activityTypeDrainageInspection,
      ActivityType.other => l10n.activityTypeOther,
    };

/// Localized label of an attendance punch.
String attendanceTypeLabel(AppLocalizations l10n, AttendanceType type) =>
    type == AttendanceType.checkIn
        ? l10n.attendanceTypeCheckIn
        : l10n.attendanceTypeCheckOut;
