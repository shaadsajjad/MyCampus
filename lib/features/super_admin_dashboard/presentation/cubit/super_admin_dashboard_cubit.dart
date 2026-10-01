import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_stats.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/super_admin_dashboard_exception.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/super_admin_dashboard_repository.dart';

enum SuperAdminDashboardStatus { loading, ready }

/// The dashboard's own bottom-nav tabs that actually have content behind
/// them. `Pass` stays unbuilt for now — tapping it just shows a "coming
/// soon" message rather than switching [tab].
enum SuperAdminDashboardTab { home, requests, directory, notices, profile }

class SuperAdminDashboardState {
  const new({
    this.status = SuperAdminDashboardStatus.loading,
    this.tab = SuperAdminDashboardTab.home,
    this.adminName,
    this.adminEmail,
    this.universityId,
    this.university,
    this.stats,
  });

  final SuperAdminDashboardStatus status;
  final SuperAdminDashboardTab tab;
  final String? adminName;
  final String? adminEmail;
  final String? universityId;

  /// Null while loading, or if the fetch failed — the UI falls back to
  /// placeholders rather than blocking on it.
  final University? university;
  final UniversityStats? stats;

  SuperAdminDashboardState copyWith({
    SuperAdminDashboardStatus? status,
    SuperAdminDashboardTab? tab,
    String? adminName,
    String? adminEmail,
    String? universityId,
    University? university,
    UniversityStats? stats,
  }) {
    return SuperAdminDashboardState(
      status: status ?? this.status,
      tab: tab ?? this.tab,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      universityId: universityId ?? this.universityId,
      university: university ?? this.university,
      stats: stats ?? this.stats,
    );
  }
}

/// Loads the super admin's own university and its membership counts for
/// the dashboard page. The university/stats calls need `users.listRule`
/// to allow a super admin to see records in their own university (see
/// `pocketbase_schema.md`) — if that hasn't been applied yet, or the
/// network call otherwise fails, the dashboard still renders with the
/// admin's identity and placeholder metrics instead of erroring.
class SuperAdminDashboardCubit extends Cubit<SuperAdminDashboardState> {
  new({SuperAdminDashboardRepository? repository})
    : _repository = repository ?? DI.superAdminDashboardRepository,
      super(const SuperAdminDashboardState()) {
    unawaited(load());
  }

  final SuperAdminDashboardRepository _repository;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    emit(
      state.copyWith(
        status: SuperAdminDashboardStatus.loading,
        adminName: _repository.currentAdminName,
        adminEmail: _repository.currentAdminEmail,
        universityId: universityId,
      ),
    );

    if (universityId == null) {
      _emitReady();
      return;
    }

    try {
      final university = await _repository.getUniversity(universityId);
      final stats = await _repository.getUniversityStats(universityId);
      _emitReady(university: university, stats: stats);
    } on SuperAdminDashboardException {
      _emitReady();
    }
  }

  void selectTab(SuperAdminDashboardTab tab) => emit(state.copyWith(tab: tab));

  void _emitReady({University? university, UniversityStats? stats}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: SuperAdminDashboardStatus.ready,
        university: university,
        stats: stats,
      ),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const SuperAdminDashboardState());
  }
}
