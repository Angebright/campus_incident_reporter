import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';
import 'auth_service.dart';

/// Firebase-backed implementation of [AuthService].
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<String?> authStateChanges() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data() ?? const {});
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) {
      throw const AuthException('Sign-in failed. Please try again.');
    }
    final profile = await fetchProfile(uid);
    if (profile == null) {
      throw const AuthException('No profile found for this account.');
    }
    return profile;
  }

  @override
  Future<AppUser> registerStudent({
    required String name,
    required String email,
    required String password,
    String? department,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthException('Could not create the account.');
    }

    await user.updateDisplayName(name.trim());

    final profile = AppUser(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.student,
      createdAt: DateTime.now(),
      department: (department != null && department.trim().isEmpty)
          ? null
          : department?.trim(),
    );

    await _users.doc(user.uid).set(profile.toMap());
    return profile;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
