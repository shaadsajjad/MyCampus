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

## `lib/core/` — shared across features

Anything more than one feature needs lives in `core/`, not inside whichever
feature happened to need it first:

```
lib/core/
  domain/entities/  # entities used by 2+ features (e.g. UserRole — both
                     # onboarding and auth switch on it). A single-feature
                     # entity stays in that feature's own domain/entities.
  di/               # dependency injection
  router/           # AppRouter, AppRoute
  theme/            # AppColors, AppTheme, AppTextStyles, light/dark ThemeData
  utils/            # pure-Dart helpers (e.g. Validators)
  widgets/          # generic, feature-agnostic UI chrome (e.g.
                     # PrimaryActionButton) — not a place for feature-shaped
                     # widgets; those stay in that feature's presentation/
                     # widgets even if a second feature ends up copying a
                     # small piece of one
  constants/        # e.g. AppAssets — centralized asset paths
```

If you're duplicating a `switch` over an enum, a color, a string literal,
or a widget across two features, that's the signal to promote it to
`core/`, not to import one feature's `presentation/` from another's.

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
  `LoginCubit` / `SuperAdminRegisterCubit` in the `auth` feature.

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
  feature/domain (`app`, `common`, `roles`, `splash`, `auth`, ...).
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
  (called once from `bootstrap()`, after `AppConfig.init()`). It wires the
  `PocketBase` client (with a `SharedPreferences`-backed `AsyncAuthStore`
  so login survives an app restart) into `AuthRepository`.
- A Cubit that needs a repository takes it as an **optional constructor
  param defaulting to the `DI` singleton**:
  ```dart
  LoginCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? DI.authRepository,
        super(const LoginState());
  ```
  Call sites stay simple (`LoginCubit()`), while tests can inject a fake.
- **Data-layer errors**: a repository method wraps its PocketBase call in
  a `try`/`on ClientException catch` (see `AuthRepositoryImpl._guard`) and
  rethrows a domain-level `AuthException(message)` — the only failure type
  a Cubit ever needs to catch. Cubits never import `package:pocketbase`.
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
  `auth` needs it too) because that vocabulary is shared across the
  feature's widgets; no `data` layer yet since nothing is persisted — add
  one (e.g. `OnboardingRepository` backed by `SharedPreferences`) if/when
  onboarding needs to remember completion or the chosen role across
  launches.
- `auth` — login (one screen, all three roles) and registration (one
  screen per role — `SuperAdminRegisterPage`, `StudentRegisterPage`,
  `TeacherRegisterPage` — since the three forms share almost no fields).
  Backed by PocketBase (see `pocketbase_schema.md` for the collections to
  set up) through a full `data`/`domain` split — `AuthRepository` is the
  contract the cubits call; `AuthRemoteDataSource` is the only file that
  imports the `pocketbase` package or sees a `RecordModel`/
  `ClientException`. `data/models` (`UserModel`, `StudentProfileModel`,
  `TeacherProfileModel`, `UniversityModel`) are DTOs matching PocketBase's
  wire format exactly (e.g. `role`/`status` stay raw strings); the
  repository is what parses those into the domain-level `AuthUser`
  (`UserRole`/`AccountStatus` enums) — a model never leaks past the data
  layer. `domain/entities` also holds the two role-specific enums
  (`UniversityType`, `TeacherDesignation`) plus `AccountStatus`
  (pending/approved/rejected — students and teachers need a super admin's
  approval; super admins are auto-approved since they create the
  university). PocketBase collections mirror this split too: `users` holds
  only basic account info (email, name, phone, role, status, university);
  role-specific fields live in their own `students` / `teachers`
  collections, linked back via a `user` relation — not crammed onto
  `users`. Shared form UI (`AppTextField`, `AppPasswordField`,
  `AppDropdownField`, `FormSectionCard`, `AuthScaffold`, `RoleContextChip`,
  `AuthFooterLink`) lives in `presentation/widgets` since it's specific to
  auth-shaped forms, not generic enough for `core/widgets`.
- `dashboard` — placeholder landing page shown after a successful login or
  registration (`context.go(AppRoute.dashboard)`, replacing the stack —
  you shouldn't be able to back out to login). Presentation-only:
  `DashboardCubit` just reads `AuthRepository.currentUser` (via `DI`) to
  show who's logged in and a pending-approval banner if relevant, plus a
  logout action. The real role-specific dashboards (attendance, notices,
  approvals, ...) are separate, later features — this one only exists to
  prove the auth round-trip works end-to-end.

## Adding a new feature — checklist

1. `lib/features/<name>/presentation/{cubit,pages,widgets}` at minimum.
2. Add `domain/entities` once you need a named type; add `domain/
   repositories` + `data/` once there's a real data source.
3. Add the route + `AppRoute` constant in `app_router.dart`.
4. Add strings to `assets/translations/en.json`, reference them via `.tr()`.
5. Use `Theme.of(context).textTheme` / `colorScheme` for all styling.
6. State lives in a `Cubit`; no `setState`.
