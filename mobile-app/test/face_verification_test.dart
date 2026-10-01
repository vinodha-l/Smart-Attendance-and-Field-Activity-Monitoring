import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_field_monitoring/data/local/memory_local_store.dart';
import 'package:smart_field_monitoring/data/models/face_verification_result.dart';
import 'package:smart_field_monitoring/data/models/geo_point.dart';
import 'package:smart_field_monitoring/data/models/worker.dart';
import 'package:smart_field_monitoring/data/remote/api_exception.dart';
import 'package:smart_field_monitoring/data/repositories/attendance_repository.dart';
import 'package:smart_field_monitoring/data/repositories/face_verification_repository.dart';
import 'package:smart_field_monitoring/services/fake_services.dart';
import 'package:smart_field_monitoring/state/attendance_controller.dart';

void main() {
  const List<FaceVerificationStatus> statuses = FaceVerificationStatus.values;

  test('parses every confirmed face verification response status', () {
    for (final FaceVerificationStatus status in statuses) {
      final FaceVerificationResult result = FaceVerificationResult.fromJson(
        <String, dynamic>{
          'worker_id': 'W001',
          'status': status.value,
          'verified': status == FaceVerificationStatus.verified,
          'similarity': 0.82,
          'message': 'Backend message',
        },
      );
      expect(result.workerId, 'W001');
      expect(result.status, status);
      expect(result.verified, status == FaceVerificationStatus.verified);
      expect(result.similarity, 0.82);
    }
  });

  test('maps every confirmed face status to its controller state', () {
    expect(FaceVerificationState.fromStatus(FaceVerificationStatus.verified),
        FaceVerificationState.verified);
    expect(FaceVerificationState.fromStatus(FaceVerificationStatus.rejected),
        FaceVerificationState.rejected);
    expect(FaceVerificationState.fromStatus(FaceVerificationStatus.noFace),
        FaceVerificationState.noFace);
    expect(
      FaceVerificationState.fromStatus(FaceVerificationStatus.multipleFaces),
      FaceVerificationState.multipleFaces,
    );
    expect(
      FaceVerificationState.fromStatus(
          FaceVerificationStatus.workerNotRegistered),
      FaceVerificationState.workerNotRegistered,
    );
    expect(
      FaceVerificationState.fromStatus(FaceVerificationStatus.invalidImage),
      FaceVerificationState.invalidImage,
    );
    expect(
      FaceVerificationState.fromStatus(FaceVerificationStatus.processingError),
      FaceVerificationState.processingError,
    );
  });

  test('reports verifying while the face API request is pending', () async {
    final Completer<FaceVerificationResult> response = Completer();
    final AttendanceController controller = _controller(
      _FakeFaceRepository((_, __) => response.future),
    );
    await controller.capturePhoto();

    final Future<void> verification = controller.verifyFace();
    expect(controller.faceVerificationState, FaceVerificationState.verifying);

    response.complete(_result(FaceVerificationStatus.verified));
    await verification;
    expect(controller.faceVerificationState, FaceVerificationState.verified);
  });

  test('reports network/API failures without changing attendance capture',
      () async {
    final AttendanceController controller = _controller(
      _FakeFaceRepository((_, __) => Future<FaceVerificationResult>.error(
          const ApiException(ApiFailure.network))),
    );
    await controller.capturePhoto();

    await controller.verifyFace();

    expect(
        controller.faceVerificationState, FaceVerificationState.networkError);
    expect(controller.faceVerificationFailure?.failure, ApiFailure.network);
    expect(controller.photoPath, isNotNull);
  });

  test('reports non-network API failures separately', () async {
    final AttendanceController controller = _controller(
      _FakeFaceRepository(
        (_, __) => Future<FaceVerificationResult>.error(
          const ApiException(ApiFailure.server),
        ),
      ),
    );
    await controller.capturePhoto();

    await controller.verifyFace();

    expect(controller.faceVerificationState, FaceVerificationState.apiError);
  });
}

AttendanceController _controller(FaceVerificationRepository faceRepository) =>
    AttendanceController(
      repository: AttendanceRepository(store: MemoryLocalStore()),
      locationService: FixedLocationService(),
      cameraService: FakeCameraService(),
      workerProvider: () => const Worker(
        employeeId: 'W001',
        name: 'Test Worker',
        designation: 'Worker',
        assignedArea: 'Ward 1',
        mobileNumber: '',
        siteCentre: GeoPoint(latitude: 0, longitude: 0),
        geofenceRadiusMeters: 100,
      ),
      faceVerificationRepository: faceRepository,
    );

FaceVerificationResult _result(FaceVerificationStatus status) =>
    FaceVerificationResult(
      workerId: 'W001',
      status: status,
      verified: status == FaceVerificationStatus.verified,
      similarity: .82,
      message: 'Backend message',
    );

class _FakeFaceRepository implements FaceVerificationRepository {
  _FakeFaceRepository(this._handler);

  final Future<FaceVerificationResult> Function(
      String workerId, String imagePath) _handler;

  @override
  Future<FaceVerificationResult> verify({
    required String workerId,
    required String imagePath,
  }) =>
      _handler(workerId, imagePath);
}
