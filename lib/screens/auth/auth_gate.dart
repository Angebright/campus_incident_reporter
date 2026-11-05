import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../staff/staff_shell.dart';
import '../student/student_shell.dart';

/// Routes the app based on auth state and role.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) {
      return const _AppLoading();
    }
    if (!auth.isSignedIn) {
      return const LoginScreen();
    }
    if (auth.isStaff) {
      return const StaffShell();
    }
    return const StudentShell();
  }
}

class _AppLoading extends StatelessWidget {
  const _AppLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_rounded, size: 56, color: AppColors.primary),
            SizedBox(height: 20),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
