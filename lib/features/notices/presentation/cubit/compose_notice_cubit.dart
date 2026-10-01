// ignore_for_file: avoid_flutter_imports, prefer_void_public_cubit_methods

// Form keys live on the cubit per the pattern documented in
// `clean_architecture.md`, so this is the rare cubit that legitimately
// imports `package:flutter`.
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/domain/exceptions/notices_exception.dart';
import 'package:mycampus/features/notices/domain/repositories/notices_repository.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class ComposeNoticeState {
  const new({
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
  new({NoticesRepository? repository})
    : _repository = repository ?? DI.noticesRepository,
      super(const ComposeNoticeState());

  final NoticesRepository _repository;

  /// Owned here so the compose sheet can stay a `StatelessWidget` while
  /// still validating on submit. Kept private to satisfy
  /// `bloc_lint.avoid_public_fields`; the sheet reads it through the
  /// public getter below. (See `clean_architecture.md`: form keys
  /// deliberately live on the cubit.)
  final _formKey = GlobalKey<FormState>();

  /// Public read-only accessor so the sheet can do `Form(key: cubit.formKey, ...)`.
  GlobalKey<FormState> get formKey => _formKey;

  /// Owned here (not in a `StatefulWidget`) so the sheet can stay a plain
  /// `StatelessWidget` while still validating on submit.

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void bodyChanged(String value) => emit(state.copyWith(body: value));

  void audienceChanged(NoticeAudience value) =>
      emit(state.copyWith(audience: value));

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
