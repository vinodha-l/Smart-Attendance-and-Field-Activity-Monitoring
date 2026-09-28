import '../models/attendance_record.dart';
import '../models/duty_task.dart';
import '../models/field_activity.dart';

/// Offline database used by the field application.
///
/// Two implementations are provided: [SqfliteLocalStore] for Android and
/// [MemoryLocalStore] for tests as well as for platforms where sqflite is not
/// available (for example the web demo build).
abstract class LocalStore {
  Future<void> open();

  Future<void> close();

  /// Stores a new attendance punch.
  Future<void> insertAttendance(AttendanceRecord record);

  Future<void> updateAttendance(AttendanceRecord record);

  /// All punches of a single calendar day, newest first.
  Future<List<AttendanceRecord>> attendanceOnDay(DateTime day);

  /// Punches between [from] and [to] inclusive, newest first.
  Future<List<AttendanceRecord>> attendanceBetween(DateTime from, DateTime to);

  /// Punches that still have to be uploaded.
  Future<List<AttendanceRecord>> pendingAttendance();

  Future<void> insertActivity(FieldActivity activity);

  Future<void> updateActivity(FieldActivity activity);

  Future<List<FieldActivity>> activities({int limit = 50});

  Future<List<FieldActivity>> pendingActivities();

  /// Replaces the cached duty tasks, for example after a refresh from the API.
  Future<void> replaceTasks(List<DutyTask> tasks);

  Future<List<DutyTask>> tasks();

  /// Number of records waiting for upload.
  Future<int> pendingCount();

  /// Removes every attendance and activity record kept on the device.
  Future<void> clearOperationalData();
}
