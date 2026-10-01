/// DTO for a `routine` record, expanded with its related course — matches
/// PocketBase's wire format. `dayOfWeek` stays a raw string here (parsed
/// against `DayOfWeek.name` by the repository) rather than the model
/// depending on a `core/` enum.
class RoutineSlotModel {
  const new({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.section,
  });

  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String? section;
}
