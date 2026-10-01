/// A day of the week, used identically by the super admin's routine
/// builder and by the read-only routine view both students and teachers
/// see — promoted to `core/` for the same reason as `UserRole`: no two
/// features could ever disagree about what these seven values mean.
///
/// `name` (`monday`, `tuesday`, ...) must match the `dayOfWeek` Select
/// field's option values in the `routine` PocketBase collection exactly —
/// see `pocketbase_schema.md`.
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekLabel on DayOfWeek {
  /// The `en.json` key for this day's short display label.
  String get labelKey {
    switch (this) {
      case DayOfWeek.monday:
        return 'routine.monday';
      case DayOfWeek.tuesday:
        return 'routine.tuesday';
      case DayOfWeek.wednesday:
        return 'routine.wednesday';
      case DayOfWeek.thursday:
        return 'routine.thursday';
      case DayOfWeek.friday:
        return 'routine.friday';
      case DayOfWeek.saturday:
        return 'routine.saturday';
      case DayOfWeek.sunday:
        return 'routine.sunday';
    }
  }
}
