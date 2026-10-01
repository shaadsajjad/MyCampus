import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardState {
  const new({this.role, this.name, this.email, this.isPending = false});

  /// Decides which role-specific dashboard `DashboardPage` shows.
  final UserRole? role;
  final String? name;
  final String? email;
  final bool isPending;
}

class DashboardCubit extends Cubit<DashboardState> {
  new({DashboardRepository? dashboardRepository})
    : _dashboardRepository = dashboardRepository ?? DI.dashboardRepository,
      super(const DashboardState()) {
    emit(
      DashboardState(
        role: _dashboardRepository.currentUserRole,
        name: _dashboardRepository.currentUserName,
        email: _dashboardRepository.currentUserEmail,
        isPending: _dashboardRepository.isCurrentUserPending,
      ),
    );
  }

  final DashboardRepository _dashboardRepository;

  Future<void> logout() async {
    await _dashboardRepository.logout();
    emit(const DashboardState());
  }
}
