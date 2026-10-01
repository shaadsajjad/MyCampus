/// The app-level view of the `universities` record a teacher belongs to —
/// just enough to identify it on the dashboard's header card.
class TeacherUniversity {
  const new({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;
}
