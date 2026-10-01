/// A user-facing failure from the routine feature. [message] is either an
/// already human-readable string (PocketBase's own error text) or a
/// translation key under `error.*` (`error.unreachableServer`,
/// `error.unknown`) — run it through `translateError()`
/// (`core/utils/translate_error.dart`) before showing it.
class RoutineException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}
