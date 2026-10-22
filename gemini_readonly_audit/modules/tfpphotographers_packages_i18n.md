# Module Review: `tfpphotographers/packages/i18n`

## 1. Module Overview
- **Path**: `tfpphotographers/packages/i18n`
- **Purpose**: Translation dictionary catalog resolution, runtime message interpolation, brand placeholder replacement, and locale negotiation.
- **File Count**: 119 files (95 language catalog JSON files, 5 regional override JSON files, TypeScript loader source, and tests).
- **Line Count**: ~24 MB of JSON catalogs + ~600 lines of loader code.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Resolution Functions: `normalizeLocaleCode`, `resolveBrandPlaceholders`, `getCatalogValue`, `mergeCatalogs` (`src/index.ts`, `src/catalog-core.ts`).
- Context Storage: `localeContext` (AsyncLocalStorage for request-scoped locale tracking).
- Types: `LocaleStrings`, `LocaleKey`.

## 3. Architecture & Internal Responsibilities
- **Master & Language Merge**: Merges master English catalog with specific language catalog and region-specific overrides.
- **Request-Scoped Context**: Utilizes Node.js `AsyncLocalStorage` to propagate the active request locale across async operations without passing it down every function parameter.

## 4. Observed Strengths
- **Catalog Sanitization**: `sanitizeLocalePayload` validates loaded JSON structures against master catalog keys to prevent arbitrary object injection.
- **Comprehensive Coverage**: Extensive translation support spanning 95 locales.

## 5. Identified Deficiencies & Findings
- **Severe Startup I/O and Memory Inefficiency (AUD-0005)**:
  - `src/index.ts:86-112`: `loadLanguageCatalogs()` executes at top-level module evaluation time.
  - It runs `readdirSync` and reads all 95 JSON files (24 MB total) synchronously via `readFileSync`, parsing every single file with `JSON.parse` into global heap memory.
  - This synchronous file I/O blocks the Node.js event loop during process startup in Fastify API, Astro SSR, background workers, and unit test suites.
  - The vast majority of incoming requests only require a single locale (e.g., `en`), making the eager in-memory retention of 94 other languages completely wasteful.
- **Fragile Relative Path Resolution**:
  - `src/index.ts:38-45`: `resolveCatalogDirectoryCandidates()` uses heuristic fallback paths relative to `process.cwd()` (`..`, `../..`) which can break if the process is launched from an unexpected directory.

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
