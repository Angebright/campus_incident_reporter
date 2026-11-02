import 'package:campus_incident_reporter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders the CampusComfort shell', (tester) async {
    await tester.pumpWidget(const CampusComfortApp());

    expect(find.text('CampusComfort'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
