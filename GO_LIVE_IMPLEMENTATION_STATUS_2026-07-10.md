# Go-Live Implementation Status

Updated: 2026-07-10  
Isolated worktree: `/Users/hexa/Desktop/tfp-main-orchestator-go-live-impl`  
Branch in root and all nested repositories: `codex/go-live-readiness-20260710`

This is the continuation source of truth for `GO_LIVE_READINESS_AUDIT_AND_IMPLEMENTATION_PLAN_2026-07-10.md`. Changes were made only in the isolated worktree so parallel agents working in the original checkout are not disturbed.

## Completed In This Worktree

### Production startup, readiness, migrations, cache, and email

- Runtime image now includes `scripts/db`, so the compose migration job can execute its checked-in migration launcher.
- API and worker share a dedicated heartbeat volume; API mounts it read-only and stale/missing/stopping heartbeat tests remain strict.
- Launch-baseline guard protects repositories that contain the baseline plus later migrations, while allowing fresh and already-resolved databases.
- Public list and detail cache keys include language and region inputs, and `Vary` includes the explicit mobile headers.
- Public JSON cache lifetime is capped below presigned media lifetime and no longer serves stale expired URLs.
- Strict production rejects `EMAIL_PROVIDER=console`; compose defaults to `resend`; deployment docs include an operator-owned delivery smoke.

### Moderation and operator security

- Removed the fake non-zero moderation sentinel score.
- Terminal provider failures remain real `FAILED` worker results and are consumed as fail-secure manual-review records with zero category scores.
- Removed public static mounting and nginx aliasing of raw folder-moderation reports.
- Folder operator status, UI, and report downloads require the internal API key; deploy smoke fails if the legacy public report URL is exposed.
- Removed the public homepage report widget and its now-unused polling/rendering JavaScript.

### Collage terminal state

- Retryable failures return to `PENDING` only while attempts remain.
- Exhausted failures become terminal `FAILED` records with their error preserved.
- `READY` writes recheck approval, publication, deletion state, processing state, and unchanged source images.
- README now contains the terminal-failure operator query and explicit reset guidance.

### Mobile runtime correctness and parity

- Removed synthetic `nearby`, `closingSoon`, activity, and message fields from the home/search contract.
- Removed unused future-dated draft creation and all brand-logo content-media fallbacks; cards hide absent/unresolved content media and reserve the logo for app chrome.
- Removed internal public-opportunity status badges and gate the apply form using actual API workflow/deadline state.
- Error checks now precede loading/empty checks across home, search, opportunity, event, contest, inbox, and message routes.
- Inbox/message routes distinguish signed-out, loading, empty, not-found, and failed states; message API failures are no longer swallowed into empty arrays.
- Implemented native file selection, SHA-256 checksums, presign, binary transfer, complete/moderation, retry/error UI, and entity-submit gating for:
  - opportunity moodboards and opportunity creation;
  - event covers and event gallery submissions;
  - contest banners, PDF/image resources, and contest entries.
- Added explicit Expo-safe `shared/contracts` package export; mobile now reuses shared location, budget, and event-fee contracts.
- Split display mapping out of the large API repository mapper and added a shrink-only hotspot cap.
- Aligned Expo SDK 52 dependencies, including Sentry, image picker, document picker, and crypto; Expo doctor passes all checks.
- Development mobile runtime now matches the documented UAT API default.

### Architecture enforcement

- Architecture scan now includes `apps/mobile/src`.
- New command/service imports of runtime database APIs fail the check.
- Mobile imports of `database` or `@prisma/client` fail the check.
- Existing command/service database imports are an explicit shrink-only baseline named `DIRECT_DATABASE_DEBT`; remove entries whenever a repository adapter replaces one.

## Validation Completed

- `bash ./scripts/pnpm-node20.sh typecheck` — passed for all workspace packages/apps, including Astro diagnostics with zero errors/warnings.
- `bash ./scripts/pnpm-node20.sh lint:architecture` — passed.
- `bash ./scripts/manage-tfp-mobile.sh validate` — 49 tests passed, TypeScript passed, Expo doctor 18/18 passed.
- Targeted API cache, health, and moderation suites — 27 tests passed.
- Baseline, runtime-image, and production environment-doctor Node tests — 8 passed.
- Config tests — 8 passed.
- `uv run pytest -q` in image moderation — 100 passed; Ruff passed for the changed worker and regression test.
- `bash ./scripts/pnpm-node.sh validate` in collage service — TypeScript plus 26 tests passed.
- `git diff --check` and deploy-script shell syntax checks — passed.
- `docker compose config --quiet` — passed with validation-only values for the two required interpolated variables.

## External Validation Not Completed

- Docker runtime image build could not run because the local Docker daemon is not running. Compose rendering passed before the daemon check failed.
- Mobile read-only UAT smoke could not resolve `uat.tfpphotographers.com` (`ENOTFOUND`) from this machine.
- The UAT performance command resolved its environment but the report runner targeted `http://localhost:3000`; no FE was running, so every navigation returned `ERR_CONNECTION_REFUSED`. Do not use that failed run as performance evidence.
- Simulator/device screenshots, dynamic-type inspection, and manual web UI comparison require a running FE/BE and simulator/device pass. No code claim in this document treats those visual checks as completed.

## Remaining Deliberate Debt

1. Move each path in `DIRECT_DATABASE_DEBT` behind a repository/read-model adapter and delete the baseline entry in the same change. The guard prevents new debt now.
2. Run Docker build/start with Docker available and verify the migration job plus shared heartbeat volume inside the actual runtime image.
3. Restore/confirm a resolvable UAT host, rerun mobile read-only smoke, then run opt-in write smoke with an operator-owned account.
4. Restart FE and BE, run the page-performance sweep against the intended host, and tune only from the fresh report.
5. Capture all five mobile root tabs and pushed create/detail/upload routes on iOS and Android; complete dynamic type and screen-reader checks.
6. Durable offline upload queueing remains open. Current upload failures are actionable and retryable but are not persisted across app termination.

## Commit State

Nested repositories are committed and pushed on `codex/go-live-readiness-20260710`:

- `tfpphotographers`: `43d3bd15` — `fix(go-live): harden runtime and mobile release paths`
- `tfp-image-moderation-service`: `08c4929` — `fix(worker): secure moderation terminal failures`
- `tfp-collage-service`: `cd5029c` — `fix(worker): persist terminal collage failures`

The root commit records these three gitlinks plus this continuation document.
