# TFP remediation and second-review results

> Historical review snapshot. For the current source-verified backlog, use [the 8 September audit and implementation plan](2026-09-08-deep-architecture-audit-and-implementation-plan.md). Revalidate these older findings before changing code.

**Date:** 7 September 2026 · **Scope:** tfpphotographers API/web, AI interface,
and collage service. This updates the two 6 September review documents; their
original findings and line references remain a historical baseline.

## Outcome

The seven confirmed findings have been addressed with focused changes. The
second review also reproduced and corrected admin evidence-display and ordering
bugs, plus a locale-losing Retry link caught by browser testing. No new backend,
queue system, dependency-injection framework, or broad folder rewrite was added.

| Finding | Implemented change | Evidence |
| --- | --- | --- |
| Five failing API fixture tests | Decorate the narrow `mediaDelivery` dependency actually consumed by contest/opportunity routes; assert rendition arguments | Final full API suite: 1,005 tests pass |
| Listings show empty during outage | Shared localized unavailable state on failed fetch; keep successful empty and populated states separate; Retry explicitly uses request language/region and retains query parameters | All three routes checked at 1440px and 390px with real API available/unavailable; same-session Retry recovery |
| Serial collage batch leases | Claim one job immediately before execution; stop claiming on shutdown; reject lost/expired completion; avoid completing a publication twice; terminate exhausted crash recovery | 44 tests pass, including real PostgreSQL ownership/reclaim/drain cases |
| AI persistence integration gap | Real PostgreSQL adapter suite in isolated schemas and CI; attempt-fenced mutations prevent stale workers overwriting a newer claim; exhausted claims do not invoke inference again | 74 tests pass with PostgreSQL enabled; Ruff and package build pass |
| Search route orchestration | Move query schema and location/media/response orchestration into `search-input.ts` and `search.query.ts`; keep HTTP parsing/cache/metric recording in route | Existing route tests plus four focused application-query tests; full API/typecheck pass |
| Stale architecture caps | Tighten existing ceilings to current size plus modest headroom, without increasing existing caps | Architecture boundary check passes |
| Local admin/collage cleanup | Move admin navigation configuration into the existing navigation module; correct configurable-canvas/centered-crop copy | Admin tab navigation and actual collage test page checked in a browser |
| Detail-cache duplication | Reuse `createPublicDetailCache` across three detail routes, after current visibility checks | Parameterized cache tests preserve scope/locale keys, authenticated bypass, fallback bypass, and 60-second TTL |

## Additional defects found by regression testing

1. **Unknown image evidence falsely appeared approved.** In non-audit contexts,
   an image with no matching evidence now shows the existing “Under review”
   label. Explicit approved audit behavior and image-scoped evidence remain.
2. **Unsupported category scores became zero.** The admin normalizer preserves
   `null`/blank/invalid scores as unavailable. The chip renderer ignores them;
   a genuine numerical zero remains valid.
3. **SSR A–Z sorting was reversed.** Report entity/reason/reporter and user
   name/role/state ordering now agrees with the A–Z UI labels and client logic.
4. **Retry lost the locale after middleware rewrote the route.** The component
   now passes `Astro.locals.language` and `region` explicitly to the existing
   URL helper. An ambient-context-only fix was rejected by the live regression.
5. **Combined coverage was below its gate.** Meaningful admin normalization,
   evidence identity/scope, approval history, filter, sort, timing, queue, and
   route-localization tests raised combined branch coverage from 55.64% to
   **58.99%**, above the unchanged 58% requirement. No exclusions or thresholds
   were weakened.
6. **Hosted collage CI failed before tests.** `setup-node@v5` automatically
   detected pnpm and tried to cache it before Corepack installed it. Disable
   that automatic cache; retain install, PostgreSQL tests, build, and audit.
   This follows the [action's documented v5 behavior](https://github.com/actions/setup-node#breaking-changes-in-v5).
7. **Hosted production dependency audit found eight unapproved advisories.**
   Update Fastify within v5 (lockfile resolves 5.12.3), existing fast-uri and
   xmldom overrides to 3.1.6 and 0.8.15, and narrowly override fflate 0.7.4 to
   patched 0.7.5. The two existing, expiring Metro-only image-size exceptions
   are unchanged. No new advisory exception is added. Upstream references:
   [Fastify fixes](https://github.com/fastify/fastify/releases/tag/v5.12.1),
   [fast-uri fixes](https://github.com/fastify/fast-uri/releases/tag/v3.1.6),
   [xmldom advisory](https://github.com/xmldom/xmldom/security/advisories/GHSA-6gmq-8vp8-gcm6),
   [fflate advisory](https://github.com/advisories/GHSA-px8p-9vwx-vf98).
8. **Fastify's patched proxy contract rejected numeric trust.** A build rerun
   caught the removed numeric option; a type cast would have hidden a real
   runtime change. Compile a reviewed IP/CIDR allowlist once at startup and
   combine it with the existing hop bound. New `TRUST_PROXY_CIDRS` defaults to
   exact IPv4/IPv6 loopback for the current same-host OCI topology. Tests inject
   trusted and untrusted socket peers to verify IP, host, and protocol handling.
   Non-loopback deployments must explicitly configure their reviewed proxies.
   See the [upstream proxy-trust advisory](https://github.com/fastify/fastify/security/advisories/GHSA-3m5p-2c4r-xxw2).
9. **Real OG image rendering failed behind a mocked endpoint test.** All three
   cards failed when the renderer parsed the bundled variable font, then on
   unsupported `inline-flex` styles. Use static 600/700 instances generated
   from the same Sora source, retain its license and generation instructions,
   and use supported flex layouts. A real-render suite checks PNG signatures
   and token-defined dimensions for opportunity, contest, and profile cards.
   Standalone test JSX compilation is explicit, and utility TSX files now join
   the coverage scope. No runtime font download or generation service is added.

## Architecture / affected-surface assessment

- **Directly affected:** the three listing pages, admin display helpers and
  navigation module, API search/query and detail-cache consumers, both worker
  adapters, proxy trust configuration, OG font/rendering assets, dependency
  versions, tests, schema fixtures, CI, and test documentation.
- **Indirectly affected:** web/mobile search and detail clients consume the
  unchanged API contracts; app result-event handlers consume unchanged worker
  event envelopes. Existing tests and source trace were checked for both.
- **Persistence and events:** PostgreSQL remains the queue authority. No app
  schema migration or wire-event change is required. Worker tests derive their
  queue-table schema from the owning Prisma migrations; root CI checks drift.
- **Shared ownership:** existing i18n labels, routing, cache locale keys, media
  capabilities, and renderer ports were reused. Domain-specific parameters and
  cross-language service boundaries were not forced into generic abstractions.
- **Cleanup:** the six previously verified dead scripts remain deleted in app
  commit `8885f713`. No additional production files met the deletion threshold.
  Test artifacts/dependencies are not misclassified as dead application code.
- **Reviewed and unchanged:** native mobile source, database schema, provider
  prompt/policy, business authorization, deployed environment values, deployment
  topology, and the unrelated historical moderation gitlink.
- **Rollback:** changes are ordinary code/test commits with unchanged schemas
  and events; revert the relevant nested commit and repin the parent if needed.
  Do not roll back to a different queue or introduce dual event publication.

## Verification commands and results

From `tfpphotographers` (repository wrappers use the pinned Node version):

```bash
bash ./scripts/with-test-env.sh bash ./scripts/pnpm-node20.sh --filter api test:coverage
bash ./scripts/pnpm-node20.sh --filter web test:coverage
bash ./scripts/run-node20.sh ./scripts/testing/merge-coverage-summary.mjs
bash ./scripts/pnpm-node20.sh --filter api typecheck
bash ./scripts/pnpm-node20.sh --filter web typecheck
bash ./scripts/pnpm-node20.sh typecheck
bash ./scripts/pnpm-node20.sh lint
bash ./scripts/pnpm-node20.sh lint:architecture
bash ./scripts/pnpm-node20.sh lint:eslint
bash ./scripts/pnpm-node20.sh --filter i18n test
bash ./scripts/pnpm-node20.sh build
bash ./scripts/pnpm-node20.sh security:audit:prod
```

- API: **181 files / 1,005 tests** pass, including 12 new proxy-trust cases.
- Web: **96 files / 637 tests** pass, including three real OG-render cases.
- i18n: **4 files / 128 tests** pass.
- Final combined coverage: statements **71.16%**, branches **59.06%**, functions
  **76.86%**, lines **74.15%**; all aggregate thresholds pass. The earlier
  58.99% result preceded proxy and OG-render regression coverage.
- API/web typechecks, architecture and zero-warning ESLint pass. Astro reports
  zero errors/warnings and 26 existing hints.
- The direct coverage commands above avoid the convenience `coverage:all`
  command's database-reset step. **Correction to earlier status:** the initial
  `coverage:all` invocation did reset the configured TEST database and replay
  its migrations; `/tmp/tfp-review-coverage.log` records “Database reset
  successful.” That unintended destructive side effect should have been
  identified before execution. Subsequent verification used the direct
  no-reset commands. No backup/restore has been verified, and no unapproved
  recovery operation was attempted.
- After dependency updates, mobile's **62 files / 250 domain tests** and
  typecheck pass; config's **37 tests** pass. This is not native-device proof.
- One API coverage rerun hit a transient localhost PostgreSQL connection
  error in account deletion. A read-only readiness check succeeded; the
  isolated regression and subsequent full 1,005-test run both passed without
  changing that test or resetting the database.

AI: `TEST_DATABASE_URL=<local test PostgreSQL URL> uv run pytest -q`,
`uv run ruff check .`, `uv build` — all pass (74 tests).

Collage: `TEST_DATABASE_URL=<local test PostgreSQL URL> bash ./scripts/pnpm-node.sh validate`,
`bash ./scripts/pnpm-node.sh build` — all pass (44 tests, zero skips).

Root: `node scripts/contracts/worker-test-schema.mjs` and
`node --test scripts/contracts/validate-ai-outbox-contract.test.mjs` pass.

## Browser evidence and limits

The FE and BE were restarted before the fresh TEST pass. The three public
listing routes were checked at **1440×1000** and **390×844**. An unavailable
backend produced an alert rather than false empty results, with correct Retry
URLs, no page exceptions, and no horizontal document overflow. After restoring
the actual API, Retry recovered in the same browser session.
After the dependency/proxy changes, both services were restarted and all six
healthy listing checks passed again. Real renderer PNGs for all three OG card
types were generated and visually inspected at 1200×630; they are recorded as
`og-opportunity.png`, `og-contest.png`, and `og-profile.png` in the evidence folder.

The TEST database had no relevant listing items. Populated listings and admin
navigation therefore used a separate **read-only synthetic API transport**;
no user/content records were seeded. This proved rendering of all three
populated pages and admin tab interaction, but is **not** proof of real admin
login, MFA, authorization, or production data behavior. The actual collage HTTP
test page was checked separately with its database worker disabled. Screenshots
were visually inspected, not merely captured.

Local evidence is under `/tmp/tfp-review-browser`; scripts are
`/tmp/playwright-test-tfp-review.js` and `/tmp/playwright-test-tfp-final-review.js`.
Build/test logs use `/tmp/tfp-review-*.log`. These are disposable local artifacts,
not committed user media or a permanent UAT evidence archive.

## Remaining release-certification boundaries

- No UAT deployment, paid provider call, secret audit, physical-device test,
  or full authenticated journey was performed. The initial TEST database
  reset is disclosed above; later verification did not repeat it.
- The collage batch-wait lease bug is fixed. One unusually slow active job can
  still exceed its configured lease and retry safely; production lease sizing
  and sustained backlog/latency require load evidence. Renewal is not added
  without that need.
- Real PostgreSQL fixtures cover queue adapters, not every domain table and
  foreign key or every external-storage failure. Existing renderer/unit tests
  complement, but do not replace, end-to-end publication and erasure proof.
- Passing local gates is not a claim that every hosted CI/security/deployment
  check has completed, or that the entire application is defect-free.
- Remote refs were fetched and matched local HEAD before commits. Dirty trees
  were preserved rather than stashed/rebased; only task-owned files are staged.

## Published changes and hosted checks

- App implementation: `4109857d`; dependency/proxy and real OG-render fixes:
  `a2ed25d9`. Both published to `main`.
  [Security Validation passed](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/34085243845):
  Gitleaks and the production dependency audit succeeded. CodeQL and dependency
  review were skipped by their existing conditions; this is not SAST proof.
- AI: `3c659c6`; [CI passed](https://github.com/mrgauravgupt/tfp-ai-interface/actions/runs/34062751395).
- Collage: `20c3017` plus CI bootstrap fix `b7f330c`;
  [CI passed, including PostgreSQL tests, build, and audit](https://github.com/mrgauravgupt/tfp-collage-service/actions/runs/34068259425).
- [Strict browser CI at the final app revision](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/34085243878)
  stops at the explicit prerequisite check because `TFP_CI_OPENROUTER_API_KEY`
  is not configured. Its real-provider requirement is preserved, not skipped
  or replaced with mocked success. Configuring a credential and authorizing
  provider-backed execution is an external release gate.

## Scheduled continuation

The one-time heartbeat fired in this same chat at **03:15:02 IST on 7 September
2026**. It resumed from the checkpoint without repeating completed cleanup.
That proves this scheduled run fired; it does not prove cross-account or
signed-out scheduling support.
