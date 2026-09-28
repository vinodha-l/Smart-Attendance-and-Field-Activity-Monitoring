import 'dart:async';

import '../data/models/geo_point.dart';
import 'camera_service.dart';
import 'connectivity_service.dart';
import 'location_service.dart';

/// Location service that always returns the same fix.
///
/// It keeps the widget tests independent from the platform location plugin and
/// allows a geofence result to be asserted deterministically.
class FixedLocationService implements LocationService {
  FixedLocationService({
    this.reading,
    this.failure,
    this.delay = Duration.zero,
  });

  /// Fix returned when [failure] is `null`.
  LocationReading? reading;

  /// When set, [currentReading] throws a [LocationException].
  LocationFailure? failure;
  Duration delay;

  int callCount = 0;

  /// Default fix: the centre of the demonstration work site in Ward 4.
  static const GeoPoint defaultPoint = GeoPoint(
    latitude: 12.9258,
    longitude: 80.0552,
  );

  @override
  Future<LocationReading> currentReading({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    callCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final LocationFailure? failure = this.failure;
    if (failure != null) {
      throw LocationException(failure);
    }
    return reading ??
        LocationReading(
          point: defaultPoint,
          accuracyMeters: 8,
          capturedAt: DateTime.now(),
        );
  }
}

/// Camera service that returns a fixed path without opening the camera.
class FakeCameraService implements CameraService {
  FakeCameraService(
      {this.photoPath = '/tmp/evidence.jpg', this.takesPhoto = true});

  /// Path returned when a photo is taken.
  String? photoPath;

  /// When `false` the capture is treated as cancelled and `null` is returned.
  bool takesPhoto;

  int captureCount = 0;

  @override
  Future<String?> capturePhoto({bool useFrontCamera = false}) async {
    captureCount++;
    if (!takesPhoto) return null;
    final String? path = photoPath;
    if (path == null) return null;
    return '$path.$captureCount';
  }
}

/// Connectivity service whose state can be changed from a test.
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({bool online = true}) : _online = online;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _online;

  set online(bool value) {
    if (_online == value) return;
    _online = value;
    _controller.add(value);
  }

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> get onlineChanges => _controller.stream;

  Future<void> dispose() => _controller.close();
}
