import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/models/status_entry.dart';
import 'package:campus_incident_reporter/models/user_role.dart';

Incident buildIncident({
  String id = 'i1',
  String title = 'Broken tap',
  String description = 'A tap in the hostel is leaking badly.',
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
  String reportedBy = 'student-1',
  String reportedByName = 'Alice',
  String? location = 'Hostel',
  DateTime? createdAt,
}) {
  final timestamp = createdAt ?? DateTime(2026, 11, 4, 9);
  return Incident(
    id: id,
    title: title,
    description: description,
    category: category,
    status: status,
    reportedBy: reportedBy,
    reportedByName: reportedByName,
    statusHistory: [
      StatusEntry(
        status: status,
        changedBy: reportedByName,
        timestamp: timestamp,
      ),
    ],
    createdAt: timestamp,
    location: location,
  );
}

AppUser buildUser({
  String uid = 'student-1',
  String name = 'Alice Student',
  String email = 'alice@campuscomfort.app',
  UserRole role = UserRole.student,
  String? department = 'Computer Science',
}) {
  return AppUser(
    uid: uid,
    name: name,
    email: email,
    role: role,
    createdAt: DateTime(2026, 11, 2, 8),
    department: department,
  );
}
