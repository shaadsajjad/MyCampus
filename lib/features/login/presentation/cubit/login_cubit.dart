import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/login/domain/exceptions/login_exception.dart';
import 'package:mycampus/features/login/domain/repositories/login_repository.dart';
import 'package:mycampus/features/login/presentation/submission_status.dart';

enum LoginResult { success, emailNotVerified, failure }

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
    this.result,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final SubmissionStatus status;
  final String? errorMessage;
  final LoginResult? result;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SubmissionStatus? status,
    String? errorMessage,
    LoginResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({LoginRepository? loginRepository})
    : _loginRepository = loginRepository ?? DI.loginRepository,
      super(const LoginState());

  final LoginRepository _loginRepository;

  /// Owned here (not in a [StatefulWidget]) so the login page can stay a
  /// plain [StatelessWidget] while still validating on submit.
  final formKey = GlobalKey<FormState>();

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearResult: true));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearResult: true));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    emit(
      state.copyWith(
        status: SubmissionStatus.submitting,
        clearError: true,
        clearResult: true,
      ),
    );
    try {
      await _loginRepository.login(
        email: state.email,
        password: state.password,
      );
      emit(
        state.copyWith(
          status: SubmissionStatus.success,
          result: LoginResult.success,
        ),
      );
    } on LoginException catch (e) {
      final isUnverified = _isEmailNotVerifiedError(e.message);
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: e.message,
          result: isUnverified
              ? LoginResult.emailNotVerified
              : LoginResult.failure,
        ),
      );
    }
  }

  /// Resend verification email for the current email.
  Future<void> resendVerificationEmail() async {
    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _loginRepository.requestVerification(state.email);
      emit(state.copyWith(status: SubmissionStatus.success));
    } on LoginException catch (e) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  bool _isEmailNotVerifiedError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('verif') ||
        lower.contains('confirm') ||
        lower.contains('unverified') ||
        lower.contains('not verified');
  }
}
