import 'package:mycampus/features/notices/domain/entities/notice.dart';

/// The contract the notices tab codes against. [NoticesException] is the
/// only failure type it needs to know about — everything else
/// (PocketBase, HTTP, ...) is a data-layer detail behind this interface.
abstract class NoticesRepository {
  /// The `universities` record id this admin owns.
  String? get currentUniversityId;

  /// The signed-in super admin's own id — lets the list decide whether
  /// *this* viewer may delete a given notice (only its author can).
  String? get currentUserId;

  Future<List<Notice>> getNotices(String universityId);

  Future<void> createNotice({
    required String title,
    required String body,
    required NoticeAudience audience,
    required String universityId,
  });

  Future<void> deleteNotice(String id);
}
