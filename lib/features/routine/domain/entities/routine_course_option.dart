/// A course offered for picking in the "new routine slot" sheet. Deliberately
/// not the `courses` feature's own `Course` entity — `routine` reads the
/// `courses` PocketBase collection directly for this lightweight shape
/// rather than importing `courses`' domain/data layer, per
/// `clean_architecture.md`'s "features own their data" rule.
class RoutineCourseOption {
  const new({required this.id, required this.code, required this.title});

  final String id;
  final String code;
  final String title;
}
