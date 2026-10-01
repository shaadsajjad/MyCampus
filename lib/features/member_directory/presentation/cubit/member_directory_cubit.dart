import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/member_directory/domain/entities/directory_member.dart';
import 'package:mycampus/features/member_directory/domain/exceptions/member_directory_exception.dart';
import 'package:mycampus/features/member_directory/domain/repositories/member_directory_repository.dart';

enum MemberDirectoryStatus { loading, ready, error }

/// Which slice of the roster the list is showing. Unlike the join-requests
/// tab there's no "archived" case here — the directory only ever holds
/// approved members, so [all] is the whole roster rather than a subset.
enum MemberDirectoryFilter { all, students, faculty }

class MemberDirectoryState {
  const new({
    this.status = MemberDirectoryStatus.loading,
    this.members = const [],
    this.query = '',
    this.filter = MemberDirectoryFilter.all,
    this.errorMessage,
  });

  final MemberDirectoryStatus status;
  final List<DirectoryMember> members;
  final String query;
  final MemberDirectoryFilter filter;
  final String? errorMessage;

  int get studentCount =>
      members.where((m) => m.role == DirectoryRole.student).length;
  int get facultyCount =>
      members.where((m) => m.role == DirectoryRole.faculty).length;

  /// The members matching the active filter pill + search query — what the
  /// list actually renders. Search covers the same fields the card shows,
  /// so anything visible on a row is findable by typing it.
  List<DirectoryMember> get visibleMembers {
    final normalizedQuery = query.trim().toLowerCase();
    return members.where((member) {
      final matchesFilter = switch (filter) {
        MemberDirectoryFilter.all => true,
        MemberDirectoryFilter.students => member.role == DirectoryRole.student,
        MemberDirectoryFilter.faculty => member.role == DirectoryRole.faculty,
      };
      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;
      return member.name.toLowerCase().contains(normalizedQuery) ||
          member.email.toLowerCase().contains(normalizedQuery) ||
          (member.roleId?.toLowerCase().contains(normalizedQuery) ?? false) ||
          (member.department?.toLowerCase().contains(normalizedQuery) ??
              false);
    }).toList();
  }

  MemberDirectoryState copyWith({
    MemberDirectoryStatus? status,
    List<DirectoryMember>? members,
    String? query,
    MemberDirectoryFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MemberDirectoryState(
      status: status ?? this.status,
      members: members ?? this.members,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Loads every approved student/faculty member of the signed-in admin's
/// university for the directory tab. Mirrors `JoinRequestsCubit`'s
/// load/search/filter shape — this is a read-only screen, so there's no
/// selection, batching, or per-row busy state to carry.
class MemberDirectoryCubit extends Cubit<MemberDirectoryState> {
  new({MemberDirectoryRepository? repository})
    : _repository = repository ?? DI.memberDirectoryRepository,
      super(const MemberDirectoryState()) {
    unawaited(load());
  }

  final MemberDirectoryRepository _repository;

  Future<void> load() async {
    final universityId = _repository.currentUniversityId;
    if (universityId == null) {
      // No university to list — render the empty state rather than an
      // error, since a super admin always creates one first.
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberDirectoryStatus.ready,
            members: const [],
          ),
        );
      }
      return;
    }

    emit(state.copyWith(status: MemberDirectoryStatus.loading, clearError: true));
    try {
      final members = await _repository.getApprovedMembers(universityId);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberDirectoryStatus.ready,
            members: members,
          ),
        );
      }
    } on MemberDirectoryException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MemberDirectoryStatus.error,
            errorMessage: e.message,
          ),
        );
      }
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void setFilter(MemberDirectoryFilter filter) =>
      emit(state.copyWith(filter: filter));
}
