import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/models/attendance_record.dart';
import '../data/models/sync_status.dart';
import '../l10n/app_localizations.dart';
import '../l10n/model_labels.dart';
import '../widgets/empty_state.dart';
import '../widgets/heading.dart';
import '../widgets/sync_status_chip.dart';
import 'sync_queue_screen.dart';

/// History tab: attendance punches stored on the device.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final deps = AppScope.of(context);
    deps.attendanceController.loadHistory();
    deps.syncController.refreshPending();
  }

  Future<void> _refresh() async {
    final deps = AppScope.of(context);
    await deps.syncController.syncNow();
    await deps.attendanceController.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        deps.attendanceController,
        deps.syncController,
      ]),
      builder: (BuildContext context, Widget? child) {
        final List<AttendanceRecord> records =
            deps.attendanceController.history;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (deps.syncController.pendingCount > 0)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: Text(
                      l10n.pendingSyncBanner(
                        deps.syncController.pendingCount.toString(),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const SyncQueueScreen(),
                      ),
                    ),
                  ),
                ),
              Heading(l10n.attendanceHistory),
              if (deps.attendanceController.historyLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!deps.attendanceController.historyLoading && records.isEmpty)
                EmptyState(
                    icon: Icons.history_toggle_off, message: l10n.noHistory)
              else
                ...records.map(
                  (AttendanceRecord record) => Card(
                    child: ListTile(
                      leading: Icon(
                        record.isCheckIn ? Icons.login : Icons.logout,
                        color: AppTheme.brand,
                      ),
                      title: Text(
                        '${attendanceTypeLabel(l10n, record.type)}  •  '
                        '${formatClock(context, record.capturedAt)}',
                      ),
                      subtitle: Text(formatDate(context, record.capturedAt)),
                      trailing: SyncStatusChip(
                        status: record.syncStatus,
                        isLate: record.isLate &&
                            record.syncStatus == SyncStatus.synced,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
