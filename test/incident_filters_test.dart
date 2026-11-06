import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/utils/incident_filters.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final incidents = [
    buildIncident(
      id: 'a',
      title: 'Broken tap',
      status: IncidentStatus.submitted,
      category: IncidentCategory.water,
      description: 'A tap is leaking in the hostel.',
    ),
    buildIncident(
      id: 'b',
      title: 'Power outage',
      status: IncidentStatus.inProgress,
      category: IncidentCategory.electricity,
      description: 'No electricity in the science block.',
    ),
    buildIncident(
      id: 'c',
      title: 'Loose railing',
      status: IncidentStatus.resolved,
      category: IncidentCategory.safety,
      description: 'A railing is loose on the stairs.',
    ),
  ];

  test('returns everything with no filters', () {
    expect(applyIncidentFilters(incidents), hasLength(3));
  });

  test('filters by status', () {
    final result = applyIncidentFilters(
      incidents,
      status: IncidentStatus.inProgress,
    );
    expect(result, hasLength(1));
    expect(result.single.id, 'b');
  });

  test('filters by category', () {
    final result = applyIncidentFilters(
      incidents,
      category: IncidentCategory.safety,
    );
    expect(result.single.id, 'c');
  });

  test('search is case-insensitive across title and description', () {
    expect(applyIncidentFilters(incidents, searchQuery: 'POWER'), hasLength(1));
    expect(
      applyIncidentFilters(incidents, searchQuery: 'electricity'),
      hasLength(1),
    );
  });

  test('combines search and status filters', () {
    final result = applyIncidentFilters(
      incidents,
      searchQuery: 'tap',
      status: IncidentStatus.resolved,
    );
    expect(result, isEmpty);
  });
}
