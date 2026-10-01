import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/features/routine/domain/entities/routine_course_option.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/domain/exceptions/routine_exception.dart'
    show RoutineException;

/// The contract both the super admin's routine builder and the read-only
/// "My Routine" tab (shown identically to students and teachers) code
/// against. [RoutineException] is the only failure type either needs to
/// know about.
abstract class RoutineRepository {
  /// The `universities` record id for the signed-in user.
  String? get currentUniversityId;

  /// Every slot in [currentUniversityId]'s weekly timetable, ordered by
  /// day then start time.
  Future<List<RoutineSlot>> getWeeklyRoutine();

  /// The university's course catalogue, for the "new slot" sheet's course
  /// picker.
  Future<List<RoutineCourseOption>> getCourseOptions();

  /// Adds a slot to the timetable.
  Future<void> createSlot({
    required String courseId,
    required DayOfWeek day,
    required String startTime,
    required String endTime,
    String? room,
    String? section,
  });

  Future<void> deleteSlot(String slotId);
}
