import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

/// Applies the shared search / status / category filters used on both the
/// student "My Reports" list and the staff reports list.
List<Incident> applyIncidentFilters(
  List<Incident> incidents, {
  String searchQuery = '',
  IncidentStatus? status,
  IncidentCategory? category,
}) {
  final query = searchQuery.trim().toLowerCase();

  return incidents.where((incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;
    if (query.isEmpty) return true;

    final haystack = [
      incident.title,
      incident.description,
      incident.location ?? '',
      incident.reportedByName,
    ].join(' ').toLowerCase();

    return haystack.contains(query);
  }).toList();
}
