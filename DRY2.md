# DRY Compliance & Hardcoding Audit

## 1. Hardcoded Colors

**Status: GOOD** — All hex colors live exclusively in `apps/web/src/styles/tokens.scss`. No raw `#hex` values found in page/component SCSS files or inline styles in `.astro` files.

**Minor issue**: In `tokens.scss` itself, `$color-error: #ef4444` duplicates `$error: #ef4444` (line 48 vs 255). Same for `$button-primary-end: #7c3aed` duplicating `$accent-violet` (line 43 vs 38).

## 2. Hardcoded Breakpoints (HIGH severity)

**77 hardcoded media-query breakpoints** found despite `$breakpoint-*` variables being defined in `tokens.scss`:

| Hardcoded value | Token available | Files affected |
|---|---|---|
| `768px` | `$breakpoint-md` | ~50+ occurrences across all create/edit/detail SCSS files |
| `640px` | `$breakpoint-sm` | `home.scss`, etc. |
| `1024px` | `$breakpoint-lg` | `home.scss` |
| `767px` | `$breakpoint-md - 1px` | `profile-edit.scss` |

**Affected files**: `event-create.scss`, `contest-create.scss`, `project-create.scss`, `profile-edit.scss`, `home.scss`, `_create-shell-shared.scss`, `_detail-shared.scss`, and more.

## 3. Hardcoded `max-width: 1280px` (MEDIUM)

Found in `search.scss:5` and `contest-submissions.scss:5`, but `$max-width: 1280px` exists in tokens.

## 4. Hardcoded URLs (MEDIUM)

| URL pattern | Occurrences | Should be |
|---|---|---|
| `https://twitter.com/intent/tweet?url=...` | 5x in `[submissionId].astro`, `[id].astro` | Shared util/constant |
| `https://www.facebook.com/sharer/sharer.php?u=...` | 3x in same files | Shared util/constant |
| `https://schema.org` | 5x in detail pages and `BaseLayout.astro` | Fine (standard spec URL) |
| `https://tfpphotographers.com` | 1x hardcoded in `sitemap.xml.ts:46` | Should use env var |
| `http://localhost:4000` | 1x in `api.ts:8` | Fine (SSR-only fallback) |

## 5. DRY Violations — Backend

### 5a. `toPublicUrl` helper — copy-pasted 4 times (HIGH)

Identical function defined independently in:
- `event.routes.ts:32`
- `project.routes.ts:55`
- `contest.routes.ts:63`
- `user.routes.ts:56`

**Fix**: Extract to `utils/url.ts` or a shared module.

### 5b. `moderationFailurePayload` — copy-pasted 4 times (HIGH)

Identical factory function in the same 4 route files, used 15 times total.

**Fix**: Move to `utils/http-errors.ts` alongside `buildErrorPayload`.

### 5c. `normalizeUpper` — copy-pasted 3 times (MEDIUM)

Identical inline function in:
- `event.routes.ts:52`
- `project.routes.ts:121`
- `contest.routes.ts:240`

### 5d. `mapXxxCreator` — 3 near-identical functions (HIGH)

All do the same thing (map `profileImageKey` through `toPublicUrl`):
- `mapEventCreator` in `event.services.ts:5`
- `mapProjectCreator` in `project.services.ts:9`
- `mapContestCreator` in `contest.services.ts:5`

**Fix**: Extract a single `mapCreatorProfileImage` to `shared/`.

### 5e. Authorization patterns — repeated ~20 times (MEDIUM)

The `canViewPending` / `canEdit` / `canDelete` ownership check pattern is repeated identically across event, project, and contest routes:
```ts
const canEdit = existing.creatorId === request.userId || request.userRole === 'ADMIN';
```

**Fix**: Create `authorizeOwnerOrAdmin(entity, request)` helper in `utils/auth-guards.ts`.

### 5f. Inline 404/403 error payloads (MEDIUM)

`{ success: false, error: { code: 'NOT_FOUND', message: '...' } }` is manually constructed ~47 times despite `buildErrorPayload` and `sendError` already existing in `utils/http-errors.ts`.

## 6. DRY Violations — Frontend SCSS

### 6a. `.page-header`, `.error-banner`, `.glass-card`, `.form-footer`, `.submit-btn` (HIGH)

These blocks are **copy-pasted nearly identically** across 3-4 create-page SCSS files:
- `event-create.scss` (lines 10-58, 259-338)
- `contest-create.scss` (lines 10-37, 140-199)
- `project-create.scss` (lines 17-48, 65-75)

The project already has `_create-shell-shared.scss` for some shared styles — these repeated blocks should be moved there as additional mixins.

### 6b. `ListingCard.astro` monolithic component (MEDIUM)

`ListingCard.astro` has 245 lines with 3 entirely separate markup branches for `project`, `contest`, and `event` variants. The media section pattern (img + fallback icon + badge) is repeated 3 times with minor differences. Consider splitting into `ProjectCard`, `ContestCard`, `EventCard` or extracting a shared `CardMedia` subcomponent.

## 7. Non-tokenized `rgba()` alpha values (LOW)

358+ instances of `rgba($token, 0.XX)` with ad-hoc alpha values throughout SCSS (e.g., `0.1`, `0.24`, `0.3`, `0.56`, etc.). While the base colors use tokens, the alpha variants are inconsistent. Some are already tokenized in `tokens.scss` (e.g., `$border-overlay-30`) but most page files use raw `rgba()` instead.

## Summary by Severity

| Severity | Count | Key issues |
|---|---|---|
| **HIGH** | 4 | Hardcoded breakpoints (77x); `toPublicUrl` x4; `moderationFailurePayload` x4; `mapXxxCreator` x3; repeated create-form SCSS |
| **MEDIUM** | 5 | `normalizeUpper` x3; auth patterns x20; inline error payloads x47; `max-width: 1280px`; social share URLs |
| **LOW** | 2 | Non-tokenized rgba alphas; duplicate token aliases in tokens.scss |
