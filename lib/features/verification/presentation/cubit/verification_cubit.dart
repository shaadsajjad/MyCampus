// ignore_for_file: prefer_void_public_cubit_methods

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/router/app_router.dart' show AppRoute;
import 'package:mycampus/core/services/deep_link_service.dart';
import 'package:mycampus/features/verification/domain/exceptions/verification_exception.dart';
import 'package:mycampus/features/verification/domain/repositories/verification_repository.dart';

/// How often to poll for verification while the deep link hasn't fired yet
/// (e.g. the user tapped the link in a different browser/device than the
/// one running the app).
const _pollInterval = Duration(seconds: 3);

enum VerificationStatus { waiting, verifying, verified, error }

class VerificationState {
  const new({
    this.status = VerificationStatus.waiting,
    this.email = '',
    this.errorMessage,
    this.canResend = true,
    this.sessionActive = false,
  });

  final VerificationStatus status;
  final String email;
  final String? errorMessage;
  final bool canResend;

  /// Whether confirming the token also left the app signed in (via the
  /// auto-login below), so the UI can go straight to the dashboard instead
  /// of asking the user to log in again right after they just registered.
  final bool sessionActive;

  VerificationState copyWith({
    VerificationStatus? status,
    String? email,
    String? errorMessage,
    bool? canResend,
    bool? sessionActive,
    bool clearError = false,
  }) {
    return VerificationState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      canResend: canResend ?? this.canResend,
      sessionActive: sessionActive ?? this.sessionActive,
    );
  }
}

class VerificationCubit extends Cubit<VerificationState> {
  new({
    required String email,
    String? password,
    VerificationRepository? verificationRepository,
  }) : _verificationRepository =
           verificationRepository ?? DI.verificationRepository,
       _password = password,
       super(VerificationState(email: email)) {
    // Claim verification links for as long as this page is on screen, so
    // tapping the link in the email app (while this app is backgrounded)
    // updates this page's own spinner/error state instead of falling back
    // to a generic snackbar.
    DeepLinkService.instance.registerTokenHandler(handleVerificationToken);

    // Fallback for when the link is opened somewhere this app instance
    // never sees (a different device, or a browser that doesn't hand back
    // to the app) — poll instead of leaving the user stuck on this screen.
    if (password != null) {
      _pollTimer = Timer.periodic(
        _pollInterval,
        (_) => checkVerificationStatus(),
      );
    }
  }

  final VerificationRepository _verificationRepository;
  Timer? _pollTimer;
  bool _isPolling = false;

  /// Captured from the registration form and handed down via the router's
  /// `extra` (never a query param — see [AppRoute]). Confirming
  /// verification only flips a flag on the PocketBase record; it doesn't
  /// establish a session, so this is what lets [handleVerificationToken]
  /// log the user straight in afterwards instead of landing on an
  /// unauthenticated dashboard. `null` when this page was reached without
  /// it (e.g. from the login screen's "I already verified" link) — the
  /// user just logs in normally in that case.
  final String? _password;

  /// Public read-only accessor — kept public only because the page reads
  /// it during its async verification flow (see `verification_page.dart`).
  /// The field itself is private to satisfy `bloc_lint.avoid_public_fields`.
  String? get password => _password;

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    DeepLinkService.instance.unregisterTokenHandler(handleVerificationToken);
    return super.close();
  }

  /// Call this when the app receives a verification deep link token.
  Future<void> handleVerificationToken(String token) async {
    if (state.status == VerificationStatus.verifying) return;
    emit(
      state.copyWith(status: VerificationStatus.verifying, clearError: true),
    );

    try {
      await _verificationRepository.confirmVerification(token);
    } on VerificationException catch (e) {
      emit(
        state.copyWith(
          status: VerificationStatus.error,
          errorMessage: e.message,
        ),
      );
      return;
    }

    final password = this.password;
    if (password != null) {
      try {
        await _verificationRepository.loginIfVerified(
          email: state.email,
          password: password,
        );
      } on VerificationException {
        // Email is still verified either way — just couldn't establish a
        // session automatically (e.g. a network hiccup on this second
        // call). The listener falls back to the login screen for this.
      }
    }

    emit(
      state.copyWith(
        status: VerificationStatus.verified,
        sessionActive: _verificationRepository.hasActiveSession,
      ),
    );
  }

  /// Resend the verification email.
  Future<void> resendEmail() async {
    if (!state.canResend || state.status == VerificationStatus.verifying) {
      return;
    }
    emit(state.copyWith(canResend: false, clearError: true));

    try {
      await _verificationRepository.requestVerification(state.email);
      // Re-enable resend after a cooldown
      await Future<void>.delayed(const Duration(seconds: 60));
      if (!isClosed) {
        emit(state.copyWith(canResend: true));
      }
    } on VerificationException catch (e) {
      emit(
        state.copyWith(
          status: VerificationStatus.error,
          errorMessage: e.message,
          canResend: true,
        ),
      );
    }
  }

  /// Check if the user's email is now verified (polling fallback).
  ///
  /// PocketBase has no "check verification status" endpoint that doesn't
  /// also authenticate, so this logs in to read the record's `verified`
  /// flag — [VerificationRepository.loginIfVerified] undoes the login
  /// immediately if it's still false, so an unverified account never ends
  /// up with a session sitting in storage.
  Future<void> checkVerificationStatus() async {
    final password = this.password;
    if (password == null || _isPolling) return;
    if (state.status != VerificationStatus.waiting) return;

    _isPolling = true;
    try {
      final verified = await _verificationRepository.loginIfVerified(
        email: state.email,
        password: password,
      );
      if (verified) {
        _pollTimer?.cancel();
        emit(
          state.copyWith(
            status: VerificationStatus.verified,
            sessionActive: true,
          ),
        );
      }
    } on VerificationException {
      // Transient network hiccup or similar — try again on the next tick.
    } finally {
      _isPolling = false;
    }
  }
}