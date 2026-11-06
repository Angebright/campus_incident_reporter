import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/providers/navigation_provider.dart';
import 'package:campus_incident_reporter/providers/staff_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';
import 'helpers.dart';

void main() {
  group('NavigationProvider', () {
    test('setIndex updates and notifies only on change', () {
      final provider = NavigationProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.setIndex(2);
      expect(provider.currentIndex, 2);
      expect(notifications, 1);

      provider.setIndex(2);
      expect(notifications, 1);

      provider.reset();
      expect(provider.currentIndex, 0);
      expect(notifications, 2);
    });
  });

  group('StaffProvider', () {
    FakeIncidentService buildService() => FakeIncidentService(
          incidents: [
            buildIncident(id: 'a', status: IncidentStatus.submitted),
            buildIncident(id: 'b', status: IncidentStatus.resolved),
            buildIncident(id: 'c', status: IncidentStatus.inProgress),
          ],
        );

    test('streams incidents and computes status counts', () async {
      final provider = StaffProvider(buildService());
      provider.streamIncidents();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.loading, isFalse);
      expect(provider.totalCount, 3);
      expect(provider.submittedCount, 1);
      expect(provider.inProgressCount, 1);
      expect(provider.resolvedCount, 1);
    });

    test('filters by status', () async {
      final provider = StaffProvider(buildService());
      provider.streamIncidents();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      provider.setStatusFilter(IncidentStatus.resolved);
      expect(provider.filteredIncidents, hasLength(1));
      expect(provider.filteredIncidents.single.id, 'b');
    });

    test('updateStatus delegates and clears the updating flag', () async {
      final provider = StaffProvider(FakeIncidentService());

      final success = await provider.updateStatus(
        incidentId: 'x',
        newStatus: IncidentStatus.resolved,
        changedByName: 'Staff',
      );

      expect(success, isTrue);
      expect(provider.updating, isFalse);
    });
  });
}
