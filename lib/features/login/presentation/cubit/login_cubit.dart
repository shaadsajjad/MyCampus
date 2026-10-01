// ignore_for_file: prefer_void_public_cubit_methods

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/utils/translate_error.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/features/login/domain/exceptions/login_exception.dart';
import 'package:mycampus/features/login/domain/repositories/login_repository.dart';
import 'package:mycampus/features/login/presentation/submission_status.dart';

enum LoginResult { success, emailNotVerified, failure }

/// Outcome of a "Forgot Password?" request — kept separate from [LoginState.
/// status] so the forgot-password link and the main submit button never
/// show each other's loading/success state.
enum PasswordResetOutcome { sent, failed }

class LoginState {
  const new({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
    this.result,
    this.isSendingPasswordReset = false,
    this.passwordResetOutcome,
    this.passwordResetError,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final SubmissionStatus status;
  final String? errorMessage;
  final LoginResult? result;
  final bool isSendingPasswordReset;
  final PasswordResetOutcome? passwordResetOutcome;
  final String? passwordResetError;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SubmissionStatus? status,
    String? errorMessage,
    LoginResult? result,
    bool? isSendingPasswordReset,
    PasswordResetOutcome? passwordResetOutcome,
    String? passwordResetError,
    bool clearError = false,
    bool clearResult = false,
    bool clearPasswordResetOutcome = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
      isSendingPasswordReset:
          isSendingPasswordReset ?? this.isSendingPasswordReset,
      passwordResetOutcome: clearPasswordResetOutcome
          ? null
          : (passwordResetOutcome ?? this.passwordResetOutcome),
      passwordResetError: clearPasswordResetOutcome
          ? null
          : (passwordResetError ?? this.passwordResetError),
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  new({LoginRepository? loginRepository})
    : _loginRepository = loginRepository ?? DI.loginRepository,
      super(const LoginState());

  final LoginRepository _loginRepository;

  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearResult: true));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearResult: true));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  Future<void> submit() async {
    // No validate() call here — the page owns the form (see `AppForm`) and
    // only invokes submit() after validation passes. Keeps the cubit free
    // of `package:flutter` imports, which is what lets
    // `bloc_lint.avoid_flutter_imports` stay green.

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
      final message = translateError(e.message);
      final isUnverified = _isEmailNotVerifiedError(message);
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: message,
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
          errorMessage: translateError(e.message),
        ),
      );
    }
  }

  /// Sends a password-reset email for the address currently typed into the
  /// email field. PocketBase's `requestPasswordReset` doesn't reveal
  /// whether the address has an account (so this can't leak which emails
  /// are registered) — a valid-looking address always reports "sent".
  Future<void> requestPasswordReset() async {
    final emailError = Validators.email(state.email);
    if (emailError != null) {
      emit(
        state.copyWith(
          passwordResetOutcome: PasswordResetOutcome.failed,
          passwordResetError: emailError,
        ),
      );
      return;
    }

    emit(state.copyWith(isSendingPasswordReset: true));
    try {
      await _loginRepository.requestPasswordReset(state.email);
      emit(
        state.copyWith(
          isSendingPasswordReset: false,
          passwordResetOutcome: PasswordResetOutcome.sent,
        ),
      );
    } on LoginException catch (e) {
      emit(
        state.copyWith(
          isSendingPasswordReset: false,
          passwordResetOutcome: PasswordResetOutcome.failed,
          passwordResetError: translateError(e.message),
        ),
      );
    }
  }

  /// Clears the one-shot [LoginState.passwordResetOutcome] after the page's
  /// `BlocListener` has shown it, so navigating away and back doesn't
  /// replay the same SnackBar.
  void acknowledgePasswordResetOutcome() =>
      emit(state.copyWith(clearPasswordResetOutcome: true));

  bool _isEmailNotVerifiedError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('verif') ||
        lower.contains('confirm') ||
        lower.contains('unverified') ||
        lower.contains('not verified');
  }
}
