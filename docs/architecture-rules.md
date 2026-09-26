# Architecture rules

Apply these rules to new code and refactors throughout the workspace. They
complement the package layout, DI, navigation, and UI conventions in the
[README](../README.md). [AGENTS.md](../AGENTS.md) makes the same responsibilities
part of the repository instructions for coding agents.

## Responsibility and orchestration

| Layer | Owns | Depends on |
| --- | --- | --- |
| Datasource | External I/O, SDK configuration, serialization, raw values/DTOs | Injected SDK, client, API service, or storage driver |
| Repository implementation | Source selection/coordination, data consistency, entity and failure mapping | Datasource contracts and data-layer collaborators with explicit ownership |
| Use case | Application/business policy and the sequence of repository operations | Domain repository contracts |
| Bloc | User events, use-case execution, presentation state and request coordination | Use cases and presentation contracts |
| Widget | Rendering and event bindings | Presentation state and events |

### Datasources

Define a datasource contract and an implementation. An existing storage port
such as `CredentialStore` can already serve as that contract; an identical
forwarding interface adds no useful boundary.

Injecting a platform object, HTTP client, or SDK is appropriate here. These are
the tools that perform external I/O. Keep Retrofit annotations on an API service
such as `AuthApi`; the datasource contract remains separate from generated HTTP
implementation details.

Datasources return raw SDK values or their DTOs. They must not map to domain
entities, wrap technical failures in domain `Result`, swallow errors by returning
an unexplained `null`, or depend on another datasource. Domain validation belongs
in domain; parsing and protocol/format validation remain technical concerns.

Expose OS operations separately when callers need separate control: checking a
service, checking permission, requesting permission, reading a sensor, and opening
Settings. Do not combine them into a datasource helper that decides whether a
dialog should appear, when tracking starts, or how an app resumes.

### Repositories

Keep the interface in domain and its implementation in data. A repository
coordinates its datasource contracts, translates DTOs to entities, and translates
technical errors and source-specific outcomes into domain results. It must not
call another repository, contain UI loading flags, or expose SDK exceptions to
use cases and Blocs.

Repository coordination can include cache selection, persistence, combining GPS
and compass observations, and ending an acquisition when its sensor fails. A
dedicated data component may own shared session state or consistency when that
ownership is explicit, as described in [identity boundaries](identity-session.md).
Such a component must not become a place to hide application permission policy.

### Use cases and Blocs

Use cases coordinate repository contracts directly. They own decisions such as
whether permission should be requested, which authentication methods are allowed,
or whether acquisition should resume after returning from Settings. Do not chain
one use case through another use case. Put shared business rules in named domain
policies or entities when reuse is needed.

For foreground location, a use case can check access, request permission when
allowed, then start reading locations. It can coordinate a lifecycle repository
with access and location repositories so resume checks remain passive. The
repositories perform those individual operations without deciding when to prompt.

Blocs turn events into use-case calls and results into state. Register each event
handler explicitly instead of routing all events through one large switch.
Keep pure business rules in domain and SDK types/I/O in data. Widgets render
state and dispatch events; navigation effects belong to the established router
or presentation effect boundary.

## Safe calls and explicit result mapping

Use small public functions to centralize repeated technical error handling.
`safeApiCall` owns HTTP/decoding exception mapping; `safeStorageCall` owns storage
exception mapping. For another SDK, place its mapper and safe functions in that
SDK's data package. A plugin-specific safe call must not add a plugin dependency
to a pure domain/common package or assume one globally configured client.

Keep datasource execution and DTO mapping inside the safe callback so both are
covered. Define whether the function accepts a raw value or an already-mapped
`Result`; preserve existing domain failures and avoid `Result<Result<T>>`.
Stateless wrappers should be functions with explicit inputs. They do not need a
DI module, injected service, or configuration object merely to run a callback.

**Exception mapping and return-value mapping are separate responsibilities.**
A safe call cannot infer the meaning of every value returned by an SDK:

| SDK outcome | Explicit interpretation |
| --- | --- |
| Opening Settings returns `true` | The operation succeeded. |
| Opening Settings returns `false` | Report the failure to open Settings even though no exception was thrown. |
| Checking location services returns `false` | Access is unavailable because the service is disabled. |
| Checking whether a cache entry exists returns `false` | A valid absence result; subsequent source selection belongs to the repository. |
| Permission returns a permanently-denied status | Map the status to a domain permission failure; the use case decides the recovery action. |
| An SDK operation throws a timeout exception | The shared safe boundary maps the exception to a timeout failure. |

A short `opened ? Success(...) : FailureResult(...)` mapping is valid in a
repository. Extract it into a named mapper when it is reused or complicated.
Avoid creating a helper solely to conceal a small conditional. Do not throw a
synthetic exception just to make the safe-call wrapper interpret a returned
status. Business eligibility decisions remain in use cases.

Safe-call functions execute an operation once. They must not add implicit
retries, permission prompts, Settings navigation, cache fallbacks, or session
lifecycle policy. Retain internal error/stack diagnostics where appropriate,
respect the existing logging policy, and keep credentials, raw exception text,
and server bodies out of user-facing failure messages.

## Streams and lifecycle

Defer acquisition until subscription and propagate cancellation to the source.
Cancelling while a platform check is pending must prevent subsequent prompts or
sensor startup. An already-issued OS operation may finish; ignore its late result
and keep late errors handled. Make pause/resume, retry, and disposal ownership
explicit rather than assuming that a cancelled Future stops native I/O.

A stream-safe function maps stream creation and delivery failures. The caller
owns whether a domain failure ends that session. Repository-owned sensor cleanup
and use-case-owned foreground/resume policy must remain visible at those layers.
Preserve useful data when an optional source fails, according to the repository's
documented data strategy.

Test these boundaries with controllable futures and streams when they change:
exception and status mapping, pending cancellation, late events/errors, passive
resume, recovery after access changes, and resource disposal. Existing automated
architecture checks enforce a subset of these rules; layer ownership and the
meaning of returned values also require code review.
