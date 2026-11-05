import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import '../../providers/staff_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../student/profile_screen.dart';
import 'staff_reports_screen.dart';

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavigationProvider>().reset();
      context.read<StaffProvider>().streamIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navigation.currentIndex,
        children: const [
          StaffReportsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigation.currentIndex,
        onTap: navigation.setIndex,
        items: const [
          AppBottomNavItem(icon: Icons.receipt_long_outlined, label: 'Reports'),
          AppBottomNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}
