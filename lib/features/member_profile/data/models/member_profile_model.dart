import 'package:mycampus/features/member_profile/domain/entities/member_profile.dart'
    show MemberProfile;

/// DTOs for the signed-in `users` record plus its expanded relations —
/// PocketBase's wire format as-is (raw strings for dates and the
/// `university.type` select). Parsing into [MemberProfile] is the
/// repository's job, not the datasource's.
class MemberProfileModel {
  const new({
    required this.id,
    required this.email,
    required this.verified,
    required this.role,
    required this.status,
    this.name,
    this.phone,
    this.created,
    this.avatarUrl,
    this.campus,
    this.student,
    this.teacher,
  });

  final String id;
  final String email;
  final bool verified;

  /// Raw `users.role` select value.
  final String role;

  /// Raw `users.status` select value.
  final String status;
  final String? name;
  final String? phone;
  final String? created;
  final String? avatarUrl;
  final MemberCampusModel? campus;
  final MemberStudentModel? student;
  final MemberTeacherModel? teacher;
}

class MemberCampusModel {
  const new({
    required this.id,
    required this.name,
    required this.shortName,
    this.type,
    this.city,
    this.country,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final String? type;
  final String? city;
  final String? country;
  final String? logoUrl;
}

class MemberStudentModel {
  const new({
    required this.studentId,
    required this.department,
    required this.batch,
  });

  final String studentId;
  final String department;
  final String batch;
}

class MemberTeacherModel {
  const new({
    required this.teacherId,
    required this.department,
    required this.designation,
  });

  final String teacherId;
  final String department;
  final String designation;
}
