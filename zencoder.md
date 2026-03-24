# TFP Photographers Platform — Complete Code Review

> **Scope:** Full codebase audit covering architecture, design patterns, security, CSS, i18n, dead code, mock data, DRY compliance, accessibility, and best-practice violations.
> **Status:** Development phase — backward compatibility not a constraint.
> **Reviewed:** `tfp-workspace` monorepo (Fastify API + Astro Web + shared packages)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Critical Issues (P0)](#2-critical-issues-p0)
3. [High-Priority Issues (P1)](#3-high-priority-issues-p1)
4. [DRY Violations](#4-dry-violations)
5. [SOLID Violations](#5-solid-violations)
6. [CQRS Pattern Inconsistency](#6-cqrs-pattern-inconsistency)
7. [Database / Prisma Issues](#7-database--prisma-issues)
8. [Config, Environment & Feature Flags](#8-config-environment--feature-flags)
9. [i18n Issues](#9-i18n-issues)
10. [CSS / Styling Issues](#10-css--styling-issues)
11. [TypeScript Type Safety](#11-typescript-type-safety)
12. [Dead Code & YAGNI Violations](#12-dead-code--yagni-violations)
13. [Mock / Hardcoded / External Data](#13-mock--hardcoded--external-data)
14. [API Response Inconsistency](#14-api-response-inconsistency)
15. [Frontend Architecture Issues](#15-frontend-architecture-issues)
16. [SSR + Progressive Enhancement](#16-ssr--progressive-enhancement)
17. [Accessibility Issues](#17-accessibility-issues)
18. [Caching & Performance](#18-caching--performance)
19. [Middleware Pipeline Issues](#19-middleware-pipeline-issues)
20. [Seed Data Issues](#20-seed-data-issues)
21. [Summary Checklist](#21-summary-checklist)

---

## 1. Architecture Overview

**Stack:**
- **Backend:** Fastify v4 + Prisma ORM + PostgreSQL (monorepo app `apps/api`)
- **Frontend:** Astro v4 SSR + SCSS (monorepo app `apps/web`)
- **Packages:** `config`, `database`, `email`, `i18n`, `shared`, `storage`
- **Infra:** pnpm workspaces, Docker, Playwright e2e tests

**Good foundations present:**
- Adapter pattern for storage (LocalAdapter / BackblazeB2Adapter) and email (ConsoleAdapter / ResendAdapter)
- Feature flags in config
- Shared i18n package with master `en_US.json`
- Design token system in `tokens.scss`
- SSR-first with progressive enhancement via vanilla JS
- EventBus in `shared` package for domain events
- Subscription quota enforcement layer
- Soft delete pattern in Prisma

---

## 2. Critical Issues (P0)

### 2.1 Hardcoded JWT Secret Fallback

**File:** `packages/config/src/index.ts:63`

```ts
JWT_SECRET: process.env.JWT_SECRET || 'dev-secret-change-in-production',
```

The fallback secret is a known string. If `JWT_SECRET` is ever missing in a production `.env`, the server silently starts with a predictable secret. The `assertProductionConfig()` check in `server.ts` guards against this at startup, but only for the API entrypoint — if someone imports `config` from another context without calling that assertion, the risk remains.

**Fix:** Throw an error at module load time in production instead of providing a fallback. Remove the fallback entirely or make it undefined/empty so JWT signing fails loudly.

---

### 2.2 Hardcoded Database Credentials Fallback

**File:** `packages/config/src/index.ts:44`

```ts
DATABASE_URL: process.env.DATABASE_URL || 'postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers',
```

Credentials `tfp_user:tfp_user` hardcoded in source. Any log or stack trace could expose these. Same risk as above — silent fallback to a known credential string.

**Fix:** No fallback for `DATABASE_URL`. If missing, fail at boot.

---

### 2.3 Geoapify API Key Exposed to Browser

**File:** `apps/web/src/layouts/BaseLayout.astro:181`

```html
<html
  lang={htmlLang}
  data-geoapify-key={ENV.GEOAPIFY_API_KEY}
  ...
>
```

The Geoapify API key is embedded as an HTML attribute on the root `<html>` element and therefore exposed to every browser visitor, scrapers, and automated bots. This allows key theft and quota abuse.

**Fix:** The key should only be used server-side via an API proxy endpoint (`/api/v1/location/autocomplete` already exists). Remove `data-geoapify-key` from the HTML element. The client-side `location-autocomplete.js` should call the backend proxy instead of Geoapify directly.

---

### 2.4 Silent Auth Failure — Unauthenticated Requests Pass Through

**File:** `apps/api/src/plugins/auth.ts:120-123`

```ts
} catch (error) {
  // For now, allow unauthenticated requests to pass through
  // Frontend will handle redirect to login
}
```

When JWT verification throws (invalid token, expired token, malformed), the error is silently swallowed. The request continues with `request.userId = undefined`. All route protection then depends on per-handler `if (!request.userId)` checks. If any handler misses this check, it becomes an unauthenticated access vulnerability.

**Fix:** This design is high-risk. The middleware should clearly differentiate between "no token at all" (pass through) and "invalid/expired token" (return 401 immediately). Invalid tokens should be rejected outright.

---

## 3. High-Priority Issues (P1)

### 3.1 Auth Plugin Violates Single Responsibility Principle

**File:** `apps/api/src/plugins/auth.ts` (500 lines)

One file handles:
- Global JWT verification middleware (the `onRequest` hook)
- Login route handler
- Register route handler
- Forgot password route handler
- Reset password validation route handler
- Reset password route handler
- Logout route handler
- Get current user (`/me`) route handler

These are 7 distinct responsibilities in a single file. It should be split:
- `plugins/auth.middleware.ts` — JWT verification hook
- `modules/auth/auth.routes.ts` — Route handlers
- `modules/auth/auth.commands.ts` — Login, Register, ResetPassword logic
- `modules/auth/auth.queries.ts` — GetCurrentUser

---

### 3.2 Soft Delete Middleware Misses `findFirst`

**File:** `packages/database/src/index.ts:42-66`

The Prisma soft delete middleware intercepts `findUnique` and `findMany` but **not** `findFirst`. Multiple route files use `prisma.*.findFirst()` including:
- `project.routes.ts` — `prisma.project.findFirst()`
- `admin.routes.ts` — `prisma.project.findFirst()`, etc.
- `subscription-policy.ts` — `prisma.user.findFirst()`

These calls can return soft-deleted records, silently breaking business rules.

**Fix:** Add `findFirst` to the middleware interception list, or better, use Prisma's `$extends` API (the modern approach over deprecated `$use` middleware).

---

### 3.3 `ProjectApplication.status` Typed as `String` Instead of Enum

**File:** `packages/database/prisma/schema.prisma:201`

```prisma
status  String   @default("APPLIED")
```

All other status fields in the schema use proper enums (`ContentStatus`, `RsvpStatus`, `ProjectRoleStatus`). `ProjectApplication.status` is a plain `String`, losing type safety, schema documentation, and DB-level validation. The valid values (`APPLIED`, `SHORTLISTED`, `SELECTED`, `REJECTED`) are scattered as string literals across multiple route files.

**Fix:** Create a `ProjectApplicationStatus` enum in the schema.

---

### 3.4 API Version Hardcoded in Auth Plugin (Not Using Config)

**File:** `apps/api/src/plugins/auth.ts:80-87`

```ts
const publicPaths = [
  '/health',
  '/ready',
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  ...
];
```

The API prefix `/api/v1` is hardcoded as string literals in the auth plugin's `publicPaths` array, but `ENV.API_PREFIX` (= `/api/v1`) is defined in config and used everywhere else in `server.ts`. If the version changes, these strings will be missed.

Also, route handlers in `auth.ts` hardcode paths directly:
```ts
app.post('/api/v1/auth/login', ...)
app.get('/api/v1/auth/me', ...)
```
While all other modules use the Fastify prefix registration pattern (e.g., `app.register(registerContestRoutes, { prefix: ENV.API_PREFIX + '/contests' })`).

**Fix:** Register auth routes via Fastify's prefix system. Use `ENV.API_PREFIX` in `publicPaths`.

---

### 3.5 `PROFILE_HERO_COVER_URL` Hardcoded Unsplash URL in Config

**File:** `packages/config/src/index.ts:72-74`

```ts
PROFILE_HERO_COVER_URL:
  process.env.PROFILE_HERO_COVER_URL ||
  'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?auto=format&fit=crop&w=1800&q=80',
```

Also present in `.env.development:79`. An external Unsplash URL is used as a default for the profile hero cover image. This creates a runtime dependency on an external CDN for default content. This is effectively mock/placeholder data baked into production config.

**Fix:** Use a locally stored placeholder image, or leave the value empty and handle the missing image gracefully in the UI.

---

### 3.6 Triple-Redundant API Response Shape

**File:** `apps/api/src/modules/contest/contest.routes.ts:150`, `apps/api/src/modules/contest/contest.routes.ts:394`, `apps/api/src/modules/project/project.routes.ts:277`

```ts
return reply.status(201).send({ success: true, data: result, submission: result, ...result });
```

The same data is returned three times simultaneously: under `data`, under `submission`/`contest`/`project`, and spread into the root. This is the root cause of the complex `extractList`/`extractItem` fallback logic in `apps/web/src/utils/api-fetch.ts` which must handle multiple possible response shapes.

**Fix:** Standardize all API responses to `{ success: true, data: { ... } }`. Remove legacy shape compatibility and clean up the `api-fetch.ts` resolver.

---

## 4. DRY Violations

### 4.1 `toPublicProfileImage` and `toPublicCreator` Duplicated Across All Route Files

These two utility functions are copy-pasted identically in every route module:

| File | Location |
|------|----------|
| `apps/api/src/modules/contest/contest.routes.ts` | Lines 28–38 |
| `apps/api/src/modules/project/project.routes.ts` | Lines 22–33 |
| `apps/api/src/modules/event/event.routes.ts` | Lines 21–32 |
| `apps/api/src/modules/user/user.routes.ts` | Lines 42–45 |
| `apps/api/src/modules/message/message.routes.ts` | Lines 14–18 |

**Fix:** Move to `apps/api/src/utils/storage-helpers.ts` and import from all routes.

---

### 4.2 `requireAuth` Duplicated Across Route Files

The pattern:
```ts
const requireAuth = (request, reply) => {
  if (request.userId) return true;
  reply.status(401).send({ success: false, error: { code: 'UNAUTHORIZED', message: 'Authentication required' } });
  return false;
};
```

Exists separately in `project.routes.ts`, `user.routes.ts`, `message.routes.ts` with slightly different type signatures. Additionally, many other route files inline the auth check directly (`if (!request.userId) { return reply.status(401)... }`).

**Fix:** Create a shared Fastify plugin or middleware that adds `requireAuth` and `requireAdmin` decorators to the Fastify instance.

---

### 4.3 `requireAdmin` Duplicated Across Route Files

Similar to above — the admin guard pattern is redefined separately in `contest.routes.ts` (returns an object), `project.routes.ts` (unused — has `requireAdmin` defined but never called, `request.userRole !== 'ADMIN'` is inlined instead), `event.routes.ts`, and `admin.routes.ts` (named `ensureAdmin`).

Each implementation is slightly different, increasing maintenance surface.

---

### 4.4 Auth Check Inline Pattern (20+ Occurrences)

```ts
if (!request.userId) {
  return reply.status(401).send({
    success: false,
    error: { code: 'UNAUTHORIZED', message: 'Authentication required' },
  });
}
```

This pattern appears 20+ times across route files. The shared `requireAuth` helper is defined but not consistently used — some handlers still inline the same logic.

---

### 4.5 `btn-primary` and `btn-secondary` CSS Classes Redefined

**Files:** `apps/web/src/styles/base.scss` AND `apps/web/src/styles/pages/home.scss`

```scss
// base.scss (square button with var(--primary-600))
.btn-primary {
  background-color: var(--primary-600);
  color: white;
  ...
}

// home.scss (pill button with gradient — completely different visual)
.btn-primary {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, $color-primary, $color-secondary);
  border-radius: 9999px;
  ...
}
```

The same class names are redefined with different styling in the home page SCSS. Since both stylesheets are loaded globally via `@use`, the home page overrides bleed into other pages. This is a specificity and cascade bug.

**Fix:** Give the home page variants unique class names (`hero-btn-primary`, `hero-btn-secondary`) or use scoped styles.

---

### 4.6 Login Redirect Pattern Duplicated Across Frontend Pages

The login redirect URL construction:
```ts
const loginRedirectHref = `/login?redirect=${encodeURIComponent(Astro.url.pathname)}`;
```
...and the `data-modal-open="auth-modal"` pattern appear in 10+ page files identically. This should be a shared utility or component.

---

## 5. SOLID Violations

### 5.1 Single Responsibility — Route Files Too Large

| File | Lines | Responsibilities |
|------|-------|-----------------|
| `apps/web/src/pages/profile/[email].astro` | 1,706 | Data fetching, form handling (portfolio upload, delete, profile edit), rendering public/private profile view, tab state |
| `apps/api/src/modules/contest/contest.routes.ts` | 1,049 | Auth checks, file upload handling, CQRS commands, CQRS queries, voting logic, admin actions, lifecycle resolution |
| `apps/web/src/pages/projects/[id].astro` | 1,334 | Project detail display, application form, TFP agreement modal, creator view, applications list |
| `apps/web/src/pages/events/[id].astro` | 1,004 | Event detail + RSVP flow |

These files do too much. The profile page especially mixes server-side form handling (POST processing), data loading (multiple API calls), and complex rendering logic into a single file.

---

### 5.2 Open/Closed Principle — Subscription Limits Use `if/else` Chain

**File:** `apps/api/src/utils/subscription-policy.ts:22-27`

```ts
const getMonthlyLimit = (tier: SubscriptionTier, entity: CreationEntity): number => {
  const quota = SUBSCRIPTION_LIMITS[tier];
  if (entity === 'project') return quota.projectsPerMonth;
  if (entity === 'event') return quota.eventsPerMonth;
  return quota.contestsPerMonth;
};
```

Adding a new entity type requires modifying this function. Same pattern in `countCreatedItems`. Should be a lookup map keyed by entity type.

---

### 5.3 Interface Segregation — `ListingCard.astro` Uses `item: any`

**File:** `apps/web/src/components/ListingCard.astro:12`

```ts
interface Props {
  variant: Variant;
  item: any;
}
```

The `ListingCard` component accepts an untyped `item` and branches internally on `variant` to access `item.moodBoardImages`, `item.bannerImageKey`, `item.imageKey`, etc. This is a union-type discrimination problem solved with `any` instead of discriminated union interfaces.

**Fix:** Define `ProjectItem`, `ContestItem`, `EventItem` interfaces and use a discriminated union `Props`.

---

## 6. CQRS Pattern Inconsistency

**Current state:**
- `apps/api/src/modules/contest/` has proper CQRS subdirectories: `commands/CreateContest.ts`, `commands/SubmitContestEntry.ts`, `queries/GetContestDetails.ts`, `queries/ListContests.ts`
- All other modules use flat `.commands.ts` / `.queries.ts` files at the module root, with no subdirectory structure

**Inconsistency table:**

| Module | CQRS Structure |
|--------|---------------|
| `contest` | Proper subdirectories per command/query |
| `project` | Flat `project.commands.ts`, `project.queries.ts` |
| `event` | Flat `event.commands.ts`, `event.queries.ts` |
| `user` | Flat `user.commands.ts`, `user.queries.ts` |
| `admin` | Flat `admin.commands.ts`, `admin.queries.ts` |
| `message` | Flat `message.commands.ts`, `message.queries.ts` |

The contest module has fully named command classes (`CreateContest`, `SubmitContestEntry`) while others just export plain functions. Pick one pattern and apply it consistently.

---

## 7. Database / Prisma Issues

### 7.1 Deprecated Prisma Middleware `$use` API

**File:** `packages/database/src/index.ts:90`

```ts
client.$use(softDeleteMiddleware);
```

`PrismaClient.$use()` (middleware) is deprecated in Prisma 5+ in favor of `$extends` (client extensions). The current approach also doesn't support `findFirst` (see P1 item 3.2).

**Fix:** Migrate to Prisma Client Extensions (`$extends`) for the soft delete behavior.

---

### 7.2 `DirectMessage` Has `deletedAt` But Is Not in Soft Delete Middleware

**File:** `packages/database/prisma/schema.prisma:221` + `packages/database/src/index.ts:31-38`

`DirectMessage` has a `deletedAt` field in the schema but is not listed in `modelsWithSoftDelete`. Queries on `DirectMessage` will return soft-deleted messages.

---

### 7.3 Inconsistent Index on `DirectMessage`

**File:** `packages/database/prisma/schema.prisma:226-229`

Three indexes are defined on DirectMessage:
```prisma
@@index([senderId, createdAt])
@@index([recipientId, createdAt])
@@index([senderId, recipientId, createdAt])
```

The compound `[senderId, recipientId, createdAt]` index is redundant if Postgres can use the individual indexes. Review actual query patterns and consolidate.

---

### 7.4 No Migration Files — Using `db push` in Dev

**File:** `package.json:20` — `"db:push": "pnpm --filter database prisma db push"`

There are no migration files in the `prisma/` directory. The team is using `db push` (schema sync without migration history). This is fine for dev but risky as the project grows — `db push` on an existing DB can cause data loss on schema changes. Formal migration files (`prisma migrate dev`) should be established.

---

### 7.5 `statusToContentStatus` in Seed Is a Logic Bug

**File:** `packages/database/prisma/seed.ts:386-387`

```ts
const statusToContentStatus = (status: 'UPCOMING' | 'APPROVED') =>
  status === 'APPROVED' ? 'APPROVED' : 'APPROVED';
```

This function always returns `'APPROVED'` regardless of input (both branches return the same value). The intent was probably to map 'UPCOMING' to something else. This is dead + broken code.

---

## 8. Config, Environment & Feature Flags

### 8.1 Duplicate Backblaze Config Keys

**File:** `.env.development:48-60`

Both `B2_*` and `BACKBLAZE_*` environment variables coexist:
```
B2_ENDPOINT=...
BACKBLAZE_ENDPOINT=...
```

Config/index.ts reads both with `||` fallbacks. This is confusing and increases the number of variables to maintain. Pick one naming convention and remove the other. `B2_*` is already used as primary.

---

### 8.2 `PORT` and `WEB_PORT` Are Redundant

**File:** `packages/config/src/index.ts:40-42`

```ts
PORT: parseInt(process.env.PORT || '3000', 10),
WEB_PORT: parseInt(process.env.WEB_PORT || '3000', 10),
```

Both default to 3000 and serve the same purpose. `PORT` is never used in any app code (only `API_PORT` and `WEB_PORT` are). Remove `PORT` or consolidate.

---

### 8.3 `assertProductionConfig` Is Incomplete

**File:** `apps/api/src/server.ts:36-44`

Only `DATABASE_URL` and `JWT_SECRET` are asserted. Missing critical checks for:
- `B2_ACCESS_KEY_ID`, `B2_SECRET_ACCESS_KEY` (when `STORAGE_PROVIDER=backblaze`)
- `RESEND_API_KEY` (when `EMAIL_PROVIDER=resend`)
- `APP_BASE_URL` (used in password reset links)

---

### 8.4 `IMAGEKIT_URL` Placeholder Default

**File:** `packages/config/src/index.ts:59`

```ts
IMAGEKIT_URL: process.env.IMAGEKIT_URL || process.env.IMAGEKIT_URL_ENDPOINT || 'https://ik.imagekit.io/your-app',
```

`'https://ik.imagekit.io/your-app'` is a placeholder URL that would cause broken image URLs in production if the env var is not set. Should default to empty string and handle gracefully.

---

### 8.5 `API_VERSION` Is a Constant, Not Env-Configurable

**File:** `packages/config/src/index.ts:97-98`

```ts
API_VERSION: 'v1',
API_PREFIX: '/api/v1',
```

`API_PREFIX` is hardcoded as a constant but auth.ts ignores it and hardcodes `/api/v1` directly in route paths and the public paths list. This breaks the single source of truth for API versioning.

---

### 8.6 `CACHE_TTL` Constants Are Defined But Never Used

**File:** `packages/config/src/index.ts:237-242`

```ts
export const CACHE_TTL = {
  SHORT: 60,
  MEDIUM: 300,
  LONG: 3600,
  DAY: 86400,
} as const;
```

Grep confirms zero usages of `CACHE_TTL` in any app or package code. Violates YAGNI. Either implement caching or remove.

---

## 9. i18n Issues

### 9.1 `detectLocale` Always Returns Default Locale

**File:** `packages/i18n/src/index.ts:140-154`

```ts
export function detectLocale(acceptLanguage?: string): string {
  if (!acceptLanguage) return DEFAULT_LOCALE;

  const preferred = acceptLanguage
    .split(',')
    .map((lang) => lang.split(';')[0].trim().toLowerCase())
    .find((lang) => lang.startsWith('en'));

  if (preferred) {
    return DEFAULT_LOCALE; // Default to en_US for now
  }

  return DEFAULT_LOCALE;
}
```

This function always returns `DEFAULT_LOCALE` regardless of the Accept-Language header. It only checks if the language starts with 'en' but then returns `DEFAULT_LOCALE` in both branches. Multi-locale detection is not actually implemented, making the middleware's locale detection logic purely cosmetic.

**Fix:** Either implement proper locale matching or clearly mark this as a stub. Remove the misleading 'Accept-Language header parsing' code.

---

### 9.2 Social Media URLs Hardcoded in i18n Locale File

**File:** `packages/i18n/src/locales/en_US.json:72-75`

```json
"social_twitter_url": "https://twitter.com/tfpphotographers",
"social_instagram_url": "https://instagram.com/tfpphotographers",
"social_linkedin_url": "https://linkedin.com/company/tfpphotographers",
```

Social media URLs are business config, not translatable strings. They belong in the `config` package as env vars, not in the i18n locale file. These URLs would be identical across all future locales.

---

### 9.3 `common.app_url` Hardcoded in Locale File

**File:** `packages/i18n/src/locales/en_US.json:3`

```json
"app_url": "https://tfpphotographers.com",
```

The app URL is used in `BaseLayout.astro` for canonical URLs and structured data. This should come from `ENV.APP_BASE_URL`, not from the i18n file. It will differ between DEV, STG, and PROD environments.

---

### 9.4 Email Bodies Not Using i18n

**File:** `apps/api/src/plugins/auth.ts:302-304`, `:404-406`

```ts
subject: 'Reset your TFP Photographers password',
text: `Use this secure link to reset your password: ${resetUrl}...`,
html: `<p>Use this secure link...</p>`,
```

All email content is hardcoded English strings directly in the auth plugin, bypassing the i18n system entirely. If localization is ever needed for emails, this requires significant refactoring.

---

### 9.5 `i18n` Package Uses Module-Level Mutable State

**File:** `packages/i18n/src/index.ts:32`

```ts
let currentLocale: string = DEFAULT_LOCALE;
```

The locale is stored in a module-level variable. In Node.js SSR, this is a singleton shared across all concurrent requests. If two simultaneous requests have different locales and `setLocale()` is called, they will race and corrupt each other's locale state.

**Fix:** Locale should be passed as a parameter to `t()` or stored in request context, not in module state. The middleware sets `Astro.locals.locale` correctly — use that and pass it to `t()`.

---

### 9.6 `contact_email`, `support_email` etc. in Locale File

**File:** `packages/i18n/src/locales/en_US.json:75-79`

```json
"contact_email": "contact@tfpphotographers.com",
"support_email": "support@tfpphotographers.com",
"privacy_email": "privacy@tfpphotographers.com",
"legal_email": "legal@tfpphotographers.com",
```

Email addresses are not translatable strings — they are business contact configuration. Move to `config` package.

---

## 10. CSS / Styling Issues

### 10.1 Hardcoded Magic Color Values in SCSS (Not Using Tokens)

**File:** `apps/web/src/styles/pages/home.scss` and `apps/web/src/styles/layouts/base-layout.scss`

The following hardcoded color values bypass the design token system:

| File | Line | Value | Should Use |
|------|------|-------|-----------|
| `home.scss` | 95 | `rgba(111, 75, 255, 0.4)` | `rgba($accent-violet, 0.4)` |
| `home.scss` | 131 | `rgba($color-white, 0.1)` | ✓ OK (uses var) |
| `home.scss` | 155 | `linear-gradient(to right, $color-primary, $color-accent)` | ✓ OK |
| `base-layout.scss` | 31 | `rgba(111, 75, 255, 0.15)` | `rgba($accent-violet, 0.15)` |
| `base-layout.scss` | 38 | `rgba(163, 255, 255, 0.1)` | `rgba($accent-cyan, 0.1)` |
| `base-layout.scss` | 58 | `rgba(15, 17, 21, 0.8)` | `rgba($bg-base, 0.8)` |
| `home.scss` | 370 | `rgba(111, 75, 255, 0.3)` | `rgba($accent-violet, 0.3)` |
| `home.scss` | 371 | `rgba(111, 75, 255, 0.15)` | `rgba($accent-violet, 0.15)` |
| `home.scss` | 210 | `rgba(111, 75, 255, 0.4)` (box-shadow) | Token |

---

### 10.2 Hardcoded Spacing Values Not Using Spacing Tokens

**File:** `apps/web/src/styles/pages/home.scss`

Multiple spacing values are hardcoded as raw rem/px values instead of using `$space-*` tokens:

```scss
padding: 1.5rem 3rem;      // should be $space-6 $space-12
gap: 1rem;                  // should be $space-4
padding: 0.25rem 0.75rem;   // should be $space-1 $space-3
margin-bottom: 1rem;        // should be $space-4
border-radius: 1.5rem;      // should be $radius-2xl
border-radius: 1rem;        // should be $radius-xl
backdrop-filter: blur(12px); // should be $glass-blur token
```

---

### 10.3 `margin-bottom` Violations (Should Use `margin-top` Only)

The project follows a "margin-top only" vertical rhythm pattern per the style guidelines. The following violate this:

| File | Line | Violation |
|------|------|-----------|
| `base.scss` | 119 | `margin-bottom: var(--space-2)` on `label` |
| `auth-modal.scss` | 88 | `margin-bottom: $space-6` |
| `base-layout.scss` | 570 | `margin-bottom: 4rem` (hardcoded) |
| `base-layout.scss` | 1028 | `margin-bottom: $space-2` |
| `home.scss` | 139 | `margin-bottom: 1rem` (hardcoded) |
| `home.scss` | 143 | `margin-bottom: 1.5rem` (hardcoded) |
| `home.scss` | 463 | `margin-bottom: 0.25rem` (hardcoded) |
| `home.scss` | 591 | `margin-bottom: 0.5rem` (hardcoded) |
| `home.scss` | 597 | `margin-bottom: 1rem` (hardcoded) |
| `_create-shell-shared.scss` | 60 | `margin-bottom: $space-4` |

---

### 10.4 Breakpoint Values Not Using Tokens in `home.scss`

**File:** `apps/web/src/styles/pages/home.scss:29,33,44`

```scss
@media (min-width: 640px) { ... }
@media (min-width: 768px) { ... }
@media (max-width: 639px) { ... }
```

Breakpoint tokens (`$breakpoint-sm`, `$breakpoint-md`) are defined in `tokens.scss` but some media queries in `home.scss` use raw pixel values. Mix of token-based and raw-value media queries.

---

### 10.5 `font-family` Hardcoded in `base-layout.scss`

**File:** `apps/web/src/styles/layouts/base-layout.scss:8`

```scss
.app-body {
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
}
```

The font family is already defined as `--font-sans` CSS custom property in `tokens.scss`. This hardcodes the value redundantly instead of using `var(--font-sans)`.

---

### 10.6 `base-layout.scss` Line 570 Has Hardcoded `4rem`

```scss
margin-bottom: 4rem;
```

Should use `$space-16` or `var(--space-16)`.

---

## 11. TypeScript Type Safety

### 11.1 Pervasive Use of `any` in Frontend Pages

**Files:** Multiple `.astro` pages

```ts
let currentUser: any = null;
let user: any = null;
let portfolioImages: any[] = [];
let myApplications: any[] = [];
let myContestEntries: any[] = [];
let myPosts: any[] = [];
```

(`apps/web/src/pages/profile/[email].astro:27-41`)

Count: **77 occurrences** of `any` across the web app. Major pages using `any` include `profile/[email].astro`, `contests/[id].astro`, `projects/[id].astro`, `events/[id].astro`.

**Fix:** Define TypeScript interfaces for API response shapes (ideally in a shared `types` package or `packages/shared`).

---

### 11.2 `any` in API Route (admin)

**File:** `apps/api/src/modules/admin/admin.routes.ts:34`

```ts
const ensureAdmin = (request: { userId?: string; userRole?: string }, reply: any): boolean => {
```

`reply: any` loses all Fastify reply type safety. Should be `FastifyReply`.

---

### 11.3 `any` in Location Routes

**File:** `apps/api/src/modules/location/location.routes.ts`

```ts
const mapGeoapifyAutocomplete = (payload: any): LocationSuggestion[] => {
const mapNominatimAutocomplete = (payload: any): LocationSuggestion[] => {
const payload: any = await response.json();
```

External API responses should have typed interfaces, even if they're just `unknown` narrowed with type guards.

---

### 11.4 `ListingCard.astro` Untyped Prop

**File:** `apps/web/src/components/ListingCard.astro:12`

```ts
item: any;
```

The card renders project/contest/event data with no type safety. Accessing `item.moodBoardImages`, `item.bannerImageKey` etc. has zero compile-time guarantees.

---

## 12. Dead Code & YAGNI Violations

### 12.1 `alpinejs` Dependency Never Used

**File:** `apps/web/package.json:17`

```json
"alpinejs": "^3.13.5",
```

Alpine.js is listed as a dependency but there are **zero** Alpine directives (`x-data`, `@click`, `x-show`, `x-bind`, etc.) anywhere in the codebase. The UI enhancement is done with vanilla JS (`ui.js`, `form-helpers.js`). Remove this unused dependency.

---

### 12.2 `createStorageServiceFactory` Never Used

**File:** `packages/storage/src/index.ts:43-45`

```ts
export function createStorageServiceFactory(provider?: StorageProvider): StorageServiceFactory {
  return () => getStorageService(provider);
}
```

Grep confirms zero usages of `createStorageServiceFactory` anywhere in the codebase. Remove.

---

### 12.3 `CACHE_TTL` Constants Never Used

**File:** `packages/config/src/index.ts:237-242`

```ts
export const CACHE_TTL = { SHORT: 60, MEDIUM: 300, LONG: 3600, DAY: 86400 } as const;
```

Zero usages found. Remove until caching is implemented.

---

### 12.4 `WEB_PORT` / `PORT` Redundancy

**File:** `packages/config/src/index.ts:40-42`

`PORT` is defined but never referenced anywhere in app code. Only `API_PORT` and `WEB_PORT` are used. Remove `PORT`.

---

### 12.5 `statusToContentStatus` in Seed — Broken Dead Function

**File:** `packages/database/prisma/seed.ts:386-387`

```ts
const statusToContentStatus = (status: 'UPCOMING' | 'APPROVED') =>
  status === 'APPROVED' ? 'APPROVED' : 'APPROVED';
```

Both branches return `'APPROVED'`. This is logically broken AND the function is only called once (for events). The conversion is meaningless. Remove and inline `'APPROVED'` directly.

---

### 12.6 `resolveLegacyDetail` Utility May Be Unnecessary Complexity

**File:** `apps/web/src/utils/detail-loader.ts`

This utility supports "legacy numeric detail routes" (e.g., `1-my-slug` style params). If the app has never had numeric IDs (it uses cuid), this entire utility and the route resolution complexity it adds may never be triggered. Verify and remove if not needed.

---

### 12.7 `StorageServiceFactory` Type Never Used for DI

**File:** `packages/storage/src/interfaces.ts`

The `StorageServiceFactory` type is exported and used only as the return type of `createStorageServiceFactory`, which is itself never used. Both can be removed.

---

### 12.8 `requireAdmin` Defined But Not Called in `project.routes.ts`

**File:** `apps/api/src/modules/project/project.routes.ts:35-38`

```ts
const requireAdmin = () => ({
  success: false,
  error: { code: 'FORBIDDEN', message: 'Admin access required' },
});
```

This function is defined but never called within `project.routes.ts`. Admin checks are done inline. Remove.

---

## 13. Mock / Hardcoded / External Data

### 13.1 Unsplash URLs Hardcoded in Test Files

**Files:**
- `apps/api/src/modules/user/user.public-list.test.ts:60,65`
- `apps/api/src/modules/contest/contest.winner.test.ts:77,145,215,222`
- `apps/api/src/modules/contest/contest.visibility.test.ts:80`

Test fixtures use live Unsplash URLs as image keys:
```ts
imageKey: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
```

Tests should use opaque strings like `'test-image-key'` — they test ID storage and retrieval, not actual URLs. Tests should never depend on external CDN availability.

---

### 13.2 Seed Data Uses External Unsplash URLs for Profile/Portfolio Images

**File:** `packages/database/prisma/seed.ts:6-25`

```ts
const PROFILE_IMAGES = [
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=240',
  ...
];
```

Seed data stores Unsplash URLs as `profileImageKey` values directly in the database. The storage system is designed to store keys (relative paths) and resolve them to URLs via `getUrl()`. Storing absolute external URLs breaks this abstraction — the storage adapter's `getUrl()` would double-prefix them.

**Fix:** Either use the local storage with real uploaded images, or store a special marker (e.g., `external:https://...`) that the storage adapter understands.

---

### 13.3 `.env.development` Contains `PROFILE_HERO_COVER_URL` with External Unsplash URL

**File:** `.env.development:79`

```
PROFILE_HERO_COVER_URL=https://images.unsplash.com/photo-1542038784456-1ea8e935640e?auto=format&fit=crop&w=1800&q=80
```

A default cover image from an external CDN is stored in the development env config. This should be a locally stored asset or left empty with graceful UI fallback.

---

### 13.4 Seed Event Data Has Fields Not in Schema

**File:** `packages/database/prisma/seed.ts:90-98`

```ts
type SeedEvent = {
  ...
  time: string;        // not in Event model
  category: string;    // not in Event model
  price: number;       // not in Event model
  attendees: number;   // not in Event model
  maxAttendees: number; // not in Event model
  organizer: { ... };  // mapped to creator
};
```

The `SeedEvent` type has 5 fields that don't exist in the `Event` schema model. These are phantom fields in the seed type that get silently dropped during DB insert. This may indicate planned but unimplemented features (pricing, capacity, categories for events).

---

## 14. API Response Inconsistency

### 14.1 Inconsistent Response Envelope

API responses use inconsistent shapes across modules:

| Module | Shape |
|--------|-------|
| Contest list | `{ success, contests, pagination }` (root-level, no `data`) |
| Contest detail | `{ success, data: { ...contest } }` |
| Project create | `{ success, data, project, ...spread }` (triple) |
| User list | `{ success, data: { items, pagination } }` |
| Auth/me | `{ success, data: { user } }` |
| Admin queue | `{ success, data: { projects, events, contests } }` |

This forces the frontend `api-fetch.ts` to have complex multi-path fallback resolvers. All responses should follow a single standard: `{ success: boolean, data: T, error?: { code, message } }`.

---

### 14.2 Contest List Does Not Wrap in `data`

**File:** `apps/api/src/modules/contest/contest.routes.ts:193-201`

```ts
return {
  success: true,
  ...result,  // spreads contests and pagination to root
  contests: result.contests.map(...),
};
```

Unlike all other endpoints, the contest list spreads `pagination` and `contests` to the root response level. The `extractList` in `api-fetch.ts` handles both `{ contests: [...] }` (root) and `{ data: { contests: [...] } }` precisely because of this inconsistency.

---

## 15. Frontend Architecture Issues

### 15.1 BaseLayout Makes 2 Blocking API Calls on Every Page Load

**File:** `apps/web/src/layouts/BaseLayout.astro:60-152`

Every single page request executes:
1. `fetch('/auth/me')` — to get current user
2. `fetch('/users/me/notifications')` — to get notification summary

These are serial (notifications only called after auth succeeds), uncached, blocking SSR calls. On every page navigation, two round-trips to the API are made before the HTML can be sent to the browser.

**Fix:**
- Cache the `auth/me` response server-side using request context or Astro's built-in response caching
- Make notification fetch non-critical (render page first, hydrate notifications client-side)
- Add `stale-while-revalidate` HTTP cache headers on these API endpoints

---

### 15.2 `PUBLIC_API_BASE_URL` Has Hardcoded API Version in Fallback

**File:** `apps/web/src/utils/api.ts:5`

```ts
return import.meta.env.PUBLIC_API_BASE_URL || 'http://localhost:4000/api/v1';
```

The API version `v1` is hardcoded in the fallback URL string. If the API version ever changes, this fallback will be stale. The version should come from a single source (`ENV.API_VERSION` or `ENV.API_PREFIX`).

---

### 15.3 Profile Page Is a God Component (1706 Lines)

**File:** `apps/web/src/pages/profile/[email].astro`

This single file handles:
- Session and auth checking
- POST form handling (portfolio upload, portfolio delete)
- 5 separate API data fetches (user, portfolio, applications, contest entries, posts)
- Tab state resolution from URL params
- Public profile rendering
- Owner dashboard rendering
- Multiple edit modals

**Fix:** Extract into sub-components:
- `ProfileHeader.astro`
- `ProfilePortfolio.astro`
- `ProfileApplications.astro`
- `ProfileActivity.astro`
- Form handling extracted to dedicated POST handler

---

### 15.4 `api-fetch.ts` Complexity Is a Symptom, Not a Fix

**File:** `apps/web/src/utils/api-fetch.ts`

The `extractList` and `extractItem` functions handle 3-4 different possible response shapes because the API returns inconsistent envelopes. The complexity here is a band-aid over the root problem (Issue 14.1). Once responses are standardized, this utility can be simplified significantly.

---

## 16. SSR + Progressive Enhancement

### 16.1 Alpine.js Dependency Present But Not Used

As noted in §12.1, `alpinejs` is in `package.json` but zero Alpine directives exist. If Alpine was intended for progressive enhancement, it is not being used. It adds unnecessary bundle weight (though since it's not imported in any `.astro` file with `<script>`, it likely does NOT make it into the client bundle — but the dependency itself is misleading).

---

### 16.2 Client JS Not Minified / Bundled

**Files:** `apps/web/public/js/ui.js` (436 lines), `form-helpers.js` (226 lines), `location-autocomplete.js` (47 lines), `location-map.js` (51 lines)

Client-side JS files are served as raw, unminified source files from `public/js/`. There is no build step, tree-shaking, or minification applied to them. For production, these should be minified.

---

### 16.3 `ui.js` Loaded Globally, Always — Even on Admin Pages

**File:** `apps/web/src/layouts/BaseLayout.astro:202`

```html
<script defer src="/js/ui.js"></script>
```

`ui.js` handles modal management, mobile navigation, notification dropdowns, country selector, etc. It is loaded on every page including admin-only pages that may not need all of it. Consider splitting `ui.js` into smaller modules loaded only where needed.

---

### 16.4 Form POST + Redirect Pattern Not Consistent

Some pages handle form submission via native `POST + redirect` (good for SSR / JS-disabled):
- `login.astro`, `register.astro`, `profile/edit.astro`, `contests/create.astro`

Others use JS-intercepted form submission with `fetch()` for the enhanced experience. The pattern is generally consistent but the error handling between the two paths differs significantly — SSR errors redirect with query params, while JS errors show inline messages.

---

## 17. Accessibility Issues

### 17.1 Region Selector Modal Has Hardcoded Country List

**File:** `apps/web/src/layouts/BaseLayout.astro:524-549`

The country/region selector offers only 6 hardcoded options: US, GB, JP, DE, FR, Global. This is not driven by config or the supported locales list. Not accessible to users from other regions and not maintainable.

---

### 17.2 `maximum-scale=1.0, user-scalable=no` Meta Tag

**File:** `apps/web/src/layouts/BaseLayout.astro:186`

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
```

`user-scalable=no` disables pinch-to-zoom, which is an **accessibility violation** (WCAG 1.4.4 — Resize Text). Users with low vision rely on being able to zoom browser content. Remove `maximum-scale=1.0, user-scalable=no`.

---

### 17.3 `details/summary` Used for Notification Dropdown (Semantics Issue)

**File:** `apps/web/src/layouts/BaseLayout.astro:290-373`

```html
<details class="nav-notifications">
  <summary class="btn-region btn-region--icon" aria-label={t('activity.page_title')}>
```

The `<details>/<summary>` element is semantically a disclosure widget, not a dropdown menu. A navigation notification panel with structured content should use `role="menu"` or a `<dialog>` pattern. Screen readers announce `<details>` content differently than a dropdown menu.

---

### 17.4 Mobile Bottom Nav Missing `aria-current` for Active State

**File:** `apps/web/src/layouts/BaseLayout.astro:493-510`

The mobile bottom navigation links have no `aria-current="page"` attribute to indicate the active page to screen readers.

---

## 18. Caching & Performance

### 18.1 No HTTP Cache Headers on API Responses

No API route sets `Cache-Control` response headers. Public endpoints (contest list, project list, event list) could be cached with `stale-while-revalidate` to dramatically reduce database load. Only `sitemap.xml.ts` has a cache header.

---

### 18.2 `BaseLayout` Makes 2 Uncached DB-Hitting API Calls Per Request

As described in §15.1. Two API calls per page load, each hitting the database, with no caching. For a page that gets 1000 concurrent visitors, this means 2000 uncached DB reads just for navigation data.

---

### 18.3 No Query Result Caching

The `CACHE_TTL` constants exist but are unused. There is no in-memory cache, Redis, or even simple `Map`-based cache for frequently accessed read-only data (e.g., approved contest list, approved project list). Each request recomputes everything from the DB.

---

### 18.4 N+1 Potential in Notification Query

**File:** `apps/api/src/modules/user/user.notifications.ts`

The notification summary aggregates data from messages, applications, RSVPs, and recommendations. Depending on implementation, this could involve multiple sequential queries. Not seen directly but worth profiling.

---

## 19. Middleware Pipeline Issues

### 19.1 No Structured Request Logging Middleware

Fastify's built-in logger is configured (pino), but there is no access log middleware that emits structured log entries per request with route, status code, response time, and user ID. This makes production debugging difficult.

---

### 19.2 Auth Middleware Does Not Differentiate Token Errors

As described in §2.4. The middleware silently swallows ALL exceptions from JWT verification — including malformed tokens, expired tokens, and signature failures — treating them identically to "no token present." This should be split into distinct error states.

---

### 19.3 Rate Limiting Only Applied to Auth Routes

**File:** `apps/api/src/server.ts:88-96`

Rate limiting is configured with `global: false`, meaning it only applies to routes that explicitly configure it (login, register, forgot-password, reset-password). All other API endpoints (content creation, uploads, search) have no rate limiting.

---

## 20. Seed Data Issues

### 20.1 Seed Password Hash is Hardcoded Plaintext Reference

**File:** `packages/database/prisma/seed.ts:4-5`

```ts
const DEFAULT_SEED_PASSWORD = 'Seed123!';
const DEFAULT_PASSWORD_HASH = '$2a$10$RNVebwYmf9b7ey.AgXoPrOxXe7sk/RF3XYs/3Bu3Mde9wf1TQlu1K';
```

The password is referenced in the seed file and printed to console on seed completion. While acceptable for dev, this creates a known credential that could be used to access seeded accounts if ever deployed to staging without a DB reset.

---

### 20.2 Seed Profiles Use Unsplash URLs as `profileImageKey`

**File:** `packages/database/prisma/seed.ts:402`

```ts
profileImageKey: PROFILE_IMAGES[imageIndex],
```

Where `PROFILE_IMAGES` contains full `https://images.unsplash.com/...` URLs. The `profileImageKey` field is designed to store storage keys (relative paths), not absolute URLs. `storage.getUrl(key)` would then prepend the storage base URL to an already-absolute URL, producing a broken double URL.

---

### 20.3 Seed `SeedEvent` Type Has Phantom Fields

As described in §13.4 — `time`, `category`, `price`, `attendees`, `maxAttendees` are in the seed type but not in the DB schema.

---

## 21. Summary Checklist

| Category | Count | Severity |
|----------|-------|----------|
| Security (P0) | 4 | Critical |
| Architecture (P1) | 5 | High |
| DRY Violations | 6 | Medium-High |
| SOLID Violations | 3 | Medium |
| CQRS Inconsistency | 1 | Medium |
| Database Issues | 5 | Medium-High |
| Config Issues | 6 | Medium |
| i18n Issues | 6 | Medium |
| CSS/Styling Issues | 6 | Medium |
| TypeScript `any` | 4 | Medium |
| Dead Code / YAGNI | 8 | Low-Medium |
| Mock/Hardcoded Data | 4 | Medium |
| API Inconsistency | 2 | Medium |
| Frontend Architecture | 4 | Medium |
| SSR/JS Issues | 4 | Low-Medium |
| Accessibility | 4 | Medium |
| Caching/Performance | 4 | Medium |
| Middleware | 3 | Medium |
| Seed Data | 3 | Low |

### Priority Fix Order (Recommended)

1. **P0 — Fix immediately:**
   - Remove `user-scalable=no` from viewport meta (accessibility)
   - Remove Geoapify key from HTML `data-` attribute
   - Eliminate hardcoded JWT/DB credential fallbacks
   - Fix silent auth error swallowing

2. **P1 — Fix before feature work:**
   - Standardize API response envelope (remove triple-data responses)
   - Add `findFirst` to soft delete middleware
   - Create `ProjectApplicationStatus` enum
   - Fix `detectLocale` (always returns default)
   - Fix i18n module-level mutable state (SSR race condition)

3. **Medium — Refactor sprint:**
   - Extract `toPublicProfileImage`, `toPublicCreator`, `requireAuth` to shared utilities
   - Split `auth.ts` into middleware + route modules
   - Fix all CSS token violations and `margin-bottom` patterns
   - Remove `any` types and define proper interfaces
   - Remove dead code (Alpine.js dep, `createStorageServiceFactory`, `CACHE_TTL`, `WEB_PORT`/`PORT` duplicate, unused `requireAdmin`)
   - Fix i18n locale file (move URLs/emails to config)
   - Fix `common.app_url` — use `ENV.APP_BASE_URL` instead
   - Fix `APP_BASE_URL` hardcoded in `api.ts` fallback

4. **Low — Cleanup:**
   - Remove all hardcoded Unsplash URLs from tests and seed
   - Add HTTP cache headers on public list endpoints
   - Minify client JS files
   - Fix seed phantom fields or implement missing Event schema fields
   - Align CQRS structure across all modules
   - Add `aria-current` to mobile nav active states
   - Replace `details/summary` notification dropdown with proper ARIA menu
