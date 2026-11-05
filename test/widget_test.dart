import 'package:campus_incident_reporter/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('shows the login screen when signed out', (tester) async {
    await tester.pumpWidget(
      CampusComfortApp(
        authService: FakeAuthService(),
        incidentService: FakeIncidentService(),
      ),
    );

    // Let the auth stream emit null and the gate rebuild out of loading.
    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
