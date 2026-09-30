enum CampusPassFailure {
  /// The user declined (or previously revoked) photo library access.
  permissionDenied,

  /// This platform can't do the operation at all (e.g. saving to a photo
  /// library from a web browser).
  unsupported,
  unknown,
}

class CampusPassException implements Exception {
  const CampusPassException(this.failure, [this.detail]);

  final CampusPassFailure failure;

  /// The underlying error, for logs — not shown to the user.
  final Object? detail;

  @override
  String toString() => 'CampusPassException($failure, $detail)';
}
