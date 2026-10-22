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

### Phase 6 — historical offline tooling

Historical adapters now have a stable import facade over model-specific modules.
The policy-neutral builder has nine ordered stages with named dataclass results,
four cohesive helper groups and the original `service.ImageDerivedSignalBuilder`
import. AST reconstruction verified all 23 adapter definitions, 34 signal helpers
(after receiver rebinding) and all 188 build statements after stage unpacking.
Remaining service definitions and policy bytes match the original. Twenty-three
synthetic golden cases were frozen before edits; outputs and diagnostic logs match.
A further 230 seeded synthetic variants, including generated images, match the
original complete output and diagnostics. No actual model/provider was loaded.

The browser toolkit is generated from the canonical TypeScript runtime plus its
editable report helpers. Browser/CommonJS APIs, YAML helpers, aliases, errors,
results and eager report diagnostics retain all 37 frozen cases. Normal application
decisions retain short-circuit behavior: 500 generated expressions match the old
runtime's results and diagnostics. Five Node contract methods pass, including
artifact drift, both loading modes and first-match/default application outcomes.
Actual Chromium passed all 37 cases plus a form action, with no console/page errors
or overflow; its screenshot was viewed. This is an offline harness, not a folder
moderation evaluation or historical service run. The cross-service CI contract
workflow now checks generation and compatibility.

The broad Python attempt passed 142 methods and exposed one stale cross-repository
language-count contract; its corrected selected check passed separately. An earlier
unit run exposed the already-enabled historical policy rule's stale disabled-set
expectation; the full attempt above passed that corrected test. Original failures
are retained. The language contract now accurately checks the declared 58-language
remote mapping against historical model configuration, rather than claiming all
95 UI languages are remotely translatable. Thirty-seven additional UI languages
remain unmapped by that remote provider. No language/provider policy was changed.
Scoped Ruff, formatting, API types, moderation build and TypeScript lint passed.

Local nested commits: application `36709e1e`, historical moderation `374006e`.
The original historical baseline was `be3f2c6` (its policy tuning stays exact).
Evidence and original log hashes are indexed in
`docs/reviews/2026-10-22-phase6-validation.json`.

### Completion and limits

All six implementation phases are committed locally. Existing manual services and
unrelated files were preserved. Owned browser/API/Web processes are closed. The
fresh owned PostgreSQL container `tfp-audit-phases-20261022` is stopped, with its
container and data retained. No source was pushed and no deployment occurred.

This closes the reviewed code-quality phases at their documented scopes. It does
not certify external providers, native devices, production configuration, legal
inputs, full business E2E or deployed launch readiness. Original scan receipts,
failures and earlier evidence remain unchanged; passing focused checks are not a
replacement whole-release certificate.

| Phase | Application commit | Other nested commit | Orchestrator commit |
| --- | --- | --- | --- |
| 1 — correctness/contracts | `1f069eed` | — | `9702ef9` |
| 2 — dead-code cleanup | `dbc58bdc` | — | `8133eb1` |
| 3 — shared behavior | `327a3d95` | collage `2be4ad0` | `67f8eaf` |
| 4 — bootstrap/persistence | `f19d41e2` | — | `e3594fe` |
| 5 — measured i18n | `fad84f60` | — | `1123478` |
| 6 — offline moderation | `36709e1e` | moderation `374006e` | this commit |
