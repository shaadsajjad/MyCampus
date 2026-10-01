/// A user-facing failure from the member-directory tab — already a
/// human-readable message by the time it reaches the Cubit, so it can be
/// shown directly.
class MemberDirectoryException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
