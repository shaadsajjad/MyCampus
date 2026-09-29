import 'package:bloc/bloc.dart';
import 'package:mycampus/features/onboarding/domain/entities/auth_mode.dart';
import 'package:mycampus/features/onboarding/domain/entities/user_role.dart';

class OnboardingState {
  const OnboardingState({
    this.selectedRole = UserRole.student,
    this.authMode = AuthMode.login,
  });

  final UserRole selectedRole;
  final AuthMode authMode;

  OnboardingState copyWith({UserRole? selectedRole, AuthMode? authMode}) {
    return OnboardingState(
      selectedRole: selectedRole ?? this.selectedRole,
      authMode: authMode ?? this.authMode,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void selectRole(UserRole role) {
    emit(state.copyWith(selectedRole: role));
  }

  void toggleAuthMode(AuthMode mode) {
    emit(state.copyWith(authMode: mode));
  }
}
