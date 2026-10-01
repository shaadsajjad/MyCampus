import 'package:mycampus/features/notices/data/models/notice_record_model.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart'
    show NoticesException;
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `notices` feature that talks to the PocketBase
/// SDK directly — `NoticesRepositoryImpl` works with [NoticeRecordModel]
/// and [NoticesException], never `RecordModel`/`ClientException`.
abstract class NoticesRemoteDataSource {
  String? get currentUniversityId;
  String? get currentUserId;

  /// Every notice in [universityId], newest first. Used by the admin's
  /// own Notices tab, which shows (and may delete) everything it posted.
  Future<List<NoticeRecordModel>> getNotices(String universityId);

  /// Only the notices addressed to [audiences] — what a student/faculty
  /// viewer is allowed to see. Filtering server-side keeps the audience
  /// boundary in one place (the query) instead of relying on every client
  /// remembering to filter.
  Future<List<NoticeRecordModel>> getNoticesForAudiences(
    String universityId,
    Set<String> audiences,
  );

  Future<void> createNotice(Map<String, dynamic> body);

  Future<void> deleteNotice(String id);
}

class NoticesRemoteDataSourceImpl implements NoticesRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  String? get currentUserId => _pb.authStore.record?.id;

  @override
  Future<List<NoticeRecordModel>> getNotices(String universityId) {
    return _fetch("university = '$universityId'");
  }

  @override
  Future<List<NoticeRecordModel>> getNoticesForAudiences(
    String universityId,
    Set<String> audiences,
  ) {
    // An empty audience set would otherwise produce `()` — a syntax error.
    // Nothing can match it, so short-circuit with an empty list.
    if (audiences.isEmpty) return Future.value(const []);
    final clause = audiences.map((a) => "audience = '$a'").join(' || ');
    return _fetch("university = '$universityId' && ($clause)");
  }

  Future<List<NoticeRecordModel>> _fetch(String filter) async {
    final result = await _pb
        .collection('notices')
        .getList(
          page: 1,
          perPage: 200,
          filter: filter,
          sort: '-created',
          expand: 'author',
        );
    return result.items.map(_toModel).toList();
  }

  @override
  Future<void> createNotice(Map<String, dynamic> body) async {
    await _pb.collection('notices').create(body: body);
  }

  @override
  Future<void> deleteNotice(String id) async {
    await _pb.collection('notices').delete(id);
  }

  NoticeRecordModel _toModel(RecordModel record) {
    final author = record.get<RecordModel?>('expand.author');
    return NoticeRecordModel(
      id: record.id,
      title: record.getStringValue('title'),
      body: record.getStringValue('body'),
      audience: record.getStringValue('audience'),
      authorId: record.getStringValue('author'),
      authorName: author?.getStringValue('name') ?? '',
      created: record.getStringValue('created'),
    );
  }
}
