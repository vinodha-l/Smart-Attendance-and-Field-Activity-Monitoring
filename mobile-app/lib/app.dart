import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'app_scope.dart';
import 'core/app_config.dart';
import 'core/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth_gate.dart';

/// Root widget of the field worker application.
class SmartFieldMonitoringApp extends StatelessWidget {
  const SmartFieldMonitoringApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => AppScope(
        dependencies: dependencies,
        child: ListenableBuilder(
          listenable: dependencies.settingsController,
          builder: (BuildContext context, Widget? child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context).appTitle,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            locale: dependencies.settingsController.locale,
            supportedLocales: AppConfig.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthGate(),
          ),
        ),
      );
}

/// Kept for the earlier demo entry point; prefer [SmartFieldMonitoringApp].
typedef SmartAttendanceApp = SmartFieldMonitoringApp;
