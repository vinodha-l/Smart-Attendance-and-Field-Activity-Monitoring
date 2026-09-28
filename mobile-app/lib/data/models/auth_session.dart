import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../../core/json.dart';
import 'worker.dart';

/// Login token together with the worker profile cached on the device.
@immutable
class AuthSession {
  const AuthSession({
    required this.token,
    required this.expiresAt,
    required this.worker,
  });

  /// Reads a session from the response of `POST /auth/login`.
  factory AuthSession.fromLoginResponse(Map<String, dynamic> json) {
    final DateTime? expiresAt = asDateTime(json['expires_at']);
    final int expiresInSeconds = asInt(json['expires_in']);
    return AuthSession(
      token: asString(json['access_token'] ?? json['token']),
      expiresAt: expiresAt ??
          DateTime.now().add(
            expiresInSeconds > 0
                ? Duration(seconds: expiresInSeconds)
                : AppConfig.sessionLifetime,
          ),
      worker: Worker.fromJson(
        asMap(json['worker'] ?? json['user'] ?? json['profile']),
      ),
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: asString(json['token']),
        expiresAt: asDateTime(json['expires_at']) ?? DateTime.now(),
        worker: Worker.fromJson(asMap(json['worker'])),
      );

  final String token;
  final DateTime expiresAt;
  final Worker worker;

  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  bool get isValid => token.isNotEmpty && !isExpired;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
        'worker': worker.toJson(),
      };
}
