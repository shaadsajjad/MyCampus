import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/features/verification/domain/exceptions/verification_exception.dart';
import 'package:mycampus/features/verification/domain/repositories/verification_repository.dart';
import 'package:mycampus/features/verification/presentation/cubit/verification_cubit.dart'
    show VerificationCubit;
import 'package:mycampus/features/verification/presentation/pages/verification_page.dart'
    show VerificationPage;

/// Service that listens for incoming deep links (e.g., mycampus://verify?token=...)
/// and routes them to the appropriate handler.
///
/// The link can arrive while [VerificationPage] is on screen (the normal
/// case — user registers, gets sent there, opens the link from their email
/// app) or while it isn't (app was cold-started from the link, or the user
/// navigated away). [VerificationCubit] claims tokens via
/// [registerTokenHandler] while it's alive so the page can show its own
/// spinner/error state; otherwise this service confirms the token itself
/// and navigates/messages the user directly.
class DeepLinkService {
  new _();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  VerificationRepository? _verificationRepository;
  void Function(String token)? _activeHandler;

  /// Initialize the deep link listener.
  /// Call this once during app startup (e.g., in bootstrap or main).
  Future<void> init({VerificationRepository? verificationRepository}) async {
    _verificationRepository =
        verificationRepository ?? DI.verificationRepository;

    // Handle links when the app is already running (foreground/background)
    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (err) {
        // Ignore errors - usually just means no link was available
      },
    );

    // Handle the initial link if the app was cold-started via a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } on Exception {
      // Ignore - no initial link
    }
  }

  /// Lets the currently-visible [VerificationCubit] claim incoming
  /// verification tokens instead of falling back to the generic
  /// confirm-and-navigate handling below. Call from the cubit's
  /// constructor; pair with [unregisterTokenHandler] in `close()`.
  void registerTokenHandler(void Function(String token) handler) {
    _activeHandler = handler;
  }

  void unregisterTokenHandler(void Function(String token) handler) {
    if (_activeHandler == handler) _activeHandler = null;
  }

  Future<void> _handleUri(Uri uri) async {
    // Expected format: mycampus://verify?token=<verification_token>
    if (uri.scheme != 'mycampus' || uri.host != 'verify') return;

    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return;

    final handler = _activeHandler;
    if (handler != null) {
      handler(token);
      return;
    }

    await _confirmAndNavigate(token);
  }

  /// Fallback used when no [VerificationCubit] is around to react to the
  /// token itself (e.g. the app was killed and the link cold-started it).
  /// There's no password available on this path, so confirming can only
  /// mark the account verified — it can't also sign the user in — hence
  /// routing to login rather than the dashboard.
  Future<void> _confirmAndNavigate(String token) async {
    try {
      await _verificationRepository?.confirmVerification(token);
      AppRouter.router.go(AppRoute.login);
      _showMessage('verification.emailVerified'.tr());
    } on VerificationException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('verification.verificationFailed'.tr());
    }
  }

  void _showMessage(String message) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
