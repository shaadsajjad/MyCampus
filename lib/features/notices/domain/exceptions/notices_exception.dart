/// A user-facing failure from the notices tab — already a human-readable
/// message by the time it reaches the Cubit.
class NoticesException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
