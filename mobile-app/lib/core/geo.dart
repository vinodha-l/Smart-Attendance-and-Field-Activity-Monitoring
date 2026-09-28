import 'dart:math' as math;

import '../data/models/geo_point.dart';

const double _earthRadiusMeters = 6371008.8;

/// Great circle distance between [from] and [to] expressed in meters.
///
/// The haversine formula is used, so the calculation is pure Dart and can be
/// unit tested without any platform plugin.
double distanceInMeters(GeoPoint from, GeoPoint to) {
  final double lat1 = _radians(from.latitude);
  final double lat2 = _radians(to.latitude);
  final double dLat = lat2 - lat1;
  final double dLon = _radians(to.longitude - from.longitude);
  final double sinLat = math.sin(dLat / 2);
  final double sinLon = math.sin(dLon / 2);
  final double a =
      sinLat * sinLat + math.cos(lat1) * math.cos(lat2) * sinLon * sinLon;
  return 2 * _earthRadiusMeters * math.asin(math.min(1, math.sqrt(a)));
}

double _radians(double degrees) => degrees * math.pi / 180;
