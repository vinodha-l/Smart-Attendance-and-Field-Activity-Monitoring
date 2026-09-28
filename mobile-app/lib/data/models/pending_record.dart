import 'attendance_record.dart';
import 'field_activity.dart';
import 'sync_status.dart';

/// One record that still has to be uploaded, shown by the sync queue screen.
class PendingRecord {
  const PendingRecord({
    required this.localId,
    required this.capturedAt,
    required this.attempts,
    required this.status,
    required this.photoCount,
    this.attendanceType,
    this.activityType,
  });

  factory PendingRecord.fromAttendance(AttendanceRecord record) =>
      PendingRecord(
        localId: record.localId,
        capturedAt: record.capturedAt,
        attempts: record.attempts,
        status: record.syncStatus,
        photoCount: record.photoPath == null ? 0 : 1,
        attendanceType: record.type,
      );

  factory PendingRecord.fromActivity(FieldActivity activity) => PendingRecord(
        localId: activity.localId,
        capturedAt: activity.capturedAt,
        attempts: activity.attempts,
        status: activity.syncStatus,
        photoCount: activity.photoPaths.length,
        activityType: activity.type,
      );

  final String localId;
  final DateTime capturedAt;
  final int attempts;
  final SyncStatus status;

  /// Number of photos attached to the record.
  final int photoCount;

  /// Set when the record is an attendance punch.
  final AttendanceType? attendanceType;

  /// Set when the record is a field activity report.
  final ActivityType? activityType;

  bool get isAttendance => attendanceType != null;

  bool get hasFailed => status == SyncStatus.failed;
}
