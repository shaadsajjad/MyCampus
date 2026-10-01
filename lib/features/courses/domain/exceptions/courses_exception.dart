/// A user-facing failure from the courses tab — already a human-readable
/// message by the time it reaches the Cubit, so it can be shown directly.
class CoursesException implements Exception {
  const CoursesException(this.message);

  final String message;

  @override
  String toString() => message;
}
