import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class ComposeNoticeState {
  const ComposeNoticeState({
    this.title = '',
    this.body = '',
    this.audience = NoticeAudience.all,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final String title;
  final String body;
  final NoticeAudience audience;
  final SubmissionStatus status;
  final String? errorMessage;

  ComposeNoticeState copyWith({
    String? title,
    String? body,
    NoticeAudience? audience,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ComposeNoticeState(
      title: title ?? this.title,
      body: body ?? this.body,
      audience: audience ?? this.audience,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Backs the "new notice" sheet. A fresh instance per sheet open (unlike
/// `NoticesCubit`, which lives for the whole tab) — the caller reloads the
/// list itself once this reports [SubmissionStatus.success].
class ComposeNoticeCubit extends Cubit<ComposeNoticeState> {
  ComposeNoticeCubit({NoticesRepository? repository})
    : _repository = repository ?? DI.noticesRepository,
      super(const ComposeNoticeState());

  final NoticesRepository _repository;

  /// Owned here (not in a `StatefulWidget`) so the sheet can stay a plain
  /// `StatelessWidget` while still validating on submit.
  final formKey = GlobalKey<FormState>();

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void bodyChanged(String value) => emit(state.copyWith(body: value));

  void audienceChanged(NoticeAudience value) =>
      emit(state.copyWith(audience: value));

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final universityId = _repository.currentUniversityId;
    if (universityId == null) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: 'You are signed out.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _repository.createNotice(
        title: state.title.trim(),
        body: state.body.trim(),
        audience: state.audience,
        universityId: universityId,
      );
      if (!isClosed) emit(state.copyWith(status: SubmissionStatus.success));
    } on NoticesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SubmissionStatus.failure,
            errorMessage: e.message,
          ),
        );
      }
    }
  }
}
