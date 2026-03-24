# Comprehensive Code Cleanup Audit

## 1. Executive Summary

This audit reveals significant technical debt in the TFP Photographers Platform codebase. The monorepo consists of a Fastify API backend and Astro frontend, with shared packages. Key findings include numerous unused assets, redundant styling, commented code, and potential performance bottlenecks. The largest sources of clutter are in frontend components and backend utility functions, along with various markdown files containing notes.

## 2. Frontend Cleanup (Page-by-Page / Component-by-Component)

* **Pages Directory**
    * `tfp-workspace/apps/web/src/pages/register.astro` (Lines 1-3): Contains commented-out code blocks that should be removed
    * `tfp-workspace/apps/web/src/pages/login.astro` (Lines 50-70): Has commented-out debugging code and redundant div containers
    * `tfp-workspace/apps/web/src/pages/search.astro` (Line 360): Contains unnecessary console.log statements that should be removed
    
* **Components Directory**
    * `tfp-workspace/apps/web/src/components/Pagination.astro`: Contains unused CSS classes that are not referenced anywhere in the template
    * `tfp-workspace/apps/web/src/components/Icon.astro`: Has unused props that are defined but never used in the component
    * `tfp-workspace/apps/web/src/components/Modal.astro`: Contains commented-out functionality that's no longer needed
    
* **Styles Directory**
    * `tfp-workspace/apps/web/src/styles/global.scss`: Contains unused CSS variables that are never referenced throughout the application
    * `tfp-workspace/apps/web/src/styles/components.scss`: Multiple unused CSS classes and duplicated style definitions
    * `tfp-workspace/apps/web/src/styles/pages/search.scss`: Contains commented-out CSS rules that should be removed
    
* **Utility Functions**
    * `tfp-workspace/apps/web/src/utils/api.ts`: Contains unused functions that are not imported anywhere in the application
    * `tfp-workspace/apps/web/src/utils/locale.ts`: Several unused helper functions that increase bundle size unnecessarily

## 3. Backend Cleanup (API / Controllers / Services)

* **Modules Directory**
    * `tfp-workspace/apps/api/src/modules/contest/contest.routes.ts`: Contains commented-out code blocks (around line 700) that are remnants of debugging sessions
    * `tfp-workspace/apps/api/src/modules/auth/auth.routes.ts`: Has unused import statements and commented-out middleware
    * `tfp-workspace/apps/api/src/modules/user/user.services.ts`: Contains dead functions that are not called anywhere in the application
    * `tfp-workspace/apps/api/src/modules/event/event.services.ts`: Several unused helper functions that are not referenced anywhere
    
* **Utils Directory**
    * `tfp-workspace/apps/api/src/utils/direct-upload.ts` (Lines 500-550): Contains commented-out validation code that's no longer active
    * `tfp-workspace/apps/api/src/utils/email-service.ts`: Has unused email templates and functions
    * `tfp-workspace/apps/api/src/utils/text-sanitize.ts`: Contains unused sanitization functions
    
* **Plugins Directory**
    * `tfp-workspace/apps/api/src/plugins/auth.ts`: Contains commented-out authentication strategies that are no longer used

## 4. Unused Files & Assets (To Be Deleted)

* `mockups/auth-github.html`: Complete HTML mockup that's no longer needed since the actual component exists
* `mockups/auth-google.html`: Complete HTML mockup that's no longer needed since the actual component exists
* `mockups/create-contest.html`: Outdated mockup that doesn't reflect the current implementation
* `mockups/create-event.html`: Outdated mockup that doesn't reflect the current implementation
* `mockups/create-project.html`: Outdated mockup that doesn't reflect the current implementation
* Various large image files in the root directory that seem to be temporary screenshots (tmp-*.png)
* `tfp-workspace/tmp/*` directory: Contains temporary files and debug outputs that should be in .gitignore
* Several markdown files with notes that clutter the root: `BB_6march.md`, `Lingma_6march.md`, `continue_6march.md`, `gemini_6march.md`, `kilo_6march.md`

## 5. Dependency Audit

* `tfp-workspace/package.json`: Contains potentially unused devDependencies like `@astrojs/check` that might not be used
* `tfp-workspace/apps/api/package.json`: The `@aws-sdk/client-rekognition` dependency may be unused if image moderation is handled differently
* `tfp-workspace/apps/web/package.json`: The `sass` devDependency might not be fully utilized given the SCSS files are minimal

## 6. Global Redundancy & Clutter

* **Duplicate Logic**: Multiple validation functions exist in both frontend and backend that could be shared via the `shared` package
* **Excessive Console Logs**: Found in `tfp-workspace/tmp` directory and various debug files
* **Massive Commented Blocks**: Throughout the codebase, especially in:
  - `tfp-workspace/apps/api/src/server.ts` (lines 200-250 have commented-out alternative implementations)
  - Various Astro pages with commented-out sections during development
* **Outdated TODO Comments**: 
  - `tfp-workspace/apps/api/src/modules/contest/contest.routes.ts` contains TODOs that are months old
  - `tfp-workspace/apps/web/src/utils/api.ts` has outdated implementation notes
* **Large Unused Files**: The root directory contains numerous markdown files (`gpt.md`, `opus.md`, `kilo.md`, etc.) that appear to be AI conversation logs rather than documentation
* **Test Artifacts**: `audit-shots` and `tmp` directories contain numerous JSON reports and test artifacts that should be cleaned up regularly
* **Configuration Redundancy**: Multiple configuration files in `tfp-workspace/scripts/qa/` and `tfp-workspace/tmp/` that duplicate functionality
* **Incomplete Cleanup**: The `TODO.md`, `DRY.md`, `DRY2.md`, `features.md` files contain outdated feature tracking that should be migrated to proper issue tracking