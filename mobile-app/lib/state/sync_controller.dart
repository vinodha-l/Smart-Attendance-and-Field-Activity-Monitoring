import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/pending_record.dart';
import '../data/repositories/sync_repository.dart';
import '../services/connectivity_service.dart';

/// Keeps the upload queue moving whenever the device has a connection.
class SyncController extends ChangeNotifier {
  SyncController({
    required SyncRepository repository,
    required ConnectivityService connectivity,
    required String? Function() tokenProvider,
    this.onRecordsSynced,
  })  : _repository = repository,
        _connectivity = connectivity,
        _tokenProvider = tokenProvider;

  final SyncRepository _repository;
  final ConnectivityService _connectivity;
  final String? Function() _tokenProvider;

  /// Called after at least one record reached the server.
  final VoidCallback? onRecordsSynced;

  StreamSubscription<bool>? _subscription;

  bool _online = true;
  bool _syncing = false;
  int _pending = 0;
  SyncOutcome? _lastOutcome;

  bool get isOnline => _online;

  bool get syncing => _syncing;

  /// Number of records that still have to be uploaded.
  int get pendingCount => _pending;

  SyncOutcome? get lastOutcome => _lastOutcome;

  /// Starts watching the connection and loads the current queue size.
  Future<void> start() async {
    _online = await _connectivity.isOnline();
    _subscription = _connectivity.onlineChanges.listen(_handleConnectivity);
    await refreshPending();
  }

  Future<void> refreshPending() async {
    _pending = await _repository.pendingCount();
    notifyListeners();
  }

  Future<List<PendingRecord>> pendingRecords() => _repository.pendingRecords();

  /// Uploads the queue. Returns `null` when there is no session or an upload is
  /// already running.
  Future<SyncOutcome?> syncNow() async {
    final String? token = _tokenProvider();
    if (token == null || _syncing) return null;

    if (!_online) {
      _lastOutcome = const SyncOutcome(offline: true);
      notifyListeners();
      return _lastOutcome;
    }

    _syncing = true;
    _lastOutcome = null;
    notifyListeners();
    try {
      final SyncOutcome outcome = await _repository.push(token: token);
      _lastOutcome = outcome;
      _online = !outcome.offline;
      if (outcome.synced > 0) onRecordsSynced?.call();
      return outcome;
    } finally {
      _pending = await _repository.pendingCount();
      _syncing = false;
      notifyListeners();
    }
  }

  void _handleConnectivity(bool online) {
    _online = online;
    notifyListeners();
    if (online) {
      unawaited(syncNow());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
