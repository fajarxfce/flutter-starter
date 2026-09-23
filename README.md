# Fluent Starter

A Flutter monorepo with enforced clean architecture, feature packages, Microsoft-style Fluent UI, and a working authentication example.

## Quick start

Install **Flutter 3.47.5 / Dart 3.13.4** (`.fvmrc` pins Flutter). With FVM, run `fvm install` and use its Flutter/Dart binaries. All commands below run from the repository root with the pinned SDK on `PATH`.

```sh
flutter pub get --enforce-lockfile
dart run melos bootstrap
dart run tool/app.dart run linux dev
```

Replace `linux` with `android`, `ios`, `web`, `windows`, or `macos`. Native builds require their corresponding host/toolchain. Mobile run commands select a single attached device; use `--device=<id>` when more than one is connected. Web uses Chrome by default.

Demo credentials: **demo@example.com / Demo123!**. Every flavor defaults explicitly to **demo**, including release builds; the environment badge remains visible. No real server is contacted in demo mode.

```sh
dart run tool/app.dart run android staging --device=emulator-5554
dart run tool/app.dart run web dev
dart run tool/app.dart build web prod --smoke
dart run tool/app.dart run linux dev --api=https://api.example.com
```

`--api` selects the real Retrofit backend and requires an HTTPS origin. It never falls back to demo. The wrapper sets matching `FLAVOR`, `BACKEND`, and native `--flavor` arguments. Web has Dart environment configuration only. Native/Dart flavor mismatches fail at startup. Direct Flutter invocations should pass the same arguments; examples are in `.vscode/launch.json`.

## Architecture

```text
apps/fluent_starter                 composition, router, platform runners
packages/core/common               pure Dart Result/Failure and storage ports
packages/core/data                 secure credentials and preferences
packages/core/network              injectable Dio/options/interceptors, failure mapping
packages/core/design_system        Fluent themes, tokens and components
packages/core/testing              fakes and mock helpers (tests only)
packages/features/auth/domain      entities, repository contract, use cases
packages/features/auth/data        Retrofit, remote data source, JSON DTOs, repository
packages/features/auth/presentation Bloc/events, Freezed state, Formz, login UI
packages/features/home/presentation dashboard and preferences UI
```

```mermaid
flowchart LR
  App[App composition] --> Presentation[Feature presentation]
  App --> Data[Feature data]
  Presentation --> Domain[Feature domain]
  Data --> Domain
  Data --> Network[Core network]
  App --> Storage[Core data]
  Presentation --> Design[Core design system]
  Domain --> Common[Core common]
  Storage --> Common
  Network --> Common
```

Domain has no Flutter, transport, persistence, JSON, or DI framework imports. Presentation depends on domain contracts and receives dependencies through constructors. Injectable generates package modules for core/network, auth/data, and auth/presentation; the app composes them in an isolated GetIt container. Only app composition accesses GetIt. Route pages are app adapters around feature widgets; features do not import each other. Home receives user data and callbacks from the app and has no artificial data/domain packages.

`tool/check_architecture.dart` checks package dependencies, production imports/exports (including conditional ones), forbidden framework dependencies, private cross-package imports, directory escapes, and cycles. It uses the Dart analyzer AST, not text matching. Generated files are checked too. The allowlist requires an explicit decision when adding a package.

### Add a feature

1. Create packages under `packages/features/<feature>/{domain,data,presentation}` as needed, with unique package names, `resolution: workspace`, `publish_to: none`, and the shared SDK constraint.
2. Register each package in root `workspace` and update the dependency allowlist in `tool/check_architecture.dart`.
3. Define entities, repository interfaces, and use cases in domain; implement DTOs/transport/mapping in data; inject use cases into event-driven presentation Blocs.
4. Annotate data implementations and Blocs, generate their Injectable micro-package modules, and include them in app composition. Register pure domain use cases through an app-owned `@module`. Add `@RoutePage` adapters and route declarations; keep cross-feature coordination in the app.
5. Generate code, add behavior tests, and run the quality gate. Never access another package's `lib/src`.

Use cases return `Success<T>` or `FailureResult<T>`. Data exceptions and DTOs never reach presentation. Freezed handles presentation state; JsonSerializable handles wire models. Domain models are plain Dart.

### File organization

Package entrypoints are export-only barrels. Each handwritten implementation file declares one public type, organized by responsibility:

```text
features/auth/domain/lib/
  auth_domain.dart
  src/entities/user.dart
  src/repositories/auth_repository.dart
  src/usecases/login.dart
  src/usecases/logout.dart
  src/usecases/restore_session.dart

features/auth/data/lib/src/
  dto/user_dto.dart
  requests/login_request.dart
  responses/login_response.dart
  datasources/remote/auth_api.dart
  datasources/remote/auth_remote_data_source.dart
  datasources/demo/demo_adapter.dart
  di/auth_api_module.dart
  di/auth_data_injection.dart
  mappers/user_mapper.dart
  repositories/remote_auth_repository.dart

features/auth/presentation/lib/src/
  inputs/{email_input,password_input,input_error}.dart
  state/login_state.dart
  bloc/login_bloc.dart
  events/login_event.dart
  events/{login_email_changed,login_password_changed,login_submitted}.dart
  di/auth_presentation_injection.dart
  views/login_view.dart
```

Core packages follow the same convention: storage contracts and implementations, HTTP interceptors, failure mappers, theme, spacing tokens, widgets, and test fakes each have their own files. Home separates navigation from its overview and preferences widgets. App composition separates configuration enums, DI registration, service creation, inherited scope, router, guards, and pages.

The architecture check enforces export-only package barrels and one public type per handwritten source file. It rejects Cubit implementations, feature service-locator imports, and DI imports in domain. A widget's private `State` may stay with its widget; generated files follow generator conventions. Sealed variants of `Result` and `LoginEvent` live in separate physical files connected with `part` so each hierarchy remains in one library. Keep each model's generated `part` next to that model; do not collect models or use cases in a barrel.

### Dependency injection and HTTP providers

`apps/fluent_starter/lib/di/composition.dart` includes three generated micro-package modules. Runtime `AppConfig`, `CredentialStore`, and `PreferenceStore` are the only manually supplied dependencies, allowing platform stores to be replaced in tests.

| Owner | Injectable registrations |
|---|---|
| Core network `lib/src/providers/network_module.dart` and annotated interceptors | Lazy singleton `BaseOptions`, `Dio`, credential interceptor, and safe logging interceptor |
| Auth data `lib/src/di/auth_api_module.dart` and annotated data classes | Lazy singleton Retrofit `AuthApi`, `AuthRemoteDataSource`, and `RemoteAuthRepository` bound as `AuthRepository` |
| Auth presentation `lib/src/bloc/login_bloc.dart` | Factory `LoginBloc`, receiving the `Login` use case |
| App `di/modules/auth_use_case_module.dart` | Factory `Login`, `RestoreSession`, and `Logout`; domain stays free of annotations |
| App `di/modules/http_transport_module.dart` | `NetworkConfig` from the flavor/backend config and `HttpClientAdapter`: demo transport or Dio's platform adapter |
| App routing | Factory `AppRouter` and shared `SessionGuard` |

The provider configures JSON content type, connection/send/receive timeouts, and interceptors. Authentication headers are restricted to the API origin and omitted from login requests. Logging exposes only method/status/error category. Generated disposal closes Dio's transport and the repository session stream when the app container is reset. Each login route owns a fresh Bloc through `BlocProvider`, which closes it when the route leaves. `LoginSubmitted` uses `droppable()` to ignore concurrent submissions; email/password edits are ignored while submitting.

### Generated navigation

`routing/app_router.dart` declares `@AutoRouterConfig`; `@RoutePage` adapters generate `LoginRoute`, `HomeRoute`, `OverviewRoute`, and `PreferencesRoute` in `routing/app_router.gr.dart`. `FluentApp.router` consumes the injected router. The protected `/home` route hosts `AutoTabsRouter`: Overview is `/home`, Preferences is `/home/preferences`, and the Fluent navigation pane reads and updates its active tab. Back returns from Preferences to Overview. Typed navigation can use `HomeRoute(children: [PreferencesRoute()])`.

Opening `/home/preferences` without a session redirects to login and resumes Preferences after authentication. Logout and session expiry clear the protected route stack.

## Authentication and storage

The demo adapter implements Dio's HTTP transport, so the example exercises Retrofit, remote data source, checked JSON parsing, DTO mapping, repository, use case, Bloc, and UI. Its API contract is documented in [docs/backend.md](docs/backend.md).

- Native credentials use OS secure storage; web credentials are memory-only and require login after refresh. Theme preferences persist on every platform.
- Credential keys are namespaced by flavor and backend mode. No password is persisted.
- Bootstrap restores and verifies a stored token before routing. A protected deep link is resumed after login. Logout or an expired session removes the protected route stack.
- Network failures preserve stored credentials for retry; a 401 from session verification clears them. Storage failures return an explicit domain failure.
- Home offers **Check session** and, in demo mode, **Expire demo session**. Invalid credentials, `timeout@example.com`, and `server@example.com` demonstrate error handling; use any valid-length password for the last two.
- HTTP logs include only method/status/error category, never URL, bodies, credentials, or headers; logging is disabled in profile/release builds.
- Refresh-token rotation, OAuth, account registration, analytics, and a backend service are intentionally outside this starter's contract.

## Commands and generated files

```sh
dart run melos run generate --no-select
dart run melos run check --no-select
dart run melos run flavors --no-select
```

`generate` runs build_runner in dependency order, then formats the workspace with the pinned Dart SDK. The formatting step also normalizes Injectable's micro-package output. `check` runs format verification, architecture validation, analysis, and all package/root tests. Individual scripts are `format`, `format-check`, `architecture`, `analyze`, and `test`.

Commit root `pubspec.lock`, `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, and `*.module.dart`. Injectable produces `composition.config.dart` and the three package `*_injection.module.dart` files; auto_route produces `app_router.gr.dart`. Do not edit generated code. Freezed is pinned to **4.0.1** because 4.0.2 requires an analyzer version outside auto_route_generator's supported range. Upgrade the generator toolchain together, regenerate, and rerun checks.

Run the Melos `flavors` wrapper: it also restores the Flutter Runner scheme build/preparation actions omitted by Flavorizr 2.6, preserving Swift Package Manager support.

Native flavor files are generated from `apps/fluent_starter/flavorizr.yaml`. Its explicit processor list excludes sample Dart code generation and Podfile processors because the current Apple runners use Swift Package Manager. Review and commit regenerated native files. Never replace the custom bootstrap with Flavorizr's sample pages.

## Platforms and build verification

| Platform | Host prerequisites | Smoke build |
|---|---|---|
| Android | JDK 17, Android SDK 36, build tools 36, Flutter-selected NDK | `dart run tool/app.dart build android dev --smoke` |
| iOS | macOS and compatible Xcode | `dart run tool/app.dart build ios dev --smoke` |
| Web | Flutter web SDK; Chrome for running | `dart run tool/app.dart build web dev --smoke` |
| Linux | clang, cmake, ninja, pkg-config, GTK 3, libsecret | `dart run tool/app.dart build linux dev --smoke` |
| Windows | Visual Studio C++ desktop workload, CMake | `dart run tool/app.dart build windows dev --smoke` |
| macOS | macOS and compatible Xcode | `dart run tool/app.dart build macos dev --smoke` |

Replace `dev` with `staging` or `prod`. Android smoke builds are debug APKs; Apple smoke builds omit code signing. Distribution signing must be configured before publishing. The repository has no deployment workflow.

Linux secure storage needs a running Secret Service, such as GNOME Keyring or KWallet, in addition to libsecret. macOS uses the legacy OS keychain (`usesDataProtectionKeychain: false`) to avoid requiring Keychain Sharing for this standalone app. macOS sandbox networking and Android internet access are enabled; Android app backup is disabled to avoid restoring encrypted credentials without their keys. iOS app signing is configured locally in Xcode for physical-device execution.

GitHub Actions runs the quality gate plus all **six platforms × three flavors** on appropriate hosts. Apple/Windows build jobs must actually run before claiming those platforms verified; a Linux host cannot validate their native toolchains. The native integration smoke test also exercises actual credential storage:

```sh
cd apps/fluent_starter
flutter test integration_test/app_flow_test.dart -d linux --flavor dev --dart-define=FLAVOR=dev --dart-define=BACKEND=demo
```

On Linux, `bash tool/test_linux.sh` creates an isolated temporary keyring and starts Xvfb/DBus; install `gnome-keyring`, `xvfb`, and `xauth` to use it. CI runs this wrapper.

If running the raw command, use a disposable dev keychain: it signs out the current dev/demo session before and after testing. Use a graphical desktop or Xvfb with a Secret Service. Widget integration tests use in-memory storage and need no desktop session.

## Rename the starter

Change app labels and platform IDs in `flavorizr.yaml`, regenerate flavors, and review the native diff. Update the Android namespace/Kotlin package, base Apple/desktop identifiers, web title/manifest, and the storage namespace in `AppConfig`. If changing Dart package names, update pubspec dependencies, package imports, the architecture allowlist, and generated code together.

The initial IDs are `dev.example.fluentstarter.dev`, `.staging`, and `dev.example.fluentstarter` for prod. UI copy is English; Fluent and Flutter localization delegates are wired. Add app-owned ARB localization when introducing another language.

Changes use atomic Conventional Commits with the configured Git identity and no co-author trailer.
