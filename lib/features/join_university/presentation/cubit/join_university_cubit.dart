// ignore_for_file: prefer_void_public_cubit_methods

import 'package:bloc/bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/join_university/domain/entities/university_preview.dart';
import 'package:mycampus/features/join_university/domain/exceptions/join_university_exception.dart';
import 'package:mycampus/features/join_university/domain/repositories/join_university_repository.dart';

enum JoinUniversityStatus {
  scanning,
  lookingUp,
  previewReady,
  submitting,
  success,
  failure,
}

class JoinUniversityState {
  const new({
    this.status = JoinUniversityStatus.scanning,
    this.manualCode = '',
    this.preview,
    this.errorMessage,
  });

  final JoinUniversityStatus status;
  final String manualCode;
  final UniversityPreview? preview;
  final String? errorMessage;

  JoinUniversityState copyWith({
    JoinUniversityStatus? status,
    String? manualCode,
    UniversityPreview? preview,
    String? errorMessage,
    bool clearPreview = false,
  }) {
    return JoinUniversityState(
      status: status ?? this.status,
      manualCode: manualCode ?? this.manualCode,
      preview: clearPreview ? null : (preview ?? this.preview),
      errorMessage: errorMessage,
    );
  }
}

/// Drives the "scan campus QR / type the code, preview, confirm" flow.
/// Owns the [MobileScannerController] itself (same convention as a Cubit
/// owning a `TextEditingController`/`GlobalKey` elsewhere in the app) so the
/// page can stay a `StatelessWidget`.
class JoinUniversityCubit extends Cubit<JoinUniversityState> {
  new({JoinUniversityRepository? repository})
    : _repository = repository ?? DI.joinUniversityRepository,
      super(const JoinUniversityState());

  final JoinUniversityRepository _repository;
  final MobileScannerController _scannerController = MobileScannerController();

  /// Public read-only accessor for the QR scanner. The page widget calls
  /// `MobileScanner(controller: cubit.scannerController, ...)`, which is
  /// why we need a getter — the field itself stays private to satisfy
  /// `bloc_lint.avoid_public_fields`.
  MobileScannerController get scannerController => _scannerController;

  bool _busy = false;

  void updateManualCode(String value) =>
      emit(state.copyWith(manualCode: value));

  Future<void> submitManualCode() => lookupCode(state.manualCode);

  Future<void> lookupCode(String rawCode) async {
    final code = rawCode.trim();
    // The page disables the lookup action while [manualCode] is empty, and a
    // detected QR code is never an empty string — this is just a defensive
    // no-op, not a user-facing validation path.
    if (_busy || code.isEmpty) return;

    _busy = true;
    await _scannerController.stop();
    emit(state.copyWith(status: JoinUniversityStatus.lookingUp));
    try {
      final preview = await _repository.lookupUniversity(code);
      emit(
        state.copyWith(
          status: JoinUniversityStatus.previewReady,
          preview: preview,
        ),
      );
    } on JoinUniversityException catch (e) {
      emit(
        state.copyWith(
          status: JoinUniversityStatus.failure,
          errorMessage: e.message,
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> confirmJoin() async {
    final preview = state.preview;
    if (preview == null || _busy) return;

    _busy = true;
    emit(state.copyWith(status: JoinUniversityStatus.submitting));
    try {
      await _repository.requestToJoin(preview.id);
      emit(state.copyWith(status: JoinUniversityStatus.success));
    } on JoinUniversityException catch (e) {
      emit(
        state.copyWith(
          status: JoinUniversityStatus.failure,
          errorMessage: e.message,
        ),
      );
    } finally {
      _busy = false;
    }
  }

  /// Discards the current preview/error and resumes the live camera feed.
  Future<void> resumeScanning() async {
    emit(const JoinUniversityState().copyWith(manualCode: state.manualCode));
    await _scannerController.start();
  }

  @override
  Future<void> close() async {
    await _scannerController.dispose();
    await super.close();
  }
}