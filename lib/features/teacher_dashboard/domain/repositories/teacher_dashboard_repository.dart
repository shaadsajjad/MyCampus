import 'package:mycampus/features/teacher_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_profile.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_university.dart';

abstract class TeacherDashboardRepository {
  String? get currentTeacherName;
  String? get currentTeacherEmail;
  String? get currentAvatarFileName;
  String? get currentAvatarUrl;
  String? get currentUserId;

  /// Null until the teacher has scanned a campus QR and sent a join
  /// request.
  String? get currentUniversityId;
  MembershipStatus get currentMembershipStatus;

  Future<TeacherUniversity> getUniversity(String id);
  Future<TeacherProfile?> getTeacherProfile(String userId);
  Future<void> logout();

  /// Subscribe to changes on the signed-in teacher's own `users` record —
  /// drives the auto-refresh from "waiting for approval" to the home
  /// dashboard when a super admin approves/rejects. Returns an unsubscribe
  /// handle (or null if no signed-in account to watch).
  Future<void> Function()? watchCurrentUser({
    required void Function() onChange,
  });
}
