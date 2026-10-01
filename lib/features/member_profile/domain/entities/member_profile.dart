import 'package:mycampus/core/domain/entities/user_role.dart';

enum UniversityType { public, private, international }

extension UniversityTypeLabel on UniversityType {
  /// The `en.json` key for this type's display name.
  String get labelKey {
    switch (this) {
      case UniversityType.public:
        return 'university.typePublic';
      case UniversityType.private:
        return 'university.typePrivate';
      case UniversityType.international:
        return 'university.typeInternational';
    }
  }
}

enum MemberStatus { none, pending, approved, rejected }

extension MemberStatusLabel on MemberStatus {
  /// The `en.json` key for this status' display name.
  String get labelKey => switch (this) {
    MemberStatus.none => 'status.notEnrolled',
    MemberStatus.pending => 'status.pending',
    MemberStatus.approved => 'status.approved',
    MemberStatus.rejected => 'status.rejected',
  };
}

/// The campus a student or faculty member belongs to. Same fields the
/// super admin's profile shows for the university they *own* — a member
/// has no `type`/`establishedAt` to manage, but reads them fine.
class MemberCampus {
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
  final UniversityType? type;
  final String? city;
  final String? country;
  final String? logoUrl;
}

/// Role-specific enrollment details. Exactly one of [student] / [teacher]
/// is non-null, matching [MemberProfile.role] — the page renders a
/// different "Academic" section per role, but both come from the same
/// fetch so the profile tab is a single call either way.
class StudentEnrollment {
  const new({
    required this.studentId,
    required this.department,
    required this.batch,
  });

  final String studentId;
  final String department;
  final String batch;
}

class FacultyAppointment {
  const new({
    required this.teacherId,
    required this.department,
    required this.designation,
  });

  final String teacherId;
  final String department;
  final String designation;
}

/// The signed-in student or faculty member's account, campus and
/// enrollment. Deliberately one entity for both roles: the profile screen
/// is structurally identical, so splitting it would duplicate the page
/// without changing what it shows.
class MemberProfile {
  const new({
    required this.id,
    required this.email,
    required this.verified,
    required this.role,
    required this.status,
    this.name,
    this.phone,
    this.memberSince,
    this.avatarUrl,
    this.campus,
    this.student,
    this.teacher,
  });

  final String id;
  final String email;

  /// Whether they've confirmed their email via the verification link.
  final bool verified;

  final UserRole role;

  /// Where they stand with the campus — `none` before they send a join
  /// request, then pending → approved/rejected.
  final MemberStatus status;
  final String? name;
  final String? phone;
  final DateTime? memberSince;
  final String? avatarUrl;
  final MemberCampus? campus;
  final StudentEnrollment? student;
  final FacultyAppointment? teacher;

  /// [name] if set, otherwise the part of [email] before the `@`.
  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return email.split('@').first;
  }

  /// Up to two initials from [displayName], for the avatar fallback.
  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The `en.json` key for this person's role badge.
  String get roleLabelKey => role.labelKey;
}
