import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/utils/translate_error.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/domain/exceptions/routine_exception.dart';
import 'package:mycampus/features/routine/domain/repositories/routine_repository.dart';

enum RoutineStatus { loading, ready, error }

class RoutineState {
  const new({
    this.status = RoutineStatus.loading,
    this.slots = const [],
    this.pendingDeleteIds = const {},
    this.errorMessage,
  });

  final RoutineStatus status;
  final List<RoutineSlot> slots;

  /// Ids currently mid-delete — lets the UI disable just that row's action
  /// instead of freezing the whole list.
  final Set<String> pendingDeleteIds;
  final String? errorMessage;

  /// [slots] grouped by day, in calendar order (Monday first) — [slots]
  /// itself is already sorted this way by the repository, so this just
  /// partitions it.
  Map<DayOfWeek, List<RoutineSlot>> get slotsByDay {
    final grouped = <DayOfWeek, List<RoutineSlot>>{};
    for (final slot in slots) {
      (grouped[slot.day] ??= []).add(slot);
    }
    return grouped;
  }

  RoutineState copyWith({
    RoutineStatus? status,
    List<RoutineSlot>? slots,
    Set<String>? pendingDeleteIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoutineState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Loads the weekly timetable for the super admin's university. Mirrors
/// `CoursesCubit`'s load/delete shape.
class RoutineCubit extends Cubit<RoutineState> {
  new({RoutineRepository? repository})
    : _repository = repository ?? DI.routineRepository,
      super(const RoutineState()) {
    unawaited(load());
  }

  final RoutineRepository _repository;

  Future<void> load() async {
    if (_repository.currentUniversityId == null) {
      // No university to build a routine for — render the empty state
      // rather than an error, matching `CoursesCubit`.
      if (!isClosed) {
        emit(state.copyWith(status: RoutineStatus.ready, slots: const []));
      }
      return;
    }

    emit(state.copyWith(status: RoutineStatus.loading, clearError: true));
    try {
      final slots = await _repository.getWeeklyRoutine();
      if (!isClosed) {
        emit(state.copyWith(status: RoutineStatus.ready, slots: slots));
      }
    } on RoutineException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: RoutineStatus.error,
            errorMessage: translateError(e.message),
          ),
        );
      }
    }
  }

  /// Removes a slot and drops it from the local list on success, so the
  /// row disappears immediately instead of waiting for a refetch.
  Future<void> delete(String id) async {
    emit(state.copyWith(pendingDeleteIds: {...state.pendingDeleteIds, id}));
    try {
      await _repository.deleteSlot(id);
      if (!isClosed) {
        emit(
          state.copyWith(
            slots: state.slots.where((s) => s.id != id).toList(),
            pendingDeleteIds: {...state.pendingDeleteIds}..remove(id),
          ),
        );
      }
    } on RoutineException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            pendingDeleteIds: {...state.pendingDeleteIds}..remove(id),
            errorMessage: translateError(e.message),
          ),
        );
      }
    }
  }
}
