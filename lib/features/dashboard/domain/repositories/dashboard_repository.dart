import 'package:mycampus/core/domain/entities/user_role.dart';

/// The contract the placeholder dashboard (and its role-routing) codes
/// against — deliberately minimal: just enough to say who's signed in and
/// let them log out. A role-specific dashboard that needs more (e.g.
/// `super_admin_dashboard`) owns its own repository rather than this one
/// growing extra fields for a single caller.
abstract class DashboardRepository {
  UserRole? get currentUserRole;
  String? get currentUserName;
  String? get currentUserEmail;

  /// Whether the signed-in account is still awaiting a super admin's
  /// approval.
  bool get isCurrentUserPending;

  Future<void> logout();
}
