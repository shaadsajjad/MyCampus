# MyCampus

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

**Your Campus, Connected.**

MyCampus is a cross-platform campus-management app built with Flutter. A
**Super Admin** registers their institution and runs it; **Students** and
**Teachers** join that institution with a QR code / join code and get a
role-specific home screen — digital ID, schedule, attendance, notices, and
academic tools — once a Super Admin approves them.

---

## Table of contents

- [Features](#features)
- [Tech stack](#tech-stack)
- [Packages](#packages)
- [Running it locally](#running-it-locally)
  - [1. Prerequisites](#1-prerequisites)
  - [2. Clone and install](#2-clone-and-install)
  - [3. Start the PocketBase backend](#3-start-the-pocketbase-backend)
  - [4. Run the Flutter app](#4-run-the-flutter-app)
  - [5. Create your first account](#5-create-your-first-account)
- [Which "user" is which](#which-user-is-which)
- [Running on a physical device](#running-on-a-physical-device)
- [Project structure & architecture](#project-structure--architecture)
- [Localization](#localization)
- [Linting & tests](#linting--tests)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## Features

### Shared (all roles)

- **Role-based onboarding** — pick Super Admin, Faculty, or Student, then
  log in or register for that role.
- **Email/password auth** against PocketBase, with form validation and
  friendly, localized error messages for every failure mode (wrong
  password, unreachable server, etc.).
- **Account verification flow** — a "check your email" screen plus a
  deep-link handler (`mycampus://verify?token=...`) that confirms the
  account without leaving the app.
- **Light & dark theme**, driven by the system or toggled manually from the
  profile screen.
- **Localization-ready** — every user-facing string is externalized, so a
  new language is a translation file away.

### Super Admin

- **Institution registration** — create the university record (name, type,
  city/country, established date, logo) in the same flow as the admin
  account.
- **Admin dashboard** — a shareable, scannable **QR join code** for the
  institution, plus live student/faculty/pending-request counts.
- **Digital campus pass** — a QR-coded ID card rendered as a
  print-resolution PNG, saved to the photo library or shared via the OS
  share sheet.
- **Join requests** — approve or reject students/teachers requesting to
  join, with an archive of already-decided requests.
- **Member directory** — a searchable, filterable, read-only list of every
  approved student and faculty member.
- **Course catalogue** — full CRUD on courses (code, title, credits,
  contact hours, department).
- **Routine builder** — compose each course's weekly class schedule (day,
  time slot, room), instantly reflected on the relevant students' and
  faculty's "My Routine" tab.
- **Notices** — compose and delete announcements, targeted at everyone,
  students only, or faculty only.
- **Profile** — institution identity, account details, dark-mode toggle,
  password reset, logout.

### Student

- **Join a university** by scanning its QR code or entering its join code,
  then wait for Super Admin approval (with a live status screen).
- **Home dashboard** — digital student ID card, today's schedule,
  bulletins, attendance progress, and an academic-tools shortcut grid.
- **Realtime approval** — the screen flips from "pending" to the full
  dashboard the moment a Super Admin approves the account, no re-login
  needed.
- **Notices** — read announcements addressed to students/everyone.
- **Profile** — view/edit name, request a password reset, logout.

### Teacher / Faculty

- Everything the student flow has, in its own faculty-specific vocabulary:
  **faculty ID card, teaching schedule, announcements, and academic
  telemetry**, plus quick actions for common faculty tasks.

---

## Tech stack

| Layer | Choice |
|---|---|
| Language / framework | [Flutter][flutter_link] `^3.47.0` / Dart `^3.13.0` |
| Backend | [PocketBase][pb_link] `v0.40.4` (self-hosted SQLite + REST API + realtime) |
| State management | [`flutter_bloc`][flutter_bloc_link] (Cubit only — no `setState`) |
| Routing | [`go_router`][go_router_link] |
| Architecture | Clean Architecture — see [`clean_architecture.md`](./clean_architecture.md) |
| Localization | [`easy_localization`][easy_loc_link] |
| Platforms | Android, iOS (Web/Desktop buildable, not the primary target) |

## Packages

| Package | Used for |
|---|---|
| [`pocketbase`][pocketbase_pub] | PocketBase SDK — auth, CRUD, realtime subscriptions |
| [`flutter_bloc`][flutter_bloc_pub] / [`bloc`][bloc_pub] | State management (Cubit) |
| [`go_router`][go_router_pub] | Declarative, URL-based navigation |
| [`easy_localization`][easy_loc_pub] | `.tr()`-based string localization |
| [`shared_preferences`][shared_prefs_pub] | Persists the PocketBase auth session across restarts |
| [`app_links`][app_links_pub] | Deep-link handling for email verification |
| [`mobile_scanner`][mobile_scanner_pub] | QR code scanning (join-university flow) |
| [`qr_flutter`][qr_flutter_pub] | QR code generation (university join code, campus pass) |
| [`image_picker`][image_picker_pub] | University logo / avatar uploads |
| [`gal`][gal_pub] | Saving the campus pass image to the photo library |
| [`share_plus`][share_plus_pub] | Sharing the campus pass via the OS share sheet |
| [`http`][http_pub] / [`intl`][intl_pub] | HTTP utilities / date formatting |
| [`device_info_plus`][device_info_plus_pub] | Detects real device vs. emulator, to pick the right default dev PocketBase URL |

Dev-only: [`bloc_lint`][bloc_lint_link] + [`bloc_tools`][bloc_tools_pub] (Cubit
convention enforcement), [`very_good_analysis`][very_good_analysis_link]
(lint ruleset), [`bloc_test`][bloc_test_pub] / [`mocktail`][mocktail_pub]
(testing).

---

## Running it locally

This project talks to a [PocketBase][pb_link] backend — the app itself is
just a Flutter client. To run it end-to-end you need **both** the Flutter
app **and** a PocketBase server with the right collections. No account,
API key, or paid service is required — everything runs on your machine.

### 1. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter | `^3.47.0` (stable) | Dart `^3.13.0` ships with it. Verify with `flutter doctor`. |
| JDK | 17+ | Required by the Android Gradle Plugin, only if building for Android. |
| PocketBase | **v0.40.4** | Pinned so the committed migrations match. Don't use a newer/older version. |
| Xcode / Android Studio | latest | Only one is required, matching the platform you'll run on. |

### 2. Clone and install

```sh
git clone <repo-url> mycampus
cd mycampus
flutter pub get
```

### 3. Start the PocketBase backend

The PocketBase binary isn't checked into the repo (standard PocketBase
convention — every developer runs their own copy), so download it once.
Pick the command for your OS:

```sh
cd pocketbase

# macOS (Apple Silicon)
curl -L https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_darwin_arm64.zip -o pb.zip && unzip pb.zip -d . && rm pb.zip && chmod +x pocketbase

# macOS (Intel)
curl -L https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_darwin_amd64.zip -o pb.zip && unzip pb.zip -d . && rm pb.zip && chmod +x pocketbase

# Linux (x86_64)
curl -L https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_linux_amd64.zip -o pb.zip && unzip pb.zip -d . && rm pb.zip && chmod +x pocketbase
```

```powershell
# Windows (PowerShell)
cd pocketbase
Invoke-WebRequest https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/pocketbase_0.40.4_windows_amd64.zip -OutFile pb.zip
Expand-Archive pb.zip -DestinationPath .; Remove-Item pb.zip
```

Run it **from inside the `pocketbase/` directory**, bound to all interfaces
(not just `127.0.0.1`) — the Flutter app's dev build defaults to your
machine's LAN IP for every target except the Android emulator, so this is
required even for day-to-day local runs, not only for a physical device:

```sh
./pocketbase serve --http=0.0.0.0:8090
```

On first launch it will:

1. Create a fresh SQLite database under `./pb_data/`.
2. **Auto-apply every migration** in `./pb_migrations/` — you'll see lines
   like `Applied 1738195200_setup_mycampus_collections.js`. This creates
   all the collections the app needs (`users`, `universities`, `students`,
   `teachers`, `notices`, `courses`), already wired with the correct API
   rules. You don't need to create anything by hand.
3. Print a one-time install URL — open it in your browser to create the
   **PocketBase superuser** account (the backend admin — see
   ["Which user is which"](#which-user-is-which) below; this is separate
   from any account you'll use inside the app).

The server is now live at `http://127.0.0.1:8090` (and on your LAN IP, same
port). Leave this terminal running — the Flutter app talks to it over HTTP.

> **Email verification**: the app has a "check your email" screen, but no
> SMTP server is configured by default, so verification emails won't
> actually be delivered on a fresh local setup. This does **not** block
> you — the account's `verified` flag is advisory only, not enforced by
> the backend's auth rule, so you can register and log straight in without
> clicking a verification link.

### 4. Run the Flutter app

In a **second terminal**, from the repo root:

```sh
flutter run --flavor development --target lib/main_development.dart
```

This is the one you want for local development — it points at your
machine's LAN IP on port `8090` by default (`http://10.0.2.2:8090`
automatically on the Android **emulator** instead, detected at runtime via
`device_info_plus` — see `lib/main_development.dart`). The `--flavor` flag
is required — this project defines Android/iOS build flavors for
`development`/`staging`/`production`, and omitting it will build all three
and then fail to find "the" output.

Other flavors (point at placeholder staging/production URLs — not useful
until you deploy your own servers there):

```sh
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart
```

### 5. Create your first account

The migrations create collections and API rules, but **no app users** —
you create your own through the app itself:

1. Launch the app → pick **Super Admin** → Register.
2. Fill in your institution details and your own admin account. Super
   admin accounts are auto-approved (no one else has to approve the
   person who's creating the university), so you're logged straight into
   the dashboard.
3. Grab the **join code / QR code** from your new dashboard's home tab.
4. To see the student/teacher side: register a second account as
   **Student** or **Faculty**, join your university with that code, then
   go back to the Super Admin's **Requests** tab and approve it. The
   student/teacher screen updates live, no re-login needed.

---

## Which "user" is which

Two unrelated "super" terms show up — they are **not** the same thing:

| Term | What it is | Created |
|---|---|---|
| **PocketBase superuser** | An admin of the PocketBase *backend itself* — can see every collection in the PB dashboard, holds the encryption env. | Once, at `http://127.0.0.1:8090/_/`, when you first start the server. |
| **App Super Admin** | A normal `users` record in the app, with `role = superAdmin`, that owns a `universities` record. An end-user of the app, not a backend admin. | By registering through the app's own onboarding flow. |

You will almost never need the PocketBase superuser account after initial
setup — it exists for inspecting the database, not for using the app.

---

## Running on a physical device

The Android emulator's special loopback (`10.0.2.2`) is detected and wired
up automatically — no extra config needed there. For a **physical phone**,
PocketBase must already be running with `--http=0.0.0.0:8090` (see
[step 3](#3-start-the-pocketbase-backend)); beyond that:

1. The app defaults to the LAN IP hardcoded as `_lanPocketbaseIp` in
   [`lib/main_development.dart`](./lib/main_development.dart) — update that
   constant to your own machine's current LAN IP (e.g. `192.168.1.42`) if
   it doesn't match, then run as usual:
   ```sh
   flutter run --flavor development --target lib/main_development.dart
   ```
   Alternatively, override it per-run without touching the code:
   ```sh
   flutter run --flavor development --target lib/main_development.dart \
     --dart-define=POCKETBASE_URL=http://192.168.1.42:8090
   ```
2. Make sure the phone and computer are on the same Wi-Fi network (not a
   guest network with client isolation enabled), and that your OS firewall
   allows inbound connections on port `8090`.

---

## Project structure & architecture

```
lib/
  app/            # App widget, MaterialApp/go_router wiring
  core/           # Shared across features — DI, router, theme, utils, widgets
  features/       # One folder per feature, each split into
                   #   data/ (datasources, models, repository impls)
                   #   domain/ (entities, abstract repositories)
                   #   presentation/ (cubit, pages, widgets)
  l10n/           # (legacy, superseded by assets/translations/)
pocketbase/
  pb_migrations/  # Versioned schema migrations, auto-applied on first run
  pb_public/      # Static fallback page for the email-verification deep link
assets/
  translations/   # en.json — all user-facing strings
```

The app follows a strict **Clean Architecture** split per feature
(`data` → `domain` ← `presentation`, dependency direction always inward),
with no `get_it`/`injectable` — just a small manual composition root at
[`lib/core/di/di.dart`](./lib/core/di/di.dart). Every convention —
layering rules, the Cubit-only state management policy, routing, theming,
and a feature-by-feature breakdown of what each one does — is documented
in [`clean_architecture.md`](./clean_architecture.md). The PocketBase
schema (collections, fields, API rules) is documented in
[`pocketbase_schema.md`](./pocketbase_schema.md).

---

## Localization

This project uses [`easy_localization`][easy_loc_link] with a single JSON
file at `assets/translations/en.json`.

To add a new string:

1. Add the key under the appropriate section (`admin.*`, `courses.*`,
   etc.) in `assets/translations/en.json`.
2. Reference it from a widget: `'common.save'.tr()`.
3. Never hardcode user-facing text in Dart.

To add a new **locale**: add a matching `assets/translations/<locale>.json`
and list the `Locale` in `lib/app/view/app.dart`.

> The older `flutter gen-l10n` / ARB pipeline (`lib/l10n/arb`,
> `lib/l10n/gen`, `l10n.yaml`) has been removed — the JSON file above is
> the only translation source. If `flutter gen-l10n` errors about a
> missing `l10n.yaml`, that's expected and harmless.

---

## Linting & tests

```sh
# Static analysis (very_good_analysis + bloc_lint)
flutter analyze

# Cubit-specific convention checks
dart run bloc_tools:bloc lint .

# Unit/widget tests
flutter test
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `flutter run` fails with a flavor/ambiguous-build error | You omitted `--flavor development` (or `staging`/`production`) — see [step 4](#4-run-the-flutter-app). |
| App can't reach PocketBase / requests time out | Confirm PocketBase is running with `--http=0.0.0.0:8090` (not the bare `./pocketbase serve`), and that `_lanPocketbaseIp` in `lib/main_development.dart` matches your machine's *current* LAN IP (it changes across networks/DHCP leases) — see [step 3](#3-start-the-pocketbase-backend) and [Running on a physical device](#running-on-a-physical-device). |
| Migrations didn't apply | They run relative to PocketBase's working directory — always `cd pocketbase` before `./pocketbase serve`. |
| Stuck on "waiting for approval" as a student/teacher | Log in as the Super Admin who owns that university, go to the **Requests** tab, and approve the account. |
| No verification email arrives | Expected on a fresh local setup — no SMTP server is configured. It doesn't block login; see the note in [step 3](#3-start-the-pocketbase-backend). |
| `flutter gen-l10n` error on build | Harmless — the old ARB pipeline was removed; see [Localization](#localization). |

---

## License

[MIT](./LICENSE)

---

[coverage_badge]: coverage_badge.svg
[bloc_lint_link]: https://pub.dev/packages/bloc_lint
[bloc_tools_pub]: https://pub.dev/packages/bloc_tools
[bloc_test_pub]: https://pub.dev/packages/bloc_test
[mocktail_pub]: https://pub.dev/packages/mocktail
[easy_loc_link]: https://pub.dev/packages/easy_localization
[easy_loc_pub]: https://pub.dev/packages/easy_localization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[pb_link]: https://pocketbase.io
[pb_release]: https://github.com/pocketbase/pocketbase/releases/tag/v0.40.4
[flutter_link]: https://flutter.dev
[flutter_bloc_link]: https://pub.dev/packages/flutter_bloc
[flutter_bloc_pub]: https://pub.dev/packages/flutter_bloc
[bloc_pub]: https://pub.dev/packages/bloc
[go_router_link]: https://pub.dev/packages/go_router
[go_router_pub]: https://pub.dev/packages/go_router
[pocketbase_pub]: https://pub.dev/packages/pocketbase
[shared_prefs_pub]: https://pub.dev/packages/shared_preferences
[app_links_pub]: https://pub.dev/packages/app_links
[mobile_scanner_pub]: https://pub.dev/packages/mobile_scanner
[qr_flutter_pub]: https://pub.dev/packages/qr_flutter
[image_picker_pub]: https://pub.dev/packages/image_picker
[gal_pub]: https://pub.dev/packages/gal
[share_plus_pub]: https://pub.dev/packages/share_plus
[http_pub]: https://pub.dev/packages/http
[intl_pub]: https://pub.dev/packages/intl
[device_info_plus_pub]: https://pub.dev/packages/device_info_plus
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
