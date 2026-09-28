import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';
import 'status_chip.dart';

/// Shows the GPS fix, its accuracy and the geofence result.
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.reading,
    required this.locating,
    required this.failure,
    required this.radiusMeters,
    required this.siteName,
    this.distanceMeters,
  });

  final LocationReading? reading;
  final bool locating;
  final LocationFailure? failure;
  final int radiusMeters;
  final String siteName;

  /// Distance between the fix and the centre of the assigned area.
  final double? distanceMeters;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (locating) {
      return Card(
        child: ListTile(
          leading: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(l10n.statusGettingGps),
        ),
      );
    }

    if (failure != null) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: const Icon(Icons.location_disabled),
          title: Text(locationFailureMessage(l10n, failure)),
        ),
      );
    }

    final LocationReading? reading = this.reading;
    if (reading == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.location_searching),
          title: Text(l10n.gpsUnavailable),
        ),
      );
    }

    final bool inside = radiusMeters <= 0 ||
        (distanceMeters != null && distanceMeters! <= radiusMeters);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.gps_fixed),
            title: Text(l10n.gpsCoordinates),
            subtitle: Text(
              l10n.gpsReading(
                formatCoordinate(reading.point.latitude),
                formatCoordinate(reading.point.longitude),
                reading.accuracyMeters.round().toString(),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              inside ? Icons.verified_user : Icons.report_problem,
              color:
                  inside ? Colors.green : Theme.of(context).colorScheme.error,
            ),
            title: Text(
              inside && distanceMeters != null
                  ? l10n.insideGeofence(
                      siteName,
                      formatDistance(distanceMeters!),
                    )
                  : distanceMeters == null
                      ? siteName
                      : l10n.outsideGeofence(formatDistance(distanceMeters!)),
            ),
            trailing: StatusChip(
              label: formatDistance(distanceMeters ?? 0),
              color:
                  inside ? Colors.green : Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// User facing message for a GPS problem.
String locationFailureMessage(
  AppLocalizations l10n,
  LocationFailure? failure,
) =>
    switch (failure) {
      null => l10n.gpsUnavailable,
      LocationFailure.permissionDenied ||
      LocationFailure.permissionDeniedForever =>
        l10n.locationPermissionDenied,
      LocationFailure.serviceDisabled => l10n.locationServiceDisabled,
      _ => l10n.gpsUnavailable,
    };
