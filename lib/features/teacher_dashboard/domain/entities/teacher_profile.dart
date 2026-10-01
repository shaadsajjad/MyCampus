/// Domain-level view of a `teachers` record — drives the redesigned
/// faculty ID card (teacherId, department, designation).
class TeacherProfile {
  const TeacherProfile({
    required this.teacherId,
    required this.department,
    required this.designation,
  });

  final String teacherId;
  final String department;
  final String designation;
}
