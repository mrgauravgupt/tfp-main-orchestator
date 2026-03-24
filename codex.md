# TFP Platform — Comprehensive Validated Audit (`codex.md`)

**Date:** 2026-03-08  
**Scope:** Full repository validation of prior review docs (`sonnet.md`, `opus_guidelines.md`, `opus.md`) + additional deep source verification  
**Method:** Every item below is grounded in current code with file+line proof.

---

## 1) Validated Findings (Confirmed)

## 1.1 Critical

- **CSP is explicitly disabled** (`helmet` configured with `contentSecurityPolicy: false`).  
  **Proof:** `apps/api/src/server.ts:83-86`

- **JWT cookie wrapper is unsigned** (`signed: false`).  
  **Proof:** `apps/api/src/server.ts:107-110`

- **Long-lived auth defaults** (JWT/session default to 180 days).  
  **Proof:** `packages/config/src/index.ts:163-164`

- **No CSRF token mechanism for state-changing routes**; cookies are used and mutating endpoints do not validate CSRF token.  
  **Proof:** cookie-based auth (`apps/api/src/modules/auth/auth.routes.ts:59,101,216`), mutating endpoints with no CSRF verifier across auth/admin/user routes.

- **No `og:image` and no `twitter:image` meta tags** in base SEO head.  
  **Proof:** `apps/web/src/layouts/BaseLayout.astro:220-229`

---

## 1.2 High

- **`/auth/me` re-signs JWT on every call** and resets cookie; layout calls it during SSR, causing token churn.  
  **Proof:** `apps/api/src/modules/auth/auth.routes.ts:215-216`, `apps/web/src/layouts/BaseLayout.astro:67-75`

- **Remember-me checkbox has no backend effect** (session `maxAge` is fixed).  
  **Proof:** checkbox UI `apps/web/src/pages/login.astro:110-113`; cookie config `apps/api/src/modules/auth/auth.routes.ts:21-28`

- **CORS allows no-origin requests** (`if (!origin) callback(null, true)`).  
  **Proof:** `apps/api/src/server.ts:64-67`

- **`trustProxy: true` enabled globally** (no in-file proxy trust scoping).  
  **Proof:** `apps/api/src/server.ts:48`

- **Upload/static serving from local API filesystem** (`uploads` folder via `@fastify/static`), not distributed/object delivery.  
  **Proof:** `apps/api/src/server.ts:120-127`

- **Contest creation is quota-gated but not role-gated** (no explicit admin role check in create route).  
  **Proof:** `apps/api/src/modules/contest/contest.routes.ts:428-432`

- **Contest upload endpoints are available to any authenticated user** (`requireAuth` only).  
  **Proof:** `/uploads/banner` `contest.routes.ts:314-316`; `/uploads/resource` `contest.routes.ts:379-381`

- **Location API endpoints are unauthenticated** (quota abuse surface for provider APIs).  
  **Proof:** `apps/api/src/modules/location/location.routes.ts:250-314`

- **Email can be used as public profile lookup key** via user route.  
  **Proof:** `apps/api/src/modules/user/user.routes.ts:104-111`

- **Authenticated SSR layout performs at least two API calls per render** (`/auth/me` + notifications).  
  **Proof:** `apps/web/src/layouts/BaseLayout.astro:67-75,112-119`

- **Dynamic content is missing from sitemap generation** (static list only).  
  **Proof:** `apps/web/src/pages/sitemap.xml.ts:3-15,21-25`

- **`@astrojs/sitemap` installed but not integrated.**  
  **Proof:** dependency `apps/web/package.json:16`; integrations empty `apps/web/astro.config.mjs:10`

- **No `robots.txt` found.**  
  **Proof:** repo glob for `**/robots.txt` returned none under workspace.

- **Public profile URLs expose email path (`/profile/[email]`)**.  
  **Proof:** route file `apps/web/src/pages/profile/[email].astro`

- **Admin moderation page has dual click handlers that both fire on action buttons** (direct moderation call + modal open), causing unintended behavior coupling.  
  **Proof:** handler 1 `[data-action]` `apps/web/src/pages/admin/moderation.astro:244-256`; handler 2 `.pending-card__actions button` `:259-292`

---

## 1.3 Medium

- **Regex-only sanitizer for plain text** (not robust HTML parsing).  
  **Proof:** `apps/api/src/utils/text-sanitize.ts:7-10`

- **Auth middleware does DB lookup on each authenticated request.**  
  **Proof:** `apps/api/src/modules/auth/auth.middleware.ts:42-46`

- **Rate limiting is route-opt-in (`global: false`) and concentrated mostly on auth/reset flows.**  
  **Proof:** `apps/api/src/server.ts:88-96`; auth/reset route configs in `auth.routes.ts`

- **`console.error` used in admin routes instead of structured logger.**  
  **Proof:** `apps/api/src/modules/admin/admin.routes.ts:72,138`

- **In-process singleton EventEmitter event bus (non-distributed).**  
  **Proof:** `packages/shared/src/eventBus.ts:10-29`

- **`location`, `budget`, `entryFees`, `exifData` are JSON fields without DB-level schema enforcement.**  
  **Proof:** `packages/database/prisma/schema.prisma:30,62,165,169,249,250`

- **Soft-delete strategy requires manual filtering (`deletedAt`) across models.**  
  **Proof:** multiple models in `schema.prisma` with `deletedAt` fields.

- **Password reset token lifecycle cleanup is partial (no global scheduled cleanup shown).**  
  **Proof:** model `schema.prisma:303-316`; cleanup pattern tied to flow `auth.commands.ts:99-113,158-163`

- **Search page does broad multi-page fetch and in-memory scoring/filtering.**  
  **Proof:** `apps/web/src/pages/search.astro:109-126,133-149`

- **`ListingCard` and multiple pages use `any`, reducing FE type safety.**  
  **Proof:** representative `apps/web/src/layouts/BaseLayout.astro:126,134,149`; admin/profile/search pages use `any`.

- **Admin pages swallow action API failures and still redirect as success path.**  
  **Proof:** `apps/web/src/pages/admin/reports.astro:27-34`; `apps/web/src/pages/admin/users.astro:20-33`

- **Navigation CSS always highlights Projects link globally due unconditional selector.**  
  **Proof:** `apps/web/src/styles/layouts/base-layout.scss:196-199`

- **Mobile nav open state requires JS behavior to toggle (`data-mobile-nav-toggle` + JS setOpen).**  
  **Proof:** markup `BaseLayout.astro:440-453`; behavior `public/js/ui.js:147-165`

- **Messages are capped at 150 chars both FE and API.**  
  **Proof:** FE `apps/web/src/pages/messages.astro:22,31,163`; API `apps/api/src/modules/message/message.services.ts:3`, `message.routes.ts:92`

- **Project apply payload hardcodes `agreedToTerms: true` in page action.**  
  **Proof:** `apps/web/src/pages/projects/[id].astro:61-64`

- **Project application consents default to `true` in API if omitted.**  
  **Proof:** `apps/api/src/modules/project/project.routes.ts:104-107`

- **Winner force override mechanism is exposed in UI (`forceWinnerDecision`) and wired to API `force` parameter.**  
  **Proof:** UI `apps/web/src/pages/contests/[id].astro:675`; server parse `:676-680`; bypass checks `:689-705`

- **Locale cookie set unconditionally when missing/mismatch with 1-year max-age and `httpOnly: false`.**  
  **Proof:** `apps/web/src/middleware.ts:33-40`

- **Legal consent version has hardcoded fallback date.**  
  **Proof:** `packages/config/src/index.ts:175`

- **Bcrypt cost factor fixed at 10.**  
  **Proof:** `apps/api/src/modules/auth/auth.commands.ts:56,147`

- **No self-service endpoints found for account deletion/export in user module routes.**  
  **Proof:** no matching routes in `apps/api/src/modules/user/user.routes.ts`.

---

## 1.4 Low

- **`.DS_Store` files are committed in web app directories.**  
  **Proof:** `apps/web/.DS_Store`, `apps/web/src/.DS_Store`, `apps/web/src/styles/.DS_Store`

- **`$primary-600` and `$primary-700` are equal values.**  
  **Proof:** `apps/web/src/styles/tokens.scss:32-33`

- **Text token comments claim AAA but some combinations are below AAA threshold.**  
  **Proof:** token values `tokens.scss:52-55` (comment + values mismatch risk)

---

## 2) Invalid / Outdated Findings (Disproved)

- **“No `.env.example` present” — Invalid.**  
  **Proof:** `tfp-workspace/.env.example` exists.

- **“Readiness endpoint does not check DB” — Invalid.**  
  **Proof:** `apps/api/src/plugins/health.ts:24-28` (`SELECT 1`).

- **“No skip-to-content link” — Invalid.**  
  **Proof:** `apps/web/src/layouts/BaseLayout.astro:240-242` + `<main id="main-content">` at `:484`.

- **“Notification/user details do not close on outside click” — Outdated/Invalid.**  
  **Proof:** `apps/web/public/js/ui.js:199-207` closes details when clicking outside.

- **“Social login pages render ‘coming soon’ content in production” — Invalid (current code redirects to login with oauth_not_configured).**  
  **Proof:** `apps/web/src/pages/auth/google.astro:2`, `apps/web/src/pages/auth/github.astro:2`

- **“Admin auth optional chaining check could silently pass” — Invalid for current code (direct role check without optional chain).**  
  **Proof:** `apps/web/src/utils/admin-auth.ts:35-37`

- **“Contest reaction counters are non-transactional / race-prone without transaction” — Outdated/Invalid.**  
  **Proof:** serializable transaction + retry in `apps/api/src/modules/contest/commands/RecordSubmissionReaction.ts:143-153`

- **“Messages API allows up to 2000 while UI restricts to 150” — Invalid for current code; API also restricts to 150.**  
  **Proof:** `message.services.ts:3`, `message.routes.ts:92`, `messages.astro:22`

- **“Profile page has no way to start messaging user” — Invalid.**  
  **Proof:** messaging CTA in `apps/web/src/pages/profile/[email].astro:333-341`

---

## 3) New Findings Added During This Validation Pass

- **Admin moderation action buttons have overlapping click behaviors** (immediate moderation call + modal opening), likely causing accidental moderation without intended review confirmation.  
  **Proof:** `apps/web/src/pages/admin/moderation.astro:244-256` and `:259-292`

- **Admin report/user action pages do not check API response outcomes before redirecting**, masking failed moderation/user actions.  
  **Proof:** `apps/web/src/pages/admin/reports.astro:27-34`; `apps/web/src/pages/admin/users.astro:20-33`

- **Projects nav active style bug is global**, not scoped to current page.  
  **Proof:** `apps/web/src/styles/layouts/base-layout.scss:196-199`

---

## 4) Prioritized Action Queue (Execution-Oriented)

1. **Auth/session hardening**: stop token refresh on `/auth/me`; shorten defaults; introduce revocation strategy.  
2. **Web security baseline**: enable CSP policy; add CSRF protection for cookie-auth mutations; tighten CORS no-origin handling.  
3. **Privacy/compliance**: remove email-based public profile paths; implement self-service export/delete; add consent strategy for cookies/EXIF handling.  
4. **SEO correctness**: add OG/Twitter images; add robots.txt; ship dynamic sitemap generation and integrate `@astrojs/sitemap`.  
5. **Admin UX correctness**: fix moderation button dual-handler bug; surface API failures in admin pages.  
6. **Scalability**: replace in-process event bus for distributed deployments; move upload serving to object/CDN delivery path; rework search backend.

---

## 5) Notes

- This document reflects the **current repository state** at validation time.  
- Some findings from prior documents were accurate at the time they were written but are now stale; those were marked as **outdated/invalid for current code**.
