# Clean Architecture — MyCampus

This document defines the architectural conventions for the MyCampus Flutter
app. Follow it for every new feature; existing code should be brought in
line with it as it's touched.

## Layers

Each feature lives under `lib/features/<feature_name>/` and is split into
up to three layers:

```
lib/features/<feature_name>/
  data/            # data sources + repository implementations
    datasources/   # remote (API) / local (SharedPreferences, DB) sources
    models/        # DTOs — serialization for the outside world
    repositories/  # implements the domain repository interfaces
  domain/          # pure Dart, no Flutter/package imports where avoidable
    entities/      # app-level models (enums, value objects)
    repositories/  # abstract repository contracts
    usecases/      # one class per business operation (only when it earns
                    # its keep — trivial reads/writes can call the
                    # repository directly from the cubit)
  presentation/    # Flutter UI
    cubit/         # state + business logic for this feature's screens
    models/        # presentation-only view data (e.g. Flutter-typed
                    # config for a widget — IconData/Color pairings a
                    # domain entity can't hold and a data DTO isn't).
                    # Only add this folder once a widget's config has
                    # grown past a couple of loose parameters.
    pages/         # route-level widgets (wired to a cubit via BlocProvider)
    widgets/       # feature-local, reusable widgets
```

`presentation/models` vs `data/models`: the former is Flutter-typed view
data that only ever flows into a widget's constructor (see `RoleOption` in
the `onboarding` feature); the latter is a serialization DTO that only ever
flows into a repository. Neither belongs in `domain/entities`, which must
stay pure Dart.

## Features own their data and domain — no cross-feature repositories

Every feature that talks to PocketBase (`login`, `register`, `verification`,
`dashboard`, `super_admin_dashboard`, `join_requests`,
`super_admin_profile`, `notices`) has its **own**
`domain/repositories` contract, its **own** `data/datasources` +
`data/repositories` implementing it, and its **own** domain
entities/exceptions — even where that means two
features each define a small type for the same underlying concept (e.g.
`login`, `verification`, `dashboard`, and `super_admin_dashboard` each read
the same PocketBase `users` record, but none of them import a shared
`AuthUser`; each just reads the handful of fields it actually needs off its
own datasource). A widget in `dashboard/` never imports
`login/domain/repositories/login_repository.dart`, and `register/` never
reaches into `dashboard/`'s anything.

This is a deliberate trade-off, not an oversight: a `_guard`/try-catch
wrapper and a couple of DTO fields end up duplicated across features, but in
exchange a feature can be read, tested, and changed on its own — no feature
graph to trace through to know what `login` is allowed to touch. The one
thing every feature's PocketBase-backed repository *does* share is the
raw `PocketBase` client from `DI.pocketBase` (see below) — that has to be
the same instance everywhere, or a session started by `login` wouldn't be
visible to `dashboard`.

Two things still belong in `core/` despite this:

- A type genuinely used **the same way** by most of the app — `UserRole` is
  the standing example: routing, the role chip, and every registration
  screen all switch on the exact same three values. `NoticeAudience` is the
  second: the `notices` feature filters/composes/displays by it, and both
  dashboards name which slice their tab shows (`students` / `faculty`), so no
  two features could ever disagree about its three values. That's different
  from "two features both happen to read a user's name," which each just
  does locally. When promoting, promote **only the shared vocabulary** —
  `NoticeAudience` moved to `core/domain/entities/notice_audience.dart` while
  `Notice` itself stayed in `notices/domain/entities`, since moving the entity
  would have dragged a feature's data layer into `core/`.
- **View-local state still gets a Cubit.** There is no `setState`
  carve-out: `DashboardShell`'s bottom-nav index lives in
  `core/widgets/dashboard_shell_cubit.dart` and the shell is a plain
  `StatelessWidget`. A cubit with no repository is normal — a cubit only
  needs an injectable dependency when it has one to inject.
- A tab body embedded in another feature's shell may legitimately import
  that shell's shared vocabulary, but it must not import the *other*
  feature's pages. `MemberNoticesPage`/`MemberProfilePage` are deliberately
  `Scaffold`-less bodies of `DashboardShell`'s `IndexedStack`, so they stay
  in their own features rather than moving to `core/` (that would make
  `core/` depend on feature data) or becoming routes (that would drop the
  bottom nav and the per-tab state).
- Generic, non-feature-shaped logic — `core/utils/pocketbase_error.dart`
  (`pocketBaseErrorMessage`) turns a PocketBase `ClientException` into a
  message string; it's identical, mechanical parsing in every feature's
  `_guard`, not a business rule any one feature owns, so it's shared code
  rather than five copies of the same nine lines. Each feature still
  defines its own exception *type* (`LoginException`, `RegisterException`,
  ...) — only the string-extraction is shared.

If you're unsure which side of the line something falls on, ask whether two
features would ever disagree about it. `UserRole.superAdmin` means the same
thing everywhere — promote it. "What a dashboard needs to know about the
current user" is answered differently by `dashboard` (name/email/pending
status) and `super_admin_dashboard` (name/email/university id) — keep it
local to each.

## `lib/core/` — shared across features

Anything more than one feature needs lives in `core/`, not inside whichever
feature happened to need it first:

```
lib/core/
  domain/entities/  # entities used the same way by most of the app (e.g.
                     # UserRole — routing, the role chip, and every
                     # registration screen all switch on it identically).
                     # A single-feature entity stays in that feature's own
                     # domain/entities — see "Features own their data and
                     # domain" above for where this line is.
  di/               # dependency injection
  router/           # AppRouter, AppRoute
  theme/            # AppColors, AppTheme, AppTextStyles, light/dark ThemeData
  utils/            # pure-Dart helpers (e.g. Validators,
                     # pocketBaseErrorMessage)
  widgets/          # generic, feature-agnostic UI chrome — either
                     # feature-blind (PrimaryActionButton, AppImagePickerField)
                     # or form-shaped widgets used by 2+ features
                     # (AppTextField, AppPasswordField, FieldLabel,
                     # AuthScaffold, AuthFooterLink, RoleContextChip — used
                     # by both `login` and `register`). A widget only one
                     # feature uses stays in that feature's own
                     # presentation/widgets even if it looks generic
                     # (AppDropdownField, AppMonthYearField, FormSectionCard
                     # currently only serve `register`).
  constants/        # e.g. AppAssets — centralized asset paths
```

If you're duplicating a `switch` over an enum, a color, a string literal,
or a widget across two features, that's the signal to promote it to
`core/`, not to import one feature's `presentation/` from another's. But
promote the *type/widget*, not the feature's whole vocabulary around it —
see "Features own their data and domain" above.

**Not every feature needs all three layers.** A feature with no persistence
or business rules beyond transient UI state (e.g. `splash`) only needs
`presentation/`. Add `domain/` once you have entities or contracts worth
naming. Add `data/` once there's a real data source (API, local storage) to
wrap — don't create empty layers "for completeness."

Dependency direction is always inward: `presentation` depends on `domain`,
`data` depends on `domain`, and `domain` depends on nothing else in the app.
Widgets never import a `data/` class directly.

## State management: Cubit only

- All state is managed with `flutter_bloc` **Cubit**, never `Bloc` and never
  `StatefulWidget.setState`. If a widget needs local mutable state, that
  state belongs in a Cubit, even if it's UI-only (e.g. a toggle).
- The same goes for any other state a widget would have to hold:
  `TextEditingController`, `AnimationController`, a `GlobalKey` field.
  Form keys live on the Cubit; fields bind via `initialValue` +
  `onChanged`; anything that needs a rendered widget's pixels (e.g. an
  exported image) is drawn in the data layer instead (see
  `CampusPassImageRenderer`).
- One Cubit per screen/feature slice. Cubits are provided at the page level
  with `BlocProvider` and read with `context.read<T>()` /
  `context.watch<T>()` / `BlocBuilder` / `BlocListener`.
- Cubit state classes are immutable; mutate via `copyWith`.
- Side effects that should happen once (navigation, snackbars) go through
  `BlocListener`, not `BlocBuilder`.
- **Forms**: bind `TextFormField`/`DropdownButtonFormField` via
  `initialValue` + `onChanged` straight to the Cubit — no
  `TextEditingController` and no wrapping the page in a `StatefulWidget`
  just to own one. A `Form`'s `GlobalKey<FormState>` is a plain final field
  on the Cubit (created in its constructor), so a `StatelessWidget` page can
  still call `cubit.formKey.currentState!.validate()` on submit. See
  `LoginCubit` (in `login`) / `SuperAdminRegisterCubit` (in `register`).

## Routing: go_router

- All navigation goes through `AppRouter` (`lib/core/router/app_router.dart`)
  using `go_router`. Route paths are named constants on `AppRoute` — never
  hardcode a path string at the call site.
- Screens don't manage their own navigation state (see the old
  splash/onboarding "phase" switch this replaced) — a screen either reads
  its own route's location, or a Cubit emits a state that a `BlocListener`
  turns into a `context.go(...)` / `context.push(...)` call.
- Add a route by adding a `GoRoute` to `AppRouter.router` and a constant to
  `AppRoute`.
- Navigation method matters: `context.go(...)` **replaces** the stack (used
  for splash → onboarding — you should never be able to go back to splash).
  `context.push(...)` **pushes** (used for onboarding → login/register, so
  the auto-added back button returns to role selection). `context.
  pushReplacement(...)` swaps the top route without growing the stack (used
  to toggle between login ↔ register for the same role — it's one flow, not
  a drill-down).
- Data that a route needs (e.g. which `UserRole` a login/register screen is
  for) travels as a **query param** (`AppRoute.loginPathFor(role)` →
  `/auth/login?role=student`), not `state.extra` — it survives a refresh/
  deep link and keeps the route parseable on its own.

## Localization: `en.json` via easy_localization

- All user-facing strings live in `assets/translations/en.json`, grouped by
  feature/domain (`app`, `common`, `roles`, `splash`, `login`, `register`,
  ...) — a section doesn't have to map 1:1 to a `lib/features/` folder
  (`student`/`teacher`/`admin` are grouped by role since both `register`
  and, eventually, that role's dashboard use them).
- In widgets, read strings with the `easy_localization` extension:
  `'roles.selectRole'.tr()`. Don't hardcode user-facing text in Dart.
- Adding a new locale means adding `assets/translations/<locale>.json` and
  listing the `Locale` in `supportedLocales` in `lib/app/view/app.dart`.
- The old `flutter gen-l10n` / ARB pipeline (`lib/l10n/arb`, `lib/l10n/gen`,
  `l10n.yaml`) has been removed — it duplicated this and was unused.

## Theming: TextTheme, not raw TextStyle constants

- `lib/core/theme/text_styles.dart` (`AppTextStyles`) defines the **type
  scale only** (font size/weight/line-height/letter-spacing) — no color.
- `lib/core/theme/light_theme.dart` / `dark_theme.dart` fold that scale into
  a `TextTheme`, tinting each slot with the appropriate color from that
  theme's `ColorScheme`. This is what makes dark mode legible — a raw
  `AppTextStyles.bodySm` baked a light-mode color in permanently, which is
  exactly the kind of bug this convention avoids.
- **UI code must read text styles from
  `Theme.of(context).textTheme.<slot>`**, not from `AppTextStyles`
  directly. `AppTextStyles` should only be referenced inside the theme
  files that build the `ThemeData`.
- Colors come from `Theme.of(context).colorScheme` (or `AppColors` for
  brand colors with no scheme slot); spacing/radii come from `AppTheme`.

## Environment config and dependency injection

- **`core/config/app_config.dart`** (`AppConfig`) holds per-flavor values
  (right now: the PocketBase base URL). It's set once, in `main_*.dart`,
  before `bootstrap()` runs — never read `AppConfig` before that or hardcode
  an environment URL at a call site.
- Three flavors, three entrypoints: `main_development.dart`,
  `main_staging.dart`, `main_production.dart`. Run with `flutter run -t
  lib/main_development.dart` (etc.), matching the existing Xcode/Android
  flavor setup. Development's PocketBase URL auto-switches to `10.0.2.2`
  on the Android emulator, since it can't reach the host's `127.0.0.1`.
  Staging/production URLs are placeholders — replace them once those
  environments exist.
- **`core/di/di.dart`** (`DI`) is a small manual service locator — no
  `get_it`/`injectable`, just static singletons built in `DI.init()`
  (called once from `bootstrap()`, after `AppConfig.init()`). It's the one
  place in the app allowed to know about every feature's data layer at
  once (that's what a composition root is for): it builds the single
  shared `PocketBase` client (with a `SharedPreferences`-backed
  `AsyncAuthStore` so login survives an app restart), then wires that same
  client into each feature's own datasource + repository —
  `loginRepository`, `registerRepository`, `verificationRepository`,
  `dashboardRepository`, `superAdminDashboardRepository`. No feature reads
  another feature's `DI.*Repository`.
- A Cubit that needs a repository takes it as an **optional constructor
  param defaulting to the matching `DI` singleton**:
  ```dart
  LoginCubit({LoginRepository? loginRepository})
      : _loginRepository = loginRepository ?? DI.loginRepository,
        super(const LoginState());
  ```
  Call sites stay simple (`LoginCubit()`), while tests can inject a fake.
- **A `core/` service must not read `DI` back.** `core/` already sits
  *above* `DI` in the import graph (`DI` imports every feature's data layer),
  so a `core/service` that does `DI.pocketBase` closes a cycle that only
  resolves because Dart tolerates it. `AuthRefreshService` takes the client
  as a constructor param — `AuthRefreshServiceImpl(pocketBase)`, wired in
  `DI.init()` — the same shape `DeepLinkService.init({verificationRepository})`
  already uses. Its public method returns `bool` (did the refresh land?), not
  a `RecordModel`, so no PocketBase type crosses back out of `core/`.
- **Data-layer errors**: a repository method wraps its PocketBase call in a
  `try`/`on ClientException catch` (each feature's own private `_guard`)
  and rethrows a domain-level, feature-owned exception (`LoginException`,
  `RegisterException`, `VerificationException`, ...) — the only failure
  type a Cubit in that feature ever needs to catch. Cubits never import
  `package:pocketbase`. The `ClientException` → message text parsing itself
  is identical everywhere, so it isn't copy-pasted: every `_guard` calls
  the shared `pocketBaseErrorMessage()` (`core/utils/pocketbase_error.dart`)
  and wraps the result in its own exception type.
- **Form submission lifecycle**: `SubmissionStatus` (`idle` /
  `submitting` / `success` / `failure`) lives in a Cubit's state alongside
  an `errorMessage`. The page wraps its `Form` in a `BlocListener` that
  reacts once per status change (`listenWhen: previous.status !=
  current.status`) — a SnackBar on success/failure, navigation on success.
  The submit button reads `status` via `BlocBuilder` to show
  `PrimaryActionButton(isLoading: ...)`.

## Feature map

- `splash` — shows the logo for a fixed delay (`SplashCubit`, 3s), then
  navigates to `onboarding` via `go_router`. Presentation-only; no domain
  layer needed since it holds no business state.
- `onboarding` — role selection + login/register toggle. Has a `domain`
  layer (`AuthMode` entity; `UserRole` itself lives in `core/domain` since
  `login`, `register`, and `dashboard` all switch on it too) because that
  vocabulary is shared across the feature's widgets; no `data` layer yet
  since nothing is persisted — add one (e.g. `OnboardingRepository` backed
  by `SharedPreferences`) if/when onboarding needs to remember completion
  or the chosen role across launches.
- `login` — the one login screen serving all three roles. Its
  `LoginRepository` is deliberately tiny: `login()` and
  `requestVerification()` (for the "resend" action when login fails
  because the account isn't verified) — the cubit never needs the
  resulting user back, so `LoginRemoteDataSource`/`LoginRepositoryImpl`
  don't parse a `RecordModel` into anything, they just call PocketBase and
  translate failures into `LoginException`.
- `register` — one feature, one screen per role (`SuperAdminRegisterPage`,
  `StudentRegisterPage`, `TeacherRegisterPage` — the three forms share
  almost no fields, so they don't share a screen, but they do share this
  feature's `RegisterRepository`/`RegisterException`/widgets). `domain/
  entities` holds `AccountStatus` (pending/approved/rejected — students
  and teachers need a super admin's approval; super admins are
  auto-approved since they create the university) and the two
  role-specific enums `UniversityType`/`TeacherDesignation`. `data/
  datasources/register_remote_datasource.dart` is the only file that
  imports `pocketbase`/sees a `RecordModel` — its methods return just the
  new record's id (or nothing), since that's all `RegisterRepositoryImpl`
  ever needs back to link a `students`/`teachers`/`universities` record to
  its `users` record. PocketBase collections mirror the role split too:
  `users` holds only basic account info (email, name, phone, role, status,
  university); role-specific fields live in their own `students` /
  `teachers` collections, linked back via a `user` relation — not crammed
  onto `users`. `presentation/widgets` (`AppDropdownField`,
  `AppMonthYearField`, `FormSectionCard`, `department_options.dart`) are
  specific to this feature's longer forms; `AppTextField`,
  `AppPasswordField`, `AuthScaffold`, `AuthFooterLink`, `RoleContextChip`
  are shared with `login` instead, so they live in `core/widgets`.
- `verification` — the "check your email" screen reached after
  registering, plus the deep-link confirmation flow. `VerificationRepository`
  is shaped around exactly two call sites: `confirmVerification`/
  `requestVerification`, and `loginIfVerified` — logs in, reports the
  account's `verified` flag, and logs back out again itself if it's still
  `false`, so the cubit's polling fallback (`checkVerificationStatus`,
  since PocketBase has no "check verified" endpoint that doesn't also
  authenticate) never has to remember to clean up a half-verified session.
  `core/services/deep_link_service.dart` also depends on this feature's
  repository (as a fallback for confirming a token when no
  `VerificationCubit` is on screen to claim it) — the one `core/` → feature
  dependency in the app, predating this doc's "features own their data"
  rule; left as-is rather than inverted for a single call site.
- `dashboard` — landing page shown after a successful login or registration
  (`context.go(AppRoute.dashboard)`, replacing the stack — you shouldn't be
  able to back out to login). `DashboardPage` is a router, not a screen: it
  provides `DashboardCubit` and a `BlocSelector` on its `role` hands each
  role off to its own dashboard — `SuperAdminDashboardPage`,
  `StudentDashboardPage`, or `TeacherDashboardPage` (the widget never reads a
  repository itself). `DashboardView` survives only as the `null`-role
  fallback for the normally-unreachable no-signed-in-user case. Its own
  `DashboardRepository` stays deliberately minimal — role, name, email,
  whether the account is still pending, plus `logout()` — because the
  per-role dashboards each answer "what does the current user need" in their
  own vocabulary (see `student_dashboard`/`teacher_dashboard` below). It does
  not grow a field the moment some other feature wants one.
- `student_dashboard` — the student's home after login/registration. One page
  that renders three states off a single `StudentDashboardCubit.load`:
  join prompt (no university / rejected), "waiting for approval" (pending),
  or the full home screen (approved) — a digital ID card, today's schedule,
  bulletins, attendance progress, and an academic-tools bento. Presentation
  is split `widgets/student_home_view.dart` plus a `widgets/sections/`
  folder, one file per section. Full `domain`/`data` split with
  `StudentProfile`/`StudentUniversity`/`MembershipStatus` entities, two
  DTOs, and a repository that reads name/email/avatar + membership
  synchronously off the shared auth store and fetches university/profile
  lazily. The key piece is `watchCurrentUser` — a realtime subscription on
  the student's own `users` record that, on change, calls
  `DI.authRefreshService.refreshCurrentUser()` (re-fetching the record into
  the shared auth store) and re-runs `load`, so an approval made by a super
  admin flips the screen without a re-login. The pending → approved
  transition sets a one-shot `justApproved` flag for a welcome snackbar.
- `teacher_dashboard` — the faculty mirror of `student_dashboard`, built to
  the same shape on purpose: its own `TeacherProfile`/`TeacherUniversity`/
  `MembershipStatus`, its own DTOs, its own `_guard`/
  `TeacherDashboardException`, its own copy of the realtime
  `watchCurrentUser` → `refreshCurrentUser` → `load` cycle, and its own
  `widgets/sections/` (faculty ID card, teaching schedule,
  announcements, academic telemetry, quick actions). None of it is shared
  with `student_dashboard` — including `MembershipStatus`, which is two
  one-line doc-comment variants of the same enum, per "features own their
  data and domain" above.
- `super_admin_dashboard` — the super admin's home screen: their
  university's identity, a scannable join-code QR (`qr_flutter`), live
  student/faculty/pending-request counts, and a join-requests banner. Has
  its own full `domain`/`data` split — `University`/`UniversityStats`/
  `UniversityType` entities, `SuperAdminDashboardRepository`
  (name/email/university id for the signed-in admin, plus
  `getUniversity`/`getUniversityStats`), its own datasource and DTO
  (`data/models/university_model.dart`) — none of it shared with
  `dashboard` or `register`, even though `register` also has a
  `UniversityType` and momentarily creates a `universities` record:
  each feature's copy only needs to agree with PocketBase's schema, not
  with each other's Dart types — same `_guard`/`SuperAdminDashboardException`
  pattern as every other feature's repository, translating PocketBase's
  `ClientException` before it reaches the Cubit. `SuperAdminDashboardCubit` loads
  university + stats once on construction and again on pull-to-refresh,
  degrading to placeholders (`—`, no banner) instead of erroring if either
  call fails — notably if `users.listRule` hasn't been migrated yet to let
  a super admin list their own university's accounts (see
  `pocketbase_schema.md`). Its bottom nav holds three real tabs (`home`,
  `requests`, `profile` — `SuperAdminDashboardTab` in the cubit's state;
  the other two are separate features embedded as tab bodies) plus two
  "coming soon" stubs (Pass/Notices). Saving/sharing the campus pass goes
  through its own `CampusPassRepository` + `CampusPassCubit` (a second
  repository in this feature, with no PocketBase behind it):
  `data/datasources/campus_pass_image_renderer.dart` draws the pass
  off-screen with `QrPainter` + `TextPainter` straight to a print-resolution
  PNG (so export never depends on the on-screen widget or a `GlobalKey`),
  and `campus_pass_export_datasource.dart` is the only file touching `gal`
  (save to Photos) and `share_plus` (share sheet). Every failure — denied
  photo permission, unsupported platform, or a `MissingPluginException`
  from an app not rebuilt after the plugins were added — becomes a
  `CampusPassException`, which the Cubit turns into a `CampusPassOutcome`
  that the page shows via `BlocListener`. The widget itself only dispatches
  and reads the busy state.
- `join_requests` — the dashboard's "Requests" tab (embedded as a tab body,
  not a separate route — see `super_admin_dashboard_page.dart`): the
  pending queue of students/faculty awaiting approval for this admin's
  university, plus an archive of already-decided accounts. Its own full
  `domain`/`data` split, independent of `super_admin_dashboard` and
  `register` even though all three eventually touch the same `users`
  fields. `JoinRequestsRepository.getMembers` fetches every member
  regardless of status in one call (`users.listRule`, widened the same way
  as for the dashboard) with `expand: 'students_via_user,teachers_via_user'`
  to pull each person's role-specific id/department/batch-or-designation
  in the same round trip; the cubit derives the pending/students/faculty/
  archived counts and the visible list from that one list rather than
  making four queries. `approve`/`reject` just flip `status` — this needed
  its own migration widening `users.updateRule` the same way `listRule`/
  `viewRule` were widened for the dashboard (see `pocketbase_schema.md`).
- `super_admin_profile` — the dashboard's "Profile" tab (embedded like
  `join_requests`): the admin's identity (avatar/initials, name, email,
  verification badge), the institution they own (logo, type, location,
  established date, copyable campus id), account details, a dark-mode
  switch (drives the app-wide `ThemeCubit` in `core/theme`), a
  password-reset action, and logout. Its own `domain`/`data` split
  (`SuperAdminProfile`/`ProfileUniversity` entities, its own
  `UniversityType` copy). `SuperAdminProfileRepository.cachedProfile` reads
  the persisted session so the tab renders immediately; `refresh()` uses
  `authRefresh(expand: 'university')` — one round trip for both records,
  and it re-saves the fresh record into the shared auth store. Editing the
  display name uses a bottom sheet that shares the page's Cubit via
  `BlocProvider.value`, with the form key on the Cubit and the field bound
  via `initialValue` + `onChanged` — same form convention as `login`/
  `register`, no controller. One-shot results (`ProfileOutcome`) drive
  SnackBars, closing the sheet, and navigating away after logout, all
  through `BlocListener`.
- `notices` — the dashboard's "Notices" tab (embedded like
  `join_requests`/`super_admin_profile`): a super admin composes
  title/body/audience announcements for their own university; anyone
  reading the tab sees the ones they authored and can delete them. Unlike
  `join_requests` (which reuses `users.status`), a notice is genuinely new
  data with nothing to piggyback on, so it's the first feature with its own
  PocketBase collection (`notices` — see `pocketbase_schema.md`) rather
  than reading/writing fields on an existing one. Two Cubits, not one:
  `NoticesCubit` owns the list (load/delete, lives for the whole tab) and
  `ComposeNoticeCubit` owns the "new notice" sheet's form (title/body/
  audience, `SubmissionStatus`, the form key) — a fresh instance per sheet
  open, discarded when it closes, since composing isn't state the list
  needs to carry. The sheet resolves its `Future<bool?>` to `true` on
  success; the page only reloads the list when it sees that, rather than
  the two Cubits knowing about each other directly. `notices.createRule`
  requires the requester to be a same-university super admin *and* the
  record's own `author`/`university` fields to already match them — a
  student's or teacher's own screen for reading these is `MemberNoticesPage`
  (embedded as a dashboard tab body; see `student_dashboard`), and per
  the university-linking gap noted in `pocketbase_schema.md`, couldn't see
  anything scoped by university even if it didn't.
- `join_university` — the QR/code flow a student or teacher uses to attach
  their account to a campus. One route (`AppRoute.joinUniversity`) serving
  both roles, because both do the identical thing server-side: update their
  own `users` record. `JoinUniversityCubit` drives scan → preview → request
  off one `JoinUniversityStatus`, with `UniversityPreview` as the
  feature-owned entity. Reads a join code off the scanned QR, resolves it to
  a preview the user confirms before sending anything, then `requestToJoin`.
  The datasource's `updateOwnMembership` is what writes
  `{'university': <id>, 'status': 'pending'}` onto the signed-in `users`
  record — the same `status` field `join_requests` reads, which is what puts
  a row in the super admin's Requests tab. The repository adds nothing but
  the `_guard`.
- `member_profile` — the student/teacher counterpart to
  `super_admin_profile`: read the signed-in member's own record, rename
  themselves, request a password reset, log out. Full domain/data split
  (`MemberProfile` entity, DTO, `_guard` → `MemberProfileException`). The
  shared profile *chrome* it has in common with `super_admin_profile` —
  `ProfileHeaderCard`, `profile_widgets.dart`, `edit_name_sheet_body.dart` —
  is promoted to `core/widgets/` (2+ features use each, per the `core/`
  rule), while the pages and the repository stay per-feature since
  `super_admin_profile` reads university identity + a join-code QR and this
  one reads the member's own avatar/name.
- `campus_pass` — lives inside `super_admin_dashboard` (not its own
  feature) because it's only reachable from the super admin's own pass card.
  `CampusPassRepository` is the one repository in the app with **no**
  PocketBase: it's device-side only, exporting the pass PNG to the gallery
  or the OS share sheet, so `DI` wires it as a bare
  `CampusPassRepositoryImpl()` with no datasource. The image is drawn by
  `CampusPassImageRenderer` in `data/datasources/` for exactly the reason
  the "no `AnimationController` in widgets" rule above implies: rendering
  needs a `ui.PictureRecorder`, which is data-layer work. `ShareAnchor` is a
  record typedef `({double left, top, width, height})` rather than a Flutter
  type, so the share-sheet call site can position the popover from a
  widget's `RenderBox` without the domain layer importing Flutter.

## Adding a new feature — checklist

1. `lib/features/<name>/presentation/{cubit,pages,widgets}` at minimum.
2. Add `domain/entities` once you need a named type; add `domain/
   repositories` + `data/` once there's a real data source.
3. Add the route + `AppRoute` constant in `app_router.dart`.
4. Add strings to `assets/translations/en.json`, reference them via `.tr()`.
5. Use `Theme.of(context).textTheme` / `colorScheme` for all styling.
6. State lives in a `Cubit`; no `setState`.
7. If the feature needs a repository, define its own — don't import
   another feature's `domain`/`data` (see "Features own their data and
   domain" above). Wire the new repository into `DI` alongside the others.
