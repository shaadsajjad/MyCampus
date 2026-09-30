import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/join_requests/domain/entities/member_request.dart';
import 'package:mycampus/features/join_requests/domain/exceptions/join_requests_exception.dart';
import 'package:mycampus/features/join_requests/domain/repositories/join_requests_repository.dart';

enum JoinRequestsStatus { loading, ready, error }

enum JoinRequestsFilter { allPending, students, faculty, archived }

class JoinRequestsState {
  const JoinRequestsState({
    this.status = JoinRequestsStatus.loading,
    this.members = const [],
    this.query = '',
    this.filter = JoinRequestsFilter.allPending,
    this.selectedIds = const {},
    this.pendingActionIds = const {},
    this.errorMessage,
  });

  final JoinRequestsStatus status;
  final List<MemberRequest> members;
  final String query;
  final JoinRequestsFilter filter;
  final Set<String> selectedIds;

  /// Ids currently mid-approve/reject — lets the UI disable just that
  /// card's buttons instead of freezing the whole list.
  final Set<String> pendingActionIds;
  final String? errorMessage;

  int get pendingCount =>
      members.where((m) => m.status == MemberStatus.pending).length;
  int get studentCount => members
      .where(
        (m) => m.status == MemberStatus.pending && m.role == MemberRole.student,
      )
      .length;
  int get facultyCount => members
      .where(
        (m) => m.status == MemberStatus.pending && m.role == MemberRole.faculty,
      )
      .length;
  int get archivedCount =>
      members.where((m) => m.status != MemberStatus.pending).length;

  /// The members matching the active filter pill + search query — what
  /// the list actually renders.
  List<MemberRequest> get visibleMembers {
    final normalizedQuery = query.trim().toLowerCase();
    return members.where((member) {
      final matchesFilter = switch (filter) {
        JoinRequestsFilter.allPending => member.status == MemberStatus.pending,
        JoinRequestsFilter.students =>
          member.status == MemberStatus.pending &&
              member.role == MemberRole.student,
        JoinRequestsFilter.faculty =>
          member.status == MemberStatus.pending &&
              member.role == MemberRole.faculty,
        JoinRequestsFilter.archived => member.status != MemberStatus.pending,
      };
      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;
      return member.name.toLowerCase().contains(normalizedQuery) ||
          member.email.toLowerCase().contains(normalizedQuery) ||
          (member.roleId?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }

  JoinRequestsState copyWith({
    JoinRequestsStatus? status,
    List<MemberRequest>? members,
    String? query,
    JoinRequestsFilter? filter,
    Set<String>? selectedIds,
    Set<String>? pendingActionIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JoinRequestsState(
      status: status ?? this.status,
      members: members ?? this.members,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      selectedIds: selectedIds ?? this.selectedIds,
      pendingActionIds: pendingActionIds ?? this.pendingActionIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class JoinRequestsCubit extends Cubit<JoinRequestsState> {
  JoinRequestsCubit({JoinRequestsRepository? repository})
    : _repository = repository ?? DI.joinRequestsRepository,
      super(const JoinRequestsState()) {
    unawaited(load());
  }

  final JoinRequestsRepository _repository;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    if (universityId == null) {
      if (!isClosed) {
        emit(
          state.copyWith(status: JoinRequestsStatus.ready, members: const []),
        );
      }
      return;
    }
    emit(state.copyWith(status: JoinRequestsStatus.loading, clearError: true));
    try {
      final members = await _repository.getMembers(universityId);
      if (!isClosed) {
        emit(
          state.copyWith(status: JoinRequestsStatus.ready, members: members),
        );
      }
    } on JoinRequestsException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: JoinRequestsStatus.error,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void setFilter(JoinRequestsFilter filter) =>
      emit(state.copyWith(filter: filter, selectedIds: const {}));

  void toggleSelected(String id) {
    final selected = {...state.selectedIds};
    if (!selected.add(id)) selected.remove(id);
    emit(state.copyWith(selectedIds: selected));
  }

  void selectAllVisible({required bool select}) {
    if (!select) {
      emit(state.copyWith(selectedIds: const {}));
      return;
    }
    final pendingVisible = state.visibleMembers
        .where((m) => m.status == MemberStatus.pending)
        .map((m) => m.id);
    emit(state.copyWith(selectedIds: pendingVisible.toSet()));
  }

  Future<void> approve(String id) => _updateStatus(id, MemberStatus.approved);

  Future<void> reject(String id) => _updateStatus(id, MemberStatus.rejected);

  Future<void> batchApprove() async {
    final ids = state.selectedIds.toList();
    for (final id in ids) {
      await approve(id);
    }
    emit(state.copyWith(selectedIds: const {}));
  }

  Future<void> _updateStatus(String id, MemberStatus status) async {
    emit(state.copyWith(pendingActionIds: {...state.pendingActionIds, id}));
    try {
      if (status == MemberStatus.approved) {
        await _repository.approve(id);
      } else {
        await _repository.reject(id);
      }
      final updatedMembers = [
        for (final member in state.members)
          if (member.id == id)
            MemberRequest(
              id: member.id,
              name: member.name,
              email: member.email,
              role: member.role,
              status: status,
              requestedAt: member.requestedAt,
              avatarUrl: member.avatarUrl,
              roleId: member.roleId,
              department: member.department,
              subInfo: member.subInfo,
            )
          else
            member,
      ];
      if (!isClosed) {
        emit(
          state.copyWith(
            members: updatedMembers,
            pendingActionIds: {...state.pendingActionIds}..remove(id),
            selectedIds: {...state.selectedIds}..remove(id),
          ),
        );
      }
    } on JoinRequestsException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            pendingActionIds: {...state.pendingActionIds}..remove(id),
            errorMessage: e.message,
          ),
        );
      }
    }
  }
}
