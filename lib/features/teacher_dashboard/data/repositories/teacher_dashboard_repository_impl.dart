import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/teacher_dashboard/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_profile.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_university.dart';
import 'package:mycampus/features/teacher_dashboard/domain/exceptions/teacher_dashboard_exception.dart';
import 'package:mycampus/features/teacher_dashboard/domain/repositories/teacher_dashboard_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class TeacherDashboardRepositoryImpl implements TeacherDashboardRepository {
  new({
    required TeacherDashboardRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final TeacherDashboardRemoteDataSource _remote;

  @override
  String? get currentTeacherName => _remote.currentTeacherName;

  @override
  String? get currentTeacherEmail => _remote.currentTeacherEmail;

  @override
  String? get currentAvatarFileName => _remote.currentAvatarFileName;

  @override
  String? get currentAvatarUrl => _remote.currentAvatarUrl;

  @override
  String? get currentUserId => _remote.currentUserId;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  MembershipStatus get currentMembershipStatus {
    if (_remote.currentUniversityId == null) return MembershipStatus.none;
    final raw = _remote.currentStatus;
    for (final status in MembershipStatus.values) {
      if (status.name == raw) return status;
    }
    return MembershipStatus.none;
  }

  @override
  Future<TeacherUniversity> getUniversity(String id) {
    return _guard(() async {
      final model = await _remote.getUniversity(id);
      return TeacherUniversity(
        id: model.id,
        name: model.name,
        shortName: model.shortName,
        logoUrl: model.logoUrl,
      );
    });
  }

  @override
  Future<TeacherProfile?> getTeacherProfile(String userId) {
    return _guard(() async {
      final model = await _remote.getTeacherProfile(userId);
      if (model == null) return null;
      return TeacherProfile(
        teacherId: model.teacherId,
        department: model.department,
        designation: model.designation,
      );
    });
  }

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<void> Function()? watchCurrentUser({
    required void Function() onChange,
  }) => _remote.watchCurrentUser(onChange: onChange);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw TeacherDashboardException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const TeacherDashboardException('error.unreachableServer');
    } catch (e) {
      throw TeacherDashboardException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
