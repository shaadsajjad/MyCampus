enum MemberRole { student, faculty }

enum MemberStatus { pending, approved, rejected }

/// A university member — student or faculty — as shown on the super
/// admin's join-requests tab. Covers both the pending queue and the
/// archive (already approved/rejected) since both are just this same
/// `users` record filtered by [status].
class MemberRequest {
  const MemberRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.requestedAt,
    this.avatarUrl,
    this.roleId,
    this.department,
    this.subInfo,
  });

  final String id;
  final String name;
  final String email;
  final MemberRole role;
  final MemberStatus status;

  /// When this account was created — the closest thing to "when they
  /// requested access" (PocketBase doesn't separately timestamp status
  /// transitions).
  final DateTime requestedAt;
  final String? avatarUrl;

  /// `studentId` or `teacherId` from that role's profile collection.
  final String? roleId;
  final String? department;

  /// Batch/year for a student, designation for faculty — whichever
  /// applies to [role].
  final String? subInfo;
}
