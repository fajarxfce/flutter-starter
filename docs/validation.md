# Validation record

Validated on Linux on 2026-09-23 using Flutter 3.47.5 and Dart 3.13.4.

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
