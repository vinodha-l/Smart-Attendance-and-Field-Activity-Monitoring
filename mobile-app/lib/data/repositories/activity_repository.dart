import '../../core/ids.dart';
import '../../services/location_service.dart';
import '../local/local_store.dart';
import '../models/field_activity.dart';
import '../models/sync_status.dart';

/// Local storage for field activity reports and their evidence photos.
class ActivityRepository {
  ActivityRepository({required LocalStore store}) : _store = store;

  final LocalStore _store;

  Future<List<FieldActivity>> recent({int limit = 50}) =>
      _store.activities(limit: limit);

  Future<List<FieldActivity>> pending() => _store.pendingActivities();

  Future<int> pendingCount() => _store.pendingActivities().then(
        (List<FieldActivity> records) => records.length,
      );

  /// Stores a new activity report on the device.
  Future<FieldActivity> capture({
    required ActivityType type,
    required String remarks,
    required LocationReading reading,
    required List<String> photoPaths,
    required DateTime capturedAt,
  }) async {
    final FieldActivity activity = FieldActivity(
      localId: newLocalId('act'),
      type: type,
      remarks: remarks.trim(),
      capturedAt: capturedAt,
      position: reading.point,
      accuracyMeters: reading.accuracyMeters,
      photoPaths: List<String>.unmodifiable(photoPaths),
    );
    await _store.insertActivity(activity);
    return activity;
  }

  Future<void> markSynced(FieldActivity activity, String remoteId) =>
      _store.updateActivity(
        activity.copyWith(syncStatus: SyncStatus.synced, remoteId: remoteId),
      );

  Future<void> markUploadResult(
    FieldActivity activity, {
    required bool retryable,
    required String reason,
  }) =>
      _store.updateActivity(
        activity.copyWith(
          syncStatus: retryable ? SyncStatus.pending : SyncStatus.failed,
          attempts: activity.attempts + 1,
          failureReason: reason,
        ),
      );

  /// Adds reports downloaded from the server to the local cache.
  Future<void> cacheRemote(List<FieldActivity> activities) async {
    for (final FieldActivity activity in activities) {
      final String? remoteId = activity.remoteId;
      if (remoteId != null && remoteId.isNotEmpty) {
        await _store.insertActivity(activity);
      }
    }
  }
}
