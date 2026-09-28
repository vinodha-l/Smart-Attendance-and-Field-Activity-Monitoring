import 'package:flutter/foundation.dart';

import '../../core/json.dart';
import 'geo_point.dart';
import 'sync_status.dart';

/// Field activities a worker can report.
enum ActivityType {
  streetSanitation('street_sanitation'),
  toiletInspection('toilet_inspection'),
  drainageInspection('drainage_inspection'),
  other('other');

  const ActivityType(this.value);

  /// Value used by the backend and the local database.
  final String value;

  static ActivityType fromValue(Object? value) {
    final String text = value?.toString() ?? '';
    return ActivityType.values.firstWhere(
      (ActivityType type) => type.value == text,
      orElse: () => ActivityType.other,
    );
  }
}

/// A completed piece of field work, with its evidence photos.
@immutable
class FieldActivity {
  const FieldActivity({
    required this.localId,
    required this.type,
    required this.remarks,
    required this.capturedAt,
    required this.position,
    required this.accuracyMeters,
    required this.photoPaths,
    this.syncStatus = SyncStatus.pending,
    this.remoteId,
    this.failureReason,
    this.attempts = 0,
  });

  factory FieldActivity.fromDbMap(Map<String, Object?> map) => FieldActivity(
        localId: asString(map['local_id']),
        type: ActivityType.fromValue(map['type']),
        remarks: asString(map['remarks']),
        capturedAt: asDateTime(map['captured_at']) ?? DateTime.now(),
        position: GeoPoint.fromMap(map),
        accuracyMeters: asDouble(map['accuracy_meters']),
        photoPaths: asStringList(_decodePhotoPaths(map['photo_paths'])),
        syncStatus: SyncStatus.fromValue(map['sync_status']),
        remoteId: asNullableString(map['remote_id']),
        failureReason: asNullableString(map['failure_reason']),
        attempts: asInt(map['attempts']),
      );

  factory FieldActivity.fromJson(Map<String, dynamic> json) => FieldActivity(
        localId: asString(
          json['client_reference'] ?? json['local_id'] ?? json['id'],
        ),
        type: ActivityType.fromValue(json['type']),
        remarks: asString(json['remarks']),
        capturedAt: asDateTime(json['captured_at']) ?? DateTime.now(),
        position: GeoPoint(
          latitude: asDouble(json['latitude']),
          longitude: asDouble(json['longitude']),
        ),
        accuracyMeters: asDouble(json['accuracy_meters']),
        photoPaths: asStringList(json['photo_urls'] ?? json['evidence']),
        syncStatus: SyncStatus.synced,
        remoteId: asString(json['id']),
      );

  final String localId;
  final ActivityType type;
  final String remarks;
  final DateTime capturedAt;
  final GeoPoint position;
  final double accuracyMeters;

  /// Local paths of the evidence photos attached to the report.
  final List<String> photoPaths;
  final SyncStatus syncStatus;
  final String? remoteId;
  final String? failureReason;
  final int attempts;

  FieldActivity copyWith({
    SyncStatus? syncStatus,
    String? remoteId,
    String? failureReason,
    int? attempts,
    List<String>? photoPaths,
  }) =>
      FieldActivity(
        localId: localId,
        type: type,
        remarks: remarks,
        capturedAt: capturedAt,
        position: position,
        accuracyMeters: accuracyMeters,
        photoPaths: photoPaths ?? this.photoPaths,
        syncStatus: syncStatus ?? this.syncStatus,
        remoteId: remoteId ?? this.remoteId,
        failureReason: failureReason ?? this.failureReason,
        attempts: attempts ?? this.attempts,
      );

  Map<String, Object?> toDbMap() => <String, Object?>{
        'local_id': localId,
        'type': type.value,
        'remarks': remarks,
        'captured_at': capturedAt.toUtc().millisecondsSinceEpoch,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': accuracyMeters,
        'photo_paths': _encodePhotoPaths(photoPaths),
        'sync_status': syncStatus.value,
        'remote_id': remoteId,
        'failure_reason': failureReason,
        'attempts': attempts,
      };

  /// JSON body of `POST /activities`; photos travel as separate parts.
  Map<String, Object?> toRequestPayload() => <String, Object?>{
        'client_reference': localId,
        'type': type.value,
        'remarks': remarks,
        'captured_at': capturedAt.toUtc().toIso8601String(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': accuracyMeters,
      };

  @override
  String toString() =>
      'FieldActivity($localId, ${type.value}, ${syncStatus.value})';
}

String _encodePhotoPaths(List<String> paths) => paths.join('\u0000');

List<String> _decodePhotoPaths(Object? value) {
  final String raw = asString(value);
  return raw.isEmpty
      ? const <String>[]
      : raw.split('\u0000').where((String path) => path.isNotEmpty).toList();
}
