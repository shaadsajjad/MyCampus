import 'package:mycampus/features/routine/data/models/routine_slot_model.dart';
import 'package:mycampus/features/routine/domain/entities/routine_course_option.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `routine` feature that talks to the PocketBase SDK
/// directly — `RoutineRepositoryImpl` works with [RoutineSlotModel]/
/// [RoutineCourseOption] and `RoutineException`, never `RecordModel`/
/// `ClientException`.
abstract class RoutineRemoteDataSource {
  String? get currentUniversityId;

  Future<List<RoutineSlotModel>> getWeeklyRoutine(String universityId);

  /// Reads the `courses` collection directly — not through the `courses`
  /// feature's own repository — so `routine` stays independently owned
  /// per `clean_architecture.md`.
  Future<List<RoutineCourseOption>> getCourseOptions(String universityId);

  Future<void> createSlot({
    required String universityId,
    required String courseId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    String? section,
  });

  Future<void> deleteSlot(String slotId);
}

class RoutineRemoteDataSourceImpl implements RoutineRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  @override
  String? get currentUniversityId {
    final value = _pb.authStore.record?.getStringValue('university');
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<List<RoutineSlotModel>> getWeeklyRoutine(String universityId) async {
    final result = await _pb
        .collection('routine')
        .getList(
          page: 1,
          perPage: 500,
          filter: "university = '$universityId'",
          expand: 'course',
          sort: 'startTime',
        );
    return result.items.map(_toModel).toList();
  }

  @override
  Future<List<RoutineCourseOption>> getCourseOptions(
    String universityId,
  ) async {
    final result = await _pb
        .collection('courses')
        .getList(
          page: 1,
          perPage: 500,
          filter: "university = '$universityId'",
          sort: 'code',
        );
    return result.items
        .map(
          (record) => RoutineCourseOption(
            id: record.id,
            code: record.getStringValue('code'),
            title: record.getStringValue('title'),
          ),
        )
        .toList();
  }

  @override
  Future<void> createSlot({
    required String universityId,
    required String courseId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    String? section,
  }) {
    return _pb
        .collection('routine')
        .create(
          body: {
            'university': universityId,
            'course': courseId,
            'dayOfWeek': dayOfWeek,
            'startTime': startTime,
            'endTime': endTime,
            if (room != null && room.isNotEmpty) 'room': room,
            if (section != null && section.isNotEmpty) 'section': section,
          },
        );
  }

  @override
  Future<void> deleteSlot(String slotId) {
    return _pb.collection('routine').delete(slotId);
  }

  RoutineSlotModel _toModel(RecordModel record) {
    final course = record.get<RecordModel?>('expand.course');
    final room = record.getStringValue('room');
    final section = record.getStringValue('section');
    return RoutineSlotModel(
      id: record.id,
      courseId: record.getStringValue('course'),
      courseCode: course?.getStringValue('code') ?? '',
      courseTitle: course?.getStringValue('title') ?? '',
      dayOfWeek: record.getStringValue('dayOfWeek'),
      startTime: record.getStringValue('startTime'),
      endTime: record.getStringValue('endTime'),
      room: room.isEmpty ? null : room,
      section: section.isEmpty ? null : section,
    );
  }
}
