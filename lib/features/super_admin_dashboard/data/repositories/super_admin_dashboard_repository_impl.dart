import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/super_admin_dashboard/data/datasources/super_admin_dashboard_remote_datasource.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_stats.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_type.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/super_admin_dashboard_exception.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/super_admin_dashboard_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class SuperAdminDashboardRepositoryImpl
    implements SuperAdminDashboardRepository {
  new({required SuperAdminDashboardRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final SuperAdminDashboardRemoteDataSource _remote;

  @override
  String? get currentAdminName => _remote.currentAdminName;

  @override
  String? get currentAdminEmail => _remote.currentAdminEmail;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  Future<University> getUniversity(String id) {
    return _guard(() async {
      final model = await _remote.getUniversity(id);
      return University(
        id: model.id,
        name: model.name,
        shortName: model.shortName,
        type: _parseUniversityType(model.type),
        city: model.city,
        country: model.country,
        logoUrl: model.logoUrl,
      );
    });
  }

  @override
  Future<UniversityStats> getUniversityStats(String universityId) {
    return _guard(() async {
      final approvedStudents = await _remote.countUsers(
        "university = '$universityId' && role = 'student' && "
        "status = 'approved'",
      );
      final approvedFaculty = await _remote.countUsers(
        "university = '$universityId' && role = 'faculty' && "
        "status = 'approved'",
      );
      final pendingRequests = await _remote.countUsers(
        "university = '$universityId' && status = 'pending'",
      );
      return UniversityStats(
        approvedStudents: approvedStudents,
        approvedFaculty: approvedFaculty,
        pendingRequests: pendingRequests,
      );
    });
  }

  @override
  Future<void> logout() => _remote.logout();

  UniversityType? _parseUniversityType(String? value) {
    if (value == null) return null;
    for (final type in UniversityType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [SuperAdminDashboardException], the only failure type above this
  /// layer needs to handle. A bare 15s timeout guards against the request
  /// hanging forever (e.g. the app pointed at a host it can't actually
  /// reach), which would otherwise leave the UI stuck showing a spinner
  /// with no error and no way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw SuperAdminDashboardException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const SuperAdminDashboardException('error.unreachableServer');
    } catch (e) {
      throw SuperAdminDashboardException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
