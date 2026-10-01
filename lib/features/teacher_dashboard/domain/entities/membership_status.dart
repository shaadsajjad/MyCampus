/// Where a teacher stands with a university. [none] covers both "never
/// scanned a campus QR" and the registration-time default `users.status`
/// of `pending` that's meaningless until `university` is actually set —
/// see `pocketbase_schema.md`'s note on `registerTeacher` never linking a
/// university. [pending]/[approved]/[rejected] only apply once a join
/// request has actually been sent.
enum MembershipStatus { none, pending, approved, rejected }
