import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import 'sync_queue_screen.dart';

/// Worker profile, language settings and manual offline-queue sync.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final worker = deps.sessionController.worker;
    return ListenableBuilder(
      listenable: deps.syncController,
      builder: (context, child) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
              child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(worker?.name.isNotEmpty == true
                ? worker!.name
                : worker?.employeeId ?? ''),
            subtitle: Text(
                '${worker?.designation ?? ''}  •  ${worker?.assignedArea ?? ''}'),
          )),
          const SizedBox(height: 12),
          Card(
              child: ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l10n.profileSyncQueue),
            subtitle: Text(l10n.recordsPendingSync(
                deps.syncController.pendingCount.toString())),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const SyncQueueScreen())),
          )),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: deps.syncController.syncing
                ? null
                : deps.syncController.syncNow,
            icon: const Icon(Icons.cloud_sync_outlined),
            label: Text(l10n.profileSyncNow),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => deps.sessionController.signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOutAction),
          ),
        ],
      ),
    );
  }
}
