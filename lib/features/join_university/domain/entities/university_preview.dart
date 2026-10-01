/// A university looked up by the join code encoded in its campus QR (the
/// `universities` record id) — shown for confirmation before the signed-in
/// student/teacher sends a join request to it.
class UniversityPreview {
  const new({
    required this.id,
    required this.name,
    required this.shortName,
    this.city,
    this.country,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final String? city;
  final String? country;
  final String? logoUrl;
}
