# TFP Photographers Platform — Validated Application Review

> **Reviewer:** Opus (AI-assisted deep-dive with code-level verification)  
> **Date:** March 8, 2026  
> **Scope:** Full-stack review — Backend, Frontend, Database, SEO, Accessibility, UI/UX, Legal/Compliance, DevOps  
> **Method:** Every finding verified against actual source code. Invalid findings from prior reviews are excluded and listed in Appendix A.

---

## Table of Contents

1. [Backend (API — Fastify)](#1-backend-api--fastify)
2. [Database & Schema (Prisma / PostgreSQL)](#2-database--schema-prisma--postgresql)
3. [Frontend (Astro + SCSS)](#3-frontend-astro--scss)
4. [SEO](#4-seo)
5. [Accessibility (a11y)](#5-accessibility-a11y)
6. [UI / UX](#6-ui--ux)
7. [Legal & Compliance](#7-legal--compliance)
8. [DevOps, Config & Infrastructure](#8-devops-config--infrastructure)
9. [Code Quality & Architecture](#9-code-quality--architecture)
10. [Performance](#10-performance)
11. [Authentication & Authorization — Deep Dive](#11-authentication--authorization--deep-dive)
12. [Navigation — Issues](#12-navigation--issues)
13. [UX Flows — Deep Dive](#13-ux-flows--deep-dive)
14. [Responsive Design — Issues](#14-responsive-design--issues)
15. [Use Case Audit — Missing, Incomplete & Broken Flows](#15-use-case-audit)
16. [Moderation System — Deep Dive](#16-moderation-system--deep-dive)
17. [New Findings (Not in Prior Reviews)](#17-new-findings)
18. [Priority Matrix](#18-priority-matrix)
19. [Appendix A — Invalid Findings from Prior Review](#appendix-a--invalid-findings-from-prior-review)

---

## 1. Backend (API — Fastify)

### 1.1 Security

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | `contentSecurityPolicy: false` — CSP is entirely disabled via `@fastify/helmet`. All pages are exposed to XSS attacks. | `server.ts:83-86` |
| **CRITICAL** | JWT cookie is `signed: false`. The cookie wrapper is unsigned, allowing cookie tampering at the transport layer. | `server.ts:108-109` |
| **HIGH** | `JWT_EXPIRES_IN` defaults to `180d` and `AUTH_SESSION_DAYS` defaults to 180. A stolen token is valid for 6 months with no server-side revocation mechanism. | `config/src/index.ts:163-164` |
| **HIGH** | CORS: `if (!origin) { callback(null, true); }` — requests with no `Origin` header bypass CORS entirely. | `server.ts:64-66` |
| **HIGH** | No CSRF protection. `sameSite: 'lax'` provides partial protection, but state-mutating POST/PATCH/DELETE endpoints do not verify CSRF tokens. | Auth routes, admin routes |
| **MEDIUM** | `trustProxy: true` without IP allowlist. Any `X-Forwarded-For` header is trusted, enabling IP spoofing for rate limiting bypass. | `server.ts:48` |
| **MEDIUM** | Open redirect potential: login redirect uses `formData.get('redirect')` with only a leading `/` check. A redirect to `//evil.com` could bypass the check. | `login.astro:41-44` |
| **MEDIUM** | Error messages exposed in URL query parameters: `?error=Invalid email or password`. These leak into browser history, server logs, and referrer headers. | `login.astro:47,52` |
| **LOW** | `JWT_SECRET` falls back to empty string `''` if env var is not set. Only fails at startup via `assertRuntimeConfig`, but in dev could silently run with an empty secret. | `config/src/index.ts:162` |
| **LOW** | `sanitizePlainText` strips HTML tags with regex `/<[^>]*>/g`, not a proper parser. Polyglot payloads like `<scr<script>ipt>` can survive regex-based stripping. | `text-sanitize.ts:7-8` |

### 1.2 Authentication & Sessions

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `auth/me` endpoint re-issues a fresh JWT on every call. `BaseLayout.astro` calls this on every page render, churning tokens continuously. Makes token revocation impractical. | `auth.routes.ts:215-216` |
| **HIGH** | The `remember_me` checkbox on login has no effect. Cookie `maxAge` is always `AUTH_SESSION_DAYS` regardless of checkbox state. | `login.astro:112-113`, `auth.routes.ts:27-28` |
| **MEDIUM** | Auth middleware calls `prisma.user.findUnique` on every authenticated request with no caching layer. One DB round-trip per request. | `auth.middleware.ts:43-46` |
| **MEDIUM** | Social login pages (`/auth/google`, `/auth/github`) render in production but `FEATURE_SOCIAL_LOGIN` defaults to `false`. Non-functional UI creates confusion. | `auth/google.astro`, `config/src/index.ts:174` |
| **LOW** | No account lockout or exponential backoff after repeated failed login attempts beyond rate limiting (10 req/minute). | `auth.routes.ts:38-40` |

### 1.3 Rate Limiting

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Rate limiting is only applied to auth and password-reset endpoints. Upload, message-send, report-submit, reaction, and moderation endpoints have no rate limiting. | `server.ts:88-96` |
| **MEDIUM** | `global: false` means rate limiting is opt-in per route. Any new route added without explicit `config.rateLimit` gets no protection. | `server.ts:90` |

### 1.4 File Uploads & Storage

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | User-uploaded files are served directly by `@fastify/static` from the API server's local filesystem (`apps/api/uploads/`). Lost on container restarts or horizontal scaling. | `server.ts:121-127` |
| **MEDIUM** | RAR files are allowed as contest resources. RAR extraction can be dangerous; consider restricting to ZIP/PDF only. | `contest.routes.ts:68-76` |
| **MEDIUM** | `application/octet-stream` is in the allowed MIME types for resource uploads. This wildcard type bypasses MIME-based validation. | `contest.routes.ts:75` |
| **LOW** | EXIF metadata from uploaded images is not stripped before storage. GPS coordinates, camera serial numbers in EXIF are a privacy risk. | `schema.prisma:62` |

### 1.5 Logging & Observability

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `console.error` is used in `admin.routes.ts` (lines 72, 138) instead of `app.log.error`. Bypasses structured Pino logger. | `admin.routes.ts:72,138` |
| **LOW** | No request correlation IDs are generated or forwarded. Distributed tracing is not possible. | `server.ts` |
| **LOW** | `pushSystemMessage` content is sliced to 150 chars — hardcoded magic number. Should be a named constant. | `server.ts:142` |

### 1.6 Architecture

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | The event bus uses a singleton Node.js EventEmitter. In-process only — horizontal scaling means events are silently dropped on other instances. | `shared/src/eventBus.ts:10-11` |
| **MEDIUM** | `moderationFailurePayload` is defined identically in both `user.routes.ts:60-69` and `contest.routes.ts:77-86`. Direct code duplication. | `user.routes.ts`, `contest.routes.ts` |
| **MEDIUM** | Search is implemented client-side in `search.astro` — fetches all records and scores them in-memory with no pagination. Does not scale beyond a few hundred records. | `search.astro:71-100` |
| **LOW** | `ensureAdmin` is redefined locally in `admin.routes.ts:42-48` instead of reusing from `auth-guards.ts`. | `admin.routes.ts:42-48` |

---

## 2. Database & Schema (Prisma / PostgreSQL)

### 2.1 Schema Design

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `location Json?` on `User`, `Project`, and `Event` has no database-level schema enforcement. Invalid location objects can be stored silently. | `schema.prisma:30, 165, 249` |
| **HIGH** | `budget Json?` on `Project` and `entryFees Json?` on `Event` share the same issue — unstructured JSON with no enforcement. | `schema.prisma:169, 250` |
| **MEDIUM** | `secondaryRoles String[]` and `badges String[]` on `User` have no enum enforcement at the database level. | `schema.prisma:21,31` |
| **MEDIUM** | Soft deletes (`deletedAt`) are used across many models but no Prisma middleware auto-filters them. Every query must manually include `deletedAt: null`. | `schema.prisma` (multiple models) |
| **MEDIUM** | `PasswordResetToken` records accumulate indefinitely. No scheduled cleanup for expired or used tokens. Note: cleanup only happens when the same user requests another reset. | `schema.prisma:303-316`, `auth.commands.ts:99-113` |
| **LOW** | `exifData Json?` on `PortfolioImage` stores raw EXIF data which can contain GPS coordinates and device identifiers. GDPR/privacy concern. | `schema.prisma:62` |
| **LOW** | `$primary-600` and `$primary-700` have the same value `#4338ca` in `tokens.scss`. May be intentional but suspicious. | `tokens.scss:32-33` |

### 2.2 Query Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | No full-text search indexes on `title` or `description` despite search being a core feature. SSR search filters in-memory after fetching all records. | `schema.prisma` (missing FTS indexes) |
| **LOW** | `DirectMessage` has composite index on `[senderId, recipientId, createdAt]` and separate indexes on `[senderId, createdAt]` and `[recipientId, createdAt]`, which is adequate. | `schema.prisma:237-239` |

---

## 3. Frontend (Astro + SCSS)

### 3.1 Type Safety

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `ListingCard.astro` uses `item: any` for its main data prop. Loses all type safety across the most-used component. | `ListingCard.astro:14` |
| **MEDIUM** | Multiple pages use `any` extensively for API response types. A shared type library would prevent runtime errors. | `index.astro`, `search.astro`, etc. |
| **LOW** | `admin-auth.ts` uses `Astro: any` in its function signature, bypassing type checking for the Astro context. | `admin-auth.ts:12` |

### 3.2 Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `BaseLayout.astro` makes two API calls on every page render: `GET /auth/me` and `GET /users/me/notifications`. For authenticated SSR, 2 round-trips minimum per page. | `BaseLayout.astro:67-170` |
| **MEDIUM** | Notifications data is fetched on every page render even for pages where the user is unlikely to check notifications. Should be lazy/on demand. | `BaseLayout.astro:112-169` |
| **LOW** | The `Inter` font family is declared in CSS tokens but there is no `<link rel="preload">` or CDN import. Font will flash or fall back. | `tokens.scss:121` |

### 3.3 Assets & Files

| Severity | Issue | Location |
|----------|-------|----------|
| **LOW** | `.DS_Store` macOS metadata files are committed to the repository (`apps/web/src/styles/.DS_Store`, `apps/web/src/.DS_Store`, `apps/web/.DS_Store`). | `.gitignore` needs update |
| **LOW** | `@astrojs/sitemap` is in `web/package.json` but is NOT added to the `integrations` array in `astro.config.mjs`. Dead dependency. | `astro.config.mjs:10` |

### 3.4 Component Design

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `ListingCard.astro` handles three completely different layouts (project, contest, event) in one monolithic component with large conditional blocks. Violates SRP. | `ListingCard.astro` |

---

## 4. SEO

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | No `og:image` or `twitter:image` meta tags anywhere. Social sharing links show no preview image. Major growth blocker. | `BaseLayout.astro:220-228` |
| **HIGH** | Sitemap only contains static paths. Dynamic pages (contest details, project details, event details, profiles) are entirely absent. Search engines cannot index core content. | `sitemap.xml.ts:3-15` |
| **HIGH** | `@astrojs/sitemap` is installed but not wired into `astro.config.mjs`. No automatic sitemap generated. | `astro.config.mjs:10` |
| **HIGH** | No `robots.txt` file found in `apps/web/public/`. Crawlers will use default behaviour and crawl admin/auth pages. | `apps/web/public/` |
| **MEDIUM** | Auth and admin pages are indexable in production (`meta robots` is `index,follow` for `isProduction`). Login, register, admin pages should be `noindex`. | `BaseLayout.astro:205` |
| **MEDIUM** | No JSON-LD structured data for entities. Contest pages should have `Event`/`Competition` schema, event pages should have `Event` schema, profiles should have `Person` schema. Only a generic `WebSite` schema exists. | `BaseLayout.astro:176-191` |
| **MEDIUM** | `changefreq` is `daily` for all static pages and `lastmod` is always `now`. Gives no real signal to crawlers about content freshness. | `sitemap.xml.ts:22` |
| **LOW** | Profile URLs use the user's email as the URL slug (`/profile/user@example.com`). Email-as-URL is indexed by Google, making user emails discoverable via search. | `profile/[email].astro` |

---

## 5. Accessibility (a11y)

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | The notification dropdown uses `<details>/<summary>` but has no `role="region"`, no `aria-label`, and status changes (badge count) are not announced via `aria-live`. | `BaseLayout.astro:306-391` |
| **MEDIUM** | The navigation search `<Icon>` before the input is not explicitly `aria-hidden`. Screen readers may announce it redundantly. | `BaseLayout.astro:284-293` |
| **MEDIUM** | `<details>/<summary>` notification panel does not close on outside click. Creates UX issue where panel overlaps content. | `BaseLayout.astro:306` |
| **MEDIUM** | `$text-disabled: #94a3b8` and `$text-tertiary: #94a3b8` are identical. Contrast ratio of `#94a3b8` on `#0f1115` is ~5.9:1 — meets WCAG AA but fails AAA despite token comment claiming AAA compliance. | `tokens.scss:54-55` |
| **MEDIUM** | Form submit buttons show no `aria-busy` or disabled state during submission. Users with assistive tech get no indication of processing. | Various form pages |
| **LOW** | No `lang` attribute change triggered when locale switches. Dynamic locale switching would need a full page reload. | `BaseLayout.astro:195-196` |

---

## 6. UI / UX

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Email exposed in profile URLs (`/profile/user@example.com`). Significant privacy risk. Should use username or ID. | `profile/[email].astro` |
| **HIGH** | No loading/skeleton states for main content areas. SSR pages show blank content until server responds. | All listing pages |
| **MEDIUM** | Notification panel is a `<details>` element but does not auto-close when focus leaves it. Panel stays open, overlapping content. | `BaseLayout.astro:306` |
| **MEDIUM** | Admin moderation queue (`/admin/moderation`) has no pagination. `GetModerationQueue` loads all pending items at once. | Admin routes |
| **MEDIUM** | Two separate upload flows exist for avatar: direct multipart POST and presigned URL flow. Dual path is confusing and moderation flow differs. | `user.routes.ts:184-313` |
| **LOW** | Dark mode only. No light mode or system-preference-based theme. Users with photosensitivity are not accommodated. | `tokens.scss` |
| **LOW** | Search is entirely client-side text matching with no fuzzy search or typo tolerance. | `search.astro:71-79` |

---

## 7. Legal & Compliance

### 7.1 Privacy & GDPR/DPDP

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | No cookie consent banner. The middleware sets a `locale` cookie on every visitor unconditionally with 365-day maxAge. GDPR and DPDP require consent for non-essential cookies. | `middleware.ts:33-41` |
| **CRITICAL** | No GDPR data export (portability) endpoint. Privacy Policy references data portability rights, but no `/api/users/me/export` exists. | `apps/api/src/modules/user/` |
| **HIGH** | User email embedded in public profile URLs. Publishes user emails to search engines and web scrapers. GDPR/DPDP data minimisation violation. | `profile/[email].astro` |
| **HIGH** | EXIF metadata stored in `PortfolioImage.exifData` can contain GPS coordinates and device serial numbers. No UI for users to opt out or view captured EXIF data. | `schema.prisma:62` |
| **HIGH** | No right-to-erasure endpoint for self-service account deletion. `SoftDeleteUser` exists as admin command only. GDPR/DPDP require self-service deletion. | `apps/api/src/modules/user/` |
| **HIGH** | Legal content stored in i18n JSON files. Terms/Privacy are not versioned documents — changes are not auditable, not versioned, not communicated to users. | `en_US.json:150-238` |
| **MEDIUM** | `deviceTrackingConsentAt` and `consentVersion` fields exist but no UI for users to grant or withdraw device tracking consent after registration. | `schema.prisma:28-29` |
| **MEDIUM** | The `locale` cookie is set with `httpOnly: false`, accessible to JavaScript. Exposes locale preference to any third-party scripts. | `middleware.ts:37` |
| **MEDIUM** | Age verification absent from registration. The platform facilitates in-person photo shoots. Without a minimum age check, the platform may host minor accounts. | `auth.commands.ts` |

### 7.2 Terms of Service

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Terms of Service does not specify governing jurisdiction explicitly. References Indian IT Act 2000 but no explicit choice-of-law clause. | `en_US.json:177-195` |
| **LOW** | Terms do not address intellectual property disputes between platform users — only between users and the platform. | `en_US.json:180` |

### 7.3 Content Moderation & Safety

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Content moderation defaults to `NOOP` provider. In production with `ACTIVE_MODERATION_PROVIDER=noop`, no image moderation occurs. Not enforced in `assertRuntimeConfig`. | `config/src/index.ts:199`, `assertRuntimeConfig:368-378` |
| **LOW** | Report reasons limited to `ADULT_CONTENT`, `VIOLENCE`, `COPYRIGHT_INFRINGEMENT`, `SPAM`. Missing "harassment", "underage", "impersonation" categories. | `config/src/index.ts:326-331` |

---

## 8. DevOps, Config & Infrastructure

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | The `uploads` directory is inside the API application directory. In containerized/serverless deployments, data is ephemeral and lost on restart. | `server.ts:121-127` |
| **HIGH** | The in-process EventEmitter event bus is incompatible with horizontal scaling. Multiple API instances won't share events. Needs Redis Pub/Sub or similar. | `shared/src/eventBus.ts` |
| **MEDIUM** | `LEGAL_CONSENT_VERSION` is hardcoded in config as `'2026-03-08'` — not read from env despite being in the `ENV` object. Legal versioning must be environment-controlled. | `config/src/index.ts:175` |
| **LOW** | `pnpm` engine requirement is `>=8.0.0` but workspace uses `pnpm@10.30.1`. The `engines` constraint doesn't match `packageManager` field. | `package.json:6,40` |
| **LOW** | `sourcemap: false` in Vite production build. Makes debugging production errors harder. Consider uploading source maps to error tracking service. | `astro.config.mjs:23` |

---

## 9. Code Quality & Architecture

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | `search.astro` implements text scoring in SSR by fetching all records and filtering in-memory. Will fail at scale (>500 records). A proper search API endpoint is needed. | `search.astro:61-100` |
| **MEDIUM** | `locationSchema` is defined in `validation-schemas.ts` but the location field structure is also manually reconstructed in `user.routes.ts:164-173`. Single source of truth missing. | `user.routes.ts`, `validation-schemas.ts` |
| **MEDIUM** | Multiple route modules define their own local `toPublicUrl` helper with slightly different signatures. Should be a single shared utility. | `user.routes.ts:56-59`, `contest.routes.ts:63-66` |
| **LOW** | TypeScript `any` used throughout frontend pages. Defining shared API response types would improve correctness. | Multiple `.astro` files |

---

## 10. Performance

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Every authenticated SSR page render triggers at minimum 2 API calls (auth/me + notifications). 50ms API response = 100ms added to every page. | `BaseLayout.astro:67-170` |
| **HIGH** | Auth middleware makes a `prisma.user.findUnique` on every request. No Redis/memory cache. 100 concurrent users = 100 user-lookup queries/second just for session validation. | `auth.middleware.ts:43-46` |
| **MEDIUM** | Static site metadata for public API responses uses `max-age=60, stale-while-revalidate=300`. For content that changes infrequently, these TTLs are very short. | `server.ts:355-361` |

---

## 11. Authentication & Authorization — Deep Dive

### 11.1 JWT & Session Security

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | `auth/me` re-issues a fresh JWT on every call. BaseLayout calls `auth/me` on every SSR render, `requireAdminSession` calls it again for admin pages. Two browser tabs create token-churn race conditions. Makes blacklisting impossible. | `auth.routes.ts:215-216`, `BaseLayout.astro:69-79`, `admin-auth.ts:24-27` |
| **HIGH** | JWT `role` claim is embedded in the token. Although middleware re-queries DB for role, any future microservice trusting the JWT directly would see stale roles. | `auth.commands.ts:20`, `auth.middleware.ts:42-55` |
| **HIGH** | `POST /auth/logout` requires no authentication. Any party can POST to clear session cookie. Combined with no CSRF tokens, a malicious page could force-logout users. | `auth.routes.ts:185-191` |
| **HIGH** | No server-side token revocation list. If DB check gets cached or moved to stateless JWT-only flow, 6-month tokens remain valid indefinitely. | `auth.middleware.ts:43-51` |
| **MEDIUM** | `displayName` defaults to email local-part on registration (`params.email.split('@')[0]`). Exposes portion of private email as public display name without explicit consent. | `auth.commands.ts:62` |
| **MEDIUM** | JWT `expiresIn` from config does not match cookie `maxAge`. Set independently — if operator sets `JWT_EXPIRES_IN=7d` but leaves `AUTH_SESSION_DAYS=180`, confusing auth failures occur. | `config/src/index.ts:163-164` |

### 11.2 API Route Authorization Gaps

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | Contest creation is guarded by subscription quota (0 for all tiers), not by role. If any operator sets `LIMIT_FREE_CONTESTS_PER_MONTH=1` or updates DB tier directly, regular users can create contests. Needs explicit admin role check. | `contest.routes.ts:428-440`, `config/src/index.ts:246` |
| **HIGH** | `POST /contests/uploads/banner` and `POST /contests/uploads/resource` are accessible to any authenticated user, not just admins. Regular users can upload contest banners/resources creating orphaned files and storage abuse. | `contest.routes.ts:314-423` |
| **HIGH** | `GET /location/autocomplete` and `GET /location/reverse` have no authentication requirement. Any unauthenticated caller can consume the platform's Geoapify API quota. | `location.routes.ts:251-313` |
| **HIGH** | `GET /users/:userId` accepts email as the `userId` parameter (`GetPublicUserByIdOrEmail`). Enables profile enumeration by email lists. | `user.routes.ts:107-122` |
| **HIGH** | Any authenticated user can send DMs to any other user including admins, with no prior relationship, no block mechanism, no opt-out privacy setting. Enables harassment and spam. | `message.routes.ts:88-135` |
| **MEDIUM** | `PATCH /users/me` allows self-role assignment for all roles except `ADMIN`. No verification or portfolio review required to claim `PHOTOGRAPHER` or `MODEL`. | `user.routes.ts:155` |
| **MEDIUM** | `ensureAdmin` is re-implemented locally in `admin.routes.ts` rather than using shared `requireAuth` + role check from `auth-guards.ts`. Dual implementation can diverge. | `admin.routes.ts:42-48` |

### 11.3 Frontend Page-Level Authorization

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Admin pages are protected by individually calling `requireAdminSession`. No middleware-level guard for `/admin/*` path prefix. New admin page without the call is unprotected. | `admin/reports.astro`, `admin/moderation.astro`, `admin/users.astro` |
| **HIGH** | `requireAdminSession` role comparison uses optional chaining: `mePayload?.data?.user?.role !== 'ADMIN'`. If response structure changes, check silently passes (undefined !== 'ADMIN' = true = redirect). | `admin-auth.ts:36` |
| **MEDIUM** | Error redirect from failed admin actions swallows API errors silently. Admin might believe action succeeded when it failed. | `admin/reports.astro`, `admin/users.astro` |

### 11.4 Input Validation & Sanitization Gaps

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `sanitizePlainText` uses regex `/<[^>]*>/g` rather than a proper HTML parser. Polyglot payloads can survive. | `text-sanitize.ts:7-8` |
| **HIGH** | User-submitted `role` filter in `GET /users/?role=` is `z.string().optional()` with no enum validation. Should be `z.nativeEnum(UserRole).optional()`. | `user.routes.ts:78` |
| **MEDIUM** | `consentSocial`, `consentEditing`, `consentTimeline` default to `true` in project application handler when not provided (`data.consentSocial ?? true`). API-level applications are auto-consented. | `project.routes.ts:104-106` |
| **MEDIUM** | Zod `.parse()` vs `.safeParse()` used inconsistently across handlers. Creates inconsistent API error response formats. | Various routes |
| **LOW** | `displayName` accepts Unicode including RTL override characters and homoglyphs. `sanitizePlainText` strips control chars but not Unicode direction overrides. | `text-sanitize.ts:9`, `user.routes.ts:162` |

### 11.5 File Upload Security Gaps

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Presigned URL flow has no server-enforced file size limit. No `ContentLengthRange` in presigned URL. Attackers can upload arbitrarily large files to B2. | `user.routes.ts:184-210` |
| **HIGH** | TOCTOU window in presigned upload flow. Between client upload to B2 and server's moderation download, file at the key could be swapped (if B2 allows overwrites). | `user.routes.ts:212-253` |
| **MEDIUM** | `validateUploadMetadata` (presigned flow) has no access to buffer, so MIME validation is client-supplied only. Magic byte check runs later in moderation but depends on moderation not being NOOP. | `upload-validation.ts:46-61` |
| **MEDIUM** | Orphaned upload files are never cleaned up. Draft-prefixed or unlinked storage keys remain in B2 indefinitely. No garbage collection job. | Various upload handlers |
| **MEDIUM** | Contest resource files (PDF/ZIP/RAR) are stored without malware scanning, content inspection, or magic byte validation. | `contest.routes.ts:379-423` |

### 11.6 Additional Security Findings

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | No `Permissions-Policy` header set. Modern browsers support it to restrict camera, microphone, geolocation APIs from rogue scripts. | `server.ts:83-86` |
| **MEDIUM** | `bcrypt` cost factor is hardcoded to `10`. Current OWASP recommends minimum `12` for new applications. Lower cost factor makes offline brute-force faster. | `auth.commands.ts:56,147` |
| **LOW** | `x-device-fingerprint` header is read as-is from request for audit logging. Entirely client-controlled — attacker can pollute audit trail. | `moderation/application/request-context.ts` |
| **LOW** | `requireAuth` pattern does not emit audit log on failure. Failed auth attempts to sensitive endpoints are not logged for intrusion detection. | `auth-guards.ts:17-25` |

---

## 12. Navigation — Issues

### 12.1 Desktop Navigation

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Nav link active state CSS always highlights Projects regardless of current page. The CSS rule `.nav-link[href="/projects"] { color: $color-accent; }` applies unconditionally — no class scope is applied. | `base-layout.scss:196-199` |
| **MEDIUM** | Notification and user-menu panels positioned with `position: absolute; right: 0`. On small laptops (1024-1200px), panels can overflow outside viewport. | `base-layout.scss:345-362, 535-546` |
| **MEDIUM** | Admin link in nav only shows "Reports" (`/admin/reports`). No dropdown for moderation queue or user management. | `BaseLayout.astro:392-396` |
| **MEDIUM** | `nav-search` form is `desktop-only`. Mobile users must navigate to `/search` via the mobile nav. No visual search prominence on mobile. | `BaseLayout.astro:284-293` |

### 12.2 Mobile Navigation

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Mobile nav requires JavaScript to open/close. If JS fails, the toggle button renders but does nothing — mobile users cannot access navigation at all. No CSS-only fallback. | `BaseLayout.astro:440-448` |
| **HIGH** | When mobile nav is open, there is no focus trap. Keyboard users can tab past mobile nav items into obscured page content. | Mobile nav section |
| **MEDIUM** | The "Messages" link is not a first-class item in the mobile bottom nav (only Home, Projects, Events, Profile). Available in the hamburger menu but not in the persistent bottom nav. | `BaseLayout.astro:543-560` |

---

## 13. UX Flows — Deep Dive

### 13.1 Registration & Login Flow

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Error messages passed as URL query parameters (`?error=Invalid+email+or+password`). Leaks into browser history, server logs, referrer headers. | `login.astro:47,52` |
| **MEDIUM** | "Remember me" checkbox has no functional effect — cookie maxAge is always `AUTH_SESSION_DAYS`. Deceptive UX. | `auth.routes.ts:27-28`, `login.astro:112` |
| **MEDIUM** | No email verification flow. Users can register with non-existent emails and immediately access all features. Enables spam accounts. | `auth.commands.ts` |
| **MEDIUM** | Password strength requirements not shown during registration. Zod enforces `min(8)` but no visual indicator shown. Users learn of requirement only after failed submission. | `register.astro` |
| **LOW** | Social login pages render "coming soon" HTML even in production. Publicly accessible and indexable. | `auth/google.astro`, `auth/github.astro` |

### 13.2 Project Application Flow

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Project application form hardcodes `agreedToTerms: true` regardless of checkbox state. User can apply without actually reading or agreeing to anything. | `projects/[id].astro:63` |
| **HIGH** | After failed project application, error feedback is only a generic `?error=1` in URL. Users cannot tell if they already applied, if period is closed, or if there was a server error. | `projects/[id].astro:89` |
| **MEDIUM** | Role selection is embedded as string prefix in free-text message field (`[Role Prefix: <role>] <message>`). Not structured data — creators must parse manually. | `projects/[id].astro:62-63` |
| **MEDIUM** | No project preview/draft before submission. If moderation AI rejects cover image, entire project is PENDING with no image. | `projects/create.astro` |

### 13.3 Messaging Flow

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Messages limited to 150 characters in frontend (`MESSAGE_MAX_LENGTH = 150` in `message.services.ts:3` and `messages.astro:22`). API supports up to 2000 characters. This is likely a dev-era limit never updated. | `message.services.ts:3`, `messages.astro:22` |
| **HIGH** | Messages page is full page load for each sent message (POST → redirect → GET). No optimistic UI, no WebSocket. | `messages.astro:24-46` |
| **MEDIUM** | Conversation list maximum 60 conversations (`?limit=60`). No pagination or search for older conversations. | `messages.astro:51` |
| **MEDIUM** | No "Send Message" button on profile pages. To message someone you must navigate to `/messages` and find them. | `profile/[email].astro` |

### 13.4 Contest Flow

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Reaction feedback (like/vote/share) uses full page redirects with query parameters. Parameters appear in browser history after every reaction click. | `contests/[id].astro:50-51` |
| **HIGH** | `select_winner` form contains hidden `forceWinnerDecision` field that bypasses judging-period check. Any admin inspecting DOM can discover this bypass mechanism. | `contests/[id].astro:76-84` |

### 13.5 Profile & Settings Flow

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Profile edit page makes a separate `GET /auth/me` call in addition to the one BaseLayout already makes. Third API call on a single page render. | `profile/edit.astro:27-37` |
| **HIGH** | Profile image upload and profile data update are separate form submissions. Partial update state possible if one succeeds and the other fails. | `profile/edit.astro:44-96` |
| **MEDIUM** | No success confirmation state on profile edit page. After successful update, page redirects with `?success=1` but no persistent indication shown. | `profile/edit.astro` |

---

## 14. Responsive Design — Issues

### 14.1 Navigation Responsive Issues

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | Between 768px and ~1079px, logo text is hidden and nav items are shown. Search input has `min-width: 12rem` — at 768px total nav items can overflow the flex container. | `base-layout.scss:129-131, 213-260` |
| **MEDIUM** | Notification panel is `width: min(28rem, 80vw)`. On 320px screen, `80vw = 256px`. Content becomes extremely cramped. No mobile-specific notification layout. | `base-layout.scss:349` |

### 14.2 Page-level Issues

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Tables used for admin reports page. No `overflow-x: auto` wrapper visible, which causes horizontal scroll on mobile. | Admin reports page |
| **MEDIUM** | Messages page is a two-column layout (conversation list + thread). If CSS doesn't collapse to single-column on mobile, both columns are too narrow. | Messages page |
| **LOW** | No `@media (prefers-reduced-motion: reduce)` override for `scroll-behavior: smooth` set globally. Only found in `listings.scss`, not globally applied. | `base.scss` |
| **LOW** | Ambient glow effects use `filter: blur(100px)` / `filter: blur(140px)`. GPU-intensive on mid-range Android phones. | `base-layout.scss:11-51` |

### 14.3 Touch & Mobile UX

| Severity | Issue | Location |
|----------|-------|----------|
| **MEDIUM** | Notification items inside panel are `<a>` tags with small padding (~30-32px tall on mobile), below the 44px recommended minimum tap target. | `base-layout.scss:399-407` |
| **LOW** | Form inputs do not set `inputmode` for search/email fields. Search input should have `inputmode="search"` for correct mobile keyboard. | `BaseLayout.astro:286-292` |

---

## 15. Use Case Audit

### 15.1 Subscription System — No Payment Gateway

**Severity: HIGH**

Contests are admin-only by design (`contestsPerMonth = 0` for all tiers). However, no payment processor integration exists. `SubscriptionTier` (FREE/PRO/PRO_PLUS) is modelled but:
- No Stripe, Razorpay, or any payment gateway
- No checkout/upgrade endpoint
- No webhook handler for subscription lifecycle
- Tier can only be changed directly in the database

### 15.2 Digital Model Release / TFP Agreement — Placeholder Only

**Severity: HIGH**

`tfpAgreement String?` exists on `Project` but no digital agreement flow:
- No contract template or e-signature workflow
- No PDF download of signed agreement
- No audit trail of what terms were accepted
- `ProjectApplication` has boolean consent flags but `agreedToTerms` is hardcoded `true` in the frontend

### 15.3 Real-time Messaging — Polling Only

**Severity: HIGH**

- No WebSocket server, no SSE endpoint
- Notifications fetched on every page load (SSR polling)
- `DirectMessage` has `readAt` and `deletedAt` but no deletion endpoint
- No image/file sharing in messages, no user blocking, no read receipts display

### 15.4 User Discovery — No Proximity or Availability

**Severity: HIGH**

- `GET /api/users/` only accepts a `role` filter (`z.string().optional()`)
- No location or radius filter on user list endpoint
- No availability/"open to collaboration" toggle
- `secondaryRoles` field exists but is not filterable

### 15.5 Contest System — Single Winner Only

**Severity: HIGH**

`Contest` has `winnerSubmissionId String?` — one field for one winner. `ContestPrize` model supports 1st/2nd/3rd but there's no mechanism to assign 2nd and 3rd place winners. `SetContestWinner.ts` only updates a single `winnerSubmissionId`.

### 15.6 Event System — Minimal

**Severity: MEDIUM**

- Single `date DateTime` — no end date or duration
- No capacity limit on RSVPs
- `entryFees Json?` stored but no payment collection
- No `CANCELLED` status in `ContentStatus` enum
- No event reminders or confirmation emails

### 15.7 Follow / Social Graph — Absent

**Severity: MEDIUM**

No `UserFollow` or relationship table exists. No follow endpoint in any route file. No personalised activity feed.

### 15.8 Notification System — No Push, No Email Preferences

**Severity: MEDIUM**

- Entirely pull-based (polled on each page render)
- No notification preference settings
- No push notifications (FCM/APNS)
- Email notifications only for password reset and contest/project/event approval

### 15.9 Admin Panel — Minimal Tooling

**Severity: MEDIUM**

- No dashboard/stats endpoint
- No subscription tier management
- `ModerationAuditLog` exists in DB but no admin endpoint reads it
- No content appeal process
- No bulk moderation actions

---

## 16. Moderation System — Deep Dive

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | NOOP provider is the default. In production with `ACTIVE_MODERATION_PROVIDER=noop`, all images pass automatically. Not enforced as a required non-NOOP in `assertRuntimeConfig` for production. | `config/src/index.ts:199`, `assertRuntimeConfig` |
| **HIGH** | Auto-block sets `deletedAt` on user without human review when repeat offender threshold is reached. No admin notification before deletion. | Auto-moderation pipeline |
| **MEDIUM** | Auto-generated `ContentReport` records have `reporterId: null`. No `isAutomated Boolean` flag to distinguish machine reports from user reports. | `auto-moderation-report.ts`, `schema.prisma:284-301` |
| **LOW** | `ModerationAuditLog.deviceFingerprint` is stored as a plain string read from `x-device-fingerprint` header which any client can forge. | `request-context.ts` |
| **LOW** | No moderation for text content. Project descriptions, event descriptions, contest titles, and direct messages pass through unfiltered (only HTML stripped). | All `sanitizePlainText` calls |
| **LOW** | When `MODERATION_ENABLED=false`, NOOP records are still written to `image_moderations` table, polluting it over time. | `SubmitImageForModerationCommand.ts` |

---

## 17. New Findings (Not in Prior Reviews)

| Severity | Issue | Location |
|----------|-------|----------|
| **HIGH** | `register.astro` redirects to `/profile` on success, which is the user's own profile — but the redirect used `formData.get('redirect')` with the same `startsWith('/')` check as login, sharing the same open redirect vulnerability. | `register.astro:28-32` |
| **HIGH** | Mobile bottom navigation exists (`<nav class="mobile-bottom-nav mobile-only">`) with Home/Projects/Events/Profile links — but no Messages or Contests link. Contests, a core feature, is only accessible via the hamburger menu on mobile. | `BaseLayout.astro:543-560` |
| **MEDIUM** | `profile/edit.astro` calls `auth/me` to populate form data (line 27), and `BaseLayout.astro` calls `auth/me` again (line 69). Both re-issue fresh JWTs. Two competing `Set-Cookie` headers on the same response can cause cookie jar conflicts. | `profile/edit.astro:27`, `BaseLayout.astro:69` |
| **MEDIUM** | The `message.services.ts` exports `MESSAGE_MAX_LENGTH = 150` which is used by both the backend validation and the frontend page. But `message.routes.ts:92` uses `z.string().trim().min(1).max(MESSAGE_MAX_LENGTH)` referencing the same constant — meaning the API limit IS 150, not 2000 as claimed. The frontend and API are consistent, but 150 chars is extremely short for a collaboration platform. | `message.services.ts:3`, `message.routes.ts:92` |
| **MEDIUM** | `app.register(cookie)` at `server.ts:99` does not pass a `secret` option. Without a cookie secret, `signed: true` on individual cookies would fail at runtime. This means even if someone tries to fix the `signed: false` JWT cookie issue, they'd hit an error. | `server.ts:99` |
| **MEDIUM** | `auth.middleware.ts:24` uses `startsWith` for public path matching. `/api/v1/auth/login-attempt` or any path prefixed with a public path would bypass auth middleware. While no such routes currently exist, this is a brittle pattern. | `auth.middleware.ts:15-26` |
| **MEDIUM** | The footer includes a `<a href="/disclaimer">` link — so the prior review's claim that Disclaimer is missing from footer is wrong. However, the `guidelines.astro` page IS linked in footer but there's no admin-facing content moderation guidelines page — only user-facing community guidelines. | `BaseLayout.astro:520` |
| **LOW** | `project.routes.ts:104-106` defaults consent booleans to `true` when omitted: `consentSocial: data.consentSocial ?? true`. Combined with frontend hardcoding `agreedToTerms: true`, a curl-based API request with no consent fields gets full consent recorded in DB. | `project.routes.ts:104-106` |
| **LOW** | The `register.astro` form has no `displayName` validation on the frontend side. While the API validates via Zod, the HTML form only has `required` — no `maxlength` or pattern. Users can submit very long display names that are only caught server-side. | `register.astro:66` |
| **LOW** | `login.astro:51` uses `console.error` in the Astro SSR frontmatter instead of structured logging. Server-side console.error in SSR bypasses any log aggregation. | `login.astro:51` |

---

## 18. Priority Matrix

### Critical — Fix Immediately (Production Blockers)

1. Enable Content Security Policy (`@fastify/helmet` with proper CSP config)
2. Add `og:image` and `twitter:image` to BaseLayout
3. Cookie consent banner for GDPR/DPDP compliance
4. Fix profile URLs to use username/ID instead of email
5. Add `robots.txt` to `apps/web/public/`
6. Fix sitemap to include dynamic entity URLs
7. Add right-to-erasure (self-service account deletion) endpoint
8. Set `ACTIVE_MODERATION_PROVIDER` to a real provider in production
9. Add GDPR data export endpoint
10. Fix contest creation to use explicit admin role check instead of quota-as-authorization

### High — Address Before Launch

11. Reduce JWT session from 180 days to 7-30 days; fix `remember_me` functionality
12. Stop re-issuing JWT on every `/auth/me` call
13. Fix `agreedToTerms: true` hardcoded in project application form
14. Add CSRF protection for state-mutating forms
15. Add email verification flow on registration
16. Add admin role guard to contest upload endpoints
17. Add auth requirement to geocoding API endpoints
18. Increase message character limit from 150 to at least 1000
19. Replace in-process EventEmitter with durable message queue
20. Externalize file uploads to cloud storage
21. Strip EXIF metadata from uploaded images before storage
22. Fix nav link active state CSS (always highlights Projects)
23. Add mobile nav JS-disabled fallback
24. Fix presigned URL flow file size enforcement
25. Add server-enforced `ContentLengthRange` to presigned uploads
26. Register cookie secret in `@fastify/cookie` to enable signed cookies

### Medium — Sprint Backlog

27. Cache user session lookup in auth middleware (Redis/short TTL)
28. Add rate limiting to upload, message, report, and reaction endpoints
29. Add pagination to admin moderation queue and reports
30. Add `aria-live` region for notification badge
31. Move Terms/Privacy from i18n JSON to versioned auditable documents
32. Add minimum age verification to registration
33. Wire `@astrojs/sitemap` into `astro.config.mjs` or remove dependency
34. Remove `application/octet-stream` from allowed upload MIME types
35. Add scheduled cleanup job for expired `PasswordResetToken` records
36. Add proper search API endpoint with DB-level full-text search
37. Add "Send Message" button on public profile pages
38. Add Contests to mobile bottom navigation
39. Fix consent defaults to `false` in project application API
40. Use `z.nativeEnum(UserRole)` for role filter validation
41. Increase bcrypt cost factor from 10 to 12
42. Add `Permissions-Policy` header
43. Consolidate `moderationFailurePayload` and `toPublicUrl` helpers
44. Fix `$primary-600`/`$primary-700` duplicate token values
45. Add `@media (prefers-reduced-motion: reduce)` globally

### Low — Technical Debt / Polish

46. Remove `.DS_Store` files and add to `.gitignore`
47. Create separate `ProjectCard`, `ContestCard`, `EventCard` from `ListingCard`
48. Define shared TypeScript types for API responses (eliminate `any`)
49. Add light mode / system-preference theme support
50. Add JSON-LD structured data for Contest, Event, User pages
51. Add source maps uploaded to error tracking
52. Fix `pnpm` engine version mismatch
53. Mark auth/admin pages as `noindex`
54. Add `inputmode` attributes to form inputs
55. Add breadcrumb navigation to detail pages
56. Add payment gateway integration (Stripe/Razorpay)
57. Implement digital model release / TFP agreement workflow
58. Add follow/unfollow system
59. Add post-collaboration rating/review system
60. Add badge awarding logic

---

## Appendix A — Invalid Findings from Prior Review (sonnet.md)

The following findings from the prior `sonnet.md` review were verified against the actual codebase and found to be **incorrect**:

| Section | Claimed Finding | Why Invalid |
|---------|----------------|-------------|
| **9 (DevOps)** | "No `.env.example` file found" | **FALSE.** Three `.env.example` files exist: root `/.env.example`, `apps/api/.env.example`, `packages/database/.env.example` |
| **9 (DevOps)** | "No Dockerfile or Docker Compose configuration found" | **FALSE.** Both `Dockerfile` and `docker-compose.yml` exist at the workspace root |
| **9 (DevOps)** | "Health route `/ready` does not check database connectivity" | **FALSE.** `plugins/health.ts:27` runs `await app.prisma.$queryRaw\`SELECT 1\`` and returns 503 on failure |
| **11 (Performance)** | "ContestSubmission counter updates are not wrapped in transactions" | **FALSE.** `RecordSubmissionReaction.ts` uses `prisma.$transaction()` with `isolationLevel: 'Serializable'` and retry logic (up to 3 attempts) |
| **15.3 (Footer)** | "disclaimer.astro page exists but is not linked in the footer" | **FALSE.** `BaseLayout.astro:520` includes `<a href="/disclaimer">` in the footer legal section |
| **17.1 (UX)** | "After registration, user is redirected to `/` (homepage)" | **FALSE.** `register.astro:28-31` redirects to `/profile` on success (or the `redirect` param value) |
| **17.3 (Messaging)** | "API supports up to 2000 characters but frontend restricts to 150" | **MISLEADING.** The API also uses `MESSAGE_MAX_LENGTH` which is 150 (from `message.services.ts:3`). Both frontend and API are consistent at 150. The limit is genuinely too short, but the claim of API supporting 2000 is false |
| **16.1 (Nav)** | "No 'Create' / 'Post' CTA in navigation" | **Feature request**, not a bug. Categorized as such, not as a HIGH severity issue |

---

*This document contains only findings verified against the actual source code. No code has been modified. All line number references are approximate.*
