import '../models/attendance_record.dart';
import '../models/duty_task.dart';
import '../models/field_activity.dart';
import '../models/sync_status.dart';
import 'local_store.dart';

/// In-memory implementation of [LocalStore].
///
/// It is used by the unit and widget tests and as a fallback when the sqflite
/// plugin cannot be initialised on the current platform.
class MemoryLocalStore implements LocalStore {
  final Map<String, AttendanceRecord> _attendance =
      <String, AttendanceRecord>{};
  final Map<String, FieldActivity> _activities = <String, FieldActivity>{};
  final Map<String, DutyTask> _tasks = <String, DutyTask>{};

  bool _open = false;

  bool get isOpen => _open;

  @override
  Future<void> open() async {
    _open = true;
  }

  @override
  Future<void> close() async {
    _open = false;
  }

  @override
  Future<void> insertAttendance(AttendanceRecord record) async {
    _attendance[record.localId] = record;
  }

  @override
  Future<void> updateAttendance(AttendanceRecord record) async {
    _attendance[record.localId] = record;
  }

  @override
  Future<List<AttendanceRecord>> attendanceOnDay(DateTime day) async {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));
    return attendanceBetween(
        start, end.subtract(const Duration(milliseconds: 1)));
  }

  @override
  Future<List<AttendanceRecord>> attendanceBetween(
    DateTime from,
    DateTime to,
  ) async {
    final List<AttendanceRecord> records = _attendance.values
        .where(
          (AttendanceRecord record) =>
              record.capturedAt
                  .isAfter(from.subtract(const Duration(seconds: 1))) &&
              record.capturedAt.isBefore(to.add(const Duration(seconds: 1))),
        )
        .toList()
      ..sort(
        (AttendanceRecord a, AttendanceRecord b) =>
            b.capturedAt.compareTo(a.capturedAt),
      );
    return records;
  }

  @override
  Future<List<AttendanceRecord>> pendingAttendance() async =>
      _pending<AttendanceRecord>(
          _attendance.values, (r) => r.syncStatus, (r) => r.capturedAt);

  @override
  Future<void> insertActivity(FieldActivity activity) async {
    _activities[activity.localId] = activity;
  }

  @override
  Future<void> updateActivity(FieldActivity activity) async {
    _activities[activity.localId] = activity;
  }

  @override
  Future<List<FieldActivity>> activities({int limit = 50}) async {
    final List<FieldActivity> list = _activities.values.toList()
      ..sort(
        (FieldActivity a, FieldActivity b) =>
            b.capturedAt.compareTo(a.capturedAt),
      );
    return list.take(limit).toList();
  }

  @override
  Future<List<FieldActivity>> pendingActivities() async =>
      _pending<FieldActivity>(
          _activities.values, (r) => r.syncStatus, (r) => r.capturedAt);

  @override
  Future<void> replaceTasks(List<DutyTask> tasks) async {
    _tasks
      ..clear()
      ..addEntries(tasks.map((DutyTask task) => MapEntry(task.id, task)));
  }

  @override
  Future<List<DutyTask>> tasks() async {
    final List<DutyTask> list = _tasks.values.toList()
      ..sort(
        (DutyTask a, DutyTask b) => a.startsAt.compareTo(b.startsAt),
      );
    return list;
  }

  @override
  Future<int> pendingCount() async {
    final int attendance =
        await pendingAttendance().then((List<AttendanceRecord> r) => r.length);
    final int activities =
        await pendingActivities().then((List<FieldActivity> r) => r.length);
    return attendance + activities;
  }

  @override
  Future<void> clearOperationalData() async {
    _attendance.clear();
    _activities.clear();
    _tasks.clear();
  }
}

List<T> _pending<T>(
  Iterable<T> values,
  SyncStatus Function(T value) statusOf,
  DateTime Function(T value) timeOf,
) {
  final List<T> list = values
      .where((T value) => statusOf(value).needsUpload)
      .toList()
    ..sort((T a, T b) => timeOf(a).compareTo(timeOf(b)));
  return list;
}
