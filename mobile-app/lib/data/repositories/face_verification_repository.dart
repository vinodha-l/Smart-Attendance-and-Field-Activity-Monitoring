import '../models/face_verification_result.dart';
import '../remote/api_client.dart';

/// Boundary used by attendance to verify its existing selfie.
abstract class FaceVerificationRepository {
  Future<FaceVerificationResult> verify({
    required String workerId,
    required String imagePath,
  });
}

/// API-backed implementation of Student 4's confirmed contract.
class RemoteFaceVerificationRepository implements FaceVerificationRepository {
  RemoteFaceVerificationRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<FaceVerificationResult> verify({
    required String workerId,
    required String imagePath,
  }) =>
      _api.verifyFace(workerId: workerId, imagePath: imagePath);
}
