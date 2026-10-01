class TeacherDashboardException implements Exception {
  const TeacherDashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
