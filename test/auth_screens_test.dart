import 'package:campus_incident_reporter/providers/auth_provider.dart';
import 'package:campus_incident_reporter/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'fakes.dart';

void main() {
  testWidgets('login form shows validation errors for empty fields',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(FakeAuthService()),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.pump();
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
