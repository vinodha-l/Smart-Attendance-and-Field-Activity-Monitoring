import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tells the app whether uploads can be attempted.
///
/// Note that the operating system only reports the state of the radio, not
/// whether the backend is reachable. Uploads are therefore still treated as
/// failed when the request itself raises a network error.
abstract class ConnectivityService {
  Future<bool> isOnline();

  /// Emits whenever the online state changes.
  Stream<bool> get onlineChanges;
}

/// Production implementation, backed by the `connectivity_plus` plugin.
class PlusConnectivityService implements ConnectivityService {
  PlusConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async =>
      _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  bool _hasConnection(List<ConnectivityResult> results) => results
      .any((ConnectivityResult result) => result != ConnectivityResult.none);
}
