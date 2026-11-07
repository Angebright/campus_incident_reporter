import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import 'auth_scaffold.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoStudentEmail = 'student@campuscomfort.app';
  static const _demoStudentPassword = 'Campus123';
  static const _demoStaffEmail = 'staff@campuscomfort.app';
  static const _demoStaffPassword = 'Campus123';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthProvider>().signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _fillDemo({required String email, required String password}) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to report and track campus issues.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.error != null)
              AuthErrorBanner(message: provider.error!),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: provider.submitting ? null : _submit,
              child: provider.submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _fillDemo(
                      email: _demoStudentEmail,
                      password: _demoStudentPassword,
                    ),
                    child: const Text('Student demo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _fillDemo(
                      email: _demoStaffEmail,
                      password: _demoStaffPassword,
                    ),
                    child: const Text('Staff demo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
