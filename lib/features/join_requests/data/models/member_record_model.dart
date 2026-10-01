/// DTO for a `users` record as seen by the join-requests tab, plus
/// whichever of its expanded `students`/`teachers` profile fields apply —
/// matches PocketBase's wire format exactly (raw `role`/`status` strings,
/// not the parsed domain enums). Parsing those into the domain-level
/// `MemberRequest` is the repository's job, not this model's.
class MemberRecordModel {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.created,
    this.avatarUrl,
    this.roleId,
    this.department,
    this.subInfo,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String created;
  final String? avatarUrl;
  final String? roleId;
  final String? department;
  final String? subInfo;
}
