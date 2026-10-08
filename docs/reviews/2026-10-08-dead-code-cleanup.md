# Verified dead-code cleanup — 8 October 2026

Application cleanup is published at `5c732cb24059ece0778a7aa58169b2d628258a41`,
from clean baseline `50c0f1d2529acaf5d23021040d9682ec74f217d0`.
The change removes 431 lines and adds one tightened architecture-cap line across
19 files. It retires 22 private runtime functions/constants, their exclusive
types/maps/imports, five orphan unit cases, and three obsolete files.

## Removed code and its consumer proof

| Area | Removal | Evidence |
| --- | --- | --- |
| Admin reporting | `ListRelatedCreatorUploadEvidenceByEntities`, `matchesEntityUploadPath`, `getEntityImageLimit` | The query had no request/operator/test caller. Its two helpers served only that query and their own unit cases. Live evidence formatting remains intact. |
| Media mapping/lifecycle | `isPublicMediaEntityType`, `getEntityTypeForPrimaryImageSourceType`, `getMediaCollectionSegmentForEntity` | No callers except the retired helper chain. Exclusive sets/reverse maps removed; forward mapping remains used by approval and reconciliation. |
| Moderation | `createRejectedTextModerationIncidentReports`, three obsolete model-prose extraction helpers, `sexualizationLevelRank`, `TEXT_MODERATION_PROVIDER_KEYS` | No executable consumers. Active rejection evaluation, incident persistence, manual analysis providers and taxonomy normalization remain. |
| Workflow/translation | `isPendingAiWorkflowStatus`, `TRANSLATION_PROVIDER_KEYS` | No consumers. Active state derivation and configured provider factories remain. |
| Mobile | Five unused listing/activity hooks and `ProfileOnboardingScreen` | Listings use discovery search. The actual onboarding route exports `CreatorOnboardingScreen`. Repository contracts, active screens and route wrappers remain. |
| Web | `getCreateHubPolicies`/paired interface and `reportAnalyticsEvent` | No callers or dynamic/namespace consumers. Creation-policy caching, handled-error reporting and canonical GA4 bootstrap remain. |
| Obsolete files | `scripts/grant-db-permissions.sql`, `scripts/storage-smoke.ts`, `src/env.d.ts` | No imports, package commands, workflows, menus or advertised manual references. The SQL hardcoded `tfp`/`postgres`; the smoke script hardcoded Backblaze/public upload. Supported environment-selected DB/storage operators and Web's actual `App.Locals` declarations remain. |

The old storage smoke additionally checked existence after deletion and public
upload. Retiring that unadvertised ad-hoc script is not a claim that the supported
private storage doctor performs exactly the same operations.

The admin query shrank from 1,153 to 1,013 lines. Its architecture cap tightened
from 1,160 to 1,020, retaining the same seven-line allowance.

## Independent review and validation

GPT-6.1 SOL high handled scoped implementation and independent review. Import,
re-export, namespace, dynamic-import and type-import discovery covered 1,793
tracked source files. The reviewer compared 274 retained statements byte-for-byte
against baseline: active function bodies and assertions are unchanged. The only
retained-statement changes are removal of orphan import bindings. Package export
contracts and framework entrypoints were separately checked.

| Check | Result |
| --- | --- |
| API typing and scoped ESLint | Passed, including final helper-chain delta |
| Initial API consumer tests | Nine files, 54 passed before orphan-test removal |
| Final changed evidence-helper tests | Eleven active cases passed; exactly five retired-helper cases removed |
| Architecture fixtures and final boundary guard | 37 fixtures passed; final guard passed |
| Mobile typing and three profile/protected-route contracts | Passed; 16 cases |
| Web Astro check and creation-policy/telemetry tests | Zero errors/warnings; nine cases passed |
| Existing DB service-role grant contracts | Two passed; no database operation |
| Production compilation/build | API TypeScript emitted without errors; Web build exit 0 |
| Final diff/staged whitespace checks | Passed |

The 28 Astro hints concern names consumed in live early-return/redirect expressions;
inspection did not justify removing them. No new tests mirror deleted code. No
browser suite, service restart, database/storage mutation or full matrix ran:
this batch removes unreachable declarations without changing reachable UI behavior.

Representative executed commands, in `tfpphotographers`:

```bash
bash scripts/pnpm-node20.sh --filter api typecheck
bash scripts/pnpm-node20.sh --filter mobile typecheck
bash scripts/pnpm-node20.sh --filter web typecheck
bash scripts/pnpm-node20.sh lint:architecture
bash scripts/pnpm-node20.sh --filter api test -- tests/modules/admin/admin-reporting-evidence.helpers.test.ts
bash scripts/pnpm-node20.sh --filter mobile test -- src/presentation/screens/__tests__/ProfileScreen.contract.test.ts src/presentation/screens/__tests__/ParityStates.contract.test.ts src/presentation/hooks/__tests__/protected-route-gate.contract.test.ts
bash scripts/pnpm-node20.sh --filter web test -- tests/utils/creation-policy-invalidation.test.ts tests/utils/telemetry.test.ts
bash scripts/run-node20.sh --test scripts/db/service-role-grants.contract.test.mjs
bash scripts/pnpm-node20.sh --filter api build
bash scripts/pnpm-node20.sh --filter web build
git diff --check
```

Exact API commands, removal inventories, combined patch, build logs and independent
review are preserved under application
`test-results/reports/diagnostic-review/dead-code-cleanup-20261008/`.

## Retained items and limits

- Public package exports, routes, migrations, recovery scripts, registered assets,
  configuration entrypoints and supported manual tools were retained. API `ajv`
  looked unused locally but is required by the parent's AI-outbox contract test.
- Responsive image variants have constructed-URL consumers. Source fonts support
  reproducible generation. Three old hero PNGs have no internal references, but
  their direct public URL consumers cannot be ruled out; they were not deleted.
- No safe runtime-module removal was confirmed in the active AI/collage services
  or root operator scripts. Unrelated moderation-service changes, the executive
  resume and all historical QA/failure evidence remain untouched.

This is a bounded consumer audit, not a guarantee that every selector, externally
linked static asset, optional manual tool or future configuration branch is dead-code
free. No dependency manifest or lockfile changed. No UAT deployment was performed;
the existing app release remains `20261007T110654Z-50c0f1d2`, worker/AI unchanged.
This cleanup does not grant production approval or an exact-revision six-child
certificate. Historical evidence remains separate under the user's no-full-rerun
policy; existing external production-access gates remain outside this cleanup.
