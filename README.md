# Sent Client App

Sent iOS Flutter client.

## Requirements

- Flutter 3.35+
- Dart 3.11+
- Xcode + iOS Simulator

## Environment

Use one of these files:

- `.env` for development
- `.env.prod` for production-like run

Examples are included:

- `.env.example`
- `.env.prod.example`

Required keys:

- `API_BASE_URL`
- `DEV_MODE`

## Run

Development:

```bash
./run.dev.sh
```

Production-like:

```bash
./run.prod.sh
```

Default alias:

```bash
./run.sh
```

## Project Structure

`lib/core`
- global infra (`router`, `network`, `storage`, `auth`, `error`, `config`)

`lib/features`
- feature-first modules (`auth`, `home`, `todo`, `ledger`, `social`, `memo`, `settings`)
- internal layering: `data` / `domain` / `presentation`

`lib/shared`
- design system, common widgets, theme utils

## Architecture Notes

- State management: Riverpod + riverpod_generator (`@riverpod`)
- Routing: `go_router` + `StatefulShellRoute`
- HTTP: `dio` + auth interceptor + token refresh flow
- Local persistence:
  - secure tokens: `flutter_secure_storage`
  - app settings: `SharedPreferences` injected at app bootstrap

## Localization

- ARB files: `lib/l10n/*.arb`
- Enable with `flutter gen-l10n` (already wired via `flutter: generate: true`)

## Quality Checks

```bash
flutter analyze
flutter test
```

## Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```
