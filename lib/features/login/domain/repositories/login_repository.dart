/// The contract the login screen codes against; [LoginException] is the
/// only failure type it needs to know about — everything else
/// (PocketBase, HTTP, ...) is a data-layer detail behind this interface.
abstract class LoginRepository {
  Future<void> login({required String email, required String password});

  /// Sends a verification email to the given address — used by the "resend
  /// verification" action shown when login fails because the account isn't
  /// verified yet.
  Future<void> requestVerification(String email);
}
