import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/auth/domain/entities/auth_user.dart';
import 'package:mycampus/features/auth/domain/repositories/auth_repository.dart';

class DashboardState {
  const DashboardState({this.user});

  final AuthUser? user;
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? DI.authRepository,
      super(const DashboardState()) {
    emit(DashboardState(user: _authRepository.currentUser));
  }

  final AuthRepository _authRepository;

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const DashboardState());
  }
}
