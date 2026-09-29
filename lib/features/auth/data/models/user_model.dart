import 'package:pocketbase/pocketbase.dart';

/// DTO for a `users` record — basic account info only, matching
/// PocketBase's wire format exactly (raw `role`/`status` strings, not the
/// parsed domain enums). Role-specific data lives in `StudentProfileModel`
/// / `TeacherProfileModel`; converting this into the domain-level
/// `AuthUser` — including parsing `role`/`status` — is the repository's
/// job, not this model's.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.name,
    this.phone,
    this.universityId,
  });

  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      role: record.getStringValue('role'),
      status: record.getStringValue('status'),
      name: _emptyToNull(record.getStringValue('name')),
      phone: _emptyToNull(record.getStringValue('phone')),
      universityId: _emptyToNull(record.getStringValue('university')),
    );
  }

  final String id;
  final String email;
  final String role;
  final String status;
  final String? name;
  final String? phone;
  final String? universityId;

  static String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
