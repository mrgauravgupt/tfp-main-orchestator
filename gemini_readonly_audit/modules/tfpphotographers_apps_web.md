# Module Review: `tfpphotographers/apps/web` (Frontend Web Application)

## 1. Module Overview
- **Path**: `tfpphotographers/apps/web`
- **Purpose**: Server-rendered and statically generated web application built with Astro, React interactive islands, and Tailwind/SCSS design tokens.
- **File Count**: 619 files (100,660 lines) across Astro pages, React islands, layout templates, styling tokens, utilities, and tests.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Page Routes: File-based routing under `apps/web/src/pages/` (`index.astro`, `login.astro`, `contests/*.astro`, `opportunities/*.astro`, etc.).
- UI Components: Reusable Astro/React components in `apps/web/src/components/`.
- Client Utilities: `apps/web/src/utils/api-fetch.ts`, `apps/web/src/utils/routing.ts`, `apps/web/src/utils/current-user.ts`.

## 3. Architecture & Internal Responsibilities
- **Astro Islands Architecture**: Pages are statically rendered or SSR-generated on the server; client-side React components hydrate only when interactivity is needed (`client:load`, `client:visible`).
- **Decoupled API Integration**: Communicates with Fastify API strictly over HTTP fetch (`src/utils/api-fetch.ts`) with timeout signals, request correlation tracking, and localized response mapping.
- **SSR Authentication Bridge**: Astro middleware inspects session cookies and extracts authenticated user context to populate SSR page props.

## 4. Observed Strengths
- **Clean Decoupling from Database**: Astro frontend does not import Prisma or database credentials; all data mutations and queries route cleanly through the Fastify API.
- **Robust Client Telemetry**: `telemetry-bootstrap.ts` and `telemetry.client.ts` handle client errors and unhandled promise rejections, reporting sanitized diagnostic payloads to the API.

## 5. Identified Deficiencies & Findings
- **Exact Duplicate Page Redirects (AUD-0007)**:
  - `src/pages/forgot-password.astro` and `src/pages/reset-password.astro` are 100% byte-for-byte identical (SHA-256 `327cc44c0ab2...`).
  - Both execute `return Astro.redirect(localizePathWithQuery('/login', Astro.url.searchParams), 302);`.
  - While harmless redirects, maintaining duplicate stub pages increases maintenance clutter.
- **Duplicate Utility Implementations**:
  - `src/utils/format.ts:10` implements `formatDate` independently of `packages/i18n/src/index.ts:231`.
  - `src/utils/admin-formatters.ts:498` implements `formatRelativeTime` independently of `packages/shared/src/formatters.ts:53`.
  - `src/scripts/client/telemetry-bootstrap.ts:26` and `src/scripts/telemetry.client.ts:221` duplicate `isNavigationAbortError`.

## 6. Review Status
- **Tool Scan**: COMPLETED (lexical rolling window and regex symbol scanner executed across all 619 files).
- **AI Review**: REVIEWED (in-depth review of Astro page components, client hydration islands, API client layer, and telemetry bootstrap).
- **Cross-Module Comparison**: COMPLETED (compared against `packages/shared`, `packages/i18n`, and mobile client API adapters).
