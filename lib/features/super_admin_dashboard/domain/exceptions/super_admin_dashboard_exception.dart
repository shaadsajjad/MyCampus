/// A failure from the dashboard's university/stats fetch — already a
/// human-readable message by the time it reaches the Cubit.
class SuperAdminDashboardException implements Exception {
  const SuperAdminDashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
