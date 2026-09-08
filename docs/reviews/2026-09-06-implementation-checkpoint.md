# Implementation checkpoint — 6 September 2026

> Historical review snapshot. For the current source-verified backlog, use [the 8 September audit and implementation plan](2026-09-08-deep-architecture-audit-and-implementation-plan.md). Revalidate these older findings before changing code.

> **Superseded — 7 September:** The scheduled run fired at 03:15:02 IST and
> continued this batch. Read [remediation and verification](./2026-09-07-remediation-and-verification.md)
> for current status. The historical checkpoint below must not be treated as a
> request to repeat completed work.
>
> **Safety correction:** the original `coverage:all` run below did reset the
> configured TEST database. Earlier no-reset descriptions apply only to the
> browser steps and later direct test commands, not that aggregate invocation.
> The current report records the side effect and unverified recovery status.

## Resume here

This is a checkpoint, **not a completion report**. The user requested a careful,
minimal remediation and second review of tfpphotographers API/web,
tfp-ai-interface, and tfp-collage-service, then asked to resume the same Codex
chat at **7 September 2026, 03:15 Asia/Kolkata**. Review the conversation and
current diffs first; preserve completed work and any subsequent user changes.

Chat: `01a0775b-e119-76a1-a734-404963a1c26b`.
Workspace: `/Users/hexa/Desktop/tfp-main-orchestator`.

## Completed before this implementation batch

- Review documents: `2026-09-06-enterprise-application-improvement-review.md`
  and `2026-09-06-dry-modularity-and-cleanup-audit.md` in this directory.
- Six consumer-traced obsolete scripts removed; app commit `8885f713` and
  parent commit `a53fb42` were already published. Do not repeat that cleanup.

## Implemented locally, not yet committed

| Area | Changes awaiting final verification |
| --- | --- |
| API route fixtures | Contest/opportunity test servers now decorate the required narrow `mediaDelivery` fake; consumer arguments asserted. |
| Web outage states | Opportunities, contests, and events distinguish failed requests from legitimate empty results, using a shared translated `ListingUnavailableState.astro` with filter-preserving Retry. |
| Collage leases | Serial worker claims just in time, stops claiming during shutdown, guards completion ownership/expiry, avoids duplicate completion after manifest publication, and terminates exhausted reclaimed attempts. |
| AI persistence | Real PostgreSQL adapter tests and CI database service; existing attempt number fences heartbeat/completion/failure against stale workers. Exhausted reclaimed attempts terminate without another inference request. |
| Search boundaries | Transport parsing stays in `search.routes.ts`; schema and application orchestration moved to `search-input.ts` and `search.query.ts`, with focused behavior tests. |
| DRY | Three public detail routes share `createPublicDetailCache`, preserving visibility checks, auth bypass, locale/role keys, and fallback rules. |
| Local cleanup | Admin navigation constants moved into existing `runtime-navigation.js`; collage test page says Configurable canvas / Centered crop. Existing architecture caps tightened with modest headroom. |
| Schema SSOT | Root `scripts/contracts/worker-test-schema.mjs` derives both workers' integration fixture DDL from app Prisma migrations and checks drift in CI. |

Changed files can be enumerated with `git status --short` separately in the
root and each nested repository. Root `tfp-moderation-service` gitlink was
already modified before this task and **must not be staged or reverted**.
No production database migration or deployment was performed.

## Verification completed in this batch

- API full suite: **180 files, 993 tests passed**.
- Web full suite: **94 files, 529 tests passed**.
- API targeted media/cache/search checks passed, including 44 focused tests.
- Architecture boundaries, ESLint (zero warnings), API typecheck passed.
- Web typecheck: 391 files, zero errors/warnings, 26 hints.
- App full build passed: `/tmp/tfp-review-build.log`.
- AI: **74 tests passed with real PostgreSQL enabled**, Ruff passed, `uv build`
  produced sdist and wheel.
- Collage: **44 tests passed with real PostgreSQL enabled**, including test
  compilation. Run its normal production build before final delivery.
- Root worker schema drift check passed; outbox validator's three tests passed.
- Real PostgreSQL tests used isolated random schemas, dropped only their own
  schemas, and did not reset or seed application databases.

### Current failing gate: combined branch coverage

`bash ./scripts/pnpm-node20.sh coverage:all` in tfpphotographers ran all API/web
tests successfully but failed the aggregate branch threshold:

- API branches: 8,168 / 13,657 (59.80%).
- Web branches: 1,408 / 3,554 (39.61%).
- Combined: 9,576 / 17,211 (**55.64%**, required **58%**).
- Combined statements, functions, and lines passed.
- Log: `/tmp/tfp-review-coverage.log`.
- Summaries: `apps/api/coverage/coverage-summary.json`,
  `apps/web/coverage/coverage-summary.json`, and root `coverage/`.
- Aggregator: `scripts/testing/merge-coverage-summary.mjs` currently sums the
  two totals. No measurement defect has been demonstrated.

Next investigate meaningful missing cases, add behavior coverage, and rerun.
Do not lower thresholds, exclude real code, or add assertion-free tests to
make this pass. Notable uncovered web logic: admin-dashboard (374 branches),
admin-formatters (238), qa-dashboard (186), profile-page (137), report (102),
OAuth (75), structured-data (75), notifications-loader (71). API hotspots
include unified-policy-engine, notification event handlers, TranslationService,
image processing, and authentication. These are investigation leads, not
confirmed defects. Approximately 407 additional covered branches are needed
if the denominator remains unchanged.

## Browser/runtime checkpoint

- FE and BE were restarted in local **TEST**, with no seed/reset. API health
  returned 200 at port 4000; web served port 3000. Recheck/restart both before
  a fresh UI verification pass, using checked-in scripts and safe exact PIDs.
- Environment used `BACKEND_URL=http://localhost:4000`,
  `APP_BASE_URL=http://localhost:3000`,
  `PUBLIC_API_BASE_URL=http://localhost:4000/api/v1`, and Sentry disabled.
  TEST environment was loaded using `scripts/with-test-env.sh`.
- Logs: `/tmp/tfp-review-api.log`, `/tmp/tfp-review-web.log`.
- Canonical page URLs are `/en-in/opportunities`, `/en-in/contests`, and
  `/en-in/events`, not `/en/in/...`.
- Agent-browser was unavailable; the installed Playwright skill fallback ran
  through the repo's Node wrapper (global Node is unsuitable).
- Temporary harness: `/tmp/playwright-test-tfp-review.js`; command from app:
  `bash ./scripts/run-node20.sh /Users/hexa/.agents/skills/playwright/run.js /tmp/playwright-test-tfp-review.js`.
- Six healthy empty-state checks passed across those three routes at 1440px
  and 390px, with no page exceptions or horizontal overflow.
- Evidence: `/tmp/tfp-review-browser/healthy.json` and six screenshots.
  **Screenshots were captured but have not yet been visually inspected.**
- Still required: actual API outage and Retry recovery at both sizes; inspect
  screenshots; add durable regression coverage for outage/empty/success;
  verify admin navigation after constant extraction; verify collage test-page
  copy in a running server without enabling work against shared job state.
- The temporary harness supports `REVIEW_PHASE=outage` and checks the alert,
  absence of false empty state, and Retry URL query preservation. Restore the
  API after outage testing. Do not mistake automated assertions for completed
  visual inspection.

## Final review and delivery still required

1. Resolve the coverage gate with relevant behavior tests or an evidenced
   measurement correction; inspect any failures rather than weakening checks.
2. Complete browser/runtime verification above. Temporary evidence may vanish
   after reboot; re-create only missing/invalidated evidence as needed.
3. Review final diffs and consumers: search response/privacy/cache behavior;
   detail cache authorization ordering; worker stale-ownership and transaction
   paths; migration-derived fixture accuracy; admin navigation imports.
4. Update both review documents with implemented fixes, evidence, and honest
   remaining limitations. Do not claim enterprise-grade certification from
   passing unit tests alone.
5. Follow current AGENTS.md and due-diligence instructions, then selectively
   commit/push validated nested changes first and root files/gitlinks second.
   Leave unrelated changes untouched. No commits have been made for this batch.

Keep the existing PostgreSQL outbox design. Avoid broad framework rewrites,
speculative abstractions, secret audits, or deletion without consumer evidence.
Do not deploy, reset/seed databases, or run paid inference as an incidental
verification step. If current permissions or external dependencies prevent a
required check, report the exact limitation rather than claiming success.

## Scheduling limitation

The built-in scheduler can target this chat, but this checkpoint cannot make
account access transferable. Local scheduled work needs the computer on and
the app running. Automatic same-chat execution after signing out or switching
accounts is not verified or guaranteed. The file preserves a manual recovery
point if another authorized session needs to continue this workspace.
