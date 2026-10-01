/// The app-level view of the `universities` record a student belongs to —
/// just enough to identify it on the dashboard's header card.
class StudentUniversity {
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
