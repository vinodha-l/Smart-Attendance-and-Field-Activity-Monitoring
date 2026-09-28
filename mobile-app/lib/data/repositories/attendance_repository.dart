import '../../core/app_config.dart';
import '../../core/geo.dart';
import '../../core/ids.dart';
import '../../services/location_service.dart';
import '../local/local_store.dart';
import '../models/attendance_record.dart';
import '../models/sync_status.dart';
import '../models/worker.dart';

/// Local storage for attendance punches.
///
/// A punch is written to the device before the upload is attempted, so the
/// geofence result and the photo are never lost when the network is down.
class AttendanceRepository {
  AttendanceRepository({required LocalStore store}) : _store = store;

  final LocalStore _store;

  Future<List<AttendanceRecord>> history({int days = 30}) =>
      _store.attendanceBetween(
        DateTime.now().subtract(Duration(days: days)),
        DateTime.now(),
      );

  Future<List<AttendanceRecord>> recordsForDay(DateTime day) =>
      _store.attendanceOnDay(day);

  Future<List<AttendanceRecord>> pending() => _store.pendingAttendance();

  Future<AttendanceRecord?> todayCheckIn() async => _firstOfType(
        await _store.attendanceOnDay(DateTime.now()),
        AttendanceType.checkIn,
      );

  Future<AttendanceRecord?> todayCheckOut() async => _firstOfType(
        await _store.attendanceOnDay(DateTime.now()),
        AttendanceType.checkOut,
      );

  /// `true` when the worker checked in and has not checked out yet.
  Future<bool> isOnDuty() async {
    final AttendanceRecord? checkIn = await todayCheckIn();
    final AttendanceRecord? checkOut = await todayCheckOut();
    return checkIn != null && checkOut == null;
  }

  /// Evaluates the geofence of [worker] and stores the punch on the device.
  Future<AttendanceRecord> capture({
    required AttendanceType type,
    required LocationReading reading,
    required Worker worker,
    required DateTime capturedAt,
    String? photoPath,
  }) async {
    final double distance = distanceInMeters(reading.point, worker.siteCentre);
    final AttendanceRecord record = AttendanceRecord(
      localId: newLocalId('att'),
      type: type,
      capturedAt: capturedAt,
      position: reading.point,
      accuracyMeters: reading.accuracyMeters,
      distanceFromSiteMeters: distance,
      withinGeofence: worker.geofenceRadiusMeters <= 0 ||
          distance <= worker.geofenceRadiusMeters,
      isLate: type == AttendanceType.checkIn && isLatePunch(capturedAt),
      photoPath: photoPath,
    );
    await _store.insertAttendance(record);
    return record;
  }

  Future<void> attachPhoto(AttendanceRecord record, String? photoPath) async {
    if (photoPath == null) return;
    await _store.updateAttendance(record.copyWith(photoPath: photoPath));
  }

  Future<void> markSynced(AttendanceRecord record, String remoteId) =>
      _store.updateAttendance(
        record.copyWith(syncStatus: SyncStatus.synced, remoteId: remoteId),
      );

  Future<void> markUploadResult(
    AttendanceRecord record, {
    required bool retryable,
    required String reason,
  }) =>
      _store.updateAttendance(
        record.copyWith(
          syncStatus: retryable ? SyncStatus.pending : SyncStatus.failed,
          attempts: record.attempts + 1,
          failureReason: reason,
        ),
      );

  /// Adds records downloaded from the server to the local cache.
  Future<void> cacheRemote(List<AttendanceRecord> records) async {
    for (final AttendanceRecord record in records) {
      final String? remoteId = record.remoteId;
      if (remoteId != null && remoteId.isNotEmpty) {
        await _store.insertAttendance(record);
      }
    }
  }

  Future<int> pendingCount() async => (await _store.pendingAttendance()).length;

  AttendanceRecord? _firstOfType(
    List<AttendanceRecord> records,
    AttendanceType type,
  ) {
    final List<AttendanceRecord> matching = records
        .where((AttendanceRecord record) => record.type == type)
        .toList();
    if (matching.isEmpty) return null;
    // The store returns records newest first.
    return type == AttendanceType.checkIn ? matching.last : matching.first;
  }
}

/// A check-in is late when it happens after the duty start plus the grace
/// period configured in [AppConfig].
bool isLatePunch(
  DateTime capturedAt, {
  int dutyStartHour = AppConfig.dutyStartHour,
  int dutyStartMinute = AppConfig.dutyStartMinute,
  int graceMinutes = AppConfig.lateGraceMinutes,
}) {
  final DateTime limit = DateTime(
    capturedAt.year,
    capturedAt.month,
    capturedAt.day,
    dutyStartHour,
    dutyStartMinute,
  ).add(Duration(minutes: graceMinutes));
  return capturedAt.isAfter(limit);
}
