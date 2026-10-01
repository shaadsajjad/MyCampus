class JoinUniversityException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
