// ignore_for_file: avoid_flutter_imports, prefer_void_public_cubit_methods

import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
// Form keys live on the cubit per the pattern documented in
// `clean_architecture.md`, so this is the rare cubit that legitimately
// imports `package:flutter`.
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/super_admin_profile/domain/entities/super_admin_profile.dart';
import 'package:mycampus/features/super_admin_profile/domain/exceptions/profile_exception.dart';
import 'package:mycampus/features/super_admin_profile/domain/repositories/super_admin_profile_repository.dart';

enum ProfileStatus { loading, ready, error }

/// One-shot results the page reacts to via `BlocListener` (SnackBar,
/// closing the edit sheet, navigating away after logout).
enum ProfileOutcome {
  nameSaved,
  nameSaveFailed,
  avatarSaved,
  avatarSaveFailed,
  resetEmailSent,
  resetEmailFailed,
  loggedOut,
}

class SuperAdminProfileState {
  const new({
    this.status = ProfileStatus.loading,
    this.profile,
    this.nameDraft = '',
    this.isSavingName = false,
    this.isSavingAvatar = false,
    this.isSendingReset = false,
    this.outcome,
    this.errorMessage,
  });

  final ProfileStatus status;
  final SuperAdminProfile? profile;

  /// The edit-name sheet's field value, bound via `initialValue` +
  /// `onChanged` — no `TextEditingController`.
  final String nameDraft;
  final bool isSavingName;
  final bool isSavingAvatar;
  final bool isSendingReset;

  /// Cleared at the start of each action so the listener fires again even
  /// when two actions in a row end the same way.
  final ProfileOutcome? outcome;
  final String? errorMessage;

  SuperAdminProfileState copyWith({
    ProfileStatus? status,
    SuperAdminProfile? profile,
    String? nameDraft,
    bool? isSavingName,
    bool? isSavingAvatar,
    bool? isSendingReset,
    ProfileOutcome? outcome,
    String? errorMessage,
    bool clearOutcome = false,
  }) {
    return SuperAdminProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      nameDraft: nameDraft ?? this.nameDraft,
      isSavingName: isSavingName ?? this.isSavingName,
      isSavingAvatar: isSavingAvatar ?? this.isSavingAvatar,
      isSendingReset: isSendingReset ?? this.isSendingReset,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
      errorMessage: clearOutcome ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SuperAdminProfileCubit extends Cubit<SuperAdminProfileState> {
  new({SuperAdminProfileRepository? repository})
    : _repository = repository ?? DI.superAdminProfileRepository,
      super(const SuperAdminProfileState()) {
    unawaited(load());
  }

  final SuperAdminProfileRepository _repository;

  /// Owned here so the edit-name sheet can stay a `StatelessWidget`.
  /// Kept private to satisfy `bloc_lint.avoid_public_fields`; the sheet
  /// reads it through the public getter below. (See
  /// `clean_architecture.md`: form keys deliberately live on the cubit.)
  final _nameFormKey = GlobalKey<FormState>();

  /// Public read-only accessor so the sheet can do `Form(key: cubit.nameFormKey, ...)`.
  GlobalKey<FormState> get nameFormKey => _nameFormKey;

  /// Owned here so the edit-name sheet can stay a `StatelessWidget`.

  /// Shows the cached session profile straight away, then replaces it with
  /// a fresh copy from the server. Only an error when there's nothing
  /// cached to fall back on.
  Future<void> load() async {
    final cached = _repository.cachedProfile;
    emit(
      state.copyWith(
        status: cached == null ? ProfileStatus.loading : ProfileStatus.ready,
        profile: cached,
        clearOutcome: true,
      ),
    );
    try {
      final fresh = await _repository.refresh();
      if (!isClosed) {
        emit(state.copyWith(status: ProfileStatus.ready, profile: fresh));
      }
    } on ProfileException catch (e) {
      if (!isClosed && state.profile == null) {
        emit(
          state.copyWith(status: ProfileStatus.error, errorMessage: e.message),
        );
      }
    }
  }

  void startEditingName() => emit(
    state.copyWith(nameDraft: state.profile?.name ?? '', clearOutcome: true),
  );

  void nameDraftChanged(String value) => emit(state.copyWith(nameDraft: value));

  Future<void> saveName() async {
    if (!(_nameFormKey.currentState?.validate() ?? false)) return;
    if (state.isSavingName) return;
    emit(state.copyWith(isSavingName: true, clearOutcome: true));
    try {
      final updated = await _repository.updateName(state.nameDraft.trim());
      if (!isClosed) {
        emit(
          state.copyWith(
            profile: updated,
            isSavingName: false,
            outcome: ProfileOutcome.nameSaved,
          ),
        );
      }
    } on ProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSavingName: false,
            outcome: ProfileOutcome.nameSaveFailed,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    if (state.isSavingAvatar) return;
    emit(state.copyWith(isSavingAvatar: true, clearOutcome: true));
    try {
      final updated = await _repository.updateAvatar(bytes);
      if (!isClosed) {
        emit(
          state.copyWith(
            profile: updated,
            isSavingAvatar: false,
            outcome: ProfileOutcome.avatarSaved,
          ),
        );
      }
    } on ProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSavingAvatar: false,
            outcome: ProfileOutcome.avatarSaveFailed,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  Future<void> removeAvatar() async {
    if (state.isSavingAvatar) return;
    emit(state.copyWith(isSavingAvatar: true, clearOutcome: true));
    try {
      final updated = await _repository.removeAvatar();
      if (!isClosed) {
        emit(
          state.copyWith(
            profile: updated,
            isSavingAvatar: false,
            outcome: ProfileOutcome.avatarSaved,
          ),
        );
      }
    } on ProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSavingAvatar: false,
            outcome: ProfileOutcome.avatarSaveFailed,
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
            outcome: ProfileOutcome.resetEmailSent,
          ),
        );
      }
    } on ProfileException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSendingReset: false,
            outcome: ProfileOutcome.resetEmailFailed,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    if (!isClosed) {
      emit(state.copyWith(outcome: ProfileOutcome.loggedOut));
    }
  }
}