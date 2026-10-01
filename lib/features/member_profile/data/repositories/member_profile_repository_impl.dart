import 'dart:async';

import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/member_profile/data/datasources/member_profile_remote_datasource.dart';
import 'package:mycampus/features/member_profile/data/models/member_profile_model.dart';
import 'package:mycampus/features/member_profile/domain/entities/member_profile.dart';
import 'package:mycampus/features/member_profile/domain/exceptions/member_profile_exception.dart';
import 'package:mycampus/features/member_profile/domain/repositories/member_profile_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class MemberProfileRepositoryImpl implements MemberProfileRepository {
  MemberProfileRepositoryImpl({
    required MemberProfileRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final MemberProfileRemoteDataSource _remote;

  @override
  MemberProfile? get cachedProfile {
    final model = _remote.cachedProfile;
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<MemberProfile> refresh() {
    return _guard(() async => _toEntity(await _remote.refresh()));
  }

  @override
  Future<MemberProfile> updateName(String name) {
    return _guard(() async {
      final id = _remote.cachedProfile?.id;
      if (id == null) {
        throw const MemberProfileException('You are signed out.');
      }
      return _toEntity(await _remote.updateName(id, name));
    });
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _guard(() => _remote.requestPasswordReset(email));
  }

  @override
  Future<void> logout() => _remote.logout();

  MemberProfile _toEntity(MemberProfileModel model) {
    final campus = model.campus;
    final student = model.student;
    final teacher = model.teacher;
    return MemberProfile(
      id: model.id,
      email: model.email,
      verified: model.verified,
      role: _parseRole(model.role),
      status: _parseStatus(model.status),
      name: model.name,
      phone: model.phone,
      memberSince: _parseDate(model.created),
      avatarUrl: model.avatarUrl,
      campus: campus == null
          ? null
          : MemberCampus(
              id: campus.id,
              name: campus.name,
              shortName: campus.shortName,
              type: _parseType(campus.type),
              city: campus.city,
              country: campus.country,
              logoUrl: campus.logoUrl,
            ),
      student: student == null
          ? null
          : StudentEnrollment(
              studentId: student.studentId,
              department: student.department,
              batch: student.batch,
            ),
      teacher: teacher == null
          ? null
          : FacultyAppointment(
              teacherId: teacher.teacherId,
              department: teacher.department,
              designation: teacher.designation,
            ),
    );
  }

  /// Falls back to [UserRole.student] for an unknown/absent value so a
  /// malformed record still renders a profile instead of throwing — the
  /// role only picks which sections and badge to draw.
  UserRole _parseRole(String? value) {
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return UserRole.student;
  }

  /// Same rationale as [_parseRole]. `none` is the safe default: it renders
  /// the "not a member yet" state, which is what an account with no campus
  /// actually is.
  MemberStatus _parseStatus(String? value) {
    for (final status in MemberStatus.values) {
      if (status.name == value) return status;
    }
    return MemberStatus.none;
  }

  UniversityType? _parseType(String? value) {
    for (final type in UniversityType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  DateTime? _parseDate(String? value) =>
      value == null ? null : DateTime.tryParse(value)?.toLocal();

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a
  /// human-readable [MemberProfileException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw MemberProfileException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const MemberProfileException(
        'Could not reach the server. Check that PocketBase is running and '
        'reachable from this device, then try again.',
      );
    } on MemberProfileException {
      rethrow;
    } catch (e) {
      throw MemberProfileException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
