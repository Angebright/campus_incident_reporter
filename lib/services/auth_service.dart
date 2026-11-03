import '../models/app_user.dart';

/// Thrown when authentication fails with a user-presentable message.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication boundary. Screens/providers depend on this interface, not
/// Firebase directly, so tests can inject fakes.
abstract class AuthService {
  /// Emits the signed-in user's uid, or null when signed out.
  Stream<String?> authStateChanges();

  /// Loads `users/{uid}`; returns null if the profile does not exist.
  Future<AppUser?> fetchProfile(String uid);

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
