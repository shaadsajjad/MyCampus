class StudentDashboardException implements Exception {
  const StudentDashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
