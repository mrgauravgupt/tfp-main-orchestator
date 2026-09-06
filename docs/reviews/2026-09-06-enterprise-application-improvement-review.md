# 🔎 TFP Enterprise Application Improvement Review

- **Review date:** 6 September 2026
- **Review type:** evidence-based application, structure, SOLID, design-pattern, and operability review
- **Decision rule:** recommend the smallest change that fixes a demonstrated problem; do not add enterprise ceremony for its own sake
- **Companion audit:** [DRY, modularity, and cleanup audit](./2026-09-06-dry-modularity-and-cleanup-audit.md)

## Executive verdict

The active TFP application is **fundamentally well structured**. Its strongest architectural choices are appropriate for the product:

- PostgreSQL-backed durable outbox/job processing with retries and `FOR UPDATE SKIP LOCKED`
- domain-oriented API modules with commands, queries, repositories, and explicit media lifecycle events
- ports/adapters for AI providers, storage, rendition generation, and collage rendering
- a shared frontend design-token and i18n system with automated audits
- health endpoints, bounded retries, immutable rendition keys, publication gates, and explicit terminal failure states

This review did **not** find a reason to replace PostgreSQL queues with Redis/BullMQ, split the system into more microservices, add a global dependency-injection container, or introduce event sourcing. Those changes would add complexity without evidence of a current need.

The review found **seven practical improvements**:

| Priority | Finding | Affected service | Why it matters |
|---|---|---|---|
| **P1** | The current API test gate is red: 5 read-route tests fail | `tfpphotographers` BE | Release confidence and CI trust |
| **P2** | Three web listings turn API failure into a legitimate empty state | `tfpphotographers` FE | Users receive incorrect information |
| **P2** | The collage worker leases a batch, processes it serially, and never renews leases | `tfp-collage-service` | Slow jobs can be reclaimed or fail after expensive work |
| **P2** | The AI PostgreSQL adapter has no real PostgreSQL integration test in its own CI | `tfp-ai-interface` | SQL/schema/transaction drift can escape unit tests |
| **P3** | Search-route orchestration exceeds the repository's transport-only rule | `tfpphotographers` BE | A high-change route has multiple reasons to change |
| **P3** | Several architecture hotspot caps are no longer shrink-only | `tfpphotographers` | The regression gate permits large amounts of regrowth |
| **P3** | Two localized structure/content hotspots should be corrected when next touched | Web admin and collage test UI | Small maintainability and documentation debt |

**Bottom line:** fix the P1 test regression first, then address the three P2 items in small independent changes. The P3 items do not justify a broad refactor.

---

## Scope and method

### Active services reviewed

1. `tfpphotographers`
   - Fastify backend
   - Astro frontend
   - shared packages, architecture gates, CI, and representative tests
2. `tfp-ai-interface`
   - HTTP API, prompt/policy boundary, provider adapter, worker service, PostgreSQL outbox adapter, tests, and CI
3. `tfp-collage-service`
   - HTTP service, configuration, storage adapters, render ports/adapters, durable image worker, tests, deployment unit, and CI

`tfp-moderation-service` was not reviewed as an active fourth service. The workspace's checked-in topology identifies `tfp-ai-interface` as the active AI runtime and treats the older moderation repository as historical.

### Explicit exclusions

- Secret discovery or secret-quality findings, per the request
- Dependency-vulnerability interpretation beyond existing validation commands
- Source remediation; this deliverable is a review and improvement plan
- Database resets, seed writes, deployments, UAT mutations, or provider-billed inference
- Authenticated end-to-end workflows while the local API and collage processes were not running

### Evidence used

- Current source and tests in all three repositories
- Repository rulebooks, architecture gates, CI workflows, and deployment configuration
- Full or targeted static validation and test commands
- Live browser inspection of the running web frontend at desktop and mobile sizes
- Failure-mode browser inspection while the local API was unavailable
- Current local health checks for the already-running services; no service was restarted for this read-oriented review

---

## Findings

### P1 — Restore the API test gate before feature work

**Status:** confirmed and reproduced twice · **Area:** backend test composition / dependency wiring · **SOLID relevance:** dependency inversion is present at runtime, but the test composition root is stale

#### Evidence

The complete API suite produced:

- **179 test files**: 177 passed, 2 failed
- **986 tests**: 981 passed, 5 failed
- **2 unhandled rejections**

The same five failures reproduced in a targeted run:

- 3 failures in `apps/api/tests/modules/contest/contest-read-routes.test.ts`
- 2 failures in `apps/api/tests/modules/opportunity/opportunity-read-routes.test.ts`

Both route modules now obtain `app.mediaDelivery` from the Fastify composition root:

- `apps/api/src/modules/contest/contest-read-routes.ts:29-35`
- `apps/api/src/modules/opportunity/opportunity-read-routes.ts:47`

The failing test fixtures decorate `storage`, `mediaStorage`, `prisma`, and `translation`, but not `mediaDelivery`:

- `apps/api/tests/modules/contest/contest-read-routes.test.ts:59-75`
- `apps/api/tests/modules/opportunity/opportunity-read-routes.test.ts:55-66`
- `apps/api/tests/modules/opportunity/opportunity-read-routes.test.ts:88-100`

Their mocked `MediaDeliveryQuery` class is no longer instantiated by the route, so it cannot satisfy the decorated capability. The resulting `undefined.publicUrl(...)` produces HTTP 500 responses and unhandled rejections.

The main pull-request workflow runs `pnpm coverage:all`, which includes the API suite, so this is a current release-gate failure rather than a harmless local warning.

#### Smallest useful remediation

1. Add a narrow fake `mediaDelivery` capability to those fixtures.
2. Assert the expected `publicUrl` and `publicEntityMedia` calls.
3. If three or more route suites need the same capabilities, introduce one small Fastify read-route test helper. Do not create a general DI framework.
4. Keep production behavior strict; do not add an `undefined` fallback to the real route.

#### Acceptance proof

- The two targeted files pass with no unhandled rejection.
- The full API suite passes.
- `pnpm coverage:all` passes in the normal test environment.

---

### P2 — Preserve “unavailable” separately from “empty” on public listings

**Status:** confirmed by source and browser runtime · **Area:** frontend correctness and failure-state UX · **Affected pages:** opportunities, contests, and events

#### Evidence

With the web frontend running and the local API unavailable, all three pages rendered the normal empty-result message, **“No items found for the selected filter.”** Reloading reproduced the behavior.

The cause is explicit in each loader:

- `apps/web/src/pages/opportunities/index.astro:163` calls `fetchJsonWithFallback(..., {})`
- `apps/web/src/pages/contests/index.astro:57` calls `fetchJsonWithFallback(..., {})`
- `apps/web/src/pages/events/index.astro:77` calls `fetchJsonWithFallback(..., {})`

Each page then extracts an empty list and enters its ordinary empty branch:

- opportunities: `apps/web/src/pages/opportunities/index.astro:421-435`
- contests: `apps/web/src/pages/contests/index.astro:158-172`
- events: `apps/web/src/pages/events/index.astro:217-231`

The shared helper already exposes the correct primitive. `fetchJsonResult` preserves `ok`, status, payload, and the synthetic-unavailable response, while `fetchJsonWithFallback` intentionally discards that distinction:

- `apps/web/src/utils/api-fetch.ts:142-188`
- `apps/web/src/utils/api-fetch.ts:193-218`

The profile directory demonstrates the desired pattern: it uses `fetchJsonResult`, sets `loadError`, and renders a localized alert with a retry action:

- `apps/web/src/pages/profile/index.astro:100-115`
- `apps/web/src/pages/profile/index.astro:229-238`

#### Impact

This is more than cosmetic. During an outage, users are told that the marketplace legitimately has no opportunities, contests, or events. That can be mistaken for real business state.

#### Smallest useful remediation

1. Use `fetchJsonResult` in these three listing loaders.
2. Render one shared, localized retryable unavailable state when `ok === false`.
3. Keep the existing empty state only for a successful response containing zero items.
4. Add focused loader/render tests for HTTP 503 or the existing synthetic-unavailable response.

Do not add client-side state management or a second fetching library for this fix.

#### Acceptance proof

- API unavailable → localized alert and retry action.
- Successful empty response → current empty-result message.
- Successful non-empty response → existing listing behavior.
- Browser check at desktop and mobile sizes.

---

### P2 — Make collage-worker leases match its serial execution model

**Status:** confirmed design flaw; occurrence depends on job duration and configuration · **Area:** durable worker correctness and graceful shutdown · **SOLID relevance:** lease ownership and job execution responsibilities are coupled inside one large worker

#### Evidence

`ImageProcessingWorker.processBatch()` claims up to `batchSize` jobs and then processes them one by one:

- claim: `tfp-collage-service/src/services/imageProcessingWorker.ts:201-205`
- serial loop: `tfp-collage-service/src/services/imageProcessingWorker.ts:205-221`

`claimJobs()` gives every job in the batch a lease starting at the same moment:

- selection and `FOR UPDATE SKIP LOCKED`: lines 240-257
- one common `locked_until`: lines 258-269

There is no lease-refresh operation. A rendition or collage job may perform several storage reads, Sharp operations, writes, visibility checks, and database operations before publication. Publication correctly rejects an expired or stolen lease:

- rendering and public writes: lines 339-464
- publication lease check: lines 467-488

Configuration makes the mismatch material:

- code permits batch sizes from 1 to 100 and defaults to 10: `src/config.ts:189-194`
- deployment defaults the batch to 5: `scripts/deploy/deploy.sh:104-116`
- the lease defaults to 900 seconds but can be configured as low as 60 seconds

Therefore, later jobs can spend much of their lease merely waiting behind earlier jobs. A second worker can reclaim an expired job, or the original worker can finish expensive uploads and then fail `IMAGE_PROCESSING_LEASE_LOST`. For non-manifest jobs, `markCompleted()` does not check the affected-row count, so local “processed” metrics can also claim success after ownership was lost (`imageProcessingWorker.ts:731-737`).

Shutdown waits for the whole active batch (`imageProcessingWorker.ts:194-199`), while systemd allows 120 seconds (`deploy/tfp-collage-service.service:13-17`). Large/slow batches therefore also weaken graceful draining.

Current worker tests cover retry calculation, deterministic keys, publication, and revocation, but do not exercise batch claims, lease expiry/reclaim, lease renewal, or shutdown timing.

#### Smallest useful remediation

Use the existing serial model consistently:

1. Claim one job immediately before processing it.
2. Set the deployment batch size to 1 or remove batch preclaiming from the serial worker.
3. Treat a zero-row completion update as `IMAGE_PROCESSING_LEASE_LOST`.
4. Add a real PostgreSQL integration test for claim, expiry/reclaim, completion ownership, and stop/drain behavior.

Only add bounded concurrent execution plus a heartbeat if observed throughput later requires it. Do not introduce Redis/BullMQ for this issue.

#### Structural follow-on, only while making this fix

The 802-line worker currently contains polling/leases plus six job-type workflows. Preserve one runtime and one dispatch table, but move cohesive job handlers into a small `services/image-jobs/` area when those lines are already changing. This narrows reasons to change without introducing a framework.

#### Acceptance proof

- A slow job cannot cause an unstarted sibling job's lease to expire.
- A stolen lease cannot be reported as completed by the previous worker.
- SIGTERM either drains the active job inside the configured limit or leaves it safely reclaimable.
- Existing rendition/publication and revocation tests remain green.

---

### P2 — Test the AI outbox adapter against PostgreSQL, not only SQL fakes

**Status:** confirmed coverage gap · **Area:** AI worker persistence boundary · **Design-pattern relevance:** the repository port is good; its production adapter needs adapter-level proof

#### Evidence

`PostgresOutboxRepository` owns critical transactional behavior, including:

- ordered claim and stale recovery using `FOR UPDATE SKIP LOCKED`
- lease refresh through `updated_at`
- entity/text loading against application tables
- cancellation-safe completion
- deterministic result-event insertion
- retry and terminal-failure transitions

The adapter is substantial (`src/tfp_ai_interface/worker_repository.py`, 443 lines), but its dedicated test file has only two tests and an in-memory fake connection (`tests/test_worker_repository.py:11-80`). Those tests assert fragments of SQL strings; they do not prove PostgreSQL syntax, enums, table/column compatibility, transaction atomicity, concurrent claims, or schema drift.

The service's own CI runs Ruff, Pytest, build, and dependency audit, but defines no PostgreSQL service (`.github/workflows/ci.yml`). The application has a valuable strict cross-repository E2E workflow, but that suite also requires a real provider credential and is not a focused replacement for deterministic persistence-adapter tests.

The machine-readable AI outbox vocabulary is healthy: the current cross-language contract validator and all three validator tests pass. The gap is database behavior, not event naming.

#### Smallest useful remediation

1. Add a PostgreSQL service to the AI CI job or one dedicated integration-test job.
2. Apply the minimum application schema needed by the adapter, preferably from the owning app migration rather than a handwritten second schema.
3. Add 4–6 adapter tests covering:
   - two workers cannot claim the same row concurrently;
   - stale `PROCESSING` rows are reclaimable;
   - completion and deterministic result insertion are atomic;
   - cancellation wins over completion/failure;
   - retry exhaustion becomes terminal;
   - translation and moderation request priorities are preserved.

Keep fast fake-based unit tests for branch coverage; add integration tests only at the persistence boundary.

#### Acceptance proof

- AI CI proves the adapter against PostgreSQL with no external provider call.
- Contract validation and the existing 65 unit tests remain green.

---

### P3 — Move search read orchestration behind one query/use-case boundary

**Status:** confirmed against the repository's own architecture rulebook · **Area:** backend structure and single responsibility

#### Evidence

The rulebook says route modules own HTTP transport only and forbids inline business orchestration (`docs/architecture/ARCHITECTURE_RULEBOOK.md:17-33`). Queries own read-side orchestration and response shaping (`:63-70`).

`apps/api/src/modules/search/search.routes.ts` is 368 lines and currently owns all of the following:

- response-wide media resolution across artists, portfolios, opportunities, events, and contests (`:24-135`)
- a large inline schema and query normalization (`:149-228`)
- explicit/profile/approximate location resolution (`:229-290`)
- search execution input assembly (`:296-324`)
- product-metric derivation and emission (`:326-353`)
- final result shaping (`:355-358`)

This passes the current import gate because it does not directly import Prisma. It nevertheless violates the stronger transport-only rule and has several independent reasons to change.

#### Smallest useful remediation

Extract one cohesive search query/use-case that receives parsed search input and request context, then returns the shaped result plus metric facts. Leave these concerns in the route:

- route registration
- HTTP schema binding/parsing
- auth/rate-limit/cache hookup
- HTTP response mapping

Do not split every function into a class, add generic base handlers, or wrap the existing read-model SQL in ceremonial repositories. `search.service.ts` is valid read/query infrastructure even though its historical filename says “service.”

#### Acceptance proof

- Route tests still cover HTTP parsing and status behavior.
- Query tests cover location fallback, media shaping, and metric facts without Fastify injection.
- `lint:architecture`, API typecheck, and search integration tests pass.

---

### P3 — Tighten stale hotspot caps so the gate remains meaningful

**Status:** confirmed low-risk maintenance gap · **Area:** architecture regression guard

#### Evidence

`scripts/architecture/enforce-boundaries.mjs:36-38` states that caps are the current size plus a small buffer and must be lowered when a file shrinks. Several caps now have much larger margins:

| File | Current lines | Cap | Unprotected regrowth |
|---|---:|---:|---:|
| `apps/api/src/modules/opportunity/opportunity.routes.ts` | 547 | 1,100 | 553 lines |
| `apps/web/src/pages/search.astro` | 389 | 800 | 411 lines |
| `apps/mobile/src/infrastructure/api/api-content-session-operations.ts` | 126 | 235 | 109 lines |
| `apps/api/src/modules/event/event.routes.ts` | 115 | 180 | 65 lines |

The architecture gate passes, but these entries no longer enforce the policy described directly above them.

#### Smallest useful remediation

Lower stale entries to current line count plus a deliberately small buffer in one mechanical change. Do not refactor files merely to hit an arbitrary number.

#### Acceptance proof

- `pnpm lint:architecture` passes at the new baselines.
- A small fixture/test demonstrates that growth beyond a cap fails the gate, if that behavior is not already covered.

---

### P3 — Address two localized hotspots when next touched

These are real but do not justify standalone redesign projects.

#### A. Web admin runtime is at its growth limit

`apps/web/src/scripts/admin/index.js` is 2,746 lines against a 2,775-line cap. The gate itself labels it a migration target. On the next functional admin change, extract one cohesive behavior into the existing `apps/web/src/scripts/admin/` module area and lower the cap. Do not rewrite the admin frontend or introduce a new state framework solely for file size.

#### B. Collage test-page copy contradicts actual behavior

The local collage test page claims:

- “Fixed 3:4 canvas”
- “No crop”

But its default controls are 1200×675 (16:9), the README documents 16:9, and the renderer uses centered crop (`src/server.ts:79-105`, `README.md:174`, `src/services/collageMaker.ts:81`). Change the chips to truthful wording such as “Configurable canvas” and “Centered crop.” This is a documentation/UI accuracy fix, not a rendering redesign.

---

## Folder-structure assessment

### `tfpphotographers`

**What is working**

- API source is organized primarily by business domain under `apps/api/src/modules/`.
- Mature/high-risk domains such as moderation and translation already separate application, domain, infrastructure, provider, and strategy concerns.
- Persistence adapters live in domain repositories or query infrastructure.
- Web source has understandable separation between pages, reusable components, server-side features, client scripts, utilities, and layered styles.
- Shared packages have bounded ownership: config, database, email, i18n, moderation, shared contracts, storage, and uploads.

**What to improve**

- Continue the route-thinning program only in high-change domains, starting with search.
- When a flat legacy domain is changed substantially, move toward the documented `routes/`, `handlers/`, `commands/`, `queries/`, `repositories/`, `policies/`, `mappers/`, and `contracts/` shape. Do not normalize every domain in a single migration.
- Extract from the admin runtime only at real behavior boundaries and lower its cap after each extraction.

### `tfp-ai-interface`

**Assessment:** the flat Python package is appropriate for its current size. The service already separates API, settings, prompt/policy, provider behavior, worker ports, worker orchestration, and the PostgreSQL repository. Creating a deep DDD folder hierarchy would make navigation worse today.

**Improvement:** strengthen the repository adapter's integration proof. Split the package only if new providers or independent domain workflows materially increase.

### `tfp-collage-service`

**What is working**

- `ports/` contains narrow renderer contracts.
- `adapters/` contains the concrete Sharp and balanced-collage implementations.
- storage is abstracted from orchestration.
- `routes.ts`, `server.ts`, config, CLI, and worker responsibilities are discoverable.

**Improvement:** keep lease/poll ownership in the worker and extract cohesive image-job workflows when correcting the lease issue. Move tests out of `src/tests/` only during an intentional test-layout change; relocating files alone adds no product value.

---

## SOLID and design-pattern assessment

| Principle | Assessment | Evidence / practical action |
|---|---|---|
| **Single Responsibility** | Mostly good; two hotspots | Search route and collage worker have multiple reasons to change. Apply the focused extractions described above. |
| **Open/Closed** | Good | AI providers, storage, rendition providers, and collage renderers enter through existing ports/adapters. Add implementations behind those ports, not new conditionals in routes. |
| **Liskov Substitution** | No confirmed violation | Existing adapter contracts are narrow enough for substitution. Avoid weakening them with provider-specific return shapes. |
| **Interface Segregation** | Good | Renderer and worker ports are small. Do not create a single “platform service” interface spanning storage, AI, metrics, and persistence. |
| **Dependency Inversion** | Good direction, one test-composition gap | Production capabilities are wired centrally, and AI/collage orchestration depends on ports. Restore the Fastify test composition root and add real adapter tests. |

### Patterns to keep

- **Transactional outbox / competing consumers:** correct for durable domain work close to PostgreSQL state.
- **Command/query/repository boundaries:** useful in the application backend where workflows and persistence are complex.
- **Ports and adapters:** appropriate for AI providers, rendering, storage, email, and other external systems.
- **Strategy/provider selection:** appropriate where two or more real implementations or environment choices exist.
- **Immutable media manifests and publication gates:** strong consistency and rollback-friendly design.

### Patterns not justified now

- Redis/BullMQ migration without measured backlog or polling pain
- additional microservices
- event sourcing
- a global IoC/DI container
- universal base repository/service/handler classes
- builders for ordinary payloads
- one factory per class
- a frontend state-management framework for server-rendered listing errors

“Enterprise grade” here should mean explicit ownership, deterministic failure handling, observable state, reproducible CI, and tested boundaries—not the maximum number of layers.

---

## What passed and should not be rewritten

| Area | Result |
|---|---|
| Application architecture gate | Passed |
| Application ESLint gate | Passed with zero warnings |
| API typecheck | Passed |
| Web typecheck | Passed: 0 errors, 0 warnings; Astro emitted informational hints |
| Web unit tests | Passed: 94 files, 529 tests |
| Web design-token and inline-asset audits | Passed |
| AI Ruff | Passed |
| AI Pytest | Passed: 65 tests |
| AI package build | Passed: source distribution and wheel |
| AI outbox cross-language contract | Passed |
| AI contract-validator tests | Passed: 3 tests |
| Collage compile and tests | Passed: 35 tests |
| Responsive home-page browser review | Passed at desktop and mobile sizes; no confirmed visual defect or browser error |
| Profile-directory outage state | Passed: truthful error alert and retry action |

The API suite is the sole red validation result in this review and is documented as P1.

---

## Recommended delivery order

### Batch 1 — Restore trust

1. Repair the five stale API route tests.
2. Run the targeted tests, full API suite, and `coverage:all`.

### Batch 2 — Correct user-visible failure semantics

1. Preserve API failure state on opportunities, contests, and events.
2. Add focused tests and inspect all three pages at desktop and mobile sizes.

### Batch 3 — Harden durable adapters

1. Make collage claims just-in-time for serial processing and test lease ownership.
2. Add AI PostgreSQL adapter integration tests in its own CI.

These are independent changes and should remain separate commits.

### Batch 4 — Opportunistic structure maintenance

- Extract search orchestration when that domain is next modified.
- Tighten stale hotspot caps mechanically.
- Split one admin behavior on the next admin change.
- Correct the collage test-page copy.

---

## Review limitations and certification boundary

This is a real source/test/browser review, but it is not a full release certification:

- The local web frontend and AI liveness endpoint were already running.
- The local application API and collage service were not running, so they were not restarted or mutated during this review.
- The API outage enabled direct validation of frontend failure behavior, but prevented authenticated and full cross-service browser journeys.
- No UAT deployment, protected UAT login, live database mutation, paid AI request, storage write, or CDN purge was performed.
- Secrets were deliberately excluded from findings, as requested.

Before a release, run the checked-in TEST/UAT workflows with traceable revisions and verify API, web, database, workers, outbox, AI readiness, collage readiness, and representative browser journeys together.
