/// DTO for a `courses` record as seen by the courses tab — matches
/// PocketBase's wire format, where every numeric field arrives as a string
/// (`credits`/`contactHours` are Number fields on the record). Parsing those
/// into the domain-level `Course` is the repository's job, not this model's.
class CourseRecordModel {
  const new({
    required this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.contactHours,
    this.department,
  });

  final String id;
  final String code;
  final String title;

  /// Raw PocketBase value — a number rendered as a string.
  final String credits;

  /// Raw PocketBase value — a number rendered as a string.
  final String contactHours;
  final String? department;
}
