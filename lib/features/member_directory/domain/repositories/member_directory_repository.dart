import 'package:mycampus/features/member_directory/domain/entities/directory_member.dart';
import 'package:mycampus/features/member_directory/domain/exceptions/member_directory_exception.dart' show MemberDirectoryException;

/// The contract the member-directory tab codes against.
/// [MemberDirectoryException] is the only failure type it needs to know
/// about — everything else (PocketBase, HTTP, ...) is a data-layer detail
/// behind this interface.
abstract class MemberDirectoryRepository {
  /// The `universities` record id this admin owns.
  String? get currentUniversityId;

  /// Every approved student/faculty member of [universityId], newest join
  /// first. Pending and rejected accounts are excluded here rather than in
  /// the cubit — "approved" is a server-side property of the record, so
  /// filtering it at the source keeps the UI from having to know the
  /// directory can hold other people's pending requests.
  Future<List<DirectoryMember>> getApprovedMembers(String universityId);
}
