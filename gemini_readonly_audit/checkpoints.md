# Audit Checkpoints and Progress Ledger

## Checkpoint 1: Baseline Established, Inventory Reconciled, Workspace Initialized
- **Timestamp**: 2026-10-22T04:06:00Z
- **Completed Work**:
  - Fingerprinted all 6 Git repositories and recorded dirty status / git commits.
  - Initialized dedicated `gemini_readonly_audit/` workspace with `audit_index.md`, `module_map.md`, `tool_runs.md`, `duplicate_groups.md`.
  - Discovered actual scope: 3,157 files total, 2,905 included, 252 excluded.
  - Reconciled categories, line counts (923,603 included lines), and exclusion justifications in `file_inventory.csv`.

---

## Checkpoint 2: Mechanical Analysis, Module Reviews & Finding Verification Completed
- **Timestamp**: 2026-10-22T04:18:00Z
- **Completed Work**:
  - Executed safe mechanical analysis (`mechanical_scan.py`, `symbol_duplicates.py`) across all 2,905 included files.
  - Cataloged 5 distinct Duplicate Groups in `duplicate_groups.md`.
  - Confirmed and verified preliminary architectural findings.

---

## Checkpoint 3: Second-Pass Verification, Candidate Reconciliation & Formal Findings Finalized
- **Timestamp**: 2026-10-22T05:35:00Z
- **Completed Work**:
  - Reconciled 97 block duplicate candidate windows and 44 symbol duplicates in `candidate_dispositions.csv`.
  - Generated dedicated module reviews for `packages/moderation`, `packages/email`, and `tfp-inhouse-moderation`, completing the formal 17-module review manifest.
  - Explicitly verified the 12 concrete repository classes in `packages/database/src/repositories/` (9 uncalled, 3 called), decoupling repository retirement from the target Ports & Adapters persistence architecture.
  - Formulated formal findings AUD-0011 (Raw policy AST evaluator duplication / DUP-004) and AUD-0012 (Direct shared-database outbox and entity table coupling in `tfp-ai-interface`).
  - Clarified PostgreSQL `FOR UPDATE SKIP LOCKED` row locking concurrency and verified `softDeleteExtension` coverage limits.
  - Updated `findings.jsonl` with 12 confirmed findings.

---

## Checkpoint 4: Verification Review Corrections, Defect Repairs & Definitive Report Finalized
- **Timestamp**: 2026-10-22T11:45:00Z
- **Completed Work**:
  - **Repaired Test Classifier Bug**: Corrected directory-boundary matching in `generate_inventory.py`; restored 65 production contest files (11,131 lines) from `TEST`/`TEST_FIXTURE` to `SOURCE_CODE`/`CONFIGURATION`.
  - **Repaired Scanner Path Exclusion**: Restored 13 production contest files to duplicate block and symbol scanner coverage.
  - **Eliminated Blanket Status Assignment**: Rewrote inventory status derivation to assign `COMPLETED`, `PARTIAL`, `UNSUPPORTED`, and `NOT_APPLICABLE` strictly from recorded tool runs, file extensions, and module review coverage.
  - **Reconciled True Source Coordinates & Line Counts**:
    - **AUD-0006**: Replaced fabricated names with exact source files: `tfp-moderation-service/src/tfp_moderation_service/service.py` (6,162 lines; class `ImageDerivedSignalBuilder` lines 234–4506; method `build` lines 251–2420 [2,170 lines]) and `adapters.py` (2,207 lines, 20 classes including 11 vision adapters). Clarified evaluation scripts (`scripts/eval_192_moderation_service.py` vs in-house `compare_golden_results.py`).
    - **AUD-0004**: Corrected paths to `packages/database/src/adapters/rate-limiter.adapter.ts` (0 callers) and `packages/database/src/adapters/cache.adapter.ts` (imported at `apps/api/src/server.ts:522`).
    - **AUD-0005**: Corrected path to `packages/i18n/src/index.ts` (lines 1–125 load 95 catalogs totaling 23.95 MB at startup; `en_US` master, `en_IN` default).
    - **AUD-0010**: Corrected `apps/api/src/server.ts` to exactly 790 lines.
    - **AUD-0012**: Corrected database driver to `psycopg` 3.x and `psycopg_pool.ConnectionPool` (not `asyncpg`).
  - **Outbox Concurrency & Transactional Exception Grounded**:
    - Traced `tfpphotographers/apps/api/src/modules/notifications/NotificationService.ts` calling `this.eventBus.emit(...)`, which binds to the root Prisma client in `runtime-services.ts`, emitting events outside active transaction contexts.
    - Qualified that PostgreSQL `FOR UPDATE SKIP LOCKED` guarantees row-level lock exclusion across worker instances, while outbox processing guarantees **at-least-once** delivery, requiring idempotent consumers.
  - **Prisma `softDeleteExtension` Operation Matrix**:
    - Formulated the exact operation-by-operation matrix: `$allOperations` intercepts 8 root operations (`findUnique`, `findUniqueOrThrow`, `findFirst`, `findFirstOrThrow`, `findMany`, `count`, `aggregate`, `groupBy`), but **bypasses** nested relation joins (`include:`, `select:`), raw SQL (`$queryRaw`, `$executeRaw`), and mutations (`delete`, `deleteMany`).
  - **Repository Factory Coupling & Decoupled Domain Architecture**:
    - Documented that retiring unused repositories requires updating `createRepositories` and `IRepositories` in `packages/database/src/repositories/index.ts` and `runtimeServices.repositories` bound to `app.decorate('repositories')`.
    - Maintained clear separation between removing dead repository classes and establishing database-independent Ports & Adapters persistence boundaries.
  - **Reconciled Candidate Dispositions Ledger**:
    - Reconciled all 96 duplicate candidate blocks and 51 multi-defined exported symbols (147 rows total) in `candidate_dispositions.csv` with evidence-based rationales (e.g. single-file TypeScript function overloads) and transparent uncertainty flags.
  - **Reconciled All 17 Module Records**:
    - Fully aligned all 17 records in `gemini_readonly_audit/modules/` with `file_inventory.csv` included counts (exactly 2,905 files, 924,043 lines).
  - **Labeled All Test Paths**:
    - Verified that all verification tests across findings and report are explicitly tagged as `[EXISTING]` or `[PROPOSED]`.
- **Final Coverage Status**:
  - Total Discovered: 3,157 files
  - Included Files: 2,905 files (924,043 lines across 17 module reviews; 923,603 baseline prior to contest reclassification)
  - Excluded Files: 252 files (233 binaries, 14 personal data, 2 generated lockfiles, 2 local env secrets, audit workspace)
  - Scanner Coverage: 2,103 source files (supported extensions); 802 files outside scanner coverage fully reconciled by extension
  - Verified Findings: 12 (2 High, 7 Medium, 3 Low)
  - Candidate Ledger Rows: 147 (96 duplicate blocks, 51 symbols)
- **Current Task**:
  - Deliver final verified audit report and summary.
