/// The access role a person can onboard into MyCampus as.
enum UserRole { superAdmin, faculty, student }

extension UserRoleLabel on UserRole {
  /// The `en.json` key for this role's display name.
  String get labelKey {
    switch (this) {
      case UserRole.superAdmin:
        return 'roles.superAdmin';
      case UserRole.faculty:
        return 'roles.faculty';
      case UserRole.student:
        return 'roles.student';
    }
  }
}
