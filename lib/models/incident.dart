import '../utils/firestore_time.dart';
import 'incident_category.dart';
import 'incident_status.dart';
import 'status_entry.dart';

/// A campus incident report stored in the `incidents` collection.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.reportedBy,
    required this.reportedByName,
    required this.statusHistory,
    required this.createdAt,
    this.location,
    this.imageUrl,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final IncidentStatus status;
  final String reportedBy;
  final String reportedByName;
  final List<StatusEntry> statusHistory;
  final DateTime createdAt;
  final String? location;
  final String? imageUrl;
  final DateTime? updatedAt;

  bool get isResolved => status == IncidentStatus.resolved;

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final rawHistory = map['statusHistory'] as List<dynamic>? ?? const [];
    return Incident(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: IncidentCategory.fromKey(map['category'] as String?),
      status: IncidentStatus.fromName(map['status'] as String?),
      reportedBy: (map['reportedBy'] as String?) ?? '',
      reportedByName: (map['reportedByName'] as String?) ?? '',
      statusHistory: rawHistory
          .whereType<Map<String, dynamic>>()
          .map(StatusEntry.fromMap)
          .toList(),
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      location: map['location'] as String?,
      imageUrl: map['imageUrl'] as String?,
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  /// Payload used when creating a new document.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.key,
      'status': status.name,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'statusHistory': statusHistory.map((entry) => entry.toMap()).toList(),
      'createdAt': createdAt,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentCategory? category,
    IncidentStatus? status,
    String? reportedBy,
    String? reportedByName,
    List<StatusEntry>? statusHistory,
    DateTime? createdAt,
    String? location,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
