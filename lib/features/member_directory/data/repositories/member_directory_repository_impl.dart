import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/member_directory/data/datasources/member_directory_remote_datasource.dart';
import 'package:mycampus/features/member_directory/data/models/directory_member_model.dart';
import 'package:mycampus/features/member_directory/domain/entities/directory_member.dart';
import 'package:mycampus/features/member_directory/domain/exceptions/member_directory_exception.dart';
import 'package:mycampus/features/member_directory/domain/repositories/member_directory_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class MemberDirectoryRepositoryImpl implements MemberDirectoryRepository {
  new({
    required MemberDirectoryRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final MemberDirectoryRemoteDataSource _remote;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  Future<List<DirectoryMember>> getApprovedMembers(String universityId) {
    return _guard(() async {
      final models = await _remote.getApprovedMembers(universityId);
      return models.map(_toDirectoryMember).toList();
    });
  }

  DirectoryMember _toDirectoryMember(DirectoryMemberModel model) {
    return DirectoryMember(
      id: model.id,
      name: model.name,
      email: model.email,
      role: model.role == 'faculty'
          ? DirectoryRole.faculty
          : DirectoryRole.student,
      joinedAt: DateTime.tryParse(model.created) ?? DateTime.now(),
      avatarUrl: model.avatarUrl,
      roleId: model.roleId,
      department: model.department,
      subInfo: model.subInfo,
    );
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [MemberDirectoryException], the only failure type above this layer
  /// needs to handle. A bare 15s timeout guards against the request hanging
  /// forever (e.g. the app pointed at a host it can't actually reach), which
  /// would otherwise leave the UI stuck showing a spinner with no error and
  /// no way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw MemberDirectoryException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const MemberDirectoryException('error.unreachableServer');
    } catch (e) {
      throw MemberDirectoryException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
