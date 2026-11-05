import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/staff_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firebase_incident_service.dart';
import 'services/incident_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusComfortApp());
}

class CampusComfortApp extends StatelessWidget {
  const CampusComfortApp({
    super.key,
    this.authService,
    this.incidentService,
  });

  /// Injectable for tests; defaults to the Firebase implementation.
  final AuthService? authService;
  final IncidentService? incidentService;

  @override
  Widget build(BuildContext context) {
    final resolvedAuth = authService ?? FirebaseAuthService();
    final resolvedIncidents = incidentService ?? FirebaseIncidentService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(resolvedAuth)),
        ChangeNotifierProvider(
          create: (_) => IncidentProvider(resolvedIncidents),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffProvider(resolvedIncidents),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'CampusComfort',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
