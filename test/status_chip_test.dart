import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatusChip renders the label for each status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusChip(status: IncidentStatus.submitted),
              StatusChip(status: IncidentStatus.inProgress),
              StatusChip(status: IncidentStatus.resolved),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });
}
