# Module Review: Orchestrator Root, Contracts, and Scripts

## 1. Module Overview
- **Path**: Orchestrator Root (`contracts/`, `scripts/`, `qa/`, `.github/`, docs, root files) and cross-cutting repository test harnesses
- **Purpose**: Workspace coordinator managing deployment workflows, multi-service QA integration harnesses, shared cross-service contracts, environment automation, and cross-cutting test suites.
- **File Count**: 644 files (248,756 lines) assigned to this orchestrator and workspace-level review record, including orchestrator root, contracts, docs, QA scripts (`scripts/qa/`, 155 files), e2e harnesses (`tests/e2e/`, 153 files), contract tests (`tests/contracts/`, 21 files), and root scripts.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Shared Contracts: `contracts/` (cross-service schemas).
- Scripts: Database supervision, launch dashboard, environment setup, Node 20 wrapper.
- QA: Cross-surface integration suites under `qa/` and `scripts/qa/`.

## 3. Architecture & Internal Responsibilities
- **Submodule Coordination**: Orchestrates git submodules across `tfpphotographers`, `tfp-collage-service`, `tfp-moderation-service`, `tfp-ai-interface`, and `tfp-inhouse-moderation`.
- **Environment Parity**: Enforces Node.js version consistency (`scripts/ensure-node20.sh`, `scripts/run-node20.sh`) across tools.

## 4. Observed Strengths
- **Strict Pre-flight Checks**: Scripts validate required environment variables and process states before launching test suites or services.
- **Automated Service Supervision**: `scripts/supervise-dev-service.sh` ensures reliable local development stack orchestration.

## 5. Identified Deficiencies & Findings
- **Boundary-Crossing QA & Script Imports (AUD-0009)**:
  - Several QA scripts in `scripts/qa/` and `scripts/db/` import directly from compiled backend artifacts (`../../apps/api/dist/modules/legal/restore-evidence.js`) or internal API source modules (`../../apps/api/src/worker.js`, `../../../apps/api/src/modules/auth/totp`).
  - These scripts bypass the public package boundaries and couple QA tools tightly to internal file paths and build output directories.

## 6. Review Status
- **Tool Scan**: COMPLETED (lexical rolling window and regex symbol scanner executed across all 644 files).
- **AI Review**: REVIEWED (structural review of orchestrator contracts, deployment runbooks, and QA test harnesses).
- **Cross-Module Comparison**: COMPLETED (evaluated against API distribution paths and mobile/web harnesses).
