import 'package:flutter/foundation.dart';

import '../data/models/field_activity.dart';
import '../data/repositories/activity_repository.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';

/// Drives the "report field activity" screen.
class ActivityController extends ChangeNotifier {
  ActivityController({
    required ActivityRepository repository,
    required LocationService locationService,
    required CameraService cameraService,
    this.onRecordQueued,
  })  : _repository = repository,
        _locationService = locationService,
        _cameraService = cameraService;

  final ActivityRepository _repository;
  final LocationService _locationService;
  final CameraService _cameraService;

  /// Called after a report is stored so the sync queue can be refreshed.
  final VoidCallback? onRecordQueued;

  ActivityType _type = ActivityType.streetSanitation;
  final List<String> _photoPaths = <String>[];
  LocationReading? _reading;
  bool _locating = false;
  LocationFailure? _locationFailure;
  bool _capturing = false;
  CameraFailure? _cameraFailure;
  bool _saving = false;

  ActivityType get type => _type;

  List<String> get photoPaths => List<String>.unmodifiable(_photoPaths);

  LocationReading? get reading => _reading;

  bool get locating => _locating;

  LocationFailure? get locationFailure => _locationFailure;

  bool get capturing => _capturing;

  CameraFailure? get cameraFailure => _cameraFailure;

  bool get saving => _saving;

  bool get hasEvidence => _photoPaths.isNotEmpty;

  void setType(ActivityType type) {
    if (_type == type) return;
    _type = type;
    notifyListeners();
  }

  Future<void> acquireLocation() async {
    _locating = true;
    _locationFailure = null;
    notifyListeners();
    try {
      _reading = await _locationService.currentReading();
    } on LocationException catch (error) {
      _locationFailure = error.failure;
    } finally {
      _locating = false;
      notifyListeners();
    }
  }

  /// Adds an evidence photo. Returns the path, or `null` when cancelled.
  Future<String?> addPhoto() async {
    _capturing = true;
    _cameraFailure = null;
    notifyListeners();
    try {
      final String? path = await _cameraService.capturePhoto();
      if (path != null) _photoPaths.add(path);
      return path;
    } on CameraException catch (error) {
      _cameraFailure = error.failure;
      return null;
    } finally {
      _capturing = false;
      notifyListeners();
    }
  }

  void removePhoto(String path) {
    _photoPaths.remove(path);
    notifyListeners();
  }

  /// Stores the report on the device.
  ///
  /// Returns the stored activity, or `null` when the evidence or the GPS fix
  /// is missing.
  Future<FieldActivity?> save({required String remarks}) async {
    final LocationReading? reading = _reading;
    if (reading == null || _photoPaths.isEmpty) return null;

    _saving = true;
    notifyListeners();
    try {
      final FieldActivity activity = await _repository.capture(
        type: _type,
        remarks: remarks,
        reading: reading,
        photoPaths: _photoPaths,
        capturedAt: DateTime.now(),
      );
      onRecordQueued?.call();
      return activity;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// Clears the form after a successful save.
  void reset() {
    _type = ActivityType.streetSanitation;
    _photoPaths.clear();
    _reading = null;
    _locationFailure = null;
    _cameraFailure = null;
    notifyListeners();
  }
}
