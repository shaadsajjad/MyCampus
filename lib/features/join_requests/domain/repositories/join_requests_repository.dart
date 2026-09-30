import 'package:mycampus/features/join_requests/domain/entities/member_request.dart';

/// The contract the join-requests tab codes against.
/// [JoinRequestsException] is the only failure type it needs to know
/// about — everything else (PocketBase, HTTP, ...) is a data-layer detail
/// behind this interface.
abstract class JoinRequestsRepository {
  /// The `universities` record id this admin owns.
  String? get currentUniversityId;

  /// Every student/faculty member of [universityId], any status — the
  /// cubit splits this into pending/archived views itself rather than
  /// making two round trips.
  Future<List<MemberRequest>> getMembers(String universityId);

  Future<void> approve(String userId);

  Future<void> reject(String userId);
}
