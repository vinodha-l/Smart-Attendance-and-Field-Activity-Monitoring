import '../../core/app_config.dart';
import '../local/local_store.dart';
import '../models/attendance_record.dart';
import '../models/field_activity.dart';
import '../models/pending_record.dart';
import '../models/sync_status.dart';
import '../remote/api_client.dart';
import '../remote/api_exception.dart';

/// Result of one sync attempt.
class SyncOutcome {
  const SyncOutcome({this.synced = 0, this.failed = 0, this.offline = false});

  final int synced;
  final int failed;

  /// `true` when the upload stopped because the server was unreachable.
  final bool offline;

  int get attempted => synced + failed;

  bool get didNothing => attempted == 0;
}

/// Uploads the records that were captured while the device was offline.
class SyncRepository {
  SyncRepository({required LocalStore store, required ApiClient api})
      : _store = store,
        _api = api;

  final LocalStore _store;
  final ApiClient _api;

  /// Every record that is still waiting for upload, oldest first.
  Future<List<PendingRecord>> pendingRecords() async {
    final List<AttendanceRecord> attendance = await _store.pendingAttendance();
    final List<FieldActivity> activities = await _store.pendingActivities();
    final List<PendingRecord> items = <PendingRecord>[
      ...attendance.map(PendingRecord.fromAttendance),
      ...activities.map(PendingRecord.fromActivity),
    ]..sort(
        (PendingRecord a, PendingRecord b) =>
            a.capturedAt.compareTo(b.capturedAt),
      );
    return items;
  }

  Future<int> pendingCount() => _store.pendingCount();

  /// Uploads everything that is pending, oldest record first.
  ///
  /// The upload stops as soon as the network drops so the queue keeps its order
  /// for the next attempt.
  Future<SyncOutcome> push({required String token}) async {
    int synced = 0;
    int failed = 0;

    for (final AttendanceRecord record in await _store.pendingAttendance()) {
      final PushResult result = await _pushAttendance(record, token);
      if (result == PushResult.offline) {
        return SyncOutcome(synced: synced, failed: failed, offline: true);
      }
      result == PushResult.synced ? synced++ : failed++;
    }

    for (final FieldActivity activity in await _store.pendingActivities()) {
      final PushResult result = await _pushActivity(activity, token);
      if (result == PushResult.offline) {
        return SyncOutcome(synced: synced, failed: failed, offline: true);
      }
      result == PushResult.synced ? synced++ : failed++;
    }

    return SyncOutcome(synced: synced, failed: failed);
  }

  Future<PushResult> _pushAttendance(
    AttendanceRecord record,
    String token,
  ) async {
    try {
      final String remoteId = await _api.uploadAttendance(
        record: record,
        token: token,
      );
      await _store.updateAttendance(
        record.copyWith(syncStatus: SyncStatus.synced, remoteId: remoteId),
      );
      return PushResult.synced;
    } on ApiException catch (error) {
      if (_isOffline(error)) return PushResult.offline;
      final int attempts = record.attempts + 1;
      final bool retryable =
          error.isRetryable && attempts < AppConfig.maxSyncAttempts;
      await _store.updateAttendance(
        record.copyWith(
          syncStatus: retryable ? SyncStatus.pending : SyncStatus.failed,
          attempts: attempts,
          failureReason: error.message,
        ),
      );
      return PushResult.failed;
    }
  }

  Future<PushResult> _pushActivity(
    FieldActivity activity,
    String token,
  ) async {
    try {
      final String remoteId = await _api.uploadActivity(
        activity: activity,
        token: token,
      );
      await _store.updateActivity(
        activity.copyWith(syncStatus: SyncStatus.synced, remoteId: remoteId),
      );
      return PushResult.synced;
    } on ApiException catch (error) {
      if (_isOffline(error)) return PushResult.offline;
      final int attempts = activity.attempts + 1;
      final bool retryable =
          error.isRetryable && attempts < AppConfig.maxSyncAttempts;
      await _store.updateActivity(
        activity.copyWith(
          syncStatus: retryable ? SyncStatus.pending : SyncStatus.failed,
          attempts: attempts,
          failureReason: error.message,
        ),
      );
      return PushResult.failed;
    }
  }

  bool _isOffline(ApiException error) =>
      error.failure == ApiFailure.network ||
      error.failure == ApiFailure.timeout;
}

/// Outcome of uploading a single record.
enum PushResult { synced, failed, offline }
