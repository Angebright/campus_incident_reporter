import '../models/incident.dart';
import '../models/incident_status.dart';

/// Data boundary for incidents. Screens/providers depend on this interface so
/// tests can inject fakes.
abstract class IncidentService {
  /// Streams the signed-in student's own reports (newest first).
  Stream<List<Incident>> watchMyIncidents(String uid);

  /// Streams every incident for staff review (newest first).
  Stream<List<Incident>> streamIncidents();

  Future<void> createIncident(Incident incident);

  /// Appends a status-history entry and updates the incident's status.
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String changedByName,
  });
}
