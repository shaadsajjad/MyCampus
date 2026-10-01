/// One course offered by a university.
///
/// This is the catalogue a routine is eventually built out of: a super admin
/// defines the courses (code, title, credits, contact hours), and a later
/// feature assigns them to students/teachers and slots them into periods.
/// Nothing here assigns a course to anyone yet — a course is just "this
/// campus teaches CSE-101, worth 4 credits, 3 hours a week".
class Course {
  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.contactHours,
    this.department,
  });

  /// The `courses` record id.
  final String id;

  /// Short identifier used in a timetable, e.g. `CSE-101`. Unique per
  /// university — the repository enforces that, since a duplicate code in a
  /// published routine would be ambiguous.
  final String code;
  final String title;

  /// Credit hours the course carries — what a student's transcript would
  /// count.
  final int credits;

  /// Scheduled hours per week — what a timetable actually has to fit. Kept
  /// separate from [credits] because a 4-credit course commonly meets 3
  /// times a week.
  final int contactHours;

  /// Free text for now, matching `students.department`/`teachers.department`
  /// being free text rather than a relation (see `pocketbase_schema.md`).
  final String? department;
}
