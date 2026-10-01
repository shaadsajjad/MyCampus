/// DTO for an approved `users` record as seen by the member-directory tab,
/// plus whichever of its expanded `students`/`teachers` profile fields
/// apply — matches PocketBase's wire format exactly (raw `role` string, not
/// the parsed domain enum). Parsing that into the domain-level
/// `DirectoryMember` is the repository's job, not this model's.
class DirectoryMemberModel {
  const DirectoryMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.created,
    this.avatarUrl,
    this.roleId,
    this.department,
    this.subInfo,
  });

  final String id;
  final String name;
  final String email;

  /// Raw PocketBase value — `student` or `faculty`.
  final String role;
  final String created;
  final String? avatarUrl;
  final String? roleId;
  final String? department;
  final String? subInfo;
}
