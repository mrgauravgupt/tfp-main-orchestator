# System Module Map and Architecture Boundaries

## 1. System Overview and Topology

The TFP platform consists of a central monorepo (`tfpphotographers`), four auxiliary microservices, and an orchestrator root coordinating deployment, QA, and shared cross-service contracts.

```
                              ┌────────────────────────────────────────┐
                              │           Orchestrator Root            │
                              │   (contracts, scripts, qa, CI/CD)      │
                              └───────────────────┬────────────────────┘
                                                  │
                 ┌────────────────────────────────┴────────────────────────────────┐
                 │                                                                 │
┌────────────────▼────────────────┐                             ┌──────────────────▼──────────────────┐
│        tfpphotographers         │                             │         Compute Microservices       │
│  ┌───────────────────────────┐  │                             │  ┌───────────────────────────────┐  │
│  │ apps/web (Astro SSR/UI)   │  │                             │  │ tfp-collage-service (Node.js) │  │
│  ├───────────────────────────┤  │    HTTP API / Outbox Events │  ├───────────────────────────────┤  │
│  │ apps/api (Fastify API)    │◄─┼─────────────────────────────┼─►│ tfp-moderation-service (Py)   │  │
│  ├───────────────────────────┤  │                             │  ├───────────────────────────────┤  │
│  │ apps/mobile (Expo RN)     │  │                             │  │ tfp-ai-interface (Py)         │  │
│  ├───────────────────────────┤  │                             │  ├───────────────────────────────┤  │
│  │ packages/* (Shared Libs)  │  │                             │  │ tfp-inhouse-moderation (Py)   │  │
│  └───────────────────────────┘  │                             │  └───────────────────────────────┘  │
└─────────────────────────────────┘                             └─────────────────────────────────────┘
```

---

## 2. Monorepo Core (`tfpphotographers`)

### 2.1 Backend API (`apps/api`)
- **Technology**: Fastify, TypeScript, Prisma ORM, PostgreSQL.
- **Entry Points**:
  - HTTP Server: `apps/api/src/server.ts`, `apps/api/src/app.ts`
  - Routes Registry: `apps/api/src/routes.ts`
  - Background Workers: `apps/api/src/worker.ts`, `apps/api/src/background/event-outbox.ts`
- **Domain Modules (`apps/api/src/modules/`)**:
  - `admin`, `auth`, `contest`, `event`, `legal`, `location`, `media`, `message`, `moderation`, `notifications`, `opportunity`, `quick-request`, `redirect`, `referral`, `report`, `search`, `telemetry`, `translation`, `upload`, `user`.
- **Data Ownership**: Primary PostgreSQL database schema (`event_outbox`, `users`, `profiles`, `contests`, `media`, `messages`, `sessions`, `consents`, etc.).

### 2.2 Web Application (`apps/web`)
- **Technology**: Astro (Hybrid SSR and static generation), React (interactive islands), Tailwind CSS / SCSS.
- **Entry Points**: Astro page routes under `apps/web/src/pages/`.
- **Structure**:
  - `components/`: UI elements (navigation, modals, buttons, forms).
  - `features/`: Complex domain widgets (contest gallery, search filters, profile editor).
  - `layouts/`: Master layouts (Base, Dashboard, Marketing, Auth).
  - `scripts/`: Client-side hydration scripts and event listeners.
  - `styles/`: CSS modules, SCSS variables, design tokens.
  - `utils/`: Client-side fetch wrappers, date formatting, storage helpers.

### 2.3 Mobile Application (`apps/mobile`)
- **Technology**: React Native, Expo, TypeScript, Maestro for E2E.
- **Architecture**: Domain-Driven / Clean Architecture:
  - `src/application/`: App coordinators, use cases, local state stores.
  - `src/domain/`: Entities, value objects, domain error types.
  - `src/infrastructure/`: Secure storage, HTTP API client, telemetry adapters.
  - `src/presentation/`: Screens, design system primitives, navigation navigators.
  - `__tests__/`: Component and unit test mocks and fixtures.

### 2.4 Shared Packages (`packages/*`)
- `packages/config`: Type-safe environment variable parsing (`zod`) for dev, test, and production.
- `packages/database`: Prisma schema (`schema.prisma`), generated client, migration scripts, soft-delete extension, transactional outbox primitives.
- `packages/email`: Transactional email templates, HTML compiler, Resend and Console adapters.
- `packages/i18n`: 95 locale translation dictionaries, RTL utilities, language negotiation.
- `packages/moderation`: Moderation upload port, raw-policy AST tokenizer, parser, and runtime evaluator.
- `packages/shared`: Universal types, DTO contracts, validation schemas, utility functions.
- `packages/storage`: Multi-provider file storage abstractions (Local disk, S3-compatible, Cloudflare R2).
- `packages/uploads`: Image processing, dimension calculation, and file validation.

---

## 3. Dedicated Microservices

### 3.1 `tfp-collage-service`
- **Technology**: Node.js / TypeScript, Sharp, Fastify.
- **Responsibility**: Dynamic image composite generation, grid stitching, and thumbnail generation.
- **Boundary**: HTTP endpoints receiving image URLs/buffers and returning composite binary images.

### 3.2 `tfp-moderation-service`
- **Technology**: Python 3.12, FastAPI, PyTorch, YOLO, CLIP, NudeNet, Marqo, SigLIP.
- **Responsibility**: AI inference and multi-stage policy evaluation for uploaded imagery (nudity detection, adult content, explicit semantics).
- **Boundary**: REST API consuming image bytes or signed URLs, producing `rawEnvelope` AI inference metrics and rule outcomes (`APPROVED`, `REJECTED`, `FLAGGED`).

### 3.3 `tfp-ai-interface`
- **Technology**: Python 3.12, FastAPI, `psycopg` 3.x / `psycopg_pool.ConnectionPool`.
- **Responsibility**: AI inference pipeline and background worker consuming from the shared PostgreSQL outbox.
- **Boundary**: REST API for prompts and worker background service querying `event_outbox` and 7 monorepo domain tables.

### 3.4 `tfp-inhouse-moderation`
- **Technology**: Python 3.12, PyTorch / HuggingFace Transformers, FastAPI.
- **Responsibility**: Local computer vision models (NudeNet, Viddexa, YOLO) for in-house content classification and policy scoring.
- **Boundary**: REST API exposing `/v1/analyze` and `/v1/policy/evaluate`.

---

## 4. Orchestrator and Cross-Service Contracts
- `contracts/`: JSON schemas, OpenAPI specifications, and event payload contracts shared across services.
- `scripts/`: Dev runners, database supervision, environment validators, deploy scripts.
- `qa/`: End-to-end integration test suites running across Web, API, and microservices.

---

## 5. Formal Module Review Manifest (17 Records)

The 2,905 included repository files are fully mapped across exactly 17 dedicated module review records in `gemini_readonly_audit/modules/`, directly reconciled with `gemini_readonly_audit/file_inventory.csv`:

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
