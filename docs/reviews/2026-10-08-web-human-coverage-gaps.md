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
Focused Chromium child `uat-web-gaps-20261008T114654Z-3757394f` stopped at the
first failure: three passed, one failed, zero retries/flakes/skips, exit 1. SEC002,
SEC007 and CON020 passed; their seven action pairs / 42 regular captures are
complete. An independent SOL high review accepted the two account blocks and
root inspected their desktop/mobile captures plus the contest captures. SEC007
aged naturally for at least 603.534 seconds. Context hash:
`0f442fcbab14877c948d952f9c00973dcd09808773101c0953fd45cd939241d0`.
Root's bound evidence audit is `/tmp/tfp-web-gaps-original-reviewed.json`.

| Source / failure | Proven initiating cause | Minimal correction / status |
| --- | --- | --- |
| `messaging-notifications.human.spec.ts:151`, preference form hidden after disable/save/reload | Trace proves the browser reload repeated the POST. The successful POST response opens details via `preferenceMessage`; the unconditional summary click then closes it. Saved values and HTTP 200 were healthy; relevant diagnostic arrays were empty. Missing after evidence is a cascade. | Harness-only: use fresh GET visits for all five preference persistence checks, require no stale saved/error feedback, and click summary only when closed. Match NOTIF003 wording to actual navigation. Source and evidence independently accepted; only this failed block recovered 1/1 on a separate clean context. |

State `/tmp/tfp-web-human-gaps-state.json` and its atomic exit remain original;
the owner is absent. Preserve the failed context/manifest/trace/video/log and
created-record state. No completed account or contest block will be replayed and
no full matrix will restart. Recovery evidence will remain a separate child;
never splice the original failure into a clean certificate.

## Failed-block recovery phase

Root accepted the three-file harness correction and published
`5ab23b68c2552218106d51424218b8f998c40929`. Final Playwright typing, scoped lint,
strict-human policy/88 guard fixtures and diff checks passed. Only the spec,
NOTIF003 navigation wording and tests README changed; product code did not.
The canonical deploy script's archive path list yields 1,173 identical blobs
for both revisions, recorded in
`/tmp/tfp-notification-recovery-runtime-archive-equality.json`. The initial whole
Git-archive comparison included QA files and reported the three expected QA
changes; that inventory remains preserved and is not runtime drift proof.

The application remains deployed at `3757394f`; the clean harness is `5ab23b68`.
FE/BE were restarted before recovery. The first immediate graph check reached
API before its listener was ready (exit7); the later settled graph check passed
without a second restart. Both health logs remain preserved.
Fresh isolated-cache official discovery selected exactly one Chromium block,
`messaging-notifications.human.spec.ts:16`. Recovery
`uat-notif-get-20261008T120920Z-5ab23b68` passed 1/1 once with zero retries,
failures, flakes or skips and canonical/atomic exit 0. Operator state is
`/tmp/tfp-notification-recovery-state.json`; both durable owners are absent.
No account, contest or completed full browser matrix was repeated. The clean
context correctly separates deployed app `3757394f` from harness `5ab23b68`.

Root and independent GPT-6.1 SOL high reviewed canonical AST/seven-ID mapping,
four live registries/input hash, regular contexts/manifests, attempt1 and two
complete action pairs / twelve ready captures. Relevant diagnostics are empty.
Root inspected all recovery desktop/mobile captures, including the localized
validation alert and unchanged saved schedule. The full flow also asserted
invalid Web response 200, disabled-state persistence, valid UTC recovery and
original-schedule restoration. No product defect was inferred from the earlier
harness failure. Passing traces are not retained by the existing policy: six
intentional submits/five fresh GET visits are verified in source and passing
assertions, not an independently preserved recovery network sequence.

Recovery context hash:
`71f0d23bc28a0c377b20bff99441b1fe85a0defa88ad682efcd1e2e887982521`.
Recovery inputs hash:
`30a2b34361bf85c27f24b55ac44311f9cfca44ca01dba3ca44f29f661b804d3a`.
Root audit: `/tmp/tfp-notification-recovery-reviewed.json`.
Across the separate original and recovery evidence, ten mapped IDs have passed
execution, nine complete action pairs and 54 regular captures; root inspected
all 36 desktop/mobile images. Tablet metadata was audited, not claimed visually
inspected. The original report remains failed/incomplete, recovery coverage is
incomplete, and their registry/input hashes differ. No aggregate/verifier success
was generated and no strict clean certificate is claimed.

Recovery command (executed once through the durable owner):

```bash
E2E_TARGET_ENV=uat E2E_BROWSERS=chromium E2E_RETRIES=0 E2E_WORKERS=1 E2E_GREP='delivers a two-party message' bash scripts/qa/run-human-target-e2e.sh
```

No browser runner or continuing monitor is needed. The remaining live inbox
question is unresolved; no secrets were requested or exposed.

## Remaining release limits

The ledger maps 155 cases: 147 implemented and eight blocked. Mapping is not
runtime proof. OAuth and the six delivered-email OTP business cases remain
excluded and must not run or become seed-login passes. The additional blocked
quiet-hours delivery case is an external inbox-proof gap, not a passed exclusion.
Native coverage remains separate. A focused child cannot satisfy the unchanged
six-compatible-clean-child aggregate/verifier contract. Production inputs,
host/DNS/TLS, provider delivery, bucket policy and independent recovery remain
external launch gates. No production deployment or approval is claimed.
