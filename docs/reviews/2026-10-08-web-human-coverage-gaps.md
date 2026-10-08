# Web human-flow corrections — 8 October 2026

Application publication: `3757394fa5e77985fdd6231c43cdeb37e2e6cf5a`.
This is scoped implementation and validation, not a new full release certificate.

## Confirmed findings and minimal corrections

| Priority | Executable evidence / cause | Correction |
| --- | --- | --- |
| P2 | `notifications.astro` put the preference PATCH and page GETs in one failure path. API invalid-zone rejection became a Web 503 and hid the form/feed. | Classify only HTTP 400 + `VALIDATION_ERROR`, show the existing translated validation alert, and load unchanged saved preferences/feed. Other service failures remain errors. |
| P2 | `createContest` uploaded the same image as banner and reference; CON020 derived filename expectation from the control being tested. | Optional reference fixture, distinct image content and independently expected filename. Actual decoded bytes discriminate a wrong banner/rendition. |
| P2 | SEC002 checked only the deleting browser, with no positive public baseline or independent existing session. | Supervised independent session plus guest profile/search baselines; after visible deletion, assert revoked editor, profile 404 and exact card removal. No authentication/cache clearing between baselines and removal. |
| P2 | No human-flow block exercised expired recent authentication and recovery. | SEC007 naturally waits beyond the unchanged shared 600-second security policy, proves rejection/unchanged settings, signs in freshly through the existing permitted bridge, and deletes once visibly. |
| External proof gap | Quiet-hour preferences and mocked/console email transport do not prove recipient delivery. No isolated inbox receipt integration exists. | Explicit blocked `WEB-E2E-NOTIF-006`, with real recipient-bound delivery requirements; no invented pass or provider framework. |

## Affected surfaces and invariants

Web SSR adapter/page/error styles and three human specs are directly affected.
The API recent-auth guard reads a shared constant with the same 600-second value;
its route, JWT policy, status contract and account-deletion implementation are
unchanged. Other `createContest` callers retain their original fixture default.
Mobile, database schema, workers, queues, providers and authorization semantics
are reviewed and unaffected. No migration, DB reset, hidden retry, clock/token
mutation, weakened security assertion or test-only product branch is introduced.

Independent GPT-6.1 SOL high source review caught and corrected an acquisition
cleanup leak and an unjustified requirement that fuzzy search be entirely empty.
All returned contexts close within protected cleanup. Exact creator absence is
required while unrelated search matches remain allowed. Original test failures
remain primary; every secondary close failure is not claimed attached.

## Completed fast validation

- Web focused Vitest: 12/12, including canonical validation privacy/service-error
  separation and decoded reference identity/wrong-banner discriminators.
- API: 8/8 across the actual account-deletion PostgreSQL suite (5) and recent-auth
  guard through Fastify HTTP injection (3). Boundary expectations independently
  protect the normative 600/601-second policy. Compiled package exports 600.
- Shared/API/Web production builds; API/Web typing and Playwright typing passed.
- Scoped ESLint and `git diff --check` passed.
- Strict-human policy and 88/88 guard fixtures passed; five other safe runner,
  report, context and verifier architecture files passed 109/109.
- Official fresh-cache target discovery selected exactly four Chromium blocks
  in three specs. Discovery is not runtime proof.

Commands use the repository Node/pnpm wrappers. Relevant test commands:

```bash
bash scripts/pnpm-node20.sh --filter web exec vitest run tests/utils/human-download-proof.test.ts tests/features/notification-preferences-validation.test.ts tests/features/account-admin-api.test.ts
bash scripts/with-target-env.sh test bash scripts/pnpm-node20.sh --filter api exec vitest run tests/utils/recent-auth.test.ts tests/modules/user/user.account-deletion.test.ts
bash scripts/run-node20.sh node_modules/typescript/bin/tsc -p tsconfig.playwright.json --noEmit
```

## Runtime phase

Exact UAT release `20261008T114205Z-3757394f` is deployed. All 1,173 Git-archive
source blobs match; FE/BE/worker restarted, eight units/six loopback endpoints
and PostgreSQL readiness/private listeners/public Access health passed.
Focused Chromium child `uat-web-gaps-20261008T114654Z-3757394f` is active with
zero retries/maxfail1 and exactly four discovered blocks. State
`/tmp/tfp-web-human-gaps-state.json` binds the owner/cache/log/report/atomic status.
Missing final status means unfinished. Only new or
affected flows are selected; no completed full matrix is repeated. Preserve every
first failure, original context/manifest and capture. Stop on the first actual
failure and review its initiating boundary before any correction or rerun.

## Remaining release limits

The ledger maps 155 cases: 147 implemented and eight blocked. Mapping is not
runtime proof. OAuth and the six delivered-email OTP business cases remain
excluded and must not run or become seed-login passes. The additional blocked
quiet-hours delivery case is an external inbox-proof gap, not a passed exclusion.
Native coverage remains separate. A focused child cannot satisfy the unchanged
six-compatible-clean-child aggregate/verifier contract. Production inputs,
host/DNS/TLS, provider delivery, bucket policy and independent recovery remain
external launch gates. No production deployment or approval is claimed.
