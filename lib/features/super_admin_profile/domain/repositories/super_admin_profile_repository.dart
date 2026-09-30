import 'package:mycampus/features/super_admin_profile/domain/entities/super_admin_profile.dart';

/// The contract the super admin's profile tab codes against;
/// [ProfileException] is the only failure type it needs to handle.
abstract class SuperAdminProfileRepository {
  /// The last-known profile from the persisted session — no network call,
  /// so the tab can render immediately while [refresh] runs.
  SuperAdminProfile? get cachedProfile;

  /// Re-fetches the account (and its university) from the server.
  Future<SuperAdminProfile> refresh();

  Future<SuperAdminProfile> updateName(String name);

  /// Emails a password-reset link to [email].
  Future<void> requestPasswordReset(String email);

  Future<void> logout();
}
