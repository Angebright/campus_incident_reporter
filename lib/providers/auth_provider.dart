import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/auth_messages.dart';

/// Holds the authenticated profile and drives the auth state of the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _listen();
  }

  final AuthService _authService;
  StreamSubscription<String?>? _subscription;
  Timer? _errorTimer;

  AppUser? _user;
  bool _initializing = true;
  bool _submitting = false;
  String? _error;

  AppUser? get user => _user;
  bool get initializing => _initializing;
  bool get submitting => _submitting;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  bool get isStaff => _user?.isStaff ?? false;

  void _listen() {
    _subscription = _authService.authStateChanges().listen((uid) async {
      if (uid == null) {
        _user = null;
        _initializing = false;
        notifyListeners();
        return;
      }
      try {
        _user = await _authService.fetchProfile(uid);
      } catch (error) {
        _showError(authErrorMessage(error));
        _user = null;
      } finally {
        _initializing = false;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setSubmitting(true);
    try {
      _user = await _authService.signIn(email: email, password: password);
      _clearError();
      return true;
    } catch (error) {
      _showError(authErrorMessage(error));
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {
    _setSubmitting(true);
    try {
      _user = await _authService.registerStudent(
        name: name,
        email: email,
        password: password,
        department: department,
      );
      _clearError();
      return true;
    } catch (error) {
      _showError(authErrorMessage(error));
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setSubmitting(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _clearError();
      return true;
    } catch (error) {
      _showError(authErrorMessage(error));
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorTimer?.cancel();
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _showError(String message) {
    _errorTimer?.cancel();
    _error = message;
    notifyListeners();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (_error == null) return;
      _error = null;
      notifyListeners();
    });
  }

  void _clearError() {
    _errorTimer?.cancel();
    _error = null;
  }

  void _setSubmitting(bool value) {
    _submitting = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
