# Comprehensive Code Cleanup Audit

## 1. Executive Summary

This codebase is a TFP (Time For Print) Photographers Platform built as a monorepo with:
- **Frontend**: Astro-based web application with 21 components, 37+ pages
- **Backend**: Fastify-based API with 80+ modules following CQRS pattern
- **Shared**: Packages for config, database, email, i18n, storage

**Overall Health Assessment**: The codebase is reasonably well-maintained with no TODO/FIXME comments found. However, there are several areas of technical debt and clutter identified below.

---

## 2. Frontend Cleanup (Page-by-Page / Component-by-Component)

### 2.1 Unused Components (To Be Deleted or Re-integrated)

**Components never imported anywhere:**
- [`tfp-workspace/apps/web/src/components/ListingCard.astro`](tfp-workspace/apps/web/src/components/ListingCard.astro) - Not imported in any page (the component wrapper is unused)
- [`tfp-workspace/apps/web/src/components/ListingShell.astro`](tfp-workspace/apps/web/src/components/ListingShell.astro) - Not imported in any page
- [`tfp-workspace/apps/web/src/components/Pagination.astro`](tfp-workspace/apps/web/src/components/Pagination.astro) - Not imported in any page
- [`tfp-workspace/apps/web/src/components/TextArea.astro`](tfp-workspace/apps/web/src/components/TextArea.astro) - Not imported in any page
- [`tfp-workspace/apps/web/src/components/UploadModerationNotice.astro`](tfp-workspace/apps/web/src/components/UploadModerationNotice.astro) - Used in: create.astro files, profile/edit.astro, contests/[id].astro

**Note**: Pagination and ListingShell are imported in events/index.astro, contests/index.astro, projects/index.astro but these pages appear to use different listing patterns - may need verification.

### 2.2 Unused Icons in Icon Component

[`tfp-workspace/apps/web/src/components/Icon.astro`](tfp-workspace/apps/web/src/components/Icon.astro) (Lines 1-291) - The following icons are defined but never used in the codebase:

| Icon Name | Status |
|-----------|--------|
| `palette` | NOT USED |
| `plus` | NOT USED |
| `map-pin` | NOT USED |
| `arrow-left` | NOT USED |
| `arrow-right` | NOT USED |
| `layout-grid` | NOT USED |
| `log-in` | NOT USED |
| `arrow-up` | NOT USED |
| `check-circle-2` | NOT USED |
| `upload-cloud` | NOT USED |
| `file-text` | NOT USED |
| `shield-check` | NOT USED |
| `x-circle` | NOT USED |
| `check-circle` | NOT USED |
| `image-plus` | NOT USED |

**Recommendation**: Remove 14 unused SVG icons from Icon.astro to reduce bundle size.

### 2.3 Duplicate Route Structure (Contests)

**Issue**: Conflicting/duplicate route structure exists:
- [`tfp-workspace/apps/web/src/pages/contests/[id].astro`](tfp-workspace/apps/web/src/pages/contests/[id].astro) - 46,250 bytes (uses `[id]` convention)
- [`tfp-workspace/apps/web/src/pages/contests/[contestId]/submissions/[submissionId].astro`](tfp-workspace/apps/web/src/pages/contests/[contestId]/submissions/[submissionId].astro) - 25,767 bytes (uses `[contestId]` convention)

The `[contestId]` folder structure appears to be orphaned legacy code. Only the `[id]` folder should be used going forward.

**Files to investigate for potential deletion:**
- `tfp-workspace/apps/web/src/pages/contests/[contestId]/` (entire directory)

### 2.4 CSS Files to Audit

The following SCSS files exist in [`tfp-workspace/apps/web/src/styles/`](tfp-workspace/apps/web/src/styles/):

**Potentially unused page styles (empty or minimal):**
- [`tfp-workspace/apps/web/src/styles/pages/forgot-password.scss`](tfp-workspace/apps/web/src/styles/pages/forgot-password.scss) - Only 205 bytes (2 lines)
- [`tfp-workspace/apps/web/src/styles/pages/register.scss`](tfp-workspace/apps/web/src/styles/pages/register.scss) - Only 238 bytes (2 lines)
- [`tfp-workspace/apps/web/src/styles/pages/reset-password.scss`](tfp-workspace/apps/web/src/styles/pages/reset-password.scss) - Only 205 bytes (2 lines)

These files appear to only import other files and contain no actual styles.

**Empty/unused component styles:**
- [`tfp-workspace/apps/web/src/styles/components/auth-modal-component.scss`](tfp-workspace/apps/web/src/styles/components/auth-modal-component.scss) - Only 22 bytes (appears to be empty or placeholder)

---

## 3. Backend Cleanup (API / Controllers / Services)

### 3.1 Potential Redundant Endpoints

**Contest Routes** ([`tfp-workspace/apps/api/src/modules/contest/contest.routes.ts`](tfp-workspace/apps/api/src/modules/contest/contest.routes.ts)):
- All endpoints appear to be actively used with proper CQRS separation
- No obvious dead endpoints identified

**Project Routes** ([`tfp-workspace/apps/api/src/modules/project/project.routes.ts`](tfp-workspace/apps/api/src/modules/project/project.routes.ts)):
- `POST /:projectId/apply` (Line 406) and `POST /:projectId/applications` (Line 411) - Both point to the same handler `handleProjectApplication`
- This is intentional redundancy for API compatibility, but could be consolidated

### 3.2 Unused Backend Files

The following test files exist but may need verification:
- [`tfp-workspace/apps/api/src/modules/contest/contest.visibility.test.ts`](tfp-workspace/apps/api/src/modules/contest/contest.visibility.test.ts)
- [`tfp-workspace/apps/api/src/modules/contest/contest.winner.test.ts`](tfp-workspace/apps/api/src/modules/contest/contest.winner.test.ts)
- [`tfp-workspace/apps/api/src/modules/contest/contest.lifecycle.ts`](tfp-workspace/apps/api/src/modules/contest/contest.lifecycle.ts) - Contains `canVoteOnContest` and `resolveContestLifecycle` - used in routes

### 3.3 Console Statements (Acceptable)

The following console statements are acceptable (used for error handling and server startup):
- `tfp-workspace/apps/api/src/server.ts` (Line 397) - Server startup errors
- `tfp-workspace/apps/api/src/modules/moderation/infrastructure/ImageModerationFactory.ts` (Lines 35, 65) - Non-production fallback warnings
- Frontend error handlers (appropriate for UX feedback)

---

## 4. Unused Files & Assets (To Be Deleted)

### 4.1 Root Level Documentation Files (Outside tfp-workspace)

The following markdown files exist in the root directory that are NOT part of the actual source code:

| File | Size | Purpose |
|------|------|---------|
| `BB_6march.md` | 24,704 | Working notes - DELETE |
| `codex.md` | 11,071 | Internal documentation - REVIEW |
| `continue_6march.md` | 27,749 | Working notes - DELETE |
| `CTO_REVIEW_REQUIREMENTS_IMPLEMENTATION.md` | 11,380 | Requirements doc - REVIEW |
| `DRY.md` | 5,983 | Design notes - DELETE |
| `DRY2.md` | 5,137 | Design notes - DELETE |
| `features.md` | 31,255 | Features doc - REVIEW |
| `gemini_6march.md` | 10,106 | AI working notes - DELETE |
| `gemini.md` | 12,392 | AI working notes - DELETE |
| `gpt.md` | 28,729 | AI working notes - DELETE |
| `kilo_6march.md` | 14,914 | AI working notes - DELETE |
| `kilo.md` | 66,005 | AI working notes - DELETE |
| `Lingma_6march.md` | 11,210 | AI working notes - DELETE |
| `mockup-guide.md` | 13,313 | Mockup guide - REVIEW |
| `opus_guidelines.md` | 15,459 | Guidelines - REVIEW |
| `opus.md` | 47,645 | AI working notes - DELETE |
| `sonnet.md` | 123,146 | AI working notes - DELETE |
| `zencoder.md` | 46,565 | AI working notes - DELETE |

### 4.2 HTML Mockup Files

Directory: [`mockups/`](mockups/)

These HTML mockup files appear to be outdated prototyping files:
- `contest-detail.html` (107,994 bytes)
- `contests.html` (107,987 bytes)
- `create-contest.html` (107,994 bytes)
- `create-event.html` (107,992 bytes)
- `create-project.html` (107,994 bytes)
- `event-detail.html` (107,992 bytes)
- `events.html` (107,986 bytes)
- `guidelines.html` (107,990 bytes)
- `home.html` (107,984 bytes)
- `privacy.html` (107,987 bytes)
- `profile.html` (107,987 bytes)
- `terms.html` (107,985 bytes)

**Recommendation**: These mockups are likely replaced by the actual Astro implementation. Consider deleting the entire `mockups/` directory.

### 4.3 Unused Image Assets

**Audit Shots** ([`audit-shots/`](audit-shots/)):
- This directory contains 100+ regression test screenshots
- Some are organized by date (regression-2026-03-03T18-57-24-274Z)
- These are QA artifacts and can be archived or deleted after review

**Temporary/Mock Images** (root level):
- `contest-detail-desktop.png` (1.6 MB)
- `contest-submission-desktop.png` (1.5 MB)
- `contest-submission-mobile.png` (342 KB)
- `tmp-*.png` files (multiple)
- `project-apply-*.png` files

These appear to be working assets during development - review for deletion.

---

## 5. Dependency Audit

### 5.1 Root Package.json ([`tfp-workspace/package.json`](tfp-workspace/package.json))

```json
{
  "devDependencies": {
    "@astrojs/check": "^0.9.6",
    "@playwright/test": "^1.58.2",
    "@types/node": "^20.19.35",
    "concurrently": "^8.2.2",
    "typescript": "^5.3.3"
  }
}
```

**Assessment**: All dependencies appear to be in use.

### 5.2 Frontend Package.json ([`tfp-workspace/apps/web/package.json`](tfp-workspace/apps/web/package.json))

```json
{
  "dependencies": {
    "@astrojs/node": "^8.2.1",
    "@astrojs/sitemap": "^3.0.5",
    "astro": "^4.2.1",
    "config": "workspace:*",
    "i18n": "workspace:*",
    "shared": "workspace:*"
  },
  "devDependencies": {
    "@playwright/test": "^1.41.1",
    "sass": "^1.69.7",
    "typescript": "^5.3.3"
  }
}
```

**Assessment**: All dependencies appear to be in use.

### 5.3 Backend Package.json ([`tfp-workspace/apps/api/package.json`](tfp-workspace/apps/api/package.json))

```json
{
  "dependencies": {
    "@aws-sdk/client-rekognition": "^3.915.0",
    "@fastify/cookie": "^9.3.1",
    "@fastify/cors": "^9.0.1",
    "@fastify/helmet": "^11.1.1",
    "@fastify/jwt": "^8.0.0",
    "@fastify/rate-limit": "^9.1.0",
    "@prisma/client": "^5.8.0",
    "bcryptjs": "^2.4.3",
    "@google-cloud/vision": "^5.3.3",
    "fastify": "^4.26.0",
    "fastify-plugin": "^4.5.1",
    "zod": "^3.22.4"
  }
}
```

**Assessment**: All dependencies appear to be in use. Both AWS Rekognition and Google Cloud Vision are included for moderation - this is intentional multi-provider support.

---

## 6. Global Redundancy & Clutter

### 6.1 Duplicate Route Parameter Naming

- Frontend uses both `[id]` and `[contestId]` for contest routes
- This creates confusion and potential routing conflicts
- Recommend standardizing on `[id]` parameter name

### 6.2 CSS Architecture

The SCSS architecture is well-organized but some files are empty/minimal placeholders:
- `pages/forgot-password.scss` - 205 bytes (empty)
- `pages/register.scss` - 238 bytes (empty)
- `pages/reset-password.scss` - 205 bytes (empty)
- `components/auth-modal-component.scss` - 22 bytes (empty)

### 6.3 Console Statements

**Frontend**: 13 `console.error` statements - all in error handling paths (acceptable)
**Backend**: 3 console statements - all for server startup/warnings (acceptable)

### 6.4 TODO/FIXME Comments

**Result**: NONE FOUND - Excellent!

---

## 7. Cleanup Priority Recommendations

### High Priority (Do First)
1. **Delete unused icons** from Icon.astro (14 SVG definitions)
2. **Delete entire `mockups/` directory** (replaced by real implementation)
3. **Delete/merge duplicate contest route** (`[contestId]` folder)
4. **Delete working notes markdown files** (gemini.md, gpt.md, kilo.md, opus.md, etc.)

### Medium Priority (Do Second)
5. **Review and delete unused components** (ListingCard, ListingShell, Pagination if truly unused)
6. **Delete empty CSS placeholder files**
7. **Archive or delete audit-shots/** after QA review

### Low Priority (Do Later)
8. **Consolidate duplicate project apply endpoints** (optional API improvement)
9. **Standardize route parameter naming** across all modules
