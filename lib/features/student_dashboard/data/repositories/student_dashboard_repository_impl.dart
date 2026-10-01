import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/student_dashboard/data/datasources/student_dashboard_remote_datasource.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_profile.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_university.dart';
import 'package:mycampus/features/student_dashboard/domain/exceptions/student_dashboard_exception.dart';
import 'package:mycampus/features/student_dashboard/domain/repositories/student_dashboard_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  new({required StudentDashboardRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final StudentDashboardRemoteDataSource _remote;

  @override
  String? get currentStudentName => _remote.currentStudentName;

  @override
  String? get currentStudentEmail => _remote.currentStudentEmail;

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
  Future<StudentUniversity> getUniversity(String id) {
    return _guard(() async {
      final model = await _remote.getUniversity(id);
      return StudentUniversity(
        id: model.id,
        name: model.name,
        shortName: model.shortName,
        logoUrl: model.logoUrl,
      );
    });
  }

  @override
  Future<StudentProfile?> getStudentProfile(String userId) {
    return _guard(() async {
      final model = await _remote.getStudentProfile(userId);
      if (model == null) return null;
      return StudentProfile(
        studentId: model.studentId,
        department: model.department,
        batch: model.batch,
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
      throw StudentDashboardException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const StudentDashboardException('error.unreachableServer');
    } catch (e) {
      throw StudentDashboardException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
