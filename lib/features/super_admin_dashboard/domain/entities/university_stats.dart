/// Membership counts for a university, shown on the super admin dashboard.
class UniversityStats {
  const UniversityStats({
    required this.approvedStudents,
    required this.approvedFaculty,
    required this.pendingRequests,
  });

  final int approvedStudents;
  final int approvedFaculty;

  /// Students and faculty whose account is still awaiting this
  /// university's super admin to approve or reject it.
  final int pendingRequests;
}
