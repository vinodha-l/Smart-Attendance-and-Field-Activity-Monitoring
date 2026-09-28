import 'package:flutter/foundation.dart';

import '../../core/json.dart';
import 'geo_point.dart';

/// The field worker signed in on this device.
@immutable
class Worker {
  const Worker({
    required this.employeeId,
    required this.name,
    required this.designation,
    required this.assignedArea,
    required this.mobileNumber,
    required this.siteCentre,
    required this.geofenceRadiusMeters,
    this.joinedOn,
  });

  /// Builds a worker from the `worker` object returned by `POST /auth/login`.
  factory Worker.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> geofence = asMap(
      json['geofence'] ?? json['assigned_site'],
    );
    return Worker(
      employeeId: asString(json['employee_id'] ?? json['employeeId']),
      name: asString(json['name']),
      designation: asString(json['designation']),
      assignedArea: asString(json['assigned_area'] ?? json['assignedArea']),
      mobileNumber: asString(json['mobile_number'] ?? json['mobileNumber']),
      siteCentre: GeoPoint(
        latitude: asDouble(geofence['latitude'] ?? json['site_latitude']),
        longitude: asDouble(geofence['longitude'] ?? json['site_longitude']),
      ),
      geofenceRadiusMeters: asInt(
        geofence['radius_meters'] ?? json['geofence_radius_meters'],
        fallback: 150,
      ),
      joinedOn: asDateTime(json['joined_on'] ?? json['joinedOn']),
    );
  }

  factory Worker.fromJsonString(String raw) =>
      Worker.fromJson(asMap(asJson(raw)));

  final String employeeId;
  final String name;
  final String designation;
  final String assignedArea;
  final String mobileNumber;

  /// Centre of the geofence the worker has to stay inside while on duty.
  final GeoPoint siteCentre;
  final int geofenceRadiusMeters;
  final DateTime? joinedOn;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'employee_id': employeeId,
        'name': name,
        'designation': designation,
        'assigned_area': assignedArea,
        'mobile_number': mobileNumber,
        'geofence': <String, dynamic>{
          'latitude': siteCentre.latitude,
          'longitude': siteCentre.longitude,
          'radius_meters': geofenceRadiusMeters,
        },
        'joined_on': joinedOn?.toIso8601String(),
      };

  /// First name, used by the localized greeting.
  String get firstName => name.split(' ').first;
}
