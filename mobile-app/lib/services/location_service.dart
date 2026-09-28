import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../core/app_config.dart';
import '../data/models/geo_point.dart';

/// One GPS fix taken by the device.
class LocationReading {
  const LocationReading({
    required this.point,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final GeoPoint point;

  /// Estimated horizontal accuracy in meters.
  final double accuracyMeters;
  final DateTime capturedAt;
}

/// Reason why a GPS fix could not be produced.
enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unavailable,

  /// The platform has no location plugin (for example the web demo build).
  unsupported,
}

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException(${failure.name})';
}

/// Reads the current position of the device.
abstract class LocationService {
  /// Throws a [LocationException] when no fix can be obtained.
  Future<LocationReading> currentReading({Duration timeout});
}

/// Production implementation, backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationReading> currentReading({
    Duration timeout = AppConfig.locationTimeout,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationFailure.permissionDenied);
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return LocationReading(
        point: GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        accuracyMeters: position.accuracy,
        capturedAt: position.timestamp,
      );
    } on TimeoutException {
      throw const LocationException(LocationFailure.timeout);
    } on LocationServiceDisabledException {
      throw const LocationException(LocationFailure.serviceDisabled);
    } on MissingPluginException {
      throw const LocationException(LocationFailure.unsupported);
    } catch (_) {
      throw const LocationException(LocationFailure.unavailable);
    }
  }
}
