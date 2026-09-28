import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'app_dependencies.dart';

export 'app.dart' show SmartAttendanceApp, SmartFieldMonitoringApp;

/// Entry point of the field worker application.
///
/// The backend address can be changed at build time with
/// `--dart-define=API_BASE_URL=http://<host>:8000/api/v1`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads the date and time symbols of every supported locale (English, Tamil).
  await initializeDateFormatting();

  final AppDependencies dependencies = await AppDependencies.create();
  await dependencies.initialize();

  runApp(SmartFieldMonitoringApp(dependencies: dependencies));
}
