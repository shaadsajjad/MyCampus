/// Which role a member of the university holds.
///
/// Deliberately this feature's own enum rather than a reuse of
/// `join_requests`' `MemberRole` or `core/domain`'s `UserRole`: the directory
/// answers a different question. It only ever lists the two member roles —
/// a super admin is not a directory entry, they're the owner of it — and
/// "faculty" is the word this screen uses, so it shouldn't depend on
/// whichever spelling another feature happened to pick.
enum DirectoryRole { student, faculty }

/// A student or faculty member as listed in the super admin's member
/// directory.
///
/// A read-only view of the same `users` record the join-requests tab manages,
/// but scoped to *approved* members only — the point of this screen is "who
/// is on campus", not "who is waiting to be let in", so pending and
/// rejected accounts are filtered out by the repository. Joining the role's
/// `students`/`teachers` profile gives the identity fields those two
/// collections own; everything else comes off `users`.
class DirectoryMember {
  const DirectoryMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
    this.roleId,
    this.department,
    this.subInfo,
  });

  /// The `users` record id.
  final String id;
  final String name;
  final String email;
  final DirectoryRole role;

  /// When the account was created — the closest thing to "when they joined",
  /// since PocketBase doesn't separately timestamp a status transition from
  /// pending to approved.
  final DateTime joinedAt;
  final String? avatarUrl;

  /// `studentId` or `teacherId` from the role's profile collection.
  final String? roleId;
  final String? department;

  /// Batch for a student, designation for faculty — whichever applies to
  /// [role]. Null when the profile hasn't filled it in.
  final String? subInfo;
}
