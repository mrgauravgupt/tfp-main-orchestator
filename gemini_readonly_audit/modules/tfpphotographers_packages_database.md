# Module Review: `tfpphotographers/packages/database`

## 1. Module Overview
- **Path**: `tfpphotographers/packages/database`
- **Purpose**: PostgreSQL database client, Prisma ORM schema and migrations, transactional outbox primitives, and persistence error mappings.
- **File Count**: 45 files (11,963 lines) across Prisma schema, migration scripts, adapters, repository classes, and unit tests.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Primary Client: `prisma`, `ExtendedPrismaClient`, `disconnect` (`src/index.ts`).
- Extensions: `softDeleteExtension`, `urlCriticalNormalizationExtension` (`src/url-critical-normalization.ts`).
- Outbox Adapters: `enqueueOutboxEntry`, `claimPendingOutboxRows`, `markOutboxEntryCompleted`, `markOutboxEntryFailed`, `deferOutboxEntry` (`src/adapters/outbox-shared.ts`).
- Repositories: `createRepositories`, `IRepositories`, `executeRepositoryWrite`, `PersistenceConflictError` (`src/repositories/*`).
- Adapters: `createInMemoryCache` (`src/adapters/cache.adapter.ts`), `createInMemoryRateLimiter` (`src/adapters/rate-limiter.adapter.ts`), `createSourceDeletionPort`.

## 3. Architecture & Internal Responsibilities
- **Singleton Pattern**: Managed global instance for development hot-reloading.
- **Soft Delete Enforcement & Operation Matrix**:
  - Global `$extends` query hook (`softDeleteExtension`) intercepts queries on 11 domain models:
    - **Intercepted Root Operations**: `findUnique`, `findUniqueOrThrow`, `findFirst`, `findFirstOrThrow`, `findMany`, `count`, `aggregate`, and `groupBy`. Appends `where: { deletedAt: null }` unless a `deletedAt` filter key is explicitly supplied.
    - **Relation Joins (`include:`, `select:`)**: **NOT** intercepted. Queries including relations return soft-deleted child entities unless explicit `where: { deletedAt: null }` filters are attached to the relation selection.
    - **Raw SQL (`$queryRaw`, `$executeRaw`)**: **NOT** intercepted. Bypasses client extensions entirely.
    - **Mutations (`delete`, `deleteMany`)**: **NOT** intercepted. These execute physical SQL `DELETE` statements. Soft-deletion requires executing explicit `update` or `updateMany` setting `deletedAt: new Date()`.
- **Transactional Outbox Mechanics**: Implements row-level locking via PostgreSQL `SELECT ... FOR UPDATE SKIP LOCKED` with exponential backoff and dead-letter handling.

## 4. Observed Strengths
- **Resilient Concurrency**: The outbox worker claiming logic (`claimPendingOutboxRows`) is fully transactional and supports monotonic claim timestamps and lease recovery.
- **Sanitized Logging**: Intercepts Prisma engine events (`baseClient.$on`) and redacts query parameters to prevent database credentials or customer data from leaking into server logs.

## 5. Identified Deficiencies & Findings
- **Abandoned Repository Pattern Layer & Factory Coupling (AUD-0003)**:
  - 12 concrete repository classes under `src/repositories/` (`contest.repository.ts`, `opportunity.repository.ts`, `event.repository.ts`, `message.repository.ts`, etc.) plus `base.repository.ts` are almost completely uncalled by the application layer.
  - The API modules bypass these classes and query Prisma directly via CQRS Command/Query objects.
  - The repository classes manually duplicate `{ deletedAt: null }` checks already handled by Prisma's `softDeleteExtension`.
  - **Coupling Warning**: Repositories are orchestrated by `createRepositories(prisma)` and typed by `IRepositories` in `src/repositories/index.ts`. In `apps/api/src/application/runtime-services.ts`, `createRepositories(prisma)` is instantiated and attached to `app.decorate('repositories')`. Retirement requires updating this factory boundary rather than deleting repository files in isolation.
- **Misplaced In-Memory Infrastructure (AUD-0004)**:
  - `packages/database/src/adapters/cache.adapter.ts` (`createInMemoryCache`) and `packages/database/src/adapters/rate-limiter.adapter.ts` (`createInMemoryRateLimiter`) are located in `packages/database`. Hosting in-memory state primitives in a database/Prisma package is an incorrect abstraction.
  - `createInMemoryCache` is imported in `apps/api/src/server.ts:522`.
  - `createInMemoryRateLimiter` has ZERO callers across the entire repository.
- **Unsafe Cast in Client Initialization**:
  - `src/index.ts:116`: `.$extends(...) as unknown as PrismaClient` overrides TypeScript safety because Prisma client extension types do not strictly match the base `PrismaClient` interface.

## 6. Review Status
- **Tool Scan**: COMPLETED (lexical rolling window and regex scanner executed across all 45 files).
- **AI Review**: REVIEWED (in-depth review of extensions, outbox locking, repository factory, and adapter exports).
- **Cross-Module Comparison**: COMPLETED (cross-checked against API runtime services and command handlers).
