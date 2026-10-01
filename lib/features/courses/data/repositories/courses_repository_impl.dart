import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/courses/data/datasources/courses_remote_datasource.dart';
import 'package:mycampus/features/courses/data/models/course_record_model.dart';
import 'package:mycampus/features/courses/domain/entities/course.dart';
import 'package:mycampus/features/courses/domain/exceptions/courses_exception.dart';
import 'package:mycampus/features/courses/domain/repositories/courses_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  CoursesRepositoryImpl({required CoursesRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final CoursesRemoteDataSource _remote;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  Future<List<Course>> getCourses(String universityId) {
    return _guard(() async {
      final models = await _remote.getCourses(universityId);
      return models.map(_toCourse).toList();
    });
  }

  @override
  Future<void> createCourse({
    required String code,
    required String title,
    required int credits,
    required int contactHours,
    String? department,
  }) {
    return _guard(() async {
      final universityId = _remote.currentUniversityId;
      if (universityId == null) {
        throw const CoursesException('You are not signed in to a university.');
      }
      // Checked here rather than relying on a PocketBase unique index:
      // the index is per-record, not per-university, so two campuses can
      // legitimately both teach `CSE-101` without colliding. The filter
      // below is what scopes the check to this university.
      final existing = await _remote.getCourses(universityId);
      final normalized = code.trim().toUpperCase();
      if (existing.any((c) => c.code.toUpperCase() == normalized)) {
        throw CoursesException(
          'A course with code "$normalized" already exists at your '
          'university.',
        );
      }
      await _remote.createCourse(
        universityId: universityId,
        code: normalized,
        title: title.trim(),
        credits: credits,
        contactHours: contactHours,
        department: department?.trim(),
      );
    });
  }

  @override
  Future<void> deleteCourse(String courseId) {
    return _guard(() => _remote.deleteCourse(courseId));
  }

  Course _toCourse(CourseRecordModel model) {
    return Course(
      id: model.id,
      code: model.code,
      title: model.title,
      credits: int.tryParse(model.credits) ?? 0,
      contactHours: int.tryParse(model.contactHours) ?? 0,
      department: model.department,
    );
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [CoursesException], the only failure type above this layer needs to
  /// handle. A bare 15s timeout guards against the request hanging forever
  /// (e.g. the app pointed at a host it can't actually reach), which would
  /// otherwise leave the UI stuck showing a spinner with no error and no way
  /// out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw CoursesException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const CoursesException('error.unreachableServer');
    } on CoursesException {
      // Already a domain-level failure (e.g. the duplicate-code check
      // above) — re-wrapping would bury its specific message behind the
      // generic catch-all below.
      rethrow;
    } catch (e) {
      throw CoursesException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
