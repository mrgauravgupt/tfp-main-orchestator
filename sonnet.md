# TFP Photographers Platform — Comprehensive Application Review

> **Reviewer:** Claude Sonnet (AI-assisted deep-dive)  
> **Date:** March 8, 2026  
> **Scope:** Full-stack review — Backend, Frontend, Database, SEO, Accessibility, UI/UX, Legal/Compliance, DevOps  
> **Status:** For human review before any implementation

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Backend (API — Fastify)](#2-backend-api--fastify)
3. [Database & Schema (Prisma / PostgreSQL)](#3-database--schema-prisma--postgresql)
4. [Frontend (Astro + SCSS)](#4-frontend-astro--scss)
5. [SEO](#5-seo)
6. [Accessibility (a11y)](#6-accessibility-a11y)
7. [UI / UX](#7-ui--ux)
8. [Legal & Compliance](#8-legal--compliance)
9. [DevOps, Config & Infrastructure](#9-devops-config--infrastructure)
10. [Code Quality & Architecture](#10-code-quality--architecture)
11. [Performance](#11-performance)
12. [Initial Priority Matrix](#12-priority-matrix)
13. [Use Case Audit](#13-use-case-audit--missing-incomplete--broken-flows)
14. [Moderation System — Deep Dive](#14-moderation-system--deep-dive)
15. [Legal & Compliance — Deep Dive](#15-legal--compliance--deep-dive)
16. [Navigation — Issues & Improvements](#16-navigation--issues--improvements)
17. [UX Flows — Deep Dive](#17-ux-flows--deep-dive)
18. [Responsive Design — Issues](#18-responsive-design--issues)
19. [Master Priority Matrix (All Sections)](#19-master-priority-matrix)
20. [Authentication & Authorization — Deep Dive](#20-authentication--authorization--deep-dive)

---

## 1. Executive Summary

The TFP Photographers Platform is a monorepo-structured Node.js application using Fastify (API) and Astro (frontend). The codebase shows strong architectural intent — CQRS in the contest module, an adapter-pattern storage layer, image moderation pipelines, an event bus, and centralized i18n. However, several **critical security, scalability, and compliance gaps** exist that must be resolved before a production launch. The most urgent issues span authentication session length, missing Content Security Policy, privacy (email in URLs, EXIF data retention, no cookie consent), lack of dynamic sitemap, and missing OG images.

---

## 2. Backend (API — Fastify)

### 2.1 Security

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | `contentSecurityPolicy: false` — CSP is entirely disabled via `@fastify/helmet`. This exposes all pages to XSS attacks. | `apps/api/src/server.ts:83-86` |
| **CRITICAL** | JWT cookie is `signed: false`. The JWT itself is cryptographically signed but the cookie wrapper is not. This allows cookie tampering at the transport layer. | `apps/api/src/server.ts:102-111` |
| **HIGH** | `JWT_EXPIRES_IN` defaults to `180d` (6 months) and `AUTH_SESSION_DAYS` defaults to 180. A stolen token is valid for 6 months with no server-side revocation mechanism. | `packages/config/src/index.ts:163-164` |
| **HIGH** | CORS: `if (!origin) { callback(null, true); }` — requests with no `Origin` header (e.g. server-to-server, Postman, curl) bypass CORS entirely. This is common on browser pre-flight but can be exploited. | `apps/api/src/server.ts:64-66` |
| **HIGH** | No CSRF protection. While `sameSite: 'lax'` provides partial protection, state-mutating POST/PATCH/DELETE endpoints on the API do not verify CSRF tokens. The login form POST and admin actions are vulnerable to cross-site form submission. | `apps/api/src/modules/auth/auth.routes.ts`, `apps/web/src/pages/admin/reports.astro` |
| **MEDIUM** | `trustProxy: true` without IP allowlist. This means any `X-Forwarded-For` header is trusted, enabling IP spoofing for rate limiting bypass. | `apps/api/src/server.ts:48` |
| **MEDIUM** | Open redirect vulnerability potential: login redirect target uses `formData.get('redirect')` with only a leading `/` check but no allowlist validation. A redirect to `//evil.com` could bypass the check. | `apps/web/src/pages/login.astro:41-44` |
| **MEDIUM** | Error messages exposed in URL query parameters: `?error=Invalid email or password` etc. These leak into browser history, server logs, and referrer headers. | `apps/web/src/pages/login.astro:47,52` |
| **LOW** | `JWT_SECRET` falls back to an empty string (`''`) if `JWT_SECRET` env var is not set. This only fails at startup via `assertRuntimeConfig`, but in test/dev environments could silently run with an empty secret. | `packages/config/src/index.ts:162` |
| **LOW** | `sanitizePlainText` strips HTML tags with a regex, not a proper parser. Certain malformed HTML (e.g. `<scr<script>ipt>`) can survive regex-based strippers. Consider a dedicated library like `sanitize-html`. | `apps/api/src/utils/text-sanitize.ts:8` |

### 2.2 Authentication & Sessions

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `auth/me` endpoint **refreshes and re-issues a new JWT token on every call**. Since `BaseLayout.astro` calls this on every page render, tokens are churned continuously. This makes token revocation lists impractical and wastes CPU on signing. | `apps/api/src/modules/auth/auth.routes.ts:215-216` |
| **HIGH** | The `remember_me` checkbox on the login page has **no effect**. The cookie `maxAge` is always `AUTH_SESSION_DAYS` regardless. Users expect shorter sessions when they don't check "Remember me". | `apps/web/src/pages/login.astro:112-113`, `apps/api/src/modules/auth/auth.routes.ts:27-28` |
| **MEDIUM** | Auth middleware calls `prisma.user.findUnique` on **every authenticated request** to check if the user is still active. With no caching layer, this is one database round-trip per request — a scalability bottleneck. | `apps/api/src/modules/auth/auth.middleware.ts:43-46` |
| **MEDIUM** | Social login pages (`/auth/google`, `/auth/github`) render in production but `FEATURE_SOCIAL_LOGIN` defaults to `false`. Non-functional UI options create confusion and may expose incomplete OAuth flows. | `apps/web/src/pages/auth/google.astro`, `apps/web/src/pages/auth/github.astro`, `packages/config/src/index.ts:174` |
| **LOW** | No account lockout or exponential backoff after repeated failed login attempts beyond rate limiting. Rate limit is per-window only (10 req/minute) and resets cleanly. | `apps/api/src/modules/auth/auth.routes.ts:38-40` |

### 2.3 Rate Limiting

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Rate limiting is only applied to auth and password-reset endpoints. The upload, message-send, report-submit, reaction, and moderation endpoints have **no rate limiting**. | `apps/api/src/server.ts:88-96` |
| **MEDIUM** | `global: false` means rate limiting is opt-in per route. Any new route added without explicit `config.rateLimit` gets no protection. | `apps/api/src/server.ts:90` |

### 2.4 File Uploads & Storage

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | User-uploaded files are served directly by `@fastify/static` from the API server's local filesystem (`apps/api/uploads/`). This directory is in the source tree and would be lost on container restarts or horizontal scaling. | `apps/api/src/server.ts:121-127` |
| **MEDIUM** | RAR files are allowed as contest resources (`application/x-rar-compressed`, `application/vnd.rar`). RAR extraction can be dangerous; consider restricting to ZIP/PDF only. | `apps/api/src/modules/contest/contest.routes.ts:68-76` |
| **MEDIUM** | `application/octet-stream` is in the allowed MIME types for resource uploads. This is a wildcard type that bypasses MIME-based validation — any binary file can be uploaded as a "resource". | `apps/api/src/modules/contest/contest.routes.ts:75` |
| **LOW** | EXIF metadata from uploaded images is not stripped before storage. GPS coordinates, camera serial numbers, and timestamps in EXIF data are a privacy risk for users. | `packages/database/prisma/schema.prisma:62` (`exifData Json?`) |

### 2.5 Logging & Observability

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `console.error` is used in `admin.routes.ts` instead of `app.log.error`. This bypasses the structured Pino logger and breaks log aggregation pipelines. | `apps/api/src/modules/admin/admin.routes.ts:73` |
| **LOW** | No request correlation IDs are generated or forwarded. Distributed tracing across API calls (BaseLayout → API → DB) is not possible. | `apps/api/src/server.ts` |
| **LOW** | System messages (`pushSystemMessage`) content is sliced to 150 chars — hardcoded magic number. Should be a named constant. | `apps/api/src/server.ts:143` |

### 2.6 Architecture

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | The event bus uses a **singleton Node.js EventEmitter** (`packages/shared/src/eventBus.ts`). This is in-process only — any horizontal scaling (multiple API replicas) means events are silently dropped on other instances. Domain events like `contest.approved` would stop triggering emails. | `packages/shared/src/eventBus.ts:22-29` |
| **MEDIUM** | `moderationFailurePayload` is defined as an identical function in **both** `user.routes.ts` and `contest.routes.ts`. This is direct code duplication that should be in a shared utility. | `apps/api/src/modules/user/user.routes.ts:60-70`, `apps/api/src/modules/contest/contest.routes.ts:77-87` |
| **MEDIUM** | Search is implemented entirely **client-side** in `apps/web/src/pages/search.astro` — it fetches all projects/events/contests/users and scores them in-memory with JS. This has no pagination, doesn't scale beyond a few hundred records, and can cause SSR timeouts. | `apps/web/src/pages/search.astro:71-79` |
| **LOW** | `ensureAdmin` is redefined locally in `admin.routes.ts` instead of reusing the `requireAuth` + role-check pattern from `auth-guards.ts`. | `apps/api/src/modules/admin/admin.routes.ts:42-48` |

---

## 3. Database & Schema (Prisma / PostgreSQL)

### 3.1 Schema Design

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `location Json?` on `User`, `Project`, and `Event` has no database-level schema enforcement. Invalid location objects (missing required fields, wrong types) can be stored silently. Consider a structured `Location` model or Prisma JSON schema validation. | `schema.prisma:30, 165, 249` |
| **HIGH** | `budget Json?` on `Project` and `entryFees Json?` on `Event` share the same issue — unstructured JSON with no enforcement. | `schema.prisma:169, 250` |
| **HIGH** | `likeCount`, `voteCount`, `shareCount` are denormalized counter fields on `ContestSubmission`. Without wrapping updates in a transaction, they can drift from the actual count in `ContestSubmissionReaction`. A race condition on concurrent likes could produce wrong counts. | `schema.prisma:125-127` |
| **MEDIUM** | `secondaryRoles String[]` and `badges String[]` on `User` have no enum enforcement at the database level. Any string value can be inserted, making data integrity depend entirely on application-layer validation. | `schema.prisma:21,31` |
| **MEDIUM** | Soft deletes (`deletedAt`) are used across User, Contest, Project, Event, PortfolioImage, ContestSubmission, DirectMessage but **no Prisma middleware** auto-filters them. Every query must manually include `deletedAt: null` or risk returning deleted records. | `schema.prisma` (multiple models) |
| **MEDIUM** | `PasswordResetToken` records accumulate indefinitely. There is no visible scheduled cleanup for expired (`expiresAt < now`) or used (`usedAt != null`) tokens. | `schema.prisma:303-316` |
| **LOW** | `exifData Json?` on `PortfolioImage` stores raw EXIF data from images, which can contain sensitive GPS coordinates and device identifiers. Storing this is a GDPR/privacy concern. | `schema.prisma:62` |
| **LOW** | `primary-600` and `primary-700` have the same value `#4338ca` in `tokens.scss`. This may or may not be intentional but is suspicious — usually 600 and 700 should differ. | `apps/web/src/styles/tokens.scss:33-34` |

### 3.2 Query Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | No full-text search indexes on `title` or `description` columns despite search being a core feature. The SSR search currently filters in-memory after fetching all records. A PostgreSQL `tsvector` index or dedicated search service is needed. | `schema.prisma` (missing FTS indexes) |
| **LOW** | `DirectMessage` table has a composite index on `[senderId, recipientId, createdAt]` but no index on `recipientId` alone for unread count queries. | `schema.prisma:237-240` |

---

## 4. Frontend (Astro + SCSS)

### 4.1 Type Safety

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `ListingCard.astro` uses `item: any` for its main data prop. This loses all type safety across the most-used component in the app. | `apps/web/src/components/ListingCard.astro:14` |
| **MEDIUM** | `index.astro`, `profile/[email].astro`, `search.astro` and other pages use `any` extensively for API response types. A shared type library for API response shapes would prevent runtime errors. | `apps/web/src/pages/index.astro:18-20` |
| **LOW** | `admin-auth.ts` uses `Astro: any` in its function signature, bypassing type checking for the Astro context object. | `apps/web/src/utils/admin-auth.ts:11` |

### 4.2 Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `BaseLayout.astro` makes **two API calls on every page render**: `GET /auth/me` and `GET /users/me/notifications`. For unauthenticated users only the `me` call is skipped, but authenticated SSR is 2 round-trips per page minimum. | `apps/web/src/layouts/BaseLayout.astro:67-79, 112-170` |
| **MEDIUM** | Notifications data is fetched on every page render to populate the nav dropdown, even for pages where the user is unlikely to check notifications (e.g. reading a contest detail). This should be loaded lazily/on demand. | `apps/web/src/layouts/BaseLayout.astro:112-169` |
| **LOW** | The `Inter` font family is declared in CSS tokens but there is no `<link rel="preload">` for the font files or a Google Fonts/CDN import in `BaseLayout.astro`. The font will fall back to system fonts or flash. | `apps/web/src/layouts/BaseLayout.astro`, `apps/web/src/styles/tokens.scss:121` |

### 4.3 Assets & Files

| Severity | Issue | Location |
|----------|-------|----------|
| **LOW** | `.DS_Store` macOS metadata files are committed to the repository. These should be in `.gitignore`. | `apps/web/src/styles/.DS_Store`, `apps/web/src/.DS_Store` |
| **LOW** | `@astrojs/sitemap` is in `web/package.json` as a dependency but is **not added** to the `integrations` array in `astro.config.mjs`. The installed package is dead code. | `apps/web/package.json`, `apps/web/astro.config.mjs:8` |

### 4.4 Component Design

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `ListingCard.astro` handles three completely different layouts (project, contest, event) in one monolithic component with large conditional blocks. This violates SRP and makes the component hard to maintain. | `apps/web/src/components/ListingCard.astro:91-226` |
| **LOW** | Duplicate `listing-card__content` markup blocks for contest and event variants are nearly identical but not extracted into a shared sub-component. | `apps/web/src/components/ListingCard.astro:169-184, 204-224` |

---

## 5. SEO

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | **No `og:image` or `twitter:image` meta tags** anywhere in `BaseLayout.astro` or any page. Social sharing links will show no preview image. This is a major virality/growth blocker. | `apps/web/src/layouts/BaseLayout.astro:220-228` |
| **HIGH** | **Sitemap only contains static paths**. Dynamic pages — contest details, project details, event details, public user profiles — are entirely absent. Search engines cannot discover or index the core content. | `apps/web/src/pages/sitemap.xml.ts:3-15` |
| **HIGH** | `@astrojs/sitemap` is installed but **not wired into `astro.config.mjs`**. No automatic sitemap is generated despite the package being present. | `apps/web/astro.config.mjs:8` |
| **HIGH** | No `robots.txt` file found in `apps/web/public/`. Without it, crawlers use default behaviour and will crawl admin and auth pages. | `apps/web/public/` |
| **MEDIUM** | **Auth and admin pages are indexable** in production (meta `robots` is `index,follow` for `isProduction`). Login, register, forgot-password, admin pages should be `noindex`. | `apps/web/src/layouts/BaseLayout.astro:205` |
| **MEDIUM** | Canonical URL is built from `Astro.url.pathname` only. For paginated listing pages (`?page=2`), the canonical points to the root pagination page — which is correct — but search/filter query parameters could create duplicate content issues. | `apps/web/src/layouts/BaseLayout.astro:43` |
| **MEDIUM** | **No JSON-LD structured data for entities**. Contest pages should have `Event` or `Competition` schema, event pages should have `Event` schema, user profiles should have `Person` schema. Only a generic `WebSite` schema exists. | `apps/web/src/layouts/BaseLayout.astro:176-191` |
| **MEDIUM** | `changefreq` is set to `daily` for all static pages and `lastmod` is always `now`. This gives no signal to crawlers about actual content freshness and may result in over-crawling static legal pages. | `apps/web/src/pages/sitemap.xml.ts:22` |
| **LOW** | Profile URLs use the user's **email address** as the URL slug (`/profile/user@example.com`). Email-as-URL is indexed by Google, making user emails discoverable via search. This is also a privacy issue. | `apps/web/src/pages/profile/[email].astro` |
| **LOW** | Keywords meta tag is optional but where used, `keywords` prop accepts any string. No guidance or default keywords exist for SEO targeting. | `apps/web/src/layouts/BaseLayout.astro:23` |

---

## 6. Accessibility (a11y)

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `<a href="#main-content" class="sr-only">` skip link exists but many pages may not have an element with `id="main-content"`. If the anchor target doesn't exist, the skip link is broken for keyboard users. | `apps/web/src/layouts/BaseLayout.astro:241` |
| **HIGH** | The notification dropdown uses `<details>/<summary>` but the expanded panel has no `role="region"`, no `aria-label`, and status changes (new badge count) are not announced via `aria-live`. Screen reader users get no notification of new activity. | `apps/web/src/layouts/BaseLayout.astro:306-391` |
| **HIGH** | `<h2>` is used for listing card titles in `ListingCard.astro`. When listing pages have section headings (also `<h2>`), item cards produce a broken heading hierarchy. Listing card titles should be `<h3>` when inside sections. | `apps/web/src/components/ListingCard.astro:134, 170, 205` |
| **MEDIUM** | The navigation search form has an `aria-label` on the `<input>` but the search `<Icon>` before the input is not explicitly `aria-hidden`. Depending on the icon implementation, screen readers may announce it redundantly. | `apps/web/src/layouts/BaseLayout.astro:284-293` |
| **MEDIUM** | Mobile navigation toggle: the hamburger button uses `data-mobile-nav-root` for JS hooks but no `aria-expanded`, `aria-controls`, or `aria-label` is visible in the layout. Mobile nav state is not announced to screen readers. | `apps/web/src/layouts/BaseLayout.astro:244` |
| **MEDIUM** | `<details>/<summary>` notification panel does not close on outside click without JavaScript enabled. With JS enabled, there is no visible outside-click-close handler either, creating a keyboard trap if focus moves elsewhere. | `apps/web/src/layouts/BaseLayout.astro:306` |
| **MEDIUM** | `$text-disabled: #94a3b8` and `$text-tertiary: #94a3b8` are identical values — both are used for muted/secondary text on `$bg-base: #0f1115`. The contrast ratio of `#94a3b8` on `#0f1115` is approximately **5.9:1**, which meets WCAG AA (4.5:1) for normal text but **fails WCAG AAA (7:1)**. The token comment claims AAA compliance. | `apps/web/src/styles/tokens.scss:54-55, 7` |
| **MEDIUM** | Form submit buttons show no `aria-busy` or disabled state during form submission. Without JavaScript-enhanced feedback, users with assistive tech have no indication a form is processing. | Various form pages |
| **LOW** | `<article>` wraps listing cards which is semantically correct, but the card's inner `<a>` wraps nearly all content (title, image, meta). A link that wraps an entire card body is acceptable with a descriptive `aria-label`, which is present, but the secondary action links (report) inside the card could cause nested interactive element issues on some AT. | `apps/web/src/components/ListingCard.astro:89-243` |
| **LOW** | No `lang` attribute change triggered when locale switches. While `html lang={htmlLang}` is set server-side, dynamic locale switching would need a full page reload to update the `lang` attribute. | `apps/web/src/layouts/BaseLayout.astro:195-196` |

---

## 7. UI / UX

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | **Email exposed in profile URLs** (`/profile/user@example.com`). Public profile URLs use the user's email address. This is a significant privacy risk and poor UX — users may not want their email visible in browser address bars, shared links, or search results. Should use username or ID. | `apps/web/src/pages/profile/[email].astro` |
| **HIGH** | **No 404 or custom error pages** found in the web app. Astro serves a generic error page on broken routes, which breaks brand consistency and provides no navigation back to the app. | `apps/web/src/pages/` |
| **HIGH** | **No loading/skeleton states** for the main content areas. Since all rendering is SSR, page loads show blank content until the server responds. This feels slow on slow connections and gives no progress feedback. | All listing pages |
| **MEDIUM** | The notification panel is a `<details>` element but does **not auto-close** when focus leaves it. On desktop this means the panel stays open when the user clicks elsewhere on the page, overlapping content. | `apps/web/src/layouts/BaseLayout.astro:306` |
| **MEDIUM** | Admin moderation queue (`/admin/moderation`) has no pagination. The `GetModerationQueue` query loads all pending items at once. This becomes unusable at scale. | `apps/web/src/pages/admin/moderation.astro`, `apps/api/src/modules/admin/admin.routes.ts:53-78` |
| **MEDIUM** | Admin reports page fetches up to 100 open reports at once (`?limit=100`) with no pagination. | `apps/web/src/pages/admin/reports.astro:36` |
| **MEDIUM** | `<details>/<summary>` is used for the notification dropdown and user menu — these are not standard dropdown menus. They don't auto-position (can overflow viewport on small screens), don't support keyboard arrow navigation within the panel, and don't close on `Escape` key by default. | `apps/web/src/layouts/BaseLayout.astro:306,397` |
| **MEDIUM** | Two separate upload flows exist for avatar uploads: a direct multipart POST (`/me/avatar`) and a presigned URL flow (`/me/avatar/presign` + `/me/avatar/complete`). The dual path is confusing and the moderation flow differs between them. | `apps/api/src/modules/user/user.routes.ts:255-313, 184-253` |
| **LOW** | **Dark mode only**. There is no light mode or system-preference-based theme. Users who prefer light mode or have accessibility needs (photosensitivity) are not accommodated. | `apps/web/src/styles/tokens.scss` |
| **LOW** | The "Artists" bento card on the home page links to `/profile` (the profile index) but shows avatar images from featured projects/contests — the association is misleading. | `apps/web/src/pages/index.astro:214` |
| **LOW** | Search is entirely client-side text matching with no fuzzy search, typo tolerance, or relevance ranking beyond prefix matching. Searching for "portrat" will not find "portrait". | `apps/web/src/pages/search.astro:71-79` |
| **LOW** | The `<input type="search">` in the nav has no `<label>` element — it uses `aria-label` on the input itself which is correct for screen readers, but visually the search input has only an icon with no visible label. | `apps/web/src/layouts/BaseLayout.astro:286-292` |

---

## 8. Legal & Compliance

### 8.1 Privacy & GDPR/DPDP

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | **No cookie consent banner or mechanism**. The middleware sets a `locale` cookie on every visitor unconditionally. GDPR and Indian DPDP Act 2023 require explicit consent for non-essential cookies before setting them. | `apps/web/src/middleware.ts:33-41` |
| **CRITICAL** | **No GDPR data export (portability) endpoint**. The Privacy Policy references user rights including data portability, but no `/api/users/me/export` or similar endpoint exists. | `apps/api/src/modules/user/` |
| **HIGH** | **User email is embedded in public profile URLs** (`/profile/user@example.com`). This effectively publishes user emails to search engines, web scrapers, and anyone who views a profile link. This is a GDPR/DPDP data minimisation violation. | `apps/web/src/pages/profile/[email].astro` |
| **HIGH** | **EXIF metadata is stored** in `PortfolioImage.exifData`. Photo EXIF data can contain GPS coordinates (precise location), device serial numbers, and timestamps. The Privacy Policy does mention this is collected, but there is no UI for users to opt out or view what EXIF data was captured. | `packages/database/prisma/schema.prisma:62` |
| **HIGH** | **No right-to-erasure endpoint** for self-service account deletion. While `SoftDeleteUser` exists as an admin command, users cannot delete their own accounts. GDPR/DPDP require self-service deletion. | `apps/api/src/modules/user/` |
| **HIGH** | **Legal content is stored in i18n JSON files** (`en_US.json`). Terms of Service and Privacy Policy are not versioned documents — they are translated strings. Any change to these strings is not auditable, not versioned, and not communicated to users. | `packages/i18n/src/locales/en_US.json:150-238` |
| **MEDIUM** | `deviceTrackingConsentAt` and `consentVersion` fields exist in the schema but there is **no visible UI** for users to grant or withdraw device tracking consent after registration. | `packages/database/prisma/schema.prisma:28-29` |
| **MEDIUM** | The `locale` cookie is set with `httpOnly: false`, meaning it is accessible to JavaScript. While not security-critical, preference cookies that are JS-readable expose the user's locale preference to any third-party scripts if added later. | `apps/web/src/middleware.ts:37` |
| **MEDIUM** | Age verification is absent from the registration flow. The platform facilitates in-person photo shoots which may involve minors. Without a minimum age (13+ COPPA, 16+ GDPR default) check, the platform may be hosting accounts from minors. | `apps/api/src/modules/auth/auth.commands.ts` |
| **LOW** | `ModerationAuditLog` stores `hashedIpAddress` and `deviceFingerprint`. The Privacy Policy mentions hashed IPs but does not specify the hashing algorithm or retention period. | `packages/database/prisma/schema.prisma:351` |

### 8.2 Terms of Service

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Terms of Service does not specify the **governing jurisdiction**. The terms mention the Information Technology Act, 2000 (India) and Intermediary Rules, but no explicit choice-of-law or dispute resolution clause (arbitration, court jurisdiction) is present. | `packages/i18n/src/locales/en_US.json:177-195` |
| **MEDIUM** | **No SLA or uptime commitment** for the platform. The "as is" disclaimer is present but no content delivery timeline, moderation response time, or dispute resolution timeline is specified. | `packages/i18n/src/locales/en_US.json:191` |
| **LOW** | The Terms of Service do not address **intellectual property disputes** between platform users — only between users and the platform. What happens when two users dispute image ownership is undefined. | `packages/i18n/src/locales/en_US.json:180` |

### 8.3 Content Moderation & Safety

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | The content moderation pipeline defaults to `NOOP` provider. In production with `ACTIVE_MODERATION_PROVIDER=noop`, no image moderation occurs and all uploads pass automatically. This must be enforced in `assertRuntimeConfig`. | `packages/config/src/index.ts:199`, `assertRuntimeConfig` at line 352 |
| **LOW** | Report reasons are limited to: `ADULT_CONTENT`, `VIOLENCE`, `COPYRIGHT_INFRINGEMENT`, `SPAM`. There is no "harassment", "misinformation", or "underage" reason, which are common categories for creator platforms. | `packages/config/src/index.ts:326-331` |

---

## 9. DevOps, Config & Infrastructure

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | **No `.env.example` file** found in the repository. New developers and deployment pipelines have no reference for required environment variables, leading to misconfiguration. | Repository root |
| **HIGH** | The `uploads` directory is located inside the API application directory (`apps/api/uploads/`). In containerized or serverless deployments, this data is **ephemeral** and lost on restart. All local storage should be externalized. | `apps/api/src/server.ts:121-127` |
| **HIGH** | The **in-process EventEmitter event bus** (`shared/src/eventBus.ts`) is incompatible with horizontal scaling. Multiple API instances won't share events — `contest.approved` emails will only be sent on the instance that approved the contest. Needs Redis Pub/Sub, RabbitMQ, or similar. | `packages/shared/src/eventBus.ts` |
| **MEDIUM** | **No Dockerfile or Docker Compose** configuration found. Deployment is not containerized or documented, making consistent environment setup difficult. | Repository root |
| **MEDIUM** | `LEGAL_CONSENT_VERSION` is hardcoded in `config/src/index.ts` as `'2026-03-08'` — it's not read from an environment variable despite being in the `ENV` object. Legal versioning must be environment-controlled to allow updates without code changes. | `packages/config/src/index.ts:175` |
| **MEDIUM** | Health route (`/health`, `/ready`) does not check database connectivity. A "healthy" server that cannot reach the database will pass load balancer health checks but fail all requests. | `apps/api/src/plugins/health.ts` |
| **LOW** | `pnpm` engine requirement is `>=8.0.0` but the workspace uses `pnpm@10.30.1`. The `engines` constraint does not match the `packageManager` field. | `tfp-workspace/package.json:13,19` |
| **LOW** | `sourcemap: false` in the Vite production build. While this reduces bundle size, it makes debugging production errors significantly harder without source maps. Consider uploading source maps to Sentry or similar. | `apps/web/astro.config.mjs:27` |

---

## 10. Code Quality & Architecture

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | The `search.astro` page implements text scoring and ranking entirely in the Astro frontmatter (SSR JavaScript) by fetching all records and filtering in-memory. This is a pattern that will fail once there are >500 records of any type. A proper search API endpoint is needed. | `apps/web/src/pages/search.astro:61-100` |
| **MEDIUM** | `locationSchema` is defined in `validation-schemas.ts` but the actual `location` field structure (`{ country, region, city, label, lat, lon }`) is also manually reconstructed in `user.routes.ts:164-173`. Single source of truth for location shape is missing. | `apps/api/src/modules/user/user.routes.ts:164-174`, `apps/api/src/utils/validation-schemas.ts` |
| **MEDIUM** | Multiple route modules define their own local `toPublicUrl` helper function with slightly different signatures. This should be a single shared utility. | `user.routes.ts:56-59`, `contest.routes.ts:63-66` |
| **LOW** | The `hi_IN.json` locale file exists but its completeness vs. `en_US.json` is unknown. Incomplete i18n keys will silently fall back to the key string, which is user-visible. | `packages/i18n/src/locales/hi_IN.json` |
| **LOW** | TypeScript `any` is used throughout the frontend pages. Given the project uses TypeScript, defining shared API response types (possibly in the `shared` package) would significantly improve correctness. | Multiple `.astro` files |

---

## 11. Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Every authenticated SSR page render triggers **at minimum 2 API calls** (auth/me + notifications). With DB queries behind each, this is significant latency chained in the hot path. Even a 50ms API response time = 100ms added to every page. | `apps/web/src/layouts/BaseLayout.astro:67-170` |
| **HIGH** | Auth middleware makes a `prisma.user.findUnique` call on every request. With no Redis/memory cache, a site with 100 concurrent users would issue 100 simultaneous user-lookup queries per second — just for session validation. | `apps/api/src/modules/auth/auth.middleware.ts:43-46` |
| **MEDIUM** | The `ContestSubmission` like/vote/share counter updates are not wrapped in transactions. Under concurrent load, two simultaneous reactions can both read the same count and both increment, causing count drift. | `apps/api/src/modules/contest/commands/RecordSubmissionReaction.ts` |
| **MEDIUM** | Static site metadata (cache headers) for public API responses uses `max-age=60, stale-while-revalidate=300`. For content that changes infrequently (e.g. approved contests), these TTLs are very short. Consider longer `stale-while-revalidate` or CDN caching. | `apps/api/src/server.ts:351-361` |
| **LOW** | `BaseLayout.astro` calls both `getSupportedAppLocales()` and `resolveRequestLocale()` on every render. These are cheap operations but could be memoized at module level for the locale list. | `apps/web/src/layouts/BaseLayout.astro:33-35` |

---

## 12. Priority Matrix

### 🔴 Critical — Fix Immediately (Blockers for Production)

1. Enable Content Security Policy (`@fastify/helmet` with proper CSP config) — `server.ts:83`
2. Add `og:image` and `twitter:image` to BaseLayout — `BaseLayout.astro:220`
3. Cookie consent banner for GDPR/DPDP compliance — new component
4. Fix profile URLs to use username/ID instead of email — `profile/[email].astro`
5. Add `robots.txt` to `apps/web/public/` — new file
6. Fix sitemap to include dynamic entity URLs — `sitemap.xml.ts`
7. Add right-to-erasure (self-service account deletion) endpoint — `user.routes.ts`

### 🟠 High — Address Before Launch

8. Reduce JWT session duration from 180 days (recommend 7-30 days max)
9. Stop refreshing JWT on every `/auth/me` call — separate token refresh from session check
10. Make `remember_me` functional — short-lived vs long-lived sessions
11. Add a proper search API endpoint — replace client-side SSR scoring
12. Replace in-process EventEmitter with a durable message queue (Redis/RabbitMQ)
13. Externalize file uploads to cloud storage — remove `@fastify/static` for uploads
14. Add data portability endpoint (`/api/users/me/export`)
15. Strip EXIF metadata from uploaded images before storage
16. Add CSRF protection for state-mutating forms
17. Add database health check to `/ready` endpoint

### 🟡 Medium — Sprint Backlog

18. Cache user session lookup in auth middleware (Redis with short TTL)
19. Add rate limiting to upload, message, report, and reaction endpoints
20. Add pagination to admin moderation queue and reports
21. Fix heading hierarchy in `ListingCard.astro` (h2 → h3 in card context)
22. Add `aria-expanded` / `aria-controls` to mobile nav toggle
23. Add `aria-live` region for notification badge
24. Move Terms/Privacy from i18n JSON to versioned, auditable documents
25. Add minimum age verification to registration
26. Fix `$primary-600` / `$primary-700` token values if not intentional
27. Add `.env.example` file
28. Wire `@astrojs/sitemap` into `astro.config.mjs` or remove the dependency
29. Fix `application/octet-stream` in allowed upload MIME types
30. Add token cleanup job for expired `PasswordResetToken` records

### 🟢 Low — Technical Debt / Polish

31. Remove `.DS_Store` files and add to `.gitignore`
32. Create `ProjectCard`, `ContestCard`, `EventCard` sub-components from `ListingCard`
33. Define shared TypeScript types for API responses (move out of `any`)
34. Add light mode / system-preference theme support
35. Add JSON-LD structured data for Contest, Event, and User pages
36. Add source maps (uploaded privately to error tracking)
37. Document all environment variables in `.env.example`
38. Add Docker/Docker Compose configuration
39. Fix `pnpm` engine version mismatch in `package.json`
40. Mark auth/admin pages as `noindex` in robots meta

---

## 13. Use Case Audit — Missing, Incomplete & Broken Flows

> **Research basis:** TFP platforms require tools for collaboration, scheduling, communication, agreements, and community support ([Format Magazine](https://www.format.com/magazine/resources/photography/tfp-shoot), [Evoto](https://www.evoto.ai/blog/tfp-photography), [Shotkit](https://shotkit.com/tfp-in-photography)). The core value proposition is connecting photographers, models, stylists, MUAs, and other creatives for portfolio-building collaborations. Every feature gap below represents a real use case that the platform fails to satisfy.

---

### 13.1 Subscription System — Contests are Admin-Only (By Design) + No Payment Gateway

**Severity: MEDIUM (design note) + HIGH (missing payment)**

**Contests are intentionally admin-only.** The `contestsPerMonth: 0` default for all tiers is by design — only ADMIN-role users can create contests, which bypasses the quota check in `subscription-policy.ts:81-83`. This is a platform editorial decision, not a bug. The document previously flagged this as critical; that classification is **corrected here**.

**Evidence (`packages/config/src/index.ts:243-257`):**
```
FREE tier:    contestsPerMonth = 0  (admin-only by design)
PRO tier:     contestsPerMonth = 0  (admin-only by design)
PRO_PLUS tier: contestsPerMonth = 0 (admin-only by design)
```

However, what remains a **HIGH severity issue** is that **there is no payment processor integration** anywhere in the codebase. The `SubscriptionTier` enum (FREE / PRO / PRO_PLUS) is fully modelled in the DB and quotas are enforced per tier, but:
- No Stripe, Razorpay, PayPal, or any payment gateway is present
- No `POST /api/subscriptions/upgrade` or checkout session endpoint exists
- No webhook handler for subscription lifecycle events (renewal, cancellation)
- No billing history, invoice, or receipt
- Tier can only be changed directly in the database — there is no admin panel action to promote a user to PRO

**Use case blocked:** A PRO subscriber gets more project/event creation quotas (10/month vs 1/month for FREE), but there is no mechanism for any user to actually become PRO through the app.

---

### 13.2 Digital Model Release / TFP Agreement — Placeholder Only

**Severity: HIGH**

The core legal instrument of every TFP shoot is the **model release / TFP agreement** — a document signed by all participants specifying image rights, usage, and consent. The platform stores a `tfpAgreement String?` field on `Project` but there is no digital agreement flow.

**Evidence (`packages/database/prisma/schema.prisma:171`):**
```prisma
tfpAgreement  String?  @map("tfp_agreement")
```

**What exists:**
- `ProjectApplication` has boolean consent flags: `agreedToTerms`, `consentSocial`, `consentEditing`, `consentTimeline` — these are collected but only as booleans with no associated legal text shown at time of consent

**What is missing:**
- No contract template or dynamic agreement generation
- No e-signature workflow (DocuSign, HelloSign, or even a checkboxed PDF)
- No PDF download of the signed agreement
- No audit trail of what terms were accepted (the `tfpAgreement` text field can be changed after application)
- No per-project custom clauses
- No revocation mechanism for consent

**Use case blocked:** A photographer creates a project. A model applies and clicks "Agree to Terms." There is no legally binding document generated, no signature captured, no versioned record of what was agreed. If a dispute arises about image usage, there is nothing enforceable.

---

### 13.3 Real-time Messaging — Polling Only, No Push

**Severity: HIGH**

The platform is built around direct collaboration, which requires timely communication. The current messaging system is text-only and entirely pull-based.

**Evidence:**
- Notifications fetched on every page load via `BaseLayout.astro:112-170` (SSR polling)
- No WebSocket server in `apps/api/src/server.ts`
- No Server-Sent Events (SSE) endpoint
- `DirectMessage` model has `readAt` and `deletedAt` but no deletion endpoint

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Real-time delivery (WebSocket / SSE) | Users only see new messages on page reload |
| Image/file sharing in messages | Creatives cannot share reference images in DMs |
| Message deletion by sender | Cannot unsend an accidental or private message |
| Conversation archiving | No way to clean up old conversations |
| Read receipts display | `readAt` is stored but never surfaced in the UI |
| User blocking within messaging | No way to block a harassing user from sending DMs |
| Message search | Cannot find a previous message in long conversations |
| Group messaging | All projects involve multiple parties but only 1:1 DMs exist |

**Use case blocked:** A photographer DMs a model about shoot location. The model only sees the message hours later on next page load. There is no way to share a location pin or mood board image in the DM thread.

---

### 13.4 User Discovery & Matching — No Proximity or Availability

**Severity: HIGH**

TFP collaborations are inherently local — a model in Mumbai cannot collaborate TFP with a photographer in Chennai. The platform collects location data but does not use it for discovery.

**Evidence:**
- `GET /api/users/` only accepts a `role` filter (`user.routes.ts:74-100`)
- No `location` or `radius` filter on the user list endpoint
- Search is in-memory in `search.astro` with basic text matching
- No availability or "open to collaboration" status on `User` model

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Location-based proximity search | Cannot find photographers within 50km |
| Availability / "open for TFP" toggle | No way to signal active availability |
| Secondary role filtering (model, MUA, stylist simultaneously) | `secondaryRoles` field exists but not filterable |
| Experience level filter | No experience indicator beyond portfolio size |
| Portfolio style tags / genres | Cannot filter by portrait, fashion, editorial specialization |
| Saved / favourited profiles | No way to bookmark a creator for later contact |
| "Recently active" or "verified" badges | No activity signal — deleted/inactive profiles show identically |

**Use case blocked:** A fashion photographer newly registered in Delhi wants to find make-up artists available for TFP within 30km. The platform has no mechanism to surface this — they can only browse an unpaginated list or search by name.

---

### 13.5 Contest System — Multi-Prize, Automation & Judge Roles Incomplete

**Severity: HIGH**

The contest model supports `ContestPrize[]` with position numbers (1st, 2nd, 3rd), but the winner assignment only supports a single winner.

**Evidence (`apps/api/src/modules/contest/commands/SetContestWinner.ts:8-22`):**
```typescript
export async function SetContestWinner(input: SetContestWinnerInput) {
  return prisma.contest.update({
    where: { id: input.contestId },
    data: {
      winnerSubmissionId: input.submissionId,  // single field only
      winnerAnnouncedAt: new Date(),
    },
  });
}
```

The `Contest` schema has `winnerSubmissionId String?` — one field for one winner. The `ContestPrize` model can hold 1st, 2nd, 3rd place, but there's no corresponding `ContestWinner` join table linking each prize position to a submission.

**Additional contest gaps:**

| Missing Feature | Impact |
|-----------------|--------|
| Multi-winner / multiple prize assignments | 2nd and 3rd place prizes exist in DB but cannot be assigned |
| Automated lifecycle transitions (cron) | Admin must manually POST `/admin/lifecycle/sync` to close stale contests |
| External judge role | No invite-judge or external-reviewer flow |
| Submission withdrawal | Entrants cannot withdraw a submission before judging ends |
| Anonymous judging mode | All submissions show submitter name — not blind judging |
| Contest duplication / templates | No clone-contest feature for recurring contests |
| Submission commenting | Only reactions (like/vote/share), no textual feedback |

**Use case blocked:** A photography school runs a monthly portrait contest with gold/silver/bronze prizes. Only the gold winner can be recorded; silver and bronze have no assignment mechanism. The school admin must also remember to manually trigger lifecycle sync to close the contest.

---

### 13.6 Event System — Single Date, No Capacity, No Payment Collection

**Severity: MEDIUM**

Events represent photo walks, workshops, and meetups. The current model is minimal.

**Evidence (`schema.prisma:243-265`):**
```prisma
model Event {
  date        DateTime          // single point in time, no end_date
  entryFees   Json?             // stored but never collected
  rsvps       EventRSVP[]       // no capacity limit
}
```

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| End date / duration | Cannot represent a 2-day workshop |
| Recurring events | No weekly meetup support |
| Capacity / attendee limit | Venue with 20 seats can get 500 RSVPs |
| Waitlist | No overflow management |
| Entry fee collection | `entryFees` JSON is stored but no payment gateway collects it |
| Event cancellation status | `ContentStatus` has no `CANCELLED` value — cancelled events must be soft-deleted |
| Ticket / confirmation email | No post-RSVP confirmation sent to attendee |
| Event reminders | No day-before reminder notification |
| Attendee list download | Organiser cannot export RSVP list |
| Co-organiser roles | Single `creatorId` only |

**Use case blocked:** A photographer organises a paid 2-day wildlife photography workshop with 15 seats. The platform can neither enforce the seat limit, collect the entry fee, nor represent the two-day duration properly.

---

### 13.7 Project Application — No Withdraw, No Counter-Offer, No Communication

**Severity: MEDIUM**

The project application workflow (APPLIED → SHORTLISTED → SELECTED → REJECTED) is implemented but the experience has significant gaps.

**Evidence (`apps/api/src/modules/project/project.routes.ts:71-100`):**
- `UpdateProjectApplicationStatus` allows the **creator** to change status
- There is no applicant-withdraw endpoint
- There is no `WITHDRAWN` or `CANCELLED` status in the `ProjectApplicationStatus` enum
- Once applied, an applicant cannot remove their application

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Applicant withdrawal | Cannot undo an accidental application |
| Counter-offer / negotiation | No way to propose modified terms before accepting |
| Application message thread | Communication about project details must use separate DM |
| Bulk status update for creator | Cannot shortlist 5 of 20 applicants at once |
| Application deadline enforcement | `applicationDeadline` field exists but no automatic close |
| Role-specific application | Applicant applies to the whole project, not a specific `ProjectRole` |
| Application portfolio link | Applicant cannot attach specific portfolio images to application |

**Use case blocked:** A model accidentally applies to the wrong project. There is no way to withdraw. They must DM the creator and ask them to reject the application manually.

---

### 13.8 User Reputation & Trust — Badges Are Static, No Rating

**Severity: MEDIUM**

Trust is fundamental on TFP platforms. Collaborating with strangers for in-person shoots requires some level of verified reputation. The platform collects social proof primitives but does not surface them.

**Evidence (`schema.prisma:31`):**
```prisma
badges  String[]  @default([])
```

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Badge awarding logic | `badges` array is never populated by any route or command |
| Post-collaboration rating/review | No way to rate a collaborator after a shoot |
| Completion rate tracking | No metric for how often someone accepts and shows up |
| Verified identity badge | No ID or professional credential verification |
| Portfolio quality score | No community-endorsed quality signal |
| Response rate / response time | No data on how quickly someone replies to DMs |
| Report history visible to mods | `ContentReport` exists but no aggregated trust score |

**Use case blocked:** A new photographer wants to know if a model is reliable before committing to a shoot. The profile shows no ratings, no completed project count, and no trust signals — only portfolio images.

---

### 13.9 Profile & Onboarding — No Guided Setup, No Completion Gate

**Severity: MEDIUM**

New users register and immediately have full platform access with a bare profile. There is no onboarding flow and no minimum profile requirements before posting content.

**Evidence (`apps/api/src/modules/auth/auth.commands.ts:58-70`):**
- User created with only `email`, `passwordHash`, and auto-derived `displayName` (from email prefix)
- `bio`, `location`, `username`, `profileImageKey`, `instagramUrl` are all optional and empty at creation
- No `/onboarding` page or API endpoint exists

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Guided onboarding wizard | New users don't know what to fill in or why |
| Profile completion percentage | No incentive to complete profile |
| Username selection at registration | `username` field exists but not prompted at signup |
| Mandatory profile photo before posting | Projects/events posted by avatar-less users look unprofessional |
| Skills / specialisation tags | No tagging beyond `UserRole` enum |
| Availability calendar | No schedule or busy/free status |
| TFP preferences setting | No way to specify "available for fashion, not for boudoir" |
| Social proof links | Only `instagramUrl` and `portfolioUrl` — no LinkedIn, Behance, 500px |

**Use case blocked:** A make-up artist registers, has no username prompt, leaves their profile blank, and immediately posts a project. Other users see a nameless, pictureless profile with no bio and no way to evaluate them.

---

### 13.10 Admin Panel — Minimal Tooling, No Dashboard

**Severity: MEDIUM**

The admin panel handles content moderation and user management but lacks the analytics and operational tools a growing platform needs.

**Evidence (`apps/api/src/modules/admin/admin.routes.ts`):**
- Available endpoints: `/queue`, `/moderate`, `/reports`, `/reports/:id`, `/users`, `/users/:id`, `/lifecycle/sync`
- No stats/dashboard endpoint, no audit log viewer, no subscription management

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Dashboard / stats | No user counts, content counts, or moderation metrics |
| Subscription tier management | Admins cannot upgrade a user to PRO via admin panel |
| Audit log viewer | `ModerationAuditLog` exists in DB but no admin endpoint reads it |
| Content appeal process | Rejected creators have no recourse — no appeal endpoint |
| Bulk moderation actions | Must approve/reject items one at a time |
| Featured content curation | No way to promote selected projects/events to homepage |
| Email blast / announcements | No broadcast messaging to users |
| Platform-wide ban (IP block) | Can only soft-delete accounts, no IP-level enforcement |
| Admin notes on users | No way to annotate a user record with internal notes |
| Export user/content data | No CSV or JSON export for compliance/analytics |

**Use case blocked:** A platform admin wants to promote a high-quality contest to the homepage. There is no featuring mechanism. A user whose content was rejected wants to understand why and appeal — there is no appeal endpoint.

---

### 13.11 Follow / Social Graph — Entirely Absent

**Severity: MEDIUM**

TFP platforms thrive on community and network effects. Following key photographers or models creates an activity feed that keeps users engaged.

**Evidence:** No `UserFollow`, `Follow`, or relationship table exists in `schema.prisma`. No follow endpoint exists in any route file.

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Follow / unfollow users | Cannot subscribe to another creator's activity |
| Personalised activity feed | Notifications are generic recommendations, not from followed users |
| Follower / following counts | No network size signal on profiles |
| "Suggested collaborators" | No ML or rule-based matching of compatible styles |
| Share project to followers | No broadcast mechanism when content is published |

**Use case blocked:** A photographer discovers a great stylist and wants to be notified of their future projects. There is no follow mechanism. They must manually check back.

---

### 13.12 Content Discovery — No Tags, No Filters, No Collections

**Severity: MEDIUM**

Projects, events, and contests have no tagging or categorisation beyond `projectType` (TFP/PAID/COLLABORATION/FREE/TRADE) and `UserRole` for required roles.

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Genre / style tags (fashion, editorial, fine-art) | Cannot browse by photography genre |
| Mood board style tags | No visual style indicator beyond uploaded images |
| Saved / bookmarked content | Cannot save a project to apply later |
| Content collections / albums | No way for users to organise portfolio into sets |
| Trending / featured content | No algorithmic or editorial curation on homepage |
| Advanced filters on listings | Location, date range, role, type are all single-value filters at best |

---

### 13.13 Notification System — No Push, No Email, No Preferences

**Severity: MEDIUM**

The notification system is entirely pull-based (polled in BaseLayout on each render) with no user preferences or delivery channels beyond polling.

**Evidence:**
- `getUserNotifications()` queries DB on every page load — no persistence of "seen" state
- No notification preference settings in user profile
- No push notification (FCM / APNS) integration
- Email notifications exist only for: password reset, contest approval (via event bus) — no email for new message, new application, application status change

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| Email for new DM | Offline users never know they received a message |
| Email for application status change | Users must log in to discover their application was shortlisted |
| Push notifications (mobile web) | No Service Worker / Web Push API integration |
| In-app notification bell with persistence | "Seen" state is not tracked — badge resets on every page |
| Notification preferences | Cannot opt out of specific notification types |
| Digest emails | No weekly summary of platform activity |

---

### 13.14 Content Flagging — Insufficient Categories & No User-Facing Outcome

**Severity: LOW**

The report system allows users to flag content but is limited in scope and provides no feedback to reporters or subjects.

**Evidence (`packages/config/src/index.ts:326-331`):**
```typescript
REPORT_REASONS: ['ADULT_CONTENT', 'VIOLENCE', 'COPYRIGHT_INFRINGEMENT', 'SPAM']
```

**What is missing:**

| Missing Feature | Impact |
|-----------------|--------|
| "Harassment / bullying" reason | Cannot report abusive messages or profiles |
| "Underage content" reason | Critical for a platform involving photo shoots |
| "Impersonation" reason | Cannot flag fake profiles |
| Reporter outcome notification | Reporter never learns if their report was acted on |
| Subject notification on removal | Removed content owner is not notified why |
| Content appeal after removal | No recourse for false positives |
| Anonymous reporting | `reporterId` is stored — non-anonymous reports may deter reporters |

---

### 13.15 Summary — Use Case Coverage Matrix

| Use Case | Implemented | Partial | Missing |
|----------|-------------|---------|---------|
| User Registration / Auth | ✅ | | |
| Public Profile Discovery | ✅ | | |
| Portfolio Upload with Moderation | ✅ | | |
| TFP Project Posting | ✅ | | |
| Project Application Workflow | | ✅ (no withdraw, no role-specific apply) | |
| Direct Messaging | | ✅ (no real-time, no file sharing, no blocking) | |
| Event Creation & RSVP | | ✅ (no capacity, no payment collection, single date) | |
| Photo Contest with Reactions | | ✅ (single winner only, no auto-lifecycle, no blind judging) | |
| Content Moderation (Admin) | | ✅ (no bulk actions, no appeal, no dashboard) | |
| Image Moderation (AI) | ✅ | | |
| i18n (en_US + hi_IN) | | ✅ (hi_IN completeness unknown) | |
| Subscription Tier Quotas | | ✅ (contests broken for ALL tiers by default) | |
| Notification System | | ✅ (polling only, no persistence of seen state) | |
| Location Autocomplete | ✅ | | |
| Payment / Subscription Upgrade | | | ❌ Entirely missing |
| Digital Model Release / e-Sign | | | ❌ Only a text field placeholder |
| Real-time Notifications (WS/SSE) | | | ❌ Entirely missing |
| Proximity / Location-based Search | | | ❌ Entirely missing |
| Follow / Social Graph | | | ❌ Entirely missing |
| User Rating / Review after Shoot | | | ❌ Entirely missing |
| Availability / Schedule Calendar | | | ❌ Entirely missing |
| Multi-prize Contest Winners | | | ❌ Only single winner supported |
| Event Capacity / Waitlist | | | ❌ Entirely missing |
| Entry Fee Payment Collection | | | ❌ `entryFees` JSON stored, never collected |
| Guided Onboarding Flow | | | ❌ Entirely missing |
| Content Tagging / Genres | | | ❌ Entirely missing |
| Admin Dashboard / Stats | | | ❌ Entirely missing |
| User Badges / Awarding Logic | | | ❌ Field exists, no awarding code |
| Push Notifications | | | ❌ Entirely missing |
| Email for DM / Application Events | | | ❌ Only password reset + approval emails |
| Content Appeal Process | | | ❌ Entirely missing |
| Profile Completion / Onboarding | | | ❌ Entirely missing |

---

## 14. Moderation System — Deep Dive

### 14.1 Architecture & Flow

The moderation pipeline is the most architecturally complete module in the codebase. It uses a proper hexagonal / ports-and-adapters design:

```
Upload route
  → SubmitImageForModerationCommand
    → IModerationProvider (Google Vision | AWS Rekognition | NOOP)
    → IModerationStrategy (STRICT | ARTISTIC)
    → PrismaModerationRepository (persist ImageModeration record)
    → AuditLogger (persist ModerationAuditLog with hashed IP + device fingerprint)
  ← ModerationDecision { outcome: APPROVED | FLAGGED | REJECTED }
  → if REJECTED/FLAGGED: createAutoModerationIncidentReport()
    → maybeAutoBlockRepeatOffender() (soft-deletes user after N strikes)
```

**Evidence (`apps/api/src/modules/moderation/application/SubmitImageForModerationCommand.ts:29-76`)**

### 14.2 Issues & Gaps

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | `MODERATION_ENABLED` defaults to `true` but `ACTIVE_MODERATION_PROVIDER` defaults to `'noop'`. The NOOP provider returns all zeros — every category score is `0` — so every image is auto-approved regardless of content. A production deployment without setting `ACTIVE_MODERATION_PROVIDER=google_vision` or `aws_rekognition` performs **zero actual moderation** while logging records showing `APPROVED`. | `packages/config/src/index.ts:199`, `SubmitImageForModerationCommand.ts:33-39` |
| **HIGH** | Auto-block (`maybeAutoBlockRepeatOffender`) **hard-deletes the account by setting `deletedAt`** without any admin review step. An adversarially-triggered sequence of borderline uploads (3 FLAGGED images within 30 days) can permanently lock out a legitimate user's account with no human review. | `auto-moderation-report.ts:51-54` |
| **HIGH** | No **human override UI** in the admin panel for moderation decisions. Admins can approve/reject entire content entities (projects, events, contests) but there is no interface to view individual `ImageModeration` records, override a REJECTED image to APPROVED, or clear a FLAGGED image. The `ModerationAuditLog` table exists in the DB but no admin endpoint exposes it. | `apps/api/src/modules/admin/admin.routes.ts` (no `/moderation/images` route) |
| **HIGH** | The `report.routes.ts` triggers `submitReportedEntityForModerationRecheck` when a content report is filed. This means any user can **force AI re-moderation of any entity's images** simply by submitting a report — an attack vector for targeted harassment via moderation triggers. | `apps/api/src/modules/report/report.routes.ts` |
| **MEDIUM** | `AI_REPEAT_OFFENDER` and `AI_MODERATION_REJECTED` are used as `ContentReport.reason` values in `auto-moderation-report.ts:65,94` but they are **not in the `REPORT_REASONS` config** (`packages/config/src/index.ts:326-331`). These synthetic reasons will appear in the admin reports panel without labels or translations. | `auto-moderation-report.ts:65,94`, `config/src/index.ts:326-331` |
| **MEDIUM** | The `ARTISTIC` moderation strategy (intended for fine-art photography) raises the ADULT rejection threshold to `Math.min(0.95, rejectThreshold + 0.1)`. However, strategy selection is a **global server config** (`MODERATION_STRATEGY` env var) — it is not selectable per-content-type or per-upload. A contest banner and a boudoir portfolio are moderated with the same global strategy. | `ArtisticModerationStrategy.ts:23`, `config/src/index.ts:200` |
| **MEDIUM** | `ensureImageMagicBytes` checks that the file starts with valid JPEG/PNG/WebP magic bytes. However, the check result (`magic.mimeType`) is only used for the response — it is **not used to block mismatched MIME types**. A file could have a valid JPEG header prepended to malicious content and still pass. | `SubmitImageForModerationCommand.ts:31`, `moderation.utils.ts` |
| **MEDIUM** | `ipAddress` is taken from `request.ip` (which respects `trustProxy: true`) and then hashed for the audit log. If `trustProxy` is exploited to spoof an IP (see Section 2.1), the audit trail will contain a **hashed spoofed IP**, not the real source. | `moderation/application/request-context.ts`, `server.ts:48` |
| **LOW** | `ModerationAuditLog.deviceFingerprint` is stored as a plain string with no documented format or validation. The `request-context.ts` reads it from a header (`x-device-fingerprint`) which any client can forge. Device fingerprinting for audit purposes only works if the fingerprint is server-computed. | `apps/api/src/modules/moderation/application/request-context.ts` |
| **LOW** | No moderation for **text content**. Project descriptions, event descriptions, contest titles, and direct messages are stored without any content scanning. Hate speech, spam URLs, or CSAM text content passes through unfiltered. | All `sanitizePlainText` calls — only strips HTML, no semantic scan |
| **LOW** | When `MODERATION_ENABLED=false`, the moderation command still runs but returns all-zero scores. The decision is always APPROVED. However, `ModerationRecord` entries are **still written** to the DB with `providerUsed: 'NOOP'`. Over time this pollutes the `image_moderations` table with meaningless NOOP records. | `SubmitImageForModerationCommand.ts:33-39` |

---

## 15. Legal & Compliance — Deep Dive

### 15.1 Cookie & Consent Law

| Severity | Issue | Evidence |
|----------|-------|----------|
| **CRITICAL** | The `locale` cookie is set **unconditionally on every visitor's first request** with a 365-day maxAge, before any consent interaction. Under GDPR Article 6 and the ePrivacy Directive, non-essential cookies require prior informed consent. The locale cookie is arguably functional (not analytics), but legal opinion varies — the safest position is to either use `sessionStorage` or collect consent first. | `apps/web/src/middleware.ts:33-41` |
| **CRITICAL** | The Privacy Policy states: *"We use cookies to enhance your experience"* but does not distinguish between cookie categories (essential vs. preference vs. analytics vs. marketing), nor provide a mechanism to revoke consent. This violates GDPR Article 13 (information obligation) and the UK PECR. | `packages/i18n/src/locales/en_US.json` → `legal.privacy.cookie_policy_body` |
| **HIGH** | `deviceTrackingConsentAt` and `consentVersion` are stored in the DB (collected at registration), but there is **no UI for users to view or withdraw device tracking consent**. The Privacy Policy mentions it, but a user has no way to know their consent is stored or how to change it. | `schema.prisma:28-29`, `auth.commands.ts:67-68` |

### 15.2 GDPR / DPDP Rights Implementation

| Right | Status | Evidence |
|-------|--------|----------|
| Right to Access (Art. 15) | ❌ Missing | No `/api/users/me/export` endpoint |
| Right to Rectification (Art. 16) | ✅ Partial | `PATCH /api/users/me/profile` exists but cannot change email |
| Right to Erasure (Art. 17) | ❌ Missing | No self-service deletion — only admin `SoftDeleteUser` |
| Right to Restriction (Art. 18) | ❌ Missing | No way for user to restrict processing |
| Right to Portability (Art. 20) | ❌ Missing | No machine-readable export |
| Right to Object (Art. 21) | ❌ Missing | No opt-out of processing for recommendations/notifications |
| Right to Withdraw Consent (Art. 7.3) | ❌ Missing | Device tracking consent stored but not withdrawable |

**Indian DPDP Act 2023 adds:** `consentManager` requirement, mandatory breach notification within 72 hours, and data localisation for sensitive personal data — none of which are implemented.

### 15.3 Terms of Service Gaps

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | The Terms of Service is rendered entirely from i18n JSON keys — it is **not a versioned legal document**. When `en_US.json` is updated (e.g., a new prohibited item added), there is no mechanism to: (a) notify users of the change, (b) require re-acceptance, (c) record which version each user accepted. `consentVersion` is set once at registration and never updated. | `apps/web/src/pages/terms.astro`, `packages/i18n/src/locales/en_US.json` |
| **HIGH** | Terms of Service does not define a **minimum age**. The platform facilitates in-person photo shoots — including TFP arrangements involving minors — without any age gate. COPPA (USA) requires parental consent for under-13; GDPR requires 16+ for data processing consent (or 13+ with parental consent depending on member state). No age verification exists at registration. | `auth.commands.ts` |
| **MEDIUM** | The Terms include a section on **prohibited conduct** (5 items) but does not address: image copyright ownership post-shoot, model release obligations, liability for in-person shoot accidents, or platform liability for user-arranged meets. For a platform explicitly facilitating physical meetings between strangers, this is a significant legal gap. | `en_US.json:legal.terms.prohibited_*` |
| **MEDIUM** | No **governing law or jurisdiction** clause. The Terms reference the Indian IT Act 2000 and Intermediary Rules, implying Indian jurisdiction, but this is not explicit. International users (the app supports en_US and hi_IN) have no clarity on which courts apply. | `en_US.json:legal.terms.termination_body` |
| **MEDIUM** | The `legal.last_updated_date` key in i18n is a static string, not dynamically derived from `LEGAL_CONSENT_VERSION`. If the consent version env var is updated but the i18n `last_updated_date` is not, the displayed date and the recorded version will be out of sync. | `terms.astro:14`, `config/src/index.ts:175` |
| **LOW** | There is no **Disclaimer page link** in the site footer alongside Terms and Privacy, despite `disclaimer.astro` existing as a page. Legal pages are incomplete in the footer navigation. | `apps/web/src/pages/disclaimer.astro` (page exists but not in footer nav) |

### 15.4 Content Moderation & Safe Harbour

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | As an **Intermediary under India's IT Act 2000 / IT (Intermediary Guidelines) Rules 2021**, the platform must: publish a grievance redressal mechanism with a named Grievance Officer, respond to complaints within 24 hours, and resolve within 15 days. No Grievance Officer contact is visible in Terms, Privacy, or Guidelines pages. | `en_US.json:legal.terms.contact_body` |
| **HIGH** | The platform facilitates in-person meets between potentially anonymous users. There is no **safety disclaimer** advising users to meet in public places, not share personal addresses, etc. Competing platforms (ModelMayhem, Purpleport) include prominent safety guidelines for this reason. | `apps/web/src/pages/guidelines.astro` |
| **MEDIUM** | `ContentReport.reason` does not include `'UNDERAGE_CONTENT'` as a report category. Under CSAM laws (IT Act 2000 s.67B in India, CDA in USA), platform operators must report known CSAM to relevant authorities. Without a dedicated report reason, admin visibility of such reports is reduced. | `packages/config/src/index.ts:326-331` |
| **MEDIUM** | The auto-moderation system creates `ContentReport` records with `reporterId: null`. If these synthetic reports are ever subpoenaed as part of a legal proceeding, their machine-generated nature must be clearly distinguishable from user reports. There is no `isAutomated Boolean` flag on `ContentReport`. | `auto-moderation-report.ts:78`, `schema.prisma:284-301` |

---

## 16. Navigation — Issues & Improvements

### 16.1 Desktop Navigation

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **Nav link active state uses a global CSS selector that always highlights `/projects`** regardless of current page. The selector `:global(.nav-projects) .nav-link[href="/projects"], .nav-link[href="/projects"] { color: $color-accent; }` applies unconditionally — the Projects link is always accented. The correct pattern is `aria-current="page"` driven styling. | `apps/web/src/styles/layouts/base-layout.scss:196-199` |
| **HIGH** | **No "Create" / "Post" CTA in the navigation for authenticated users**. To post a new project, an authenticated user must navigate to `/projects` then find the create button, or remember the `/projects/create` URL. Major platforms (LinkedIn, Instagram, Behance) surface a prominent create action in the nav. | `BaseLayout.astro:254-280` |
| **HIGH** | **The "Messages" link is not in the desktop navigation**. Messages exist at `/messages` but the only nav access is via the profile dropdown (`nav-user-space__panel`). For a platform whose core loop involves DM communication, messages should be a first-class nav item with its own unread badge. | `BaseLayout.astro:418`, `base-layout.scss:535-573` |
| **MEDIUM** | The notification dropdown (`<details>`) **does not close when clicking outside** it. `<details>` is a native HTML disclosure widget — it has no built-in outside-click dismiss. While this can be fixed with a small Alpine.js click-outside handler, none is present. The panel stays open and overlaps page content. | `BaseLayout.astro:306`, `base-layout.scss:341-362` |
| **MEDIUM** | The notification and user-menu panels are positioned with `position: absolute; right: 0`. On small laptop screens (1024–1200px width) where the nav is crowded, these panels can overflow outside the viewport. No `max-width: 100vw` or viewport-edge detection is in place. | `base-layout.scss:345-362, 535-546` |
| **MEDIUM** | The **admin link in the nav only shows "Reports"** (`/admin/reports`). Admins who need to use the moderation queue (`/admin/moderation`) or user management (`/admin/users`) must navigate there manually — there is no admin section dropdown or breadcrumb. | `BaseLayout.astro:392-396` |
| **MEDIUM** | The `nav-search` form is `desktop-only` (hidden on mobile via class). Mobile users have no inline search — they must navigate to `/search` via the mobile nav. On mobile, search is a top-level nav item but shares the same list as Home/Projects/Contests/Events — there is no visual distinction or search icon prominence. | `BaseLayout.astro:284-293`, `base-layout.scss:203-210` |
| **LOW** | The logo text "TFP PLATFORM" is hidden at the `$breakpoint-md` to `1079px` range (tablets and small laptops). Only the camera icon shows. The brand name disappearing at this range can create a trust/recognition issue. | `base-layout.scss:129-131` |
| **LOW** | No **breadcrumb navigation** on detail pages (`/projects/[id]`, `/events/[id]`, `/contests/[id]`). Users who deep-link into a detail page have no context for where they are in the site hierarchy. | All `[id].astro` detail pages |

### 16.2 Mobile Navigation

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | The mobile nav requires **JavaScript to open/close** (`data-mobile-nav-toggle` handled by Alpine.js or custom script). If JS fails or is blocked, the mobile nav toggle button renders but does nothing — mobile users cannot access navigation at all. There is no CSS-only fallback. | `BaseLayout.astro:440-448`, mobile nav JS required |
| **HIGH** | When the mobile nav is open, **there is no focus trap**. A keyboard user pressing Tab will tab past the mobile nav items into the obscured page content below. This violates WCAG 2.1 Success Criterion 2.1.2 (No Keyboard Trap is required to be escapable, but trapping focus *inside* an open menu is the correct UX). | `mobile-nav` in `base-layout.scss:609-628` |
| **MEDIUM** | The mobile nav **does not close on route change** (since this is SSR, each nav click triggers a full page load — so this is fine). However, if Alpine.js manages any in-page state, the nav open state is preserved across soft navigations. | `BaseLayout.astro:452-480` |
| **MEDIUM** | On mobile, the authenticated user sees: Search, Home, Projects, Contests, Events, Notifications, (Admin if admin), Profile, Logout. The **"Messages" link is absent from the mobile nav**. Mobile users cannot access their inbox from the navigation. | `BaseLayout.astro:459-480` |
| **MEDIUM** | The mobile nav `<div id="mobile-nav">` is `position: absolute` inside `<header class="site-header">` which is `position: sticky`. On iOS Safari, sticky elements with absolutely-positioned children can create paint/scroll glitches especially with `backdrop-filter`. | `base-layout.scss:54-67, 609-628` |
| **LOW** | The mobile menu button has `aria-expanded="false"` hardcoded in HTML. Once JavaScript sets it to `true` when open, this is correct. However, if JS is disabled, the attribute is always `false` even when the menu might be showing via CSS. | `BaseLayout.astro:444` |

### 16.3 Footer Navigation

| Severity | Issue | Evidence |
|----------|-------|----------|
| **MEDIUM** | The footer has a `margin-bottom: calc(4.5rem + env(safe-area-inset-bottom, 0px))` on mobile. This suggests a bottom navigation bar is planned or existed but is not present in the current code. This creates unnecessary whitespace at the bottom of every mobile page. | `base-layout.scss:679` |
| **MEDIUM** | The `disclaimer.astro` page exists but is not linked in the footer legal section. The footer only links Terms and Privacy. The Disclaimer page is effectively unreachable unless the URL is known. | `apps/web/src/pages/disclaimer.astro`, footer markup in `BaseLayout.astro` |
| **LOW** | No **sitemap link** in the footer (human-readable sitemap, separate from `sitemap.xml`). | Footer in `BaseLayout.astro` |

---

## 17. UX Flows — Deep Dive

### 17.1 Registration & Login Flow

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **Error messages are passed as URL query parameters** (`?error=Invalid+email+or+password`). These leak into: browser history, server access logs, referrer headers when the user navigates away, and any analytics tool. Sensitive authentication errors should never be URL-encoded. | `apps/web/src/pages/login.astro:47,52` |
| **HIGH** | After registration, the user is redirected to `/` (homepage) with no welcome message, no profile setup prompt, and no indication of what to do next. First-time users land on the public homepage without any onboarding nudge. | `apps/web/src/pages/register.astro` (redirect to `/` on success) |
| **MEDIUM** | The login page has a "Remember me" checkbox that has **no functional effect** — the cookie maxAge is always `AUTH_SESSION_DAYS` (180 days) regardless of the checkbox state. Showing a non-functional control is deceptive UX. | `auth.routes.ts:27-28`, `login.astro:112-113` |
| **MEDIUM** | There is no **email verification flow**. A user can register with any email address (including a non-existent one) and immediately access all platform features. This enables spam account creation and makes the email field unreliable for notification delivery. | `auth.commands.ts` (no verification token logic) |
| **MEDIUM** | Password strength requirements are not shown during registration. The `registerSchema` enforces `min(8)` on password but the form provides no visual indicator of password strength or the minimum requirement. Users only learn of the requirement after a failed submission. | `auth.schemas.ts`, `register.astro` |
| **LOW** | Social login pages (`/auth/google`, `/auth/github`) render HTML pages that tell users the feature is coming soon, even in production. These pages are linked from nowhere but are publicly accessible and indexable. | `apps/web/src/pages/auth/google.astro`, `auth/github.astro` |

### 17.2 Project Creation & Application Flow

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | The project application form hardcodes `agreedToTerms: true` in the form submission regardless of whether the user checked any checkbox. The consent checkboxes (`consentSocial`, `consentEditing`, `consentTimeline`) are properly sent, but `agreedToTerms` is always `true` — a user can apply without actually reading or agreeing to anything. | `apps/web/src/pages/projects/[id].astro:63` — `agreedToTerms: true` hardcoded |
| **HIGH** | After a **failed project application** (e.g. quota exceeded, already applied), the error feedback is only a generic `?error=1` in the URL. The page then shows a hardcoded "An error occurred" message. Users cannot tell if they already applied, if the application period is closed, or if there was a server error. | `projects/[id].astro:89` |
| **MEDIUM** | The role selection in the project application form prepends the role as `[Role Prefix: <role>] <message>`. This means the role choice is embedded as a string prefix in a free-text message field, not as a structured data field. Creators must parse the role out of the message text manually. | `projects/[id].astro:62-63` |
| **MEDIUM** | There is no **project preview** before submission. A creator fills out a long create-project form and submits — if the moderation AI rejects their cover image, the entire project is in PENDING state with no image. There is no draft/preview flow. | `apps/web/src/pages/projects/create.astro` |
| **LOW** | After a **successful application**, the page shows `?applied=1` but the UI feedback is a banner that disappears on the next page load. There is no persistent "You've applied" state shown on the project card or detail page when the user returns. | `projects/[id].astro:93` |

### 17.3 Messaging Flow

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | Messages are **limited to 150 characters** (`MESSAGE_MAX_LENGTH = 150` in `messages.astro:22`). This is shorter than a tweet. For a platform facilitating project collaboration discussions, 150 characters severely limits communication. The API supports up to `2000` characters (`message.routes.ts`), but the frontend restricts to 150 — this is likely a development-era limit never updated. | `messages.astro:22`, `message.routes.ts` — API allows 2000 |
| **HIGH** | The messages page is a **full page load** for each sent message (POST → redirect → GET). There is no optimistic UI, no WebSocket, no streaming. A conversation with 20 messages requires the user to wait for 20 round-trips. | `messages.astro:24-46` |
| **MEDIUM** | Conversation list shows a maximum of **60 conversations** (`?limit=60`). Users with many contacts lose access to older conversations with no pagination or search. | `messages.astro:51` |
| **MEDIUM** | There is no **"New Message" flow** from a profile page. To message someone you discovered on `/profile/[email]`, you must navigate to `/messages`, find them in your conversation list (if you've messaged them before), or copy their user ID. There is no "Send Message" button on profile pages that initialises a new thread. | `profile/[email].astro` — no message CTA |
| **LOW** | The "sent" / "failed" / "too_long" feedback uses URL query parameters on the messages page. A user who sends a message and then refreshes the page will still see the "Message sent" confirmation on reload. | `messages.astro:19-22` |

### 17.4 Contest Detail & Submission Flow

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | Reaction feedback (like/vote/share) uses **full page redirects** with query parameters encoding the reaction result (`?reactionType=...&reactionCreated=...`). These parameters appear in browser history and the URL bar after every reaction click. A simpler fetch-based approach would avoid this. | `contests/[id].astro:50-51` |
| **HIGH** | The `select_winner` action on the contest detail page accepts a `forceWinnerDecision` boolean from a hidden form field. This boolean bypasses the judging-period check. Any user who discovers this field and is the contest owner can **force a winner selection outside the judging period** by sending a crafted POST request. The guard exists in the API but the form exposes the bypass. | `contests/[id].astro:76-84` |
| **MEDIUM** | Contest submissions page (`/contests/[id]/submissions`) does not show the **submitter's display name** prominently — only a small avatar. For community voting, knowing who submitted is important context. | `apps/web/src/pages/contests/[id]/submissions/index.astro` |
| **LOW** | After voting (`VOTE` reaction), users with an existing vote on another submission see an `ALREADY_VOTED_ON_CONTEST` error but the error message is surfaced only as a query parameter. The UI shows a generic "already voted" state without identifying which submission they voted for. | `contests/[id].astro:59-64` |

### 17.5 Profile & Settings Flow

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | The **profile edit page makes a separate `GET /auth/me` call** in addition to the one `BaseLayout.astro` already makes. This is a third API call on the profile edit page (BaseLayout × 2 + edit page × 1 = 3 API calls on a single page render). | `profile/edit.astro:27-37` |
| **HIGH** | **Profile image upload and profile data update are separate form submissions**. A user who wants to update their bio AND upload a new avatar must submit twice. If the image upload succeeds but the profile text update fails (or vice versa), the profile is in a partially updated state. | `profile/edit.astro:44-140` (separate avatar/cover/profile forms) |
| **MEDIUM** | There is **no success confirmation state** on the profile edit page. After a successful update, the page redirects back to `?success=1` but the query param is consumed and the user sees the default form again with no persistent indication that their profile was saved. | `profile/edit.astro` (redirect to edit page on success) |
| **MEDIUM** | `username` is a unique optional field on `User` but the profile edit form may not surface it for editing. If the username was never set, the profile URL falls back to email — which is the privacy issue described in Section 8.1. | `schema.prisma:19`, `profile/edit.astro` |

---

## 18. Responsive Design — Issues

### 18.1 Breakpoint System

The design uses three named breakpoints defined in `tokens.scss`:

```scss
$breakpoint-sm: 640px;
$breakpoint-md: 768px;
$breakpoint-lg: 1024px;
$breakpoint-xl: 1280px;
```

### 18.2 Navigation Responsive Issues

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | Between `768px` and approximately `1079px`, the **logo text is hidden** and nav items are shown. At this range the nav is: [camera icon] [Projects] [Contests] [Events] [search input] [globe] [notifications bell] [avatar]. The search input has a `min-width: 12rem` constraint — at 768px the total nav items can overflow the flex container and cause horizontal scroll or wrapping. | `base-layout.scss:129-131, 213-260` |
| **HIGH** | The `nav-actions` div (containing search, globe, bell, avatar) is `display: none` on mobile and `display: flex` on `≥768px`. However the desktop nav links (`.nav-links`) are also only shown on `≥768px`. Below 768px, **both the nav links AND the action area are hidden** — only the logo and hamburger button show. This is correct mobile behaviour but means authenticated users see no notification count at all on mobile without opening the mobile menu. | `base-layout.scss:203-210` |
| **MEDIUM** | The notification panel is `width: min(28rem, 80vw)`. On a 320px screen (iPhone SE), `80vw = 256px`. The panel fits but the content — 4 notification sections with titles, items, and a "View All" button — becomes extremely cramped at this width. No mobile-specific notification layout exists. | `base-layout.scss:349` |
| **MEDIUM** | The user-menu panel is `width: min(14rem, 72vw)`. On 320px screens this is `230px` positioned `right: 0`. Since the avatar is near the right edge of the screen, the panel aligns to the right edge correctly. But on screens where the nav is wider, `right: 0` positions the panel relative to the `<details>` container, which could cause the panel to clip outside the viewport on the left. | `base-layout.scss:539` |

### 18.3 Page-level Responsive Issues

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | The homepage (`index.astro`) has a **hero section, bento grid, and multiple feature sections**. The bento grid uses complex `grid-template-areas` with named regions. If the grid does not have a defined mobile fallback (`grid-template-columns: 1fr`), the bento layout can break on narrow screens. Needs visual verification at 320px, 375px, and 414px. | `apps/web/src/styles/pages/home.scss` |
| **MEDIUM** | The `ListingCard.astro` project variant uses a multi-tile image layout: `listing-card__media--project-1` through `-project-5` classes change the grid based on image count. On mobile, these multi-column image grids may not reflow properly if `grid-template-columns` is not reset to a single column in the responsive overrides. | `apps/web/src/styles/pages/listings.scss` (project card grid) |
| **MEDIUM** | Tables are used for the admin reports page (`admin/reports.astro`). HTML tables have notorious horizontal scroll issues on mobile. If no `overflow-x: auto` wrapper is present, tables will force the entire page to scroll horizontally on small screens. | `apps/web/src/styles/pages/admin-reports.scss` |
| **MEDIUM** | The messages page is a **two-column layout** (conversation list + message thread). On mobile, both columns would need to collapse into a single-column navigation (list → select → thread). If CSS does not handle this, the layout will be too narrow for both columns side by side on mobile. | `apps/web/src/styles/pages/messages.scss` |
| **LOW** | No explicit `touch-action: manipulation` on interactive elements (buttons, links). This can cause a 300ms tap delay on older iOS browsers that do not use fast-tap heuristics automatically. | Various button styles in `base.scss` |
| **LOW** | `scroll-behavior: smooth` is set globally in `base.scss:27`. On users with `prefers-reduced-motion: reduce`, smooth scrolling should be disabled. No `@media (prefers-reduced-motion: reduce)` override is present. | `base.scss:27` |
| **LOW** | The ambient glow background effects (`ambient-bg--primary`, `ambient-bg--secondary`) use `filter: blur(100px)` / `filter: blur(140px)`. Heavy CSS blur filters on fixed-position elements are GPU-intensive and can cause performance degradation on mid-range Android phones. | `base-layout.scss:11-51` |

### 18.4 Touch & Mobile UX

| Severity | Issue | Evidence |
|----------|-------|----------|
| **MEDIUM** | The `<details>/<summary>` pattern for the notification panel and user menu has **no touch-friendly minimum tap target**. The `summary` element (bell icon button) is `2.5rem × 2.5rem`, which meets the 44×44px minimum, but the notification items inside are styled as `<a>` tags with `padding: 0.5rem 0.75rem` — approximately 30–32px tall on mobile, below the 44px recommended minimum. | `base-layout.scss:399-407` |
| **MEDIUM** | There is no **pull-to-refresh** or infinite scroll on listing pages. Mobile users must use the pagination component (numbered buttons) to navigate through results. Numbered pagination on mobile requires precise tapping on small elements. | All listing pages using `Pagination.astro` |
| **LOW** | Form inputs do not set `inputmode` for numeric/email/search fields. For example, the search input should have `inputmode="search"` to trigger the correct mobile keyboard. | `BaseLayout.astro:286-292` |

---

## 19. Master Priority Matrix

### 🔴 Critical — Fix Immediately (Production Blockers)

1. **[MODERATION]** Set `ACTIVE_MODERATION_PROVIDER` to a real provider in production — NOOP silently approves all images — `config/src/index.ts:199`
2. **[SECURITY]** Enable Content Security Policy in `@fastify/helmet` — `server.ts:83`
3. **[LEGAL]** Add `og:image` and `twitter:image` to BaseLayout — `BaseLayout.astro`
4. **[LEGAL]** Cookie consent banner (GDPR/DPDP) before setting locale cookie — `middleware.ts:33-41`
5. **[LEGAL/UX]** Fix profile URLs to use `username` or `id` instead of email — `profile/[email].astro`
6. **[SEO]** Add `robots.txt` — `apps/web/public/`
7. **[SEO]** Fix dynamic sitemap to include contest/project/event/profile URLs — `sitemap.xml.ts`
8. **[LEGAL]** Add self-service account deletion (right to erasure) — `user.routes.ts`
9. **[MODERATION]** Remove auto-block without human review — require admin confirmation before `deletedAt` is set — `auto-moderation-report.ts:51-54`
10. **[LEGAL]** Add Grievance Officer contact to Terms/Guidelines (IT Act 2000 compliance) — `en_US.json`

### 🟠 High — Address Before Launch

11. **[USE CASE]** Integrate a payment gateway (Stripe/Razorpay) for PRO/PRO_PLUS subscriptions
12. **[USE CASE]** Implement digital model release / TFP agreement workflow with PDF and audit trail
13. **[LEGAL]** Add GDPR data export endpoint (`/api/users/me/export`)
14. **[UX]** Fix 150-character message limit in frontend — API supports 2000 — `messages.astro:22`
15. **[UX/LEGAL]** Fix `agreedToTerms: true` hardcoded in project application form — `projects/[id].astro:63`
16. **[NAV]** Add "Messages" link to desktop and mobile navigation with unread badge
17. **[NAV]** Fix always-on Projects nav active state CSS selector — `base-layout.scss:196-199`
18. **[MODERATION]** Add admin image moderation override UI (view, approve, reject individual images)
19. Strip EXIF metadata from uploaded images before storage
20. Reduce JWT session from 180 days to 7-30 days; fix `remember_me` functionality
21. Stop re-issuing JWT on every `/auth/me` call
22. Replace in-process EventEmitter with Redis Pub/Sub / durable queue
23. Externalize file uploads to cloud storage (remove `@fastify/static` for uploads)
24. Add CSRF protection for state-mutating forms
25. **[USE CASE]** Fix multi-prize winner assignment (create `ContestWinner` join table or array field)
26. Add database health check to `/ready` endpoint
27. Add rate limiting to upload, message, report, and reaction endpoints
28. **[LEGAL]** Add email verification flow on registration — `auth.commands.ts`
29. **[LEGAL]** Add safety disclaimer to guidelines page (for in-person meetings)
30. **[MODERATION]** Add `isAutomated` flag to `ContentReport` schema

### 🟡 Medium — Sprint Backlog

31. **[USE CASE]** Add location-based proximity filter to user discovery API
32. **[USE CASE]** Implement real-time messaging via WebSocket or Server-Sent Events
33. **[USE CASE]** Add event capacity limit and waitlist
34. **[USE CASE]** Add email notifications for new DM, application status changes
35. **[USE CASE]** Add applicant withdrawal endpoint (`DELETE /api/projects/:id/applications/me`)
36. **[USE CASE]** Add admin dashboard stats endpoint
37. **[USE CASE]** Add subscription tier management to admin panel
38. **[USE CASE]** Add automated contest lifecycle cron job (replace manual `/lifecycle/sync`)
39. **[NAV]** Add admin dropdown with links to /admin/moderation, /admin/users, /admin/reports
40. **[NAV]** Add "Create Project" CTA to authenticated desktop nav
41. **[NAV]** Add outside-click dismiss handler for notification and user-menu dropdowns
42. **[NAV]** Add focus trap for mobile navigation when open
43. **[NAV]** Fix footer margin-bottom on mobile (remove orphaned bottom-nav spacing) — `base-layout.scss:679`
44. **[NAV]** Add Disclaimer page to footer navigation
45. **[UX]** Add "Send Message" button on public profile pages
46. **[UX]** Remove or implement "Remember Me" checkbox — currently non-functional
47. **[UX]** Add error message differentiation on project application failures
48. **[UX]** Reduce profile edit page to 1 combined form (avatar + bio + metadata in one POST)
49. **[RESPONSIVE]** Verify homepage bento grid reflow at 320px/375px/414px
50. **[RESPONSIVE]** Add `overflow-x: auto` wrapper to admin reports table
51. **[RESPONSIVE]** Verify messages two-column layout collapses correctly on mobile
52. **[RESPONSIVE]** Add `@media (prefers-reduced-motion: reduce)` to disable smooth scroll and pulse animation
53. Cache user session lookup in auth middleware (Redis with short TTL)
54. Add pagination to admin moderation queue and reports
55. Fix heading hierarchy in `ListingCard.astro` (`h2` → `h3` in card context)
56. Add `aria-expanded` / `aria-controls` to mobile nav toggle
57. Add `aria-live` region for notification badge updates
58. **[LEGAL]** Move Terms/Privacy from i18n JSON to versioned auditable documents
59. **[LEGAL]** Add minimum age verification to registration
60. Fix `$primary-600` / `$primary-700` token value duplication — `tokens.scss:33-34`
61. Add `.env.example` file
62. Wire `@astrojs/sitemap` into `astro.config.mjs` or remove dead dependency
63. Remove `application/octet-stream` from allowed upload MIME types — `contest.routes.ts:75`
64. Add scheduled cleanup job for expired `PasswordResetToken` records
65. **[MODERATION]** Add `AI_REPEAT_OFFENDER` / `AI_MODERATION_REJECTED` to `REPORT_REASONS` with labels — `config/src/index.ts:326`

### 🟢 Low — Technical Debt / Polish

66. **[USE CASE]** Add follow/unfollow system and personalised activity feed
67. **[USE CASE]** Add post-collaboration rating/review system
68. **[USE CASE]** Add guided onboarding flow for new users
69. **[USE CASE]** Add content genre/style tagging
70. **[USE CASE]** Add "open for TFP" availability toggle on user profiles
71. **[USE CASE]** Add badge awarding logic (field exists, never populated)
72. **[USE CASE]** Add message deletion endpoint for sender
73. **[USE CASE]** Add "harassment", "underage", "impersonation" report reasons
74. **[NAV]** Add breadcrumb navigation to all detail pages
75. **[NAV]** Consider making logo text visible at tablet breakpoint
76. **[RESPONSIVE]** Add `touch-action: manipulation` to buttons/links
77. **[RESPONSIVE]** Add `inputmode` attributes to form inputs (email, search, tel)
78. **[RESPONSIVE]** Consider reducing ambient blur effect on low-power devices (`prefers-reduced-motion`)
79. **[MODERATION]** Consider per-content-type moderation strategy (not a single global config)
80. **[UX]** Remove social login pages from production if not implemented (`/auth/google`, `/auth/github`)
81. **[UX]** Add password strength indicator to registration form
82. Remove `.DS_Store` files and add to `.gitignore`
83. Create `ProjectCard`, `ContestCard`, `EventCard` sub-components from `ListingCard`
84. Define shared TypeScript types for API responses (eliminate `any`)
85. Add light mode / system-preference theme support
86. Add JSON-LD structured data for Contest, Event, and User entity pages
87. Add source maps (uploaded privately to error tracking)
88. Add Docker / Docker Compose configuration
89. Fix `pnpm` engine version mismatch in `package.json`
90. Mark auth/admin/social-login pages as `noindex`

---

## 20. Authentication & Authorization — Deep Dive

This section covers the full auth/authz layer: JWT lifecycle, session management, route-level guards, frontend page guards, input validation, upload security, and privilege escalation vectors.

---

### 20.1 JWT & Session Security

| Severity | Issue | Evidence |
|----------|-------|----------|
| **CRITICAL** | The **JWT cookie is `signed: false`** (`server.ts:109`). While the JWT payload itself is cryptographically signed with `JWT_SECRET`, the cookie transport wrapper is unsigned. A network-layer or same-site attacker who can inject cookies can substitute a crafted JWT. The correct setting is `signed: true` using `@fastify/cookie`'s HMAC signing on top of JWT signing (defence-in-depth). | `apps/api/src/server.ts:108-109` |
| **CRITICAL** | **`auth/me` re-issues a fresh JWT on every call** (`auth.routes.ts:215-216`). Since `BaseLayout.astro` calls `auth/me` on every SSR render, and `requireAdminSession` calls it again for admin pages, every page load results in 2 fresh JWT tokens being minted and set via `Set-Cookie`. When 2 browser tabs are open simultaneously, the two responses set different cookies — the second response's cookie wins, silently invalidating the first tab's token. This is a token-churn race condition that also makes token blacklisting impossible in practice. | `apps/api/src/modules/auth/auth.routes.ts:215-216`, `apps/web/src/layouts/BaseLayout.astro:69-79`, `apps/web/src/utils/admin-auth.ts:24-27` |
| **HIGH** | The **JWT `role` claim is embedded in the token** (`auth.commands.ts:20`). Although `auth.middleware.ts:54` re-queries the DB for the role on every authenticated request, the JWT payload still contains the role. A JWT obtained before a role change will contain the outdated role until the `auth/me` refresh cycle re-issues it. In the window between a role being revoked and the next `auth/me` call, the old role is still in the cookie's JWT — but since the middleware re-reads from DB this is mitigated server-side. However, any third-party service that trusts the JWT directly (e.g. a future microservice) would see the stale role. | `auth.commands.ts:20`, `auth.middleware.ts:42-55` |
| **HIGH** | **`POST /auth/logout` requires no authentication**. Any party can POST to this endpoint to clear the user's session cookie. Combined with the absence of CSRF tokens, a malicious page visited by a logged-in user could POST to the logout endpoint via a form and force-logout the user (logout CSRF). `sameSite: 'lax'` prevents cross-site POSTs from forms on **cross-origin navigations**, but `lax` does allow top-level navigation POST in some browser configurations. | `apps/api/src/modules/auth/auth.routes.ts:185-191` |
| **HIGH** | **No server-side token revocation list**. Deleting or disabling a user (`SetUserDisabled`, `SoftDeleteUser`) marks `deletedAt` in the DB, and `auth.middleware.ts:48` checks `activeUser.deletedAt` on every request — so disabled accounts are blocked correctly. However, if the DB check ever gets cached or moved to a stateless JWT-only flow, the 6-month token remains valid. There is no Redis-backed or DB-backed token blacklist for immediate invalidation. | `auth.middleware.ts:43-51`, `config/src/index.ts:163` |
| **MEDIUM** | **`displayName` defaults to the email local-part on registration**. If no `displayName` is provided, the register command sets `displayName: params.email.split('@')[0]`. This exposes a portion of the user's private email address as their public display name without the user's explicit consent. A user registering with `john.smith@gmail.com` would have a public `displayName` of `john.smith`. | `auth.commands.ts:62` |
| **MEDIUM** | **JWT `expiresIn` from config does not match cookie `maxAge`**. `JWT_EXPIRES_IN` defaults to `'180d'` (string, parsed by `jsonwebtoken`). `AUTH_SESSION_DAYS` defaults to `180` (integer, converted to seconds). These are set independently. If an operator sets `JWT_EXPIRES_IN=7d` but leaves `AUTH_SESSION_DAYS=180`, the cookie persists for 180 days but the JWT inside it expires after 7 days — causing confusing authentication failures. | `config/src/index.ts:163-164`, `auth.routes.ts:27` |
| **LOW** | **Password reset token not rate-limited at the validation step**. `GET /auth/reset-password/validate` has rate limiting configured, but the actual `POST /auth/reset-password` endpoint has the same limit (5 req / 15 min). A brute-force attacker who obtains a reset token hash collision window of 32 hex chars (64 bits) is unlikely to succeed within 5 attempts — this is acceptable — but the limit should also be tied to a specific email to prevent token-stuffing across multiple accounts. | `auth.routes.ts:148-183` |

---

### 20.2 API Route Authorization Gaps

| Severity | Issue | Evidence |
|----------|-------|----------|
| **CRITICAL** | **Contest creation is guarded by subscription quota, not by role**. `POST /contests/` calls `enforceMonthlyCreationQuota(request.userId, 'contest')` which returns `allowed: false` only because `contestsPerMonth: 0` for all user tiers. This is a **subscription limit used as an authorization check** — not a proper role guard. If any operator sets the env var `LIMIT_FREE_CONTESTS_PER_MONTH=1` (e.g., during testing), or if a user's `subscriptionTier` is updated directly in the DB, **regular users would be able to create contests**. The correct implementation requires an explicit `if (request.userRole !== 'ADMIN') return 403` before the quota check. | `apps/api/src/modules/contest/contest.routes.ts:428-440`, `packages/config/src/index.ts:246-257` |
| **CRITICAL** | **Admin routes have no route-level pre-handler guard**. All admin routes are registered under the `/admin` prefix but the `ensureAdmin()` guard is called manually inside each individual handler. If a developer adds a new handler to `admin.routes.ts` and forgets to call `ensureAdmin`, it becomes an unauthenticated admin endpoint. The correct pattern is to register a `preHandler` hook on the `/admin` plugin scope that enforces admin for all routes within it. | `apps/api/src/modules/admin/admin.routes.ts:42-48`, `apps/api/src/server.ts:308` |
| **HIGH** | **`POST /contests/uploads/banner` and `POST /contests/uploads/resource` are accessible to any authenticated user**, including regular `USER` role accounts. Since only admins should create contests, regular users have no legitimate reason to upload contest banners or resources. These files get stored and moderation-logged against the user's ID but never attached to a contest (because regular users can't create contests). This is a storage-abuse vector and creates orphaned files. An admin check should gate these endpoints. | `contest.routes.ts:314-423` |
| **HIGH** | **`GET /location/autocomplete` and `GET /location/reverse` have no authentication requirement**. These endpoints proxy requests to Geoapify (a paid API) using the platform's API key. Any unauthenticated caller on the internet can hit these endpoints to consume the platform's Geoapify quota and incur costs. A minimum requirement of `requireAuth` would prevent abuse without impacting UX (location search is only used in forms that require login). | `apps/api/src/modules/location/location.routes.ts:251-313` |
| **HIGH** | **`GET /users/:userId` accepts an email address as the `userId` parameter** (`GetPublicUserByIdOrEmail(userId)`). This means any actor who knows a user's email address can retrieve their full public profile (including profile images, location, bio, display name, roles). Email addresses are not secret, but using them as a lookup key merges authentication identity with public lookup identity — enabling enumeration attacks and profile scraping by email lists. | `user.routes.ts:107-122`, `user.queries.ts` (GetPublicUserByIdOrEmail) |
| **HIGH** | **Any authenticated user can send direct messages to any other user, including admins**, with no prior relationship, no block mechanism, no opt-out privacy setting. There is no per-user DM privacy setting (e.g., "only accepted connections can message me"). This enables harassment, admin impersonation attempts (user could DM an admin claiming to be another admin), and spam. | `message.routes.ts:88-135`, `schema.prisma` (no block/privacy model) |
| **MEDIUM** | **`PATCH /users/me` allows self-role assignment** for all roles except `ADMIN`. A user can set their own `role` to `PHOTOGRAPHER`, `MODEL`, `STYLIST`, or `MAKEUP_ARTIST` without any verification. Platforms typically require portfolio review, approval, or minimum criteria before assigning professional roles. Self-assignment undermines the role system and would devalue the `PHOTOGRAPHER` label if it becomes meaningless. | `user.routes.ts:154-156` — `role: z.enum(['USER', 'PHOTOGRAPHER', 'MODEL', 'STYLIST', 'MAKEUP_ARTIST'])` |
| **MEDIUM** | **`ensureAdmin` is re-implemented locally in `admin.routes.ts`** rather than using `requireAuth` + role check from the shared `auth-guards.ts`. This dual implementation diverges: the shared `requireAuth` reads `request.authErrorCode` for better error messaging; the local `ensureAdmin` skips this and always returns a generic `FORBIDDEN`. If `requireAuth` is ever updated (e.g., to add audit logging), the admin guard won't inherit the change. | `admin.routes.ts:42-48` vs `auth-guards.ts:12-26` |
| **MEDIUM** | **`PATCH /projects/:projectId/applications/:applicationId/status` does not verify the applicationId belongs to the projectId at the DB query level**. The handler calls `GetProjectApplication(projectId, applicationId)` — which should return `null` if they don't match — but if the query implementation ever changes, a project owner could update an application belonging to a different project by knowing a valid applicationId. The query should use `AND projectId = $1 AND id = $2` to be safe. | `project.routes.ts:424-443` — verify `GetProjectApplication` implementation |
| **MEDIUM** | **`requireAdminSession` in the frontend calls `auth/me` separately from `BaseLayout.astro`'s own `auth/me` call**. On every admin page render: `BaseLayout` calls `auth/me` (re-issues JWT, sets cookie #1), then `requireAdminSession` calls `auth/me` again (re-issues JWT, sets cookie #2). The second `Set-Cookie` wins. These two concurrent token refreshes can trigger a race condition in the browser's cookie jar where the `BaseLayout` token (set first) is silently overwritten by the `requireAdminSession` token. Admin pages make 2× the API calls of regular pages. | `admin-auth.ts:24-27`, `BaseLayout.astro:69-79` |
| **LOW** | **Auth middleware public-path check uses `startsWith()`**. The public paths are checked with `request.url.startsWith(path)`. The path `/api/v1/auth/login` would match a hypothetical `/api/v1/auth/login.malicious` URL. In practice, no such route exists so it's not exploitable, but this is a brittle pattern. An exact match (`===`) or suffix check (`.startsWith(path + '?')`) would be safer. | `auth.middleware.ts:15-26` |
| **LOW** | **`POST /auth/register` is gated by `FEATURE_REGISTRATION_ENABLED`** but the social login pages (`/auth/google`, `/auth/github`) render to HTML even when `FEATURE_SOCIAL_LOGIN=false`. If incomplete OAuth handlers exist, a user who POSTs directly to the OAuth callback URL could trigger partially implemented code. The social login feature flag should also suppress the API-side routes, not just the frontend pages. | `auth.routes.ts:73-82`, `config/src/index.ts:174` |

---

### 20.3 Frontend Page-Level Authorization

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **Admin pages are protected server-side via `requireAdminSession`**, which is correct for SSR. However, there is **no middleware-level guard** on the Astro side (e.g., in `src/middleware.ts`) that enforces admin access for the `/admin/*` path prefix. Each admin page individually imports and calls `requireAdminSession`. If a new admin page is added without calling `requireAdminSession`, it renders as an unprotected page. A centralized middleware guard in `apps/web/src/middleware.ts` would be more robust. | `apps/web/src/pages/admin/reports.astro:8-11`, `apps/web/src/pages/admin/moderation.astro:20-23`, `apps/web/src/pages/admin/users.astro:8-11` |
| **HIGH** | **The frontend `requireAdminSession` checks the role from `auth/me` response**, which in turn reads the DB role. This is correct. However, the role comparison is `mePayload?.data?.user?.role !== 'ADMIN'` using optional chaining — if the response structure changes or the `data.user` key is renamed, the role check silently passes (returns `undefined !== 'ADMIN'` → `true` → redirect). A strict equality check with a defined default would be safer. | `admin-auth.ts:36` |
| **MEDIUM** | **Profile edit page (`/profile/edit`) has no server-side auth guard visible in the Astro frontmatter** — it relies on the API rejecting unauthenticated requests. If the page renders the form HTML without an auth check, an unauthenticated user sees the full profile edit form before being redirected on submission. This is a UI issue, not a true security gap, but it leaks the form structure and field names. | `apps/web/src/pages/profile/edit.astro` — check for token guard |
| **MEDIUM** | **Error redirect from failed admin actions in `reports.astro` and `users.astro` swallows API errors silently**. When the `PATCH /admin/reports/...` or `DELETE /admin/users/:id` call fails, the page simply redirects back to the admin page with no error indicator. An admin might believe an action succeeded when it failed (e.g., attempting to delete a non-existent user). | `admin/reports.astro:26-33`, `admin/users.astro:26-32` |
| **LOW** | **`/profile/edit` makes 3 `auth/me` API calls on a single page load**: `BaseLayout.astro` calls `auth/me` once (line 69), `requireAdminSession` is NOT called here, but the edit page itself may call `auth/me` again to populate form defaults. Excessive API calls on a single page render slow SSR and churn JWT tokens. | `profile/edit.astro` — verify direct auth/me call |

---

### 20.4 Input Validation & Sanitization Gaps

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **`sanitizePlainText` uses a regex to strip HTML (`/<[^>]*>/g`)** rather than a proper HTML parser. Certain polyglot payloads can survive regex-based strippers. Example: `<scr<script>ipt>alert(1)</scr</script>ipt>` — the outer tags are stripped but the inner script survives. The correct approach is a whitelist-based sanitizer like `sanitize-html` with `allowedTags: []`. | `apps/api/src/utils/text-sanitize.ts:7-8` |
| **HIGH** | **User-submitted `role` filter in `GET /users/?role=` is passed to the DB as a raw string** with no enum validation (`role: z.string().optional()`). Prisma would safely handle this (it won't inject SQL), but passing an arbitrary string as a `where.role` filter could return empty results or expose edge-case Prisma behavior. The correct schema is `z.nativeEnum(UserRole).optional()` to constrain to valid enum values. | `user.routes.ts:78` — `role: z.string().optional()` |
| **MEDIUM** | **`consentSocial`, `consentEditing`, `consentTimeline` default to `true`** in the project application handler when not provided by the client (`data.consentSocial ?? true`). A minimally-crafted API request that omits these fields would record full consent in the DB. Combined with the frontend hardcoding `agreedToTerms: true` (§17.2), this means API-level applications are auto-consented on all fields. | `project.routes.ts:104-106` |
| **MEDIUM** | **No maximum age on password reset tokens beyond the TTL check**. Expired tokens remain in the DB indefinitely (only `usedAt` tokens trigger cleanup). The `forgotPasswordCommand` deletes unused tokens for the same user on a new request, but tokens for users who never request a second reset accumulate. A periodic cleanup job for expired tokens is missing. | `auth.commands.ts:99-113` — cleanup only on new request |
| **MEDIUM** | **Zod `.parse()` is used in some handlers and `.safeParse()` in others** inconsistently. `.parse()` throws a `ZodError` which is caught by the global error handler (`setErrorHandler`). `.safeParse()` allows manual error handling per-route. The inconsistency means some validation errors return the global 400 format and others return custom route-level formats, creating an inconsistent API contract for clients. | Various routes — e.g., `message.routes.ts:94` uses `safeParse`, `admin.routes.ts:94` uses `parse` |
| **LOW** | **The `displayName` field accepts Unicode including right-to-left override characters** (`\u202e`), zero-width characters, and homoglyph characters. A malicious user could create a displayName that visually impersonates another user's name or admin label. `sanitizePlainText` strips control characters `[\u0000-\u001F\u007F]` but not Unicode direction overrides or homoglyphs. | `text-sanitize.ts:9`, `user.routes.ts:162` |
| **LOW** | **`instagramUrl` and `portfolioUrl` are stored as plain strings** with no URL format validation in the profile update schema. A user could store `javascript:alert(1)` as their portfolio URL, and if the frontend renders it as an `<a href>` without sanitization, it becomes an XSS vector. The schema should enforce `z.string().url()` with an allowlist of `https://` schemes. | `user.routes.ts:151-157` — no instagramUrl/portfolioUrl in update schema; check profile schema |

---

### 20.5 File Upload Security Gaps

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **Presigned URL flow has no server-enforced file size limit**. `POST /me/avatar/presign` and similar endpoints validate MIME type and extension but the presigned URL issued to B2 does not include a `ContentLengthRange` constraint. An attacker with a valid auth token can upload arbitrarily large files to B2 (limited only by B2's defaults), bypassing the `MAX_FILE_SIZE` limit enforced by the multipart direct-upload path. | `user.routes.ts:184-210`, `contest.routes.ts:503-534` — no `maxSize` in `createPresignedUpload` call |
| **HIGH** | **TOCTOU (Time-of-Check Time-of-Use) window in presigned upload flow**. The flow is: (1) presign → (2) client uploads to B2 → (3) client POSTs to `/complete` → server downloads file from B2 for moderation → approves → updates DB. Between steps 2 and 3, another client call or race could replace the file at the same key in B2 before the server's moderation download. The approved file key is then saved to the DB but the file at that key has been swapped. This is theoretical but the window exists for B2 bucket configurations that allow overwrites. | `user.routes.ts:212-253` (avatar/complete flow) |
| **MEDIUM** | **`validateUploadMetadata` (used in presigned flow) does not check magic bytes** because it has no access to the buffer (the file hasn't been downloaded yet). This means the MIME type and extension validation for presigned uploads is client-supplied only — the buffer magic byte check only runs later in the `submitImageForModeration` call. A client could presign as `image/jpeg` but upload a different binary to B2. The magic byte check would catch this, but moderation must be correctly configured (not NOOP) to enforce it. | `upload-validation.ts:46-61` (validateUploadMetadata), `SubmitImageForModerationCommand.ts:31` |
| **MEDIUM** | **Orphaned upload files are never cleaned up**. When a user starts a presigned upload (draft-prefixed key created in B2) but never completes it (never calls `/complete`), or when a moodboard image is uploaded but the project creation fails, the file remains in B2 indefinitely. There is no garbage collection job for draft-prefixed or unlinked storage keys. | Storage paths in `user.routes.ts:200`, `project.routes.ts:186` — no cleanup on error |
| **MEDIUM** | **Contest resource files (`application/octet-stream`) are not scanned**. Contest resource files (PDF/ZIP/RAR) uploaded via `POST /contests/uploads/resource` are stored without malware scanning, content inspection, or magic byte validation (the contest resource upload uses a separate code path that only checks extension and MIME type without a magic byte buffer check). A malicious ZIP file could be distributed to contest participants. | `contest.routes.ts:379-423` — no magic byte check, no malware scan |
| **LOW** | **`normalizeExtension` uses `path.extname(filename).replace('.', '')`**. A filename like `evil.jpg.php` would return extension `php` which is blocked. But a file named `evil.jpg.` (trailing dot) returns an empty extension, which would fail the extension check with a confusing error. More importantly, double-extension filenames are blocked by the extension check, which is good, but this relies entirely on the extension check being the first line of defence — not magic bytes. | `upload-validation.ts:21-22` |

---

### 20.6 Privilege Escalation & Access Control Matrix

Summary of which roles can access which critical operations:

| Operation | `USER` | `PHOTOGRAPHER` etc. | `ADMIN` | Correct? |
|-----------|--------|---------------------|---------|----------|
| Create Project | ✅ (quota limited) | ✅ (quota limited) | ✅ (unlimited) | ✅ |
| Create Event | ✅ (quota limited) | ✅ (quota limited) | ✅ (unlimited) | ✅ |
| Create Contest | ❌ (quota=0) | ❌ (quota=0) | ✅ (unlimited) | ⚠️ quota-as-authz (see §20.2) |
| Upload Contest Banner | ✅ (no role check) | ✅ (no role check) | ✅ | ❌ should be ADMIN only |
| Upload Contest Resource | ✅ (no role check) | ✅ (no role check) | ✅ | ❌ should be ADMIN only |
| Self-assign professional role | ✅ (any non-ADMIN role) | ✅ | N/A | ⚠️ no verification |
| View own profile | ✅ | ✅ | ✅ | ✅ |
| Edit own profile | ✅ | ✅ | ✅ | ✅ |
| View any user by email | ✅ (unauthenticated too) | ✅ | ✅ | ⚠️ email enumeration |
| DM any user | ✅ (incl. admin) | ✅ | ✅ | ⚠️ no block/privacy |
| View pending content | ❌ (only own) | ❌ (only own) | ✅ | ✅ |
| Moderate content (approve/reject) | ❌ | ❌ | ✅ | ✅ |
| Access `/admin/*` pages | ❌ (redirected) | ❌ (redirected) | ✅ | ✅ (per-page guard) |
| Access geocoding API (no auth) | ✅ (unauthenticated) | ✅ | ✅ | ❌ should require auth |
| Report content | ✅ | ✅ | ✅ | ✅ |
| Submit moderation recheck (via report) | ✅ (indirect) | ✅ | ✅ | ⚠️ harassment vector |

---

### 20.7 Additional Security Findings

| Severity | Issue | Evidence |
|----------|-------|----------|
| **HIGH** | **`pushSystemMessage` in `server.ts` slices content to 150 characters** (`content.slice(0, 150)`) but is called with dynamically constructed template strings that include user-provided data (e.g., contest title, project title). A contest titled with 200+ characters would have its system message silently truncated without informing the recipient, potentially breaking the message mid-sentence. This is also the hardcoded magic number documented in §2.5. | `server.ts:142-145` |
| **HIGH** | **`forceWinnerDecision` exploit surface via frontend form**: The winner selection form on the contest detail page (`contests/[id].astro`) contains a hidden field `forceWinnerDecision` that maps to the `force: boolean` parameter on the API. The API endpoint is admin-only (correct). However, the frontend form field is a hidden HTML input — any user who inspects the form DOM can see and modify it. This is not a security issue for the API (admin guard is correct), but it means **non-admin users who inspect the page source can discover the `force` parameter exists**, learn about the judging-period bypass mechanism, and potentially use it via curl/Postman if they obtain an admin token. | `apps/web/src/pages/contests/[id].astro:76-84`, `contest.routes.ts:668-715` |
| **MEDIUM** | **No `Permissions-Policy` header is set**. Beyond the CSP that is currently disabled, modern browsers support `Permissions-Policy` (formerly `Feature-Policy`) to restrict access to APIs like camera, microphone, geolocation, and payment. Since the platform handles location data, disabling geolocation access via header prevents rogue scripts from requesting it. `@fastify/helmet` can set this header. | `server.ts:83-86` (helmet config) |
| **MEDIUM** | **`bcrypt` cost factor is hardcoded to `10`** in both `registerCommand` and `resetPasswordCommand`. bcrypt cost 10 was the OWASP minimum in ~2015. Current OWASP guidelines recommend a minimum of `12` for new applications (or Argon2id as the preferred algorithm). The lower cost factor makes offline brute-force attacks faster if the database is ever compromised. | `auth.commands.ts:56,147` — `bcrypt.hash(password, 10)` |
| **MEDIUM** | **`PasswordResetToken` records for expired tokens are never cleaned up** unless the same user requests another reset. An admin querying the `password_reset_tokens` table will see accumulating expired, unconsumed tokens. These are hashed so they're not a direct security risk, but they constitute unnecessary data retention under GDPR minimisation principles. | `auth.commands.ts:99-113` — no scheduled cleanup |
| **LOW** | **`x-device-fingerprint` header is read as-is from the request** for moderation audit logging. This header is entirely client-controlled. An attacker can set this to any value (including another user's fingerprint) to pollute the audit trail. Server-computed fingerprinting (user-agent + TLS fingerprint) should supplement or replace this. | `moderation/application/request-context.ts` |
| **LOW** | **`require_auth` pattern does not emit an audit log on failure**. When `requireAuth` returns `false` (unauthorized attempt), no log entry records which endpoint was attempted, from what IP, or which auth error code was present. Failed auth attempts to sensitive endpoints should be logged for intrusion detection. | `auth-guards.ts:17-25` |

---

*This document is a review artifact only. No code has been modified. All line number references are approximate and may drift as the codebase evolves.*

*Sections 1–13: Security, Database, Frontend, SEO, a11y, UI/UX, Legal, DevOps, Code Quality, Performance, Use Case Audit.*
*Sections 14–18: Deep dives into Moderation Pipeline, Legal Compliance, Navigation, UX Flows, and Responsive Design.*
*Section 20: Authentication & Authorization comprehensive security audit.*
