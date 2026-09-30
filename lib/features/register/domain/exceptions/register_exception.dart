/// A user-facing failure from a registration operation — already a
/// human-readable message by the time it reaches the Cubit, so it can be
/// shown directly.
class RegisterException implements Exception {
  const RegisterException(this.message);

  final String message;

  @override
  String toString() => message;
}
