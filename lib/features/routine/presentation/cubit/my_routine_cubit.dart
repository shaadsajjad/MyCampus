import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/utils/translate_error.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/domain/exceptions/routine_exception.dart';
import 'package:mycampus/features/routine/domain/repositories/routine_repository.dart';

enum MyRoutineStatus { loading, ready, error }

class MyRoutineState {
  const new({
    this.status = MyRoutineStatus.loading,
    this.slots = const [],
    this.errorMessage,
  });

  final MyRoutineStatus status;
  final List<RoutineSlot> slots;
  final String? errorMessage;

  /// [slots] grouped by day, in calendar order — [slots] is already sorted
  /// this way by the repository.
  Map<DayOfWeek, List<RoutineSlot>> get slotsByDay {
    final grouped = <DayOfWeek, List<RoutineSlot>>{};
    for (final slot in slots) {
      (grouped[slot.day] ??= []).add(slot);
    }
    return grouped;
  }

  MyRoutineState copyWith({
    MyRoutineStatus? status,
    List<RoutineSlot>? slots,
    String? errorMessage,
  }) {
    return MyRoutineState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Read-only weekly timetable shown identically to students and teachers —
/// same contract `MemberNoticesCubit` follows for the Notices tab, just
/// without an audience filter (the whole university shares one routine).
class MyRoutineCubit extends Cubit<MyRoutineState> {
  new({RoutineRepository? repository})
    : _repository = repository ?? DI.routineRepository,
      super(const MyRoutineState()) {
    unawaited(load());
  }

  final RoutineRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: MyRoutineStatus.loading));
    try {
      final slots = await _repository.getWeeklyRoutine();
      if (!isClosed) {
        emit(state.copyWith(status: MyRoutineStatus.ready, slots: slots));
      }
    } on RoutineException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MyRoutineStatus.error,
            errorMessage: translateError(e.message),
          ),
        );
      }
    }
  }
}
