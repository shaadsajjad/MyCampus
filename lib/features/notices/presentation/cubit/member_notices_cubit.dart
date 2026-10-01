// ignore_for_file: prefer_void_public_cubit_methods

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';

enum MemberNoticesStatus { loading, ready, error }

class MemberNoticesState {
  const MemberNoticesState({
    this.status = MemberNoticesStatus.loading,
    this.notices = const [],
    this.errorMessage,
  });

  final MemberNoticesStatus status;

  /// Already filtered server-side to the audiences this viewer belongs to
  /// — [MemberNoticesCubit] never has to filter the list itself.
  final List<Notice> notices;
  final String? errorMessage;

  MemberNoticesState copyWith({
    MemberNoticesStatus? status,
    List<Notice>? notices,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MemberNoticesState(
      status: status ?? this.status,
      notices: notices ?? this.notices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Read-only view of the notices a super admin has published, for the
/// Notices tab inside the student and teacher dashboards.
///
/// Separate from [NoticesCubit] (the admin's post-and-manage tab) on
/// purpose: a member can only ever *read*, so this cubit exposes no
/// create/delete and the audience set it requests is derived from the
/// viewer's role rather than passed in from a menu the user could change.
class MemberNoticesCubit extends Cubit<MemberNoticesState> {
  MemberNoticesCubit({
    required NoticeAudience audience,
    NoticesRepository? repository,
  }) : _repository = repository ?? DI.noticesRepository,
       _audience = audience,
       super(const MemberNoticesState()) {
    unawaited(load());
  }

  /// The role-specific audience (`students` or `faculty`). Combined with
  /// [NoticeAudience.all] automatically — every member sees campus-wide
  /// notices. Read-only via the public getter so the field itself stays
  /// private (`bloc_lint.avoid_public_fields`).
  final NoticeAudience _audience;
  NoticeAudience get audience => _audience;

  final NoticesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: MemberNoticesStatus.loading, clearError: true));
    final universityId = _repository.currentUniversityId;
    if (universityId == null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberNoticesStatus.ready,
            notices: const [],
          ),
        );
      }
      return;
    }
    try {
      final notices = await _repository.getNoticesForAudiences(
        universityId,
        {NoticeAudience.all, _audience},
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberNoticesStatus.ready,
            notices: notices,
          ),
        );
      }
    } on NoticesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberNoticesStatus.error,
            errorMessage: e.message,
          ),
        );
      }
    }
  }
}