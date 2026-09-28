import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Banner that reports the connection state and the upload queue size.
///
/// It stays hidden while the device is online and nothing is pending.
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: deps.syncController,
      builder: (BuildContext context, Widget? child) {
        final bool online = deps.syncController.isOnline;
        final int pending = deps.syncController.pendingCount;
        final bool syncing = deps.syncController.syncing;

        if (online && pending == 0 && !syncing) return const SizedBox.shrink();

        final Color color = online ? AppTheme.brand : AppTheme.warning;
        final String message = online
            ? pending > 0
                ? l10n.pendingSyncBanner('$pending')
                : l10n.onlineBanner
            : l10n.offlineBanner;

        return Material(
          color: color.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Icon(
                  online ? Icons.cloud_done_outlined : Icons.cloud_off,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (syncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (online && pending > 0)
                  TextButton(
                    onPressed: deps.syncController.syncNow,
                    child: Text(l10n.profileSyncNow),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
