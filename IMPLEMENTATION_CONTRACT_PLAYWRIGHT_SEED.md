# TFP Implementation Contract: Playwright-Like-Human Data Seeding

## 1) Objective
Establish a simple, robust, repeatable pipeline that:
1. Hard-resets the DB.
2. Seeds only core accounts.
3. Creates all business data via Playwright browser flows (human-like), not direct DB inserts.
4. Produces deterministic data used by E2E, moderation tests, and UI screenshot QA.

## 2) Baseline Decision
1. Roll back codebase to commit `96fe5c5`.
2. Rebuild only the minimum required seed/test architecture from that baseline.
3. Keep a single DB across `development/test/qa` for now (env-target aware, same URL).

## 3) Non-Negotiable Rules
1. No storage bypass or local fallback flags in normal seeding/test flow.
2. No remote URL uploads in runtime flows.
3. All upload assets must be local workspace files.
4. Browser-based creation must follow real product paths (auth, form input, upload, publish).
5. Reset must always run before full seed-all runs.

## 4) Scope of Data Creation
Must support browser creation for:
1. Projects
2. Events
3. Contests
4. Contest submissions
5. User profile updates
6. Portfolio uploads

All canonical content must come from SSOT catalog, including project entries like `Fitness Campaign`.

## 5) SSOT Structure
Create and maintain:
1. `tests/create-data/ssot/content-catalog.json`
2. `tests/create-data/ssot/accounts.json`
3. `tests/create-data/assets/**` (local curated files only)
4. `tests/create-data/services/browser-crud-service.ts` (reusable Playwright actions)

## 6) Command Contracts
Required commands:
1. `pnpm qa:test:reset`
2. `pnpm qa:create-data:seed:baseline`
3. `pnpm qa:create-data:seed:moderation`
4. `pnpm qa:create-data:seed:all`

Behavior:
1. `seed:all` = `qa:test:reset` -> `seed:baseline` -> `seed:moderation`.
2. Commands must print resolved env target, DB URL, DB name, base URLs before destructive actions.

## 7) Environment and Runtime Contract
1. Keep single env resolver for all scripts.
2. Add explicit app lifecycle commands:
   - `app:stop`
   - `app:restart:dev`
   - `app:restart:test`
3. Ensure restart order for verification passes:
   - stop stale processes
   - restart API + Web
   - confirm health
   - execute seed/tests.

## 8) Verification Gates (Must Pass)
After seed runs:
1. Data verification
   - Expected titles exist (including `Fitness Campaign`).
   - Expected counts per entity type.
2. UI verification
   - Listing pages show seeded entities.
   - Images are visible on cards/details.
3. Test verification
   - `pnpm typecheck`
   - `pnpm lint`
   - `pnpm build`
   - required E2E/moderation suites.

## 9) Acceptance Criteria
1. Fresh reset leaves DB with core accounts only.
2. `seed:all` creates deterministic SSOT content via Playwright browser flows.
3. Project/Event/Contest listing pages show seeded records and visible images.
4. Moderation scenarios are reproducible from local curated assets.
5. Scripts are simple, documented, and free of bypass/fallback overengineering.

## 10) Execution Plan After Rollback
Phase A: Rollback and clean baseline
1. Move repo to `96fe5c5` branch baseline.
2. Remove leftover generated artifacts and stale temp outputs.

Phase B: Reintroduce minimal architecture
1. Add `tests/create-data` SSOT + assets + services.
2. Add minimal command scripts for reset and seed profiles.
3. Add `app:restart:test` and enforce health checks.

Phase C: Seed flow implementation
1. Implement browser CRUD creation primitives.
2. Implement baseline profile from SSOT.
3. Implement moderation profile from local curated assets.

Phase D: Validation and stabilization
1. Run reset -> seed-all repeatedly until deterministic.
2. Verify UI pages and image visibility.
3. Fix defects, rerun, and lock behavior.

Phase E: Documentation
1. Update `tests/README.md` with exact run commands and expected outcomes.
2. Document seeded accounts in `tests/seed/accounts.md`.
3. Record troubleshooting playbook for stale process and DB mismatch detection.

## 11) Out-of-Scope for This Pass
1. Multi-DB split between dev/test/qa.
2. Over-abstraction of seed services.
3. Non-essential refactors unrelated to seed reliability.

## 12) Change Control
1. Keep commits small and scoped.
2. Verify each phase before proceeding.
3. If a change increases complexity without reliability gain, revert and simplify.
