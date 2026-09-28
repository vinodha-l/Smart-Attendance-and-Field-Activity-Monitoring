import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/models/pending_record.dart';
import '../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';

/// Lists records waiting to upload while the worker was offline.
class SyncQueueScreen extends StatefulWidget {
  const SyncQueueScreen({super.key});
  @override
  State<SyncQueueScreen> createState() => _SyncQueueScreenState();
}

class _SyncQueueScreenState extends State<SyncQueueScreen> {
  late Future<List<PendingRecord>> _records;
  @override
  void initState() {
    super.initState();
    _records = AppScope.of(context).syncController.pendingRecords();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(l10n.syncQueueTitle)),
        body: FutureBuilder<List<PendingRecord>>(
          future: _records,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final records = snapshot.data!;
            if (records.isEmpty) {
              return EmptyState(
                  icon: Icons.cloud_done_outlined,
                  message: l10n.syncQueueEmpty);
            }
            return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined),
                      title: Text(
                        record.attendanceType?.name ??
                            record.activityType?.name ??
                            '',
                      ),
                      subtitle: Text(record.capturedAt.toLocal().toString()));
                });
          },
        ));
  }
}
