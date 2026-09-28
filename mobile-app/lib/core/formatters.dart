import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _localeTag(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// Clock time such as `09:04 AM` (English) or `09:04 மு.ப` (Tamil).
String formatClock(BuildContext context, DateTime time) =>
    DateFormat.jm(_localeTag(context)).format(time.toLocal());

/// Calendar date in the active locale, for example `26 September 2026`.
String formatDate(BuildContext context, DateTime day) =>
    DateFormat.yMMMMd(_localeTag(context)).format(day.toLocal());

/// Date and time combined, used by the sync queue.
String formatDateTime(BuildContext context, DateTime time) =>
    '${formatDate(context, time)} • ${formatClock(context, time)}';

/// Short distance label, meters below one kilometer and kilometers above.
String formatDistance(double meters) => meters < 1000
    ? '${meters.round()} m'
    : '${(meters / 1000).toStringAsFixed(1)} km';

/// Five decimal places is roughly one meter of precision.
String formatCoordinate(double value) => value.toStringAsFixed(5);

/// `26 September 2026` style date for values coming from the backend.
String formatIsoDate(BuildContext context, String isoDate) {
  final DateTime? parsed = DateTime.tryParse(isoDate);
  return parsed == null ? isoDate : formatDate(context, parsed);
}
