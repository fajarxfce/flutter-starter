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
packages/features/auth/presentation login/session Blocs, Freezed state, Formz, login UI
packages/features/home/presentation navigation shell and dashboard UI
packages/features/settings/domain  theme entity, repository contract, use cases
packages/features/settings/data    persisted appearance preferences
packages/features/settings/presentation appearance Bloc and preferences UI
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

Domain has no Flutter, transport, persistence, JSON, or DI framework imports. Presentation Blocs depend on domain use cases through constructors. Injectable generates package modules for core/network, auth/data, auth/presentation, settings/data, and settings/presentation; the app composes them in an isolated GetIt container. GetIt access stays in DI, bootstrap, and route composition. Route pages bind presentation state and events to feature widgets; features do not import each other. Home receives display values and event callbacks from the app.

`tool/check_architecture.dart` checks package dependencies, production imports/exports (including conditional ones), forbidden framework dependencies, private cross-package imports, directory escapes, and cycles. It uses the Dart analyzer AST, not text matching. Generated files are checked too. The allowlist requires an explicit decision when adding a package.

### Shared dependency versions

Root `pubspec_overrides.yaml` is committed and owns the hosted dependency version constraints for this private workspace. Every root/member `pubspec.yaml` declares the dependencies it uses as `any`. Flutter SDK dependencies keep `sdk: flutter`; internal packages resolve through Dart's workspace. Package release versions and SDK constraints stay in each pubspec.

To add a library, declare it as `any` in the consuming package and add its constraint once in root `dependency_overrides`. Run `flutter pub get` and commit the updated root lockfile. Overrides apply to the entire dependency graph, including transitive constraints; upgrade related generators together and run the quality gate. The lockfile records exact resolved versions.

`tool/check_dependencies.dart` rejects repeated versions, missing shared constraints, and dependency overrides in member files. Melos includes this policy in `check`.

### Add a feature

1. Create packages under `packages/features/<feature>/{domain,data,presentation}` as needed, with unique package names, `resolution: workspace`, `publish_to: none`, and the shared SDK constraint.
2. Register each package in root `workspace` and update the dependency allowlist in `tool/check_architecture.dart`.
3. Define entities, repository interfaces, and use cases in domain; implement DTOs/transport/mapping in data; inject use cases into event-driven presentation Blocs.
4. Annotate data implementations and Blocs. Add one `lib/src/di/injection.dart` per participating package with `@InjectableInit.microPackage`, generate it, and include its module in the app's `lib/di/injection.dart`. Group pure domain use-case bindings in a single `@module` inside the feature data package's `injection.dart`. Add `@RoutePage` adapters and route declarations; keep cross-feature coordination in the app.
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
  di/injection.dart
  mappers/user_mapper.dart
  repositories/remote_auth_repository.dart

features/auth/presentation/lib/src/
  inputs/{email_input,password_input,input_error}.dart
  state/login_state.dart
  bloc/login_bloc.dart
  events/login_event.dart
  events/{login_email_changed,login_password_changed,login_submitted}.dart
  di/injection.dart
  views/login_view.dart
  session/bloc/session_bloc.dart
  session/state/session_state.dart
  session/events/session_event.dart

features/settings/domain/lib/src/
  entities/app_theme_mode.dart
  repositories/settings_repository.dart
  usecases/{load_theme,save_theme}.dart

features/settings/data/lib/src/
  repositories/local_settings_repository.dart
  di/injection.dart

features/settings/presentation/lib/src/
  bloc/appearance_bloc.dart
  events/appearance_event.dart
  state/appearance_state.dart
  di/injection.dart
  views/appearance_view.dart
```

Core packages follow the same convention: storage contracts and implementations, HTTP interceptors, failure mappers, theme, spacing tokens, widgets, and test fakes each have their own files. App composition separates configuration, DI registration, bootstrap, router, guards, and pages.

The architecture check enforces export-only package barrels and one public type per handwritten source file. It rejects feature service-locator imports and DI imports in domain. Private implementation companions are allowed outside UI; generated files follow generator conventions. Sealed result/event variants live in separate physical files connected with `part` so each hierarchy remains in one library. Keep each model's generated `part` next to that model; do not collect models or use cases in a barrel.

### UI contains rendering and event bindings only

Pages and views render presentation state and dispatch Bloc events. They do not call use cases, repositories, storage, or transport; manage subscriptions; await operations; keep application state with `setState`; or decide authentication/navigation outcomes. Conditional widget rendering and layout bindings remain in UI. Validation messages and display-ready user fields belong to presentation state.

- `LoginBloc` owns input validation and submission.
- `SessionBloc` owns startup restoration, session observation, checking, logout, demo-expiry orchestration, loading state, and feedback. `WatchSession`, `RestoreSession`, `Logout`, and `ExpireDemoSession` are domain use cases. The demo simulation has its own repository contract and data implementation.
- `AppearanceBloc` owns theme loading, conversion to Flutter theme mode, and ordered persistence through settings use cases. Storage failures keep the chosen theme for the current session and expose feedback in state.
- `AppRouter` observes authentication transitions and coordinates protected navigation with `SessionGuard`. UI has no sign-in completion callback or session subscription.

`tool/ui_architecture_visitor.dart` checks UI source for helper methods/functions, asynchronous work, imperative decisions, assignments, and subscription/state-management calls. The package checker also rejects UI imports of domain, data, storage ports, DI, and transport. `app.dart`, route pages, and feature views/widgets are covered by these checks.

`tool/bloc_architecture_visitor.dart` checks every handwritten production file, including files outside UI folders. It rejects references to `Cubit`, `setState`, `StatefulWidget`, `StatefulBuilder`, `ChangeNotifier`, `ValueNotifier`, `ValueListenableBuilder`, and `ListenableBuilder`, plus Flutter `State` inheritance/aliases. Constructor calls, prefixed names, mixins, and tear-offs are covered. Framework and generated widget internals are outside this rule.

### Dependency injection and HTTP providers

`apps/fluent_starter/lib/di/injection.dart` includes five generated micro-package modules. Each participating package has one `lib/src/di/injection.dart` entry point. Runtime `AppConfig`, `CredentialStore`, and `PreferenceStore` are supplied at the app boundary, allowing platform stores to be replaced in tests. The container also registers itself for route composition. Application dependencies are generated by Injectable. Session and appearance startup events finish before the app mounts.

`@InjectableInit.microPackage` generates registrations from the package's annotations. Annotate constructors/classes directly for data sources, repositories, Blocs, and the Retrofit factory. Handwritten `@module` bindings are needed for third-party constructors and pure domain classes that cannot carry DI annotations. Each feature data package groups its use-case bindings in its existing `injection.dart`: `AuthModule` for auth and `SettingsModule` for settings. Domain classes retain constructor injection without importing a DI framework.

Adding a use case to an existing feature changes that feature's bindings and generated micro-package module. `AppModule` supplies only shared runtime configuration and transport; the app composes the generated modules. `NetworkModule` constructs Dio and its options in core/network. Each feature module can be initialized with its required infrastructure dependencies and tested without app composition.

| Owner | Injectable registrations |
|---|---|
| Core network `lib/src/di/injection.dart` and annotated interceptors | Lazy singleton `BaseOptions`, `Dio`, credential interceptor, and safe logging interceptor |
| Auth data `lib/src/di/injection.dart` and annotated classes/factory | Factory `Login`, `RestoreSession`, `Logout`, `WatchSession`, and `ExpireDemoSession`; lazy singleton API, data source, and repository implementations |
| Auth presentation | Factory `LoginBloc` and shared `SessionBloc`, receiving domain use cases |
| Settings data `lib/src/di/injection.dart` and annotated repository | Factory `LoadTheme` and `SaveTheme`; `LocalSettingsRepository` bound as `SettingsRepository` |
| Settings presentation | Shared `AppearanceBloc`, receiving settings use cases |
| App `lib/di/injection.dart` | `AppEnvironment`, `NetworkConfig` from the flavor/backend config, and `HttpClientAdapter`: demo transport or Dio's platform adapter |
| App routing | Shared `AppRouter` and `SessionGuard` |

The provider configures JSON content type, connection/send/receive timeouts, and interceptors. Authentication headers are restricted to the API origin and omitted from login requests. Logging exposes only method/status/error category. Generated disposal closes the router, shared Blocs, repository session stream, and Dio transport when the container is reset.

`AuthApi` uses `@lazySingleton` and `@factoryMethod` directly on its Retrofit factory. Its optional `baseUrl` is marked `@ignoreParam` so DI uses Dio's configured API origin without a separate API provider module.

The router binds `LoginRoute.page` to `BlocProvider(create: (_) => container<LoginBloc>())` directly. Each login route owns a fresh Bloc and closes it on removal. Bootstrap provides the shared session/appearance Blocs by value; their lifecycle belongs to the DI container. There is no application service bag or factory callback between Injectable and a Bloc. `LoginSubmitted` uses `droppable()` to ignore concurrent submissions; email/password edits are ignored while submitting.

### Generated navigation

`routing/app_router.dart` declares `@AutoRouterConfig`; `@RoutePage` adapters generate `LoginRoute`, `HomeRoute`, `OverviewRoute`, and `PreferencesRoute` in `routing/app_router.gr.dart`. `FluentApp.router` consumes the injected router. The protected `/home` route hosts `AutoTabsRouter`: Overview is `/home`, Preferences is `/home/preferences`, and the Fluent navigation pane reads and updates its active tab. Back returns from Preferences to Overview. Typed navigation can use `HomeRoute(children: [PreferencesRoute()])`.

Opening `/home/preferences` without a session redirects to login. The router receives authenticated session state and asks the guard to resume the pending destination. Logout and session expiry clear the protected route stack. No navigation decision runs in a page or view.

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

`generate` runs build_runner in dependency order, then formats the workspace with the pinned Dart SDK. The formatting step also normalizes Injectable's micro-package output. `check` runs format verification, dependency policy, architecture validation, analysis, and all package/root tests. Individual scripts are `format`, `format-check`, `dependencies`, `architecture`, `analyze`, and `test`.

Commit root `pubspec_overrides.yaml`, `pubspec.lock`, `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, and `*.module.dart`. Injectable produces app `injection.config.dart` and five package `injection.module.dart` files; auto_route produces `app_router.gr.dart`. Do not edit generated code. Freezed is pinned to **4.0.1** because 4.0.2 requires an analyzer version outside auto_route_generator's supported range. Upgrade the generator toolchain together, regenerate, and rerun checks.

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
