import 'package:mycampus/features/notices/data/models/notice_record_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `notices` feature that talks to the PocketBase
/// SDK directly — `NoticesRepositoryImpl` works with [NoticeRecordModel]
/// and [NoticesException], never `RecordModel`/`ClientException`.
abstract class NoticesRemoteDataSource {
  String? get currentUniversityId;
  String? get currentUserId;

  Future<List<NoticeRecordModel>> getNotices(String universityId);

  Future<void> createNotice(Map<String, dynamic> body);

  Future<void> deleteNotice(String id);
}

class NoticesRemoteDataSourceImpl implements NoticesRemoteDataSource {
  NoticesRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  String? get currentUserId => _pb.authStore.record?.id;

  @override
  Future<List<NoticeRecordModel>> getNotices(String universityId) async {
    final result = await _pb
        .collection('notices')
        .getList(
          page: 1,
          perPage: 200,
          filter: "university = '$universityId'",
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
