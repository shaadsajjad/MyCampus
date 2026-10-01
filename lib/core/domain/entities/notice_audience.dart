/// Which slice of campus a notice is addressed to.
///
/// Promoted to `core/domain` for the same reason as `UserRole`: the
/// `notices` feature uses it to filter/compose/display notices, and the
/// student + teacher dashboards use it to say which slice *their* tab should
/// show (`students` / `faculty`). Two features would never disagree about
/// what these three values mean, so per `clean_architecture.md` the shared
/// vocabulary belongs in `core/` rather than being reached for across the
/// feature boundary.
///
/// The `Notice` entity itself stays in `notices/domain/entities` — it's one
/// feature's model, not shared vocabulary, and moving it would drag
/// `notices`' data layer into `core/`.
enum NoticeAudience { all, students, faculty }
