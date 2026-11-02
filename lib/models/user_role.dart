enum UserRole {
  student,
  staff;

  static UserRole fromName(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }

  String get label => switch (this) {
        UserRole.student => 'Student',
        UserRole.staff => 'Staff',
      };
}
