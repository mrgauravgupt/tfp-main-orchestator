# Read-Only Architecture and Code Quality Audit Index

## 1. Purpose and Scope
Comprehensive, evidence-based, read-only architectural and code quality audit across the TFP platform orchestrator and its constituent services and applications.
Objectives:
- Identify exact, near-duplicate, and semantically similar implementations.
- Identify repeated business rules, responsibilities, and behavioral drift.
- Identify dead, obsolete, unreachable, or unused code and clutter.
- Identify architectural boundary violations, layer crossings, and inappropriate coupling.
- Identify reusable abstractions vs unnecessary complexity and overengineering.
- Identify concrete maintainability, correctness, and testability problems.
- Identify good existing architecture that should be preserved.

## 2. Repository Identity and Baseline Revisions
- **Root Orchestrator**: `git rev-parse HEAD` = `659daaa69a718a8299f4c883a071fff1d23d6eda` (branch `main`).
  - Working tree: Dirty. Untracked review drafts (`docs/reviews/2026-10-13-full-codebase-architecture-audit.md`, `gemini_1.md`, `sonnet_1.md`), personal user files (`eKhata_Application_A104/`, `Gaurav_Gupta_Executive_Resume.pdf`), and modified submodule gitlink for `tfp-moderation-service`.
- **tfpphotographers**: `dd05a4c8a77851078af31afff20928d36eb72b63` (branch `main`, clean).
- **tfp-collage-service**: `15b48392e46df7bfcfbbb6c7f12adc3d1b0af279` (branch `main`, clean).
- **tfp-moderation-service**: `dd25f0659fda9fb5eee1df466c3d69626a412c88` (branch `main`, modified: `src/tfp_moderation_service/policies/policy_ai_inference_raw_envelope.yml`).
- **tfp-ai-interface**: `4e46c6f935e782f3172f7f25c12985e104d3b672` (branch `main`, clean).
- **tfp-inhouse-moderation**: `47a9e1e18d304472b9e82eb40a3aa7b6a6b641f9` (branch `main`, clean).

## 3. Discovered Scope and Reconciliation
- **Total Discovered Files**: 3,157 files across 6 git repositories.
- **Included Files**: 2,905 files (924,043 lines of code, configuration, tests, and documentation; 923,603 baseline prior to contest classification correction).
- **Excluded Files**: 252 files:
  - Binary assets: 233 files (PNG, JPG, WEBP, PDF, TTF, etc.)
  - Personal non-repository data: 14 files (`eKhata_Application_A104/*`)
  - Generated lockfiles: 2 files (`pnpm-lock.yaml`, `Podfile.lock`)
  - Local secret env files: 2 files (`.env.deploy.uat.local`, etc.)
  - Audit workspace artifacts: 1+ files (`gemini_readonly_audit/*`)
- **Uninstalled/Ignored Subtrees Excluded by Default**: `node_modules`, `.venv`, CocoaPods `Pods`, build outputs (`dist`, `build`, `.astro`), cache directories (`.cache`, `__pycache__`, `persistent-cache`, `models-cache`).

## 4. Architecture Overview: Intended vs Observed
- **Intended Architecture**:
  - Monorepo core (`tfpphotographers`) with clean separation between Web frontend (Astro SSR/static), Mobile client (Expo React Native), and Fastify API.
  - Asynchronous event bus via PostgreSQL transactional outbox (`event_outbox` with `FOR UPDATE SKIP LOCKED`).
  - Dedicated microservices for heavy compute: `tfp-collage-service` (Node.js), `tfp-moderation-service` (Python/FastAPI), `tfp-ai-interface` (Python/FastAPI), `tfp-inhouse-moderation` (Python).
  - Shared domain models, contracts, i18n dictionaries, and configuration packages (`packages/*`).
- **Observed Architecture**:
  - Strict event outbox architecture with dedicated workers (`apps/api/src/worker.ts`, `services/ui-review-worker`). Note that notification events (`NotificationService.ts`) bypass transaction contexts via root Prisma client.
  - High degree of modularity in API (`apps/api/src/modules/*`), but some direct cross-module coupling and schema drift across services.
  - Repository abstraction pattern in `packages/database` abandoned in practice; API queries Prisma directly via CQRS handlers.
  - Python moderation service exhibits extreme monolithic complexity (6,162-line `service.py` with 2,170-line `build()` method; 2,207-line `adapters.py`).

## 5. Audit Phase and Progress
- **Phase 1: Baseline and Scope**: COMPLETED. All 6 repositories fingerprinted; 3,157 files discovered and reconciled in `file_inventory.csv`.
- **Phase 2: Safe Mechanical Analysis**: COMPLETED. Full rolling-hash lexical window scanner and regex symbol scanner executed across all 2,905 included files without truncation. Discovered 96 duplicate candidate blocks, 51 multi-defined symbols, 132 large files (>500 lines), and 13 layer violations.
- **Phase 3: Module-by-Module Source Review**: COMPLETED. All 17 module records completed in `modules/`, matching exact inventory counts.
- **Phase 4: Duplication & Cross-Module Comparison**: COMPLETED. Reconciled 147 candidate rows (96 blocks, 51 symbols) into `candidate_dispositions.csv` with evidence-based rationales.
- **Phase 5: Finding Verification & Synthesis**: COMPLETED. Formulated 12 verified findings (2 High, 7 Medium, 3 Low) with exact file coordinates, outbox transaction qualifications, soft-delete matrix, and `[EXISTING]` vs `[PROPOSED]` test labels in `findings.jsonl` and `final_report.md`.

## 6. Links to Supporting Records
- File Inventory: [file_inventory.csv](file_inventory.csv)
- Module Map: [module_map.md](module_map.md)
- Checkpoints: [checkpoints.md](checkpoints.md)
- Tool Execution Log: [tool_runs.md](tool_runs.md)
- Mechanical Scan Results: [mechanical_scan_results.json](mechanical_scan_results.json)
- Symbol Duplications: [symbol_duplication.json](symbol_duplication.json)
- Candidate Dispositions Ledger: [candidate_dispositions.csv](candidate_dispositions.csv)
- Findings Stream: [findings.jsonl](findings.jsonl)
- Module Reviews: [modules/](modules/)
- Final Audit Report: [final_report.md](final_report.md)

## 7. Next Concrete Actions
1. Hand off final audit report and verified findings backlog to engineering leadership.
2. Formulate prioritized implementation milestones respecting database-independent domain goals and transaction safety.
