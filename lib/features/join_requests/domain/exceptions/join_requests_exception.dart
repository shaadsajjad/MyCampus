/// A user-facing failure from the join-requests tab — already a
/// human-readable message by the time it reaches the Cubit, so it can be
/// shown directly.
class JoinRequestsException implements Exception {
  const JoinRequestsException(this.message);

  final String message;

  @override
  String toString() => message;
}
