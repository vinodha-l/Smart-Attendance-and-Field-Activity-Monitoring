import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/app_config.dart';
import '../models/attendance_record.dart';
import '../models/duty_task.dart';
import '../models/field_activity.dart';
import 'local_store.dart';

/// SQLite implementation of [LocalStore], backed by the `sqflite` plugin.
///
/// Every record is written before the upload is attempted, which is what makes
/// the attendance and activity screens usable without a network connection.
class SqfliteLocalStore implements LocalStore {
  SqfliteLocalStore({
    this.databaseName = AppConfig.databaseName,
    this.version = AppConfig.databaseVersion,
  });

  final String databaseName;
  final int version;

  Database? _database;

  Database get _db {
    final Database? db = _database;
    if (db == null) {
      throw StateError('SqfliteLocalStore.open() must be called first.');
    }
    return db;
  }

  @override
  Future<void> open() async {
    if (_database != null) return;
    final String path = p.join(await getDatabasesPath(), databaseName);
    _database = await openDatabase(
      path,
      version: version,
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance (
        local_id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        captured_at INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy_meters REAL NOT NULL,
        distance_meters REAL NOT NULL,
        within_geofence INTEGER NOT NULL,
        is_late INTEGER NOT NULL,
        photo_path TEXT,
        sync_status TEXT NOT NULL,
        remote_id TEXT,
        failure_reason TEXT,
        attempts INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX attendance_captured_at ON attendance (captured_at DESC)',
    );
    await db.execute('''
      CREATE TABLE activities (
        local_id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        remarks TEXT NOT NULL,
        captured_at INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy_meters REAL NOT NULL,
        photo_paths TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        remote_id TEXT,
        failure_reason TEXT,
        attempts INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        location_name TEXT NOT NULL,
        starts_at INTEGER NOT NULL,
        ends_at INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 1 is the first shipped schema, so there is nothing to migrate.
  }

  @override
  Future<void> insertAttendance(AttendanceRecord record) async {
    await _db.insert(
      'attendance',
      record.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateAttendance(AttendanceRecord record) =>
      insertAttendance(record);

  @override
  Future<List<AttendanceRecord>> attendanceOnDay(DateTime day) async {
    final DateTime start = DateTime(day.year, day.month, day.day);
    return attendanceBetween(start, start.add(const Duration(days: 1)));
  }

  @override
  Future<List<AttendanceRecord>> attendanceBetween(
    DateTime from,
    DateTime to,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'attendance',
      where: 'captured_at >= ? AND captured_at <= ?',
      whereArgs: <Object?>[
        from.toUtc().millisecondsSinceEpoch,
        to.toUtc().millisecondsSinceEpoch,
      ],
      orderBy: 'captured_at DESC',
    );
    return rows.map(AttendanceRecord.fromDbMap).toList();
  }

  @override
  Future<List<AttendanceRecord>> pendingAttendance() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'attendance',
      where: 'sync_status != ?',
      whereArgs: <Object?>['synced'],
      orderBy: 'captured_at ASC',
    );
    return rows.map(AttendanceRecord.fromDbMap).toList();
  }

  @override
  Future<void> insertActivity(FieldActivity activity) async {
    await _db.insert(
      'activities',
      activity.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateActivity(FieldActivity activity) =>
      insertActivity(activity);

  @override
  Future<List<FieldActivity>> activities({int limit = 50}) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'activities',
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return rows.map(FieldActivity.fromDbMap).toList();
  }

  @override
  Future<List<FieldActivity>> pendingActivities() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'activities',
      where: 'sync_status != ?',
      whereArgs: <Object?>['synced'],
      orderBy: 'captured_at ASC',
    );
    return rows.map(FieldActivity.fromDbMap).toList();
  }

  @override
  Future<void> replaceTasks(List<DutyTask> tasks) async {
    await _db.transaction((Transaction txn) async {
      await txn.delete('tasks');
      final Batch batch = txn.batch();
      for (final DutyTask task in tasks) {
        batch.insert('tasks', task.toDbMap());
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<DutyTask>> tasks() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'tasks',
      orderBy: 'starts_at ASC',
    );
    return rows.map(DutyTask.fromDbMap).toList();
  }

  @override
  Future<int> pendingCount() async {
    final List<Map<String, Object?>> attendance = await _db.rawQuery(
      "SELECT COUNT(*) AS total FROM attendance WHERE sync_status != 'synced'",
    );
    final List<Map<String, Object?>> activities = await _db.rawQuery(
      "SELECT COUNT(*) AS total FROM activities WHERE sync_status != 'synced'",
    );
    return _total(attendance) + _total(activities);
  }

  @override
  Future<void> clearOperationalData() async {
    await _db.transaction((Transaction txn) async {
      await txn.delete('attendance');
      await txn.delete('activities');
      await txn.delete('tasks');
    });
  }

  int _total(List<Map<String, Object?>> rows) =>
      rows.isEmpty ? 0 : (rows.first['total'] as num?)?.toInt() ?? 0;
}
