# Remaining Web gates — scoped implementation, 8 October 2026

The user authorized implementation of feasible remaining gates and selected
manual email-delivery checking. Completed browser flows and matrices must not
be repeated. Current executable code and tests are authoritative.

## Prioritized pre-edit findings

| Priority | Evidence and cause | Minimal change |
| --- | --- | --- |
| P1 operator correctness | `apps/api/src/modules/quick-request/quick-request.repository.ts` updates a moderation decision by ID without fencing the displayed state, revision, expiry or timestamp. The existing authenticated administrator API can overwrite a terminal request or newer owner revision. This is not an unauthenticated exploit. | Conditional transactional transition using existing state/revision/time fields; reject stale, expired, selected and inactive-owner requests before side effects. No migration. |
| P2 missing Web capability | The authenticated QuickRequest moderation queue/decision API exists, and the owner detail already supports ACTION_REQUIRED/REJECTED resubmission. No administrator Web consumer reaches those decisions; QR013 is blocked. | Private SSR operator queue, typed shared API contracts, existing admin session/MFA and canonical navigation/localization; one new strict-human revision flow. |
| External delivery proof | Notification scheduling already defers transport through existing delivery/outbox owners while preserving immediate in-app activity. Sender-key presence does not provide recipient-inbox access. | User chose manual receipt verification. No new transport, receipt-provider dependency, fake inbox or scheduler change. NOTIF006 remains unverified. |
| External production launch | Fresh strict production doctor exits 1 for 19 actual missing/unsafe production bindings. | Retain fail-closed configuration. Do not invent production values or deploy production. |

## Affected-surface map

- Direct: QuickRequest moderation API/command/repository, administrator Web queue,
  owner revision form, shared API contracts, navigation/localization and new
  human-flow mapping.
- Indirect: existing matching and automated moderation consumers; retain one
  winner, terminal-state protection and original event ownership.
- Persistence: existing version/status/expiry fields and transactional audit;
  no schema migration or queue replacement.
- Native: same backend contracts; inspect callers of the moderation endpoint.
  No native UI implementation or authenticated device proof is claimed.
- Validation: focused real PostgreSQL and HTTP/auth checks, affected types/lint/
  builds/guards, one new filtered human flow with fresh FE/BE setup and live
  desktop/tablet/mobile evidence.
- External: production host/DNS/TLS, actual provider delivery, storage ACL/CORS/
  retention, credential revocation/rotation and independent off-host recovery.

## Fresh production configuration check

`bash scripts/run-node20.sh scripts/env/doctor.mjs --target production --strict`
exited 1. The private diagnostic log is
`/tmp/tfp-remaining-gates-production-doctor-20261008.log`; no secret values are
published. The 19 gaps are:

- Three database URLs still resolve to local development rather than the actual
  production database (application, direct/migration and shadow).
- Six legal/operator values: operator name/address, grievance officer name/
  designation and governing law/forum.
- Three actual service URLs: moderation, translation and image processing.
- Four independently scoped private/public storage credential bindings; use the
  supported canonical `STORAGE_PRIVATE_*` / `STORAGE_PUBLIC_*` environment names.
- Three separate off-host backup bucket/key bindings; use `BACKUP_STORAGE_*`.

These are inputs and live proof, not unfinished code inferred from Markdown.
The standard strict six-compatible-clean-child aggregate/verifier certificate
also remains pending under the user's no-full-rerun policy.

## Manual quiet-hour receipt check

The user offered their logged-in Gmail mailbox or a manual check; the selected
option is manual. No mailbox access or email send is performed by this batch.

1. In the recipient's normal account, configure quiet hours in Notifications
   using a known time zone, with the current time inside the window and its end
   a few minutes ahead. Record the actual end time and zone.
2. Use a real visible notification-producing action, such as operator approval
   of the recipient's owned opportunity. Ordinary messaging alone is not this
   email trigger. Use a unique harmless title for identification.
3. Confirm the matching in-app activity immediately, and no matching email in
   the actual inbox before the window ends.
4. After the natural boundary, confirm one matching received email, its receipt
   time and exact target link. Open the target normally and restore preferences.

No provider acknowledgement, console-capture file or passing preference form
test is inbox-delivery proof. A manual result is separate evidence; it does not
retroactively make NOTIF006 an implemented automated flow or certify a release.
OAuth and six delivered-email OTP business cases remain excluded.

## Implementation and verification result

App `61eb5e7d508ca72d83b3102e194198c23697633a` is published with 21 scoped files. The existing manual-audit
persistence helper was moved and reused by both original admin commands and
QuickRequest moderation; no competing audit implementation remains. API decision
payloads now require the current queue snapshot. The existing domain API consumer
was migrated, and no native moderation consumer exists.

Independent GPT-6.1 SOL high review accepted the product implementation. Its one
P2 test finding was corrected before execution: a pre-existing automated rejection
could make a failed operator POST appear successful. The new block now requires
the exact visible operator POST's success-only 303 redirect, no error alert and an
advanced snapshot timestamp.

Executed checks:

- Real disposable PostgreSQL 24 cases plus seven actual HTTP handler/guard checks.
- Existing manual admin command/override consumers: 32 passed.
- Web unit suite: 783 passed once. A forwarded `--` made the intended filter
  ineffective; this full unit run was preserved and was not repeated.
- Shared/API/Web typing, Playwright typing, scoped ESLint, strict-human guard
  (17 specs, 155 mapped cases, 66 routes), production builds and staged diff check.
- A disposable unlocked-matching mutation failed the intended cancellation
  assertion (expected zero invitations, received one). Original product bytes
  were not reverted; disposable copies were removed.

Initial PostgreSQL execution skipped 21 cases without the TEST binding and is not
proof. The later explicit local TEST binding executed the real cases. The first
mutation launcher had a wrong cwd and ran zero tests; it remains distinct. An
initial discovery JSON postprocessor rejected the environment-wrapper preamble;
the same preserved official exit-zero discovery was parsed correctly without
another discovery or browser run. Staging also caught and removed one trailing
blank line in a newly tracked helper before commit.

Official fresh-cache discovery selects exactly one Chromium block at
`quick-request-lifecycle.human.spec.ts:463`, titled
`recovers an operator-returned quick request through owner revision and resubmission`.
Preflight is `/tmp/tfp-qr013-preflight-state.json`.

UAT is deployed at `20261008T150145Z-61eb5e7d`. All 1,176 canonical
Git-archive blobs match; API, worker and Web running cwd bindings match the
release. Main deployment restarted FE/BE/worker. Full graph health passed: eight
active units, six loopback endpoints, PostgreSQL ready, private listeners and
public Access HTTP302. No old release pruning was requested.

Original focused Chromium child `uat-qr-revision-20261008T150540Z-61eb5e7d` stopped at its first failure with zero retries,
one worker, maxfail1 and complete action evidence. Durable operator state is
`/tmp/tfp-qr013-proof-state.json`; atomic final status, not PID existence alone,
owns the result. No completed flow or matrix was replayed. The original failed evidence is preserved; no success is inferred from its completed operator steps.
No production approval, aggregate success or universal absence of defects is claimed.


## Preserved first failure and minimal recovery

| Source snapshot / first failure | Proven initiating cause | Correction / status |
| --- | --- | --- |
| Clean app/harness `61eb5e7d`, focused child `uat-qr-revision-20261008T150540Z-61eb5e7d`, exit 1, zero retries. The owner value assertion at line513 found no exact-label locator. | Saved DOM has a label containing both the caption and the textarea's server-rendered initial text. Playwright 1.59.1's exact label-text engine concatenates both. The saved accessibility snapshot and screenshot independently show the correctly named, visible textbox with its original value. Locale caption matches. Operator POST 303, changed snapshot and rejected status passed; owner empty/revision/active assertions were unexecuted. Missing after captures are a cascade. | One harness locator changes to textbox role with exact accessible name; README explains the engine difference. Product and ledger are unchanged. Playwright typing, scoped lint, strict-human guard and diff passed. No timeout, retry, assertion or security weakening. |

Original context/manifest/results/trace/video/screenshots/logs and created-record
state remain unchanged under the original report and `/tmp/tfp-qr013-proof-state.json`.
The original atomic result remains exit 1 and its owner is absent.

Harness-only `4d0da4445d5be7c5d7fdd490b9b7fc1cf2cbfc6c` is published. All 1,176
canonical runtime archive blobs are byte-identical to the deployed app 61eb5e7d;
no redundant deployment was needed. The equality inventory is in the recovery
preflight directory. Fresh FE/BE restart and full settled graph health passed.
Exactly one official fresh-cache recovery discovery maps the same QR013 block.
Recovery `uat-qr-recovery-20261008T151413Z-4d0da444` stopped on its first failure (exit 1, zero retries); `/tmp/tfp-qr013-recovery-state.json`
binds the independent OS-session owner, cache, file logs, report and atomic exit.
It uses zero retries, one worker and maxfail1. This was a reviewed failed-flow rerun;
no previously completed business flow or browser matrix is repeated. Application
and harness revisions remain separate, and original/partial evidence will not be
spliced into a strict clean certificate. The original recovery artifacts remain unchanged; it is not passed evidence.


## Newly reached invalid-field accessibility boundary

The recovery reached and filled the correctly named owner textarea, then its
empty required-field submission exposed a real markup/validation interaction.
`form-helpers.ts` resolves an input wrapper from canonical field containers or
its parent element; the newly wrapped label was that fallback. The helper read
its entire `textContent` (including the SSR initial textarea value), inserted the
error inside the same label, and used the absent control ID to produce `-error`.
The saved trace and error-context show that contaminated message becoming part
of the textbox's accessible name. The field was still visible and required
validation worked; subsequent lookup and after evidence failures were cascades.

The new administrator select has the same source pattern and no ID, so its
empty-choice boundary requires the same correction. The minimal product fix is
limited to both new forms: explicit labels referencing unique control IDs inside
existing `data-validation-field` wrappers, with errors outside the label. Shared
validation code, APIs, persistence, retries and timeouts remain unchanged.
Actual source-derived markup and compiled validation-helper browser checks must
prove stable names, uncontaminated messages, unique described-by IDs, invalid
submission blocking and recovery before another focused business execution.
No full suite, completed old flow, DB reset or historical evidence rewrite is
permitted. Both original failed attempts remain separate.


## Reviewed product accessibility correction

App `cda03ae320b29ee41465959a0347434e822235f9` is published with five scoped files. Both new owner/operator
controls now use explicit labels and unique IDs in existing validation wrappers.
Shared validation code, API behavior, constraints, persistence and queue ownership
remain unchanged. Source-derived markup with the actual compiled helper passed
in Chromium and Firefox (two tests covering both controls). Each old wrapping
shape failed its intended accessible-name assertion in both engines. Four target
Web checks, typing, scoped lint, strict guard and Web production build passed.
Independent SOL high source review accepted the exact diff. These are isolated
DOM checks, not API persistence or external E2E proof.

Preserve the initial browser-boundary prototype's invalid ValidityState
serialization failure and first focus/blur setup failure separately from final
passing tests. Temporary mutant copies were removed; original product bytes were
not reverted. Exact publication/deployment and one affected proof remain pending.
