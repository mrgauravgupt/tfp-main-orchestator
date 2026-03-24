# TFP Photographers Platform - Guidelines Compliance Audit

## Executive Summary

The codebase has a solid foundation: monorepo structure, centralized config (`packages/config`), i18n package, adapter-pattern storage, CQRS in the moderation module, and design tokens in SCSS. However, there are actionable violations and improvement areas across backend, frontend, CSS, database, and infrastructure that would bring it closer to production-grade quality.

---

## 1. SOLID / Clean Architecture Violations

### 1.1 Fat Route Files (SRP Violation)
- **Files**: `contest.routes.ts` (1034 lines), `project.routes.ts` (649 lines), `user.routes.ts` (650+ lines), `event.routes.ts` (402 lines)
- **Issue**: Route files contain inline Zod schemas, business logic, image moderation orchestration, error mapping, and response shaping all in one file.
- **Fix**: Extract inline schemas to `*.schemas.ts` files per module. Move response mapping to service layer. Keep route files thin (just request parsing, calling command/query, returning response).

### 1.2 Inconsistent CQRS Adoption
- **Good**: `contest` module has `commands/` and `queries/` folders with proper CQRS separation.
- **Good**: `moderation` module follows clean/hexagonal architecture (domain, application, infrastructure layers).
- **Bad**: `project`, `event`, `user` modules have `*.commands.ts` and `*.queries.ts` as flat files, not folder-organized like `contest`.
- **Fix**: Standardize all modules to the same CQRS folder structure as `contest` and `moderation`.

### 1.3 Missing Repository Pattern in Most Modules
- **Good**: `moderation` has `PrismaModerationRepository` behind `IModerationRepository` interface.
- **Bad**: All other modules (`contest`, `project`, `event`, `user`, `auth`, `admin`) call `prisma` directly in commands/queries.
- **Fix**: Introduce repository interfaces per module so the data layer is swappable. This aligns with the Dependency Injection guideline.

---

## 2. DRY Violations

### 2.1 Duplicated `toPublicUrl` Helper
- **Files**: Defined identically in `contest.routes.ts`, `project.routes.ts`, `event.routes.ts`, `user.routes.ts`
- **Fix**: Move to `apps/api/src/utils/storage-helpers.ts` or `modules/shared/`.

### 2.2 Duplicated `moderationFailurePayload` Helper
- **Files**: Defined identically in `contest.routes.ts`, `project.routes.ts`, `event.routes.ts`, `user.routes.ts`
- **Fix**: Move to `apps/api/src/utils/moderation-helpers.ts` or `modules/shared/`.

### 2.3 Duplicated Moderation Orchestration Pattern
- **Issue**: Every route file that handles uploads repeats the same pattern: validate file -> upload -> moderate -> persist evidence -> return error/success. This orchestration is copy-pasted across contest, project, event, and user routes.
- **Fix**: Create a shared `moderateAndUpload()` pipeline function.

### 2.4 Duplicated Error Response Shapes
- **Issue**: Inline `{ success: false, error: { code, message } }` objects are constructed ad-hoc in every route handler instead of using `sendError()` from `http-errors.ts` consistently.
- **Fix**: Use `sendError()` everywhere. Ensure all error responses go through the centralized helper.

### 2.5 CSS `margin-bottom` Usage
- **Issue**: `margin-bottom` appears in 21 SCSS files across pages, components, and layouts. The guideline specifies "margin-top only" for consistent vertical rhythm.
- **Fix**: Audit and convert all `margin-bottom` usages to `margin-top` on the subsequent sibling or use `gap` in flex/grid layouts.

---

## 3. CSS / Styling Violations

### 3.1 Hardcoded `px` Values in Page SCSS
- **Issue**: Hundreds of hardcoded `px` values across 22+ page SCSS files (e.g., `min-height: 450px`, `width: 300px`, `border-radius: 1.5rem` instead of `$radius-2xl`).
- **Files**: `home.scss` (52 instances), `profile-detail.scss` (35), `event-detail.scss` (36), `project-detail.scss` (24), `contest-detail.scss` (23), `profile-edit.scss` (29), etc.
- **Fix**: Replace hardcoded values with token variables from `tokens.scss` wherever possible. For truly one-off values, add them as named tokens.

### 3.2 Duplicate Font Family Declaration
- **File**: `base-layout.scss` line 8 re-declares `font-family: 'Inter', system-ui, -apple-system, sans-serif;` instead of using `$font-family-body` from tokens.
- **Fix**: Use the token variable.

### 3.3 Token File Has Redundant Aliases
- **File**: `tokens.scss` defines both CSS custom properties (`--space-1` through `--space-24`) AND SCSS variables (`$space-1` through `$space-16`) AND a `$spacing` map, all with the same values.
- **Fix**: Pick one approach as canonical. Recommend SCSS variables for compile-time usage and CSS custom properties for runtime/theming only. Remove the `$spacing` map duplicate.

### 3.4 No Light Theme / Theme-Aware UI
- **Issue**: The design tokens are dark-mode only. There is no `:root[data-theme="light"]` or `@media (prefers-color-scheme: light)` override.
- **Fix**: Add light-mode token overrides for theme-aware UI. Even if dark-first, the architecture should support theming via CSS custom property swapping.

### 3.5 Large Monolithic SCSS Files
- **Files**: `base-layout.scss` (1333 lines), `profile-detail.scss` (955 lines), `home.scss` (746 lines), `listings.scss` (746+ lines)
- **Fix**: Break into smaller partials using SCSS `@use` composition.

---

## 4. i18n Violations

### 4.1 Hardcoded Strings in Backend
- **Issue**: All API error messages, email subjects, and email body text are hardcoded English strings in `server.ts`, `auth.routes.ts`, and route files.
- **Examples**:
  - `subject: 'Contest approved: ${contest.title}'` (server.ts)
  - `message: 'Registration is currently disabled'` (auth.routes.ts)
  - `message: 'Image was rejected by moderation policy'` (multiple route files)
- **Fix**: Use i18n `t()` function for all user-facing strings. For emails, use template keys from `en_US.json`.

### 4.2 Missing i18n Keys for Backend Messages
- **Issue**: The `en_US.json` master file has no keys for API error messages, email templates, moderation messages, or validation errors.
- **Fix**: Add sections like `api_errors.*`, `emails.*`, `moderation.*` to `en_US.json`.

### 4.3 `any` Type Cast in i18n Calls
- **File**: `ListingCard.astro` line 54: `t(key as any)` - This breaks type safety.
- **Fix**: The `LocaleKey` type is currently just `string`. Make it a proper union of valid dot-paths derived from `en_US.json`.

---

## 5. Database / Schema Violations

### 5.1 `Json?` Type for Structured Data
- **Fields**: `User.location`, `Project.location`, `Event.location`, `Project.budget`, `Event.entryFees`, `PortfolioImage.exifData`
- **Issue**: `Json?` lacks schema enforcement at the DB level. Location has a Zod schema at the API layer but nothing at the DB level.
- **Fix**: Create proper `Location` model with `country`, `region`, `city`, `lat`, `lon` fields as a one-to-one relation. This enables location-based queries (e.g., find events in a city) at the DB level.

### 5.2 Denormalized Counters Without Transactions
- **Fields**: `ContestSubmission.likeCount`, `voteCount`, `shareCount`
- **Issue**: These denormalized counters can drift from actual `ContestSubmissionReaction` records if updates don't use transactions.
- **Fix**: Ensure all counter updates are wrapped in `prisma.$transaction()` with the reaction create/delete. Alternatively, compute counts from reactions on read.

### 5.3 Soft Delete Without Middleware
- **Issue**: Multiple models use `deletedAt` for soft deletes, but there's no Prisma middleware to automatically filter deleted records. Every query must manually add `deletedAt: null`.
- **Fix**: Implement Prisma middleware for automatic soft-delete filtering.

### 5.4 Missing Indexes for Common Query Patterns
- **Issue**: No composite index on `(status, createdAt)` for listing queries that filter by status and sort by date.
- **Fix**: Add composite indexes for common query patterns.

---

## 6. Frontend Architecture Violations

### 6.1 No Alpine.js or Client-Side Framework
- **Issue**: The `x-data` / Alpine.js directive count is **zero** across all `.astro` files. The app appears to have removed Alpine but hasn't replaced it with any client-side interactivity framework.
- **Impact**: Forms, modals, dropdowns, search, and notifications likely require JS for enhanced UX but there's no JS framework for progressive enhancement.
- **Fix**: Either re-add Alpine.js for lightweight interactivity or use Astro islands with a framework (React/Svelte) for interactive components.

### 6.2 Monolithic `ListingCard.astro`
- **Issue**: Single 245-line component handles three completely different variants (project, contest, event) via conditional rendering.
- **Fix**: Split into `ProjectCard.astro`, `ContestCard.astro`, `EventCard.astro` sharing a common `CardShell.astro`.

### 6.3 Heavy `BaseLayout.astro`
- **Issue**: 643+ lines with API calls, auth logic, SEO setup, navigation, footer, modals, toast, and report modal all in one file.
- **Fix**: Extract into smaller components: `NavBar.astro`, `Footer.astro`, `SEOHead.astro`, `ToastContainer.astro`, etc.

### 6.4 Excessive Use of `any` Type
- **Issue**: `any` type used extensively in `.astro` frontmatter (e.g., `let featuredProject: any`, `item: any` in ListingCard props).
- **Fix**: Define proper TypeScript interfaces for API response shapes and use them in component props.

### 6.5 No Progressive Enhancement / JS-Disabled Fallback
- **Issue**: The guideline says "Both SSR JS disabled and JS enabled should work." Without Alpine.js or any client JS framework, interactive features (modals, form validation, search autocomplete) have no JS-enhanced path.
- **Fix**: Implement progressive enhancement - base functionality via SSR forms/links, JS-enhanced UX via Alpine.js or Astro islands.

---

## 7. Security

### 7.1 Input Sanitization Gaps
- **Good**: `text-sanitize.ts` exists and Zod validation is used.
- **Issue**: Not all user inputs go through sanitization. Direct `request.body` fields like `email`, `password` don't need HTML sanitization, but free-text fields in some handlers may bypass `sanitizePlainText()`.
- **Fix**: Audit all text input fields to ensure consistent sanitization.

### 7.2 Helmet CSP Disabled
- **File**: `server.ts` line 84: `contentSecurityPolicy: false`
- **Fix**: Define a proper CSP policy, even a permissive one, rather than disabling it entirely.

---

## 8. Environment / Configuration

### 8.1 Missing Staging Environment Config
- **Issue**: Only `.env.development` and `.env.production` exist. No `.env.staging`.
- **Fix**: Add `.env.staging` for the staging environment.

### 8.2 Duplicate Backblaze Config Keys
- **File**: `.env.development` has both `B2_*` and `BACKBLAZE_*` prefixed keys for the same values.
- **Fix**: Standardize on one prefix (`B2_*`) and remove the duplicates.

### 8.3 Limited Feature Flags
- **Issue**: Only 2 feature flags exist: `FEATURE_REGISTRATION_ENABLED` and `FEATURE_SOCIAL_LOGIN`. No feature flag for contests, events, messaging, etc.
- **Fix**: Add feature flags for major features to enable gradual rollout.

### 8.4 No API Versioning Strategy Beyond Prefix
- **Issue**: API versioning is just a URL prefix (`/api/v1`). No header-based versioning or version negotiation.
- **Fix**: This is fine for now but document the versioning strategy for when v2 is needed.

---

## 9. Caching

### 9.1 No Application-Level Caching
- **Issue**: HTTP cache headers are set on responses (good), but there is no in-memory or Redis-based caching for expensive DB queries (listing pages, search results, user profiles).
- **Fix**: Add a caching layer (in-memory for dev, Redis for prod) for read-heavy endpoints. The `CACHE_TTL` constants exist but are only used for HTTP headers.

---

## 10. Code Comments

### 10.1 Inconsistent Comment Coverage
- **Good**: Package-level files (`config/index.ts`, `i18n/index.ts`, `storage/index.ts`) have thorough JSDoc comments.
- **Bad**: Route handlers, service functions, and utility functions in most modules have minimal or no inline comments.
- **Fix**: Add inline comments for non-obvious business logic, validation rules, and edge cases.

---

## 11. Code Cleanup Opportunities

### 11.1 Unused Imports / Dead Code Candidates
- Audit needed: `shared` package's `eventBus.ts` exports should be checked for unused event types.
- `ListingShell.astro` (800 bytes) - check if still used or replaced by other shell components.

### 11.2 `.DS_Store` Files in Repository
- **Files**: `apps/web/src/.DS_Store`, `apps/web/src/styles/.DS_Store`
- **Fix**: Add `.DS_Store` to `.gitignore` and remove tracked instances.

### 11.3 Large Audit Screenshots in Repo
- **Directory**: `audit-shots/` contains 100+ PNG files (many >1MB).
- **Fix**: Move to external storage or a separate artifact repository.

---

## 12. Testing

### 12.1 Limited Test Coverage
- **Existing tests**: `contest.visibility.test.ts`, `contest.winner.test.ts`, `admin.routes.test.ts`, `user.activity.test.ts`, `user.public-list.test.ts`, `auth.reset.test.ts`, `auto-moderation-report.test.ts`, `content.delete.test.ts`
- **Missing**: No tests for project routes, event routes, message routes, report routes, storage adapters, email adapters, i18n functions, or frontend utils.
- **Fix**: Add test coverage for critical paths.

---

## 13. JS Bundle / Performance

### 13.1 No Client JS Bundle Splitting
- **Issue**: `astro.config.mjs` has no `manualChunks` or code-splitting configuration. No Alpine.js or client framework is loaded.
- **Fix**: When client JS is added, ensure code splitting via Vite config.

### 13.2 SSR API Call in Layout
- **File**: `BaseLayout.astro` makes a `fetch('/auth/me')` call on every page load to check auth status.
- **Fix**: Use cookie-only auth check for layout rendering. Move the `/auth/me` call to pages that actually need user data.

---

## 14. Accessibility

### 14.1 Good Foundation
- `aria-label` attributes are used on interactive elements (good).
- `.sr-only` utility class exists (good).
- `focus-visible` styles are defined (good).

### 14.2 Gaps
- No skip-to-content link.
- No ARIA live regions for dynamic content updates.
- No `role` attributes on landmark regions.
- Image `onerror` handlers hide images but don't provide text fallback for screen readers.
- **Fix**: Add skip navigation, ARIA landmarks, and live regions.

---

## Priority Action Items (Ordered by Impact)

1. **DRY: Extract duplicated helpers** (`toPublicUrl`, `moderationFailurePayload`, moderation orchestration) - Quick win, reduces ~200 lines of duplication
2. **Slim down route files** - Extract schemas, move business logic to services
3. **Standardize module structure** - All modules should follow contest/moderation CQRS pattern
4. **Replace `Json?` with proper Location model** - DB integrity improvement
5. **Add `margin-bottom` to `margin-top` conversion** - CSS consistency
6. **Replace hardcoded px values with tokens** - CSS maintainability
7. **Add i18n keys for backend messages** - Complete i18n coverage
8. **Add client-side interactivity framework** - Progressive enhancement
9. **Split monolithic components** - `ListingCard`, `BaseLayout`
10. **Add `.env.staging`** - Environment config completeness
11. **Enable CSP in helmet** - Security posture
12. **Add application-level caching** - Performance
13. **Type the `any` usages** - TypeScript safety
14. **Add soft-delete Prisma middleware** - Data integrity
15. **Theme-aware CSS tokens** - Light mode support
