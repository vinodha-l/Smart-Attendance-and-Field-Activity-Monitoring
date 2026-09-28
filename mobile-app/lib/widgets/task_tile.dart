import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/models/duty_task.dart';
import '../l10n/app_localizations.dart';
import 'status_chip.dart';

/// One assigned duty task of the day.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final DutyTask task;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final (String label, Color color) = switch (task.status) {
      TaskStatus.upcoming => (l10n.taskStatusUpcoming, AppTheme.brand),
      TaskStatus.inProgress => (l10n.taskStatusInProgress, AppTheme.warning),
      TaskStatus.completed => (l10n.taskStatusCompleted, AppTheme.positive),
    };

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.assignment_outlined)),
        title: Text(task.title),
        subtitle: Text(
          '${task.locationName}\n'
          '${formatClock(context, task.startsAt)} - '
          '${formatClock(context, task.endsAt)}',
        ),
        isThreeLine: true,
        trailing: StatusChip(label: label, color: color),
      ),
    );
  }
}
