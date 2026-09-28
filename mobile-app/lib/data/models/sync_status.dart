/// Upload state of a record that was created on the device.
enum SyncStatus {
  pending('pending'),
  synced('synced'),
  failed('failed');

  const SyncStatus(this.value);

  /// Value stored in the local database and sent to the backend.
  final String value;

  static SyncStatus fromValue(Object? value) {
    final String text = value?.toString() ?? '';
    return SyncStatus.values.firstWhere(
      (SyncStatus status) => status.value == text,
      orElse: () => SyncStatus.pending,
    );
  }

  /// `true` while the record still has to reach the server.
  bool get needsUpload => this != SyncStatus.synced;
}
