import 'dart:async';

import 'package:flutter/foundation.dart';

import 'data/local/local_store.dart';
import 'data/local/memory_local_store.dart';
import 'data/local/preferences_settings_store.dart';
import 'data/local/settings_store.dart';
import 'data/local/sqflite_local_store.dart';
import 'data/remote/api_client.dart';
import 'data/repositories/activity_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/face_verification_repository.dart';
import 'data/repositories/sync_repository.dart';
import 'data/repositories/task_repository.dart';
import 'services/camera_service.dart';
import 'services/connectivity_service.dart';
import 'services/fake_services.dart';
import 'services/location_service.dart';
import 'state/activity_controller.dart';
import 'state/attendance_controller.dart';
import 'state/session_controller.dart';
import 'state/settings_controller.dart';
import 'state/sync_controller.dart';
import 'state/task_controller.dart';

/// Composition root of the application.
///
/// It owns the storage, the API client, the device services, the repositories
/// and the controllers. Widgets reach it through `AppScope.of(context)`, and
/// the tests build it with fake services.
class AppDependencies {
  AppDependencies({
    required this.store,
    required this.settings,
    required this.api,
    required this.locationService,
    required this.cameraService,
    required this.connectivityService,
    this.usingSqlite = true,
  });

  final LocalStore store;
  final SettingsStore settings;
  final ApiClient api;
  final LocationService locationService;
  final CameraService cameraService;
  final ConnectivityService connectivityService;

  /// `false` when the app had to fall back to the in-memory store.
  final bool usingSqlite;

  late final AuthRepository auth = AuthRepository(api: api, settings: settings);
  late final FaceVerificationRepository faceVerification =
      RemoteFaceVerificationRepository(api: api);
  late final AttendanceRepository attendance =
      AttendanceRepository(store: store);
  late final ActivityRepository activities = ActivityRepository(store: store);
  late final TaskRepository tasks = TaskRepository(store: store, api: api);
  late final SyncRepository sync = SyncRepository(store: store, api: api);

  late final SettingsController settingsController = SettingsController(
    store: settings,
  );

  late final SessionController sessionController = SessionController(
    repository: auth,
  );

  late final SyncController syncController = SyncController(
    repository: sync,
    connectivity: connectivityService,
    tokenProvider: () => auth.token,
    onRecordsSynced: _handleRecordsSynced,
  );

  late final AttendanceController attendanceController = AttendanceController(
    repository: attendance,
    locationService: locationService,
    cameraService: cameraService,
    workerProvider: () => auth.worker,
    faceVerificationRepository: faceVerification,
    onRecordQueued: _handleRecordQueued,
  );

  late final ActivityController activityController = ActivityController(
    repository: activities,
    locationService: locationService,
    cameraService: cameraService,
    onRecordQueued: _handleRecordQueued,
  );

  late final TaskController taskController = TaskController(
    repository: tasks,
    tokenProvider: () => auth.token,
  );

  /// Builds the production dependency graph.
  ///
  /// The SQLite database is used when the plugin is available. On platforms
  /// without sqflite support (the web demo, or a broken plugin install) the app
  /// keeps working with an in-memory store and says so on the profile screen.
  static Future<AppDependencies> create({String? apiBaseUrl}) async {
    final SettingsStore settings = PreferencesSettingsStore();
    try {
      await settings.open();
    } catch (error) {
      debugPrint('Settings could not be loaded: $error');
    }

    LocalStore store;
    bool usingSqlite = true;
    try {
      final SqfliteLocalStore sqlite = SqfliteLocalStore();
      await sqlite.open();
      store = sqlite;
    } catch (error) {
      debugPrint('sqflite is unavailable, records stay in memory: $error');
      final MemoryLocalStore memory = MemoryLocalStore();
      await memory.open();
      store = memory;
      usingSqlite = false;
    }

    return AppDependencies(
      store: store,
      settings: settings,
      api: ApiClient(baseUrl: apiBaseUrl),
      locationService: const GeolocatorLocationService(),
      cameraService: ImagePickerCameraService(),
      connectivityService: PlusConnectivityService(),
      usingSqlite: usingSqlite,
    );
  }

  /// Dependency graph used by the widget tests.
  factory AppDependencies.forTesting({
    LocalStore? store,
    SettingsStore? settings,
    ApiClient? api,
    LocationService? locationService,
    CameraService? cameraService,
    ConnectivityService? connectivityService,
  }) =>
      AppDependencies(
        store: store ?? MemoryLocalStore(),
        settings: settings ?? MemorySettingsStore(),
        api: api ?? ApiClient(),
        locationService: locationService ?? FixedLocationService(),
        cameraService: cameraService ?? FakeCameraService(),
        connectivityService: connectivityService ?? FakeConnectivityService(),
      );

  /// Restores the session, the language and the upload queue.
  Future<void> initialize() async {
    await store.open();
    await settingsController.load();
    await sessionController.restore();
    await syncController.start();
    unawaited(attendanceController.refreshToday());
  }

  void dispose() {
    syncController.dispose();
    sessionController.dispose();
    settingsController.dispose();
    attendanceController.dispose();
    activityController.dispose();
    taskController.dispose();
    api.close();
  }

  void _handleRecordQueued() => unawaited(syncController.refreshPending());

  void _handleRecordsSynced() {
    unawaited(attendanceController.refreshToday());
    unawaited(attendanceController.loadHistory());
  }
}
