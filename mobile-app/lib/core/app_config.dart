import 'package:flutter/widgets.dart';

/// Static, build time configuration for the field worker application.
class AppConfig {
  const AppConfig._();

  /// Version string shown on the profile screen.
  static const String appVersion = '0.2.0';

  /// Base URL of the FastAPI backend.
  ///
  /// Override it for a physical device or another host:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api/v1`
  ///
  /// The default address is the host machine as seen from an Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Timeout applied to every backend request.
  static const Duration apiTimeout = Duration(seconds: 20);

  /// Maximum time allowed to obtain a fresh GPS fix.
  static const Duration locationTimeout = Duration(seconds: 30);

  /// Evidence photos are downscaled before they are stored or uploaded.
  static const int evidenceImageMaxWidth = 1280;
  static const int evidenceImageQuality = 75;

  /// Number of upload attempts before a queued record is flagged as failed.
  static const int maxSyncAttempts = 5;

  static const String databaseName = 'smart_field_monitoring.db';
  static const int databaseVersion = 1;

  /// Locales shipped with the application (English and Tamil).
  static const Locale fallbackLocale = Locale('en');
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// Default duty window used for the "late" flag until the server sends a
  /// shift specific value.
  static const int dutyStartHour = 9;
  static const int dutyStartMinute = 0;
  static const int lateGraceMinutes = 15;

  /// How long a cached login token stays valid on the device.
  static const Duration sessionLifetime = Duration(days: 7);
}
