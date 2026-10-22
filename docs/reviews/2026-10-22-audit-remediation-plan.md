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
