class JoinUniversityException implements Exception {
  const JoinUniversityException(this.message);

  final String message;

  @override
  String toString() => message;
}
