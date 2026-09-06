# 🧹 TFP DRY, Modularity, and Cleanup Audit

- **Audit date:** 6 September 2026
- **Scope:** `tfpphotographers` backend/frontend/shared packages, `tfp-ai-interface`, and `tfp-collage-service`
- **Method:** source-clone discovery followed by consumer, package-script, CI, documentation, deployment, test, and Git-history tracing
- **Companion review:** [Enterprise application improvement review](./2026-09-06-enterprise-application-improvement-review.md)
- **Decision rule:** remove or consolidate only when the evidence is stronger than the risk; do not create abstractions merely to reduce a line-count metric

## Executive outcome

The active services are **already reasonably DRY and modular**. The application source scan found only **0.12% duplicated lines**, while the scoped AI and collage source scans found no clone groups. Most apparent duplication is intentional: it preserves platform entry points, route compatibility, fixture meaning, or separate trust boundaries.

The audit did confirm a small cleanup set:

- **6 tracked, unreferenced one-off scripts removed** from `tfpphotographers` (**498 lines**)
- **45 `.DS_Store` files removed** from the three active repositories
- Python test/lint/bytecode caches and locally generated AI/collage `dist` outputs removed
- **No production source deleted** from `tfp-ai-interface` or `tfp-collage-service`, because no candidate met the proof threshold

This is intentionally not a broad refactor. The PostgreSQL outbox, worker state, runtime media/model assets, QA evidence, platform-specific files, compatibility routes, and user-authored changes were preserved.

## What was actually deleted

### Tracked obsolete scripts

| Removed file | Why it was dead | Maintained replacement |
|---|---|---|
| `tfpphotographers/add_missing_keys.js` | One-time English catalog mutator; no source, script, CI, doc, or deployment consumer | `packages/i18n/scripts/sync-master-keys.mjs` plus locale tests |
| `tfpphotographers/check_i18n.js` | Ad-hoc regex checker; unreferenced and narrower than current validation | `packages/i18n/scripts/validate-locales.mjs` |
| `tfpphotographers/scripts/update-i18n.js` | Historical one-time catalog rewrite; no consumer | Canonical i18n sync and validation package scripts |
| `tfpphotographers/scripts/sync-i18n.ts` | Unreferenced legacy sync tool with a placeholder translation function | `pnpm --filter i18n sync:master` and `validate:locales` |
| `tfpphotographers/test-ui.js` | One-off Playwright runner with machine-specific screenshot paths | Checked-in Playwright suites and shared fixtures |
| `tfpphotographers/tests/puppeteer_test_location.js` | One-off local Puppeteer check with a machine-specific output path | Domain and journey Playwright coverage |

Every basename was searched across source, tests, package scripts, CI, documentation, and deploy files before deletion. Git history confirmed that these were historical migration or ad-hoc testing helpers rather than active entry points.

### Ignored disposable artifacts

The following local-only artifacts were removed and are recoverable by normal tools if needed:

- `.DS_Store` metadata in the three active repositories
- `__pycache__`, `.pytest_cache`, and `.ruff_cache` under `tfp-ai-interface`
- locally generated `dist/` packages in `tfp-ai-interface`
- locally generated `dist/` JavaScript in `tfp-collage-service`

Dependencies, virtual environments, generated QA evidence, uploaded media, model assets, runtime state, and database files were not removed.

## DRY findings

### Source-level result

| Repository | Scoped result | Verdict |
|---|---:|---|
| `tfpphotographers` | 6 clone groups, 125 duplicated lines, **0.12%** | Very low duplication; no broad DRY project justified |
| `tfp-ai-interface` | 0 clone groups in Python source/scripts | No actionable source duplication |
| `tfp-collage-service` | 0 clone groups in TypeScript source | No actionable source duplication |

The scan excluded generated output, dependencies, migrations, locale catalogs, tests, and media fixtures where repetition is expected or semantically meaningful. Clone detection was used only to discover candidates; it was not treated as deletion proof.

### Intentional duplication retained

| Candidate | Decision | Reason |
|---|---|---|
| `packages/shared/src/location-context.ts` and `.native.ts` | **Keep** | Conditional package exports intentionally keep the React Native entry free of Node/request-only dependencies |
| Web/mobile brand and home assets | **Keep** | Astro public assets and Expo bundled assets have different build roots |
| `forgot-password.astro` and `reset-password.astro` redirects | **Keep** | Separate URLs are compatibility contracts and are exercised by route/E2E coverage |
| Duplicate seed and moderation fixture images | **Keep** | Paths encode distinct fixture roles and expected moderation categories |
| Small package `tsconfig.json` files | **Keep** | Declarative package boundaries are clearer than a new inheritance layer for a few repeated fields |
| Browser persisted-link validation and server config URL validation | **Keep separate** | Similar private-address checks protect different trust boundaries; coupling browser content validation to server configuration would enlarge the shared security surface |

### Small reuse opportunities—not urgent rewrites

1. **Public detail-cache flow:** event, contest, and opportunity read routes repeat a small cache-read/cache-write pattern. Extend `apps/api/src/utils/public-list-cache.ts` with one focused detail-cache helper when one of those routes next changes.
2. **Legal request creation:** two short blocks in `legal.routes.ts` are similar but remain readable. Extract only if a third flow appears or the payload contract changes together.
3. **Location-aware listings:** event and opportunity routes already reuse the shared request-location resolver; their remaining parameter assembly is domain-specific and does not justify another layer.

The first item is the only clear near-term DRY improvement. It should be a targeted helper with unchanged cache keys and response behavior, not a generic repository or route framework.

## Modularity and reuse assessment

### `tfpphotographers` backend and frontend

**Healthy boundaries**

- API domains own commands, queries, repositories, policies, and route adapters where complexity requires them.
- Shared packages have coherent ownership for config, database, email, i18n, moderation, storage, uploads, and cross-platform contracts.
- Web pages reuse API-fetch, media, i18n, design-token, and component primitives rather than introducing a second client framework.
- Architecture and lint gates actively protect dependency direction.

**Focused improvements**

- Move search orchestration behind one query/use-case boundary; keep HTTP concerns in the route.
- Reuse one public detail-cache helper across the three read domains when touched.
- Lower stale architecture caps mechanically so they remain shrink-only.
- Split a cohesive admin behavior only during the next real admin change.

### `tfp-ai-interface`

The current flat package is suitable for its size. API, settings, prompt/policy, provider adapter, worker service, worker port, and PostgreSQL repository responsibilities are distinguishable. A deeper DDD directory tree would add navigation cost without a present benefit.

The material gap is test depth, not module layout: the PostgreSQL outbox adapter needs focused real-PostgreSQL integration coverage.

### `tfp-collage-service`

Ports, concrete rendering adapters, storage, HTTP routes, configuration, CLI, and worker orchestration are discoverable and have no confirmed duplicate or dead source.

The worker's batch lease and serial execution mismatch is a correctness issue. Correct that first; extract cohesive image-job handlers only while changing that area. Do not add Redis, BullMQ, a DI container, or more services for this fix.

## What the seven findings mean and what should be fixed

| Priority | Issue in plain language | Smallest planned fix |
|---|---|---|
| **P1** | Five API route tests build an incomplete Fastify test app, so CI is red even though production wiring exists | Add the narrow `mediaDelivery` fake to the affected contest/opportunity fixtures, assert its calls, then run targeted, full API, and coverage gates |
| **P2** | Opportunities, contests, and events say “No items found” during an API outage | Use `fetchJsonResult`, render one localized retryable unavailable state on failure, and reserve the empty message for a successful zero-item response |
| **P2** | Collage jobs are leased in a batch but processed one at a time, so later leases can expire before processing | Claim one job immediately before serial processing and reject zero-row completion; add PostgreSQL lease/reclaim tests |
| **P2** | AI outbox SQL is checked mostly with fakes, so real PostgreSQL/schema/transaction drift can escape CI | Add a small PostgreSQL-backed adapter suite with no paid provider call |
| **P3** | The search HTTP route also performs location, media, query, metric, and response orchestration | Extract one cohesive search query/use case while leaving transport concerns in the route |
| **P3** | Some architecture line caps allow hundreds of lines of regrowth | Lower them to current size plus a small deliberate buffer |
| **P3** | The admin runtime is near its cap and collage test-page copy is inaccurate | Correct the collage copy directly; extract one admin behavior only when that code is next changed |

### Delivery order

1. **Restore trust:** repair the five API tests and return the full CI/coverage gate to green.
2. **Correct user-facing truth:** distinguish API failure from a legitimate empty result on all three public listings.
3. **Harden durable persistence:** correct collage lease ownership and add AI PostgreSQL adapter tests.
4. **Apply small maintenance changes:** tighten caps, thin search, correct collage copy, and extract admin behavior only when touched.

The six obsolete-script deletions in this audit are complete. The seven functional fixes above remain separate implementation changes so each can be reviewed, tested, and rolled back independently.

## Verification

### Passed after cleanup

- `bash ./scripts/pnpm-node20.sh lint:architecture`
- `bash ./scripts/pnpm-node20.sh lint:eslint`
- `bash ./scripts/pnpm-node20.sh --filter i18n validate:locales` — 95 language catalogs and 5 regional overrides
- `bash ./scripts/pnpm-node20.sh --filter i18n test` — 4 files, 128 tests
- post-deletion reference search for all six removed basenames — no consumers

The earlier full review also passed web, AI, and collage validation. Its known API-suite failure is the documented P1 fixture problem, not a cleanup regression.

## Certification boundary

This audit certifies the candidates actually traced; it does not claim that a heuristic can mathematically prove every unused symbol in a dynamic Astro/Fastify/Expo workspace. A broad Knip result was rejected because it incorrectly labeled framework entry points, registered routes, CLIs, tests, and dynamically loaded modules as unused. Python Vulture at the high-confidence threshold reported no removable production symbols.

That conservative boundary is intentional: an enterprise cleanup should prefer a small verified deletion over a large speculative one.
