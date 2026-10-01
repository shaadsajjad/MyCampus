import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:mycampus/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  new({required DashboardRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final DashboardRemoteDataSource _remote;

  @override
  UserRole? get currentUserRole {
    final raw = _remote.currentUserRole;
    if (raw == null) return null;
    for (final role in UserRole.values) {
      if (role.name == raw) return role;
    }
    return null;
  }

  @override
  String? get currentUserName => _remote.currentUserName;

  @override
  String? get currentUserEmail => _remote.currentUserEmail;

  @override
  bool get isCurrentUserPending => _remote.currentUserStatus == 'pending';

  @override
  Future<void> logout() => _remote.logout();
}
