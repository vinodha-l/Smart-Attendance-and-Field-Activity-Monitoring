import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../core/geo.dart';
import '../data/models/attendance_record.dart';
import '../data/models/face_verification_result.dart';
import '../data/models/worker.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/face_verification_repository.dart';
import '../data/remote/api_exception.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';

/// Drives the "mark attendance" flow and the attendance history.
class AttendanceController extends ChangeNotifier {
  AttendanceController({
    required AttendanceRepository repository,
    required LocationService locationService,
    required CameraService cameraService,
    required Worker? Function() workerProvider,
    required FaceVerificationRepository faceVerificationRepository,
    this.onRecordQueued,
  })  : _repository = repository,
        _locationService = locationService,
        _cameraService = cameraService,
        _workerProvider = workerProvider,
        _faceVerificationRepository = faceVerificationRepository;

  final AttendanceRepository _repository;
  final LocationService _locationService;
  final CameraService _cameraService;
  final Worker? Function() _workerProvider;
  final FaceVerificationRepository _faceVerificationRepository;

  /// Called after a punch is stored so the sync queue can be refreshed.
  final VoidCallback? onRecordQueued;

  LocationReading? _reading;
  bool _locating = false;
  LocationFailure? _locationFailure;

  String? _photoPath;
  bool _capturing = false;
  CameraFailure? _cameraFailure;

  FaceVerificationState _faceVerificationState = FaceVerificationState.idle;
  FaceVerificationResult? _faceVerificationResult;
  ApiException? _faceVerificationFailure;

  bool _submitting = false;
  AttendanceRecord? _todayCheckIn;
  AttendanceRecord? _todayCheckOut;
  List<AttendanceRecord> _history = const <AttendanceRecord>[];
  bool _historyLoading = false;

  LocationReading? get reading => _reading;

  bool get locating => _locating;

  LocationFailure? get locationFailure => _locationFailure;

  String? get photoPath => _photoPath;

  bool get capturing => _capturing;

  CameraFailure? get cameraFailure => _cameraFailure;

  FaceVerificationState get faceVerificationState => _faceVerificationState;

  FaceVerificationResult? get faceVerificationResult => _faceVerificationResult;

  ApiException? get faceVerificationFailure => _faceVerificationFailure;

  bool get submitting => _submitting;

  AttendanceRecord? get todayCheckIn => _todayCheckIn;

  AttendanceRecord? get todayCheckOut => _todayCheckOut;

  /// `true` when the worker is on duty right now.
  bool get isOnDuty => _todayCheckIn != null && _todayCheckOut == null;

  bool get hasCheckedIn => _todayCheckIn != null;

  List<AttendanceRecord> get history => _history;

  bool get historyLoading => _historyLoading;

  /// Distance between the latest GPS fix and the assigned work site, if both
  /// are known.
  double? get distanceFromSiteMeters {
    final LocationReading? reading = _reading;
    final Worker? worker = _workerProvider();
    if (reading == null || worker == null || worker.geofenceRadiusMeters <= 0) {
      return null;
    }
    return distanceInMeters(reading.point, worker.siteCentre);
  }

  bool get canSubmit =>
      _reading != null && _photoPath != null && !_submitting && !_locating;

  Future<void> refreshToday() async {
    _todayCheckIn = await _repository.todayCheckIn();
    _todayCheckOut = await _repository.todayCheckOut();
    notifyListeners();
  }

  Future<void> loadHistory({int days = 30}) async {
    _historyLoading = true;
    notifyListeners();
    _history = await _repository.history(days: days);
    _historyLoading = false;
    notifyListeners();
  }

  /// Requests a fresh GPS fix for the attendance screen.
  Future<void> acquireLocation() async {
    _locating = true;
    _locationFailure = null;
    notifyListeners();
    try {
      _reading = await _locationService.currentReading(
        timeout: AppConfig.locationTimeout,
      );
    } on LocationException catch (error) {
      _locationFailure = error.failure;
      _reading = null;
    } finally {
      _locating = false;
      notifyListeners();
    }
  }

  /// Captures the attendance photo; `null` means the worker cancelled.
  Future<String?> capturePhoto() async {
    _capturing = true;
    _cameraFailure = null;
    notifyListeners();
    try {
      final String? path =
          await _cameraService.capturePhoto(useFrontCamera: true);
      if (path != null) {
        _photoPath = path;
        _faceVerificationState = FaceVerificationState.idle;
        _faceVerificationResult = null;
        _faceVerificationFailure = null;
      }
      return path;
    } on CameraException catch (error) {
      _cameraFailure = error.failure;
      return null;
    } finally {
      _capturing = false;
      notifyListeners();
    }
  }

  /// Verifies the already captured attendance selfie with Student 4's API.
  /// Attendance submission remains independent until its final API contract is
  /// agreed by the backend team.
  Future<void> verifyFace() async {
    final String? photoPath = _photoPath;
    final Worker? worker = _workerProvider();
    if (photoPath == null || worker == null || worker.employeeId.isEmpty) {
      return;
    }

    _faceVerificationState = FaceVerificationState.verifying;
    _faceVerificationResult = null;
    _faceVerificationFailure = null;
    notifyListeners();
    try {
      final FaceVerificationResult result =
          await _faceVerificationRepository.verify(
        workerId: worker.employeeId,
        imagePath: photoPath,
      );
      _faceVerificationResult = result;
      _faceVerificationState = FaceVerificationState.fromStatus(result.status);
    } on ApiException catch (error) {
      _faceVerificationFailure = error;
      _faceVerificationState = switch (error.failure) {
        ApiFailure.network ||
        ApiFailure.timeout =>
          FaceVerificationState.networkError,
        _ => FaceVerificationState.apiError,
      };
    } finally {
      notifyListeners();
    }
  }

  /// Stores the punch on the device. Returns `null` when the GPS fix or the
  /// photo is missing.
  Future<AttendanceRecord?> submit(AttendanceType type) async {
    final LocationReading? reading = _reading;
    final Worker? worker = _workerProvider();
    if (reading == null || worker == null) return null;

    _submitting = true;
    notifyListeners();
    try {
      final AttendanceRecord record = await _repository.capture(
        type: type,
        reading: reading,
        worker: worker,
        capturedAt: DateTime.now(),
        photoPath: _photoPath,
      );
      if (type == AttendanceType.checkIn) {
        _todayCheckIn = record;
      } else {
        _todayCheckOut = record;
      }
      onRecordQueued?.call();
      return record;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Clears the GPS fix and the photo, used when the screen is closed.
  void resetCapture() {
    _reading = null;
    _photoPath = null;
    _locationFailure = null;
    _cameraFailure = null;
    _faceVerificationState = FaceVerificationState.idle;
    _faceVerificationResult = null;
    _faceVerificationFailure = null;
    _locating = false;
    _capturing = false;
    notifyListeners();
  }
}

/// UI state for the confirmed face-verification outcomes.
enum FaceVerificationState {
  idle,
  verifying,
  verified,
  rejected,
  noFace,
  multipleFaces,
  workerNotRegistered,
  invalidImage,
  processingError,
  networkError,
  apiError;

  static FaceVerificationState fromStatus(FaceVerificationStatus status) =>
      switch (status) {
        FaceVerificationStatus.verified => FaceVerificationState.verified,
        FaceVerificationStatus.rejected => FaceVerificationState.rejected,
        FaceVerificationStatus.noFace => FaceVerificationState.noFace,
        FaceVerificationStatus.multipleFaces =>
          FaceVerificationState.multipleFaces,
        FaceVerificationStatus.workerNotRegistered =>
          FaceVerificationState.workerNotRegistered,
        FaceVerificationStatus.invalidImage =>
          FaceVerificationState.invalidImage,
        FaceVerificationStatus.processingError =>
          FaceVerificationState.processingError,
      };
}
