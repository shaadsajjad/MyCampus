/// A user-facing failure from the verification screen — already a
/// human-readable message by the time it reaches the Cubit, so it can be
/// shown directly.
class VerificationException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
