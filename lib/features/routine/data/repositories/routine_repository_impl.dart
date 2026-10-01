import 'dart:async';

import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/routine/data/datasources/routine_remote_datasource.dart';
import 'package:mycampus/features/routine/data/models/routine_slot_model.dart';
import 'package:mycampus/features/routine/domain/entities/routine_course_option.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/domain/exceptions/routine_exception.dart';
import 'package:mycampus/features/routine/domain/repositories/routine_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  new({required RoutineRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RoutineRemoteDataSource _remote;

  @override
  String? get currentUniversityId => _remote.currentUniversityId;

  @override
  Future<List<RoutineSlot>> getWeeklyRoutine() {
    return _guard(() async {
      final universityId = _requireUniversityId();
      final models = await _remote.getWeeklyRoutine(universityId);
      final slots = models.map(_toSlot).whereType<RoutineSlot>().toList();
      // PocketBase sorts `startTime` correctly (zero-padded `HH:mm`), but
      // has no way to sort `dayOfWeek` into calendar order — its Select
      // values are compared alphabetically, which isn't Monday-first. So
      // the day grouping is done here instead of trusting a `sort` param.
      slots.sort((a, b) {
        final dayCompare = a.day.index.compareTo(b.day.index);
        return dayCompare != 0
            ? dayCompare
            : a.startTime.compareTo(b.startTime);
      });
      return slots;
    });
  }

  @override
  Future<List<RoutineCourseOption>> getCourseOptions() {
    return _guard(() {
      final universityId = _requireUniversityId();
      return _remote.getCourseOptions(universityId);
    });
  }

  @override
  Future<void> createSlot({
    required String courseId,
    required DayOfWeek day,
    required String startTime,
    required String endTime,
    String? room,
    String? section,
  }) {
    return _guard(() {
      final universityId = _requireUniversityId();
      return _remote.createSlot(
        universityId: universityId,
        courseId: courseId,
        dayOfWeek: day.name,
        startTime: startTime,
        endTime: endTime,
        room: room?.trim(),
        section: section?.trim(),
      );
    });
  }

  @override
  Future<void> deleteSlot(String slotId) {
    return _guard(() => _remote.deleteSlot(slotId));
  }

  String _requireUniversityId() {
    final id = _remote.currentUniversityId;
    if (id == null) {
      throw const RoutineException('You are not signed in to a university.');
    }
    return id;
  }

  /// A slot whose `dayOfWeek` doesn't match a known [DayOfWeek] (e.g. a
  /// record edited by hand in the PocketBase dashboard) is dropped rather
  /// than crashing the whole list.
  RoutineSlot? _toSlot(RoutineSlotModel model) {
    DayOfWeek? day;
    for (final value in DayOfWeek.values) {
      if (value.name == model.dayOfWeek) day = value;
    }
    if (day == null) return null;
    return RoutineSlot(
      id: model.id,
      courseId: model.courseId,
      courseCode: model.courseCode,
      courseTitle: model.courseTitle,
      day: day,
      startTime: model.startTime,
      endTime: model.endTime,
      room: model.room,
      section: model.section,
    );
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [RoutineException], the only failure type above this layer needs to
  /// handle.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw RoutineException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const RoutineException('error.unreachableServer');
    } on RoutineException {
      rethrow;
    } catch (e) {
      throw const RoutineException('error.unknown');
    }
  }
}
