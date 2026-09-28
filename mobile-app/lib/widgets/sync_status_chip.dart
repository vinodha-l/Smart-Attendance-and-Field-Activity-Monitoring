import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/models/sync_status.dart';
import '../l10n/app_localizations.dart';
import 'status_chip.dart';

/// Chip that describes the upload state of a record.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key, required this.status, this.isLate = false});

  final SyncStatus status;

  /// Marks a late check-in that reached the server.
  final bool isLate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final (String label, Color color, IconData icon) = switch (status) {
      SyncStatus.synced => isLate
          ? (l10n.statusLate, AppTheme.warning, Icons.warning_amber)
          : (l10n.statusVerified, AppTheme.positive, Icons.check_circle),
      SyncStatus.pending => (
          l10n.statusPending,
          AppTheme.brand,
          Icons.cloud_upload_outlined,
        ),
      SyncStatus.failed => (
          l10n.statusFailed,
          Theme.of(context).colorScheme.error,
          Icons.error_outline,
        ),
    };

    return StatusChip(label: label, color: color, icon: icon);
  }
}
