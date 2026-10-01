/// DTO for the signed-in `users` record plus its expanded `university` —
/// PocketBase's wire format as-is (raw strings for dates and the
/// university `type`). Parsing into `SuperAdminProfile` is the
/// repository's job.
class ProfileModel {
  const new({
    required this.id,
    required this.email,
    required this.verified,
    this.name,
    this.created,
    this.avatarUrl,
    this.university,
  });

  final String id;
  final String email;
  final bool verified;
  final String? name;
  final String? created;
  final String? avatarUrl;
  final ProfileUniversityModel? university;
}

class ProfileUniversityModel {
  const new({
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
  final String? type;
  final String? city;
  final String? country;
  final String? establishedAt;
  final String? logoUrl;
}
