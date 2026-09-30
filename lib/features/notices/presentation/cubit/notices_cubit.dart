import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';

enum NoticesStatus { loading, ready, error }

class NoticesState {
  const NoticesState({
    this.status = NoticesStatus.loading,
    this.notices = const [],
    this.currentUserId,
    this.deletingIds = const {},
    this.errorMessage,
  });

  final NoticesStatus status;
  final List<Notice> notices;

  /// Lets the list decide whether *this* viewer may delete a given notice
  /// (only its author can).
  final String? currentUserId;

  /// Ids currently mid-delete — lets the UI disable just that card instead
  /// of freezing the whole list.
  final Set<String> deletingIds;
  final String? errorMessage;

  NoticesState copyWith({
    NoticesStatus? status,
    List<Notice>? notices,
    String? currentUserId,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NoticesState(
      status: status ?? this.status,
      notices: notices ?? this.notices,
      currentUserId: currentUserId ?? this.currentUserId,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NoticesCubit extends Cubit<NoticesState> {
  NoticesCubit({NoticesRepository? repository})
    : _repository = repository ?? DI.noticesRepository,
      super(const NoticesState()) {
    unawaited(load());
  }

  final NoticesRepository _repository;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    emit(
      state.copyWith(
        status: NoticesStatus.loading,
        currentUserId: _repository.currentUserId,
        clearError: true,
      ),
    );
    if (universityId == null) {
      if (!isClosed) {
        emit(state.copyWith(status: NoticesStatus.ready, notices: const []));
      }
      return;
    }
    try {
      final notices = await _repository.getNotices(universityId);
      if (!isClosed) {
        emit(state.copyWith(status: NoticesStatus.ready, notices: notices));
      }
    } on NoticesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: NoticesStatus.error, errorMessage: e.message),
        );
      }
    }
  }

  Future<void> deleteNotice(String id) async {
    emit(state.copyWith(deletingIds: {...state.deletingIds, id}));
    try {
      await _repository.deleteNotice(id);
      if (!isClosed) {
        emit(
          state.copyWith(
            notices: state.notices.where((n) => n.id != id).toList(),
            deletingIds: {...state.deletingIds}..remove(id),
          ),
        );
      }
    } on NoticesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            deletingIds: {...state.deletingIds}..remove(id),
            errorMessage: e.message,
          ),
        );
      }
    }
  }
}
