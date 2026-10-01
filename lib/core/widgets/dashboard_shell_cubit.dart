// ignore_for_file: prefer_void_public_cubit_methods

import 'package:bloc/bloc.dart';

/// Holds which tab the dashboard bottom-nav shell is showing.
///
/// This is view-local state (it isn't persisted and nothing else needs to
/// read it), but `clean_architecture.md` asks for Cubit over
/// `StatefulWidget.setState` without exception — so the shell's
/// `StatefulWidget` is gone and the index lives here instead.
///
/// [tabCount] is fixed at construction because the shell's tab list never
/// changes for a given role; it's what lets [selectTab] reject a tap that
/// falls outside the nav bar instead of emitting an index the `IndexedStack`
/// has no child for.
class DashboardShellCubit extends Cubit<int> {
  new({required int initialIndex, required int tabCount})
    : assert(initialIndex >= 0 && initialIndex < tabCount),
      _tabCount = tabCount,
      super(initialIndex);

  /// The number of tabs the shell renders — captured at construction
  /// because the tab list for a given role never changes mid-session.
  /// Read-only via the public getter so `bloc_lint.avoid_public_fields`
  /// stays green.
  final int _tabCount;
  int get tabCount => _tabCount;

  /// Taps a nav item. Ignores a tap on the already-active tab so a
  /// redundant tap can't re-emit the same value (which would rebuild
  /// the `IndexedStack` for nothing), and ignores out-of-range indexes.
  void selectTab(int index) {
    if (index < 0 || index >= tabCount) return;
    if (index == state) return;
    emit(index);
  }
}
