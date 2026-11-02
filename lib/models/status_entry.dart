import '../utils/firestore_time.dart';
import 'incident_status.dart';

/// One entry in an incident's status history.
class StatusEntry {
  const StatusEntry({
    required this.status,
    required this.changedBy,
    required this.timestamp,
  });

  final IncidentStatus status;
  final String changedBy;
  final DateTime timestamp;

  factory StatusEntry.fromMap(Map<String, dynamic> map) {
    return StatusEntry(
      status: IncidentStatus.fromName(map['status'] as String?),
      changedBy: (map['changedBy'] as String?) ?? '',
      timestamp: parseTimestamp(map['timestamp']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'changedBy': changedBy,
      'timestamp': timestamp,
    };
  }
}
