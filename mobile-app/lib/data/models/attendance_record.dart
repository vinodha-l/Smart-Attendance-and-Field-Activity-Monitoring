import 'package:flutter/foundation.dart';

import '../../core/json.dart';
import 'geo_point.dart';
import 'sync_status.dart';

/// Whether the record marks the start or the end of the duty.
enum AttendanceType {
  checkIn('check_in'),
  checkOut('check_out');

  const AttendanceType(this.value);

  /// Value used by the backend and the local database.
  final String value;

  static AttendanceType fromValue(Object? value) =>
      value?.toString() == checkOut.value ? checkOut : checkIn;
}

/// One attendance punch captured on the device.
@immutable
class AttendanceRecord {
  const AttendanceRecord({
    required this.localId,
    required this.type,
    required this.capturedAt,
    required this.position,
    required this.accuracyMeters,
    required this.distanceFromSiteMeters,
    required this.withinGeofence,
    required this.isLate,
    this.photoPath,
    this.syncStatus = SyncStatus.pending,
    this.remoteId,
    this.failureReason,
    this.attempts = 0,
  });

  /// Rebuilds a record that was stored by [LocalStore].
  factory AttendanceRecord.fromDbMap(Map<String, Object?> map) =>
      AttendanceRecord(
        localId: asString(map['local_id']),
        type: AttendanceType.fromValue(map['type']),
        capturedAt: asDateTime(map['captured_at']) ?? DateTime.now(),
        position: GeoPoint.fromMap(map),
        accuracyMeters: asDouble(map['accuracy_meters']),
        distanceFromSiteMeters: asDouble(map['distance_meters']),
        withinGeofence: asBool(map['within_geofence']),
        isLate: asBool(map['is_late']),
        photoPath: asNullableString(map['photo_path']),
        syncStatus: SyncStatus.fromValue(map['sync_status']),
        remoteId: asNullableString(map['remote_id']),
        failureReason: asNullableString(map['failure_reason']),
        attempts: asInt(map['attempts']),
      );

  /// Rebuilds a record that was returned by the backend.
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        localId: asString(
          json['client_reference'] ?? json['local_id'] ?? json['id'],
        ),
        type: AttendanceType.fromValue(json['type']),
        capturedAt: asDateTime(json['captured_at']) ?? DateTime.now(),
        position: GeoPoint(
          latitude: asDouble(json['latitude']),
          longitude: asDouble(json['longitude']),
        ),
        accuracyMeters: asDouble(json['accuracy_meters']),
        distanceFromSiteMeters: asDouble(json['distance_meters']),
        withinGeofence: asBool(json['within_geofence'], fallback: true),
        isLate: asBool(json['is_late']),
        photoPath: asNullableString(json['photo_url']),
        syncStatus: SyncStatus.synced,
        remoteId: asString(json['id']),
      );

  /// Identifier generated on the device; also sent as `client_reference`.
  final String localId;
  final AttendanceType type;
  final DateTime capturedAt;
  final GeoPoint position;
  final double accuracyMeters;

  /// Distance between the GPS fix and the centre of the assigned area.
  final double distanceFromSiteMeters;
  final bool withinGeofence;

  /// `true` when a check-in happened after the allowed duty start.
  final bool isLate;

  /// Local path of the attendance photo, `null` while the photo is missing.
  final String? photoPath;
  final SyncStatus syncStatus;
  final String? remoteId;
  final String? failureReason;
  final int attempts;

  /// Calendar day of the punch, used for the "today" queries.
  DateTime get day => DateTime(
        capturedAt.year,
        capturedAt.month,
        capturedAt.day,
      );

  bool get isCheckIn => type == AttendanceType.checkIn;

  AttendanceRecord copyWith({
    AttendanceType? type,
    String? photoPath,
    SyncStatus? syncStatus,
    String? remoteId,
    String? failureReason,
    int? attempts,
  }) =>
      AttendanceRecord(
        localId: localId,
        type: type ?? this.type,
        capturedAt: capturedAt,
        position: position,
        accuracyMeters: accuracyMeters,
        distanceFromSiteMeters: distanceFromSiteMeters,
        withinGeofence: withinGeofence,
        isLate: isLate,
        photoPath: photoPath ?? this.photoPath,
        syncStatus: syncStatus ?? this.syncStatus,
        remoteId: remoteId ?? this.remoteId,
        failureReason: failureReason ?? this.failureReason,
        attempts: attempts ?? this.attempts,
      );

  Map<String, Object?> toDbMap() => <String, Object?>{
        'local_id': localId,
        'type': type.value,
        'captured_at': capturedAt.toUtc().millisecondsSinceEpoch,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': accuracyMeters,
        'distance_meters': distanceFromSiteMeters,
        'within_geofence': withinGeofence ? 1 : 0,
        'is_late': isLate ? 1 : 0,
        'photo_path': photoPath,
        'sync_status': syncStatus.value,
        'remote_id': remoteId,
        'failure_reason': failureReason,
        'attempts': attempts,
      };

  /// JSON body of `POST /attendance`; the photo travels as a separate part.
  Map<String, Object?> toRequestPayload() => <String, Object?>{
        'client_reference': localId,
        'type': type.value,
        'captured_at': capturedAt.toUtc().toIso8601String(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': accuracyMeters,
        'distance_meters': distanceFromSiteMeters,
        'within_geofence': withinGeofence,
        'is_late': isLate,
      };

  @override
  String toString() =>
      'AttendanceRecord($localId, ${type.value}, ${syncStatus.value})';
}
