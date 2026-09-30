import 'package:mycampus/features/super_admin_dashboard/domain/entities/university.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_stats.dart';

/// The contract the super admin dashboard codes against — the signed-in
/// admin's own identity plus everything about the university they own.
abstract class SuperAdminDashboardRepository {
  String? get currentAdminName;
  String? get currentAdminEmail;

  /// The `universities` record id this admin owns — also the join code
  /// encoded in the campus QR.
  String? get currentUniversityId;

  Future<University> getUniversity(String id);

  /// Counts approved students/faculty and pending join requests for
  /// [universityId].
  Future<UniversityStats> getUniversityStats(String universityId);

  Future<void> logout();
}
