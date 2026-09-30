/// A user-facing failure from the login screen — already a human-readable
/// message by the time it reaches the Cubit, so it can be shown directly.
class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
