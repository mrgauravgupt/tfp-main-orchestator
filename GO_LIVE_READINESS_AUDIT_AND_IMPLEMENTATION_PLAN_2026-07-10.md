# Go-Live Readiness Audit And Implementation Plan

Date: 2026-07-10

Scope:
- Root workspace: `/Users/hexa/Desktop/tfp-main-orchestator`
- Main app: `tfpphotographers`
- Mobile app: `tfpphotographers/apps/mobile`
- Collage service: `tfp-collage-service`
- Image moderation service: `tfp-image-moderation-service`

This document is an agent-ready handoff for fixing the current go-live blockers found in the read-only audit. It is intentionally actionable: each item includes the expected fix direction, files to inspect, and validation criteria.

## Current Readiness Verdict

Status: **Not go-live ready yet**

Primary reasons:
- The production Docker Compose path can fail before app startup.
- API readiness can stay unhealthy because worker heartbeat state is not shared.
- Public cache keys can serve the wrong localized content.
- Public API payloads can cache short-lived presigned media URLs too long.
- Production email can silently run as console-only.
- Moderation operator/report surfaces are too exposed.
- The moderation worker still writes dummy sentinel scores.
- Mobile is visually closer to web but not release-ready.
- Hexagonal boundaries exist in documentation, but enforcement and implementation are incomplete.

## Agent Working Rules

- Preserve existing unrelated dirty files. Do not revert user or parallel-agent changes.
- Work nested repos first, then update the root gitlink if nested commits are made.
- Stage only the files changed for the current fix.
- Do not replace the PostgreSQL-backed queue/outbox model with BullMQ/Redis by default. Improve terminal states, health checks, backlog visibility, and operator runbooks first.
- Do not introduce fake, mock, sample, fallback, or hardcoded runtime content.
- Mobile must use the existing `/api/v1` backend. Do not create a second backend.
- Use checked-in wrappers where applicable:
  - `tfpphotographers/scripts/manage-tfp.sh`
  - `tfpphotographers/scripts/manage-tfp-mobile.sh`
  - `tfpphotographers/scripts/start-app.sh`
  - `tfpphotographers/scripts/pnpm-node20.sh`

## Phase 0: Stabilize The Working Tree

Goal: make later fixes traceable and avoid mixing unrelated local artifacts into commits.

TODO:
- [ ] Inspect root status with `git status --short --branch`.
- [ ] Inspect nested app status with `git -C tfpphotographers status --short --branch`.
- [ ] Decide whether current untracked helper/audit files should remain untracked, be deleted by the owner, or be committed in a separate docs/helper commit.
- [ ] Confirm whether the modified `tfpphotographers/scripts/manage-tfp-mobile.sh` is intended. Do not overwrite it blindly.
- [ ] If fixing nested repos, commit nested repo changes before updating the root gitlink.

Acceptance criteria:
- Every change in the final commit set is intentional and scoped.
- Root gitlink points to the committed nested app revision if nested app changes are shipped.

## Phase 1: Production Startup And Readiness Blockers

### 1.1 Docker Runtime Missing Migration Script

Problem:
- `tfpphotographers/docker-compose.yml` runs `bash ./scripts/db/migrate.sh deploy`.
- `tfpphotographers/Dockerfile` runtime stage does not copy `scripts/`.
- Result: the migration container can fail before API/web can start.

Files:
- `tfpphotographers/Dockerfile`
- `tfpphotographers/docker-compose.yml`
- `tfpphotographers/scripts/db/migrate.sh`

TODO:
- [ ] Either copy the required `scripts/db` path into the runtime image or replace the compose migration command with a runtime-safe package script.
- [ ] Keep the runtime image minimal. Do not copy unrelated dev/test assets unless needed.
- [ ] Add a validation check that the runtime image can execute the migration command.

Acceptance criteria:
- `migrate` service can find and execute the migration entrypoint.
- `api` and `web` are not blocked by a missing file in the migration container.

Suggested validation:
```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
docker compose config
docker compose build migrate
docker compose run --rm migrate bash -lc 'test -x ./scripts/db/migrate.sh || test -f ./scripts/db/migrate.sh'
```

### 1.2 API Readiness Cannot See Worker Heartbeat

Problem:
- `/ready` requires worker readiness in production.
- Worker writes heartbeat to `/tmp/tfp-worker-heartbeat.json`.
- API and worker containers do not share that path.
- Result: API health can stay `503`, and web depends on healthy API.

Files:
- `tfpphotographers/apps/api/src/plugins/health.ts`
- `tfpphotographers/apps/api/src/worker.ts`
- `tfpphotographers/packages/config/src/env-core.ts`
- `tfpphotographers/docker-compose.yml`

TODO:
- [ ] Prefer a DB-backed worker heartbeat/readiness record or a shared volume dedicated to heartbeat files.
- [ ] Ensure API and worker use the same heartbeat source in production compose.
- [ ] Keep readiness strict enough to detect a dead worker.
- [ ] Add a test or smoke check for stale heartbeat behavior.

Acceptance criteria:
- `/ready` returns ready when DB is connected, worker heartbeat is fresh, and moderation queue is healthy.
- `/ready` returns not ready when worker heartbeat is stale or missing in production.

Suggested validation:
```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
bash ./scripts/pnpm-node20.sh test -- --runInBand apps/api/tests
docker compose up -d db migrate worker api
curl -f http://127.0.0.1:4000/ready
```

## Phase 2: Database Migration Safety

### 2.1 Launch Baseline Guard No Longer Protects Follow-Up Migrations

Problem:
- `launch-baseline-guard.mjs` only rejects mixed migration history when the repository contains exactly one migration.
- The repo now has:
  - `20260619000100_launch_baseline`
  - `20260702143000_referral_system`
  - `20260705093000_add_abuse_attribution`
- Result: a DB with old pre-squash finished migrations but no launch baseline can pass once follow-up migrations exist.

Files:
- `tfpphotographers/scripts/db/launch-baseline-guard.mjs`
- `tfpphotographers/scripts/db/launch-baseline-guard.test.mjs`
- `tfpphotographers/packages/database/prisma/migrations`

TODO:
- [ ] Change guard logic to fail whenever the repo contains the launch baseline and DB has old finished migrations but not the launch baseline.
- [ ] Allow fresh DBs.
- [ ] Allow DBs already resolved to `20260619000100_launch_baseline`.
- [ ] Add tests for baseline plus follow-up migrations.
- [ ] Update migration runbook text if needed.

Acceptance criteria:
- Mixed old-history DBs fail before `prisma migrate deploy`.
- Fresh and correctly resolved DBs still pass.

Suggested validation:
```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
node --test scripts/db/launch-baseline-guard.test.mjs
```

## Phase 3: Public Cache And Media Correctness

### 3.1 Localized Public Cache Pollution

Problem:
- Web SSR forwards request context via `x-language` and `x-region`.
- Public list cache keys use URL, `Accept-Language`, and `CF-IPCountry`.
- HTTP `Vary` also omits `X-Language` and `X-Region`.
- Result: wrong localized or regional payload can be served from cache.

Files:
- `tfpphotographers/apps/web/src/utils/api-fetch.ts`
- `tfpphotographers/apps/api/src/utils/public-list-cache.ts`
- `tfpphotographers/apps/api/src/server.ts`
- Detail route caches in:
  - `apps/api/src/modules/opportunity/opportunity-read-routes.ts`
  - `apps/api/src/modules/event/event-read-routes.ts`
  - `apps/api/src/modules/contest/contest-read-routes.ts`

TODO:
- [ ] Include resolved language and region in internal cache keys.
- [ ] Include `X-Language` and `X-Region` in `Vary` where those headers affect output.
- [ ] Apply the same rule to list and detail caches.
- [ ] Add regression tests for same URL with two locales/regions.

Acceptance criteria:
- Two requests to the same public URL with different language/region headers cannot share the same localized cache entry.

### 3.2 Presigned Media URLs Cached Longer Than They Live

Problem:
- Managed storage resolver defaults to 15-minute presigned URLs.
- Public API responses use longer shared-cache headers.
- Backblaze object info does not identify public objects.
- Result: cached JSON can contain expired image URLs.

Files:
- `tfpphotographers/apps/api/src/utils/storage-urls.ts`
- `tfpphotographers/packages/storage/src/adapters/BackblazeB2Adapter.ts`
- `tfpphotographers/apps/api/src/server.ts`

TODO:
- [ ] Prefer stable public/CDN URLs for public media payloads.
- [ ] If presigned URLs remain in public JSON, cap response cache TTL below presign TTL and remove stale-while-revalidate that can serve expired URLs.
- [ ] Add or derive `isPublic` metadata for public media paths where possible.
- [ ] Avoid repeated cold-path `HEAD` calls for common public media where metadata is known.

Acceptance criteria:
- Public list/detail JSON never serves expired media URLs from shared cache.
- Public media resolution does not add avoidable cold latency to hot list/detail endpoints.

## Phase 4: Production Email Readiness

Problem:
- `EMAIL_PROVIDER` defaults to `console`.
- Production validation only requires `RESEND_API_KEY` when provider is already `resend`.
- Result: password reset, verification, and notifications can appear healthy but not send real email.

Files:
- `tfpphotographers/docker-compose.yml`
- `tfpphotographers/packages/config/src/env-core.ts`
- `tfpphotographers/packages/config/src/config-sections.ts`
- `tfpphotographers/apps/api/src/utils/email-service.ts`

TODO:
- [ ] Reject `EMAIL_PROVIDER=console` in strict production.
- [ ] Keep console adapter allowed for local/dev/test.
- [ ] Ensure provider setup failures do not silently fall back to console in production.
- [ ] Add a production env doctor check.
- [ ] Add an email delivery smoke runbook.

Acceptance criteria:
- Production startup fails fast unless a real email provider is configured.
- Non-production console behavior remains available.

## Phase 5: Moderation And Operator Surface Hardening

### 5.1 Public Folder Moderation Reports And Status

Problem:
- `/folder-moderation` serves report files as static content.
- `/folder-ops/status` is always public.
- Raw report artifacts preserve provider envelopes for debugging.
- Result: operator/report data can be exposed publicly.

Files:
- `tfp-image-moderation-service/src/tfp_image_moderation_service/web.py`
- `tfp-image-moderation-service/scripts/vps/deploy-to-instance.sh`
- `tfpphotographers/scripts/vps/run-folder-moderation.sh`

TODO:
- [ ] Remove public static mounting of raw folder moderation report directories.
- [ ] Add authenticated/operator-only access for report downloads.
- [ ] Publish only redacted summaries publicly if a homepage/status widget is required.
- [ ] Ensure nginx/VPS aliases do not expose raw reports.
- [ ] Add a deployment check that raw report URLs are not public.

Acceptance criteria:
- Raw moderation report JSON is not publicly accessible.
- Operator status/report access requires the configured internal/operator auth.

### 5.2 Dummy Sentinel Scores In Moderation Worker

Problem:
- Worker writes a completed flagged sentinel with non-zero dummy `SPOOF: 0.01`.
- This is explicitly done to bypass `ALL_ZERO_RESPONSE` validation.
- Result: violates the no mock/fake/dummy data requirement and pollutes moderation data semantics.

Files:
- `tfp-image-moderation-service/src/tfp_image_moderation_service/moderation_worker.py`
- `tfpphotographers/apps/api/src/modules/moderation/application/process-image-moderation-job.ts`

TODO:
- [ ] Represent terminal provider failures with a real failure/error/manual-review state, not a fake completed score.
- [ ] Update validation so failure/manual-review states do not require non-zero category scores.
- [ ] Ensure main app consumer routes exhausted provider failures to queue review without needing fake scores.
- [ ] Add regression tests for all-zero provider payloads versus terminal provider failures.

Acceptance criteria:
- No runtime moderation path writes fake category scores.
- Provider failure remains fail-secure and visible to operators.

## Phase 6: Collage Worker Terminal State

Problem:
- Collage worker marks retryable failures as `PENDING`.
- Candidate acquisition only claims while attempts are below max.
- After max attempts, rows can remain `PENDING` but no longer be claimable.
- `markReady` only checks status and image array, not full business visibility state.

Files:
- `tfp-collage-service/src/services/collageWorker.ts`
- `tfp-collage-service/README.md`

TODO:
- [ ] Return `PENDING` only while attempts remain.
- [ ] Mark terminal exhausted jobs as `FAILED`.
- [ ] Add operator visibility for terminal collage failures.
- [ ] Recheck business state in `markReady`: approved, published, not deleted, and source images unchanged.
- [ ] Update README/runbook for terminal failure handling.

Acceptance criteria:
- Exhausted collage generation cannot remain invisible as unclaimable `PENDING`.
- A deleted/unpublished/unapproved opportunity cannot receive a newly published collage result.

## Phase 7: Mobile Release Readiness

### 7.1 Remove Local Content Invention

Problem:
- Mobile uses the real API adapter, but the mapper still invents product sections and fallback display values.
- Examples: `activity: []`, `messages: []`, `nearby` from first 4 opportunities, `closingSoon` from regex on label, `logo` as content image fallback.

Files:
- `tfpphotographers/apps/mobile/src/infrastructure/api/api-content-repository.ts`
- `tfpphotographers/apps/mobile/src/domain/entities.ts`
- `tfpphotographers/apps/mobile/src/presentation/components/cards.tsx`

TODO:
- [ ] Remove hardcoded empty activity/messages from home/search payloads or source them from API endpoints.
- [ ] Do not label sections as `nearby` or `closingSoon` unless the API provides that semantic grouping.
- [ ] Hide image fragments when API media is absent instead of using brand logo as content media.
- [ ] Remove local future-date draft creation defaults.
- [ ] Replace local English/date/currency formatting with API-provided display fields or shared i18n formatting.
- [ ] Fix opportunity status mapping so public approved/accepting items do not display as internal review states.

Acceptance criteria:
- Mobile runtime does not invent domain content.
- Missing API fields render as hidden/empty UI fragments, not fake values.

### 7.2 Fix Mobile Error And Empty States

Problem:
- Several screens check `isLoading || !data` before `isError`, making error states unreachable.
- This can show endless skeletons instead of actionable retry UI.

Files:
- `tfpphotographers/apps/mobile/src/presentation/screens/HomeScreen.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/OpportunityScreens.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/ContestScreens.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/EventScreens.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/InboxScreen.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/MessageScreens.tsx`

TODO:
- [ ] Check `isError` before treating missing data as loading.
- [ ] Distinguish loading, signed-out, empty, not-found, and failed states.
- [ ] Add unit/component coverage where practical.

Acceptance criteria:
- Network/API failures show a retry/error state instead of infinite skeletons.

### 7.3 Finish Native Upload-Gated Flows

Problem:
- Production tracker still marks native upload/presign/finalize flows as open.
- Opportunity creation, event gallery uploads, contest banners/resources, and contest submissions are not fully native-ready.

Files:
- `tfpphotographers/docs/mobile/mobile-app-implementation-todo.md`
- `tfpphotographers/apps/mobile/src/presentation/screens/CreateHubScreen.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/ContestScreens.tsx`
- `tfpphotographers/apps/mobile/src/presentation/screens/EventScreens.tsx`
- `tfpphotographers/apps/mobile/src/infrastructure/api/api-content-repository.ts`
- Upload routes under `tfpphotographers/apps/api/src/modules/upload`

TODO:
- [ ] Implement native presign -> upload -> finalize -> moderation linkage.
- [ ] Gate publish/submit actions until required media keys are finalized.
- [ ] Add upload retry/error UI.
- [ ] Add read-only smoke plus opt-in write smoke for upload flows.

Acceptance criteria:
- Mobile can complete core creation/submission media workflows against the existing API.

### 7.4 Match Web Visual Quality And Validate Screens

Problem:
- Mobile palette is closer to web, but current screenshots show wrong capture states and product UI gaps.
- Some screenshots are Android launcher/recents instead of the app.
- Current feed is dominated by brand-logo fallback media and internal labels.

Files:
- `tfpphotographers/apps/mobile/src/presentation/theme/tokens.ts`
- `tfpphotographers/apps/mobile/src/presentation/components`
- `tfpphotographers/apps/mobile/src/presentation/screens`
- `tfpphotographers/docs/mobile/mockups`
- `tfpphotographers/docs/mobile-screenshots/android`

TODO:
- [ ] Re-run simulator/device screenshots after route fixes.
- [ ] Compare every root tab and pushed route against the mobile mockups.
- [ ] Remove internal status labels from public cards where web does not show them.
- [ ] Ensure closed opportunities do not show an active apply CTA.
- [ ] Validate Create, Inbox, and Profile screenshots show the intended app screens.
- [ ] Complete dynamic type and accessibility pass.

Acceptance criteria:
- Current screenshot set accurately captures Home, Search, Create, Inbox, and Profile.
- Mobile feels like the web product in palette, typography, content hierarchy, and state semantics.

Suggested validation:
```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
bash ./scripts/manage-tfp-mobile.sh validate
bash ./scripts/manage-tfp-mobile.sh uat-smoke
bash ./scripts/manage-tfp-mobile.sh android:uat:local
bash ./scripts/manage-tfp-mobile.sh ios:uat:local
```

## Phase 8: Shared Contracts And Hexagonal Architecture

### 8.1 Enforce Documented Backend Boundaries

Problem:
- Architecture docs forbid direct database imports in routes, handlers, commands, and generic services.
- Current code still imports `database` from many command/service/query files.
- Boundary checker only catches a subset and omits mobile/sibling services.

Files:
- `tfpphotographers/docs/architecture/ARCHITECTURE_RULEBOOK.md`
- `tfpphotographers/scripts/architecture/enforce-boundaries.mjs`
- `tfpphotographers/apps/api/src/modules/**`

TODO:
- [ ] Decide the actual boundary standard: strict hexagonal or pragmatic query/command direct Prisma access.
- [ ] Update rulebook if the standard is intentionally pragmatic.
- [ ] If strict, move Prisma access behind repositories/read models.
- [ ] Expand `enforce-boundaries.mjs` to catch command/service database imports.
- [ ] Include `apps/mobile` and relevant sibling service source paths in architecture checks.
- [ ] Add hotspot caps for current large files or split them.

Acceptance criteria:
- Architecture docs, enforcement script, and implementation agree.
- CI fails on new forbidden imports.

### 8.2 Share Mobile Contracts Properly

Problem:
- Mobile has aliases for `@tfp/shared`, but current mobile source only imports shared i18n.
- DTO/API response mapping remains local in a large mobile repository mapper.

Files:
- `tfpphotographers/apps/mobile/tsconfig.json`
- `tfpphotographers/apps/mobile/src/infrastructure/api/api-content-repository.ts`
- `tfpphotographers/packages/shared/src`
- `tfpphotographers/packages/i18n/src/mobile.ts`

TODO:
- [ ] Identify Expo-safe shared DTOs/types to import from `packages/shared`.
- [ ] Move duplicated display/status rules into shared, Expo-safe modules where practical.
- [ ] Keep mobile platform concerns in mobile infrastructure/presentation.
- [ ] Split the 676-line mobile API mapper by domain.

Acceptance criteria:
- Mobile shares stable DTO/status/display contracts with web/API where safe.
- Mobile still builds under Expo/Metro.

## Phase 9: Web Performance And Fresh Go-Live Validation

Problem:
- Existing performance artifacts are stale and localhost-based.
- Latest stored admin sample had 3/3 poor pages.
- Broader stored run had 4 pages needing work.

Files:
- `tfpphotographers/scripts/qa/page-performance-report.mjs`
- `tfpphotographers/test-results/reports/page-performance`
- Large web/API hotspots from the audit:
  - `apps/api/src/modules/moderation/engine/unified-policy-engine.ts`
  - `apps/api/src/modules/translation/TranslationService.ts`
  - `apps/api/src/modules/moderation/application/process-image-moderation-job.ts`
  - `apps/web/src/pages/opportunities/[slug].astro`
  - `apps/api/src/modules/admin/admin-reporting.queries.ts`
  - `apps/mobile/src/infrastructure/api/api-content-repository.ts`

TODO:
- [ ] Fix correctness blockers before performance tuning.
- [ ] Restart FE/BE before browser or performance QA.
- [ ] Run the full page-performance sweep against UAT.
- [ ] Investigate detail-page SSR waterfalls and admin query TTFB.
- [ ] Reduce public media resolution latency.
- [ ] Keep latest full performance report as the latest pointer.

Suggested validation:
```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
TFP_ENV_TARGET=uat bash ./scripts/pnpm-node20.sh qa:page-performance
```

Acceptance criteria:
- No critical page is graded poor.
- Detail pages and admin pages have documented remediation or accepted risk.

## Final Validation Checklist

Run after all fixes are complete:

- [ ] `git status --short --branch` in root and every nested repo.
- [ ] `cd tfpphotographers && bash ./scripts/pnpm-node20.sh typecheck`
- [ ] `cd tfpphotographers && bash ./scripts/pnpm-node20.sh lint:architecture`
- [ ] `cd tfpphotographers && bash ./scripts/manage-tfp-mobile.sh validate`
- [ ] `cd tfpphotographers && bash ./scripts/manage-tfp-mobile.sh uat-smoke`
- [ ] `cd tfpphotographers && TFP_ENV_TARGET=uat bash ./scripts/pnpm-node20.sh qa:page-performance`
- [ ] `cd tfp-collage-service && bash ./scripts/pnpm-node.sh validate`
- [ ] `cd tfp-image-moderation-service && uv run pytest -q`
- [ ] Docker compose config/build smoke for production runtime path.
- [ ] Manual browser smoke for web public pages, auth, admin, locale switching, and mobile nav.
- [ ] Simulator/device smoke for mobile Home, Search, Create, Inbox, Profile, detail routes, auth, and upload flows.

## Definition Of Done

The workspace can be considered go-live ready only when:

- Production compose starts migrate, API, worker, and web successfully.
- API `/ready` reflects real DB, worker, and queue health.
- Migration guard blocks mixed old-history databases.
- Public cache keys and response headers are locale/region safe.
- Public media URLs do not expire inside cached JSON.
- Production email cannot silently use console mode.
- Raw moderation reports are not public.
- Moderation and collage terminal failures use real states, not dummy data.
- Mobile runtime uses only real API/domain data and has complete core upload flows.
- Mobile screenshots match actual app screens and visual direction.
- Architecture rules are either enforced or explicitly updated to match reality.
- Fresh validation commands pass or have documented, accepted non-code blockers.

