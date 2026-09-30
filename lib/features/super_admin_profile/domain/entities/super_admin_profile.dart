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

/// The institution a super admin owns, as shown on their profile.
class ProfileUniversity {
  const ProfileUniversity({
    required this.id,
    required this.name,
    required this.shortName,
    this.type,
    this.city,
    this.country,
    this.establishedAt,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final UniversityType? type;
  final String? city;
  final String? country;
  final DateTime? establishedAt;
  final String? logoUrl;
}

/// The signed-in super admin's own account plus the university they own.
class SuperAdminProfile {
  const SuperAdminProfile({
    required this.id,
    required this.email,
    required this.verified,
    this.name,
    this.memberSince,
    this.avatarUrl,
    this.university,
  });

  final String id;
  final String email;

  /// Whether they've confirmed their email via the verification link.
  final bool verified;
  final String? name;
  final DateTime? memberSince;
  final String? avatarUrl;
  final ProfileUniversity? university;

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
}
