/// Domain-level view of a `students` record — what the redesigned
/// student dashboard needs to render the digital ID card (studentId),
/// program label (department) and term (batch).
class StudentProfile {
  const new({
    required this.studentId,
    required this.department,
    required this.batch,
  });

  final String studentId;
  final String department;
  final String batch;
}
