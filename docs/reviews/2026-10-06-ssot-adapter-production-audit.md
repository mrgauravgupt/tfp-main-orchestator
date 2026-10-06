# SSOT, adapter and production-safety audit — 6 October 2026

## Release decision

The seven confirmed findings in this bounded code-first audit are fixed,
independently reviewed, published and deployed to UAT. Implementation and scoped
independent reviews used **GPT-6.1 SOL high**, as requested. Root inspected the
actual callers, transaction/lock boundaries, configuration consumers, saved
discriminating checks and all twelve affected browser captures.

No actionable code blocker was found in the reviewed changes. This is not an
error-free or load/scale guarantee for every application path. Production launch
and a new strict six-child certificate remain pending. No completed suite or
browser matrix was restarted.

| Repository | Published revision | Exact UAT release |
| --- | --- | --- |
| Application/harness | `9df8105d7a24edd7bafe68bd444da43421616a35` | `20261006T105806Z-9df8105d` |
| Image worker | `6272694fe8dfd9211028e83468eb9789cd7eb52a` | `20261006T105210Z-6272694f` |
| AI interface | `96fef1a18cd3cfeffba28f3d170fe451b7985e58` | `20261006T105249Z-96fef1a1` |

Parent gitlink publication is `36d56072ebd99610f28856d2ab9ca88cacebe27e`.
Application implementation is `02455468429bfa85c32f3cd63afe6f9660bd0791`;
`9df8105d7` removes only two trailing new-file blank lines caught after that
commit. This formatting correction was published before deployment; remote
history and original evidence were not rewritten.

## Confirmed changes and ownership

| Finding | Concrete correction and canonical owner | Affected consumers |
| --- | --- | --- |
| Competing requests can lose a committed finalized upload | `apps/api/src/modules/upload/upload-link.ts` validates finalized ownership/scope/entity and uses the existing owner barrier inside the linking transaction | Contest create/update/entries; event create/update/gallery; opportunity create/update/gallery/workspace; avatar/cover/portfolio |
| Source deletion can bypass references or evidence protection | `packages/database/src/adapters/source-deletion.adapter.ts` supplies one `SourceDeletionPort`. Sorted owner session locks share namespace 71903 with link transaction locks. It rechecks owners/references/holds, commits retirement and cleanup work before provider DELETE, retains the lock through awaited settlement and clears work only on confirmed success | Upload service, server/worker composition, background cleanup, report enforcement, opportunity cleanup and owner portfolio deletion |
| Worker deployment overwrites supported environment overrides | `tfp-collage-service/scripts/deploy/deploy.sh` forwards supported values and validates the emitted environment through `src/config.ts` before remote writes. Integer/boolean parsing fails closed | Local/UAT/production deployment profiles and private/public storage adapters |
| A late invitation response can reopen a terminal quick request | Existing `quick-request-lifecycle.policy.ts` is the status authority; `quick-request.repository.ts` locks the parent, reads fresh status/time and conditionally updates the exact invitation. Decline does not rewrite the parent | Response route/command/repository, cancellation and selection ordering |
| Recipient challenge quota admission races | `auth/email-code-reservation.ts` uses `authCommandStore` and a recipient advisory lock; quota/supersession/insertion are atomic and use a fresh post-lock clock | Existing email-code request path; delivery remains outside the transaction |
| New OAuth users bypass the registration flag | `auth/user-creation-admission.ts` is shared by the actual new-user OTP and OAuth branches | New-user provisioning only; existing-user sign-in/link branches stay intact |
| AI failure paths can retain raw exception text | `tfp-ai-interface/src/tfp_ai_interface/worker_ports.py::normalize_failure_code` is the bounded known-code authority, reused by typed failures, adapters, classification, repository failure storage and the private text/translation API response sinks | Worker retry/failure metadata, `last_error`, private API error codes and sanitized diagnostics |

No new migration, queue replacement, retry layer, global transport tweak,
security exception, console suppression or test-only product branch was added.
The source deletion adapter uses a dedicated bounded PostgreSQL client, not a
second pool. The existing request timeout supplies its connection/query/lock
and SDK DELETE bounds. HTTP/TLS and SDK retry behavior remain intact. Missing
deletion-port composition fails closed and leaves durable cleanup work.

Legacy active media without upload intents remains protected until domain
retirement. Shared/referenced/held objects and unknown ownership are retained;
historical unknown provider settlement requires evidence/operator resolution,
not speculative deletion. Portfolio command extraction and opportunity media
command extraction retain the existing module-size boundary rather than raising
it. No duplicate application-wide status/config registry was introduced.

## Executed checks and discrimination

| Boundary | Accepted executed result | What distinguished broken behavior |
| --- | --- | --- |
| Recipient admission/policy | 15/15: 8 real PostgreSQL reservation checks, 4 policy/consumer-AST checks, 3 unchanged crypto/schema checks | Removing the recipient lock or bypassing creation admission failed the two intended assertions |
| Quick-request response | 27/27, including 17 real PostgreSQL cases | Old lifecycle policy failed three intended cases; removing the parent lock failed two contention assertions |
| Upload linking/deletion | Final source/link file 18/18 real PostgreSQL; completion file 9/9 real PostgreSQL; three affected consumer unit files 12 passes | Removing owner locking or reference fencing failed the actual lock/winner-protection assertions |
| SDK deletion settlement | 1/1 with a real loopback HTTP server | Removing abort settlement allowed a late 204 and failed the intended rejection assertion |
| Worker configuration | 45/45 actual deploy-environment/config checks | Restored old forwarding/parsing failed two intended assertions |
| AI failure privacy | 61/61 worker/adapter/repository checks, including disposable real PostgreSQL, plus 17/17 authenticated ASGI API checks | Unsafe normalizer failed seven intended assertions; restored raw API sink failed two. Known codes remained passing |

Upload's earlier combined run is preserved as failed: twelve consumer unit
checks passed but PostgreSQL cases exposed a real session `search_path` reset.
The adapter was corrected and final PostgreSQL checks passed separately. Do not
describe that earlier aggregate as passing, or count overlapping runs as new
business coverage. Mutations used disposable modules/schemas and did not revert
published source or inject faults into UAT providers.

API/database/storage/upload types, strict affected test typing, scoped lint,
production builds, E2E typing, architecture boundaries and strict-human guard
88/88 passed. Worker deployment's required lower-level validation reported
66 passed / 4 skipped / 0 failed; its skipped PostgreSQL tests are not proof for
this batch. The independently executed 45 configuration checks provide that
batch's proof. AI checks did not invoke model/provider business inference.
OAuth and delivered-email OTP business/provider cases were not executed or
counted as passes; lower-level reservation and admission/AST checks are separate.

Representative commands used, with an explicitly selected disposable local
PostgreSQL URL for database tests:

```bash
# Application workspace: no broad test/reset launcher
bash scripts/pnpm-node20.sh --filter api test tests/modules/auth/email-code-reservation.postgres.test.ts tests/modules/auth/user-creation-admission.test.ts tests/modules/auth/email-code-auth.test.ts
bash scripts/pnpm-node20.sh --filter api test tests/modules/quick-request/quick-request-lifecycle.policy.test.ts tests/modules/quick-request/quick-request-response.postgres.test.ts
bash scripts/pnpm-node20.sh --filter api test tests/modules/upload/upload-link-safety.postgres.test.ts tests/modules/upload/upload-completion-concurrency.postgres.test.ts
bash scripts/pnpm-node20.sh --filter storage test tests/storage-delete-deadline.test.ts
bash scripts/pnpm-node20.sh --filter database build
bash scripts/pnpm-node20.sh --filter storage build
bash scripts/pnpm-node20.sh --filter uploads build
bash scripts/pnpm-node20.sh --filter api build
bash scripts/pnpm-node20.sh exec tsc -p tsconfig.playwright.json --noEmit
bash scripts/pnpm-node20.sh test:e2e:human:guard
# Worker workspace
bash scripts/pnpm-node.sh exec tsc
bash scripts/pnpm-node.sh run build
# AI workspace
uv run pytest -q tests/test_worker_service.py tests/test_worker_adapters.py tests/test_worker_repository.py tests/test_worker_repository_postgres.py
uv run pytest -q tests/test_api.py
# Parent workspace
bash scripts/oci/verify-uat-stack.sh
```

The immutable log files record executed subsets, environment wrappers, early
failures and mutation results. These commands document targeted usage; they do
not authorize another browser run or reset. Repository wrappers select the
pinned runtime despite their historical `node20` names.

## Deployment and affected live proof

Canonical service deployers restarted the actual FE, BE and affected workers.
Full UAT health passed: eight active units, ready PostgreSQL, six reachable
loopback endpoints, private listeners and the public Cloudflare Access 302
boundary. Current release pointers and actual Git archive blobs matched:
**1,174 app / 29 worker / 23 AI blobs, zero mismatches**.

Exactly one fresh focused Chromium child ran after exact-block discovery:
`uat-ssot-affected-20261006T110220Z-9df8105d`. Both canonical blocks passed
once, zero retries/failures/flakes/skips, canonical runner and durable wrapper
exit 0. Its owner is absent; no further browser launch is needed.

- Profile `profile-portfolio.human.spec.ts:18`, PRO001/002/003: avatar/cover and
  portfolio uploads, invalid-file handling, exact new loaded-image assertion,
  deletion cancel/confirm/persistence and public loaded image assertions.
- Request `quick-request-lifecycle.human.spec.ts:137`, QR006: visible invitation
  decline, persistence after reload, requester cancellation and persistence.

Root's raw audit used the canonical context loader and AST block matcher, checked
exact clean app/harness/release, four live registry hashes, unique identities and
attempts, results, catalog and all regular non-symlink capture files. All browser
console/page/request/server diagnostic arrays are empty. Root directly viewed
all twelve before/after desktop/tablet/mobile captures; recorded document widths
match 1440/768/390, images are loaded and complete invitation names/statuses fit.
The fixed navigation position in full-page screenshots was not treated as an
unproved layout defect. These captures do not claim drawer interaction coverage.

Canonical context hash:
`0b81ef4b9c619027f78d699af20251355d7429037fdddf7fce3cf321a29b7750`.
Current inputs hash:
`da0005c9a1a2c39c7eb117f9a459ee9f46a9df4b7f2771f1fa54d5b17bfada19`.
The child explicitly reports **incomplete coverage**; no aggregate/verifier
certificate was generated. Historical f19 and all earlier failed/partial/dirty
observations remain separate. These corrections do not establish the initiating
cause of the original provider PUT timeout, telemetry rejection, ORB, earlier
notifications 500 or Firefox insertion loss.

## Remaining launch gates

Fresh strict production doctor at `9df8105d7` exits 1 with **19 external input
gaps**: three database bindings, six legal/operator fields, three service URLs,
four private/public storage credential fields and three backup bindings.
Production host/DNS/TLS, actual provider delivery, bucket ACL/CORS/retention and
independent off-host database/object restoration still require production access.
No values were invented; production deployment or approval did not occur.

A new strict certificate still needs six compatible complete clean children and
aggregate/verifier exit 0. The user's no-full-rerun policy remains in force;
focused/historical/partial evidence must not be spliced or relabeled to close
that gate. Manual `test:e2e:human:certify` remains available for a separately
authorized future run. Current feasible scoped implementation and validation
are complete; no continuing monitor or browser runner is required.

## Evidence retained

Application directory:
`test-results/reports/diagnostic-review/ssot-architecture-audit-20261006/`.
Key records are `upload-freeze.json`, `published-source-binding.json`,
`root-build-static-result.json`, `deployment-bindings.json`, the three deployed
source audits, `production-env-doctor.json`, `supervisor-focused-audit.json`,
`independent-final-review.json` and copied command/mutation/deployment logs.
The original child report remains under
`test-results/reports/human-target/uat/uat-ssot-affected-20261006T110220Z-9df8105d/`.
Launcher/cache/state originals are preserved. Unrelated moderation-service work
and the executive resume are untouched.
