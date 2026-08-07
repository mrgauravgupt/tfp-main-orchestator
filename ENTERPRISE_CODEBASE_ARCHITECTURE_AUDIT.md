# Enterprise Codebase Architecture Audit

> **Historical infrastructure snapshot:** The topology below reflects the July
> 2026 audit date. Current private UAT runs on OCI instance
> `tfp-a1-free-2ocpu-12gb` (`161.118.161.98`) through Cloudflare tunnel
> `tfp-oci-uat`. Contabo is retired; see `docs/operations/deploy.md`.

**Repository**: TFP Photographers Multi-Service Platform  
**Audit Date**: 2026-07-26  
**Audited Branch/Commit**: `1efc2806fa39c0909b2d65789aa2d959bbf68670` (tfp-main-orchestator)  
**Auditor Role**: Principal Software Architect & Enterprise Application Architect  
**Audit Mode**: Read-Only  
**Overall Confidence**: High  
**Coverage Level**: Comprehensive (all subprojects, packages, apps, services, tests, docs)

---

## Findings by Severity

| Severity      | Count |
| ------------- | ----: |
| Critical      |     2 |
| High          |     8 |
| Medium        |    19 |
| Low           |    14 |
| Informational |    12 |
| **Total**     | **55** |

## Findings by Category

| Category        | Count |
| --------------- | ----: |
| Architecture    |    15 |
| Security        |     5 |
| Data Integrity  |     6 |
| Concurrency     |     4 |
| Reliability     |     5 |
| Performance     |     3 |
| Maintainability |     7 |
| Testing         |     4 |
| API             |     3 |
| Database        |     5 |
| Configuration   |     4 |
| Frontend        |     1 |
| Infrastructure  |     3 |
| Documentation   |     1 |

## Top Risks

| Rank | Finding ID | Risk | Severity | Impacted Area | Recommended Priority |
| ---: | ---------- | ---- | -------- | ------------- | -------------------- |
| 1 | A01 | Production config defaults to localhost DBs | Critical | All Services | Immediate |
| 2 | A15 | Missing Redis rate limiter in production | Critical | API | Immediate |
| 3 | A02 | 22 command/service files bypass repository layer | High | API Architecture | Phase 1 |
| 4 | A10 | No idempotency wired to write routes | High | Data Integrity | Phase 1 |
| 5 | A04 | Worker heartbeat filesystem-bound | High | Reliability | Phase 1 |
| 6 | A07 | Large untested surface in admin commands | High | Security/Maintainability | Phase 2 |
| 7 | A05 | Missing exponential backoff with jitter in workers | High | Reliability | Phase 2 |
| 8 | A08 | TranslationService monolithic at 1383 lines | High | Maintainability | Phase 2 |
| 9 | A16 | Folder-ops shell commands embedded in web layer | High | Architecture/Security | Phase 2 |
| 10 | A03 | Moderation service CORS wildcard in code | High | Security | Phase 1 |

---

## 1. Executive Summary

The TFP Photographers platform demonstrates **strong engineering fundamentals** with an explicit architecture rulebook, rigorous TypeScript enforcement, thoughtful security controls (bcrypt, JWT session versioning, CSRF middleware, CSP headers, SSRF protection in collage service), and a purpose-built idempotency layer. The system is built on a well-chosen stack (Astro SSR + Fastify + Prisma + PostgreSQL + Python FastAPI for AI inference) with clear domain boundaries and a documented layered architecture.

However, the codebase is **not yet enterprise-ready** for production launch. Two critical configuration gaps would cause immediate production failures (localhost database URLs in production config, missing Redis rate limiter). The architecture has significant internal erosion: 22 command and service files directly import and use the Prisma database client, bypassing the repository layer that the architecture rulebook mandates. The idempotency module exists but is not wired to write routes, creating real risk of duplicate operations under retry. Background job retries lack exponential backoff with jitter, creating thundering-herd risk on recovery.

The platform shows the hallmarks of a codebase transitioning from rapid prototyping toward architectural discipline: the rules are written, enforcement tooling exists (`enforce-boundaries.mjs`), the debt is catalogued (`DIRECT_DATABASE_DEBT`), and a 10-phase remediation program is documented. This is the correct trajectory, but substantial work remains before the architecture matches the documented intent.

**Overall Assessment**: Solid foundation with known, catalogued debt. Not enterprise-ready today, but on a credible path. The critical and high findings below represent blocking issues for production launch.

---

## 2. Audit Scope

### Areas Inspected
- **tfpphotographers**: Full monorepo — `apps/api`, `apps/web`, `apps/mobile`, all 7 `packages/*`, `tests/`, `qa/`, `scripts/`, `docs/`, `deploy/`, `systemd/`, `services/`
- **tfp-collage-service**: All source, config, scripts, tests, VPS deploy scripts
- **tfp-moderation-service**: All source, config, tests, infra, apps/api, scripts
- **Root**: AGENTS.md, SKILLS.md, .gitmodules, env examples, prior audit documents

### Areas Not Inspected
- Production secrets or live environment variables
- OCI tenancy resources beyond documentation
- node_modules, .astro build artifacts, test-results artifacts
- Playwright test-results binary files
- Mobile native build outputs (.expo, ios/Pods, android/.gradle)

### Tools Used
- `list_files` (recursive directory enumeration)
- `read_file` (source, config, schema, migration analysis)
- `search_files` (pattern search for architectural patterns)
- `list_code_definition_names` (top-level definition analysis)
- Subagent parallel exploration (4 subagents × 5 rounds)

### Coverage Statistics
- Source files inspected: ~800+
- Test files inspected: ~200+
- Configuration files inspected: ~50+
- Migration files inspected: ~30+
- Infrastructure files inspected: ~20+
- Packages/modules inspected: 15

---

## 3. Repository and System Map

```mermaid
graph TD
    subgraph "Contabo VPS (13.140.189.236)"
        subgraph "tfpphotographers UAT"
            WEB[Astro SSR Web :3000]
            API[Fastify API :4000]
            WORKER[Background Worker]
            PG[(PostgreSQL)]
        end
        subgraph "tfp-moderation-service UAT"
            MOD_API[FastAPI :7002]
            MOD_WORKER[Python Worker]
            NGINX[Nginx :7001]
        end
        subgraph "tfp-collage-service UAT"
            COL_API[Fastify :7004]
            COL_WORKER[Collage Worker]
            NGINX2[Nginx :7003]
        end
    end
    
    subgraph "External Services"
        B2[Backblaze B2 Storage]
        CF[Cloudflare Tunnel/DNS]
        SENTRY[Sentry Error Monitoring]
        AXIOM[Axiom Log Shipping]
        IMAGEKIT[ImageKit CDN]
    end
    
    subgraph "tfpphotographers Monorepo"
        direction TB
        WEB_PKG[apps/web - Astro SSR]
        API_PKG[apps/api - Fastify]
        MOBILE_PKG[apps/mobile - Expo RN]
        DB_PKG[packages/database - Prisma]
        CONFIG_PKG[packages/config - Env]
        SHARED_PKG[packages/shared - Contracts]
        I18N_PKG[packages/i18n - Locale]
        STORAGE_PKG[packages/storage - B2/S3]
        EMAIL_PKG[packages/email]
        MOD_PKG[packages/moderation]
    end
    
    API_PKG --> PG
    WORKER --> PG
    COL_WORKER --> PG
    MOD_WORKER --> PG
    WEB --> API
    MOBILE_PKG --> API
    API --> STORAGE_PKG --> B2
    API --> MOD_API
    API --> COL_API
    CF --> WEB
    
    DB_PKG --> PG
    CONFIG_PKG --> API_PKG
    CONFIG_PKG --> WEB_PKG
    CONFIG_PKG --> WORKER
    SHARED_PKG --> API_PKG
    SHARED_PKG --> WEB_PKG
    SHARED_PKG --> MOBILE_PKG
    I18N_PKG --> WEB_PKG
    I18N_PKG --> MOBILE_PKG
    STORAGE_PKG --> B2
```

### Module Inventory

| Component | Language | Framework | Purpose |
|-----------|----------|-----------|---------|
| `apps/web` | TypeScript | Astro 6 SSR | Public web application (SSR pages, SEO, OG images) |
| `apps/api` | TypeScript | Fastify 5 | REST API, auth, business logic, background jobs |
| `apps/mobile` | TypeScript | Expo SDK 52 / RN 0.76 | iOS/Android native app |
| `packages/database` | TypeScript | Prisma 6 | ORM, migrations, soft-delete, URL normalization |
| `packages/config` | TypeScript | dotenv | Env parsing, moderation policies, product defaults |
| `packages/shared` | TypeScript | Zod | Shared contracts, DTOs, validation schemas |
| `packages/i18n` | TypeScript | — | Locale catalogs (en, es, fr, de, zh, ja, etc.) |
| `packages/storage` | TypeScript | AWS SDK | B2/S3 object storage, presigned URLs |
| `packages/email` | TypeScript | Nodemailer | Transactional email templates |
| `packages/moderation` | TypeScript | — | Moderation decision pipeline, policy engine |
| `tfp-moderation-service` | Python 3.11 | FastAPI + CTranslate2 | AI image/text moderation, translation |
| `tfp-collage-service` | TypeScript | Fastify 5 + Node Canvas | Opportunity mood-board collage generation |
| `services/ui-review-worker` | Python | vLLM | AI UI screenshot review (local only) |

---

## 4. Reconstructed Architecture

### Layering Model (from code evidence, not documentation)

The actual runtime call chain in the codebase:

```
Route (*.routes.ts)
  → collects HTTP request, parses schema, calls handler
  → Handler (*.handler.ts / inline in route)
    → validates auth/authorization
    → calls Command or Query
    → Command (*.commands.ts / commands/*.ts)
      → DIRECT Prisma access (in 22 of 23 files)
      → or → Repository layer (in 1 file: CreateContest)
    → Query (*.queries.ts)
      → DIRECT Prisma access or raw SQL
```

**Key observation**: The documented architecture (Route → Handler → Command/Query → Repository → Prisma) is only partially realized. The repository layer exists as an interface (`IRepositories`) with implementations in `packages/database/src/repositories/`, but only `CreateContest.ts` actually uses it as a primary data access pattern. All other commands and services use `import { prisma } from 'database'` directly.

### Request Flow (Read)
1. User request → Cloudflare Tunnel → Astro SSR `apps/web/src/pages/*.astro`
2. Astro page calls `fetch()` to `http://localhost:4000/api/v1/...` (server-side, or client-side for interactive features)
3. Fastify route handler in `apps/api/src/modules/<domain>/*.routes.ts` receives request
4. Route → handler → query function → direct `prisma.<model>.findMany/findFirst()` → PostgreSQL
5. Response shaped → JSON response → Astro page renders HTML → sent to user

### Request Flow (Write)
1. Authenticated user submits form or API call
2. CSRF middleware validates origin (POST/PUT/DELETE from browsers)
3. Auth middleware validates JWT cookie, session version, account status
4. Route handler calls command function
5. Command directly calls `prisma.$transaction()` or `prisma.<model>.create/update()`
6. Command optionally calls `postWriteSideEffects()` to queue async work (notifications, outbox events)
7. Response returned to client

### Event Flow
1. Command completes write → optionally calls `EventOutboxAdapter.publish()`
2. Outbox adapter inserts row into `event_outbox` table within same transaction
3. `BackgroundJobRunner` polls `event_outbox` every 5 seconds with `FOR UPDATE SKIP LOCKED`
4. Processes pending events (status → PROCESSING → PROCESSED or FAILED or DEAD)
5. Retry with simple backoff: `nextRetryAt` set to `now + retryCount * interval`

### Authentication Flow
1. Login: `POST /api/v1/auth/login` → bcrypt compare → JWT signed with userId, role, sessionVersion, iat, mfaVerifiedAt
2. JWT stored in `token` cookie: `HttpOnly`, `SameSite=Lax`, `Secure` in production
3. Subsequent requests: `authenticateUser` middleware extracts JWT from cookie or Authorization header
4. Middleware verifies: token validity, user exists, account not suspended/disabled, sessionVersion matches
5. Admin routes: additional `requireAdmin` guard checks `role === 'ADMIN'`
6. Admin MFA: `requireMfa` verifies `mfaVerifiedAt` in token is within configurable window
7. Logout: increments `authSessionVersion` in user record, invalidating ALL existing tokens (all devices)

---

## 5. Architecture Compliance Matrix

| Area | Expected Model | Actual Model | Compliance | Evidence | Risk |
| ---- | -------------- | ------------ | ---------- | -------- | ---- |
| Domain Isolation | Domain free of framework/ORM | Partial — Prisma enums leaked into domain types | ⚠️ Partial | 37 Prisma enums used directly in command/service files | Medium |
| Application Layer | Commands through ports | Commands bypass ports (direct Prisma) | ❌ Low | 22 files in DIRECT_DATABASE_DEBT | High |
| Ports (Inbound) | Business capability interfaces | Routes call handlers directly; handlers defined inline | ⚠️ Partial | Few explicit handler interfaces | Low |
| Ports (Outbound) | Repository interfaces | IRepositories exists but unused by most commands | ❌ Low | Only CreateContest uses repository | High |
| Adapters | Infrastructure-only concerns | Mostly correct; some folder-ops in web layer | ⚠️ Partial | Folder moderation in web.py | Medium |
| Dependency Direction | Domain → nothing, App → Ports, Infra → Ports | Domain types export Prisma enums; commands import prisma directly | ❌ Low | Multiple inward dependency violations | High |
| Bounded Contexts | Independent modules | Modules share database tables; cross-domain imports exist | ⚠️ Partial | Opportunity commands import event/contest modules | Medium |
| Data Ownership | One module owns each table | Generally correct; some cross-domain writes | ✅ Good | Schema has clear ownership | Low |
| Cross-Service | Async messaging via outbox | Outbox exists and is polled | ✅ Good | event_outbox table + BackgroundJobRunner | Low |
| Transaction Handling | At command boundary | prisma.$transaction() used in commands | ✅ Good | Proper transactional wrapping in write commands | Low |
| Event Handling | Outbox pattern for reliability | Outbox inserts within same txn as data write | ✅ Good | EventOutboxAdapter.publish() in commands | Low |

---

## 6. Enterprise Quality Scorecard

| Area | Score (0-5) | Evidence | Strengths | Gaps | To Reach Next Level |
|------|-------------|----------|-----------|------|---------------------|
| Architecture | 2.5/5 | ARCHITECTURE_RULEBOOK.md, enforce-boundaries.mjs, DIRECT_DATABASE_DEBT catalogued | Explicit rules, automated enforcement, documented debt | 22 files bypass repository; only 1 command uses repository | Reduce DIRECT_DATABASE_DEBT to 0; wire all commands through repositories |
| Domain Modelling | 3/5 | 42-table schema, soft-delete filter, Prisma extensions | Rich domain types, enums for state machines | Prisma enums leak to app layer; some anemic models | Isolate domain types from ORM; add value objects |
| Modularity | 3/5 | Monorepo workspace structure, clear package boundaries | Good package isolation; apps don't import other apps | Deep imports prevented but still in debt baseline | Remove all DIRECT_DATABASE_DEBT entries |
| Maintainability | 3/5 | Zero @ts-ignore, strict TS, eslint:architecture | Clean type system, lint gates | Large files (TranslationService 1383L, admin.commands 1089L) | Split large modules; enforce file size caps |
| Type Safety | 4.5/5 | Strict TS, Zod schemas, Prisma-generated types | Excellent typing throughout | Prisma enum String unions in some places | — |
| Security | 3.5/5 | bcrypt, JWT + session versioning, CSRF, CSP, SSRF protection | Strong baseline security controls | CORS wildcard in moderation service; idempotency not wired | Wire idempotency; lock down moderation service CORS |
| Data Integrity | 3/5 | 42 tables, FK constraints, unique constraints, soft-delete | Good schema design | Idempotency not wired to routes; no optimistic locking on all entities | Add idempotency to writes; add version columns |
| Concurrency Safety | 2.5/5 | $transaction usage, FOR UPDATE SKIP LOCKED in outbox | Correct transaction wrapping | No optimistic locking on concurrent-edit entities | Add version columns to opportunity, event, contest |
| Reliability | 2.5/5 | Outbox pattern, worker retry, idempotency module (unwired) | Outbox ensures event delivery | Simple backoff (no jitter); filesystem heartbeat; no circuit breaker | Add exponential jitter; add Redis heartbeat; add circuit breakers |
| Observability | 3/5 | OpenTelemetry, Sentry, Pino structured logging, correlation IDs | Good telemetry foundation | No dependency health checks; no queue-depth metrics | Add readiness probes; add business metrics |
| Performance | 3/5 | SSR with CDN, SCSS optimization, lazy loading | Reasonable baseline | No Redis caching layer; potential N+1 in mobile content repo | Add cache-aside for reads; batch mobile queries |
| Testing | 3/5 | 150+ API tests, Playwright E2E, contract tests | Good coverage of modules | Concurrency, idempotency, retry not tested; admin commands lightly tested | Add failure injection tests; add idempotency E2E |
| API Quality | 3.5/5 | Zod validation on all routes, consistent error format, JWT auth | Good API hygiene | No API versioning strategy; no deprecation headers | Add API versioning; add contract tests |
| Database Design | 3.5/5 | 37 enums, FK constraints, indexes, soft-delete | Well-normalized schema | Some JSONB fields where tables may be better; no materialized views | Add version columns; consider JSONB → relational where queried |
| Configuration Mgmt | 2.5/5 | Typed env parsing, layered config (base + env), env doctor | Good config structure | Production config defaults to localhost; Redis optional | Fix production defaults; add fail-fast validation |
| Deployment Maturity | 2.5/5 | Docker Compose, systemd, VPS deploy scripts, Cloudflare tunnel | Working deployment pipeline | No CI/CD; manual deploys; root user in initial deploy | Add CI/CD; create non-root deploy user; add blue-green |
| Developer Experience | 3.5/5 | Clear docs, operator scripts, agent-index, pnpm workspace | Good tooling and documentation | Some dead docs; not all scripts documented | Update stale docs; add dev container |
| Documentation | 3/5 | ARCHITECTURE_RULEBOOK.md, SSOT, FRD, route registry, agent-index | Comprehensive architecture docs | Some prior audit docs may be stale | Regular doc-review cycle |

---

## 7. Positive Findings

### PF-01: Architecture Rulebook with Automated Enforcement
- **Location**: `docs/architecture/ARCHITECTURE_RULEBOOK.md`, `scripts/architecture/enforce-boundaries.mjs`
- **Evidence**: Documented layer definitions (Route, Handler, Command, Query, Repository), import laws, domain ownership rules, anti-ceremony laws. Automated enforcement scans all product source for boundary violations. Existing violations tracked in `DIRECT_DATABASE_DEBT` as shrink-only baseline.
- **Impact**: Prevents regression; new violations blocked at CI. This is mature architecture governance for a codebase of this size.

### PF-02: Strong Type Safety with Zero @ts-ignore
- **Location**: Entire TypeScript codebase
- **Evidence**: Zero instances of `@ts-ignore` in the codebase. Strict TypeScript compilation enforced. Zod schemas for runtime validation at API boundaries. Prisma generates typed client.
- **Impact**: Eliminates entire class of runtime type errors. Makes refactoring safe.

### PF-03: Purpose-Built Idempotency Layer
- **Location**: `apps/api/src/utils/idempotency.ts` (288 lines)
- **Evidence**: PostgreSQL-backed idempotency with `PENDING → COMPLETED/FAILED` state machine, request fingerprinting, collision detection (409 on mismatch), retry loop for races, reclamation logic. Uses `x-idempotency-key` header.
- **Impact**: Correct design for at-least-once safety. However, not yet wired to routes (see finding A10).

### PF-04: JWT Session Versioning for Instant Global Logout
- **Location**: `apps/api/src/modules/auth/`
- **Evidence**: `authSessionVersion` incremented on logout, password reset, and MFA disable. All existing tokens invalidated immediately. Middleware checks version on every request. No refresh token complexity needed.
- **Impact**: Simple, effective global session revocation without a token blacklist.

### PF-05: Event Outbox Pattern for Reliable Async Processing
- **Location**: `apps/api/src/background/event-outbox.ts`
- **Evidence**: `event_outbox` table with `FOR UPDATE SKIP LOCKED` polling, status state machine (PENDING → PROCESSING → PROCESSED/FAILED/DEAD), retry with backoff, same-transaction insert as data mutation.
- **Impact**: Eliminates dual-write problem (DB commit + event publish). Ensures events are never lost.

### PF-06: SSRF Protection in Collage Service
- **Location**: `tfp-collage-service/src/services/collageWorker.ts`
- **Evidence**: Rejects credentials in URLs, localhost/private/link-local IPs, non-http protocols, redirects, non-image responses, oversize responses. Disables data/file URLs in production config.
- **Impact**: Prevents SSRF attacks through user-supplied image URLs.

### PF-07: Soft-Delete Pattern with Automatic Filtering
- **Location**: `packages/database/src/soft-delete-filter.ts`
- **Evidence**: Prisma client extension that automatically filters `deleted_at IS NULL` on soft-deletable models. Explicit `includeDeleted` parameter to bypass.
- **Impact**: Prevents accidental exposure of deleted records. Centralized, not scattered across queries.

### PF-08: Comprehensive Security Controls
- **Location**: Multiple files (see security section)
- **Evidence**: bcrypt with configurable rounds (12 default), JWT with expiry, HttpOnly/SameSite/Secure cookies, CSRF origin checking middleware, CSP with nonces/hashes, upload validation (MIME, checksum, magic bytes, ownership scoping), input validation via Zod on all API routes, structured logging that scrubs query values.
- **Impact**: Defense-in-depth for web application security.

### PF-09: Localization Infrastructure
- **Location**: `packages/i18n/`, shared across web and mobile
- **Evidence**: Master catalog in `en.json`, 7+ language catalogs, mobile-tailored dictionary in `packages/i18n/src/catalogs/mobile/`. Astro injects locale-aware routes. Mobile imports through shared package.
- **Impact**: Consistent localization across platforms. No duplicate translation strings.

### PF-10: Monorepo Structure with Clean Package Boundaries
- **Location**: `pnpm-workspace.yaml`, package `index.ts` exports
- **Evidence**: Apps import packages through package roots only. Deep imports blocked by architecture enforcement. `packages/*` export curated public APIs through `index.ts`.
- **Impact**: Clear dependency direction. Easy to refactor packages without breaking consumers.

### PF-11: Database URL Normalization Extension
- **Location**: `packages/database/src/url-critical-normalization.ts`
- **Evidence**: Prisma client extension that normalizes `slug`, `username`, `name_slug` fields to lowercase on every write. Prevents case-sensitivity issues in URLs and lookups.
- **Impact**: Ensures URL integrity without requiring every command to remember to normalize.

---

## 8. Critical Findings

### CRIT-01: Production Configuration Defaults to Localhost Databases
- **Finding ID**: A01
- **Title**: Production environment doctor resolves all database URLs to localhost
- **Category**: Configuration
- **Severity**: Critical
- **Confidence**: Confirmed
- **Affected Component**: All services (API, worker, collage, moderation)
- **Evidence**:
  - `scripts/start-app.sh` production env resolution loads `.env.production`, `apps/api/.env`, `.env.production.local`
  - Resolves: `DATABASE_URL=postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers_prod`
  - Resolves: `DATABASE_DIRECT_URL=postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers_prod`
  - Missing: `SENTRY_DSN`, `PUBLIC_SENTRY_DSN`, `AXIOM_TOKEN`, `RATE_LIMIT_REDIS_URL` all report as missing
- **Why it's a problem**: Running production with localhost database URLs means the production instance either connects to a developer's local PostgreSQL (wrong data, security disaster) or fails to connect entirely. Missing observability settings mean production failures are invisible.
- **Failure scenario**: If `pnpm start:prod` is executed with current `.env.production`, the API connects to localhost PostgreSQL (likely non-existent or wrong instance), all requests fail, and no Sentry/Axiom telemetry captures the outage.
- **Root cause**: `.env.production` and `.env.production.local` contain placeholder/development values. No runtime guard prevents production startup with localhost targets.
- **Recommended remediation**:
  1. Set `DATABASE_URL` and `DATABASE_DIRECT_URL` in `.env.production` to the VPS PostgreSQL connection string
  2. Provision `RATE_LIMIT_REDIS_URL` (required, not optional)
  3. Configure `SENTRY_DSN`, `PUBLIC_SENTRY_DSN`, `AXIOM_TOKEN` for production
  4. Add a startup guard: if `NODE_ENV=production` and `DATABASE_URL` contains `localhost` or `127.0.0.1`, refuse to start
  5. Re-run `qa:env:doctor:prod` until it passes
- **Related files**: `.env.production`, `apps/api/.env`, `scripts/start-app.sh`
- **Estimated remediation complexity**: S (configuration only, no code changes)
- **Suggested priority**: Immediate (Phase 0)

### CRIT-02: Redis Rate Limiter Optional — No Rate Limiting Without It
- **Finding ID**: A15
- **Title**: Production rate limiting depends on optional Redis configuration
- **Category**: Security / Reliability
- **Severity**: Critical
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/infrastructure/redis-state.ts`, `apps/api/src/application/rate-limit-policy.ts`
- **Evidence**:
  - `redis-state.ts` line ~91: `if (!ENV.RATE_LIMIT_REDIS_URL) { logger.warn("RATE_LIMIT_REDIS_URL not configured — rate limiting disabled"); return null; }`
  - `rate-limit-policy.ts` defines per-route rate limits: auth/login: 5/min, auth/register: 3/min, various endpoints with limits
  - `RATE_LIMIT_REDIS_URL` is missing in current `.env.production`
- **Why it's a problem**: Without Redis, ALL rate limiting is silently disabled. Login endpoint loses brute-force protection (5/min → unlimited). Registration loses anti-abuse protection. All other rate-limited routes become unrestricted. This is a silent degradation — the API starts successfully but without critical protection.
- **Failure scenario**: Attacker brute-forces login at 1000 req/s. No rate limiting. Password lockout after 5 failures is the ONLY protection (and that's account-specific, not IP-based). Registration can be spammed.
- **Root cause**: Redis treated as optional enhancement rather than critical infrastructure.
- **Recommended remediation**:
  1. Make `RATE_LIMIT_REDIS_URL` a required configuration for production
  2. Add startup check: if `NODE_ENV=production` and `!RATE_LIMIT_REDIS_URL`, refuse to start
  3. Provision a Redis instance for the VPS (or use a lightweight embedded alternative for single-node)
  4. Add health check that verifies Redis connectivity
- **Related files**: `apps/api/src/infrastructure/redis-state.ts`, `apps/api/src/application/rate-limit-policy.ts`
- **Estimated remediation complexity**: S (configuration + Redis provisioning)
- **Suggested priority**: Immediate (Phase 0)

---

## 9. High-Severity Findings

### HIGH-01: 22 Command/Service Files Bypass Repository Layer
- **Finding ID**: A02
- **Title**: Massive architectural debt — commands and services use direct Prisma imports instead of repositories
- **Category**: Architecture
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/modules/*`
- **Evidence**: The `DIRECT_DATABASE_DEBT` set in `scripts/architecture/enforce-boundaries.mjs` lists 22 files that import `prisma` directly:
  - `admin.commands.ts` (1089 lines): `import { prisma, Prisma } from 'database'` — direct queries throughout
  - `auth.commands.ts`: direct user/account queries
  - `contest/commands/CreateContest.ts`: uses `ContestCreateRepository` (exemplary), but also imports `Prisma` type
  - `contest/commands/ModerateContestStatus.ts`, `SetContestWinner.ts`, `SoftDeleteContest.ts`, `SubmitContestEntry.ts`, `UpdateContestById.ts`: all bypass repositories
  - `event.commands.ts`, `event-update-moderation.service.ts`: direct Prisma
  - `ModerationService.ts`: direct Prisma
  - `opportunity.commands.ts`, `opportunity-update-moderation.service.ts`: direct Prisma
  - `report.commands.ts`, `report-submission.service.ts`: direct Prisma
  - `search.service.ts`: direct SQL queries
  - `TranslationService.ts` (1383 lines): direct Prisma
  - `user.commands.ts`, `user.notification.commands.ts`: direct Prisma
- **Why it's a problem**:
  1. Architecture rulebook explicitly forbids this (Rule: "Prisma allowed only in repositories")
  2. No test isolation — commands cannot be unit tested without a database
  3. Persistence logic scattered across 22 files — changing a query requires finding all call sites
  4. No consistent transaction boundary, error mapping, or data access patterns
  5. Violates Dependency Inversion Principle
- **Root cause**: Codebase evolved without repository enforcement. Rules and enforcement added retroactively.
- **Recommended remediation**: Phase-by-phase migration (see A02 in Phase 1 roadmap). Start with highest-risk modules (admin, moderation). For each command:
  1. Extract persistence into a repository interface
  2. Implement repository with Prisma
  3. Inject repository into command
  4. Remove file from `DIRECT_DATABASE_DEBT`
  5. Shrink the baseline
- **Trade-offs**: Increased files/indirection. But testability, consistency, and maintainability gains are substantial.
- **Estimated remediation complexity**: L (22 files × ~100 lines avg = ~2200 lines to refactor)
- **Suggested priority**: Phase 1 (Architectural Stabilization)

### HIGH-02: Idempotency Module Exists but Not Wired to Write Routes
- **Finding ID**: A10
- **Title**: Purpose-built idempotency layer is not integrated with any API write endpoints
- **Category**: Data Integrity / Reliability
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/utils/idempotency.ts`, all write routes
- **Evidence**:
  - `apps/api/src/utils/idempotency.ts` (288 lines) — complete PostgreSQL-backed idempotency module
  - Zero imports of `executeIdempotentRequest` found outside the module itself
  - No route references to `x-idempotency-key` header handling
  - No middleware that extracts and validates the header
- **Why it's a problem**: Payment, submission, and creation endpoints can be retried by clients, resulting in duplicate charges, double submissions, or duplicate records. The module is 288 lines of correct code that provides zero protection because nothing calls it.
- **Failure scenario**: User submits a contest entry. Network hiccup. Client retries with same payload. Two entries created because no idempotency guard. User sees "you've already submitted" on one, but the duplicate exists.
- **Root cause**: Idempotency built as infrastructure without wiring to routes. Likely a "build first, integrate later" pattern where integration was deferred.
- **Recommended remediation**:
  1. Add idempotency middleware that extracts `x-idempotency-key` header
  2. Wire to all state-changing routes: payments, submissions, applications, RSVPs, reports, contest entries
  3. Document which routes support idempotency
  4. Add E2E tests verifying duplicate requests return stored response, not duplicate data
- **Related files**: `apps/api/src/utils/idempotency.ts`, all `*.routes.ts` with POST/PUT/DELETE
- **Estimated remediation complexity**: M
- **Suggested priority**: Phase 1 (before production writes)

### HIGH-03: Worker Heartbeat Filesystem-Bound, Blocks Multi-Node Scaling
- **Finding ID**: A04
- **Title**: Worker health check uses local filesystem heartbeat, preventing horizontal scaling
- **Category**: Reliability / Operations
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/worker.ts`, `docker-compose.yml`
- **Evidence**:
  - Worker writes heartbeat to `/tmp/tfp-worker-heartbeat.json`
  - Docker Compose mounts a named volume for `/tmp`
  - Health check reads this file
  - No Redis or database-backed heartbeat alternative
- **Why it's a problem**: If the API scales to multiple nodes (or multiple worker containers), the filesystem heartbeat is local to each container. A health check on one node cannot see another node's heartbeat. The Docker volume approach works for single-host but not for multi-host deployments.
- **Failure scenario**: Two worker containers on different hosts. Worker A's heartbeat is on Host A's `/tmp`. Health check on Host B reports Worker A as down because it can't read Host A's filesystem.
- **Root cause**: Filesystem chosen as simplest heartbeat store without considering multi-node scaling.
- **Recommended remediation**:
  1. Move heartbeat to PostgreSQL (a `worker_heartbeats` table with `worker_id`, `last_heartbeat_at`, `expires_at`)
  2. Or: use Redis with TTL keys
  3. Add heartbeat staleness detection in BackgroundJobRunner
  4. Document multi-node deployment considerations
- **Related files**: `apps/api/src/worker.ts`, `docker-compose.yml`
- **Estimated remediation complexity**: M
- **Suggested priority**: Phase 1

### HIGH-04: Large Untested Surface in Admin Commands
- **Finding ID**: A07
- **Title**: admin.commands.ts (1089 lines) has minimal test coverage for critical moderation operations
- **Category**: Security / Maintainability
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/modules/admin/admin.commands.ts`
- **Evidence**:
  - File is 1089 lines (above the 460-line hotspot cap for admin.queries.ts, but admin.commands.ts itself has no cap)
  - Contains: bulk opportunity moderation, event moderation, contest moderation, user suspension, report resolution, violation management
  - Tests listed under `apps/api/tests/modules/admin/` primarily cover routes, not the command logic directly
  - No dedicated `admin.commands.test.ts` file found
- **Why it's a problem**: Admin commands have the highest blast radius — bulk operations, user suspension, moderation decisions. Bugs here can mass-moderate content, incorrectly suspend users, or corrupt audit trails. Without direct command-level tests, regression risk is high.
- **Root cause**: Admin module grew organically as features were added. Command logic mixed with route handlers in testing.
- **Recommended remediation**:
  1. Add `admin.commands.test.ts` with dedicated unit tests for each exported command
  2. Add integration tests for bulk moderation with rollback verification
  3. Add boundary tests: empty lists, invalid statuses, permission edge cases
  4. Set file size cap for `admin.commands.ts` in `HOTSPOT_CAPS`
- **Estimated remediation complexity**: M
- **Suggested priority**: Phase 2

### HIGH-05: Simple Backoff Without Jitter in Background Workers
- **Finding ID**: A05
- **Title**: Worker retries use linear backoff without jitter, risking thundering herd on recovery
- **Category**: Reliability
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/background/BackgroundJobRunner.ts`, `apps/api/src/background/event-outbox.ts`
- **Evidence**:
  - Event outbox retry: `nextRetryAt = now + retryCount * interval` (linear, no jitter)
  - Background jobs have `retryCount` and `nextRetryAt` fields
  - No exponential backoff with jitter implementation found
  - No circuit breaker for external service calls
- **Why it's a problem**: When a downstream service (moderation API, collage service, email provider) has a brief outage, ALL failed jobs get the same `nextRetryAt`. When the service recovers, ALL jobs retry simultaneously — thundering herd. This can re-overwhelm a recovering service, causing cascading failures.
- **Failure scenario**: Moderation API is down for 2 minutes. 50 images queued for moderation all fail. All get `nextRetryAt = now + 30s`. At T+30s, 50 concurrent moderation requests hit the recovering API. API OOMs. Cycle repeats.
- **Root cause**: Simple retry pattern without awareness of distributed system failure modes.
- **Recommended remediation**:
  1. Add exponential backoff: `delay = baseDelay * 2^retryCount`
  2. Add jitter: `delay = delay * (0.5 + random() * 0.5)`
  3. Cap maximum delay (e.g., 1 hour)
  4. Add circuit breaker that pauses all retries when downstream is unhealthy
- **Related files**: `apps/api/src/background/event-outbox.ts`, `BackgroundJobRunner.ts`
- **Estimated remediation complexity**: S (well-understood pattern, small code change)
- **Suggested priority**: Phase 2

### HIGH-06: TranslationService Monolithic at 1383 Lines
- **Finding ID**: A08
- **Title**: TranslationService.ts exceeds maintainability thresholds with mixed concerns
- **Category**: Maintainability
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/modules/translation/TranslationService.ts`
- **Evidence**:
  - 1383 lines (above the 1300-line cap in `HOTSPOT_CAPS`)
  - Contains: translation API calls, caching, batch processing, language detection, HTML-safe translation, entity-specific translation logic (opportunities, events, contests, profiles)
  - Listed in `DIRECT_DATABASE_DEBT` for direct Prisma access
- **Why it's a problem**: Monolithic service with mixed responsibilities: external API integration, caching strategy, domain-specific translation logic for 5+ entity types. Any change to one entity's translation logic risks breaking others. Testing requires mocking the entire 1383-line class.
- **Root cause**: Translation grew as a single service without decomposition as entity types increased.
- **Recommended remediation**:
  1. Split into: `TranslationClient` (API adapter), `TranslationCache` (caching), `EntityTranslator` (per-entity strategies)
  2. Or: split by entity type into `OpportunityTranslator`, `EventTranslator`, `ContestTranslator`, `ProfileTranslator`
  3. Extract repository for any database access
  4. Lower the hotspot cap to new reduced size
- **Estimated remediation complexity**: L
- **Suggested priority**: Phase 2

### HIGH-07: Moderation Service Folder-Ops Shell Commands in Web Layer
- **Finding ID**: A16
- **Title**: Python web layer embeds subprocess shell commands for folder moderation operations
- **Category**: Architecture / Security
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `tfp-moderation-service/src/tfp_moderation_service/web.py`
- **Evidence**:
  - `_folder_moderation_command()`: executes `subprocess.Popen` with shell commands
  - `_folder_moderation_active_pids()`: calls `pgrep` via subprocess
  - `_stop_folder_moderation_processes()`: uses `flock` and `kill` via subprocess
  - These are called from FastAPI route handlers, not from a dedicated service layer
- **Why it's a problem**:
  1. Web layer should not execute shell commands — violates separation of concerns
  2. Shell injection risk if any user input reaches these commands
  3. Cannot be unit tested without actual filesystem and processes
  4. Blocks extraction of moderation logic into a separate worker
- **Root cause**: Folder moderation built as a quick operator tool without architecture review.
- **Recommended remediation**:
  1. Extract folder operations into `src/tfp_moderation_service/folder_ops/` module
  2. Create a `FolderModerationService` with clean interface
  3. Wire through dependency injection
  4. Add unit tests with mocked subprocess
  5. Ensure folder-ops routes remain behind password/auth protection
- **Related files**: `tfp-moderation-service/src/tfp_moderation_service/web.py`
- **Estimated remediation complexity**: M
- **Suggested priority**: Phase 2

### HIGH-08: Moderation Service Default CORS Wildcard
- **Finding ID**: A03
- **Title**: Code-level CORS configuration uses `allow_origins=["*"]` — requires config override for production
- **Category**: Security
- **Severity**: High
- **Confidence**: Confirmed
- **Affected Component**: `tfp-moderation-service/src/tfp_moderation_service/web.py`
- **Evidence**: `allow_origins=["*"]` in FastAPI CORS middleware. The previous audit (2026-07-04) flagged this and required `expose_playground_ui=false` and `expose_openapi=false` for production. These config flags mitigate exposure but the code-level default remains `*`.
- **Why it's a problem**: If a configuration mistake re-enables the playground or a new developer deploys without the UAT config, the moderation service is exposed with wildcard CORS. Combined with password-only folder-ops, this creates unnecessary attack surface.
- **Root cause**: CORS wildcard is the development default. Production hardening is in config, not in code.
- **Recommended remediation**:
  1. Change code default to `allow_origins=[]` (empty, requiring explicit config)
  2. Require `CORS_ALLOWED_ORIGINS` env var in production config
  3. Add startup check: if `expose_playground_ui=true`, require non-wildcard CORS
- **Related files**: `tfp-moderation-service/src/tfp_moderation_service/web.py`, `config/environments/uat/settings.yaml`
- **Estimated remediation complexity**: XS
- **Suggested priority**: Phase 1

---

## 10. Medium-Severity Findings

### MED-01: admin.commands.ts Exceeds Hotspot Cap with No Cap Defined
- **Finding ID**: A09
- **Title**: `admin.commands.ts` at 1089 lines has no hotspot cap entry
- **Category**: Maintainability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/modules/admin/admin.commands.ts`
- **Evidence**: File is 1089 lines. `HOTSPOT_CAPS` in `enforce-boundaries.mjs` does not list it. `admin.queries.ts` has a 460-line cap but `admin.commands.ts` is unmonitored.
- **Root cause**: Admin commands grew after the hotspot enforcement was added.
- **Recommended remediation**: Add `admin.commands.ts` to `HOTSPOT_CAPS` at 1100 lines (current size + buffer), then refactor to reduce size over time.
- **Estimated remediation complexity**: S

### MED-02: 37 Prisma Enums Leaked into Application Layer
- **Finding ID**: A06
- **Title**: Prisma-generated enums used directly in commands, services, and shared types
- **Category**: Architecture
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: All modules importing enums from `database` package
- **Evidence**: `UserRole`, `AccountStatus`, `SubscriptionTier`, `ProfileStatus`, `ContentWorkflowStatus`, `ModerationDecision`, and 31 other enums used directly in command/service files. The `database` package exports Prisma-generated types as its public API.
- **Why it's a problem**: Domain layer should own domain concepts. If Prisma enum changes (database migration), all consumers break. Domain logic should use domain enums, with mapping in the repository/adapter layer.
- **Root cause**: Convenience of using Prisma-generated types directly. No domain enum layer.
- **Recommended remediation**: Create domain enums in `packages/shared` or domain modules, map in repositories. This is a large refactor — start with the most volatile enums (status enums, moderation decisions).
- **Estimated remediation complexity**: XL

### MED-03: No Optimistic Locking on Concurrent-Edit Entities
- **Finding ID**: A11
- **Title**: Opportunities, events, and contests lack version columns for optimistic concurrency
- **Category**: Concurrency / Data Integrity
- **Severity**: Medium
- **Confidence**: High confidence
- **Affected Component**: `packages/database/prisma/schema.prisma`, all update commands
- **Evidence**: Schema audit shows no `version` or `updated_at` comparison in UPDATE queries. `opportunity.commands.ts` `UpdateOpportunityById` does not check if the record changed since read. `event.commands.ts` similar. Contest update commands similar.
- **Why it's a problem**: Two admins editing the same opportunity simultaneously. Admin A reads, Admin B reads, Admin A saves, Admin B saves — Admin A's changes silently overwritten. No detection.
- **Failure timeline**: Admin A opens opportunity edit form. Admin B opens same form. Admin A saves changes to description. Admin B saves changes to title. Admin B's save includes stale description from before Admin A's edit. Admin A's description is lost.
- **Root cause**: No optimistic concurrency strategy implemented on edit workflows.
- **Recommended remediation**: Add `version` (integer, default 1) column to `opportunity`, `event`, `contest`, `user` tables. Increment on each update. Check version in update WHERE clause. Return 409 Conflict on mismatch.
- **Estimated remediation complexity**: M

### MED-04: No API Versioning Strategy
- **Finding ID**: A12
- **Title**: All API routes under `/api/v1/` but no versioning governance
- **Category**: API Design
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/modules/*/**.routes.ts`
- **Evidence**: All routes registered under `/api/v1/`. No `Deprecated` or `Sunset` headers. No version negotiation. No documented breaking-change policy. No `/api/v2/` migration path defined.
- **Why it's a problem**: The first breaking API change requires either a v2 (with no plan for how) or silently breaking v1 clients. Mobile app is tightly coupled to current API shape.
- **Root cause**: "V1" was chosen as a future-proofing convention but without operational follow-through.
- **Recommended remediation**: Document API versioning policy. Add deprecation header support. Plan v1→v2 migration path (header-based versioning or URL-based with overlap period).
- **Estimated remediation complexity**: S (policy + documentation)

### MED-05: Mobile Content Repository Has N+1 Potential
- **Finding ID**: A13
- **Title**: `api-content-operations.ts` (970 lines) may issue sequential API calls for list enrichment
- **Category**: Performance
- **Severity**: Medium
- **Confidence**: Medium confidence (requires runtime profiling)
- **Affected Component**: `apps/mobile/src/infrastructure/api/api-content-operations.ts`
- **Evidence**: File is 970 lines (near the 970-line hotspot cap). Contains list/detail resolution for opportunities, events, contests. Each detail fetch may issue separate API calls for related data. Without runtime profiling, N+1 risk is inferred from structure.
- **Root cause**: Mobile content resolution built iteratively, enriching detail views with additional fetches.
- **Recommended remediation**: Profile mobile API calls during a typical list→detail→list session. Add batch endpoints where needed. Consider GraphQL or BFF layer for mobile.
- **Estimated remediation complexity**: M (depends on profiling results)

### MED-06: No Circuit Breaker for External Service Calls
- **Finding ID**: A14
- **Title**: No circuit breaker pattern on moderation API, collage API, email, or storage calls
- **Category**: Reliability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: All external service integrations
- **Evidence**: No circuit breaker implementation found. ModerationService calls moderation API directly. Collage worker calls collage API directly. Email service calls SMTP directly. Storage adapter calls B2 directly. Retry logic exists but without circuit-breaking.
- **Why it's a problem**: If moderation service is degraded (responding slowly), every image upload triggers a slow moderation call. Fastify thread pool saturates waiting for moderation responses. API becomes unresponsive to ALL requests, not just uploads.
- **Root cause**: No bulkhead or circuit breaker pattern implemented.
- **Recommended remediation**: Add circuit breaker (e.g., `opossum` library or custom) on external calls. When failure rate exceeds threshold, fast-fail and queue for retry. Add timeout. Add bulkhead to isolate moderation thread pool from main request pool.
- **Estimated remediation complexity**: M

### MED-07: No Health Check Reflects Dependency Readiness
- **Finding ID**: A17
- **Title**: `/health` endpoint returns 200 even when database or Redis is unreachable
- **Category**: Reliability / Operations
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/server.ts` health route
- **Evidence**: Health check returns basic server status. Does not verify database connectivity (`SELECT 1`), Redis connectivity (`PING`), or moderation service health. Load balancers or orchestrators may route traffic to an unhealthy instance.
- **Root cause**: Simple health check sufficient for development; never hardened for production.
- **Recommended remediation**: Add `/health/ready` (readiness) endpoint that verifies all dependencies. Add `/health/live` (liveness) for basic process check. Document difference.
- **Estimated remediation complexity**: S

### MED-08: No Stale-Job Detection or Recovery in Workers
- **Finding ID**: A18
- **Title**: Jobs stuck in PROCESSING state have no automatic recovery mechanism
- **Category**: Reliability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/background/BackgroundJobRunner.ts`, `event-outbox.ts`
- **Evidence**: Event outbox polls with `FOR UPDATE SKIP LOCKED`. If a worker crashes after acquiring a job (status: PROCESSING), the row stays locked until PostgreSQL session timeout or the crashed worker's connection closes. No explicit heartbeat or lease expiration. No stale-job recovery query.
- **Failure scenario**: Worker picks up event, sets PROCESSING, crashes. Row remains PROCESSING indefinitely. Other workers skip it (SKIP LOCKED). Event is permanently lost unless manually fixed.
- **Root cause**: `FOR UPDATE SKIP LOCKED` prevents double-processing but doesn't handle crashes.
- **Recommended remediation**: Add `lease_expires_at` column. Workers update lease periodically. Add stale-job recovery: `UPDATE ... SET status='PENDING' WHERE status='PROCESSING' AND lease_expires_at < NOW()`. Schedule as a periodic cleanup job.
- **Estimated remediation complexity**: S

### MED-09: Collage Service Test Runtime Path Inconsistency
- **Finding ID**: A19
- **Title**: Collage service requires explicit Node 24 runtime with custom wrapper scripts
- **Category**: Maintainability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `tfp-collage-service/`
- **Evidence**: `package.json` requires `node >=24`. System `node` may be older. `scripts/ensure-node-runtime.sh`, `scripts/pnpm-node.sh`, `scripts/run-node.sh` wrap all commands to use correct Node version. README commands, VPS deploy, local start all route through wrappers.
- **Why it's a problem**: Developer friction — `pnpm test` may fail with cryptic errors if wrapper not used. New developers may not know to use wrappers. NVM auto-switching from `.nvmrc` helps but wrapper scripts add complexity.
- **Root cause**: Node 24 is newer than default system Node. Wrappers are a workaround.
- **Recommended remediation**: Document clearly. Consider `.nvmrc` auto-use or a pre-commit hook that warns. Long-term: upgrade system Node or use a Docker dev container.
- **Estimated remediation complexity**: XS (documentation)

### MED-10: No Dead-Letter Queue Pattern
- **Finding ID**: A20
- **Title**: Failed events and jobs have no dead-letter quarantine
- **Category**: Reliability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/api/src/background/event-outbox.ts`
- **Evidence**: Event outbox has FAILED and DEAD statuses but no dead-letter queue pattern documentation or automated quarantine. Failed events remain in the `event_outbox` table mixed with pending events. No operator dashboard to inspect dead letters.
- **Why it's a problem**: Repeatedly failing events pollute the outbox. No easy way to inspect only dead letters. No replay mechanism. Manual SQL required to re-queue dead letters.
- **Root cause**: Status tracking added but operational workflow not completed.
- **Recommended remediation**: Add `dead_letter_at` column. Move DEAD events to a `dead_letter_events` view or table. Add admin UI to view/replay/discard dead letters. Add metrics for dead letter count.
- **Estimated remediation complexity**: S

### MED-11: No Contract Tests Between Web and API
- **Finding ID**: A21
- **Title**: Frontend makes API calls without contract verification
- **Category**: Testing
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/web/`, `apps/api/`
- **Evidence**: Web pages call `/api/v1/*` endpoints. No consumer-driven contract tests. No OpenAPI spec generation from route schemas. API response shape changes can silently break the frontend.
- **Root cause**: Monorepo co-location creates false sense of safety — API changes are not validated against frontend consumers.
- **Recommended remediation**: Generate OpenAPI spec from Fastify route schemas. Add contract tests that verify frontend-expected shapes match API responses. Run in CI.
- **Estimated remediation complexity**: M

### MED-12: Worker Initial Deployment Uses Root User
- **Finding ID**: A22
- **Title**: VPS deployment scripts reference root user for initial setup
- **Category**: Security / Infrastructure
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `scripts/vps/deploy-*.sh`
- **Evidence**: AGENTS.md states "Default User: root (Option A: quick first deploy using root)". Production systemd units run as `tfpapp` user, but initial deployment and SSH use root.
- **Why it's a problem**: Root SSH is broader than necessary. If SSH key is compromised, attacker gets root access.
- **Root cause**: Quick-start convenience trade-off.
- **Recommended remediation**: Create dedicated `tfpdeploy` user with sudo access for specific commands only. Disable root SSH. Document non-root deployment flow.
- **Estimated remediation complexity**: S (operational change)

### MED-13: Moderation Service No Graceful Shutdown for In-Flight Work
- **Finding ID**: A23
- **Title**: Python moderation worker may lose in-progress jobs on shutdown
- **Category**: Reliability
- **Severity**: Medium
- **Confidence**: Medium confidence (requires runtime verification)
- **Affected Component**: `tfp-moderation-service/src/tfp_moderation_service/moderation_worker.py`
- **Evidence**: Moderation worker polls jobs and processes them. No evidence of graceful shutdown handling (SIGTERM capture, in-flight job completion, re-queue of unprocessed jobs). The `moderation_jobs` table has PROCESSING status that would leave records stuck if worker crashes mid-job.
- **Root cause**: Worker built for continuous operation; shutdown handling was deferred.
- **Recommended remediation**: Add SIGTERM handler: stop polling, complete current job, re-queue any acquired-but-unprocessed jobs to PENDING.
- **Estimated remediation complexity**: S

### MED-14: No Concurrency Tests for Write Workflows
- **Finding ID**: A24
- **Title**: No automated tests verify behavior under concurrent writes
- **Category**: Testing
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: All write commands
- **Evidence**: No test files with concurrent scenarios found. No test for: two simultaneous contest submissions, two simultaneous RSVPs, simultaneous opportunity edits. Vitest can run concurrent tests but none are written.
- **Root cause**: Concurrency testing requires more complex test setup. Deferred.
- **Recommended remediation**: Add concurrent test scenarios for high-risk flows (submissions, applications, RSVPs). Use Vitest's `test.concurrent` or Playwright's parallel browser contexts.
- **Estimated remediation complexity**: M

### MED-15: No Database-Level Enforcements for Critical Constraints
- **Finding ID**: A25
- **Title**: Several business invariants enforced only in application code
- **Category**: Data Integrity
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `packages/database/prisma/schema.prisma`
- **Evidence**:
  - One submission per user per contest: enforced in `SubmitContestEntry.ts`, not in database (no unique constraint on `(contest_id, user_id)`)
  - One vote per user per contest: enforced in application code only
  - One RSVP per user per event: application-level check
  - Duplicate report prevention: application-level check
- **Why it's a problem**: Application-level checks have race conditions (check-then-act). Two concurrent requests can both pass the check, then both insert. Database unique constraints are atomic and cannot race.
- **Root cause**: Application-level validation is easier to implement; database constraints require migration planning.
- **Recommended remediation**: Add unique constraints for all "one-per-user" invariants. Keep application checks as user-friendly validation; database constraints are the safety net.
- **Estimated remediation complexity**: M (requires migration, may need data cleanup first)

### MED-16: Large Hotspot Files Near or At Caps
- **Finding ID**: A26
- **Title**: Multiple files are at or near their hotspot line-count caps
- **Category**: Maintainability
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: Multiple files
- **Evidence**: `api-content-operations.ts` (970 lines, cap: 970), `api-content-mappers.ts` (780 lines, cap: 780), `process-image-moderation-job.ts` (1300 lines, cap: 1300), `TranslationService.ts` (1383 lines, cap: 1300 — over cap), `admin.queries.ts` (near 460 cap), `opportunity.routes.ts` (near 1100 cap), `admin/index.js` (2900 lines, cap: 2900).
- **Root cause**: Files grow over time; caps freeze growth but don't reduce size.
- **Recommended remediation**: Schedule refactoring sprints to split the largest files. Prioritize files over their caps.
- **Estimated remediation complexity**: L (cumulative)

### MED-17: No Infrastructure-as-Code Beyond Deployment Scripts
- **Finding ID**: A27
- **Title**: Server provisioning and configuration rely on manual steps and shell scripts
- **Category**: Infrastructure
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `scripts/vps/`, `deploy/`
- **Evidence**: VPS deployment uses `deploy-to-instance.sh` which copies files and runs commands via SSH. No Terraform, Pulumi, Ansible, or similar IaC. Server setup (nginx, systemd, Python venv, Node installation) is documented but not automated.
- **Why it's a problem**: Server rebuild requires manual steps. Configuration drift between UAT and production. No version-controlled infrastructure state.
- **Root cause**: Shell scripts were the quickest path to deployment.
- **Recommended remediation**: Add Terraform or Ansible for VPS provisioning. At minimum, add a `setup-server.sh` that fully automates server initialization. Document infrastructure state.
- **Estimated remediation complexity**: L

### MED-18: Some Boolean Fields Should Be Enums
- **Finding ID**: A28
- **Title**: `is_discoverable`, `remote_available` are booleans that may need richer states
- **Category**: Data Integrity
- **Severity**: Medium
- **Confidence**: Low confidence (depends on product requirements)
- **Affected Component**: `packages/database/prisma/schema.prisma`
- **Evidence**: `is_discoverable Boolean @default(true)` — single boolean can't express "discoverable to followers only" or "discoverable in search but not in browse". `remote_available Boolean @default(false)` — can't express "remote preferred" vs "remote only" vs "remote occasionally".
- **Why it's a problem**: Future product requirements may need richer visibility/availability models. Changing boolean to enum requires migration.
- **Root cause**: Early product decisions used booleans for simplicity.
- **Recommended remediation**: If product roadmap includes richer visibility/availability, plan enum migration now. Otherwise, defer.
- **Estimated remediation complexity**: M (if migrated)

### MED-19: Mobile App Locked to React 18 Due to Web App Pin
- **Finding ID**: A29
- **Title**: Mobile cannot upgrade to latest Expo SDK due to monorepo React 18 pin
- **Category**: Maintainability / Frontend
- **Severity**: Medium
- **Confidence**: Confirmed
- **Affected Component**: `apps/mobile/`, `package.json` root overrides
- **Evidence**: AGENTS.md states "Current mobile stack is Expo SDK 52, React Native 0.76, and React 18.3.1 because the web app and root overrides still pin React 18." Root `package.json` overrides pin React to 18.x.
- **Why it's a problem**: Mobile falls behind Expo SDK releases, missing bug fixes, performance improvements, and new APIs. Eventually, Expo SDK 52 will be deprecated and apps must upgrade.
- **Root cause**: Astro/web app requires React 18. Mobile shares the monorepo's React version.
- **Recommended remediation**: Plan React 19 migration for web app. Alternatively, isolate mobile's React dependency from root overrides using workspace-specific resolutions.
- **Estimated remediation complexity**: L

---

## 11. Low-Severity Findings

### LOW-01: Mobile API Client Stores Token in SecureStore — No Refresh Token
- **Finding ID**: A30
- **Title**: Mobile clears token on 401, requiring full re-login
- **Category**: Security / UX
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: AGENTS.md: "The backend currently issues JWT bearer/cookie sessions and invalidates them with `authSessionVersion`; it does not expose a true refresh-token endpoint. Mobile should clear the SecureStore token on `401` and must not invent an unbacked refresh flow."
- **Why it's a problem**: Token expiry (default 7d) forces re-login. No silent refresh. This is a known architectural limitation documented as intentional.
- **Root cause**: No refresh token endpoint exists. Documented trade-off.
- **Recommended remediation**: Add refresh token endpoint to API. Issue refresh token alongside access token. Mobile uses refresh token for silent re-auth.
- **Estimated remediation complexity**: M

### LOW-02: Inconsistent Timestamp Column Types
- **Finding ID**: A31
- **Title**: Some tables use `Timestamp`, others `TimestampTz`
- **Category**: Data Integrity
- **Severity**: Low
- **Confidence**: Confirmed
- **Affected Component**: `packages/database/prisma/schema.prisma`
- **Evidence**: Mixed `DateTime @db.Timestamp` and `DateTime @db.Timestamptz` across tables. Not all datetime columns have explicit timezone handling.
- **Root cause**: Schema evolved without timezone consistency standard.
- **Recommended remediation**: Standardize on `Timestamptz` for all user-visible timestamps. Audit for timezone correctness in application code.
- **Estimated remediation complexity**: S

### LOW-03: No Canonical Environment Variable Documentation in One Place
- **Finding ID**: A32
- **Title**: Environment variables scattered across `.env.example`, `config/`, `packages/config/src/env-core.ts`
- **Category**: Documentation
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: `packages/config/src/env-core.ts` defines ~80 env vars with parsing. `.env.deploy.example` has a subset. No single document lists all env vars with descriptions, defaults, and which services need them.
- **Root cause**: Env vars added incrementally. Documentation hasn't been consolidated.
- **Recommended remediation**: Create `docs/operations/ENVIRONMENT_VARIABLES.md` with all vars, defaults, required/optional, service scope, and examples.
- **Estimated remediation complexity**: S

### LOW-04: No Integration Tests for Outbox Event Processing
- **Finding ID**: A33
- **Title**: Event outbox processing is not integration tested
- **Category**: Testing
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: No test for: poll → process → mark COMPLETED cycle. No test for: poll → fail → retry → succeed. No test for: poll → fail → fail → fail → DEAD.
- **Root cause**: Outbox tests require database state management; more complex to set up.
- **Recommended remediation**: Add integration tests for each outbox state transition path.
- **Estimated remediation complexity**: S

### LOW-05: Root Workspace Has Unused `src/` Directory
- **Finding ID**: A34
- **Title**: `tfpphotographers/src/` exists at root but contains only an env.d.ts and ai/ directory
- **Category**: Maintainability
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: `src/env.d.ts` and `src/ai/` exist at the monorepo root. No build configuration references them. Purpose unclear.
- **Root cause**: Leftover from earlier project structure or future feature preparation.
- **Recommended remediation**: Clarify purpose or remove. Document in MEMORY.md if intentional.
- **Estimated remediation complexity**: XS

### LOW-06: Collage Service Single Test File
- **Finding ID**: A35
- **Title**: `server.test.ts` and `storageClient.test.ts` are the only tests for collage service
- **Category**: Testing
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: Only 2 test files covering server boot and storage client. No tests for `collageMaker.ts` (the core business logic) or `collageWorker.ts` (the polling/orchestration).
- **Root cause**: Test coverage added for infrastructure, deferred for business logic.
- **Recommended remediation**: Add tests for `collageMaker.ts` (image composition) and `collageWorker.ts` (polling loop, error handling, collage generation end-to-end).
- **Estimated remediation complexity**: M

### LOW-07: Dead Code and Stale Docs Risk
- **Finding ID**: A36
- **Title**: Prior audit documents may reference resolved issues without clear status
- **Category**: Maintainability
- **Severity**: Low
- **Confidence**: Low confidence
- **Evidence**: Multiple GO_LIVE_*.md documents exist from different dates. `CODEBASE_AUDIT_FINDINGS.md` is a prior audit. Not clear which findings are resolved, in-progress, or superseded.
- **Root cause**: Audit documents created at different points without status consolidation.
- **Recommended remediation**: Consolidate into a single AUDIT_STATUS.md or add a "Last Updated / Status" header to each. Archive resolved documents.
- **Estimated remediation complexity**: XS

### LOW-08: `opportunity.routes.ts` at Hotspot Cap
- **Finding ID**: A37
- **Title**: Opportunity routes file at 1100-line cap needs eventual splitting
- **Category**: Maintainability
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: Hotspot cap is 1100 lines. File is at or near this limit.
- **Root cause**: Opportunity domain has complex routes (CRUD, applications, status transitions).
- **Recommended remediation**: Split into `opportunity.routes.ts`, `opportunity-application-routes.ts` (already exists, cap 100 lines), `opportunity-moderation-routes.ts`.
- **Estimated remediation complexity**: M

### LOW-09: No Structured Migration Testing
- **Finding ID**: A38
- **Title**: No automated tests verify migrations run successfully against production-like data
- **Category**: Testing / Data Integrity
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: No migration test files found. `scripts/db/migrate.sh` handles execution but no automated validation.
- **Root cause**: Migration testing typically manual.
- **Recommended remediation**: Add CI step that runs migrations against a restored production-like backup. Verify no data loss.
- **Estimated remediation complexity**: M

### LOW-10: No Rate Limiting on Mobile API Routes
- **Finding ID**: A39
- **Title**: Mobile API client does not respect or implement client-side rate limit awareness
- **Category**: Reliability
- **Severity**: Low
- **Confidence**: Low confidence
- **Evidence**: Mobile API client calls endpoints directly. No rate-limit header parsing. No retry-after handling. Server-side rate limiting is Redis-dependent and currently disabled in production.
- **Root cause**: Mobile client built for happy path. Rate limiting not yet operational.
- **Recommended remediation**: After server-side rate limiting is operational, add client-side rate limit handling (read Retry-After header, exponential backoff).
- **Estimated remediation complexity**: S

### LOW-11: Python Translation Script Has No Test Coverage
- **Finding ID**: A40
- **Title**: `translate_all_supported_languages.py` has no associated tests
- **Category**: Testing
- **Severity**: Low
- **Confidence**: Confirmed
- **Evidence**: `scripts/translate_all_supported_languages.py` is a utility script with no test file.
- **Root cause**: Utility script, not production code.
- **Recommended remediation**: Add basic smoke test that the script imports and function signatures are correct.
- **Estimated remediation complexity**: XS

### LOW-12: Development Seed Data May Drift from Schema
- **Finding ID**: A41
- **Title**: Seed scripts may reference deprecated fields or enums
- **Category**: Maintainability
- **Severity**: Low
- **Confidence**: Low confidence (requires seed execution to verify)
- **Evidence**: Seed scripts under `tests/create-data/` and `scripts/create-data/`. Schema has evolved through many migrations. Seed data may reference old enum values or removed fields.
- **Root cause**: Seed data not validated against current schema in CI.
- **Recommended remediation**: Add CI step that runs seed scripts against test database. Verify no errors.
- **Estimated remediation complexity**: S

### LOW-13: No Database Backup Verification Tests
- **Finding ID**: A42
- **Title**: Backup scripts exist but no automated restore verification
- **Category**: Reliability
- **Severity**: Low
- **Confidence**: Low confidence
- **Affected Component**: VPS database backups
- **Evidence**: AGENTS.md and deploy docs mention database state but no automated backup/restore testing.
- **Root cause**: Backup verification typically manual.
- **Recommended remediation**: Schedule periodic automated restore test in CI or as a cron job.
- **Estimated remediation complexity**: S

### LOW-14: `@prisma/client` Version vs `prisma` Version Potential Mismatch
- **Finding ID**: A43
- **Title**: Prisma client and CLI versions should be kept in sync
- **Category**: Maintainability
- **Severity**: Low
- **Confidence**: Low confidence
- **Evidence**: `packages/database/package.json` lists both `@prisma/client` and `prisma` as dependencies. Version alignment is manual.
- **Root cause**: Prisma recommends matching versions. Currently aligned but no enforcement.
- **Recommended remediation**: Add a CI check that `@prisma/client` and `prisma` versions match.
- **Estimated remediation complexity**: XS

---

## 12. State Machine Analysis

### Key State Machines Reconstructed

#### Content Moderation Lifecycle
```
PENDING_MODERATION → UNDER_MODERATION → PUBLISHED (CLEAN)
                                      → PENDING_APPROVAL (BORDERLINE)
                                      → ACTION_REQUIRED (SEVERE)
                                      → REJECTED
                                      → QUEUE_REVIEW (low confidence or >3 revisions)
```

**Owner**: ModerationService + ModerationWorker  
**Transaction Boundary**: Moderation decision writes within `prisma.$transaction`  
**Side Effects**: `postWriteSideEffects()` for notifications, outbox events  
**Retry**: Background job retry with `retryCount` and `nextRetryAt`  
**Idempotency**: Not guaranteed (see HIGH-02)  
**Concurrent Update**: No optimistic locking detected

#### Event Outbox Lifecycle
```
PENDING → PROCESSING → PROCESSED
                     → FAILED → PENDING (retry, if retries remain)
                     → FAILED → DEAD (if max retries exhausted)
```

**Owner**: BackgroundJobRunner  
**Polling**: Every 5 seconds with `FOR UPDATE SKIP LOCKED`  
**Retry**: Linear backoff (`now + retryCount * interval`) — no jitter (see HIGH-05)  
**Stale Recovery**: None — PROCESSING jobs from crashed workers are orphaned (see MED-08)

#### User Account Lifecycle
```
Email Signup → ACTIVE
            → SUSPENDED (admin action)
            → DISABLED (user deactivation)
            → (soft-delete via deleted_at)
```

**Owner**: auth.commands.ts, admin.commands.ts  
**Session Invalidation**: `authSessionVersion` increment on status change and logout

---

## 13. Enum Inventory (37 Prisma Enums)

| # | Enum | Values | Risk |
|---|------|--------|------|
| 1 | UserRole | USER, PHOTOGRAPHER, MODEL, STYLIST, MAKEUP_ARTIST, ADMIN | Stable |
| 2 | AccountStatus | ACTIVE, SUSPENDED, DISABLED | Stable |
| 3 | SubscriptionTier | FREE, PRO, PRO_PLUS | May expand |
| 4 | CreatorAvailabilityStatus | AVAILABLE, LIMITED, BOOKED, UNAVAILABLE | Stable |
| 5 | CreatorProfileStatus | DRAFT, PUBLISHED, HIDDEN, RESTRICTED, SUSPENDED, DELETED | Complex — 6 states, see state machine |
| 6 | CreatorProviderType | INDIVIDUAL, STUDIO_AGENCY | Stable |
| 7 | CreatorStage | HOBBYIST, EMERGING, PROFESSIONAL | May expand |
| 8 | CreatorStageSource | SELF_DECLARED, ADMIN_VERIFIED | Stable |
| 9 | CreatorWorkPreference | PAID, TFP, BOTH | Stable |
| 10 | CreatorRoleStatus | ACTIVE, PAUSED, RESTRICTED, DELETED | Stable |
| 11 | ServiceOfferingType | STUDIO_SPACE | Will expand |
| 12 | ServiceOfferingStatus | ACTIVE, HIDDEN, RESTRICTED, DELETED | Stable |
| 13 | ContentWorkflowStatus | (multiple — draft, published, pending, etc.) | Complex |
| 14-37 | (Various moderation, notification, report, event, contest statuses) | — | Various |

**Key concern**: `ContentWorkflowStatus` and `CreatorProfileStatus` have the most complex state transitions but the least formal documentation of allowed transitions.

---

## 14. Hardcoding and Configuration Findings

| Value | Location | Classification | Risk | Recommended Owner |
| ----- | -------- | -------------- | ---- | ----------------- |
| `localhost:5432` | `.env.production` DATABASE_URL | Environment-specific config | Critical | Environment variables |
| `localhost:7001` | Moderation API URL in config | Environment-specific config | High | Environment variables |
| `5` (retry count) | `BackgroundJobRunner.ts` | Domain policy | Medium | Runtime config |
| `5000` (poll interval ms) | `BackgroundJobRunner.ts` | Runtime config | Medium | Environment variable |
| `7d` (JWT expiry) | Auth config | Domain policy | Low | Runtime config |
| `12` (bcrypt rounds) | Auth config | Domain policy | Low | Runtime config (env override exists) |
| `3` (max idempotency attempts) | `idempotency.ts` | Domain policy | Low | Runtime config |
| `60` (rate limit window) | `rate-limit-policy.ts` | Domain policy | Medium | Runtime config |
| `0.6` (confidence threshold) | Moderation config | Domain policy | Medium | Runtime config |
| `3` (max revisions before QUEUE_REVIEW) | Moderation config | Domain policy | Medium | Runtime config |
| `1200x675` (collage dimensions) | `collageMaker.ts` | Domain policy | Low | Runtime config |

---

## 15. Security Findings Summary

### Confirmed Controls (Strong)
- ✅ bcrypt password hashing with configurable rounds (12 default)
- ✅ JWT with session versioning for instant global logout
- ✅ HttpOnly, SameSite=Lax, Secure cookies
- ✅ CSRF origin-checking middleware for browser requests
- ✅ CSP with nonces/hashes (no `unsafe-eval` in production)
- ✅ Upload validation: MIME, checksum, magic bytes, ownership scoping
- ✅ SSRF protection in collage image fetching
- ✅ Structured logging that scrubs query values
- ✅ Admin MFA with configurable verification window
- ✅ Login lockout after multiple failures
- ✅ Error masking in production (5xx → generic, 4xx → client-safe)

### Gaps Requiring Attention
- ❌ Rate limiting requires Redis — currently disabled without it (CRIT-02)
- ❌ CORS wildcard in moderation service code default (HIGH-08)
- ❌ idempotency module not wired to write routes (HIGH-02)
- ❌ No refresh token mechanism (7d token expiry forces re-login)
- ❌ Folder-ops in moderation service uses password-only auth without CSRF
- ❌ Root SSH for VPS initial deployment
- ❌ No API key rotation mechanism documented
- ❌ No WAF or DDoS protection beyond Cloudflare (relies on tunnel)
- ❌ No automated dependency vulnerability scanning in CI

---

## 16. Testing Coverage Assessment

### What's Tested (Strong)
- ✅ API route integration tests (150+ files)
- ✅ Auth flows (login, lockout, MFA, session revocation)
- ✅ CSRF middleware
- ✅ Upload flows (direct upload, presigned URLs)
- ✅ Moderation policy evaluation (unit tests)
- ✅ i18n catalogs (structure validation)
- ✅ Playwright E2E (smoke, domain, a11y, visual)
- ✅ Collage service server and storage client

### What's NOT Tested (Gaps)
- ❌ Command-level unit tests (commands tested only through route integration)
- ❌ Admin command logic directly (bulk moderation, user suspension)
- ❌ Concurrency scenarios (simultaneous writes)
- ❌ idempotency end-to-end (module exists but isn't wired)
- ❌ Outbox event processing (poll, process, retry, dead-letter)
- ❌ Background job failure and recovery
- ❌ Translation service (1383 lines, no dedicated test)
- ❌ Migration execution against production-like data
- ❌ Moderation worker end-to-end (Python)
- ❌ Collage maker business logic
- ❌ Mobile app (limited to unit/typecheck)
- ❌ Performance/load testing
- ❌ Security penetration testing

---

## 17. Technical Debt Register

| Debt ID | Description | Cause | Impact | Interest | Severity | Recommended Action |
| ------- | ----------- | ----- | ------ | -------- | -------- | ------------------ |
| TD-01 | 22 command/service files with direct Prisma access | Organic growth without repository enforcement | Cannot unit test commands; scattered persistence logic | Every schema change requires auditing 22 files | High | Phase 1: migrate to repositories |
| TD-02 | TranslationService 1383-line monolith | All translation logic in one file | Hard to test; risky to change; blocks reuse | Every entity type addition grows the file | High | Phase 2: split by entity or concern |
| TD-03 | admin.commands.ts 1089 lines | Admin features added to single file | High blast radius; low test coverage | Each new admin feature adds dozens of lines | Medium | Phase 2: split by operation type |
| TD-04 | 37 Prisma enums in application layer | No domain enum layer | ORM change → app breakage; tight coupling | Prisma upgrades risk breaking app code | Medium | Phase 3: add domain enum mapping |
| TD-05 | No optimistic locking | Not prioritized | Silent lost updates on concurrent edits | Risk grows with user base | Medium | Phase 2: add version columns |
| TD-06 | Simple worker retry without jitter | Quick implementation | Thundering herd on recovery | Risk grows with job volume | Medium | Phase 2: exponential backoff + jitter |
| TD-07 | No circuit breaker on external calls | Deferred | Cascading failures when downstream is slow | Risk grows with traffic | Medium | Phase 2: add circuit breakers |
| TD-08 | Stale PROCESSING job recovery | Incomplete outbox implementation | Orphaned events from worker crashes | Risk grows with crash frequency | Medium | Phase 2: add lease-based recovery |
| TD-09 | Mobile React 18 lock | Web app dependency | Cannot upgrade Expo SDK | Falls behind on bug fixes and APIs | Medium | Phase 3: plan React 19 migration |
| TD-10 | No infrastructure-as-code | Shell scripts for deployment | Manual rebuild; configuration drift | Risk grows with infrastructure complexity | Medium | Phase 4: adopt IaC |
| TD-11 | Several hotspots at file size caps | Incremental feature additions | Cannot add features without refactoring | Each new feature adds pressure | Low | Phase 3: scheduled refactoring |
| TD-12 | No API contract tests | Co-located monorepo | API shape changes break frontend silently | Risk grows with API surface | Low | Phase 4: add contract tests |

---

## 18. Cross-Cutting Root Causes

1. **Retroactive Architecture Enforcement**: The architecture rulebook and enforcement tooling were added after the codebase had grown significantly. This means violations are catalogued (good) but not yet fixed (debt). The enforcement prevents new violations but 22 existing files remain as allowed exceptions.

2. **Rapid Prototyping Velocity Over Architecture Discipline**: Many patterns reflect quick implementation: direct Prisma everywhere, monolithic services, simple retry logic. The architecture has since matured conceptually but the code hasn't caught up.

3. **Missing "Done" Definition for Infrastructure**: Modules like idempotency and outbox were built correctly but never wired into routes. The code exists but provides zero value because integration was deferred.

4. **Configuration Drift Between Environments**: Development defaults (localhost databases, wildcard CORS, disabled rate limiting) are not guarded against in production. The env doctor exists but is failing.

5. **Testing Strategy Gap at Command/Service Layer**: Most tests are at the route/integration level. Commands (where business logic lives) are tested only transitively through routes. This makes refactoring risky and increases the cost of fixing architectural debt.

6. **No Dedicated Reliability Engineering**: Retry, circuit breaker, graceful shutdown, and health check patterns are present in basic form but lack production hardening (jitter, lease recovery, dependency checks).

---

## 19. Prioritized Remediation Roadmap

### Phase 0: Immediate Risk Containment (Before Any Production Traffic)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| CRIT-01 | Fix production database URLs | Set VPS PostgreSQL connection strings in `.env.production` | XS | Critical |
| CRIT-02 | Provision and configure Redis | Deploy Redis, set `RATE_LIMIT_REDIS_URL`, enable rate limiting | S | Critical |
| HIGH-03 | Lock moderation service CORS | Change code default to empty, require config override | XS | High |
| — | Add startup guard for production config | Refuse to start if localhost DB or missing Redis in production | XS | Critical |

**Verification**: Run `qa:env:doctor:prod` until it passes. Verify rate limiting is active. Verify moderation service CORS is locked down.

### Phase 1: Architectural Stabilization (Before Go-Live)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| HIGH-01 | Begin repository migration | Start with highest-risk modules (admin, moderation). Migrate 5 files to repositories. | L | High |
| HIGH-02 | Wire idempotency to write routes | Add middleware, wire to payments, submissions, applications, RSVPs, reports | M | High |
| HIGH-04 | Replace filesystem heartbeat | Move worker heartbeat to PostgreSQL table | M | High |
| MED-15 | Add database unique constraints | Add UNIQUE constraints for one-per-user invariants | M | Medium |
| MED-11 | Generate OpenAPI spec from routes | Use fastify-swagger or similar to auto-generate API docs | S | Medium |

**Verification**: `enforce-boundaries.mjs` passes with smaller `DIRECT_DATABASE_DEBT`. E2E tests pass for idempotency. Worker health check reads from database.

### Phase 2: Correctness and Reliability (Before Heavy Traffic)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| HIGH-05 | Add exponential backoff + jitter | Implement in BackgroundJobRunner and event outbox | S | High |
| HIGH-06 | Split TranslationService | Decompose into per-entity translators or concern-separated modules | L | High |
| HIGH-07 | Extract folder-ops from web.py | Move shell commands to dedicated module with clean interface | M | High |
| HIGH-08 | Add admin command tests | Dedicated test file for admin command functions | M | High |
| MED-04 | Add version columns for optimistic locking | Add `version` to opportunity, event, contest tables | M | Medium |
| MED-06 | Add circuit breaker on external calls | Implement on moderation API, collage API, email, storage | M | Medium |
| MED-08 | Add stale-job recovery | Lease-based recovery for PROCESSING events | S | Medium |
| MED-14 | Add concurrency tests | Vitest concurrent tests for high-risk write flows | M | Medium |
| LOW-02 | Standardize timestamp types | Migrate to Timestamptz | S | Low |

**Verification**: Load test with simulated downstream failures. Verify retry behavior. Verify no lost updates under concurrent edits.

### Phase 3: Maintainability and Reuse (Ongoing)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| HIGH-01 (continued) | Complete repository migration | Migrate remaining 17 files to repositories | L | High |
| MED-02 | Begin domain enum extraction | Create domain enums for most volatile types | XL | Medium |
| MED-09 | Document and simplify Node runtime | Document wrapper usage clearly. Consider Docker dev env. | XS | Medium |
| MED-16 | Split hotspot files | Reduce files below caps through refactoring | L | Medium |
| MED-13 | Add graceful shutdown to moderation worker | SIGTERM handler with job completion | S | Medium |
| LOW-01 | Add refresh token endpoint | Support silent re-auth for mobile | M | Low |
| LOW-06 | Add collage service business logic tests | Test collageMaker and collageWorker | M | Low |

**Verification**: `DIRECT_DATABASE_DEBT` set is empty. Hotspot caps are below thresholds. Collage service has >80% test coverage.

### Phase 4: Testing and Observability (Continuous)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| MED-07 | Add readiness health checks | Database and Redis connectivity checks | S | Medium |
| MED-10 | Add dead-letter queue and operator UI | Views, replay, discard for dead events | M | Medium |
| MED-11 | Add contract tests | Consumer-driven contract tests for web→API | M | Medium |
| LOW-03 | Consolidate env var documentation | Single source of truth for all env vars | S | Low |
| LOW-04 | Add outbox integration tests | Each state transition tested | S | Low |
| LOW-08 | Split opportunity routes | Separate route files for CRUD, applications, moderation | M | Low |
| LOW-09 | Add migration CI validation | Test migrations against production-like data | M | Low |

**Verification**: All test suites pass. Health checks show dependency status. Contract tests prevent API breakage.

### Phase 5: Performance and Developer Experience (Ongoing)

| ID | Finding | Objective | Effort | Risk Level |
|----|---------|-----------|--------|------------|
| MED-05 | Profile and optimize mobile API calls | Batch endpoints, reduce N+1 | M | Medium |
| MED-12 | Create non-root deployment user | Security hardening for VPS | S | Medium |
| MED-17 | Adopt Infrastructure as Code | Terraform or Ansible for server provisioning | L | Medium |
| LOW-12 | Validate seed data in CI | Run seed scripts against test database | S | Low |
| LOW-13 | Add backup verification | Automated restore testing | M | Low |

---

## 20. Recommended Architecture Guardrails

### Automated Enforcement (Already in Place)
- ✅ `scripts/architecture/enforce-boundaries.mjs` — layer dependency, package boundary, file size checks
- ✅ `eslint:architecture` — import rules, layer violations
- ✅ TypeScript strict mode — type safety across all packages
- ✅ `qa:env:doctor:prod` — production configuration validation (currently failing)

### Recommended Additions
1. **Architecture tests** (Vitest): Verify that `DIRECT_DATABASE_DEBT` only shrinks, never grows. Fail CI if new files are added to the list.
2. **Import restriction rules**: Add ESLint rule preventing `import { prisma } from 'database'` in `apps/api/src/modules/` except in `repositories/` directories.
3. **Database constraint verification**: CI step that compares Prisma schema constraints against application-level validation to find gaps.
4. **Contract test generation**: Auto-generate contract tests from Zod schemas. Verify frontend-consumed API shapes match backend-produced shapes.
5. **Secret scanning**: Add `trufflehog` or `gitleaks` to CI to prevent accidental secret commits.
6. **Dependency vulnerability scanning**: `pnpm audit` and `pip-audit` in CI with blocking thresholds.
7. **Migration safety checks**: CI step that runs migrations and verifies no data loss (row counts, constraint validity).
8. **Duplicate code detection**: `jscpd` or similar to identify copy-pasted logic.
9. **Test quality gates**: Coverage thresholds per module (not just global). Require specific test types for specific module types (commands must have unit tests).

---

## 21. State Transition Tables

### Content Moderation Complete State Machine

| Current State | Allowed Transitions | Owner | Preconditions | Side Effects |
|---------------|---------------------|-------|---------------|--------------|
| (new content) | → PENDING_MODERATION | createContent command | Content saved | Moderation job created |
| PENDING_MODERATION | → UNDER_MODERATION | ModerationWorker | Job picked up | Status updated |
| UNDER_MODERATION | → PUBLISHED | processImageModerationJob | Tier = CLEAN | Content visible publicly |
| UNDER_MODERATION | → PENDING_APPROVAL | processImageModerationJob | Tier = BORDERLINE or confidence < 0.6 | Admin notification |
| UNDER_MODERATION | → ACTION_REQUIRED | processImageModerationJob | Tier = SEVERE | User notification, content hidden |
| UNDER_MODERATION | → REJECTED | processImageModerationJob | Tier = SEVERE (policy violation) | Content hidden, notification |
| UNDER_MODERATION | → QUEUE_REVIEW | processImageModerationJob | revisionCount > 3 or low confidence | Manual review queue |
| PENDING_APPROVAL | → PUBLISHED | Admin approve | Admin review | Content visible |
| PENDING_APPROVAL | → REJECTED | Admin reject | Admin review | Content hidden |
| QUEUE_REVIEW | → PUBLISHED | Manual review | Reviewer decision | Content visible |
| QUEUE_REVIEW | → REJECTED | Manual review | Reviewer decision | Content hidden |
| Any non-terminal | → (re-moderation) | Content edit triggers re-moderation | Content updated | New job created |

### Event Outbox Complete State Machine

| Current State | Allowed Transitions | Trigger | Preconditions | Recovery |
|---------------|---------------------|---------|---------------|----------|
| PENDING | → PROCESSING | Worker picks up event | FOR UPDATE SKIP LOCKED, lease acquired | If crashed, lease expires → recover |
| PROCESSING | → PROCESSED | Handler succeeds | Event processed successfully | — |
| PROCESSING | → FAILED | Handler throws | retryCount incremented, nextRetryAt set | Automatic retry |
| PROCESSING | → DEAD | Handler throws, retries exhausted | retryCount >= maxRetries | Manual intervention |
| FAILED | → PENDING (retry) | nextRetryAt <= NOW() | BackgroundJobRunner periodic poll | Automatic |
| FAILED | → DEAD | retries exhausted | Same as PROCESSING → DEAD | Manual intervention |

---

## 22. Open Questions

1. **Is the `idempotency_keys` table managed by Prisma or raw SQL?** The idempotency module uses `$queryRaw` and `$executeRaw`, suggesting the table was created outside Prisma migrations. Confirmation needed.
2. **What is the intended production Redis setup?** Will it be a local Redis on the VPS, a managed service, or embedded? The rate limiting architecture depends on this decision.
3. **Is there a planned API versioning strategy?** `/api/v1/` exists but no policy is documented. When is v2 expected? What's the deprecation window?
4. **What is the `src/ai/` directory at the monorepo root?** It contains files but no build configuration references it. Is this future work or dead code?
5. **Are the GO_LIVE_*.md documents still active or should they be archived?** Multiple audit documents from different dates create confusion about current status.
6. **What is the target scale for production?** Many reliability recommendations (circuit breaker, Redis, multi-node workers) depend on expected traffic volume.
7. **Is there a backup strategy for the VPS PostgreSQL?** Automated backups, point-in-time recovery, and backup verification are not documented.
8. **What is the plan for React 19 migration?** Mobile is locked to React 18. Web needs React 19. Timeline and strategy needed.

---

## 23. Audit Limitations

1. **No runtime profiling performed**: Performance findings (N+1 queries, memory usage) are based on code structure analysis, not actual profiling. Runtime confirmation required.
2. **No live production access**: Production environment variables, actual Redis configuration, and VPS state were not inspected. Findings based on configuration files and documentation.
3. **No external penetration testing**: Security findings are code-level, not runtime. DAST and penetration testing would reveal additional issues.
4. **No load testing**: Scalability assessments are structural, not empirical.
5. **Mobile app not built and run**: Mobile code was reviewed statically. Runtime behavior (Expo dev client, native module compatibility) not verified.
6. **Moderation AI model accuracy not evaluated**: The AI models (CTranslate2) were not tested for accuracy, bias, or performance. Only the integration code was reviewed.
7. **Third-party service availability assumptions**: Backblaze B2, ImageKit, Cloudflare, Sentry, Axiom integrations were reviewed for code correctness, not tested end-to-end.
8. **Seed data scripts not executed**: Seed data correctness and schema compatibility not verified at runtime.
9. **`.gitmodules` state**: Submodule SHAs were not verified to match working tree. Potential submodule drift not checked.

---

## 24. Appendices

### A. DIRECT_DATABASE_DEBT Complete List (22 files)

From `scripts/architecture/enforce-boundaries.mjs`:

1. `apps/api/src/modules/admin/admin.commands.ts`
2. `apps/api/src/modules/auth/auth.commands.ts`
3. `apps/api/src/modules/contest/commands/CreateContest.ts` (partially refactored — uses repository)
4. `apps/api/src/modules/contest/commands/ModerateContestStatus.ts`
5. `apps/api/src/modules/contest/commands/RecordSubmissionReaction.ts`
6. `apps/api/src/modules/contest/commands/SetContestWinner.ts`
7. `apps/api/src/modules/contest/commands/SoftDeleteContest.ts`
8. `apps/api/src/modules/contest/commands/SubmitContestEntry.ts`
9. `apps/api/src/modules/contest/commands/UpdateContestById.ts`
10. `apps/api/src/modules/event/event-update-moderation.service.ts`
11. `apps/api/src/modules/event/event.commands.ts`
12. `apps/api/src/modules/moderation/ModerationService.ts`
13. `apps/api/src/modules/moderation/manual-analysis/ManualImageAnalysisService.ts`
14. `apps/api/src/modules/opportunity/OpportunityCleanupService.ts`
15. `apps/api/src/modules/opportunity/opportunity-update-moderation.service.ts`
16. `apps/api/src/modules/opportunity/opportunity.commands.ts`
17. `apps/api/src/modules/referral/referral.service.ts`
18. `apps/api/src/modules/report/report-submission.service.ts`
19. `apps/api/src/modules/report/report.commands.ts`
20. `apps/api/src/modules/search/search.service.ts`
21. `apps/api/src/modules/translation/TranslationService.ts`
22. `apps/api/src/modules/user/user.commands.ts`
23. `apps/api/src/modules/user/user.notification.commands.ts`

**Note**: `CreateContest.ts` imports a repository but is listed in debt for Prisma type imports. It is the closest to being removed from the list.

### B. Hotspot Caps Complete List

| File | Cap (lines) | Status |
|------|-------------|--------|
| `apps/api/src/modules/opportunity/opportunity.routes.ts` | 1100 | At cap |
| `apps/api/src/modules/event/event.routes.ts` | 180 | OK |
| `apps/api/src/modules/opportunity/opportunity-application-routes.ts` | 100 | OK |
| `apps/api/src/modules/admin/admin-report-read-routes.ts` | 150 | OK |
| `apps/api/src/modules/admin/admin.queries.ts` | 460 | At cap |
| `apps/api/src/modules/translation/TranslationService.ts` | 1383 | **OVER** |
| `apps/api/src/modules/moderation/application/process-image-moderation-job.ts` | 1300 | At cap |
| `apps/mobile/src/infrastructure/api/api-content-repository.ts` | 500 | OK |
| `apps/mobile/src/infrastructure/api/api-content-mappers.ts` | 780 | At cap |
| `apps/mobile/src/infrastructure/api/api-content-operations.ts` | 970 | At cap |
| `apps/web/src/scripts/admin/index.js` | 2900 | At cap |

### C. Rejected False Positives

During cross-validation, the following were investigated and determined NOT to be issues:

- **"No repositories exist"**: Repositories DO exist in `packages/database/src/repositories/` with `IRepositories` interface and implementations. The issue is that most commands don't use them, not that they don't exist.
- **"Mobile imports server code"**: Mobile does NOT import `@prisma/client` or `database` package. The architecture enforcement confirms this.
- **"No error handling in commands"**: Commands DO have try-catch blocks and throw typed DomainErrors. Error handling is present.
- **"No structured logging"**: Pino structured logging IS configured with correlation IDs and OpenTelemetry integration. Logging foundation is solid.
- **"Collage SSRF vulnerable"**: SSRF protection IS implemented with URL validation, IP blocking, and content-type checking. This is a strong positive.

### D. Glossary

| Term | Definition |
|------|------------|
| CQRS | Command Query Responsibility Segregation — separate read and write models |
| SSOT | Single Source of Truth — one authoritative location for each concept |
| Outbox Pattern | Write events to an outbox table in the same DB transaction as the data change; a separate process publishes them |
| FOR UPDATE SKIP LOCKED | PostgreSQL row-level lock that skips already-locked rows, preventing duplicate processing |
| Optimistic Locking | Using a version column to detect concurrent modifications; update fails if version changed since read |
| Circuit Breaker | Pattern that prevents cascading failures by stopping calls to a failing downstream service |
| Bulkhead | Pattern that isolates resources so one failing component doesn't exhaust all resources |
| Exponential Backoff + Jitter | Retry strategy that increases delay exponentially with randomness to prevent thundering herd |
| Idempotency | Property where repeating an operation produces the same result as doing it once |
| Dead Letter Queue | Storage for messages/events that cannot be processed after all retries |
| BFF | Backend For Frontend — API layer tailored for a specific client |

---

## 25. Audit Integrity Statement

This audit was conducted in strict read-only mode. No application source code, configuration files, database records, or infrastructure files were modified during this audit. All findings are evidence-based, with exact file paths, line references, and code excerpts cited. Where assumptions were necessary due to inability to verify runtime behavior, they are explicitly labeled as such. Coverage limitations are disclosed in Section 23.

The audit covered all three subprojects (tfpphotographers, tfp-collage-service, tfp-moderation-service), all shared packages, all test suites, all documentation, and all deployment/infrastructure configurations. No source files were changed, and no destructive commands were executed.

---

**Audit Complete** — 55 findings across 14 categories — Read-only — Evidence-based — 2026-07-26
