import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/join_requests/data/datasources/join_requests_remote_datasource.dart';
import 'package:mycampus/features/join_requests/data/models/member_record_model.dart';
import 'package:mycampus/features/join_requests/domain/entities/member_request.dart';
import 'package:mycampus/features/join_requests/domain/exceptions/join_requests_exception.dart';
import 'package:mycampus/features/join_requests/domain/repositories/join_requests_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class JoinRequestsRepositoryImpl implements JoinRequestsRepository {
  JoinRequestsRepositoryImpl({
    required JoinRequestsRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final JoinRequestsRemoteDataSource _remote;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  Future<List<MemberRequest>> getMembers(String universityId) {
    return _guard(() async {
      final models = await _remote.getMembers(universityId);
      return models.map(_toMemberRequest).toList();
    });
  }

  @override
  Future<void> approve(String userId) {
    return _guard(() => _remote.updateStatus(userId, 'approved'));
  }

  @override
  Future<void> reject(String userId) {
    return _guard(() => _remote.updateStatus(userId, 'rejected'));
  }

  MemberRequest _toMemberRequest(MemberRecordModel model) {
    return MemberRequest(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role == 'faculty' ? MemberRole.faculty : MemberRole.student,
      status: _parseStatus(model.status),
      requestedAt: DateTime.tryParse(model.created) ?? DateTime.now(),
      avatarUrl: model.avatarUrl,
      roleId: model.roleId,
      department: model.department,
      subInfo: model.subInfo,
    );
  }

  MemberStatus _parseStatus(String value) {
    for (final status in MemberStatus.values) {
      if (status.name == value) return status;
    }
    return MemberStatus.pending;
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [JoinRequestsException], the only failure type above this layer needs
  /// to handle. A bare 15s timeout guards against the request hanging
  /// forever (e.g. the app pointed at a host it can't actually reach),
  /// which would otherwise leave the UI stuck showing a spinner with no
  /// error and no way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw JoinRequestsException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const JoinRequestsException('error.unreachableServer');
    } catch (e) {
      throw JoinRequestsException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
