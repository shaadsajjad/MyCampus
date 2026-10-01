// ignore_for_file: avoid_flutter_imports, prefer_void_public_cubit_methods

// Form keys live on the cubit per the pattern documented in
// `clean_architecture.md`, so this is the rare cubit that legitimately
// imports `package:flutter`.
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/utils/translate_error.dart';
import 'package:mycampus/features/routine/domain/entities/routine_course_option.dart';
import 'package:mycampus/features/routine/domain/exceptions/routine_exception.dart';
import 'package:mycampus/features/routine/domain/repositories/routine_repository.dart';
import 'package:mycampus/features/routine/presentation/widgets/app_time_field.dart'
    show AppTimeField;

enum SubmissionStatus { idle, submitting, success, failure }

class ComposeRoutineSlotState {
  const new({
    this.courseOptions = const [],
    this.isLoadingCourses = true,
    this.courseId,
    this.day,
    this.startTime,
    this.endTime,
    this.room = '',
    this.section = '',
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final List<RoutineCourseOption> courseOptions;
  final bool isLoadingCourses;

  final String? courseId;
  final DayOfWeek? day;

  /// 24h `HH:mm`, set via [AppTimeField]'s native time picker — never
  /// free-typed, so no format validation is needed on these two.
  final String? startTime;
  final String? endTime;

  final String room;
  final String section;
  final SubmissionStatus status;
  final String? errorMessage;

  ComposeRoutineSlotState copyWith({
    List<RoutineCourseOption>? courseOptions,
    bool? isLoadingCourses,
    String? courseId,
    DayOfWeek? day,
    String? startTime,
    String? endTime,
    String? room,
    String? section,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ComposeRoutineSlotState(
      courseOptions: courseOptions ?? this.courseOptions,
      isLoadingCourses: isLoadingCourses ?? this.isLoadingCourses,
      courseId: courseId ?? this.courseId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      section: section ?? this.section,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Backs the "new routine slot" sheet. A fresh instance per sheet open
/// (unlike `RoutineCubit`, which lives for the whole page) — the caller
/// reloads the list itself once this reports [SubmissionStatus.success].
class ComposeRoutineSlotCubit extends Cubit<ComposeRoutineSlotState> {
  new({RoutineRepository? repository})
    : _repository = repository ?? DI.routineRepository,
      super(const ComposeRoutineSlotState()) {
    unawaited(_loadCourseOptions());
  }

  final RoutineRepository _repository;

  /// Owned here so the compose sheet can stay a `StatelessWidget` while
  /// still validating on submit. (See `clean_architecture.md`: form keys
  /// deliberately live on the cubit.)
  final _formKey = GlobalKey<FormState>();

  /// Public read-only accessor so the sheet can do `Form(key: cubit.formKey, ...)`.
  GlobalKey<FormState> get formKey => _formKey;

  Future<void> _loadCourseOptions() async {
    try {
      final options = await _repository.getCourseOptions();
      if (!isClosed) {
        emit(state.copyWith(courseOptions: options, isLoadingCourses: false));
      }
    } on RoutineException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingCourses: false,
            errorMessage: translateError(e.message),
          ),
        );
      }
    }
  }

  void courseChanged(String? value) => emit(state.copyWith(courseId: value));

  void dayChanged(DayOfWeek? value) => emit(state.copyWith(day: value));

  void startTimeChanged(String value) =>
      emit(state.copyWith(startTime: value, clearError: true));

  void endTimeChanged(String value) =>
      emit(state.copyWith(endTime: value, clearError: true));

  void roomChanged(String value) => emit(state.copyWith(room: value));

  void sectionChanged(String value) => emit(state.copyWith(section: value));

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final courseId = state.courseId;
    final day = state.day;
    final start = state.startTime;
    final end = state.endTime;
    if (courseId == null || day == null || start == null || end == null) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: 'validation.required'.tr(),
        ),
      );
      return;
    }
    if (end.compareTo(start) <= 0) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: 'routine.endBeforeStart'.tr(),
        ),
      );
      return;
    }

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _repository.createSlot(
        courseId: courseId,
        day: day,
        startTime: start,
        endTime: end,
        room: state.room.isEmpty ? null : state.room,
        section: state.section.isEmpty ? null : state.section,
      );
      if (!isClosed) emit(state.copyWith(status: SubmissionStatus.success));
    } on RoutineException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SubmissionStatus.failure,
            errorMessage: translateError(e.message),
          ),
        );
      }
    }
  }
}
