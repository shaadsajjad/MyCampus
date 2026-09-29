# PocketBase schema — MyCampus

This schema is applied via migrations in `pocketbase/pb_migrations/` — copy
them into your PocketBase install's own `pb_migrations/` folder and restart
`./pocketbase serve` (it auto-applies pending migrations on startup). This
file is the human-readable reference for what those migrations create;
field names here must match `lib/features/auth/data/models/` exactly — if
you rename a field in one, update the other.

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

All select option values must match exactly — they're `UserRole.name` /
`AccountStatus.name` / `UniversityType.name` / `TeacherDesignation.name`
from the Dart enums.

**API rules**: `universities`, `students`, and `teachers` all have a public
`createRule` (empty string). This is necessary because each is written
right after the matching `users` record, before that account is
authenticated — tighten these once registration goes through a
server-side hook instead of sequential client writes, or once the app logs
the new account in immediately after creating it.

## Notes / known simplifications

- `department` is free text on both `students` and `teachers`, not a
  relation to a per-university department list — `kDepartmentOptions` in
  the app (`lib/features/auth/presentation/widgets/department_options.dart`)
  is a **hardcoded placeholder** dropdown, not real data. Once universities
  can define their own departments, this becomes a relation and that
  placeholder file goes away.
- No granular per-record API rules yet (e.g. "a student can only read
  their own record") — add those once there's a dashboard that needs them.
- Registering a student/teacher/super-admin is 2 (or 3, for super admin)
  separate writes, not wrapped in a PocketBase transaction/hook. If a step
  fails partway during testing, you may need to manually delete the
  orphaned `users` record.
