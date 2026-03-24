# gpt_plan.md — Comprehensive Cleanup & Refactor Execution Blueprint

## Summary
- Target plan document path (for execution phase): `/Users/hexa/Desktop/tfp-latest/tfp-workspace/gpt_plan.md`.
- Objective: apply only **validated** findings from existing reviews, remove clutter, enforce architecture consistency, and keep the application behavior stable via strict checkpoints.
- Delivery style: incremental, phase-gated, test-first progression.
- Constraint model: pre-release project, no legacy URL/API guarantee required, DB reset is allowed.

## Absolute Reference Documents (Read First)
- `/Users/hexa/Desktop/tfp-latest/gpt.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/gpt.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/gpt_DRY.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/gtp_arc.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/final_review.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/gpt_clutter.md`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/AGENTS.md`

## Validity Lock (Do This Before Any Refactor)
- Keep in active backlog: monolithic routes/pages/styles, upload-flow duplication, repeated validation/error helpers, `any`/`@ts-nocheck` debt, CSP `unsafe-inline`, missing CSRF and login lockout, i18n global mutable locale risk, localhost API fallback, token/style inconsistency, search overfetch/in-memory ranking.
- Mark stale but directionally valid: file-size/occurrence counts from older docs.
- Mark incorrect and exclude from implementation backlog:
  - “Web typecheck is currently failing”
  - “Soft-delete middleware is missing”
  - “Local filesystem upload serving is active”
  - “`.old.astro` files are not compiled”
  - “Project/profile structured data missing”
  - “ListingCard is a large monolith”
  - “Web has no lint script”

## Execution Rules for the Implementing Agent
- Work only inside `/Users/hexa/Desktop/tfp-latest/tfp-workspace`.
- Use one branch per phase (`codex/cleanup-phase-<n>`).
- After each phase: run mandatory checkpoint suite; do not proceed on failure.
- For large changes: split into sub-PRs, each with explicit rollback point.
- Do not mix schema-level changes with UI architecture changes in the same PR.

## Phased Implementation Plan

### Phase 0 — Baseline, Triage File, and Guardrails
- Create canonical triage file documenting every finding as `valid`, `stale`, `incorrect`, or `defer`.
- Capture baseline metrics: route file sizes, page sizes, style sizes, `@ts-nocheck` count, `any` count.
- Freeze quality gates and failure policy.
- Checkpoint: lint/build/tests all green before starting cleanup work.

### Phase 1 — Clutter and Dead-Code Removal
- Remove admin `.old` pages and related obsolete style chains.
- Remove orphaned/empty directories and wrapper-only style indirections.
- Remove runtime `console.*` noise from application paths (exclude seed/test tooling logs).
- Checkpoint: route manifest no longer includes legacy `.old` page entries; app behavior unchanged in active routes.

### Phase 2 — Security and Correctness Hardening
- Eliminate CSP `unsafe-inline` by moving inline scripts/styles to proper assets/modules.
- Add CSRF protection for state-changing form/API paths.
- Add auth lockout/throttle policy for repeated failed login attempts.
- Replace localhost API fallback with config-driven base resolution.
- Checkpoint: login/register/report/create/edit flows pass; security-focused tests pass.

### Phase 3 — Backend DRY and Layering Cleanup
- Extract direct-upload route factory (presign/complete parity across domains).
- Extract shared query schema builders, normalization helpers, and not-found/visibility policies.
- Move event side-effect business logic out of server bootstrap into a notifications module.
- Thin admin routes by extracting enrichment/orchestration into services/queries.
- Checkpoint: route LOC materially reduced; response contracts unchanged for retained endpoints.

### Phase 4 — Frontend Decomposition and Type Debt Reduction
- Split admin page into loader/view-model/section components/client module.
- Split BaseLayout responsibilities (SEO/head, nav/header, user menu, notifications, footer orchestration).
- Remove `@ts-nocheck` from active pages and replace with typed DOM/event handling.
- Consolidate repeated card actions, image fallback behavior, and page-local format helpers.
- Checkpoint: `@ts-nocheck` removed from active pages; web typecheck remains clean.

### Phase 5 — i18n and SSOT Contract Enforcement
- Replace mutable global i18n state with request-scoped translator creation.
- Unify shared contracts (pagination, list item shapes, report reasons, API envelopes) in one shared package boundary.
- Remove duplicated web-local contract types and consume shared definitions directly.
- Checkpoint: no locale bleed risk; no duplicated contract definitions for active APIs.

### Phase 6 — Schema Normalization (DB Reset Path)
- Convert critical JSON-heavy fields to typed schema models/columns where justified.
- Preserve denormalized counters where current behavior is correct and tested.
- Add missing composite indexes from validated backlog.
- Use reset-based rollout (no migration-compat burden) and reseed.
- Checkpoint: clean DB reset + seed + full tests green.

### Phase 7 — CSS/Systematic Style Cleanup
- Split oversized stylesheets into focused partials by domain.
- Enforce token usage policy (no ad-hoc hex/spacing literals when token exists).
- Add global reduced-motion support in shared animation layer.
- Checkpoint: style hotspot metrics improved and policy violations reduced to agreed threshold.

### Phase 8 — Performance and Scalability
- Move search ranking/filtering toward backend/database-side logic.
- Reduce layout hot-path SSR data fetching costs.
- Add perf checkpoints (response times and payload size thresholds for key pages/routes).
- Checkpoint: measurable improvement on search and authenticated layout render path.

## Important Public API / Interface / Type Changes
- Remove legacy admin `.old` web routes.
- Standardize profile identity handling to ID-based behavior and remove email-based fallback semantics.
- Introduce/expand shared cross-app contracts for list/search/report/pagination responses.
- Normalize schema contracts for location/budget/entry-fees (reset-based rollout).

## Mandatory Checkpoints and Test Commands
- Core checkpoint commands after every phase:
  - `cd /Users/hexa/Desktop/tfp-latest/tfp-workspace && pnpm lint`
  - `cd /Users/hexa/Desktop/tfp-latest/tfp-workspace && pnpm build`
  - `cd /Users/hexa/Desktop/tfp-latest/tfp-workspace && pnpm --filter api test`
- DB reset checkpoint (Phase 6):
  - `cd /Users/hexa/Desktop/tfp-latest/tfp-workspace && pnpm --filter database exec prisma db push --accept-data-loss`
  - `cd /Users/hexa/Desktop/tfp-latest/tfp-workspace && pnpm --filter database prisma:seed`
- Required scenario validation (manual or automated smoke):
  - Auth: login/register/logout/reset-password
  - Create/edit flows: project/event/contest/profile
  - Admin moderation/report lifecycle
  - Public listing/detail/search/profile routes
  - Upload presign/complete flows across all entity types
- Promotion rule: no phase merges with failing gates or unresolved P0/P1 regressions.

## Critical Implementation Targets (Primary Code Areas)
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/server.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/admin/admin.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/contest/contest.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/project/project.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/event/event.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/user/user.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/search/search.routes.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/layouts/BaseLayout.astro`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/pages/admin/index.astro`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/pages/profile/[email].astro`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/pages/admin-unified.scss`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/layouts/base-layout.scss`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/packages/i18n/src/index.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/packages/shared/src/contracts.ts`
- `/Users/hexa/Desktop/tfp-latest/tfp-workspace/packages/database/prisma/schema.prisma`

## Assumptions and Defaults
- This roadmap is for pre-release cleanup, with no external backward-compat obligation.
- Database reset and reseed are acceptable.
- Workspace-first scope is enforced; root-folder archival/cleanup can be done as a separate follow-up.
- Success definition: all checkpoint suites pass, validated findings are resolved, and no active user flow regresses.
