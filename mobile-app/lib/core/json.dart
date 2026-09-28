/// Defensive converters for values that arrive from the FastAPI backend.
///
/// The app never trusts the shape of a remote payload, so every field is read
/// through one of these helpers instead of a raw cast.
library;

import 'dart:convert';

/// Decodes [raw] and returns it as a JSON object, or an empty map.
Map<String, dynamic> asJson(String raw) {
  try {
    final Object? decoded = jsonDecode(raw);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
}

String asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? asNullableString(Object? value) {
  if (value == null) return null;
  final String text = value.toString();
  return text.isEmpty ? null : text;
}

double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(asString(value)) ?? fallback;
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(asString(value)) ?? fallback;
}

bool asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = asString(value).toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

DateTime? asDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  final String text = asString(value);
  return text.isEmpty ? null : DateTime.tryParse(text);
}

Map<String, dynamic> asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

List<Map<String, dynamic>> asMapList(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Object>()
      .map(asMap)
      .where((Map<String, dynamic> entry) => entry.isNotEmpty)
      .toList();
}

List<String> asStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map(asString).where((String e) => e.isNotEmpty).toList();
}
