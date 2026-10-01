import 'package:mycampus/core/domain/entities/day_of_week.dart';

/// One weekly, recurring class period: a course meeting on a given day, in
/// a given time window. The university-wide timetable a super admin
/// builds out of the `courses` catalogue, read by every student and
/// teacher at that university.
class RoutineSlot {
  const new({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
    this.section,
  });

  /// The `routine` record id.
  final String id;

  /// The `courses` record id this slot is for.
  final String courseId;

  /// Denormalized off the related course (via a PocketBase `expand`) so a
  /// slot card never needs a second fetch to show what it's for.
  final String courseCode;
  final String courseTitle;

  final DayOfWeek day;

  /// 24h `HH:mm`, e.g. `09:30`. No native PocketBase time field exists, and
  /// a zero-padded string already sorts correctly — a `DateTime` would
  /// carry a meaningless date component for what's really a time of day.
  final String startTime;
  final String endTime;

  final String? room;
  final String? section;
}
