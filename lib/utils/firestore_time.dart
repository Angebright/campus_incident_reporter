import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore/JSON timestamp value into a [DateTime].
///
/// Handles [Timestamp], [DateTime], epoch millis, and ISO strings so models
/// stay tolerant of whatever the backend returns.
DateTime? parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}
