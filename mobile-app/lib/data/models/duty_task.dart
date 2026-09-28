import 'package:flutter/foundation.dart';

import '../../core/json.dart';

/// Progress of an assigned duty task.
enum TaskStatus {
  upcoming('upcoming'),
  inProgress('in_progress'),
  completed('completed');

  const TaskStatus(this.value);

  final String value;

  static TaskStatus fromValue(Object? value) {
    final String text = value?.toString() ?? '';
    return TaskStatus.values.firstWhere(
      (TaskStatus status) => status.value == text,
      orElse: () => TaskStatus.upcoming,
    );
  }
}

/// A task assigned to the worker for the day.
@immutable
class DutyTask {
  const DutyTask({
    required this.id,
    required this.title,
    required this.locationName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  factory DutyTask.fromJson(Map<String, dynamic> json) => DutyTask(
        id: asString(json['id'] ?? json['task_id']),
        title: asString(json['title']),
        locationName: asString(json['location'] ?? json['location_name']),
        startsAt: asDateTime(json['starts_at']) ?? DateTime.now(),
        endsAt: asDateTime(json['ends_at']) ?? DateTime.now(),
        status: TaskStatus.fromValue(json['status']),
      );

  factory DutyTask.fromDbMap(Map<String, Object?> map) => DutyTask(
        id: asString(map['id']),
        title: asString(map['title']),
        locationName: asString(map['location_name']),
        startsAt: asDateTime(map['starts_at']) ?? DateTime.now(),
        endsAt: asDateTime(map['ends_at']) ?? DateTime.now(),
        status: TaskStatus.fromValue(map['status']),
      );

  final String id;
  final String title;
  final String locationName;
  final DateTime startsAt;
  final DateTime endsAt;
  final TaskStatus status;

  Map<String, Object?> toDbMap() => <String, Object?>{
        'id': id,
        'title': title,
        'location_name': locationName,
        'starts_at': startsAt.toUtc().millisecondsSinceEpoch,
        'ends_at': endsAt.toUtc().millisecondsSinceEpoch,
        'status': status.value,
      };

  /// Window during which the task is expected to run.
  String get timeRange => '${_clock(startsAt)} - ${_clock(endsAt)}';

  static String _clock(DateTime time) {
    final DateTime local = time.toLocal();
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
  }
}
