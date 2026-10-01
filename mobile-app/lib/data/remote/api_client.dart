import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/json.dart';
import '../models/attendance_record.dart';
import '../models/auth_session.dart';
import '../models/duty_task.dart';
import '../models/field_activity.dart';
import '../models/face_verification_result.dart';
import 'api_exception.dart';

/// Thin HTTP wrapper around the FastAPI backend.
///
/// Only the endpoints the field application needs are implemented. The
/// expected request and response shapes are documented in the project README.
class ApiClient {
  ApiClient(
      {String? baseUrl,
      http.Client? client,
      this.timeout = AppConfig.apiTimeout})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// `POST /auth/login` - exchanges the employee id and password for a token.
  Future<AuthSession> login({
    required String employeeId,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/auth/login',
      body: <String, Object?>{'employee_id': employeeId, 'password': password},
    );
    final AuthSession session = AuthSession.fromLoginResponse(json);
    if (session.token.isEmpty) {
      throw const ApiException(
        ApiFailure.unexpected,
        message: 'Login response did not contain an access token.',
      );
    }
    return session;
  }

  /// `POST /auth/otp/request` asks the backend SMS provider for an OTP.
  /// The backend must rate-limit this endpoint and never return the OTP value.
  Future<void> requestOtp({required String phoneNumber}) async {
    await _postJson(
      '/auth/otp/request',
      body: <String, Object?>{'phone_number': phoneNumber.trim()},
    );
  }

  /// `POST /auth/otp/verify` validates an SMS OTP and returns a session.
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final Map<String, dynamic> json = await _postJson(
      '/auth/otp/verify',
      body: <String, Object?>{
        'phone_number': phoneNumber.trim(),
        'otp': otp.trim(),
      },
    );
    final AuthSession session = AuthSession.fromLoginResponse(json);
    if (session.token.isEmpty) {
      throw const ApiException(
        ApiFailure.unexpected,
        message: 'OTP verification did not return an access token.',
      );
    }
    return session;
  }

  /// `POST /api/face/verify` - verifies an attendance selfie.
  ///
  /// This endpoint's multipart fields are confirmed by Student 4. It does not
  /// add an authorization header because the final authentication format has
  /// not been agreed by the backend team.
  Future<FaceVerificationResult> verifyFace({
    required String workerId,
    required String imagePath,
  }) async {
    final Map<String, dynamic> json = await _postMultipart(
      '/face/verify',
      fields: <String, String>{'worker_id': workerId},
      files: <http.MultipartFile>[
        await http.MultipartFile.fromPath('image', imagePath),
      ],
      token: '',
    );
    return FaceVerificationResult.fromJson(json);
  }

  /// `GET /tasks/today` - duty tasks assigned for the current day.
  Future<List<DutyTask>> fetchTodayTasks(String token) async {
    final Map<String, dynamic> json =
        await _getJson('/tasks/today', token: token);
    final Object? items = json['tasks'] ?? json['items'] ?? json['data'];
    if (items is List) {
      return asMapList(items).map(DutyTask.fromJson).toList();
    }
    // The endpoint may also answer with a bare list.
    return json.isEmpty ? const <DutyTask>[] : const <DutyTask>[];
  }

  /// `GET /attendance` - attendance history of the signed in worker.
  Future<List<AttendanceRecord>> fetchAttendance({
    required String token,
    required String employeeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final Map<String, dynamic> json = await _getJson(
      '/attendance',
      token: token,
      query: <String, String>{
        'employee_id': employeeId,
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    final Object? items = json['records'] ?? json['items'] ?? json['data'];
    return asMapList(items).map(AttendanceRecord.fromJson).toList();
  }

  /// `POST /attendance` - uploads one punch and its photo.
  ///
  /// Returns the identifier assigned by the server.
  Future<String> uploadAttendance({
    required AttendanceRecord record,
    required String token,
  }) async {
    final String? photoPath = record.photoPath;
    final Map<String, dynamic> json = await _postMultipart(
      '/attendance',
      fields: _stringFields(record.toRequestPayload()),
      files: photoPath == null
          ? const <http.MultipartFile>[]
          : <http.MultipartFile>[
              await http.MultipartFile.fromPath('photo', photoPath),
            ],
      token: token,
    );
    return asString(json['id'] ?? json['remote_id'] ?? json['reference']);
  }

  /// `POST /activities` - uploads a field activity report with its evidence.
  Future<String> uploadActivity({
    required FieldActivity activity,
    required String token,
  }) async {
    final List<http.MultipartFile> files = <http.MultipartFile>[];
    for (final String path in activity.photoPaths) {
      files.add(await http.MultipartFile.fromPath('evidence', path));
    }
    final Map<String, dynamic> json = await _postMultipart(
      '/activities',
      fields: _stringFields(activity.toRequestPayload()),
      files: files,
      token: token,
    );
    return asString(json['id'] ?? json['remote_id'] ?? json['reference']);
  }

  void close() => _client.close();

  Future<Map<String, dynamic>> _getJson(
    String path, {
    required String token,
    Map<String, String>? query,
  }) async {
    final Uri uri =
        query == null ? _uri(path) : _uri(path).replace(queryParameters: query);
    final http.Response response = await _withErrors(
      () => _client.get(uri, headers: _jsonHeaders(token)),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path, {
    required Map<String, Object?> body,
    String? token,
  }) async {
    final http.Response response = await _withErrors(
      () => _client.post(
        _uri(path),
        headers: _jsonHeaders(token),
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    required String token,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', _uri(path))
          ..headers.addAll(_authHeaders(token))
          ..fields.addAll(fields)
          ..files.addAll(files);
    final http.StreamedResponse streamed = await _withErrors(request.send);
    final http.Response response = await _decodeStream(streamed);
    return _decode(response);
  }

  /// Converts transport failures into an [ApiException].
  Future<T> _withErrors<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        ApiFailure.timeout,
        message: 'The server did not respond in time.',
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(ApiFailure.network, message: error.toString());
    }
  }

  Future<http.Response> _decodeStream(http.StreamedResponse streamed) async {
    final http.Response response = await http.Response.fromStream(streamed);
    return response;
  }

  /// Turns a response into JSON, or raises an [ApiException].
  Map<String, dynamic> _decode(http.Response response) {
    final int status = response.statusCode;
    final String body = utf8.decode(response.bodyBytes, allowMalformed: true);

    if (status >= 200 && status < 300) {
      if (body.trim().isEmpty) return <String, dynamic>{};
      try {
        final Object? decoded = jsonDecode(body);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        return <String, dynamic>{'data': decoded};
      } on FormatException {
        throw const ApiException(
          ApiFailure.unexpected,
          message: 'The server response was not valid JSON.',
        );
      }
    }

    throw ApiException(
      _failureFor(status),
      statusCode: status,
      message: _messageFrom(body, status),
    );
  }
}

ApiFailure _failureFor(int status) {
  if (status == 401 || status == 403) return ApiFailure.unauthorized;
  if (status >= 500) return ApiFailure.server;
  if (status >= 400) return ApiFailure.badRequest;
  return ApiFailure.unexpected;
}

/// Reads the FastAPI `detail` field so the UI can show it when useful.
String _messageFrom(String body, int status) {
  final Map<String, dynamic> json = asJson(body);
  final Object? detail = json['detail'] ?? json['message'] ?? json['error'];
  if (detail is String && detail.isNotEmpty) return detail;
  if (detail is List && detail.isNotEmpty) return detail.first.toString();
  return 'HTTP $status';
}

Map<String, String> _jsonHeaders(String? token) => <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
    };

Map<String, String> _authHeaders(String? token) => <String, String>{
      'accept': 'application/json',
      if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
    };

Map<String, String> _stringFields(Map<String, Object?> payload) {
  final Map<String, String> fields = <String, String>{};
  payload.forEach((String key, Object? value) {
    if (value != null) fields[key] = value.toString();
  });
  return fields;
}
