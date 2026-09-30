/// A user-facing failure from the profile tab — already a human-readable
/// message by the time it reaches the Cubit.
class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
