import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/models/duty_task.dart';
import '../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';
import '../widgets/heading.dart';
import '../widgets/task_tile.dart';

/// Tasks tab: duty tasks assigned for the current day.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    AppScope.of(context).taskController.load();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: deps.taskController,
      builder: (BuildContext context, Widget? child) => RefreshIndicator(
        onRefresh: deps.taskController.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (deps.taskController.fromCache &&
                deps.taskController.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.offlineBanner,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Heading(l10n.assignedForToday),
            if (deps.taskController.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!deps.taskController.loading &&
                deps.taskController.tasks.isEmpty)
              EmptyState(icon: Icons.event_available, message: l10n.noTasks)
            else
              ...deps.taskController.tasks.map(
                (DutyTask task) => TaskTile(task: task),
              ),
          ],
        ),
      ),
    );
  }
}
