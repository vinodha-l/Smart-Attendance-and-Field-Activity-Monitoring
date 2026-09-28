import 'dart:convert';

import '../../core/json.dart';
import '../local/settings_store.dart';
import '../models/auth_session.dart';
import '../models/geo_point.dart';
import '../models/worker.dart';
import '../remote/api_client.dart';

/// Sign in, session cache and sign out.
///
/// The token and worker profile are kept in [SettingsStore] so the worker stays
/// signed in between shifts, including while the device has no connection.
class AuthRepository {
  AuthRepository({required ApiClient api, required SettingsStore settings})
      : _api = api,
        _settings = settings;

  final ApiClient _api;
  final SettingsStore _settings;

  AuthSession? _session;

  AuthSession? get session => _session;

  Worker? get worker => _session?.worker;

  String? get token => _session?.token;

  /// Restores the session cached on the device, `null` when there is none.
  Future<AuthSession?> restoreSession() async {
    final String? raw = _settings.getString(SettingsKeys.session);
    if (raw == null) return null;

    final AuthSession session = AuthSession.fromJson(asJson(raw));
    if (!session.isValid) {
      await _settings.remove(SettingsKeys.session);
      return null;
    }
    _session = session;
    return session;
  }

  /// Signs in against the backend and caches the returned session.
  ///
  /// Throws an [ApiException] when the credentials are rejected or the server
  /// cannot be reached.
  Future<Worker> signIn({
    required String employeeId,
    required String password,
  }) async {
    final String id = employeeId.trim();
    final AuthSession session = await _api.login(
      employeeId: id,
      password: password,
    );

    // The backend is expected to echo the profile. If it does not, the value
    // typed by the worker is kept so the dashboard still has data to show.
    final AuthSession cached = session.worker.employeeId.isEmpty
        ? AuthSession(
            token: session.token,
            expiresAt: session.expiresAt,
            worker: _fallbackWorker(id),
          )
        : session;

    _session = cached;
    await _settings.setString(
        SettingsKeys.session, jsonEncode(cached.toJson()));
    return cached.worker;
  }

  /// Requests an OTP for a registered worker mobile number.
  Future<void> requestOtp(String phoneNumber) => _api.requestOtp(
        phoneNumber: phoneNumber,
      );

  /// Verifies the OTP and stores the returned authenticated session.
  Future<Worker> signInWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final AuthSession session = await _api.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    _session = session;
    await _settings.setString(
        SettingsKeys.session, jsonEncode(session.toJson()));
    return session.worker;
  }

  /// Starts a local, non-production session so the mobile interface can be
  /// demonstrated before the backend OTP service is connected.
  Future<Worker> signInForDemo() async {
    final Worker worker = Worker(
      employeeId: 'SW-DEMO-01',
      name: 'Vinodha L',
      designation: 'Sanitation Field Worker',
      assignedArea: 'Chennai Ward 12',
      mobileNumber: '+91 98765 43210',
      siteCentre: const GeoPoint(latitude: 13.0827, longitude: 80.2707),
      geofenceRadiusMeters: 250,
    );
    final AuthSession session = AuthSession(
      token: 'local-demo-session',
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
      worker: worker,
    );
    _session = session;
    await _settings.setString(
        SettingsKeys.session, jsonEncode(session.toJson()));
    return worker;
  }

  Future<void> signOut() async {
    _session = null;
    await _settings.remove(SettingsKeys.session);
  }

  Worker _fallbackWorker(String employeeId) => Worker(
        employeeId: employeeId,
        name: employeeId,
        designation: '',
        assignedArea: '',
        mobileNumber: '',
        siteCentre: const GeoPoint(latitude: 0, longitude: 0),
        geofenceRadiusMeters: 0,
      );
}
