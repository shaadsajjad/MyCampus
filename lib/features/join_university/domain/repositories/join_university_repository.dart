import 'package:mycampus/features/join_university/domain/entities/university_preview.dart';

/// Lets a signed-in student/teacher scan (or type) the campus QR's join
/// code, preview which university it belongs to, and send a join request —
/// role-agnostic: both roles use the exact same two calls against their own
/// `users` record.
abstract class JoinUniversityRepository {
  /// Looks up the `universities` record behind [code] (the id encoded in
  /// the QR) so the user can confirm before joining.
  Future<UniversityPreview> lookupUniversity(String code);

  /// Sets the signed-in user's own `university` relation to [universityId]
  /// and flips their `status` back to pending. Allowed by `users.
  /// updateRule`'s self-update clause — no super admin action needed at
  /// this step, only when they later review the request.
  Future<void> requestToJoin(String universityId);
}
