/// Reason why a backend call could not be completed.
enum ApiFailure {
  /// The device has no working connection to the server.
  network,

  /// The server did not answer within the configured request timeout.
  timeout,

  /// The token is missing, expired or rejected.
  unauthorized,

  /// The request itself was invalid.
  badRequest,

  /// The server answered with a 5xx status code.
  server,

  /// Anything else, for example a malformed response body.
  unexpected,
}

/// Error raised by `ApiClient`, translated into a user message by the UI.
class ApiException implements Exception {
  const ApiException(this.failure, {this.message = '', this.statusCode});

  final ApiFailure failure;
  final String message;
  final int? statusCode;

  /// Network and server problems are worth retrying, validation errors are not.
  bool get isRetryable =>
      failure == ApiFailure.network ||
      failure == ApiFailure.timeout ||
      failure == ApiFailure.server;

  @override
  String toString() =>
      'ApiException(${failure.name}, status: $statusCode, message: $message)';
}
