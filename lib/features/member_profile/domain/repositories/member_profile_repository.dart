import 'package:mycampus/features/member_profile/domain/entities/member_profile.dart';

/// The contract the student/faculty profile screen codes against.
/// [MemberProfileException] is the only failure type it needs to know
/// about — everything else (PocketBase, HTTP, ...) is a data-layer detail
/// behind this interface.
///
/// Mirrors `SuperAdminProfileRepository` (same `cachedProfile` / `refresh`
/// / `updateName` / `requestPasswordReset` / `logout` shape) so the two
/// profile screens stay recognisably the same, with the member version
/// adding the enrollment read that only students/faculty have.
abstract class MemberProfileRepository {
  /// The persisted session's profile, read synchronously so the tab
  /// renders immediately with no spinner. Null when signed out.
  MemberProfile? get cachedProfile;

  /// Re-read the profile from the server. Also re-saves the fresh auth
  /// record into the shared store, so other features' cached reads stay
  /// current.
  Future<MemberProfile> refresh();

  Future<MemberProfile> updateName(String name);

  Future<void> requestPasswordReset(String email);

  Future<void> logout();
}
