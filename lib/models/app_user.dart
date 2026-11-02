import '../utils/firestore_time.dart';
import 'user_role.dart';

/// A user profile stored in the `users` collection.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.department,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final String? department;

  bool get isStaff => role == UserRole.staff;
  bool get isStudent => role == UserRole.student;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: UserRole.fromName(map['role'] as String?),
      createdAt: parseTimestamp(map['createdAt']) ?? DateTime.now(),
      department: map['department'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'createdAt': createdAt,
      'department': department,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    DateTime? createdAt,
    String? department,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      department: department ?? this.department,
    );
  }
}
