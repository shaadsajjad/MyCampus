import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/auth/domain/exceptions/auth_exception.dart';
import 'package:mycampus/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycampus/features/auth/presentation/cubit/submission_status.dart';

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final SubmissionStatus status;
  final String? errorMessage;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? DI.authRepository,
      super(const LoginState());

  final AuthRepository _authRepository;

  /// Owned here (not in a [StatefulWidget]) so the login page can stay a
  /// plain [StatelessWidget] while still validating on submit.
  final formKey = GlobalKey<FormState>();

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void passwordChanged(String value) => emit(state.copyWith(password: value));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _authRepository.login(email: state.email, password: state.password);
      emit(state.copyWith(status: SubmissionStatus.success));
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
