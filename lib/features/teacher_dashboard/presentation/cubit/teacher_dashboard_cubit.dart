import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/services/auth_refresh_service.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_profile.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_university.dart';
import 'package:mycampus/features/teacher_dashboard/domain/exceptions/teacher_dashboard_exception.dart';
import 'package:mycampus/features/teacher_dashboard/domain/repositories/teacher_dashboard_repository.dart';

enum TeacherDashboardStatus { loading, ready }

class TeacherDashboardState {
  const new({
    this.status = TeacherDashboardStatus.loading,
    this.name,
    this.email,
    this.avatarUrl,
    this.profile,
    this.membership = MembershipStatus.none,
    this.university,
    this.justApproved = false,
  });

  final TeacherDashboardStatus status;
  final String? name;
  final String? email;

  /// Authenticated URL for the signed-in faculty's avatar (from the
  /// `users.avatar` field) — used by the redesigned dashboard's faculty
  /// ID card. Null when no avatar is uploaded.
  final String? avatarUrl;

  /// Role-extension record — drives the faculty ID card's designation,
  /// department, and teacherId. Loaded lazily so dashboards work even
  /// when the registration step hasn't created the linked row yet.
  final TeacherProfile? profile;
  final MembershipStatus membership;

  /// Null while loading, if there's no university yet, or if the fetch
  /// failed — the UI falls back to the join prompt instead of erroring.
  final TeacherUniversity? university;

  /// Becomes `true` the instant a realtime event flips the faculty's
  /// status from pending → approved so the page can show a "welcome to
  /// campus" snackbar. Reset to false once the user opens a sub-screen
  /// or the cubit reloads.
  final bool justApproved;

  TeacherDashboardState copyWith({
    TeacherDashboardStatus? status,
    String? name,
    String? email,
    String? avatarUrl,
    TeacherProfile? profile,
    MembershipStatus? membership,
    TeacherUniversity? university,
    bool? justApproved,
  }) {
    return TeacherDashboardState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profile: profile ?? this.profile,
      membership: membership ?? this.membership,
      university: university ?? this.university,
      justApproved: justApproved ?? this.justApproved,
    );
  }
}

/// Loads the signed-in teacher's membership status (and, once approved,
/// their university's identity) for the dashboard page. Mirrors
/// `SuperAdminDashboardCubit`'s load/refresh shape. Also subscribes to
/// realtime updates on the faculty's own `users` record so the page
/// transitions automatically from "waiting for approval" to the home
/// dashboard the moment a super admin approves/rejects the request.
class TeacherDashboardCubit extends Cubit<TeacherDashboardState> {
  new({
    TeacherDashboardRepository? repository,
    AuthRefreshService? authRefreshService,
  }) : _repository = repository ?? DI.teacherDashboardRepository,
       _authRefreshService = authRefreshService ?? DI.authRefreshService,
       super(const TeacherDashboardState()) {
    unawaited(load());
    _subscribeToUserUpdates();
  }

  final TeacherDashboardRepository _repository;

  /// Re-reads the signed-in `users` record into the shared auth store when
  /// a realtime event fires, so [load] below sees the new approval status.
  final AuthRefreshService _authRefreshService;

  /// Tracks the membership status as of the most recent realtime event so
  /// the next event's pending → approved comparison is against an actually
  /// current snapshot, not whatever the status was when this cubit was
  /// first created. Without this, *every* subsequent event after the first
  /// approval would also satisfy `pending → approved` and fire a duplicate
  /// welcome snackbar — e.g. an admin editing the faculty's name after
  /// approving them would surface a second "welcome to campus" banner.
  MembershipStatus _lastSeenMembership = MembershipStatus.none;

  Future<void> Function()? _unsubscribeUpdates;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    final membership = _repository.currentMembershipStatus;
    final userId = _repository.currentUserId;
    emit(
      state.copyWith(
        status: TeacherDashboardStatus.loading,
        name: _repository.currentTeacherName,
        email: _repository.currentTeacherEmail,
        avatarUrl: _repository.currentAvatarUrl,
        membership: membership,
      ),
    );

    TeacherUniversity? university;
    if (universityId != null) {
      try {
        university = await _repository.getUniversity(universityId);
      } on TeacherDashboardException {
        // UI still renders the home view; just without a university header.
      }
    }

    TeacherProfile? profile;
    if (userId != null) {
      try {
        profile = await _repository.getTeacherProfile(userId);
      } on TeacherDashboardException {
        // Same as above: ID card falls back to the auth record name.
      }
    }

    _emitReady(university: university, profile: profile);
  }

  void _emitReady({
    TeacherUniversity? university,
    TeacherProfile? profile,
    bool? justApproved,
  }) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: TeacherDashboardStatus.ready,
        university: university,
        profile: profile,
        justApproved: justApproved,
      ),
    );
  }

  /// Wires the realtime channel: when the server reports an update to the
  /// signed-in user's record, pull the fresh values into the auth store
  /// (so every other feature reading `_pb.authStore.record` sees the same
  /// data) and re-run [load]. If the faculty just got approved, also
  /// flip `justApproved` so the UI can fire a one-shot snackbar.
  void _subscribeToUserUpdates() {
    _lastSeenMembership = _repository.currentMembershipStatus;
    _unsubscribeUpdates = _repository.watchCurrentUser(
      onChange: () async {
        if (isClosed) return;
        await _authRefreshService.refreshCurrentUser();
        if (isClosed) return;
        final previousMembership = _lastSeenMembership;
        final nextMembership = _repository.currentMembershipStatus;
        // Update BEFORE `load()` so that, if `load()` re-enters or another
        // event arrives mid-await, the next comparison starts from the value
        // we just observed rather than the stale snapshot.
        _lastSeenMembership = nextMembership;
        final justApproved =
            previousMembership == MembershipStatus.pending &&
            nextMembership == MembershipStatus.approved;
        await load();
        if (justApproved && !isClosed) {
          _emitReady(justApproved: true);
        }
      },
    );
  }

  /// Acknowledged by the page once it's shown the welcome snackbar so it
  /// doesn't re-fire on the next rebuild.
  void clearJustApproved() {
    if (!state.justApproved) return;
    _emitReady(justApproved: false);
  }

  Future<void> logout() async {
    await _unsubscribeUpdates?.call();
    _unsubscribeUpdates = null;
    await _repository.logout();
    emit(const TeacherDashboardState());
  }

  @override
  Future<void> close() async {
    await _unsubscribeUpdates?.call();
    _unsubscribeUpdates = null;
    await super.close();
  }
}
