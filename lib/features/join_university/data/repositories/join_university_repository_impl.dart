import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/join_university/data/datasources/join_university_remote_datasource.dart';
import 'package:mycampus/features/join_university/domain/entities/university_preview.dart';
import 'package:mycampus/features/join_university/domain/exceptions/join_university_exception.dart';
import 'package:mycampus/features/join_university/domain/repositories/join_university_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class JoinUniversityRepositoryImpl implements JoinUniversityRepository {
  JoinUniversityRepositoryImpl({
    required JoinUniversityRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final JoinUniversityRemoteDataSource _remote;

  @override
  Future<UniversityPreview> lookupUniversity(String code) {
    return _guard(() async {
      final model = await _remote.getUniversity(code);
      return UniversityPreview(
        id: model.id,
        name: model.name,
        shortName: model.shortName,
        city: model.city,
        country: model.country,
        logoUrl: model.logoUrl,
      );
    });
  }

  @override
  Future<void> requestToJoin(String universityId) {
    return _guard(() => _remote.updateOwnMembership(universityId));
  }

  /// Same `_guard` shape as every other feature's repository — see
  /// `join_requests_repository_impl.dart` for the canonical version.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw JoinUniversityException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const JoinUniversityException(
        'Could not reach the server. Check that PocketBase is running and '
        'reachable from this device, then try again.',
      );
    } catch (e) {
      throw JoinUniversityException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
