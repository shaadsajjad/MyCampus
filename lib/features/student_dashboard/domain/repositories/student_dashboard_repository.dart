import 'package:mycampus/features/student_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_profile.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_university.dart';

abstract class StudentDashboardRepository {
  String? get currentStudentName;
  String? get currentStudentEmail;
  String? get currentAvatarFileName;
  String? get currentAvatarUrl;
  String? get currentUserId;

  /// Null until the student has scanned a campus QR and sent a join
  /// request.
  String? get currentUniversityId;
  MembershipStatus get currentMembershipStatus;

  Future<StudentUniversity> getUniversity(String id);
  Future<StudentProfile?> getStudentProfile(String userId);
  Future<void> logout();

  /// Subscribe to changes on the signed-in student's own `users` record —
  /// drives the auto-refresh from "waiting for approval" to the home
  /// dashboard when a super admin approves/rejects. Returns an unsubscribe
  /// handle (or null if no signed-in account to watch).
  Future<void> Function()? watchCurrentUser({required void Function() onChange});
}
