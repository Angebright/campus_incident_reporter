import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'report_incident_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavigationProvider>().reset();
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<IncidentProvider>().watchMyIncidents(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navigation.currentIndex,
        children: const [
          HomeScreen(),
          ReportIncidentScreen(),
          MyReportsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigation.currentIndex,
        onTap: navigation.setIndex,
        items: const [
          AppBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
          AppBottomNavItem(
            icon: Icons.add_circle_outline,
            label: 'Report',
            emphasized: true,
          ),
          AppBottomNavItem(icon: Icons.receipt_long_outlined, label: 'Reports'),
          AppBottomNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}
