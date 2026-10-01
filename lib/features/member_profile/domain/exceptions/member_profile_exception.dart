/// The only failure type the member profile layer surfaces — PocketBase's
/// `ClientException`, timeouts and anything else are translated into this
/// by `MemberProfileRepositoryImpl`.
class MemberProfileException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'MemberProfileException: $message';
}
