# Validation record

Validated on Linux on 2026-09-23 using Flutter 3.47.5 and Dart 3.13.4.

- Workspace bootstrap with enforced root lockfile: passed; 10 workspace packages resolved.
- `dart run melos run check --no-select`: passed, including format, architecture boundaries, analyzer, and 38 tests.
- Build runner regeneration: passed; committed Dart generated files unchanged.
- GitHub Actions workflow validation with actionlint 1.7.12: passed.
- Android dev/prod debug APK builds: passed.
- Web dev/prod release builds: passed. The final prod build includes all required icon fonts.
- Linux dev/prod release builds: passed.
- Native Linux integration: login, actual secure credential persistence, restore through a fresh service container, and logout passed under Xvfb with an isolated Secret Service.
- Apple scheme checks for all three flavors: passed, including preserved Flutter preparation and build actions.

Windows, iOS, and macOS native builds were not executed on this Linux host. GitHub Actions contains their build jobs on appropriate runners, alongside all dev/staging/prod combinations. The workflow has not been run remotely because this repository has no remote configured.

Build artifacts are ignored. Android APKs are under `apps/fluent_starter/build/app/outputs/flutter-apk/`, Linux bundles under `apps/fluent_starter/build/linux/x64/<flavor>/release/bundle/`, and the latest web build under `apps/fluent_starter/build/web/`.
