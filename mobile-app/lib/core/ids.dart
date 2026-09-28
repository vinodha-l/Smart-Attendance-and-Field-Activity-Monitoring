import 'dart:math';

final Random _random = Random();

/// Identifier for a record that is created on the device before it is synced.
///
/// The server keeps this value in the `client_reference` field so duplicate
/// uploads can be ignored.
String newLocalId(String prefix) {
  final int micros = DateTime.now().toUtc().microsecondsSinceEpoch;
  return '$prefix-$micros-${_random.nextInt(1 << 20)}';
}
