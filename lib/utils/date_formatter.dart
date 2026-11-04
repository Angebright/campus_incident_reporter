import 'package:intl/intl.dart';

/// Short "time ago" label used on cards, falling back to a date for old items.
String formatRelativeTime(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(date);

  if (difference.isNegative) {
    return DateFormat('MMM d, y').format(date);
  }
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return DateFormat('MMM d, y').format(date);
}

/// Full timestamp for detail views and the status timeline.
String formatFullDateTime(DateTime date) {
  return DateFormat('MMM d, y • h:mm a').format(date);
}

String formatShortDate(DateTime date) {
  return DateFormat('MMM d, y').format(date);
}
