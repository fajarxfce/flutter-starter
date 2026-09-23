# Validation record

Validated on Linux on 2026-09-23 using Flutter 3.47.5 and Dart 3.13.4.

## Feature-owned use-case registration

- Auth and settings use-case bindings now live in their data packages' `injection.dart`, collected by the existing generated micro-package modules. App DI supplies runtime configuration and composes these modules; it no longer imports either domain package.
- `flutter pub get --enforce-lockfile`: passed. Auth domain is now an app test dependency; the app's unused settings domain dependency was removed. No resolved versions changed.
- `dart run melos run check --no-select`: passed with 90 tests, clean analysis, formatting, dependency policy, and architecture checks.
- New package tests initialize generated feature modules without app DI. Auth exercises all five use cases through login, session observation, restore, expiry, and logout; settings exercises theme loading and persistence. Both verify use-case factory lifetimes.
- Existing app tests still cover bootstrap, generated route/Bloc composition, deep links, login/logout, session expiry, and appearance persistence.
- `dart run melos run generate --no-select`: passed; all 14 generated files stayed byte-for-byte identical on regeneration.

Platform builds and native integration were not repeated for this registration refactor. Their latest results are recorded below.

## Shared versions, consolidated DI, and Bloc enforcement

- Root `pubspec_overrides.yaml` owns 29 hosted dependency constraints. All 14 pubspecs use `any` for hosted/workspace dependencies and retain SDK declarations. All 173 resolved dependency versions are unchanged.
- `flutter pub get --enforce-lockfile` and `dart run melos bootstrap`: passed for all 13 workspace members.
- Each of the five Injectable micro-packages has one `injection.dart` entry point. App bindings are consolidated in app `di/injection.dart`; the Retrofit factory is directly annotated. Network configuration, provider lifetimes, and disposal remain covered by existing graph/network tests.
- `dart run melos run check --no-select`: passed with 88 tests, clean analysis, formatting, dependency policy, and architecture checks.
- Dependency-policy regression tests reject scattered versions, missing central constraints, member overrides, and overridden workspace/SDK sources. Bloc checks reject legacy state APIs across handwritten production files, including aliases, prefixed constructors, mixins, and tear-offs outside UI folders.
- `dart run melos run generate --no-select`: passed; all 14 generated source files stayed byte-for-byte identical on regeneration.
- Web dev release build: passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed. Login persisted credentials to the isolated OS keyring, a new container restored the session, and logout cleared it.

Android, Windows, iOS, and macOS builds were not repeated for this change.

## UI state and event boundaries

- Removed `AppServices`, `AppScope`, and the application-services factory. UI consumes Bloc state and dispatches events; route composition resolves `LoginBloc` directly from Injectable.
- `dart run melos run check --no-select`: passed with 68 tests, clean analysis, formatting, and architecture checks.
- UI architecture regression tests reject helper methods, async work, imperative decisions, mutation, subscriptions, and domain/data/DI imports. The checker normalizes paths for Windows and POSIX; its 14 tests passed after that adjustment.
- Session Bloc tests cover startup failure, session observation, checking/loading feedback, demo expiry, and logout storage failure. Settings tests cover persisted/unknown themes, storage failures, and ordered writes after rapid selections.
- Widget tests cover guarded deep links, login/logout/login with a fresh route Bloc, session expiry, nested route/back behavior, and changing appearance through an event. Widget-test containers are created inside the test's fake-async zone so stream callbacks and UI frames use the same scheduler.
- `dart run melos run generate --no-select`: passed; all 14 generated source files remained byte-for-byte identical on regeneration.
- Web dev release build: passed, including the Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed. Login persisted credentials to the isolated OS keyring, the first container was disposed, a new container restored the session, and logout cleared it.
- Appearance Bloc tests also passed after enabling the package's required Material icon assets.

Android, Windows, iOS, and macOS builds were not repeated for this change. The workspace now contains 13 packages.

## Modular Injectable, Bloc, and generated navigation

- `dart run melos run check --no-select`: passed, including formatting, strict architecture rules, analyzer, and 51 tests.
- Generated DI graph tests resolve Dio, Retrofit, remote data source, repository, use cases, Bloc, guard, and router; exercise login/restore/logout; verify factory/singleton lifetimes and repository disposal.
- Network tests verify provider configuration, origin-scoped credentials, login header omission, redacted logs, and generated Dio transport disposal. Real backend mode selects the platform adapter without a demo fallback; no live backend was contacted.
- Bloc tests cover validation, successful submission, duplicate submit suppression, ignored edits during submission, and retry after failure.
- Router widget tests cover protected nested deep links, generated typed navigation, Fluent menu/URL synchronization, back to Overview, logout, and session expiry.
- `dart run melos run generate --no-select`: passed; a second run left all 10 generated source files byte-for-byte unchanged.
- `dart run tool/app.dart build web dev --smoke`: release build passed, including Flutter's Wasm dry run.
- `bash tool/test_linux.sh`: dev debug build and native integration passed under Xvfb with an isolated Secret Service. Login persisted real secure credentials, a new service container restored the session, and logout cleared it.

Android, Windows, iOS, and macOS builds were not repeated for this change.

## File organization refactor

- `dart run melos run check --no-select`: passed, including format, analyzer, architecture rules, and 41 tests.
- Package barrels and one-public-type-per-file rules include regression coverage.
- JSON, Retrofit, Freezed, DI, and route code regenerated successfully; a second generation left all seven generated Dart files unchanged.
- Web dev release build: passed after the refactor.

The native build and integration results below describe the initial scaffold; native builds were not repeated for this source-organization refactor.

## Initial scaffold

- Workspace bootstrap with enforced root lockfile: passed; 10 workspace packages resolved.
- `dart run melos run check --no-select`: passed, including format, architecture boundaries, analyzer, and 38 tests.
- Build runner regeneration: passed; committed Dart generated files unchanged.
- GitHub Actions workflow validation with actionlint 1.7.12: passed.
- Android dev/prod debug APK builds: passed.
- Web dev/prod release builds: passed. The final prod build includes all required icon fonts.
- Linux dev/prod release builds: passed.
- Native Linux integration: login, actual secure credential persistence, restore through a fresh service container, and logout passed under Xvfb with an isolated Secret Service.
- Apple scheme checks for all three flavors: passed, including preserved Flutter preparation and build actions.

Windows, iOS, and macOS native builds were not executed on this Linux host. GitHub Actions contains their build jobs on appropriate runners, alongside all dev/staging/prod combinations. Remote CI was not run as part of this local validation.

Build artifacts are ignored. Android APKs are under `apps/fluent_starter/build/app/outputs/flutter-apk/`, Linux bundles under `apps/fluent_starter/build/linux/x64/<flavor>/release/bundle/`, and the latest web build under `apps/fluent_starter/build/web/`.
