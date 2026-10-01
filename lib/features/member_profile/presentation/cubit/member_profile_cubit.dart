import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/member_profile/domain/entities/member_profile.dart';
import 'package:mycampus/features/member_profile/domain/exceptions/member_profile_exception.dart';
import 'package:mycampus/features/member_profile/domain/repositories/member_profile_repository.dart';

enum MemberProfileStatus { loading, ready, error }

/// One-shot results the page reacts to via `BlocListener` (SnackBar,
/// closing the edit sheet, navigating away after logout).
enum MemberProfileOutcome {
  nameSaved,
  nameSaveFailed,
  resetEmailSent,
  resetEmailFailed,
  loggedOut,
}

class MemberProfileState {
  const MemberProfileState({
    this.status = MemberProfileStatus.loading,
    this.profile,
    this.nameDraft = '',
    this.isSavingName = false,
    this.isSendingReset = false,
    this.outcome,
    this.errorMessage,
  });

  final MemberProfileStatus status;
  final MemberProfile? profile;

  /// The edit-name sheet's field value, bound via `initialValue` +
  /// `onChanged` — no `TextEditingController`.
  final String nameDraft;
  final bool isSavingName;
  final bool isSendingReset;

  /// Cleared at the start of each action so the listener fires again even
  /// when two actions in a row end the same way.
  final MemberProfileOutcome? outcome;
  final String? errorMessage;

  MemberProfileState copyWith({
    MemberProfileStatus? status,
    MemberProfile? profile,
    String? nameDraft,
    bool? isSavingName,
    bool? isSendingReset,
    MemberProfileOutcome? outcome,
    String? errorMessage,
    bool clearOutcome = false,
  }) {
    return MemberProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      nameDraft: nameDraft ?? this.nameDraft,
      isSavingName: isSavingName ?? this.isSavingName,
      isSendingReset: isSendingReset ?? this.isSendingReset,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      errorMessage: clearOutcome ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives the student/faculty Profile tab. Structurally the same contract
/// as `SuperAdminProfileCubit` (cached-then-fresh load, name edit, reset
/// email, logout) so the two profile screens behave identically.
class MemberProfileCubit extends Cubit<MemberProfileState> {
  MemberProfileCubit({MemberProfileRepository? repository})
    : _repository = repository ?? DI.memberProfileRepository,
      super(const MemberProfileState()) {
    unawaited(load());
  }

  final MemberProfileRepository _repository;

  /// Owned here so the edit-name sheet can stay a `StatelessWidget`.
  final nameFormKey = GlobalKey<FormState>();

  /// Shows the cached session profile straight away, then replaces it with
  /// a fresh copy from the server. Only an error when there's nothing
  /// cached to fall back on.
  Future<void> load() async {
    final cached = _repository.cachedProfile;
    emit(
      state.copyWith(
        status: cached == null ? MemberProfileStatus.loading : MemberProfileStatus.ready,
        profile: cached,
        clearOutcome: true,
      ),
    );
    try {
      final fresh = await _repository.refresh();
      if (!isClosed) {
        emit(state.copyWith(status: MemberProfileStatus.ready, profile: fresh));
      }
    } on MemberProfileException catch (e) {
      if (!isClosed && state.profile == null) {
        emit(
          state.copyWith(status: MemberProfileStatus.error, errorMessage: e.message),
        );
      }
    }
  }

  void startEditingName() => emit(
    state.copyWith(nameDraft: state.profile?.name ?? '', clearOutcome: true),
  );

  void nameDraftChanged(String value) => emit(state.copyWith(nameDraft: value));

  Future<void> saveName() async {
    if (state.isSavingName) return;
    if (!(nameFormKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(isSavingName: true, clearOutcome: true));
    try {
      final updated = await _repository.updateName(state.nameDraft.trim());
      if (!isClosed) {
        emit(
          state.copyWith(
            profile: updated,
            isSavingName: false,
            outcome: MemberProfileOutcome.nameSaved,
          ),
        );
      }
    } on MemberProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSavingName: false,
            outcome: MemberProfileOutcome.nameSaveFailed,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  Future<void> requestPasswordReset() async {
    final email = state.profile?.email;
    if (email == null || state.isSendingReset) return;
    emit(state.copyWith(isSendingReset: true, clearOutcome: true));
    try {
      await _repository.requestPasswordReset(email);
      if (!isClosed) {
        emit(
          state.copyWith(
            isSendingReset: false,
            outcome: MemberProfileOutcome.resetEmailSent,
          ),
        );
      }
    } on MemberProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSendingReset: false,
            outcome: MemberProfileOutcome.resetEmailFailed,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    if (!isClosed) {
      emit(state.copyWith(outcome: MemberProfileOutcome.loggedOut));
    }
  }
}
