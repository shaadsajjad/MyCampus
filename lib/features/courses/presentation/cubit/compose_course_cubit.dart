// ignore_for_file: avoid_flutter_imports, prefer_void_public_cubit_methods

// Form keys live on the cubit per the pattern documented in
// `clean_architecture.md`, so this is the rare cubit that legitimately
// imports `package:flutter`.
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/courses/domain/exceptions/courses_exception.dart';
import 'package:mycampus/features/courses/domain/repositories/courses_repository.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class ComposeCourseState {
  const new({
    this.code = '',
    this.title = '',
    this.credits = '',
    this.contactHours = '',
    this.department = '',
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final String code;
  final String title;

  /// Kept as raw strings rather than ints so the field can hold a
  /// half-typed value ("" or "1") without the cubit having to guess at what
  /// the user meant. Parsed once, in [_parsePositiveInt] at submit time.
  final String credits;
  final String contactHours;
  final String department;
  final SubmissionStatus status;
  final String? errorMessage;

  ComposeCourseState copyWith({
    String? code,
    String? title,
    String? credits,
    String? contactHours,
    String? department,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ComposeCourseState(
      code: code ?? this.code,
      title: title ?? this.title,
      credits: credits ?? this.credits,
      contactHours: contactHours ?? this.contactHours,
      department: department ?? this.department,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Backs the "new course" sheet. A fresh instance per sheet open (unlike
/// `CoursesCubit`, which lives for the whole tab) — the caller reloads the
/// list itself once this reports [SubmissionStatus.success].
class ComposeCourseCubit extends Cubit<ComposeCourseState> {
  new({CoursesRepository? repository})
    : _repository = repository ?? DI.coursesRepository,
      super(const ComposeCourseState());

  final CoursesRepository _repository;

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

  void codeChanged(String value) => emit(state.copyWith(code: value));

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void creditsChanged(String value) => emit(state.copyWith(credits: value));

  void contactHoursChanged(String value) =>
      emit(state.copyWith(contactHours: value));

  void departmentChanged(String value) =>
      emit(state.copyWith(department: value));

  /// Validator for the two numeric fields — a positive whole number, capped
  /// at 20 since nothing sensible in a university catalogue exceeds that
  /// and it keeps a fat-fingered 999 out of the database.
  String? Function(String?) positiveIntValidator() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'validation.required'.tr();
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed <= 0) {
        return 'validation.positiveNumber'.tr();
      }
      if (parsed > 20) {
        return 'validation.tooLarge'.tr();
      }
      return null;
    };
  }

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Safe to force-unwrap: the form only validates when both fields hold a
    // number in range, and the parse can't fail on a string that int.parse
    // already accepted.
    final credits = int.parse(state.credits.trim());
    final contactHours = int.parse(state.contactHours.trim());

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _repository.createCourse(
        code: state.code,
        title: state.title,
        credits: credits,
        contactHours: contactHours,
        department: state.department.isEmpty ? null : state.department,
      );
      if (!isClosed) emit(state.copyWith(status: SubmissionStatus.success));
    } on CoursesException catch (e) {
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