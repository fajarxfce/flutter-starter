# Repository instructions

Read [the architecture rules](docs/architecture-rules.md) before changing layer
boundaries or error handling. Use [README.md](README.md) for the workspace layout,
dependency policy, DI, navigation, and available commands.

## Layer ownership

- Datasources implement contracts and perform SDK, OS, network, or storage I/O.
  They return raw values or DTOs and preserve technical exceptions. Injecting an
  SDK/client into a datasource is valid. A datasource must not depend on another
  datasource or decide application permission, session, or lifecycle policy.
- Repositories coordinate datasources, select data strategies, map DTOs to
  entities, and return domain `Result` values. Keep repository interfaces in
  domain and implementations in data. Repositories must not call other
  repositories or store UI state.
- Use cases coordinate repository contracts and own application/business policy:
  when to request permission, start acquisition, retry an action, or resume after
  Settings. Use cases must not call other use cases or import SDK types.
- Blocs coordinate use cases through separately registered, typed event handlers
  and own presentation state. Keep I/O, SDK types, `BuildContext`, and navigation
  calls out of Blocs. Widgets render state and dispatch events. Follow the
  workspace's Bloc-only and declarative-UI rules.

## Error boundaries and helpers

- Centralize repeated exception-to-`Failure` handling in small, named public
  functions in the appropriate infrastructure/data package. Reuse `safeApiCall`
  for HTTP and `safeStorageCall` for storage. Add an SDK-specific boundary when
  its failure mapping differs; keep SDK dependencies out of domain/core common.
- Prefer plain functions for stateless safe-call behavior. Do not introduce a
  class, DI binding, retry engine, or service just to wrap an operation.
- Keep acquisition and DTO mapping inside the safe boundary. Preserve an
  existing `FailureResult` and its classification; avoid nested `Result` values.
- A returned `false`, `null`, or status enum needs operation-specific mapping.
  It does not automatically indicate an exception or a failure. Small inline
  mappings in repositories are valid; use cases own the policy that follows.
- Safe functions must not silently retry, request permission, open Settings,
  select another source, or change subscription/session lifetime. Propagate
  cancellation, reject stale work at its owner, and retain appropriate internal
  diagnostics without exposing credentials or raw error text in UI messages.
- Give every helper a clear layer and responsibility. Do not hide application
  orchestration in a datasource/repository helper such as `_prepareAccess`.
  Extract a mapper or function when it improves clarity or reuse; avoid creating
  a separate abstraction for every small conditional.

## Implementation and delivery

- Keep implementation under `lib/src` and package DI under `lib/di/injection.dart`.
  Use injectable micro-packages and generated AutoRoute feature routes as
  described in the README. Do not create a DI module per use case or operation.
- Keep shared hosted dependency versions in root `pubspec_overrides.yaml`.
  Declare consuming dependencies as `any`; preserve SDK/workspace exceptions.
- Use existing asynchronous primitives and explicit resource ownership. Test
  cancellation during pending work, late failures/results, permission recovery,
  and disposal when those behaviors change.
- Run `dart run melos run generate --no-select` when generator inputs change and
  `dart run melos run check --no-select` for code/dependency changes. For
  documentation-only changes, verify links and consistency. Report only checks
  and device/build validation actually performed.
- Make atomic commits that include relevant implementation, tests, and docs.
  Do not add a `Co-authored-by` trailer. Preserve unrelated user changes. Push
  when authorized; create releases only when explicitly requested.
