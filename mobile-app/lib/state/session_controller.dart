import 'package:flutter/foundation.dart';

import '../data/models/worker.dart';
import '../data/models/auth_session.dart';
import '../data/remote/api_exception.dart';
import '../data/repositories/auth_repository.dart';

/// Sign in state of the application.
enum AuthStatus { unknown, signedOut, signedIn }

/// Keeps the signed in worker and drives the login screen.
class SessionController extends ChangeNotifier {
  SessionController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  Worker? _worker;
  bool _busy = false;
  ApiException? _failure;

  AuthStatus get status => _status;

  Worker? get worker => _worker;

  bool get busy => _busy;

  /// Last failure raised by the backend, shown on the login screen.
  ApiException? get failure => _failure;

  String? get token => _repository.token;

  /// Restores the session stored on the device, if any.
  Future<void> restore() async {
    final AuthSession? session = await _repository.restoreSession();
    _worker = session?.worker;
    _status = session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  Future<bool> signIn({
    required String employeeId,
    required String password,
  }) async {
    _busy = true;
    _failure = null;
    notifyListeners();
    try {
      _worker = await _repository.signIn(
        employeeId: employeeId,
        password: password,
      );
      _status = AuthStatus.signedIn;
      return true;
    } on ApiException catch (error) {
      _failure = error;
      _status = AuthStatus.signedOut;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> requestOtp(String phoneNumber) async {
    _busy = true;
    _failure = null;
    notifyListeners();
    try {
      await _repository.requestOtp(phoneNumber);
      return true;
    } on ApiException catch (error) {
      _failure = error;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    _busy = true;
    _failure = null;
    notifyListeners();
    try {
      _worker = await _repository.signInWithOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      _status = AuthStatus.signedIn;
      return true;
    } on ApiException catch (error) {
      _failure = error;
      _status = AuthStatus.signedOut;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signInForDemo() async {
    _busy = true;
    _failure = null;
    notifyListeners();
    try {
      _worker = await _repository.signInForDemo();
      _status = AuthStatus.signedIn;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _worker = null;
    _failure = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}
