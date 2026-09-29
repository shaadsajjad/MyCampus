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

## Feature map

- `splash` — shows the logo for a fixed delay (`SplashCubit`, 3s), then
  navigates to `onboarding` via `go_router`. Presentation-only; no domain
  layer needed since it holds no business state.
- `onboarding` — role selection + login/register toggle. Has a `domain`
  layer (`UserRole`, `AuthMode` entities) because that vocabulary is shared
  across the feature's widgets; no `data` layer yet since nothing is
  persisted — add one (e.g. `OnboardingRepository` backed by
  `SharedPreferences`) if/when onboarding needs to remember completion or
  the chosen role across launches.

## Adding a new feature — checklist

1. `lib/features/<name>/presentation/{cubit,pages,widgets}` at minimum.
2. Add `domain/entities` once you need a named type; add `domain/
   repositories` + `data/` once there's a real data source.
3. Add the route + `AppRoute` constant in `app_router.dart`.
4. Add strings to `assets/translations/en.json`, reference them via `.tr()`.
5. Use `Theme.of(context).textTheme` / `colorScheme` for all styling.
6. State lives in a `Cubit`; no `setState`.
