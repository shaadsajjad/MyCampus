import 'package:flutter_bloc/flutter_bloc.dart';

enum UserRole { superAdmin, faculty, student }

enum AuthMode { login, register }

enum SplashPhase { initial, onboarding }

class SplashState {
  final SplashPhase phase;
  final UserRole selectedRole;
  final AuthMode authMode;

  const SplashState({
    this.phase = SplashPhase.initial,
    this.selectedRole = UserRole.student,
    this.authMode = AuthMode.login,
  });

  SplashState copyWith({
    SplashPhase? phase,
    UserRole? selectedRole,
    AuthMode? authMode,
  }) {
    return SplashState(
      phase: phase ?? this.phase,
      selectedRole: selectedRole ?? this.selectedRole,
      authMode: authMode ?? this.authMode,
    );
  }
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState()) {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!isClosed) {
      emit(state.copyWith(phase: SplashPhase.onboarding));
    }
  }

  void selectRole(UserRole role) {
    emit(state.copyWith(selectedRole: role));
  }

  void toggleAuthMode(AuthMode mode) {
    emit(state.copyWith(authMode: mode));
  }
}