import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../data/models/attendance_record.dart';
import '../data/models/duty_task.dart';
import '../data/models/worker.dart';
import '../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';
import '../widgets/heading.dart';
import '../widgets/task_tile.dart';
import 'activity_screen.dart';
import 'attendance_screen.dart';

/// Home tab: attendance state for today and the assigned schedule.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The controllers are read here because AppScope.of() needs a context that
    // is already mounted.
    if (_initialised) return;
    _initialised = true;
    final deps = AppScope.of(context);
    deps.attendanceController.refreshToday();
    deps.taskController.load();
    deps.syncController.refreshPending();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Worker? worker = deps.sessionController.worker;

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        deps.attendanceController,
        deps.taskController,
        deps.sessionController,
      ]),
      builder: (BuildContext context, Widget? child) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            _greeting(l10n, worker),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            <String?>[worker?.designation, worker?.assignedArea]
                .whereType<String>()
                .where((String value) => value.isNotEmpty)
                .join('  •  '),
          ),
          const SizedBox(height: 16),
          _AttendanceCard(
            checkIn: deps.attendanceController.todayCheckIn,
            checkOut: deps.attendanceController.todayCheckOut,
          ),
          const SizedBox(height: 12),
          _attendanceAction(l10n),
          Heading(l10n.todaysSchedule),
          if (deps.taskController.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (deps.taskController.tasks.isEmpty)
            EmptyState(icon: Icons.event_available, message: l10n.noTasks)
          else
            ...deps.taskController.tasks.map(
              (DutyTask task) => TaskTile(task: task),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const ActivityScreen(),
              ),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(l10n.reportFieldActivityAction),
          ),
        ],
      ),
    );
  }

  Widget _attendanceAction(AppLocalizations l10n) {
    final deps = AppScope.of(context);

    if (!deps.attendanceController.hasCheckedIn) {
      return FilledButton.icon(
        onPressed: () => _openAttendance(AttendanceType.checkIn),
        icon: const Icon(Icons.fingerprint),
        label: Text(l10n.markAttendanceAction),
      );
    }
    if (deps.attendanceController.isOnDuty) {
      return FilledButton.icon(
        onPressed: () => _openAttendance(AttendanceType.checkOut),
        icon: const Icon(Icons.logout),
        label: Text(l10n.markCheckOutAction),
      );
    }
    return FilledButton.icon(
      onPressed: null,
      icon: const Icon(Icons.check_circle),
      label: Text(l10n.attendanceCompleted),
    );
  }

  Future<void> _openAttendance(AttendanceType type) async {
    final deps = AppScope.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AttendanceScreen(type: type),
      ),
    );
    await deps.attendanceController.refreshToday();
  }

  String _greeting(AppLocalizations l10n, Worker? worker) {
    final String name = worker?.firstName ?? '';
    final int hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning(name);
    if (hour < 17) return l10n.greetingAfternoon(name);
    return l10n.greetingEvening(name);
  }
}

/// Attendance summary for the current day.
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.checkIn, required this.checkOut});

  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool onDuty = checkIn != null && checkOut == null;

    final Color color = checkIn == null
        ? AppTheme.warning
        : onDuty
            ? Colors.orange
            : AppTheme.positive;
    final IconData icon = checkIn == null
        ? Icons.schedule
        : onDuty
            ? Icons.timelapse
            : Icons.check_circle;

    final String title = checkIn == null
        ? l10n.attendancePending
        : onDuty
            ? l10n.checkedInAt(formatClock(context, checkIn!.capturedAt))
            : l10n.attendanceCompleted;

    final String subtitle = checkIn == null
        ? l10n.dutyStartsAt('09:00 AM')
        : checkOut == null
            ? l10n.locationVerifiedForToday
            : l10n.checkedOutAt(formatClock(context, checkOut!.capturedAt));

    return Card(
      child: ListTile(
        leading: Icon(icon, size: 34, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
