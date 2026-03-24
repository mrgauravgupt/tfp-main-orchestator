# Comprehensive Code Cleanup Audit

## 1. Executive Summary

This audit examines the TFP (Time For Print) Photographers Platform codebase, a monorepo consisting of:
- **Frontend**: Astro-based web application with 20 components, 37+ pages
- **Backend**: Fastify-based API with CQRS pattern modules
- **Shared Packages**: Config, database, email, i18n, storage packages

**Overall Health Assessment**: The codebase is well-structured with modern patterns. However, this audit identifies specific unused assets, redundant code, and clutter that should be addressed.

### Key Findings Summary:
- 1 unused component (TextArea.astro)
- 14+ unused SVG icons in Icon.astro
- 22+ outdated HTML mockup files
- 15+ working note markdown files in root
- Duplicate route structure in contests
- Multiple empty/minimal CSS placeholder files
- Acceptable console statements (mostly in test/seed files)

---

## 2. Frontend Cleanup (Page-by-Page / Component-by-Component)

### 2.1 Unused Components

**`tfp-workspace/apps/web/src/components/TextArea.astro`**
- Status: **NOT IMPORTED ANYWHERE**
- Action: Delete this file

**`tfp-workspace/apps/web/src/components/ListingCard.astro`**
- Status: **USED** (imported in contests/index.astro and events/index.astro)
- Action: Keep

**`tfp-workspace/apps/web/src/components/ListingShell.astro`**
- Status: **USED** (imported in contests/index.astro and events/index.astro)
- Action: Keep

**`tfp-workspace/apps/web/src/components/Pagination.astro`**
- Status: **USED** (imported in contests/index.astro, events/index.astro, search.astro, contests/[id]/submissions/index.astro)
- Action: Keep

**`tfp-workspace/apps/web/src/components/UploadModerationNotice.astro`**
- Status: **USED** (imported in 6 pages: projects/create.astro, profile/edit.astro, profile/[email].astro, contests/[id].astro, contests/create.astro, events/create.astro)
- Action: Keep

### 2.2 Unused Icons in Icon Component

**`tfp-workspace/apps/web/src/components/Icon.astro`**

The following SVG icons are defined but never imported in any file:

| Icon Name | Status | Recommendation |
|-----------|--------|----------------|
| `palette` | NOT USED | Remove |
| `plus` | NOT USED | Remove |
| `map-pin` | NOT USED | Remove |
| `arrow-left` | NOT USED | Remove |
| `arrow-right` | NOT USED | Remove |
| `layout-grid` | NOT USED | Remove |
| `log-in` | NOT USED | Remove |
| `arrow-up` | NOT USED | Remove |
| `check-circle-2` | NOT USED | Remove |
| `upload-cloud` | NOT USED | Remove |
| `file-text` | NOT USED | Remove |
| `shield-check` | NOT USED | Remove |
| `x-circle` | NOT USED | Remove |
| `check-circle` | NOT USED | Remove |
| `image-plus` | NOT USED | Remove |

**Total: 15 unused SVG definitions** - Remove to reduce bundle size

### 2.3 Duplicate Route Structure

**`tfp-workspace/apps/web/src/pages/contests/`**

| Path | Status |
|------|--------|
| `[id].astro` | Active - Main contest detail page |
| `[id]/submissions/index.astro` | Active - Contest submissions list |
| `[contestId]/submissions/[submissionId].astro` | **LEGACY** - Duplicate structure using different parameter name |

The `[contestId]` folder structure is orphaned legacy code that should be removed. Only the `[id]` convention should be used.

**Action**: Delete `tfp-workspace/apps/web/src/pages/contests/[contestId]/` directory

### 2.4 Empty/Minimal CSS Files

**`tfp-workspace/apps/web/src/styles/pages/forgot-password.scss`** (205 bytes)
- Only contains imports, no actual styles
- Action: Delete or add meaningful styles

**`tfp-workspace/apps/web/src/styles/pages/register.scss`** (238 bytes)
- Only contains imports, no actual styles
- Action: Delete or add meaningful styles

**`tfp-workspace/apps/web/src/styles/pages/reset-password.scss`** (205 bytes)
- Only contains imports, no actual styles
- Action: Delete or add meaningful styles

**`tfp-workspace/apps/web/src/styles/components/auth-modal-component.scss`** (22 bytes)
- Empty/placeholder file
- Action: Delete

### 2.5 Pages with Potential Cleanup

**`tfp-workspace/apps/web/src/pages/login.astro`**
- Lines 50-70: Contains commented-out debugging code and redundant div containers
- Action: Clean up commented code

**`tfp-workspace/apps/web/src/pages/register.astro`**
- Lines 1-3: Contains commented-out code blocks
- Action: Clean up commented code

**`tfp-workspace/apps/web/src/pages/search.astro`**
- Line 360: Contains unnecessary console.log statements
- Action: Remove console.log

---

## 3. Backend Cleanup (API / Controllers / Services)

### 3.1 API Route Assessment

All major API routes appear to be properly used:

| Module | Routes | Status |
|--------|--------|--------|
| `/users` | All routes | Active |
| `/contests` | All routes | Active |
| `/projects` | All routes | Active |
| `/events` | All routes | Active |
| `/messages` | All routes | Active |
| `/admin` | All routes | Active |
| `/reports` | All routes | Active |
| `/location` | All routes | Active |
| `/search` | All routes | Active |

### 3.2 Project Routes Redundancy

**`tfp-workspace/apps/api/src/modules/project/project.routes.ts`**
- `POST /:projectId/apply` (Line 406)
- `POST /:projectId/applications` (Line 411)

Both endpoints use the same handler `handleProjectApplication` - this is intentional for API backward compatibility but could be documented or consolidated.

### 3.3 Console Statements (Acceptable)

The following console statements are acceptable (server operations, tests, seeding):

- `tfp-workspace/apps/api/src/server.ts` - Server startup errors
- `tfp-workspace/global.setup.ts` - Test database seeding logs
- `tfp-workspace/packages/database/prisma/seed.ts` - Database seeding logs
- `tfp-workspace/tests/e2e/*.ts` - Test output logs

### 3.4 Backend Files Assessment

| File | Status |
|------|--------|
| `contest.lifecycle.ts` | Active - Used in contest routes |
| `contest.visibility.test.ts` | Active - Test file |
| `contest.winner.test.ts` | Active - Test file |
| All command/query files | Active - Part of CQRS pattern |

---

## 4. Unused Files & Assets (To Be Deleted)

### 4.1 Mockup Files

**Directory**: `mockups/` (22 files)

All these HTML mockup files are outdated prototypes replaced by the Astro implementation:

| File | Size |
|------|------|
| `mockups/auth-github.html` | ~108KB |
| `mockups/auth-google.html` | ~108KB |
| `mockups/contest-detail.html` | ~108KB |
| `mockups/contests.html` | ~108KB |
| `mockups/create-contest.html` | ~108KB |
| `mockups/create-event.html` | ~108KB |
| `mockups/create-project.html` | ~108KB |
| `mockups/event-detail.html` | ~108KB |
| `mockups/events.html` | ~108KB |
| `mockups/forgot-password.html` | ~108KB |
| `mockups/guidelines.html` | ~108KB |
| `mockups/home.html` | ~108KB |
| `mockups/index.html` | ~108KB |
| `mockups/login.html` | ~108KB |
| `mockups/privacy.html` | ~108KB |
| `mockups/profile.html` | ~108KB |
| `mockups/project-detail.html` | ~108KB |
| `mockups/projects.html` | ~108KB |
| `mockups/register.html` | ~108KB |
| `mockups/terms.html` | ~108KB |

**Action**: Delete entire `mockups/` directory

### 4.2 Root Level Documentation Files (Working Notes)

These markdown files contain working notes and should be deleted:

| File | Purpose | Action |
|------|---------|--------|
| `BB_6march.md` | Working notes | DELETE |
| `continue_6march.md` | Working notes | DELETE |
| `DRY.md` | Design notes | DELETE |
| `DRY2.md` | Design notes | DELETE |
| `gemini_6march.md` | AI working notes | DELETE |
| `gemini.md` | AI working notes | DELETE |
| `gpt.md` | AI working notes | DELETE |
| `kilo_6march.md` | AI working notes | DELETE |
| `kilo.md` | AI working notes | DELETE |
| `Lingma_6march.md` | AI working notes | DELETE |
| `opus.md` | AI working notes | DELETE |
| `sonnet.md` | AI working notes | DELETE |
| `zencoder.md` | AI working notes | DELETE |

**Files to REVIEW** (may contain useful documentation):
- `codex.md` - Internal documentation
- `CTO_REVIEW_REQUIREMENTS_IMPLEMENTATION.md` - Requirements doc
- `features.md` - Features documentation
- `mockup-guide.md` - Mockup guide
- `opus_guidelines.md` - Guidelines

### 4.3 Temporary Image Files

Root level image files that appear to be temporary working assets:
- `contest-detail-desktop.png` (1.6 MB)
- `contest-submission-desktop.png` (1.5 MB)
- `contest-submission-mobile.png` (342 KB)
- `project-apply-*.png` files
- `tmp-*.png` files (multiple)

**Action**: Review and delete temporary image files

### 4.4 Test/QA Artifacts

**`audit-shots/` directory**
- Contains 100+ regression test screenshots
- Some organized by date (regression-2026-03-03T18-57-24-274Z)
- Action: Archive or delete after QA review

**`tfp-workspace/tmp/` directory**
- Contains temporary files and debug outputs
- Should be in .gitignore
- Action: Review and ensure ignored by git

---

## 5. Dependency Audit

### 5.1 Root Package.json (`tfp-workspace/package.json`)

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

**Assessment**: All dependencies are in use.

### 5.2 Frontend Package.json (`tfp-workspace/apps/web/package.json`)

```
json
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

**Assessment**: All dependencies are in use. `sass` is used for SCSS compilation.

### 5.3 Backend Package.json (`tfp-workspace/apps/api/package.json`)

```
json
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

**Assessment**: All dependencies are in use. Both AWS Rekognition and Google Cloud Vision are intentionally included for multi-provider image moderation support.

---

## 6. Global Redundancy & Clutter

### 6.1 Route Parameter Naming Inconsistency

- Frontend uses both `[id]` and `[contestId]` for contest routes
- Creates confusion and potential routing conflicts
- **Recommendation**: Standardize on `[id]` parameter name

### 6.2 CSS Architecture

The SCSS architecture is well-organized but some files are empty placeholders:
- `pages/forgot-password.scss` - 205 bytes (empty)
- `pages/register.scss` - 238 bytes (empty)
- `pages/reset-password.scss` - 205 bytes (empty)
- `components/auth-modal-component.scss` - 22 bytes (empty)

### 6.3 TODO/FIXME Comments

**Result**: NONE FOUND in source code - Excellent!

### 6.4 Existing Cleanup Files

Note: There are two existing cleanup audit files in the repository:
- `cleanup.md` - Previous cleanup audit
- `cleanup_lingma.md` - Additional cleanup audit

This document (`cleanup_bb.md`) provides additional findings and verification.

---

## 7. Cleanup Priority Recommendations

### High Priority (Do First)

1. **Delete `tfp-workspace/apps/web/src/components/TextArea.astro`** - Not imported anywhere
2. **Remove 15 unused SVG icons from `Icon.astro`** - Reduce bundle size
3. **Delete entire `mockups/` directory** - Replaced by Astro implementation
4. **Delete `tfp-workspace/apps/web/src/pages/contests/[contestId]/`** - Legacy duplicate route
5. **Delete 13 working note markdown files** from root (gemini.md, gpt.md, kilo.md, opus.md, etc.)

### Medium Priority (Do Second)

6. **Delete empty CSS placeholder files:**
   - `styles/pages/forgot-password.scss`
   - `styles/pages/register.scss`
   - `styles/pages/reset-password.scss`
   - `styles/components/auth-modal-component.scss`

7. **Clean up commented code in:**
   - `pages/login.astro` (lines 50-70)
   - `pages/register.astro` (lines 1-3)
   - `pages/search.astro` (console.log on line 360)

8. **Archive or delete `audit-shots/`** after QA review

### Low Priority (Do Later)

9. **Document duplicate project apply endpoints** or consolidate
10. **Standardize route parameter naming** across all modules (`[id]` convention)

---

## 8. Files Verified as Active

The following components and files were verified to be actively used:

### Components (Used)
- `AppFooter.astro` - Used in layouts
- `AuthModal.astro` - Used in auth pages
- `AuthModalLink.astro` - Used in multiple pages
- `Badge.astro` - Used in ProjectCard and ContestCard
- `Button.astro` - Used in many pages
- `ContestCard.astro` - Used in contests/index.astro
- `CountryModal.astro` - Used in create pages
- `EventCard.astro` - Used in events/index.astro
- `FormHelpersScript.astro` - Used in create/edit pages
- `Icon.astro` - Used extensively
- `LocationMap.astro` - Used in detail pages
- `ProjectCard.astro` - Used in projects/index.astro
- `ReportLink.astro` - Used in detail pages
- `ReportModal.astro` - Used in report pages
- `TextInput.astro` - Used in forms

### API Modules (Active)
- All contest, project, event, user, admin, message routes
- All commands and queries in CQRS pattern
- All middleware and plugins

---

*Generated: Cleanup Audit BB*
*Scope: Full monorepo analysis*
