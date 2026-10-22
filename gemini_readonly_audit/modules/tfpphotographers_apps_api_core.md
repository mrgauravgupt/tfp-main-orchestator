# Module Review: `tfpphotographers/apps/api` (Core Infrastructure & Server)

## 1. Module Overview
- **Path**: `tfpphotographers/apps/api` (Server, Background Workers, Application Initialization)
- **Purpose**: Backend REST API server built on Fastify, orchestrating HTTP routing, authentication plugins, security headers, background queue processing, and event dispatching.
- **File Count**: 275 files assigned to this core review record (43,660 lines; the total API package comprises 592 files / 94,619 lines, split between core infrastructure and 20 vertical domain modules).
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Entrypoint: `apps/api/src/server.ts` (`buildServer`, `startServer`).
- Worker Entrypoint: `apps/api/src/worker.ts` (`startBackgroundWorkers`).
- Runtime Composition: `apps/api/src/application/runtime-services.ts` (`createRuntimeServices`).
- Background Handlers: `apps/api/src/background/event-outbox.ts`, `apps/api/src/background/background-jobs.ts`.

## 3. Architecture & Internal Responsibilities
- **Plugin Architecture**: Fastify plugins encapsulate CORS, Helmet security headers, cookie parsing, JWT authentication, and rate limiting.
- **Service Decoration**: Injects singletons (`prisma`, `storage`, `mediaStorage`, `eventBus`, `cacheProvider`, `repositories`) onto the Fastify instance via `app.decorate()`.
- **Root Error Boundary**: `app.setErrorHandler` standardizes responses, redacting internal 5xx details while formatting client 4xx validation errors and capturing Sentry exceptions.
- **Worker Isolation**: Standalone worker process (`worker.ts`) executes transactional outbox consumers and background jobs without degrading HTTP request thread responsiveness.

## 4. Observed Strengths
- **Strict Error Redaction**: Production 5xx errors return masked messages (`translateRequest(request, 'errors.server_error_desc')`) while preserving correlated tracing IDs.
- **Atomic Job Lease Claims**: Outbox processor relies on PostgreSQL `FOR UPDATE SKIP LOCKED` with explicit 5-minute timeout recovery for crashed workers.
- **Graceful Shutdown**: Catches `SIGTERM` / `SIGINT` signals and cleanly drains active event listeners and background worker loops.

## 5. Identified Deficiencies & Findings
- **Monolithic `server.ts` File (AUD-0010)**:
  - `server.ts` is exactly **790 lines long**, combining HTTP server bootstrapping, Fastify plugin registration, route attachment, decorator initialization, telemetry setup, error boundary definition, and health route binding in a single continuous script.
  - Sub-concerns (e.g. error handling, service decoration, security plugins) should be factored into modular Fastify plugin files under `src/plugins/`.
- **Outbox Concurrency & Non-Transactional Notification Emission**:
  - `tfpphotographers/apps/api/src/modules/notifications/NotificationService.ts`: `EventBusNotificationService` calls `this.eventBus.emit(...)`.
  - In `apps/api/src/application/runtime-services.ts`, `eventBus` is instantiated as `getEventBus(createEventOutboxAdapter(input.prisma))`, which binds to the root `prisma` client rather than an active transaction client (`tx`).
  - As a result, notification events are written directly to `event_outbox` outside parent business transactions. If the surrounding database transaction rolls back, or conversely if outbox insertion fails, state updates and event emission can diverge.
  - **Delivery Semantics**: While PostgreSQL `FOR UPDATE SKIP LOCKED` provides strict row-level lock exclusion across worker replicas, transactional outbox processing delivers **at-least-once** semantics (crashes prior to updating `processedAt` trigger redelivery after lease expiry), requiring strictly idempotent event consumers.

## 6. Review Status
- **Tool Scan**: COMPLETED (lexical rolling window and regex scanner executed across all 275 files).
- **AI Review**: REVIEWED (detailed trace of server bootstrap, plugin composition, outbox workers, and notification service).
- **Cross-Module Comparison**: COMPLETED (compared against API domain modules and database outbox adapters).
