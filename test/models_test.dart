import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Incident serialization', () {
    test('round-trips through toMap/fromMap', () {
      final incident = buildIncident(
        title: 'No water',
        category: IncidentCategory.water,
        location: 'Hostel',
      );

      final parsed = Incident.fromMap('doc-1', incident.toMap());

      expect(parsed.id, 'doc-1');
      expect(parsed.title, 'No water');
      expect(parsed.category, IncidentCategory.water);
      expect(parsed.status, IncidentStatus.submitted);
      expect(parsed.location, 'Hostel');
      expect(parsed.statusHistory, hasLength(1));
      expect(parsed.category.key, 'water');
      expect(parsed.status.name, 'submitted');
    });

    test('parses missing/unknown fields with safe defaults', () {
      final parsed = Incident.fromMap('doc-2', {
        'title': 'Unlabeled',
        'category': 'mystery',
        'status': 'nonsense',
      });

      expect(parsed.category, IncidentCategory.facilities);
      expect(parsed.status, IncidentStatus.submitted);
      expect(parsed.statusHistory, isEmpty);
    });
  });

  group('Enum parsing', () {
    test('IncidentStatus.fromName falls back to submitted', () {
      expect(IncidentStatus.fromName('resolved'), IncidentStatus.resolved);
      expect(IncidentStatus.fromName('garbage'), IncidentStatus.submitted);
      expect(IncidentStatus.fromName(null), IncidentStatus.submitted);
    });

    test('IncidentCategory.fromKey falls back to facilities', () {
      expect(IncidentCategory.fromKey('safety'), IncidentCategory.safety);
      expect(IncidentCategory.fromKey(null), IncidentCategory.facilities);
    });

    test('UserRole.fromName falls back to student', () {
      expect(UserRole.fromName('staff'), UserRole.staff);
      expect(UserRole.fromName('admin'), UserRole.student);
    });
  });

  group('AppUser', () {
    test('round-trips and exposes role helpers', () {
      final user = buildUser(role: UserRole.staff);
      final parsed = AppUser.fromMap(user.uid, user.toMap());

      expect(parsed.isStaff, isTrue);
      expect(parsed.isStudent, isFalse);
      expect(parsed.department, 'Computer Science');
      expect(parsed.toMap()['role'], 'staff');
    });
  });
}
