import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/features/auth/domain/entities/account_status.dart';

/// The authenticated person — the app-level view of a PocketBase `users`
/// record, independent of how it was actually fetched/stored.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.name,
    this.universityId,
  });

  final String id;
  final String email;
  final UserRole role;
  final AccountStatus status;
  final String? name;
  final String? universityId;
}
