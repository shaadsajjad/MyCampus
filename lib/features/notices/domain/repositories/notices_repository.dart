import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart' show NoticesException;

/// The contract the notices tab codes against. [NoticesException] is the
/// only failure type it needs to know about — everything else
/// (PocketBase, HTTP, ...) is a data-layer detail behind this interface.
///
/// Read and write are deliberately separate methods rather than one
/// `getNotices` with an optional filter: posting is a super-admin-only
/// capability (`notices.createRule`), so a student/faculty viewer is
/// handed a different surface that simply cannot post or delete.
abstract class NoticesRepository {
  /// The `universities` record id this admin owns.
  String? get currentUniversityId;

  /// The signed-in super admin's own id — lets the list decide whether
  /// *this* viewer may delete a given notice (only its author can).
  String? get currentUserId;

  /// Every notice in [universityId], regardless of audience — the admin's
  /// own management view.
  Future<List<Notice>> getNotices(String universityId);

  /// Only the notices addressed to [audiences] — the read-only view a
  /// student (`{all, students}`) or faculty (`{all, faculty}`) member
  /// gets. `audience: all` notices are always included for anyone signed
  /// in to that university.
  Future<List<Notice>> getNoticesForAudiences(
    String universityId,
    Set<NoticeAudience> audiences,
  );

  Future<void> createNotice({
    required String title,
    required String body,
    required NoticeAudience audience,
    required String universityId,
  });

  Future<void> deleteNotice(String id);
}
