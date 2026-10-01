import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/notices/data/datasources/notices_remote_datasource.dart';
import 'package:mycampus/features/notices/data/models/notice_record_model.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class NoticesRepositoryImpl implements NoticesRepository {
  new({required NoticesRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final NoticesRemoteDataSource _remote;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  Future<List<Notice>> getNotices(String universityId) {
    return _guard(() async {
      final models = await _remote.getNotices(universityId);
      return models.map(_toNotice).toList();
    });
  }

  @override
  Future<List<Notice>> getNoticesForAudiences(
    String universityId,
    Set<NoticeAudience> audiences,
  ) {
    return _guard(() async {
      final models = await _remote.getNoticesForAudiences(
        universityId,
        audiences.map((a) => a.name).toSet(),
      );
      return models.map(_toNotice).toList();
    });
  }

  @override
  Future<void> createNotice({
    required String title,
    required String body,
    required NoticeAudience audience,
    required String universityId,
  }) {
    return _guard(() async {
      final authorId = _remote.currentUserId;
      if (authorId == null) {
        throw const NoticesException('You are signed out.');
      }
      await _remote.createNotice({
        'title': title,
        'body': body,
        'audience': audience.name,
        'university': universityId,
        'author': authorId,
      });
    });
  }

  @override
  Future<void> deleteNotice(String id) {
    return _guard(() => _remote.deleteNotice(id));
  }

  Notice _toNotice(NoticeRecordModel model) {
    return Notice(
      id: model.id,
      title: model.title,
      body: model.body,
      audience: _parseAudience(model.audience),
      authorId: model.authorId,
      authorName: model.authorName,
      createdAt: DateTime.tryParse(model.created) ?? DateTime.now(),
    );
  }

  NoticeAudience _parseAudience(String value) {
    for (final audience in NoticeAudience.values) {
      if (audience.name == value) return audience;
    }
    return NoticeAudience.all;
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [NoticesException], the only failure type above this layer needs to
  /// handle. A bare 15s timeout guards against the request hanging forever
  /// (e.g. the app pointed at a host it can't actually reach), which would
  /// otherwise leave the UI stuck showing a spinner with no error and no
  /// way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw NoticesException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const NoticesException('error.unreachableServer');
    } on NoticesException {
      rethrow;
    } catch (e) {
      throw const NoticesException('error.unknown');
    }
  }
}
