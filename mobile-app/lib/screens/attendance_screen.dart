import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../core/formatters.dart';
import '../data/models/attendance_record.dart';
import '../data/models/worker.dart';
import '../l10n/app_localizations.dart';
import '../widgets/evidence_thumbnail.dart';
import '../widgets/location_card.dart';
import '../state/attendance_controller.dart';

/// Captures a check-in or a check-out with GPS, photo and a geofence check.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.type});

  final AttendanceType type;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final deps = AppScope.of(context);
    deps.attendanceController.resetCapture();
    deps.attendanceController.acquireLocation();
  }

  Future<void> _capturePhoto() async {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? path = await deps.attendanceController.capturePhoto();
    if (!mounted) return;
    if (path == null && deps.attendanceController.cameraFailure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cameraPermissionDenied)));
    }
  }

  Future<void> _verifyFace() async {
    await AppScope.of(context).attendanceController.verifyFace();
  }

  Future<void> _submit() async {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AttendanceRecord? record = await deps.attendanceController.submit(
      widget.type,
    );
    if (!mounted || record == null) return;

    final String body = !record.withinGeofence
        ? l10n.outsideGeofence(formatDistance(record.distanceFromSiteMeters))
        : deps.syncController.isOnline
            ? l10n.attendanceMarkedBody
            : l10n.attendanceQueuedBody;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: Icon(
          record.withinGeofence ? Icons.verified : Icons.report_problem,
          size: 48,
          color: record.withinGeofence ? Colors.green : Colors.orange,
        ),
        title: Text(l10n.attendanceMarkedTitle),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.doneAction),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Worker? worker = deps.sessionController.worker;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.markAttendanceTitle)),
      body: ListenableBuilder(
        listenable: deps.attendanceController,
        builder: (BuildContext context, Widget? child) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              widget.type == AttendanceType.checkIn
                  ? l10n.attendanceTypeCheckIn
                  : l10n.attendanceTypeCheckOut,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LocationCard(
              reading: deps.attendanceController.reading,
              locating: deps.attendanceController.locating,
              failure: deps.attendanceController.locationFailure,
              radiusMeters: worker?.geofenceRadiusMeters ?? 0,
              siteName: worker?.assignedArea ?? '',
              distanceMeters: deps.attendanceController.distanceFromSiteMeters,
            ),
            if (deps.attendanceController.locationFailure != null)
              OutlinedButton.icon(
                onPressed: deps.attendanceController.acquireLocation,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryAction),
              ),
            const SizedBox(height: 12),
            _PhotoCard(
              photoPath: deps.attendanceController.photoPath,
              capturing: deps.attendanceController.capturing,
              onCapture: _capturePhoto,
            ),
            const SizedBox(height: 12),
            _VerificationCard(
              controller: deps.attendanceController,
              onVerify: _verifyFace,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: deps.attendanceController.canSubmit ? _submit : null,
              child: Text(l10n.submitAttendanceAction),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.photoOnlyModeNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Evidence photo section of the attendance flow.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photoPath,
    required this.capturing,
    required this.onCapture,
  });

  final String? photoPath;
  final bool capturing;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? photoPath = this.photoPath;

    return Card(
      child: Column(
        children: <Widget>[
          if (photoPath == null)
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.photoNotCaptured),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  EvidenceThumbnail(path: photoPath),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.photoCaptured)),
                ],
              ),
            ),
          const Divider(height: 1),
          if (capturing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            )
          else
            TextButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                photoPath == null ? l10n.photographAction : l10n.retryAction,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows the actual result of Student 4's face-verification request.
class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.controller,
    required this.onVerify,
  });

  final AttendanceController controller;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FaceVerificationState state = controller.faceVerificationState;
    final bool hasPhoto = controller.photoPath != null;
    final _FaceMessage message = _faceMessage(context, state);
    final bool canVerify = hasPhoto && state != FaceVerificationState.verifying;

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              message.icon,
              color: message.color,
            ),
            title: Text(l10n.faceVerificationTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(hasPhoto
                    ? message.text
                    : l10n.faceVerificationCaptureFirst),
                if (controller.faceVerificationResult != null)
                  Text(
                    l10n.faceSimilarity(
                      controller.faceVerificationResult!.similarity
                          .toStringAsFixed(2),
                    ),
                  ),
              ],
            ),
          ),
          if (state == FaceVerificationState.verifying)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LinearProgressIndicator(),
            ),
          const Divider(height: 1),
          TextButton.icon(
            onPressed: canVerify ? onVerify : null,
            icon: Icon(
              state == FaceVerificationState.verifying
                  ? Icons.hourglass_top
                  : Icons.face_retouching_natural,
            ),
            label: Text(
              state == FaceVerificationState.verifying
                  ? l10n.faceVerificationLoading
                  : l10n.verifyFaceAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceMessage {
  const _FaceMessage(this.text, this.icon, this.color);

  final String text;
  final IconData icon;
  final Color color;
}

_FaceMessage _faceMessage(BuildContext context, FaceVerificationState state) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Color pending = Theme.of(context).colorScheme.outline;
  final Color error = Theme.of(context).colorScheme.error;
  return switch (state) {
    FaceVerificationState.idle => _FaceMessage(
        l10n.faceVerificationReady,
        Icons.face_retouching_natural_outlined,
        pending,
      ),
    FaceVerificationState.verifying => _FaceMessage(
        l10n.faceVerificationLoading,
        Icons.hourglass_top,
        pending,
      ),
    FaceVerificationState.verified => _FaceMessage(
        l10n.faceVerifiedSuccess,
        Icons.verified,
        Colors.green,
      ),
    FaceVerificationState.rejected => _FaceMessage(
        l10n.faceRejected,
        Icons.cancel_outlined,
        error,
      ),
    FaceVerificationState.noFace => _FaceMessage(
        l10n.faceNoFace,
        Icons.face_retouching_off,
        error,
      ),
    FaceVerificationState.multipleFaces => _FaceMessage(
        l10n.faceMultipleFaces,
        Icons.groups_outlined,
        error,
      ),
    FaceVerificationState.workerNotRegistered => _FaceMessage(
        l10n.faceWorkerNotRegistered,
        Icons.person_off_outlined,
        error,
      ),
    FaceVerificationState.invalidImage => _FaceMessage(
        l10n.faceInvalidImage,
        Icons.broken_image_outlined,
        error,
      ),
    FaceVerificationState.processingError => _FaceMessage(
        l10n.faceProcessingError,
        Icons.error_outline,
        error,
      ),
    FaceVerificationState.networkError => _FaceMessage(
        l10n.faceNetworkError,
        Icons.cloud_off_outlined,
        error,
      ),
    FaceVerificationState.apiError => _FaceMessage(
        l10n.faceApiError,
        Icons.error_outline,
        error,
      ),
  };
}
