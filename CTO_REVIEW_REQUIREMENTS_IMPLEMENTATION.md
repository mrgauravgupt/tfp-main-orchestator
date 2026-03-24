# TFP Photographers Platform - Complete Technical Review for CTO

## 1. Executive Summary
This document captures the current implementation of the TFP platform in `/Users/hexa/Desktop/tfp-latest/tfp-workspace`, including architecture, standards compliance, security, storage, SEO, accessibility, i18n/locale detection, and end-to-end validation.

Current status:
- Application boots successfully (API + Web SSR).
- Home page returns `200 OK`.
- Moderation and authorization workflow implemented and verified.
- Progressive enhancement (JS-enabled and JS-disabled paths) implemented and verified.
- End-to-end Playwright suite passing: `7/7`.

---

## 2. Monorepo Architecture and Folder Structure

## 2.1 Workspace model
- Package manager: `pnpm` workspaces (`pnpm-workspace.yaml`).
- Root orchestrates app-level scripts, tests, and build tasks.

Key top-level structure:
- `apps/api` - Fastify API (modular domain routes + command/query split in key domains)
- `apps/web` - Astro SSR frontend (component-based)
- `packages/config` - centralized runtime/environment/config constants (SSOT)
- `packages/database` - Prisma schema + singleton Prisma client + soft-delete middleware
- `packages/storage` - storage port + adapters (local/backblaze) + ImageKit URL helper
- `packages/i18n` - translation runtime + `en_US.json` master locale
- `packages/shared` - backend EventBus abstraction (typed domain events)

## 2.2 Backend structure
Inside `apps/api/src`:
- `server.ts` - Fastify app bootstrap, plugins, decorators, routes, error handler
- `plugins/auth.ts` - auth and identity extraction
- `modules/contest/*` - contest commands/queries/routes
- `modules/project/*` - project commands/queries/routes
- `modules/event/*` - event routes
- `modules/user/*` - user/profile routes
- `types/fastify.d.ts` - typed Fastify instance decorators

## 2.3 Frontend structure
Inside `apps/web/src`:
- `layouts/BaseLayout.astro` - global shell, SEO base metadata, JSON-LD website schema, nav/footer
- `components/*` - reusable component library (`Button`, `TextInput`, `TextArea`, `Badge`, `AuthModal`, etc.)
- `pages/*` - SSR routes (auth, listings, detail pages, create flows, legal pages)
- `styles/*` - tokens and shared styles
- `middleware.ts` - locale/location detection and request context enrichment

---

## 3. Core Technical Patterns Implemented

## 3.1 SSOT (Single Source of Truth)
- Environment/config constants centralized in `packages/config/src/index.ts`.
- i18n master locale centralized in `packages/i18n/src/locales/en_US.json`.
- Translation helper centralized in `packages/i18n/src/index.ts`.
- Storage provider switching centralized in `packages/storage/src/index.ts`.
- API base URL resolver centralized in `apps/web/src/utils/api.ts`.

## 3.2 Hexagonal/Adapter style for storage
- Port: `IStorageService` in `packages/storage/src/interfaces.ts`.
- Adapters:
  - `LocalAdapter` (filesystem storage for dev)
  - `BackblazeB2Adapter` (S3-compatible production adapter)
- Runtime selection through factory: `getStorageService()` using `STORAGE_PROVIDER` from config.
- CDN delivery path helper via ImageKit transform URL builder in `imagekit.helpers.ts`.

## 3.3 EventBus integration
- Added typed backend event bus in `packages/shared/src/eventBus.ts`.
- Injected into API as `app.eventBus` in `apps/api/src/server.ts`.
- Moderation events emitted on approval:
  - `contest.approved`
  - `project.approved`
  - `event.approved`
- Server-level listeners currently log and centralize side-effect points (email/webhook integrations can attach here without changing domain routes).

## 3.4 CQRS-aligned domain layering
- Contest and project modules use command/query split for write/read responsibilities.
- Route handlers delegate to query/command handlers where implemented.

---

## 4. Backend Implementation Details

## 4.1 API runtime and middleware pipeline
`apps/api/src/server.ts` registers:
- CORS (`@fastify/cors`)
- Cookies (`@fastify/cookie`)
- JWT (`@fastify/jwt`)
- Multipart upload (`@fastify/multipart`)
- Static uploads serving (`/uploads/*`)
- Domain routes under `API_PREFIX=/api/v1`

## 4.2 Authentication and identity
- Login/registration/logout/me endpoints in `plugins/auth.ts`.
- JWT issued and stored in HTTP-only cookie (`token`).
- Identity extracted in `onRequest` hook to `request.userId` and `request.userRole`.
- Protected actions validate these values at route level.

## 4.3 Moderation and authorization hardening
Implemented restrictions:
- Only admins can patch moderation status for contests/projects/events.
- Non-admin access to non-public status listing (e.g., `?status=PENDING`) is denied (`403`).
- Detail endpoints for pending content return `404` unless requester is owner or admin.

## 4.4 Contest constraints
- Duplicate submission blocked (unique `(contestId,userId)` + route-level mapping to conflict semantics).
- Contest creator cannot submit to own contest.
- Non-multipart submission validation normalized.

## 4.5 Project constraints
- Self-application blocked (UX + API behavior).
- Consent fields enforced on application path.
- Moodboard images accepted and persisted.

## 4.6 Database layer and schema
- Prisma schema at `packages/database/prisma/schema.prisma`.
- Includes all Phase entities with indexes and constraints:
  - User, PortfolioImage, Contest, ContestPrize, ContestSubmission
  - Project, ProjectRole, ProjectApplication
  - Event, EventRSVP
- Composite unique constraints for one-per-user submissions/applications where required.
- Soft delete fields present on core models (`deletedAt`).

## 4.7 Prisma singleton and soft-delete middleware
- Global singleton Prisma client in `packages/database/src/index.ts`.
- Middleware auto-injects `deletedAt: null` for key `findUnique/findMany` operations.

---

## 5. Frontend Implementation Details

## 5.1 SSR-first with progressive enhancement
- All key forms work via SSR-native POST (no JS dependency required).
- JS runtime (`apps/web/public/js/ui.js`) enhances behavior:
  - Mobile nav toggles
  - Dialog modal open/close
  - Auth tab switch
  - File upload previews
- Added runtime stabilization to close stale opened dialogs on init, preventing pointer interception bugs across routes.

## 5.2 Auth flow behavior
- JS enabled:
  - Sign-in link can open glassmorphic auth `<dialog>`.
- JS disabled:
  - Sign-in follows link to `/login` fallback page.
  - Native HTML form POST login flow works.

## 5.3 Component architecture
- Reusable components (`Button`, `TextInput`, `TextArea`, `Badge`, etc.) are used across pages.
- Shared layout and design primitives reduce duplication.

## 5.4 Styling system
- SCSS token injection configured globally in Astro config.
- Consistent token-driven styling in components/pages.
- Global layout and base styles centralized.

---

## 6. i18n and Locale/Location Detection

## 6.1 i18n
- Master locale file: `packages/i18n/src/locales/en_US.json`.
- Translation helper `t()` used across pages and components.
- Missing keys addressed in this phase where surfaced.

## 6.2 Locale detection (implemented)
Added request middleware (`apps/web/src/middleware.ts`) that:
- Reads locale from cookie (`locale`) if present.
- Falls back to `Accept-Language` via `detectLocale()`.
- Sets `Astro.locals.locale` for SSR use.
- Persists locale cookie if absent.
- Adds response header `x-app-locale`.

## 6.3 Cloudflare location header support (implemented)
Middleware also reads:
- `CF-IPCountry`
- `CF-Region`
- `CF-City`

Then sets `Astro.locals.location = { country, region, city, source }` for SSR templates/services.

---

## 7. Storage and Media Strategy

## 7.1 Storage adapters
- `LocalAdapter`: local filesystem, `/uploads` delivery path.
- `BackblazeB2Adapter`: S3-compatible cloud object storage with signed credentials.

## 7.2 Provider switching
- Controlled by `STORAGE_PROVIDER` in centralized config.
- No domain code changes required when switching provider.

## 7.3 CDN delivery
- ImageKit URL builder provides transformed delivery URLs (`thumb/small/medium/large`) for optimized media rendering paths.

## 7.4 EXIF extraction
- Both storage adapters expose EXIF extraction method via `sharp` (`extractExif`).

---

## 8. SEO Implementation

Implemented:
- Canonical URL per page in `BaseLayout.astro`.
- Open Graph + Twitter card base tags.
- Base JSON-LD (`WebSite`) script in layout.
- Sitemap integration present in Astro config and controlled by env flag (`GENERATE_SITEMAP=true`).

Notes:
- Dynamic page-level schema (ImageGallery/Photograph for all detail pages) is not fully comprehensive yet and can be added incrementally page-by-page.

---

## 9. Accessibility (A11Y) Implementation

Implemented:
- Skip link to main content.
- Semantic structure with nav/main/footer landmarks.
- Form labels and required states on inputs.
- Error/status messaging using ARIA roles (`role="alert"`, `role="status"`).
- Accessible control labels on modal/menu buttons.
- Mobile navigation ARIA attributes (`aria-expanded`, `aria-controls`).

Notes:
- Baseline accessibility is in place; an additional axe-core audit pass can be layered for exhaustive WCAG conformance checks.

---

## 10. Security and Authorization Validation

Validated controls:
- Unauthorized moderation actions blocked.
- Unauthorized access to pending resources blocked.
- Duplicate and prohibited actions blocked by API logic.
- Auth cookies set HTTP-only and same-site.
- Zod-based payload validation used on protected create/apply endpoints.

---

## 11. End-to-End Testing and QA Evidence

## 11.1 Playwright setup
- `playwright.config.ts` orchestrates both API and Web servers.
- `global.setup.ts` resets DB and seeds deterministic test users.

Seeded users used in automated testing:
- `admin@tfp.local / Admin123!`
- `photo@tfp.local / Photo123!`
- `model@tfp.local / Model123!`

## 11.2 E2E scenarios implemented and passing
1. `scenario-a-auth.spec.ts` - authentication and profile behavior
2. `scenario-b-contests.spec.ts` - contest create/approve/submit + one-time constraint
3. `scenario-c-projects.spec.ts` - project create/approve + owner block + external apply
4. `scenario-d-progressive.spec.ts` - JS-disabled sign-in fallback flow
5. `scenario-e-moderation-authz.spec.ts` - cross-domain moderation + authz attack checks
6. `scenario-f-events.spec.ts` - event create/approve/public visibility flow
7. `scenario-g-page-smoke.spec.ts` - public pages return `200` and render

Result:
- `7 passed` (latest run)

---

## 12. Deployment/Operations Readiness

Implemented foundation:
- API and Web independently runnable.
- Environment-driven configuration is centralized.
- Storage providers swappable via env.
- Prisma schema and client centralized.
- Health routes available.

Operational recommendations (next hardening pass):
- Add CI pipeline gates for lint/typecheck/e2e before merge.
- Add structured audit log sink for moderation events.
- Add rate limiting and stricter auth middleware separation for public vs protected route groups.
- Add production alerting and dashboarding for failed auth/moderation attempts.

---

## 13. Final Verification Snapshot
- App startup: PASS
- Root/home status: PASS (`200`)
- Contest approval lifecycle: PASS
- Project approval lifecycle: PASS
- Event approval lifecycle: PASS
- Public visibility gate before/after approval: PASS
- JS-disabled auth fallback: PASS
- E2E status: PASS (`7/7`)

