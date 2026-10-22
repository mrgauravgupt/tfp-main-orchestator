# Audit remediation, 22 October 2026

Requested scope: execute the six reviewed phases, with a local commit after each
phase in every affected repository and a corresponding orchestrator commit.
No deployment, publication, existing database reset, or historical provider run.
Preserve unrelated files and original audit/runtime receipts.

## Approach and affected surfaces

| Surface | Effect and validation |
| --- | --- |
| API moderation and reminders | Direct: persist state and notification intent in the same transaction; test enqueue failure, update failure, no-op and retry |
| Outbox and AI worker | Direct contract coverage; preserve polling, lease, event vocabulary and at-least-once semantics |
| Repositories and cache | Direct factory/export cleanup; indirect OAuth, logout, admin and server consumers need typecheck and focused tests |
| MIME and appeals | Direct shared implementation; preserve image-only/PDF boundaries, ownership checks and response DTOs |
| Cloudflare purge | Two independently released adapters; align contracts without creating a distribution package for a small adapter |
| Server | Direct composition extraction; preserve exact hook order, scope, headers, authentication, routes and lifecycle |
| i18n | Direct server catalog loading; indirect Web/worker and mobile shared contracts, legal fallbacks and request isolation |
| Historical moderation | Explicitly scoped offline source refactor and golden fixtures only; no policy edits, model downloads, service startup or folder moderation |
| Persistence/schema | No intended migrations; extend schema checks, retain nested/raw soft-delete filters |
| Deployment and configuration | Preserve existing runtime defaults; compiled package and isolated local runtime verification required |
| Web/native UI | No intended layout or navigation changes; runtime Web check for bootstrap/i18n, native adapter checks; device proof stays separate |

## Phases and acceptance

1. Correctness and evidence: transactional notification intent, reminder markers,
   AI domain schema contracts, accurate audit/test status. Failure-injection tests.
2. Cleanup: remove only unconsumed repository classes and rate-limiter factory;
   update all factory/interface/export owners. Preserve active persistence consumers.
3. Consolidation: image MIME primitives, domain-owned appeal command, matching
   purge behavior and boundary tests. Keep localized redirect stubs.
4. Structure: cohesive bootstrap registration helpers, application-owned memory
   cache, persistence interfaces that expose only consumed capabilities.
5. Localization: measure cold import/RSS baseline, implement lazy synchronous
   catalog loading when justified, then compare output and measurements.
6. Historical tooling: golden signal/policy baselines, model adapter modules,
   cohesive signal stages and generated browser evaluator core with full API parity.

Validate focused checks per phase, then affected broader type/lint/build/runtime
gates. Keep each phase independently revertible by its commits. Tests against a
fresh owned database may create fixtures; never reset an existing database.
Record actual validation and remaining limits below; never infer runtime proof
from static checks or carry old certificates forward to changed source.

## Execution record

Implementation started from product `1e330912` and orchestrator `6f9d631`.

### Phase 1 — correctness and evidence

Entity action-required intent now leaves evaluation as data and is queued by the
state owner inside its transaction (opportunity/event/contest and auto-fix).
Reminder enqueue + marker share a transaction and per-entity advisory lock.
A fresh owned PostgreSQL 15 container on 15522 received canonical migrations; three
actual transaction cases pass, including rollback, no-op and concurrent reminder
retry. Focused affected tests passed 39 methods across separate final selections;
initial stale media/worker mocks and the void lock-result failure are retained in
`/tmp/tfp-phase1-*.log`. API typecheck, affected ESLint, 37 AST/import tests and
architecture enforcement passed. Three wire-contract and three domain schema
contract tests passed. Domain schema checks are static SQL name/shape checks.
Audit original inventory/scan receipts remain unchanged; corrections are explicit.
No provider, deployment, UI or whole-release certification follows this phase.

### Phase 2 — bounded cleanup

Removed nine unconsumed concrete repositories and the unused memory rate-limiter
factory, including factory/interface/barrel entries (801 source lines). Active
User/OAuthAccount/UserViolation adapters, soft-delete filters and redirect pages
remain. API/database typechecks, affected lint and database build passed. Existing
auth/admin tests passed 45 methods. A separate compiled-package PostgreSQL probe
passed actual OAuth lookup, logout session-version update and violation query,
then removed only its fixtures. Old compiled-output sourcemap warnings before the
package rebuild remain in the original test log; they are not runtime defects.

### Phase 3 — shared behavior

MIME primitives now have one pure uploads subpath, preserving general upload
JPEG-prefix behavior, stricter image-only short buffers and PDF separation.
Moderation owns appeal creation; admin/report exports are compatibility aliases
and the member route calls the canonical command. Independent Cloudflare adapters
share configuration/batching/transport/acknowledgement behavior and contract cases;
existing error vocabularies remain compatible. No distribution package introduced.
API tests passed 28 methods; full storage package passed 23; collage purge passed
four. Upload build, API/collage types, affected lint and architecture gates passed.
No real purge request, provider operation or authenticated business E2E was run.

### Phase 4 — application structure

Server composition is 289 lines (formerly 790); five registration helpers execute
on the original root scope. AST reconstruction compared all 48 registrations,
decorators and hooks against the original: exact content and ordering retained.
Memory cache and its three existing behavior tests moved to API infrastructure.
OAuth application code now consumes plain persistence capabilities; Prisma relation
syntax and identity upsert live in its repository adapter. UserViolation already
has a domain port. Active logout remains on its retained repository.
API selections passed 78 methods (including an actual PostgreSQL port mapping);
architecture and affected lint passed, mobile typecheck passed. Canonical build
completed eight package stages before an API port type mismatch; corrected API
and previously unrun Web builds then passed. Initial direct-Node startup failed
on existing extensionless i18n imports; the canonical tsx runtime entrypoint passed.
Fresh owned API/Web on 14510/13510 passed health/ready, auth and public cache/header
probes. The initial assumed unknown-route 404 was corrected to the existing global
auth policy's 401; original output is retained. Root viewed 1440x900 and 390x844
Home screenshots: no overflow, broken images, console or page errors. Owned browser
and both servers closed. No authenticated business/native/device certificate.

### Phase 5 — measured i18n loading

Synchronous catalog lookup now hydrates and caches only canonical requested
languages; English remains preloaded and cache membership is registry-bounded.
No catalog or mobile loader bytes changed. Five fresh compiled imports per version
measured medians 604.6 -> 120.0 ms, retained heap delta 29,670,320 -> 4,118,992 bytes,
RSS delta 114,704,384 -> 24,395,776 bytes, and language reads 97 -> 2 (95 -> 1 unique).
All 96 resolved-locale catalog hashes match baseline. This is local measurement,
not deployed latency or a linguistic certificate; native adapter behavior is covered
by i18n tests, not a new device run. Reader/fallback and existing i18n tests passed
137 methods; final Web unit suite passed all 827 across 124 files. Two original
stale shared-token/limit assertions were corrected after the first Web run failed.
API/Web/i18n builds, i18n/mobile types, affected lint and architecture checks passed.
Twelve actual compiled Web renders across six locales and two viewports returned
200 with no overflow/broken images; Arabic remained RTL. Root viewed Arabic desktop
and mobile screenshots. Owned browser/API/Web closed; original attempts retained.
Measurements and source hashes: `docs/reviews/2026-10-22-i18n-profile.json`.
