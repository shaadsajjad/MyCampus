/// A user-facing failure from an auth operation — already a human-readable
/// message by the time it reaches the Cubit, so it can be shown directly.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
