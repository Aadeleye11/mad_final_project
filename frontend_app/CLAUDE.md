# CLAUDE.md

Project context for Claude Code. Read this before making any change.

## What this is

RwandaGo — an offline-first Rwanda travel app. Users build a personalised
itinerary and access it via QR code with no connectivity. Flutter front end,
Firebase back end. University final project, graded against a rubric, due
imminently. Bias toward working code over elegant code.

## First task — install the staged files, then verify

The Discover slice was written outside this repo and downloaded into two
staging folders at the project root: `files/` (the original slice) and
`files2/` (a later revision plus new files). **Flutter cannot compile from
either** — Dart must live under `lib/`, tests under `test/`, assets under
`assets/`.

Work through these steps in order. Do not skip ahead to running the app.

### Step 1 — apply `files/`

Move its contents into the matching real folders, merging rather than
replacing what is already there:

- `files/lib/**` → `lib/**` (overwrites the generated `lib/main.dart` — intended)
- `files/test/**` → `test/**`
- `files/assets/**` → `assets/**`

### Step 2 — apply `files2/` on top

`files2/` is **newer** and must be applied second. It may be flat rather than
nested, so place each file by name:

| File | Destination |
|---|---|
| `attraction_image.dart` | `lib/features/discover/presentation/widgets/` (new) |
| `attraction_card.dart` | `lib/features/discover/presentation/widgets/` (overwrite) |
| `attraction_detail_page.dart` | `lib/features/discover/presentation/pages/` (overwrite) |
| `fetch_images.py` | `tool/fetch_images.py` (create `tool/`) |
| `INTEGRATE.md` | project root |

If a filename appears in both staging folders, the `files2/` version wins.

### Step 3 — clean up

Delete `files/` and `files2/` once empty. Neither should ever be committed.
Read `INTEGRATE.md`, then delete that too.

### Step 4 — pubspec.yaml

Add the dependencies listed in `INTEGRATE.md`. Register both asset folders
under `flutter:`, beside `uses-material-design` — not under `dependencies:`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/data/
    - assets/images/
```

### Step 5 — remove the generated test

`flutter create` leaves `test/widget_test.dart` referencing a counter app that
no longer exists. It will fail the test run. Delete it.

### Step 6 — fetch the attraction photos

```bash
python3 tool/fetch_images.py
```

Downloads freely licensed Wikimedia Commons photos into `assets/images/`,
rewrites `imageUrl` in `assets/data/attractions_seed.json`, and writes
`IMAGE_CREDITS.md`. If it fails, carry on — the app renders placeholders and
still runs. Do not substitute images from any other source; licensing matters
for a submitted project.

### Step 7 — build and verify

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

None of this code has been compiled before, so expect version and deprecation
errors on the first pass. **Fix them in place.** Do not restructure the
architecture, swap the state management, or rewrite files wholesale to make an
error go away — the layout is graded. If an error seems to demand an
architectural change, stop and explain instead.

Report what you changed and anything still failing.

## Stack

- Flutter, Dart 3
- State management: **BLoC** (`flutter_bloc`). Never `setState`.
- DI: `get_it`
- Routing: `go_router`
- Errors: `dartz` — repositories return `Either<Failure, T>`
- Backend: Firebase Auth + Cloud Firestore
- Local: `shared_preferences`

## Architecture

Clean Architecture, sliced **vertically by feature**. Each feature owns its
full `data / domain / presentation` stack.

```
lib/
├── main.dart
├── injection_container.dart
├── core/                  shared: failures, usecase base, router, theme
└── features/
    ├── discover/          data/ domain/ presentation/
    ├── trips/
    └── auth/
```

Dependency direction is strictly inward: `presentation → domain ← data`.
The domain layer imports nothing from Flutter or Firebase.

### The registration pattern — do not break this

Three people work on this repo simultaneously. To keep them out of the same
files, every feature exposes its own registration:

- `features/<name>/<name>_injection.dart` exports `init<Name>(GetIt sl)`
- `features/<name>/<name>_routes.dart` exports `List<RouteBase> <name>Routes`

`injection_container.dart` and `core/router/app_router.dart` only call/spread
those. **Never add an individual dependency or route to a shared file.** Add it
to the feature's own file.

## File ownership — important

| Path | Owner |
|---|---|
| `lib/features/discover/**` | Ayomide (this user) |
| `lib/features/trips/**` | Saad |
| `lib/features/auth/**` | Paul |
| `lib/core/**`, `main.dart`, `injection_container.dart` | shared |

**Only edit files under `lib/features/discover/`, `lib/core/`, and the
single registration lines in `main.dart` / `injection_container.dart` /
`app_router.dart`.**

Do not refactor, fix, or reorganise anything under `lib/features/trips/` or
`lib/features/auth/`, even if it is broken or would be improved. Those are
other people's working branches and changes there cause merge conflicts. If
something there blocks you, say so instead of fixing it.

## Conventions

- Business logic never lives in a widget. Validation, filtering, and sorting
  belong in use cases or BLoCs so they can be unit tested without a widget tree.
- Widgets stateless wherever possible.
- Entities are `Equatable` and immutable, with `const` constructors.
- Data-layer models extend their domain entity and add `fromJson` / `toJson`.
- Comment the non-obvious: why a fallback exists, why a value is cached. Do not
  comment what the code plainly says.
- User-facing strings are plain, specific, and sentence case. Errors explain
  what happened and what to do, and never apologise.
- Prefer `flutter_bloc`'s `BlocBuilder` / `BlocConsumer` over manual listeners.

## Rubric constraints — these are graded, treat as requirements

- **No pixel overflow in landscape or on any screen size.** Use
  `LayoutBuilder`, `SingleChildScrollView`, `Wrap` instead of `Row`,
  `Expanded`/`Flexible`. Check every screen rotated.
- Buttons at least 48dp tall; text contrast at least 4.5:1.
- Wide variety of widgets is scored — lists, grids, cards, dialogs, chips,
  slivers, animations.
- Errors surface as `SnackBar` or dialog, never a silent failure or a red
  screen.
- Widget tests plus at least **three** unit tests, all passing.
- At least three `SharedPreferences` settings that persist across relaunch.
- `dart format .` and `flutter analyze` must both be clean before any commit.
- **Android/iOS only.** A web or desktop build scores zero. Never suggest
  `flutter run -d chrome`.

## Commands

```bash
flutter pub get
flutter run                 # physical device or emulator only
dart format .
flutter analyze             # must report 0 issues
flutter test
flutter test --coverage
```

## Current state

The `discover` slice is written but **staged in `files/` and `files2/`, not yet
installed** — see the first section. Once installed it provides: browse,
category filter, search, detail page, three-tier offline fallback (Firestore →
SharedPreferences cache → bundled `assets/data/attractions_seed.json`), bundled
attraction photos, plus BLoC and widget tests.

`AttractionImage` handles all three image cases — bundled asset path, remote
URL, or empty — so the UI never depends on connectivity to render.

None of that code has been compiled yet, so expect version and deprecation
issues on the first `flutter analyze`. Fix them in place rather than rewriting
the architecture.

Firebase is optional at runtime right now — `Firebase.initializeApp()` in
`main.dart` is wrapped in try/catch and the Firestore handle resolves lazily
inside `fetchAll()`, so the app boots on seed data before `flutterfire
configure` has been run. Keep that behaviour; it is deliberate.

Not built yet: QR generation and scanning, the offline itinerary payload codec,
the shared bottom-navigation shell, trips, auth.

## Gotchas

- `discover_event.dart` and `discover_state.dart` are `part of`
  `discover_bloc.dart` — they must stay in the same folder.
- `flutter create` leaves a `test/widget_test.dart` referencing a counter app.
  Delete it or `flutter test` fails.
- In `pubspec.yaml`, `assets:` goes under `flutter:`, beside
  `uses-material-design` — not under `dependencies:`.
- If a package version in `pubspec.yaml` conflicts with the installed SDK, fix
  the version rather than downgrading the SDK.

## Working style

- Small changes, verified. After any edit, run `flutter analyze` and
  `flutter test` before moving on.
- If a fix would require touching another person's feature folder, stop and
  explain instead.
- Commit messages: imperative, specific. `add category filter to discover`,
  not `updates`.