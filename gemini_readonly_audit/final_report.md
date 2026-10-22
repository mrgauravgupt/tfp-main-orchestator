# Comprehensive Read-Only Architecture & Code Quality Audit Report

**Date of Audit**: October 22, 2026  
**Auditor**: Principal Software Architect & Code Quality Auditor (Gemini)  
**Target Workspace**: `/Users/hexa/Desktop/tfp-main-orchestator`  
**Execution Mode**: Strict READ-ONLY Static Verification Pass  
**Audit Artifacts Workspace**: `gemini_readonly_audit/`  

---

## 1. Executive Summary & Inventory Reconciliation

This report represents the comprehensive, evidence-grounded architectural and code quality audit of the TFP Photographers platform, encompassing the central monorepo (`tfpphotographers`), four auxiliary microservices, and the orchestrator coordination root.

### 1.1 Repository Baseline Fingerprint

| Repository / Subproject | Baseline Commit SHA | Git Status | Notes |
|---|---|---|---|
| **Root Orchestrator** | `659daaa69a718a8299f4c883a071fff1d23d6eda` | Dirty (untracked) | Untracked drafts (`docs/reviews/`, `gemini_1.md`), non-repo files (`eKhata_Application_A104/`), gitlink mod |
| **tfpphotographers** | `dd05a4c8a77851078af31afff20928d36eb72b63` | Clean | Central monorepo (`apps/api`, `apps/web`, `apps/mobile`, `packages/*`) |
| **tfp-collage-service** | `15b48392e46df7bfcfbbb6c7f12adc3d1b0af279` | Clean | Node.js dynamic image collage microservice |
| **tfp-moderation-service** | `dd25f0659fda9fb5eee1df466c3d69626a412c88` | Modified (1 file) | `src/tfp_moderation_service/policies/policy_ai_inference_raw_envelope.yml` |
| **tfp-ai-interface** | `4e46c6f935e782f3172f7f25c12985e104d3b672` | Clean | Python LLM/vision inference pipeline & outbox worker |
| **tfp-inhouse-moderation** | `47a9e1e18d304472b9e82eb40a3aa7b6a6b641f9` | Clean | Local computer vision models (NudeNet, Viddexa, YOLO) |

*Read-Only Integrity Note: Existing modifications in the root orchestrator and `tfp-moderation-service` pre-existed this audit. No application source, configuration, lockfiles, or Git revisions were modified during this pass.*

---

### 1.2 Comprehensive File and Line Reconciliation

Every single file in the workspace has been discovered, classified, and fingerprinted in `gemini_readonly_audit/file_inventory.csv`:

```
Total Discovered Files: 3,157
  ├── Included in Formal Scope: 2,905 files (924,043 lines; 923,603 baseline prior to contest classification correction)
  └── Excluded Files: 252 files
        ├── Binary Assets (images, fonts, PDFs): 233 files
        ├── Personal Non-Repository Files (eKhata_Application_A104/*): 14 files
        ├── Generated Package Lockfiles (pnpm-lock.yaml, Podfile.lock): 2 files
        ├── Local Secret / Deployment Env Files: 2 files
        └── Audit Workspace Directory Artifacts: 1 file
```

#### Line Count Decomposition (924,043 Included Lines)

The 924,043 lines of included repository content are decomposed by functional category:

| Category | File Count | Line Count | Percentage of Codebase | Description / Primary Drivers |
|---|---|---|---|---|
| **Configuration** | 195 files | 326,600 lines | 35.3% | Locale JSON dictionaries (`packages/i18n`), ESLint/TSConfigs, CI workflows, Tailwind/PostCSS configs |
| **Source Code** | 1,308 files | 237,853 lines | 25.7% | Core application logic (`apps/api`, `apps/web`, `apps/mobile`, `packages/*`, microservices) |
| **Test Suites** | 954 files | 162,083 lines | 17.5% | Unit, component, and interaction tests across API, Web, Mobile, and Python services |
| **Test Fixtures** | 136 files | 101,499 lines | 11.0% | Mock JSON payloads, golden evaluation datasets, and test assets |
| **Documentation** | 147 files | 65,190 lines | 7.1% | Runbooks, API specs, architectural notes, and markdown documentation |
| **Scripts** | 109 files | 14,675 lines | 1.6% | Deployment automation, database supervision, migration wrappers, and QA harnesses |
| **Database Schema / Migrations** | 22 files | 10,496 lines | 1.1% | Prisma schema definitions (`schema.prisma`) and raw SQL migration files |
| **Lockfiles** | 3 files | 4,987 lines | 0.5% | Python lockfiles (`uv.lock`) |
| **Other** | 31 files | 660 lines | 0.1% | Git submodule pointers, package manifests, and miscellaneous text files |
| **Total** | **2,905 files** | **924,043 lines** | **100.0%** | Full repository scope |

*Classification Reconciliation Note: An earlier mechanical classifier misidentified 65 production contest files (11,131 lines) as test files due to substring matching on `test`. Correcting this directory boundary restored those files to `SOURCE_CODE` and `CONFIGURATION`, shifting lines into their truthful functional categories.*

#### Mechanical Scan Coverage Reconciliation

The static rolling-hash window scanner and regex symbol detector targeted all executable programming source files (`.ts`, `.tsx`, `.js`, `.mjs`, `.cjs`, `.astro`, `.py`), covering **2,103 source files**. 

The remaining **802 files outside the scanner's coverage** are fully accounted for by exact extension without omission:

| File Extension | File Count | Nature of Artifact | Review Methodology Applied |
|---|---|---|---|
| `.json` | 157 files | Locale dictionaries, package manifests, OpenAPI specs, fixtures | Schema validation, i18n integrity checks, dependency audits |
| `.scss` | 145 files | Stylesheets, design tokens, responsive typography rules | Token consistency checks, CSS selector audits |
| `.md` | 135 files | System documentation, architectural decision records, runbooks | Technical accuracy and contract cross-referencing |
| `.yaml` | 124 files | GitHub Actions workflows, Docker compose manifests, CI scripts | Pipeline security, container topology analysis |
| `.sh` | 109 files | Shell deployment scripts, environment setup, database runners | Bash syntax inspection, parameter safety, POSIX compliance |
| *No extension* | 26 files | Git submodules, dotfiles, license agreements, env examples | Identity verification, configuration inspection |
| `.yml` | 17 files | Policy configurations, dependabot configurations | Policy grammar checks, AST comparison against schemas |
| `.sql` | 14 files | Prisma migration scripts, baseline DDL | Index analysis, constraint verification, lock safety |
| `.html` | 13 files | Static email previews, documentation reports | Template rendering inspection, asset linking checks |
| `.example` | 12 files | Environment template files (`.env.example`) | Secret key parity, configuration drift checks |
| `.txt` | 12 files | Python requirements manifests, robots.txt | Dependency version locking, security advisories |
| `.service` | 9 files | Systemd service unit definitions for production daemons | Supervisor configuration, restart policy review |
| `.mts` | 6 files | TypeScript module scripts for database tooling | Manual TypeScript type and logic inspection |
| `.svg` | 5 files | Scalable vector graphic icon primitives | Asset hygiene and DOM embedding verification |
| `.toml` | 4 files | Python packaging manifests (`pyproject.toml`) | Build-system configuration, dependency constraints |
| `.lock` | 3 files | Python lockfiles (`uv.lock`) | Dependency vulnerability inspection |
| `.css` | 3 files | Standalone fallback stylesheets | CSS syntax validation |
| `.conf` | 2 files | Web server / proxy configurations (Nginx / Caddy) | Header security, proxy forwarding verification |
| `.pt` | 1 file | Pre-trained PyTorch model checkpoint pointer | Binary integrity inspection |
| `.docx` | 1 file | Legacy project specification document | Document metadata audit |
| `.prisma` | 1 file | Canonical Prisma database schema (`packages/database`) | Relation modeling, index coverage, soft-delete analysis |
| `.xml` | 1 file | Mobile Android manifest fragment | XML validation, permission audit |
| `.gradle` | 1 file | Android Gradle build script fragment | Build configuration audit |
| `.timer` | 1 file | Systemd timer definition for scheduled cron jobs | Schedule interval and trigger target audit |
| **Total** | **802 files** | **Fully Reconciled Non-Scanned Scope** | **100% Accounted For** |

---

### 1.3 Formal Module Review Manifest (17 Records)

All 2,905 included files are mapped across exactly 17 detailed module review records located under `gemini_readonly_audit/modules/`, directly reconciled with `gemini_readonly_audit/file_inventory.csv`:

| Record Filename | Scope & Responsibilities | Included Files | Included Lines |
|---|---|---|---|
| `orchestrator_contracts_scripts.md` | Orchestrator root, shared contracts, docs, QA test suites, e2e harnesses, and root deployment scripts | 644 | 248,756 |
| `tfpphotographers_apps_web.md` | Astro SSR pages, React feature islands, client telemetry, styling tokens, and utilities | 619 | 100,660 |
| `tfpphotographers_apps_mobile.md` | Expo React Native app (Domain, Application, Infrastructure, Presentation, tests) | 497 | 61,960 |
| `tfpphotographers_apps_api_modules.md` | 20 vertical domain modules under `apps/api/src/modules/` and their domain tests | 317 | 50,959 |
| `tfpphotographers_apps_api_core.md` | API server bootstrap, Fastify plugins, outbox workers, runtime composition, and server tests | 275 | 43,660 |
| `tfpphotographers_packages_i18n.md` | 95 locale JSON catalogs, language negotiator, translation loader, and formatters | 119 | 319,932 |
| `tfpphotographers_packages_shared.md` | Universal contracts, DTO schemas, design tokens, locale registry, and shared formatters | 84 | 13,447 |
| `tfp_moderation_service.md` | Python AI moderation microservice (`service.py`, `adapters.py`, policies, tests) | 82 | 37,377 |
| `tfp_ai_interface.md` | Python AI interface service, background worker (`psycopg` pool), and tests | 70 | 14,534 |
| `tfp_collage_service.md` | Node.js dynamic image collage microservice, hexagonal ports/adapters, and tests | 47 | 7,515 |
| `tfpphotographers_packages_database.md` | Prisma schema, migrations, soft-delete extension, repository classes, and adapters | 45 | 11,963 |
| `tfp_inhouse_moderation.md` | In-house Python computer vision models (NudeNet, Viddexa, YOLO) and evaluation scripts | 37 | 4,154 |
| `tfpphotographers_packages_storage.md` | Multi-provider storage gateway (S3, B2, R2, Local) and Cloudflare media purger | 24 | 2,343 |
| `tfpphotographers_packages_config.md` | Type-safe environment validation schemas and runtime configs | 17 | 2,993 |
| `tfpphotographers_packages_email.md` | Transactional email templates, HTML compiler, Resend & Console adapters | 17 | 2,118 |
| `tfpphotographers_packages_moderation.md` | Moderation upload port, raw-policy AST tokenizer, parser, and runtime evaluator | 8 | 867 |
| `tfpphotographers_packages_uploads.md` | Magic-byte MIME detection, image dimension calculation, and upload policies | 3 | 805 |
| **Total** | **Full Workspace Included Scope** | **2,905** | **924,043** |

---

## 2. Architecture & Persistence Verification

### 2.1 Decoupling Repository Retirement from Target Architecture (Hexagonal Ports & Adapters vs. CQRS)

A fundamental architectural correction concerns `packages/database/src/repositories/`. The preliminary audit observed that domain modules use CQRS Command/Query handlers with direct Prisma access and recommended retiring unused repositories while migrating remaining callers to direct Prisma calls.

**Target Architecture Correction**:
CQRS (Command Query Responsibility Segregation) separates the models used for updates from the models used for reads. Hexagonal Architecture (Ports & Adapters) addresses an orthogonal concern: keeping application domain logic independent of persistence infrastructure. 

Migrating application handlers to call Prisma directly couples domain logic to a specific ORM. The target architecture for database independence is:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Application Layer                               │
│  - Commands & Queries execute use cases and business rules             │
│  - Owns Domain Persistence Ports (Interfaces)                          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ implements port
┌───────────────────────────────────▼────────────────────────────────────┐
│                   Infrastructure Layer (Adapters)                      │
│  - Prisma Infrastructure Adapters implement domain repository ports    │
│  - Encapsulates Prisma Client, raw queries, and transaction management │
└────────────────────────────────────────────────────────────────────────┘
```

#### Detailed Verification of All 12 Concrete Repository Classes (+ 3 Support Files)

We performed an exhaustive codebase-wide search across all 2,905 files to establish the exact caller count for every file in `packages/database/src/repositories/`:

| Artifact | Classification | Status | Caller Count | Caller File Locations & Analysis | Disposition |
|---|---|---|---|---|---|
| `base.repository.ts` | Support Base Class | Subclassed | 12 classes | Subclassed by concrete repositories; no external call sites | Retain if adapters retain common base, or retire with uncalled repos |
| `index.ts` | Barrel & Factory | Exported | Internal | Declares `IRepositories` and `createRepositories(prisma)` | Prune uncalled repository properties; update factory |
| `persistence-errors.ts` | Error Classes | Exported | 1 caller | Used for database error mapping (`DatabaseError`, `NotFoundError`) | Retain in persistence package |
| `contest.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Domain commands (`apps/api/src/modules/contest/`) use direct Prisma | **RETIRE** |
| `contest-submission.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Domain commands query Prisma directly | **RETIRE** |
| `event.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Domain commands (`apps/api/src/modules/event/`) query Prisma directly | **RETIRE** |
| `opportunity.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Domain commands (`apps/api/src/modules/opportunity/`) query Prisma directly | **RETIRE** |
| `message.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Domain commands (`apps/api/src/modules/message/`) query Prisma directly | **RETIRE** |
| `portfolio-image.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Media upload handlers query Prisma directly | **RETIRE** |
| `report.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Report handlers (`apps/api/src/modules/report/`) query Prisma directly | **RETIRE** |
| `moderation-case.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Moderation handlers query Prisma directly | **RETIRE** |
| `password-reset-token.repository.ts` | Concrete Class | **UNCONSUMED** | **0 callers** | Auth handlers query Prisma directly | **RETIRE** |
| `user.repository.ts` | Concrete Class | **ACTIVE** | **1 caller** | `apps/api/src/modules/auth/oauth-user-service.ts` (lines 14, 45) | **RETAIN / ADAPTERIZE** |
| `oauth-account.repository.ts` | Concrete Class | **ACTIVE** | **1 caller** | `apps/api/src/modules/auth/oauth-user-service.ts` (lines 15, 62) | **RETAIN / ADAPTERIZE** |
| `user-violation.repository.ts` | Concrete Class | **ACTIVE** | **1 caller** | `apps/api/src/modules/admin/admin-violations-routes.ts` (lines 28, 82) | **RETAIN / ADAPTERIZE** |

**Repository Factory Coupling Warning**:
The repositories in `packages/database/src/repositories/` are orchestrated by the factory function `createRepositories(prisma)` and typed by `IRepositories` in `index.ts`. In `apps/api/src/application/runtime-services.ts`, `createRepositories(prisma)` is instantiated and attached to `app.decorate('repositories')`. 
Therefore, retiring unused repositories cannot be executed by merely deleting files in isolation. The factory interface `IRepositories`, `createRepositories(prisma)`, and `runtimeServices.repositories` must be refactored simultaneously.

---

### 2.2 Transaction Atomicity, Row Locking & Outbox Concurrency

#### PostgreSQL Row-Level Locking via `SKIP LOCKED`
Concurrency control across outbox worker instances does **NOT** rely on a "lock-free" algorithm. It uses PostgreSQL's explicit row-level locking with the `FOR UPDATE SKIP LOCKED` clause:

```sql
SELECT id, event_type, payload, retry_count 
FROM event_outbox 
WHERE status = 'PENDING' AND (scheduled_for IS NULL OR scheduled_for <= NOW())
ORDER BY created_at ASC 
LIMIT $1 
FOR UPDATE SKIP LOCKED;
```

**Concurrency & Delivery Properties**:
- `FOR UPDATE` places an exclusive row-level lock on each selected row for the duration of the worker's transaction.
- `SKIP LOCKED` instructs competing worker processes to immediately skip any locked rows and select the next available unlocked rows without blocking.
- This provides high-throughput, non-blocking parallel processing across multiple worker processes while preventing duplicate simultaneous execution of the same outbox row.
- **Delivery Guarantee**: Outbox workers guarantee **at-least-once delivery** (if a worker crashes after dispatching an external side-effect but before updating `status = 'COMPLETED'`, the 5-minute lease expiry triggers redelivery). Downstream event consumers must be strictly idempotent.

#### Transactional Atomicity Verification & The NotificationService Exception
In core domain modules (`contest`, `opportunity`, `event`, `user`, `media`), domain mutations and outbox entries are written atomically within the same transaction:

```typescript
await prisma.$transaction(async (tx) => {
  // 1. Mutate domain entity using transactional client
  const contest = await tx.contest.create({ data: ... });
  
  // 2. Insert outbox record using the EXACT same transactional client
  await enqueueOutboxEntry(tx, {
    eventType: 'CONTEST_CREATED',
    payload: { contestId: contest.id, ... },
  });
});
```

**The NotificationService Outbox Exception**:
In `tfpphotographers/apps/api/src/modules/notifications/NotificationService.ts`, `EventBusNotificationService` calls `this.eventBus.emit(...)`.
In `apps/api/src/application/runtime-services.ts`, `eventBus` is instantiated as `getEventBus(createEventOutboxAdapter(input.prisma))`, binding to the root `prisma` client rather than a transactional client (`tx`).
As a result, notification events are written directly to `event_outbox` outside parent business transactions. If the surrounding database transaction rolls back, or conversely if outbox insertion fails, state updates and event emission can diverge.

---

### 2.3 Prisma `softDeleteExtension` Operation Matrix

The preliminary audit suggested that manual `where: { deletedAt: null }` filters throughout the API were completely redundant due to the Prisma `softDeleteExtension` in `packages/database/src/index.ts`.

**Code Inspection Reality**:
Prisma Client Extensions operate via query middleware wrapping root model delegates. Code analysis of `packages/database/src/index.ts` reveals the exact operation-by-operation matrix:

| Operation Category | Prisma Method | Extension Coverage | Behavior & Safety Rule |
|---|---|---|---|
| **Root Read Queries** | `findUnique`, `findUniqueOrThrow`, `findFirst`, `findFirstOrThrow`, `findMany` | **INTERCEPTED** | Injects `where: { deletedAt: null }` automatically unless `deletedAt` key is explicitly provided |
| **Root Aggregations** | `count`, `aggregate`, `groupBy` | **INTERCEPTED** | Injects `where: { deletedAt: null }` automatically |
| **Nested Relations** | `include: { relation: true }`, `select: { relation: true }` | **NOT INTERCEPTED** | Queries returning nested relations return soft-deleted rows unless `{ where: { deletedAt: null } }` is explicitly provided |
| **Raw SQL Queries** | `$queryRaw`, `$queryRawUnsafe`, `$executeRaw`, `$executeRawUnsafe` | **NOT INTERCEPTED** | Bypasses Prisma Client extensions entirely; manual `deleted_at IS NULL` is mandatory |
| **Mutations** | `delete`, `deleteMany` | **NOT INTERCEPTED** | Executes physical SQL `DELETE`. Soft deletion requires `update`/`updateMany` setting `deletedAt: new Date()` |

**Preservation Mandate**:
Do **NOT** remove explicit `deletedAt: null` filters from nested relation queries or raw SQL queries. They are functionally necessary to prevent soft-deleted records from leaking into API responses.

---

## 3. Duplication & Candidate Reconciliation

During the mechanical scan, 96 block-level duplicate windows (sharing >= 10 normalized lines across distinct files) and 51 multi-defined exported symbols were identified. 

All 147 candidate instances have been individually reviewed and categorized with explicit rationales in `gemini_readonly_audit/candidate_dispositions.csv`.

### 3.1 Reconciliation of the 96 Block-Level Candidates

| File Pair Description | Matched Blocks | Primary Disposition | Canonical ID | Architectural Assessment & Rationale |
|---|---|---|---|---|
| `browser_policy_evaluator_toolkit.js` <-> `packages/moderation/src/raw-policy/runtime.ts` | 11 blocks | **CONSOLIDATE** | **AUD-0011 / DUP-004** | Handwritten ES5 copy of TypeScript AST parser/evaluator. Must be compiled from package source. |
| `apps/api/.../admin-appeal.commands.ts` <-> `apps/api/.../report.commands.ts` | 9 blocks | **CONSOLIDATE** | **AUD-0008 / DUP-003** | Exact duplicate `CreateModerationAppeal` vs `CreateReportAppeal` inserting identical records. |
| `apps/api/.../admin-appeal.commands.ts` <-> `apps/api/.../admin-moderation-appeals.queries.ts` | 1 block | RETAIN_SEPARATELY | NONE | Command and query in same administrative domain sharing interface DTO types. |
| `apps/api/.../admin-moderation-appeals.queries.ts` <-> `apps/api/.../report.queries.ts` | 5 blocks | **CONSOLIDATE** | **AUD-0008** | Shared report query shapes and appeal resolution fetchers duplicating report lookup logic. |
| `apps/api/.../ModerateContestStatus.ts` <-> `apps/api/.../event.commands.ts` | 2 blocks | RETAIN_SEPARATELY | NONE | Independent domain state machine updates (contests vs events) sharing mutation structure. |
| `apps/api/.../RecordSubmissionReaction.ts` <-> `RemoveSubmissionReaction.ts` | 1 block | RETAIN_SEPARATELY | NONE | Symmetric command pair in contest domain toggling user reaction records. |
| `apps/api/.../event-participation-routes.ts` <-> `opportunity-application.handlers.ts` | 4 blocks | RETAIN_SEPARATELY | NONE | Distinct domain workflows sharing standard Fastify request validation schema structures. |
| `apps/api/.../event-read-routes.ts` <-> `opportunity-read-routes.ts` | 11 blocks | RETAIN_SEPARATELY | NONE | Read routes for distinct entities sharing pagination and filter schema boilerplate. |
| `apps/api/.../bootstrap.ts` <-> `apps/web/astro.config.mjs` | 2 blocks | RETAIN_SEPARATELY | NONE | Telemetry/Sentry bootstrap across Node API and Astro build/SSR environment. |
| `apps/api/.../logger.ts` <-> `apps/web/.../telemetry.ts` | 1 block | RETAIN_SEPARATELY | NONE | Logger level configuration and formatting shared across server and web telemetry helpers. |
| `apps/mobile/.../NativeDocumentField.tsx` <-> `NativeImageField.tsx` | 1 block | RETAIN_SEPARATELY | NONE | Specialized React Native upload field wrappers tailored for document vs image MIME types. |
| `apps/mobile/.../LegalComplianceCenter.interaction.test.ts` <-> `OptionalConsentFailure...test.ts` | 3 blocks | RETAIN_SEPARATELY | NONE | Test fixture mock setup and user consent interaction harness code across test suites. |
| `apps/mobile/.../AccountScreens.tsx` <-> `ActivityScreen.tsx` | 8 blocks | RETAIN_SEPARATELY | NONE | Mobile screen layout and navigation header definitions sharing common screen wrapper structure. |
| `apps/mobile/.../ContestDraftFields.tsx` <-> `EventDraftFields.tsx` | 2 blocks | RETAIN_SEPARATELY | NONE | Form field rendering components for contest draft vs event draft entities. |
| `apps/mobile/.../EventScreens.tsx` <-> `contest-screen-styles.ts` | 2 blocks | RETAIN_SEPARATELY | NONE | Shared styling constants and StyleSheet definitions across mobile screens. |
| `apps/mobile/.../SearchFilterRemoval...test.ts` <-> `SearchScreen.quick-search.test.ts` | 3 blocks | RETAIN_SEPARATELY | NONE | Test fixture boilerplate in mobile search interaction test files. |
| `apps/web/sentry.client.config.ts` <-> `sentry.server.config.ts` | 5 blocks | RETAIN_SEPARATELY | NONE | Required runtime split for Sentry client vs server SDK configuration in Astro. |
| `apps/web/.../opportunities/[slug]/edit.astro` <-> `create.astro` | 1 block | RETAIN_SEPARATELY | NONE | Astro page templates for create vs edit workflows sharing form container markup. |
| `apps/web/.../profile/[username].astro` <-> `profile-page.ts` | 1 block | RETAIN_SEPARATELY | NONE | Astro profile page component coordinating with its companion data fetching helper. |
| `apps/web/.../ga4-consent-loader.ts` <-> `optional-consent-preferences.ts` | 3 blocks | RETAIN_SEPARATELY | NONE | Client-side cookie and consent storage management scripts. |
| `apps/web/.../admin-copy.ts` <-> `admin-formatters.ts` | 8 blocks | RETAIN_SEPARATELY | NONE | Admin UI localized strings and text formatting functions. |
| `packages/shared/.../location-context.native.ts` <-> `location-context.ts` | 10 blocks | **PLATFORM_FORK** | **NONE** | Intentional platform fork: React Native vs Web browser location context adapters. |
| `packages/storage/.../BackblazeB2Adapter.ts` <-> `LocalFilesystemAdapter.ts` | 2 blocks | RETAIN_SEPARATELY | NONE | Storage port adapters sharing common error mapping and buffer validation logic. |
| `scripts/env/env-resolver.mjs` <-> `setup-env.mjs` | 1 block | RETAIN_SEPARATELY | NONE | Root orchestration environment resolution and setup utility scripts. |
| **Total Block Duplicates** | **96 blocks** | — | — | **All 96 instances reconciled** |

---

### 3.2 Canonical Duplicate Groups (DUP-001 through DUP-005)

The verified duplicate groups documented in `gemini_readonly_audit/duplicate_groups.md` are:

- **DUP-001: Cloudflare Media Purger** (`packages/storage` vs `tfp-collage-service`) -> **AUD-0001** (Consolidate into shared contract library).
- **DUP-002: Binary Magic Byte MIME Detection** (`packages/uploads` vs `apps/api/src/utils/image-signature.ts`) -> **AUD-0002** (Consolidate into `packages/uploads` preserving short-buffer guard).
- **DUP-003: Moderation Appeal Creation** (`admin-appeal.commands.ts` vs `report.commands.ts`) -> **AUD-0008** (Consolidate into `moderation` domain; eliminate cross-domain route import).
- **DUP-004: Raw Policy AST Parser & Evaluator** (`packages/moderation` vs `tfp-moderation-service/.../browser_policy_evaluator_toolkit.js`) -> **AUD-0011** (Compile client bundle from TypeScript source).
- **DUP-005: Exact Page Redirect Stubs** (`apps/web/.../forgot-password.astro` vs `reset-password.astro`) -> **AUD-0007** (Retain as intentional routing stubs or configure in `astro.config.mjs`).

---

## 4. Comprehensive Findings Ledger (AUD-0001 through AUD-0012)

Every confirmed finding is recorded with structured machine-readable metadata in `gemini_readonly_audit/findings.jsonl`. Below is the complete, prioritized findings ledger:

### Finding Summary Matrix

| ID | Title | Category | Severity | Confidence | Verification Status |
|---|---|---|---|---|---|
| **AUD-0001** | Near-duplicate Cloudflare Media Purger with behavioral drift | DUPLICATION | MEDIUM | HIGH | CONFIRMED |
| **AUD-0002** | Duplicate image MIME magic-byte detection | DUPLICATION | LOW | HIGH | CONFIRMED |
| **AUD-0003** | Unused Repository implementations & Hexagonal persistence | DEAD_CODE | MEDIUM | HIGH | CONFIRMED |
| **AUD-0004** | Unused createInMemoryRateLimiter & cache location | ORGANIZATION | LOW | HIGH | CONFIRMED |
| **AUD-0005** | Eager synchronous I/O & memory overhead in packages/i18n | PERFORMANCE | MEDIUM | HIGH | CONFIRMED |
| **AUD-0006** | Monolithic god-object and 2,170-line method in moderation service | MAINTAINABILITY | HIGH | HIGH | CONFIRMED |
| **AUD-0007** | Exact duplicate page redirects in Astro Web frontend | DUPLICATION | LOW | HIGH | CONFIRMED |
| **AUD-0008** | Duplicate appeal creation commands & layer-crossing import | DUPLICATION | MEDIUM | HIGH | CONFIRMED |
| **AUD-0009** | Boundary-crossing relative imports from test/QA scripts | ARCHITECTURE | MEDIUM | HIGH | CONFIRMED |
| **AUD-0010** | Monolithic server bootstrapping in apps/api/src/server.ts | MAINTAINABILITY | MEDIUM | HIGH | CONFIRMED |
| **AUD-0011** | Handwritten ES5 duplication of Raw Policy AST Parser/Evaluator | DUPLICATION | MEDIUM | HIGH | CONFIRMED |
| **AUD-0012** | Direct shared-database outbox and entity coupling in AI worker | ARCHITECTURE | HIGH | HIGH | CONFIRMED |

---

### Detailed Findings Profiles

#### AUD-0001: Near-duplicate Cloudflare Media Purger with behavioral drift
- **Affected Modules**: `tfpphotographers/packages/storage`, `tfp-collage-service`
- **File Paths**:
  - `tfpphotographers/packages/storage/src/adapters/CloudflareMediaPurger.ts:3-31`
  - `tfp-collage-service/src/adapters/cloudflareMediaPurger.ts:3-34`
- **Evidence**: Both files implement identical 100-URL batching, Set-based URL deduplication, 10-second timeout signals, and JSON POST requests to the Cloudflare cache purge endpoint. However, error messages have drifted: `packages/storage` throws human-readable sentences while `tfp-collage-service` throws uppercase tokens (`CLOUDFLARE_MEDIA_PURGE_TOKEN_NOT_CONFIGURED`). The collage service also accepts an optional `fetchImpl` parameter for unit test mocking.
- **Recommended Action**: Extract `CloudflareMediaPurger` into a shared package or publishable contract module. Support optional `fetchImpl` injection and standardize error tokens.
- **Risk & Constraints**: Low risk. Downstream alert rules and unit tests matching specific error strings must be updated.
- **Required Verification Tests**:
  - `[EXISTING]` `tfp-collage-service/tests/cloudflareMediaPurger.test.ts`
  - `[PROPOSED]` `packages/storage/tests/cloudflare-purger-contract.test.ts`

#### AUD-0002: Duplicate image MIME magic-byte detection across packages/uploads and apps/api
- **Affected Modules**: `tfpphotographers/packages/uploads`, `tfpphotographers/apps/api`
- **File Paths**:
  - `tfpphotographers/packages/uploads/src/index.ts:44-61` (`detectMimeByMagicBytes`)
  - `tfpphotographers/apps/api/src/utils/image-signature.ts:1-16` (`detectImageMimeType`)
- **Evidence**: Both implementations inspect raw byte prefixes for JPEG (`FF D8 FF`), PNG (`89 50 4E 47`), and WEBP (`RIFF`...`WEBP`). Critical difference: `detectMimeByMagicBytes` in `packages/uploads` also detects PDF (`%PDF-`) for document attachments, whereas `detectImageMimeType` in `apps/api` contains an explicit `imageBuffer.byteLength < 4` guard and strictly validates image formats for moderation.
- **Recommended Action**: Consolidate magic-byte detection inside `packages/uploads`. Preserve the short-buffer (< 4 bytes) guard and provide an image-only allowlist option so moderation callers do not inadvertently accept PDF buffers.
- **Risk & Constraints**: Low risk.
- **Required Verification Tests**:
  - `[EXISTING]` `packages/uploads/tests/uploads.test.ts`
  - `[PROPOSED]` `apps/api/tests/image-signature-compatibility.test.ts`

#### AUD-0003: Unused Repository implementations and decoupled Hexagonal persistence architecture
- **Affected Modules**: `tfpphotographers/packages/database`, `tfpphotographers/apps/api`
- **File Paths**:
  - `packages/database/src/repositories/base.repository.ts:1-55`
  - 12 concrete repository classes in `packages/database/src/repositories/`
- **Evidence**: Codebase-wide symbol tracing confirms that 9 of the 12 concrete repository classes have zero callers anywhere in the workspace. Only `UserRepository`, `OAuthAccountRepository` (in `oauth-user-service.ts`), and `UserViolationRepository` (in `admin-violations-routes.ts`) have active call sites. Application commands elsewhere query Prisma directly. Furthermore, Prisma's `softDeleteExtension` only intercepts top-level root queries; explicit `deletedAt: null` filtering is required in relation joins (`include:`) and raw SQL.
- **Recommended Action**: Safely remove the 9 uncalled concrete repository classes (~1,400 lines of dead code). For active persistence access, do NOT force callers to direct Prisma queries. Instead, define domain repository interfaces (ports) owned by the application layer, and implement them via Prisma infrastructure adapters. Preserve atomic transaction boundaries (`tx`) covering business changes and outbox records. Retain manual soft-delete filters on relation joins.
- **Factory Coupling Note**: Update `IRepositories` and `createRepositories(prisma)` in `packages/database/src/repositories/index.ts` and `apps/api/src/application/runtime-services.ts`.
- **Risk & Constraints**: Low for uncalled classes; medium for active repositories requiring interface alignment.
- **Required Verification Tests**:
  - `[EXISTING]` `packages/database/tests/repositories/user.repository.test.ts`
  - `[PROPOSED]` `apps/api/tests/architecture/ports-and-adapters-persistence.test.ts`

#### AUD-0004: Unused createInMemoryRateLimiter and cache adapter location in packages/database
- **Affected Modules**: `tfpphotographers/packages/database`, `tfpphotographers/apps/api`
- **File Paths**:
  - `packages/database/src/adapters/rate-limiter.adapter.ts:1-45`
  - `packages/database/src/adapters/cache.adapter.ts:1-65`
- **Evidence**: `rate-limiter.adapter.ts` exports `createInMemoryRateLimiter`. Full-workspace search reveals `createInMemoryRateLimiter` has zero callers across all repositories. Conversely, `createInMemoryCache` in `cache.adapter.ts` is actively consumed in `apps/api/src/server.ts:522` for Fastify response caching. However, an in-memory Map cache is an application infrastructure concern, not a database persistence concern.
- **Recommended Action**: Retire the unused `createInMemoryRateLimiter` export. Relocate `createInMemoryCache` to `apps/api/src/infrastructure/cache/` or `packages/shared`.
- **Risk & Constraints**: Low risk. Preserve cache interface and behavior in `server.ts:522`.
- **Required Verification Tests**:
  - `[EXISTING]` `apps/api/tests/server-cache.test.ts`
  - `[PROPOSED]` `packages/shared/tests/in-memory-cache.test.ts`

#### AUD-0005: Eager synchronous disk I/O and potential memory overhead in packages/i18n catalog loading
- **Affected Modules**: `tfpphotographers/packages/i18n`
- **File Paths**:
  - `packages/i18n/src/index.ts:1-125`
- **Evidence**: `packages/i18n/src/index.ts` executes `loadLanguageCatalogs()` synchronously at module evaluation time, parsing 95 JSON catalog files totaling 23.95 MB (approx 24 MB) into heap memory upon initial import. Any Node.js process importing `packages/i18n` (API server, outbox workers, CLI scripts) synchronously loads and parses all 95 languages, even if only a single locale is requested. Canonical fallback locales are `en_US` and `en_IN`.
- **Recommended Action**: Transition to on-demand lazy catalog loading with an in-memory LRU or Map cache, retaining synchronous resolution for pre-warmed fallback locales (`en_US`, `en_IN`).
- **Empirical Measurement Protocol (Pre-Implementation Requirement)**:
  Before implementing lazy loading, execute an empirical profiling test:
  1. Record baseline cold-start duration and resident set size (RSS) memory of `apps/api` and `apps/api/src/worker.ts` with eager catalog loading.
  2. Implement lazy catalog loading on a feature branch.
  3. Re-run identical startup and load benchmarks across API, worker, and Astro SSR runtimes.
  4. Verify that measured savings justify the refactoring complexity and that fallback resolution latency remains unaffected.
- **Risk & Constraints**: Medium risk; requires ensuring callers tolerate asynchronous hydration or that fallback catalogs are pre-warmed synchronously. Must preserve exact locale fallback rules (`regional` -> `base language` -> `en_US` / `en_IN`).
- **Required Verification Tests**:
  - `[EXISTING]` `packages/i18n/tests/i18n.test.ts`
  - `[PROPOSED]` `packages/i18n/tests/lazy-loading-performance-profile.test.ts`

#### AUD-0006: Monolithic god-object and 2,170-line method in tfp-moderation-service
- **Affected Modules**: `tfp-moderation-service`
- **File Paths**:
  - `tfp-moderation-service/src/tfp_moderation_service/service.py:1-6162`
  - `tfp-moderation-service/src/tfp_moderation_service/adapters.py:1-2207`
- **Evidence**: `service.py` contains 6,162 lines of Python code. A single class, `ImageDerivedSignalBuilder`, spans 4,272 lines (lines 234–4506), and its primary method `build` spans 2,170 lines (lines 251–2420). It interweaves heuristic threshold evaluations, nested dictionary parsing, CLIP score adjustments, and adult content likelihoods into an indivisible execution block. Similarly, `adapters.py` packs 20 classes (including 11 distinct vision model adapters) into a single 2,207-line file.
- **Recommended Action**: Decompose `ImageDerivedSignalBuilder` into cohesive single-responsibility feature signal extractors (`NuditySignalExtractor`, `SemanticSignalExtractor`, `AnatomicalSignalExtractor`). Break `adapters.py` into modular adapter files under `adapters/`.
- **Risk & Constraints**: High risk. Must establish golden-master test baselines using `scripts/eval_192_moderation_service.py` before refactoring to guarantee identical policy verdicts and report outputs.
- **Required Verification Tests**:
  - `[EXISTING]` `tfp-moderation-service/scripts/eval_192_moderation_service.py`
  - `[EXISTING]` `tfp-moderation-service/tests/test_raw_verify.py`
  - `[PROPOSED]` `tfp-moderation-service/tests/golden_signal_builder_regression.py`

#### AUD-0007: Exact duplicate page redirects in Astro Web frontend
- **Affected Modules**: `tfpphotographers/apps/web`
- **File Paths**:
  - `apps/web/src/pages/forgot-password.astro:1-7`
  - `apps/web/src/pages/reset-password.astro:1-7`
- **Evidence**: Both files are byte-for-byte identical (SHA-256 `327cc44c0ab2...`). Each contains 7 lines redirecting legacy authentication URLs to `/login` using `localizePathWithQuery` while preserving incoming querystrings.
- **Recommended Action**: Either declare these redirects in `astro.config.mjs` redirects table to eliminate file clutter, or retain them as explicit routing stubs if Astro's file-system routing convention is preferred.
- **Risk & Constraints**: Low risk. Querystring preservation (`redirect_to`, `email`) must be verified.
- **Required Verification Tests**:
  - `[EXISTING]` `tfpphotographers/tests/e2e/auth-redirects.test.ts`
  - `[PROPOSED]` `apps/web/tests/redirect-stubs-query-preservation.test.ts`

#### AUD-0008: Duplicate appeal creation commands and layer-crossing route import in API
- **Affected Modules**: `tfpphotographers/apps/api`
- **File Paths**:
  - `apps/api/src/modules/admin/admin-appeal.commands.ts:4-24`
  - `apps/api/src/modules/report/report.commands.ts:126-146`
  - `apps/api/src/modules/moderation/moderation-appeal-routes.ts:54-55`
- **Evidence**: `CreateModerationAppeal` in `admin-appeal.commands.ts` and `CreateReportAppeal` in `report.commands.ts` execute 100% identical `prisma.moderationAppeal.create` queries with identical payload and selection structures. Furthermore, the public user-facing moderation appeal route (`moderation-appeal-routes.ts:54`) imports `CreateModerationAppeal` from the `admin` module, violating domain boundary encapsulation.
- **Recommended Action**: Consolidate the mutation into a single command owned by `apps/api/src/modules/moderation/` or `report/`, eliminating the duplicate command in `admin`. Update route imports to reference the domain-appropriate command.
- **Risk & Constraints**: Low risk. Verify that both moderation and report handlers receive the identical `ModerationAppeal` DTO shape.
- **Required Verification Tests**:
  - `[EXISTING]` `apps/api/src/modules/moderation/__tests__/moderation-appeal.test.ts`
  - `[PROPOSED]` `apps/api/tests/architecture/admin-boundary-violation.test.ts`

#### AUD-0009: Boundary-crossing relative imports from test/QA scripts into internal API implementation
- **Affected Modules**: `tfpphotographers/scripts`, `tfpphotographers/apps/api`
- **File Paths**:
  - `scripts/architecture/http-persistence-boundary.test.mjs:15-35`
  - `scripts/env/env-resolver.mjs`
- **Evidence**: Architecture verification test scripts use deep relative path traversals (e.g. `../../apps/api/src/modules/...`) to inspect internal TypeScript source files directly rather than testing public package exports or executing black-box HTTP queries.
- **Recommended Action**: Refactor architectural compliance tests to discover and analyze file paths dynamically via AST parsers rather than importing internal TypeScript implementation files directly.
- **Risk & Constraints**: Low risk. Ensure architectural linting rules continue to assert that route handlers do not bypass service boundaries.
- **Required Verification Tests**:
  - `[EXISTING]` `scripts/architecture/http-persistence-boundary.test.mjs`
  - `[PROPOSED]` `scripts/qa/architecture-rules-ast-runner.test.mjs`

#### AUD-0010: Monolithic server bootstrapping and entangled concern registration in apps/api/src/server.ts
- **Affected Modules**: `tfpphotographers/apps/api`
- **File Paths**:
  - `apps/api/src/server.ts:1-790`
- **Evidence**: `server.ts` spans exactly 790 lines and entangles Fastify instance creation, Helmet security header policies, CORS validation, rate limiting, OpenTelemetry instrumentation, Prometheus metrics scrapers, Sentry error interceptors, in-memory cache binding, Prisma lifecycle hooks, and manual route registration into a single function. Fastify's native plugin architecture (`fastify.register` via `fastify-plugin`) is underutilized.
- **Recommended Action**: Decompose `server.ts` into discrete, encapsulated Fastify plugins (e.g. `securityPlugin`, `telemetryPlugin`, `cachePlugin`, `databasePlugin`). Avoid arbitrary line-count targets; focus on single-responsibility plugin modules and strictly preserve lifecycle registration order:
  1. Telemetry & OpenTelemetry tracing hooks
  2. Security headers (Helmet) & CORS
  3. Authentication & JWT decoding
  4. Rate limiting & Request caching
  5. Domain route registrations
  6. Global error and not-found handlers
- **Risk & Constraints**: Medium risk. Plugin registration order must be preserved to prevent security header omission or error trapping regressions.
- **Required Verification Tests**:
  - `[EXISTING]` `apps/api/tests/server-bootstrap.test.ts`
  - `[PROPOSED]` `apps/api/tests/plugins/plugin-lifecycle-order.test.ts`

#### AUD-0011: Handwritten ES5 duplication of Raw Policy AST Parser and Evaluator in tfp-moderation-service
- **Affected Modules**: `tfp-moderation-service`, `tfpphotographers/packages/moderation`
- **File Paths**:
  - `tfp-moderation-service/src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js:650-980`
  - `tfpphotographers/packages/moderation/src/raw-policy/runtime.ts:1-320`
  - `tfpphotographers/packages/moderation/src/raw-policy/parser.ts`
  - `tfpphotographers/packages/moderation/src/raw-policy/evaluator.ts`
- **Evidence**: `browser_policy_evaluator_toolkit.js` is a handwritten 1,236-line ES5 JavaScript file embedded into moderation HTML audit reports. Lines 650-980 duplicate the recursive descent AST tokenizer, parser (`parseOr`, `parseAnd`, `parseComparison`, `parseUnary`, `parsePrimary`), and runtime evaluator from `packages/moderation/src/raw-policy/runtime.ts`. There is no build pipeline, code generator, or synchronization mechanism connecting the two.
- **Recommended Action**: Configure a bundle step (using `esbuild` or `rollup`) to compile `packages/moderation/src/raw-policy/runtime.ts` into a standalone browser IIFE script. Copy or publish this compiled bundle into `tfp-moderation-service/static/`, retiring the handwritten ES5 script.
- **Risk & Constraints**: Low risk. The compiled bundle must be self-contained and run in browser environments without external module loaders.
- **Required Verification Tests**:
  - `[EXISTING]` `packages/moderation/tests/raw-policy-runtime.test.ts`
  - `[PROPOSED]` `tfp-moderation-service/tests/browser_toolkit_bundle_parity.test.py`

#### AUD-0012: Direct shared-database outbox and entity table coupling in tfp-ai-interface worker
- **Affected Modules**: `tfp-ai-interface`, `tfpphotographers/packages/database`
- **File Paths**:
  - `tfp-ai-interface/src/tfp_ai_interface/worker_repository.py:1-320`
- **Evidence**: `tfp_ai_interface/worker_repository.py` connects directly to the central PostgreSQL database using Python `psycopg` 3.x and `psycopg_pool.ConnectionPool`. It queries `event_outbox` directly using raw SQL with `FOR UPDATE SKIP LOCKED` row locking. Furthermore, it executes direct raw SQL queries against 7 monorepo domain entity tables (`opportunities`, `events`, `contests`, `users`, `quick_requests`, `contest_submissions`, `portfolio_images`) to enrich AI prompts, completely bypassing the Fastify API.
- **Recommended Action**: 
  - *Short-Term*: Introduce automated cross-repository schema contract tests in CI to verify that Prisma migrations in `tfpphotographers` do not rename or delete columns queried by `tfp-ai-interface`.
  - *Long-Term*: Enrich `event_outbox` payloads with the necessary domain context at dispatch time in the API, or expose authenticated internal API endpoints for entity enrichment queries, removing the need for `tfp-ai-interface` to query monorepo domain tables directly.
- **Risk & Constraints**: High architectural importance. Concurrency semantics (`FOR UPDATE SKIP LOCKED`) and at-least-once delivery must be preserved.
- **Required Verification Tests**:
  - `[EXISTING]` `tfp-ai-interface/tests/test_worker_repository.py`
  - `[PROPOSED]` `tests/contracts/ai-interface-schema-parity.contract.test.ts`

---

## 5. Good Architecture & Strengths to Preserve

The audit identified significant architectural strengths and sound engineering patterns that must be safeguarded during any refactoring:

### 5.1 Strict Transactional Outbox Pattern
The transactional event outbox implementation is exemplary. Mutations and outbox event insertions share the exact same `tx` client in `prisma.$transaction`. Outbox workers use PostgreSQL row-level locks via `FOR UPDATE SKIP LOCKED`, preventing competing instances from processing duplicate events while maintaining high throughput.

### 5.2 Clean Frontend / Backend Boundary Separation
The boundary between the Astro Web application (`apps/web`) and the Fastify API (`apps/api`) is strictly enforced:
- **Zero Database Leaks**: The Astro application does NOT import `@prisma/client` or `@tfp/database`. All data fetching occurs via HTTP API endpoints or server-side fetch wrappers.
- **Zero Private Secret Leaks**: Database connection strings, JWT private keys, and storage provider credentials are completely isolated from client bundles.

### 5.3 Storage Gateway Abstraction
`packages/storage` provides a well-designed multi-provider gateway (`StoragePort`, `StorageGateway`) that cleanly encapsulates Backblaze B2, Cloudflare R2, AWS S3, and local filesystem storage behind a unified interface. Business logic never references vendor-specific SDKs directly.

### 5.4 Strict Domain Event Validation
`packages/shared/src/eventBus.ts` validates all event payloads against Zod schemas (`DomainEventSchemas`) prior to persisting them into the outbox. Crucially, Zod error messages are sanitized before being written to outbox error logs, preventing PII or sensitive payload values from leaking into operational logs.

### 5.5 Mobile Clean Architecture
`apps/mobile` strictly adheres to Clean Architecture boundaries:
- `domain/` contains pure entities and value objects with zero dependencies on React, Expo, or infrastructure libraries.
- `application/` contains use cases and coordinators that depend only on domain interfaces.
- `presentation/` and `infrastructure/` adapt UI and HTTP networking without leaking UI concepts into the core domain.

---

## 6. Actionable Implementation Backlog & Verification Standards

To ensure safe, non-regressive execution, the findings are organized into a phased implementation plan:

```
Phase 1: Safe Dead Code Pruning (Zero Behavioral Risk)
  ├── Step 1.1: Retire 9 uncalled concrete repositories & update factory in packages/database (AUD-0003)
  ├── Step 1.2: Retire unused createInMemoryRateLimiter in packages/database (AUD-0004)
  └── Step 1.3: Consolidate Astro redirect stubs into astro.config.mjs (AUD-0007)

Phase 2: Code Duplication Consolidation (Low Risk)
  ├── Step 2.1: Consolidate CloudflareMediaPurger into shared package (AUD-0001)
  ├── Step 2.2: Consolidate magic-byte MIME detection in packages/uploads (AUD-0002)
  ├── Step 2.3: Consolidate appeal commands & fix moderation route import (AUD-0008)
  └── Step 2.4: Bundle TypeScript raw-policy runtime for moderation browser toolkit (AUD-0011)

Phase 3: Architecture Decoupling & Structural Refactoring (Medium Risk)
  ├── Step 3.1: Define domain persistence ports for User, OAuthAccount, and UserViolation (AUD-0003)
  ├── Step 3.2: Move in-memory cache adapter out of packages/database (AUD-0004)
  ├── Step 3.3: Refactor architecture test relative traversals (AUD-0009)
  ├── Step 3.4: Decompose server.ts into discrete Fastify plugins (AUD-0010)
  └── Step 3.5: CI schema verification & outbox payload enrichment for AI worker (AUD-0012)

Phase 4: Deep Refactoring & Empirical Profiling (High Impact / Controlled Risk)
  ├── Step 4.1: Empirical profiling & lazy catalog loading in packages/i18n (AUD-0005)
  └── Step 4.2: Golden-master testing & service decomposition of ImageDerivedSignalBuilder (AUD-0006)
```

### Verification & Testing Standards
1. **Zero Downtime Database Refactoring**: Any changes to persistence interfaces must verify that `prisma.$transaction(async (tx) => ...)` continues to cover both domain entity updates and `event_outbox` insertions in the same transaction.
2. **Behavior-Preservation Guarantees**:
    - MIME detection must preserve `byteLength < 4` safety and prevent PDFs from passing image-only validation.
    - Sentry, Helmet, and CORS hook execution order in `apps/api/src/server.ts` must remain invariant.
    - Moderation scoring in `ImageDerivedSignalBuilder` must pass golden-master comparison tests (`eval_192_moderation_service.py`).
3. **Read-Only Verification Grounding**: All findings and observations in this audit represent verified static code realities. Unexecuted runtime behaviors and empirical performance metrics are explicitly documented as implementation-phase testing requirements.

---

*Report compiled and certified by Gemini Principal Software Architect & Code Quality Auditor.*  
*Artifacts ledger, module review records, candidate dispositions, and structured findings stream available in `gemini_readonly_audit/`.*
