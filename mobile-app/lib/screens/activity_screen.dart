import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/models/field_activity.dart';
import '../l10n/app_localizations.dart';
import '../l10n/model_labels.dart';
import '../state/activity_controller.dart';
import '../widgets/evidence_thumbnail.dart';
import '../widgets/location_card.dart';

/// Reports a completed field activity with GPS and evidence photos.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final TextEditingController _remarks = TextEditingController();
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final deps = AppScope.of(context);
    deps.activityController.reset();
    deps.activityController.acquireLocation();
  }

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? path = await deps.activityController.addPhoto();
    if (!mounted) return;
    if (path == null && deps.activityController.cameraFailure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cameraPermissionDenied)));
    }
  }

  Future<void> _save() async {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!deps.activityController.hasEvidence) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.evidenceRequired)));
      return;
    }

    final FieldActivity? activity = await deps.activityController.save(
      remarks: _remarks.text,
    );
    if (!mounted) return;

    if (activity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.activitySaveFailed)));
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deps.syncController.isOnline
              ? l10n.activitySavedAndSynced
              : l10n.activitySavedLocally,
        ),
      ),
    );
    deps.activityController.reset();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ActivityController controller = deps.activityController;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportActivityTitle)),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            DropdownButtonFormField<ActivityType>(
              initialValue: controller.type,
              decoration: InputDecoration(labelText: l10n.activityTypeLabel),
              items: ActivityType.values
                  .map(
                    (ActivityType type) => DropdownMenuItem<ActivityType>(
                      value: type,
                      child: Text(activityTypeLabel(l10n, type)),
                    ),
                  )
                  .toList(),
              onChanged: (ActivityType? value) {
                if (value != null) controller.setType(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarks,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.remarksLabel,
                hintText: l10n.remarksHint,
              ),
            ),
            const SizedBox(height: 16),
            LocationCard(
              reading: controller.reading,
              locating: controller.locating,
              failure: controller.locationFailure,
              radiusMeters: 0,
              siteName: deps.sessionController.worker?.assignedArea ?? '',
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(
                      l10n.evidencePhotoCount(
                        controller.photoPaths.length.toString(),
                      ),
                    ),
                  ),
                  if (controller.photoPaths.isNotEmpty)
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.photoPaths.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (BuildContext context, int index) => Stack(
                          children: <Widget>[
                            EvidenceThumbnail(
                              path: controller.photoPaths[index],
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                iconSize: 18,
                                onPressed: () => controller.removePhoto(
                                  controller.photoPaths[index],
                                ),
                                icon: const Icon(Icons.cancel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                  if (controller.capturing)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    )
                  else
                    TextButton.icon(
                      onPressed: _addPhoto,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(l10n.evidencePhotoAction),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.saveActivityAction),
            ),
          ],
        ),
      ),
    );
  }
}
