import 'package:mycampus/features/courses/domain/entities/course.dart';
import 'package:mycampus/features/courses/domain/exceptions/courses_exception.dart' show CoursesException;

/// The contract the courses tab codes against. [CoursesException] is the
/// only failure type it needs to know about — everything else (PocketBase,
/// HTTP, ...) is a data-layer detail behind this interface.
abstract class CoursesRepository {
  /// The `universities` record id this admin owns.
  String? get currentUniversityId;

  /// Every course defined for [universityId], ordered by code.
  Future<List<Course>> getCourses(String universityId);

  /// Creates a course. Throws [CoursesException] if [code] is already taken
  /// in this university.
  Future<void> createCourse({
    required String code,
    required String title,
    required int credits,
    required int contactHours,
    String? department,
  });

  /// Removes a course. Routines built on top of it will lose their slot
  /// reference — see the note in `pocketbase_schema.md` before deleting a
  /// course that a routine already points at.
  Future<void> deleteCourse(String courseId);
}
