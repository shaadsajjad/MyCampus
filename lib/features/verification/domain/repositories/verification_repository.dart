import 'package:mycampus/features/verification/domain/exceptions/verification_exception.dart' show VerificationException;

/// The contract the verification screen codes against;
/// [VerificationException] is the only failure type it needs to know
/// about — everything else (PocketBase, HTTP, ...) is a data-layer detail
/// behind this interface.
abstract class VerificationRepository {
  /// Confirms verification with the token from the deep link. Only flips a
  /// flag on the PocketBase record — it doesn't establish a session.
  Future<void> confirmVerification(String token);

  /// Sends a verification email to the given address.
  Future<void> requestVerification(String email);

  /// Logs in with [email]/[password] and reports whether the account is
  /// verified. Leaves an active session only when it is — logs back out
  /// immediately otherwise, so an unverified account never ends up with a
  /// session sitting in storage. Used both for the auto-login right after
  /// confirming a token, and for the polling fallback while waiting for one.
  Future<bool> loginIfVerified({
    required String email,
    required String password,
  });

  /// Whether logging in above left an active session.
  bool get hasActiveSession;
}
