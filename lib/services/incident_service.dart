import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

/// Data boundary for incidents. Screens/providers depend on this interface so
/// tests can inject fakes.
abstract class IncidentService {
  /// Streams the signed-in student's own reports (newest first).
  Stream<List<Incident>> watchMyIncidents(String uid);

  /// Streams every incident for staff review (newest first).
  Stream<List<Incident>> streamIncidents();

  Future<void> createIncident(Incident incident);

  /// Updates the editable fields of a report the reporter still owns.
  Future<void> updateIncident({
    required String incidentId,
    required String title,
    required String description,
    required IncidentCategory category,
    String? location,
  });

  Future<void> deleteIncident(String incidentId);

  /// Appends a status-history entry and updates the incident's status.
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String changedByName,
  });
}
