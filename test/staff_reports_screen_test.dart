import 'package:campus_incident_reporter/providers/auth_provider.dart';
import 'package:campus_incident_reporter/providers/staff_provider.dart';
import 'package:campus_incident_reporter/screens/staff/staff_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';
import 'helpers.dart';

Widget _wrap(StaffProvider staff) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(FakeAuthService())),
      ChangeNotifierProvider<StaffProvider>.value(value: staff),
    ],
    child: const MaterialApp(home: Scaffold(body: StaffReportsScreen())),
  );
}

void main() {
  testWidgets('staff list renders incidents with the reporter name',
      (tester) async {
    final service = FakeIncidentService(
      incidents: [buildIncident(title: 'Leaking tap', reportedByName: 'Alice')],
    );
    final staff = StaffProvider(service)..streamIncidents();

    await tester.pumpWidget(_wrap(staff));
    await tester.pump();
    await tester.pump();

    expect(find.text('Leaking tap'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });

  testWidgets('staff list shows an empty state when there are no reports',
      (tester) async {
    final staff = StaffProvider(FakeIncidentService())..streamIncidents();

    await tester.pumpWidget(_wrap(staff));
    await tester.pump();
    await tester.pump();

    expect(find.text('No reports found'), findsOneWidget);
  });
}
