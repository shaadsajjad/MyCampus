import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/campus_pass.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/campus_pass_exception.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/campus_pass_repository.dart';

enum CampusPassAction { idle, saving, sharing }

/// One-shot results the page turns into a SnackBar via `BlocListener`.
/// A successful share has no outcome — the share sheet was the feedback.
enum CampusPassOutcome {
  saved,
  saveFailed,
  shareFailed,
  permissionDenied,
  unsupported,
}

class CampusPassState {
  const CampusPassState({this.action = CampusPassAction.idle, this.outcome});

  final CampusPassAction action;

  /// Cleared at the start of every action, so the listener fires again
  /// even when two actions in a row end the same way.
  final CampusPassOutcome? outcome;

  bool get isBusy => action != CampusPassAction.idle;
}

class CampusPassCubit extends Cubit<CampusPassState> {
  CampusPassCubit({CampusPassRepository? repository})
    : _repository = repository ?? DI.campusPassRepository,
      super(const CampusPassState());

  final CampusPassRepository _repository;

  Future<void> save(CampusPass pass) async {
    if (state.isBusy) return;
    emit(const CampusPassState(action: CampusPassAction.saving));
    try {
      await _repository.saveToGallery(pass);
      _finish(CampusPassOutcome.saved);
    } on CampusPassException catch (e, stackTrace) {
      addError(e, stackTrace);
      _finish(_outcomeFor(e, fallback: CampusPassOutcome.saveFailed));
    }
  }

  Future<void> share(
    CampusPass pass, {
    required String message,
    ShareAnchor? anchor,
  }) async {
    if (state.isBusy) return;
    emit(const CampusPassState(action: CampusPassAction.sharing));
    try {
      await _repository.share(pass, message: message, anchor: anchor);
      _finish(null);
    } on CampusPassException catch (e, stackTrace) {
      addError(e, stackTrace);
      _finish(_outcomeFor(e, fallback: CampusPassOutcome.shareFailed));
    }
  }

  void _finish(CampusPassOutcome? outcome) {
    if (!isClosed) emit(CampusPassState(outcome: outcome));
  }

  CampusPassOutcome _outcomeFor(
    CampusPassException e, {
    required CampusPassOutcome fallback,
  }) {
    return switch (e.failure) {
      CampusPassFailure.permissionDenied => CampusPassOutcome.permissionDenied,
      CampusPassFailure.unsupported => CampusPassOutcome.unsupported,
      CampusPassFailure.unknown => fallback,
    };
  }
}
