# PocketBase schema — MyCampus

This schema is applied via migrations in `pocketbase/pb_migrations/` — copy
them into your PocketBase install's own `pb_migrations/` folder and restart
`./pocketbase serve` (it auto-applies pending migrations on startup). This
file is the human-readable reference for what those migrations create;
field names here must match each feature's own field-name string literals
exactly (`register/data/repositories/register_repository_impl.dart` writes
them; `dashboard`, `super_admin_dashboard`, `login`, and `verification`
each read the ones they need off the same records via their own
datasources) — if you rename a field here, update every feature that
touches it.

`users` holds only basic account info. Role-specific data lives in its own
collection (`students` / `teachers`), linked back via a `user` relation —
not crammed onto `users` itself.

## 1. `users` (extend the built-in auth collection)

| Field | Type | Options |
|---|---|---|
| `role` | Select (single) | `superAdmin`, `faculty`, `student` |
| `status` | Select (single) | `pending`, `approved`, `rejected` |
| `phone` | Plain text | optional |
| `university` | Relation → `universities` | optional, single |

(`avatar` is already on the built-in collection — used as-is for the
profile photo / university logo... actually logo lives on `universities`,
see below. `avatar` here is the person's own profile photo.)

## 2. `universities` (new collection, type: Base)

| Field | Type | Options |
|---|---|---|
| `name` | Plain text | required |
| `shortName` | Plain text | required |
| `type` | Select (single) | `public`, `private`, `international` |
| `city` | Plain text | required |
| `country` | Plain text | required |
| `establishedAt` | Date | optional |
| `logo` | File (single image) | optional |
| `admin` | Relation → `users` | required, single — the super admin who owns it |

## 3. `students` (new collection, type: Base)

| Field | Type | Options |
|---|---|---|
| `user` | Relation → `users` | required, single |
| `studentId` | Plain text | required |
| `department` | Plain text | optional (free text for now — see note below) |
| `batch` | Plain text | optional |

## 4. `teachers` (new collection, type: Base)

| Field | Type | Options |
|---|---|---|
| `user` | Relation → `users` | required, single |
| `teacherId` | Plain text | required |
| `department` | Plain text | optional |
| `designation` | Select (single) | `professor`, `associateProfessor`, `assistantProfessor`, `lecturer` |

## 5. `notices` (new collection, type: Base)

| Field | Type | Options |
|---|---|---|
| `title` | Plain text | required, max 140 |
| `body` | Plain text | required, max 4000 |
| `audience` | Select (single) | `all`, `students`, `faculty` |
| `university` | Relation → `universities` | required, single |
| `author` | Relation → `users` | required, single — the super admin who posted it |

Unlike a join request (which is just a `users` row filtered by `status`),
a notice is genuinely new data with nothing to piggyback on, so it gets its
own collection. `audience` picks who it's for so a reading screen can
filter without a second collection.

6. `courses` (new collection, type: Base)

The catalogue a university teaches — the thing a routine is eventually built
out of. A super admin creates courses (code, title, credits, contact hours);
nothing assigns them to students/teachers or slots them into periods yet.
| Field | Type | Options |
|---|---|---|
| `code` | Plain text | required — e.g. `CSE-101`, unique **per university** |
| `title` | Plain text | required |
| `credits` | Number | required, 1–20 |
| `contactHours` | Number | required, 1–20 — scheduled hours/week, deliberately separate from `credits` (a 4-credit course commonly meets 3×/week) |
| `department` | Plain text | optional (free text for now, matching `students`/`teachers`) |
| `university` | Relation → `universities` | required, single |

**API rules**: same shape as `notices` — `listRule`/`viewRule` are
`university = @request.auth.university`, `createRule` requires
`@request.auth.role = 'superAdmin'` *and* `university` matching the requester,
`updateRule`/`deleteRule` require `university = @request.auth.university` (so
one super admin can maintain their own catalogue but not another's).

**Uniqueness is enforced in the app, not by a PocketBase index.** A unique
index on `code` alone would be record-scoped, not university-scoped, so it
would wrongly stop two different campuses from each teaching `CSE-101`.
`CoursesRepositoryImpl.createCourse` therefore lists the university's courses
and rejects a duplicate code itself. If you ever need this at the database
level, use a compound unique on (`university`, `code`).

##

All select option values must match exactly — they're `UserRole.name` /
`AccountStatus.name` / `UniversityType.name` / `TeacherDesignation.name` /
`NoticeAudience.name` from the Dart enums.

**API rules**: `universities`, `students`, and `teachers` all have a public
`createRule` (empty string). This is necessary because each is written
right after the matching `users` record, before that account is
authenticated — tighten these once registration goes through a
server-side hook instead of sequential client writes, or once the app logs
the new account in immediately after creating it.

`notices` is the first collection scoped by university membership from day
one: `listRule`/`viewRule` are `university = @request.auth.university` (any
signed-in member of that university can read), `createRule` requires
`@request.auth.role = 'superAdmin'` *and* `university`/`author` matching the
requester, `updateRule`/`deleteRule` require `author = @request.auth.id`.
Note the field order in each rule — PocketBase's rule parser resolves a
bare field name against whichever side of `=` it's on, so writing
`@request.auth.x = y` looks up `y` as a field on `users` (the auth
collection) instead of on the record's own collection and fails to apply
with "unknown field". The record's own field always goes first.

## Notes / known simplifications

- **`registerStudent`/`registerTeacher` never set `users.university`.**
  Only `registerSuperAdmin` links a `users` record to a university (see
  `register_repository_impl.dart`) — a student or teacher registering has
  no way to say which campus they're joining; the onboarding copy
  (`roles.studentDesc`: "Scan campus QR...") describes a flow that was
  never built. Until that's fixed (e.g. a campus-id field or QR scanner on
  those forms, writing `university` into the same `createUser` call), every
  student/faculty account has an empty `university`, so `join_requests` and
  `notices` — both scoped by `university = @request.auth.university` —
  will never surface anything for them, no matter which super admin is
  looking. This doesn't block a super admin composing/reading their own
  notices; it only blocks a student/faculty screen from ever seeing them,
  and no such screen exists yet anyway (see `dashboard` below).
- `department` is free text on both `students` and `teachers`, not a
  relation to a per-university department list — `kDepartmentOptions` in
  the app (`lib/features/register/presentation/widgets/department_options.dart`)
  is a **hardcoded placeholder** dropdown, not real data. Once universities
  can define their own departments, this becomes a relation and that
  placeholder file goes away.
- `users.listRule` / `viewRule` / `updateRule` default to
  `id = @request.auth.id` (read/update your own record only) plus, as of
  the super admin dashboard and its join-requests tab, `@request.auth.role
  = 'superAdmin' && university = @request.auth.university` — a super admin
  can also list/view/update accounts in their own university, which is
  what powers the dashboard's student/faculty/pending counts and the
  approve/reject actions in `join_requests`. This is coarser than ideal
  (a super admin can update *any* field on those records, not just
  `status`) — tighten with a field-scoped server hook once that's worth
  the complexity. No other per-record rules yet (e.g. a student reading a
  classmate's record) — add those once a feature needs them.
- Registering a student/teacher/super-admin is 2 (or 3, for super admin)
  separate writes, not wrapped in a PocketBase transaction/hook. If a step
  fails partway during testing, you may need to manually delete the
  orphaned `users` record.
