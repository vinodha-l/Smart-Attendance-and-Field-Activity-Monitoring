import 'package:flutter/foundation.dart';

import '../../core/json.dart';

/// Statuses returned by Student 4's confirmed face-verification API.
enum FaceVerificationStatus {
  verified('VERIFIED'),
  rejected('REJECTED'),
  noFace('NO_FACE'),
  multipleFaces('MULTIPLE_FACES'),
  workerNotRegistered('WORKER_NOT_REGISTERED'),
  invalidImage('INVALID_IMAGE'),
  processingError('PROCESSING_ERROR');

  const FaceVerificationStatus(this.value);

  final String value;

  static FaceVerificationStatus fromValue(Object? value) =>
      FaceVerificationStatus.values.firstWhere(
        (FaceVerificationStatus status) => status.value == value?.toString(),
        // The confirmed API has no unknown status. Treat an unexpected value
        // as a temporary server-processing issue instead of accepting it.
        orElse: () => FaceVerificationStatus.processingError,
      );
}

/// Exact response payload of `POST /api/face/verify`.
@immutable
class FaceVerificationResult {
  const FaceVerificationResult({
    required this.workerId,
    required this.status,
    required this.verified,
    required this.similarity,
    required this.message,
  });

  factory FaceVerificationResult.fromJson(Map<String, dynamic> json) =>
      FaceVerificationResult(
        workerId: asString(json['worker_id']),
        status: FaceVerificationStatus.fromValue(json['status']),
        verified: asBool(json['verified']),
        similarity: asDouble(json['similarity']),
        message: asString(json['message']),
      );

  final String workerId;
  final FaceVerificationStatus status;
  final bool verified;
  final double similarity;
  final String message;
}
