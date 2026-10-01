import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/super_admin_profile/data/datasources/super_admin_profile_remote_datasource.dart';
import 'package:mycampus/features/super_admin_profile/data/models/profile_model.dart';
import 'package:mycampus/features/super_admin_profile/domain/entities/super_admin_profile.dart';
import 'package:mycampus/features/super_admin_profile/domain/exceptions/profile_exception.dart';
import 'package:mycampus/features/super_admin_profile/domain/repositories/super_admin_profile_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class SuperAdminProfileRepositoryImpl implements SuperAdminProfileRepository {
  SuperAdminProfileRepositoryImpl({
    required SuperAdminProfileRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final SuperAdminProfileRemoteDataSource _remote;

  @override
  SuperAdminProfile? get cachedProfile {
    final model = _remote.cachedProfile;
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<SuperAdminProfile> refresh() {
    return _guard(() async => _toEntity(await _remote.refresh()));
  }

  @override
  Future<SuperAdminProfile> updateName(String name) {
    return _guard(() async {
      final id = _remote.cachedProfile?.id;
      if (id == null) throw const ProfileException('You are signed out.');
      return _toEntity(await _remote.updateName(id, name));
    });
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _guard(() => _remote.requestPasswordReset(email));
  }

  @override
  Future<void> logout() => _remote.logout();

  SuperAdminProfile _toEntity(ProfileModel model) {
    final university = model.university;
    return SuperAdminProfile(
      id: model.id,
      email: model.email,
      verified: model.verified,
      name: model.name,
      memberSince: _parseDate(model.created),
      avatarUrl: model.avatarUrl,
      university: university == null
          ? null
          : ProfileUniversity(
              id: university.id,
              name: university.name,
              shortName: university.shortName,
              type: _parseType(university.type),
              city: university.city,
              country: university.country,
              establishedAt: _parseDate(university.establishedAt),
              logoUrl: university.logoUrl,
            ),
    );
  }

  DateTime? _parseDate(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toLocal();

  UniversityType? _parseType(String? value) {
    for (final type in UniversityType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [ProfileException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw ProfileException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const ProfileException('error.unreachableServer');
    } on ProfileException {
      rethrow;
    } catch (e) {
      throw ProfileException('error.unknown');
    }
  }
}
