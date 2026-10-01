import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/courses/domain/entities/course.dart';
import 'package:mycampus/features/courses/domain/exceptions/courses_exception.dart';
import 'package:mycampus/features/courses/domain/repositories/courses_repository.dart';

enum CoursesStatus { loading, ready, error }

class CoursesState {
  const new({
    this.status = CoursesStatus.loading,
    this.courses = const [],
    this.query = '',
    this.pendingDeleteIds = const {},
    this.errorMessage,
  });

  final CoursesStatus status;
  final List<Course> courses;
  final String query;

  /// Ids currently mid-delete — lets the UI disable just that row's action
  /// instead of freezing the whole list.
  final Set<String> pendingDeleteIds;
  final String? errorMessage;

  /// Total credits across the whole catalogue — the number a super admin
  /// actually wants off this screen ("how big is this programme?"), so it's
  /// derived here rather than made the UI sum.
  int get totalCredits =>
      courses.fold(0, (sum, course) => sum + course.credits);

  /// The courses matching the search query — code, title and department are
  /// all searchable, since a super admin looking for a course may know only
  /// one of the three.
  List<Course> get visibleCourses {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return courses;
    return courses
        .where(
          (course) =>
              course.code.toLowerCase().contains(normalizedQuery) ||
              course.title.toLowerCase().contains(normalizedQuery) ||
              (course.department?.toLowerCase().contains(normalizedQuery) ??
                  false),
        )
        .toList();
  }

  CoursesState copyWith({
    CoursesStatus? status,
    List<Course>? courses,
    String? query,
    Set<String>? pendingDeleteIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoursesState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      query: query ?? this.query,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Loads the course catalogue for the super admin's university. Mirrors
/// `MemberDirectoryCubit`'s load/search shape, plus the per-row busy state
/// that deleting a course needs.
class CoursesCubit extends Cubit<CoursesState> {
  new({CoursesRepository? repository})
    : _repository = repository ?? DI.coursesRepository,
      super(const CoursesState()) {
    unawaited(load());
  }

  final CoursesRepository _repository;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    if (universityId == null) {
      // No university to list — render the empty state rather than an
      // error, since a super admin always creates one first.
      if (!isClosed) {
        emit(state.copyWith(status: CoursesStatus.ready, courses: const []));
      }
      return;
    }

    emit(state.copyWith(status: CoursesStatus.loading, clearError: true));
    try {
      final courses = await _repository.getCourses(universityId);
      if (!isClosed) {
        emit(state.copyWith(status: CoursesStatus.ready, courses: courses));
      }
    } on CoursesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: CoursesStatus.error, errorMessage: e.message),
        );
      }
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  /// Removes a course and drops it from the local list on success, so the
  /// row disappears immediately instead of waiting for a refetch.
  Future<void> delete(String id) async {
    emit(state.copyWith(pendingDeleteIds: {...state.pendingDeleteIds, id}));
    try {
      await _repository.deleteCourse(id);
      if (!isClosed) {
        emit(
          state.copyWith(
            courses: state.courses.where((c) => c.id != id).toList(),
            pendingDeleteIds: {...state.pendingDeleteIds}..remove(id),
          ),
        );
      }
    } on CoursesException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            pendingDeleteIds: {...state.pendingDeleteIds}..remove(id),
            errorMessage: e.message,
          ),
        );
      }
    }
  }
}
