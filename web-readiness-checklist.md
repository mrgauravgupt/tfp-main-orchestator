# ✅ TFP Web — readiness and pending verification checklist

**Reviewed and implemented locally: 20–21 November 2026 (IST). Phase 1: web. Phase 2: native mobile.**

This is the work checklist for a defensible web release, not a promise of zero
future bugs. It separates confirmed tooling/configuration problems, uncompleted
verification, operator-deferred work and host commissioning. An unchecked item
does not automatically mean the corresponding product feature is broken.

The follow-up review identified eight areas needing explicit acceptance checks.
[Section 6](#follow-up-findings) records each finding,
existing implementation/test owners and completion evidence.
[Section 7](#execution-plan) gives the execution order. These additions are
tracked acceptance work. The [implementation and actual-results record](tfpphotographers/docs/operations/WEB_READINESS_BATCH_2026_11_20.md) distinguishes completed local fixes from remaining release gates.
[Section 8](#public-user-e2e-gaps) records the subsequent public-user E2E
reconciliation and eight specific scenario additions/refinements. Existing
domain/API coverage is distinguished from missing strict-human execution.

## 📍 Ownership and current evidence

- **Business requirements and implementation status:** the [canonical use-case ledger](tfpphotographers/tests/e2e/human/use-case-coverage.json).
- **Per-journey execution status, deferred titles and original attempts:** [human-like-flow-pending.md](human-like-flow-pending.md).
- **Providers, secure configuration and operator inputs:** the [provider inventory](tfpphotographers/docs/operations/PROVIDER_AND_SERVICE_INVENTORY.md).
- **This file:** remaining release tasks and acceptance evidence. It does not replace those owners or maintain another set of per-case pass/fail results. Update the journey tracker first when a flow completes, then link its actual receipt here.

The original read-only review inspected `73c4267d697219a07f2099e140d6bb0ae0272ac0`.
This implementation batch ends at application/test source
`1e1476e19339b161ef0557ebec0439ef0d4339e1`. Its intermediate candidates and
original failed attempts remain recorded separately; documentation publication
does not restamp them.

| Current fact | Verified boundary |
| --- | --- |
| 207 canonical cases | 200 implemented; 7 delivered-email cases blocked. Four new fixture-dependent cases remain local-only. Implementation status is not a runtime pass. |
| 128 executable journey groups in 29 specs | 108 ordinary/public declarations and 20 deferred admin/mixed-admin declarations. The original 93 + 8 matrix remains historical; this batch adds seven declarations and extends existing ones. |
| Earlier member journeys | The 93-group matrix has passing source-specific evidence per browser; 8 earlier groups retain their prior evidence. This is not a single complete current-revision run. |
| Latest reporting fix | 12/12 selected executions passed on the same application candidate: four each in Chromium, Firefox and responsive Chromium, zero retries; six exact DB receipts and 144 retained captures. See the [reporting record](tfpphotographers/docs/operations/MOBILE_REPORT_CLICK_FIX_2026_11_20.md). |
| Batch lower-level validation | Full API 1,516/1,516 at `70c1925d3`; later frontend/harness candidates have their own selected 73-method prerequisites, including ten exact DB checks. Web 915 + 4 separately after disk recovery; safe harness 245/245. Final affected image/location checks, types/lint and frozen web build passed. These are scoped results. |
| Production configuration | The local read-only strict doctor was rerun for this checklist: exit 1, exactly 12 unresolved settings, listed below. This is not an observation of a deployed host. |

**Do not reopen completed work as missing:** B2 media roles/private backup bucket,
backup completion/pruning/restore fixtures, Cloudflare operator access, Axiom UAT
repair, monitoring ingestion and shared upload/storage URL ownership already have
documented proof. Their future host activation remains separate. Existing email
is Resend; no SES adapter, new paid plan or replacement provider is required here.

## ✅ Local batch completion — 21 November 2026

All **12 affected journeys × 3 web browsers = 36 slots** have passing actual
source-specific evidence: **39 exact DB receipts, 252 retained captures, zero
retries**. Mobile web passed 12/12 on `1e1476e19`; Chromium/Firefox use their
recorded original and failed-only attempts. The [current journey table](human-like-flow-pending.md#readiness-batch-20261120)
and [batch report](tfpphotographers/docs/operations/WEB_READINESS_BATCH_2026_11_20.md)
retain sources, original failures and commands. This does not certify the full
108-declaration current-source member matrix or the full release aggregate.

Confirmed fixes include homepage count/unread freshness, localized 500 Retry,
bounded location permission/manual recovery and empty-gallery-image handling.
The eight public coverage gaps below are closed at their affected local scopes.
Shared workflow, location, URL/cache and read-only persistence owners remain SSOT.
Storage, checksums, attribution, moderation and evidence holds are unchanged.

Safe cleanup removed 42 verified rebuildable TFP/PulseTrade cache directories
(3.24 GiB logical). Sources, DBs/trading ledgers, media, held evidence, releases,
active PulseTrade and manual FE3000/API4000 remain preserved. Both manual health
endpoints returned HTTP 200. Owned test services/cluster are stopped; data remain.

**Still open:** scoped hosted-CI repository access; final-source full acceptance,
production-artifact/security/restart and supported-browser/AT/timezone review;
operator legal/contact decisions and host commissioning. Admin/email remain
deferred and native is Phase 2. The final read-only production doctor still
reports the same 12 settings. No purchase, paid upgrade or deployment occurred.

## 🔧 1. Work before buying a host — implemented and remaining CI access

- [x] **Repair moderation/autofix CI database bindings.** The workflow now supplies the canonical admin role, owner, password and shadow URL matching its Postgres service. The owned local database bootstrap and actual API/regression execution passed. A hosted run of this changed workflow is still unverified; do not replace the retained failed run with a green claim.
- [ ] **Complete secure CI repository access.** The existing Geoapify key is now bound as `GEOAPIFY_API_KEY`; `TFP_CI_OPENROUTER_API_KEY` already exists. `TFP_CROSS_REPO_READ_TOKEN` remains absent. The private user-owned repository has no organization/environment credential supplying it. Provide approved contents-read-only access to the existing AI/image repositories; do not copy the broad personal local credential into Actions. Real auxiliary checkouts and hosted browser execution remain the acceptance gate.
- [x] **Replace unsupported paid Dependency Review.** Every PR retains the supported whole production-tree vulnerability audit, frozen install, installed-byte safeguards and Gitleaks. The unsupported duplicate paid action is removed. This does not claim differential/license review. Local frozen-install checks and production audit passed; no purchase or paid feature activation occurred.
- [x] **Repair OTP-compatible authenticated performance tooling.** Use a private `--storage-state` exported after normal OTP login, read-only `/auth/me` verification and redacted failures. Two actual HTTP/cookie/private-file methods passed; the anonymous two-page CLI smoke ran successfully. Real authenticated measurements remain deferred with delivered email and are not claimed from those component tests.
- [x] **Review dated dependency safeguards.** The primary Deepmerge/Picomatch advisories are withdrawn; conservative patches and installed-byte safeguards remain. Effect is centrally pinned to the fixed 3.22.1 patch. Frozen-install safeguards passed 6/6 and the production audit passed. Deepmerge **24 November** and Picomatch **2 December** review dates remain unchanged; review again if launch crosses them.

Actual sources, commands, original failures, provider-binding scope and receipts
are in the [batch record](tfpphotographers/docs/operations/WEB_READINESS_BATCH_2026_11_20.md).
No hosted CI success or final production performance is inferred from local proof.

## 🧪 2. Pending human-like E2E and final-source proof

### Member web journeys and exact persistence

- [x] **Define the final Phase 1 acceptance scope explicitly.** Chromium, Firefox and responsive Chromium are the current executable projects. `mobile-chromium` is web emulation, not an Expo/iOS/Android result. Keep the admin/email exclusions visible; do not describe this excluded scope as every web case tested.
- [ ] **Freeze the intended release source and assemble compatible lower-level/API proof.** The latest candidate has its own 73-method selected proof, including ten PostgreSQL persistence checks. The complete 1,516-method result is bound to `70c1925d3`; the API implementation is unchanged, but this is not a full final-commit required-PostgreSQL certificate. Use the existing source-bound proof owner; no restamping old results.
- [ ] **When final sign-off is requested, obtain the missing complete current-source member matrix.** Earlier successful member journeys span several sources and scoped reruns. Use one planned final pass on a clean isolated TEST target, with zero retries and exact selected titles. Do not repeatedly replay completed suites during ordinary fixes. Any later failed-only result must retain the original failure and its actual source.
- [x] **Reconcile persisted postconditions with the right evidence.** Reuse [the typed read-only verification port](tfpphotographers/scripts/qa/support/persistence-contract.ts) and visible reload/independent readback. It already covers profiles/location, content, messages, applications, saved searches, reviews, media, holds, erasure and reports. Audit important saved fields against their test assertions and add checks only for confirmed gaps; do not assume every DB column or every form field already has an exact-value checkpoint.

  **Completed scope:** exact contest-entry/RSVP checkpoints were added to the existing typed port; the affected real application/entry/RSVP, report, message and saved-location flows passed independent DB/reload checks across browsers. This does not claim every database column/form field or unexecuted sibling case was checked.
- [x] **Investigate and fix the newly reproduced pending-location interaction.** Native Firefox permission waiting could keep Detect loading indefinitely; the shared overall deadline/manual cancellation now passes in all three web browsers. This is distinct from the earlier provider-empty/SRI observations, whose original failed and separate passing receipts remain preserved. SRI has not recurred; keep integrity checks and genuine provider results. No error suppression or automatic retry loop was added.

### Admin/mixed-admin journeys — ⏸ operator-deferred

**Do not run these under the current instruction.** The exact 20 executable
titles and their source owners stay in the [existing deferred list](human-like-flow-pending.md#deferred-admin-journeys).
The following groups summarize that list; they do not create additional cases.

- [ ] **Moderation and reporting: 8 groups.** Queue triage, report resolution, anonymous/standalone report with admin readback, reported-content removal, image hiding, reported-owner disablement, moderator rejection and failed-transport recovery. Preserve exact held bytes and private evidence throughout.
- [ ] **Account security and privileged access: 6 groups.** Disable/restore controls, invalid/replayed MFA, disabled-user login, nonadmin admin-route rejection, member/admin route gates and MFA-gated admin/QA workspaces.
- [ ] **Returned-content recovery: 3 groups.** Quick request, opportunity and event owner corrections after an operator/moderator return, followed by real resubmission/public retrieval.
- [ ] **Contest winner workflows: 2 groups.** The combined publish/react/share/winner journey, and force-gated winner replacement/clearing with nonadmin denial. The combined journey is deferred in full; do not imply all its member-facing phases were independently covered by that declaration.
- [ ] **Referral attribution: 1 group.** Visible signup and the matching administrator attribution view.

The member upload/reporting fix is verified separately. That does not certify the
deferred end-to-end enforcement or privileged review journeys. Revisit their
launch acceptance explicitly before claiming the whole web product is verified.

### Delivered email — ⏸ operator-deferred

- [ ] **After changed authorization, supply a controlled receipt reader and implement/run the seven blocked contracts.** These canonical cases currently have `specs: []`; they are not seven executable passing tests waiting to be counted. The exact blocked status stays in the ledger and [delivery list](human-like-flow-pending.md#deferred-delivered-email-cases).

| Canonical case | Required human-visible proof when resumed |
| --- | --- |
| WEB-E2E-AUTH-002 | Receive a real OTP and complete the login form. |
| WEB-E2E-AUTH-008 | Only the requesting browser challenge accepts its delivered OTP. |
| WEB-E2E-AUTH-009 | Verification consumes the challenge and visible logout clears the session. |
| WEB-E2E-AUTH-010 | Change-email/resend cooldown works without consuming the active code. |
| WEB-E2E-AUTH-011 | Wrong-code attempts reach the real configured challenge lock. |
| WEB-E2E-AUTH-012 | An unknown email receives its OTP and completes visible onboarding. |
| WEB-E2E-NOTIF-006 | Quiet hours delay actual receipt, then the exact notification arrives. |

The existing one-off Gmail/OTP observation and TEST sign-in bridge do not certify
this matrix. No inbox access, real email sending or email exclusion change was
performed for this checklist. Social OAuth is intentionally disabled and its
OTP fallback has coverage; enabling Google/Apple/Meta login is not a missing
requirement of this release.

### Same-source deployed-target certificate

- [ ] **After an explicitly authorized UAT release, verify the declared deployed-target slots.** Match source, registry hashes, actual deployed identity, API prerequisites and original child manifests. The current ledger declares 200 implemented local cases and 164 implemented target cases; use its per-case profiles rather than inventing an identical cross-product for every case.
- [ ] **Run the existing release verifier only after its real requirements are satisfied.** [The canonical certification command](tfpphotographers/scripts/qa/run-human-web-certification.sh) requires clean committed source, matching independently deployed UAT source and the complete required children. It cannot certify an admin-excluded member subset as the full declared web suite. Do not weaken the verifier or change case statuses to make an aggregate green. UAT/production writes need their existing authorization.

## 🔍 3. Additional confidence checks — uncompleted proof, not confirmed defects

- [ ] **Measure production-like web performance and capacity.** First repair authenticated measurement above, then record page weight, loading/rendering timings and responsiveness for representative public/member pages. Check concurrent browsing/uploads, database/outbox backlog and recovery on the chosen host. No capacity or worldwide latency guarantee follows from local functional passes.
- [ ] **Confirm the browser support promise.** Safari/WebKit and real iPhone Safari are not executable projects in the current matrix. If Safari is a Phase 1 target, add/run the appropriate web verification and document actual engine/device results; desktop Chromium emulation is insufficient. Native app work remains Phase 2. Do not advertise other browsers as tested without their evidence.
- [ ] **Complete a focused assistive-technology review.** Existing keyboard/modal and responsive checks passed at their scopes. Verify representative forms, errors, navigation and reporting with a real screen reader and browser zoom; retain contrast/focus/overflow findings and fix confirmed problems. Do not call the existing visual scan full accessibility certification.
- [ ] **Review priority public locales and legal/contact copy.** Existing catalog/schema/RTL checks are useful but do not prove linguistic accuracy in every supported language. Record reviewed languages, long-copy behavior and approved legal text; avoid treating translation inventory counts as human language approval.
- [ ] **Close the historical credential-exposure gate after explicit operator authorization.** The [security record](tfpphotographers/docs/operations/DEPENDENCY_SECURITY_FOLLOWUP_2026_11_18.md#historical-credential-findings--operator-approval-required) retains 47 historical entries, with 28 configuration matches across 13 names; these are not counts of distinct active keys. The user deferred rotation/retirement. Review actual key ownership/consumers and validate replacements before any approved retirement; no revocation, history rewrite or suppression is authorized by this file. A host purchase does not resolve this gate.

## 🖥️ 4. Host commissioning and deployed-provider verification

These are **future tasks**, not authorization to deploy now. Existing B2,
Cloudflare, OpenRouter, Sentry, Axiom and Resend accounts remain the starting point.

- [ ] Obtain the chosen host/access details; configure OS security, private service networking, firewall and TLS.
- [ ] Install PostgreSQL, scoped roles/databases, migrations and the existing FE/API/AI/image/outbox workers. No new Redis/BullMQ architecture or separately purchased DB is required by this checklist.
- [ ] Bind the six technical production values listed below and verify API `/health`, `/ready` and actual worker progress under the chosen runtime.
- [ ] Validate the final compiled/container artifact and a rollback/restart using preserved data. Existing older-image smoke is not final-source image proof.
- [ ] Repeat browser → upload → storage → moderation → retrieval/checksum tests through the real chosen production topology before accepting it.
- [ ] Verify trusted IP/location provenance and non-spoofable forwarded headers on that topology, including ordinary business actions and upload phases. Preserve evidence holds/audit integrity. Geographic inference is not proof of a person's physical location.
- [ ] If enabling the optional Worker flow, separately approve and commission its callback/secrets/routes and real public cache/purge policy. Private/signed/session responses must remain uncached. API ingress remains a valid documented default; do not activate routes merely to mark a checkbox.
- [ ] Install backup, pruning and freshness schedules: six-hour backups, 30-day retention, at least three complete sets and the existing eight-hour freshness threshold. Run a new disposable host-specific restore and verify held evidence/hash readback. B2 bucket/role creation and fixture restore are already complete.
- [ ] Verify target Sentry/Axiom ingestion, redaction and controlled alert receipt. Keep `tfp-uat` separate from `tfp-prod` and application tokens ingest-only. Provider ingestion proof is not proof that an operator received an alert.
- [ ] Configure or replace the optional hosted SEO/health check's missing bindings and verify actual sentinel execution. The latest [green health workflow](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/44353597892) skipped SEO after its configuration check; production health was also skipped. That green badge is not deployed-health or SEO proof. Do not supply an unrestricted production DB credential to untrusted PR jobs.
- [ ] Confirm external account quotas/credits, storage growth and host bandwidth from measured workloads. Purchases, paid upgrades and provider replacements require their own decision.

## 📝 5. All 12 unresolved production settings

Verified by the current local `doctor.mjs --target production --strict` output.
The [provider inventory ownership table](tfpphotographers/docs/operations/PROVIDER_AND_SERVICE_INVENTORY.md#production-inputs-and-setup-ownership--17-november-2026)
remains the canonical configuration handoff; this table lists the pending values
without copying their secrets.

| Setting | Who supplies it / when |
| --- | --- |
| `DATABASE_URL` | We provision scoped runtime access during host/database setup. |
| `DATABASE_DIRECT_URL` | We configure direct migration/tooling access during host/database setup. |
| `SHADOW_DATABASE_URL` | We provision a separate disposable validation DB/role, never the application data DB. |
| `MODERATION_REMOTE_URL` | We bind the installed private moderation endpoint. |
| `TRANSLATION_REMOTE_URL` | We bind the installed private translation endpoint/model assets. |
| `COLLAGE_SERVICE_URL` | We bind the installed private image/collage endpoint. |
| `LEGAL_OPERATOR_NAME` | Operator approves the real operating person/entity name. |
| `LEGAL_OPERATOR_SERVICE_ADDRESS` | Operator approves the legal correspondence/service address. |
| `LEGAL_GRIEVANCE_OFFICER_NAME` | Operator approves the responsible officer. |
| `LEGAL_GRIEVANCE_OFFICER_DESIGNATION` | Operator approves the officer's designation/title. |
| `LEGAL_GOVERNING_LAW` | Operator/legal approval; an agent must not invent it. |
| `LEGAL_GOVERNING_FORUM` | Operator/legal approval; an agent must not invent it. |

- [ ] Operator supplies the six legal approvals and confirms existing public support/privacy/grievance contacts. These are readiness inputs, not a claim of worldwide legal certification.
- [ ] Operator confirms alert recipients and the intended recovery objectives; an existing inbox can be used. Email testing stays deferred until changed authorization.
- [ ] After secure binding, rerun the strict doctor and target checks. Twelve filled values alone do not prove application or infrastructure readiness.
- [ ] Obtain explicit final go-live approval. **Current instruction: no production deployment.**

<a id="follow-up-findings"></a>

## 🔎 6. Follow-up findings and acceptance checks

The original review checked executable source, not only this checklist. The
updated strict-human guard and inventory pass with 207 canonical cases,
128 declarations, 29 specs, 66 mapped Astro pages and 48 API source files. These counts describe the current inventory; they do not establish that
every control, permission or failure branch has been exercised.

The eight items below close omissions or overly broad acceptance wording in the
original checklist. They are not eight newly established product defects.
Existing lower-level tests must be reused where they already cover a boundary.

### 1. Complete control/state coverage — before final web sign-off

- [ ] **Reconcile actual product behavior with the canonical cases.** Inspect visible forms, actions, filters, dialogs and navigation for anonymous users, owners, participants and other members. Cover success, invalid/empty input, limits, forbidden/stale states, cancel, repeated submission and independent retrieval where applicable. Include dates/deadlines across relevant browser timezones and daylight-saving boundaries; a timezone-safe input helper alone does not prove those business boundaries.

  **Finding:** the existing reconciliation accounts for all declared tests. The
  [route guard](tfpphotographers/scripts/qa/human-e2e-guard.mjs) checks mappings
  and annotations; it does not establish semantic coverage of every control or
  branch in a mapped page. No dedicated `timezoneId` variation was found in the
  strict-human spec bodies inspected during the review.

  **Implementation plan:** extend existing `visibleActions`,
  `visiblePostconditions`, `persistedPostconditions` and `negativeStates` in the
  canonical ledger when a real gap is confirmed. Reuse the existing workflow,
  date/location and persistence helpers. Give each behavior a browser journey,
  lower-level-only justification or explicit blocker in the existing owners;
  do not add another action/coverage registry. The four existing API-only
  dispositions, including moderation appeals, remain explicit in
  [API source coverage](tfpphotographers/tests/e2e/human/api-source-coverage.json).

  **Acceptance:** important saved values are checked through the typed read-only
  DB port and independent reload/second-actor retrieval where relevant; negative
  paths prove the forbidden side effect did not happen. Update the existing
  journey tracker with exact source/browser results and remaining blockers.

### 2. Production-mode security boundaries — before final web sign-off

- [ ] **Make the security acceptance matrix explicit.** Verify cross-account resource/file access denial, CSRF, CORS, CSP, cookie flags/session revocation, configured rate limits, private downloads, and absence of test-only authentication/preview shortcuts in the intended production profile.

  **Finding:** the original checklist mentioned API proof and configuration
  checks without listing these security outcomes. The existing
  [CSRF integration suite](tfpphotographers/apps/api/tests/utils/csrf.integration.test.ts)
  explicitly distinguishes enforced non-TEST behavior from the TEST bypass.
  A local TEST human pass alone does not prove the deployed cookie/origin policy.

  **Implementation plan:** reuse the
  [security boundary suites](tfpphotographers/tests/e2e/domains/security/tests),
  existing API/config tests and real browser origin/session controls. Keep
  adversarial request tests in the API/integration layer rather than bypassing
  business logic inside strict-human journeys. Prepare isolated non-TEST checks
  locally; repeat topology-dependent checks only on an authorized target.

  **Acceptance:** unauthorized access has the expected denial and no mutation
  or private-byte disclosure; legitimate writes still work; the final response
  headers/cookies and disabled test surfaces are observed on the exact artifact.
  Admin UI journeys remain deferred; flag any security proof that depends on them.

### 3. Device-location permission and fallback — browser journey gap

- [x] **Verify the actual Detect Location control when permission is denied or location is unavailable.** Check bounded settling, readable feedback, preservation of an existing value, supported approximate fallback and manual selection/save/reload recovery.

  **Completed:** WEB-E2E-PRO-013 passes per browser, including pending/denied native permission, selected map/metadata preservation and manual Pune save/reopen/reload with exact DB coordinates. Native permission success is not manufactured as GPS evidence; component-only emulation remains separate.

  **Finding:** [the shared location client](tfpphotographers/apps/web/src/scripts/client/form-helpers.ts)
  contains a distinct permission-denied/approximate-fallback path. No dedicated
  device-location permission journey was found in the strict-human specs/helpers
  inspected. Existing saved map/coordinate readback and
  [nearest-first autocomplete assertions](tfpphotographers/tests/e2e/human/support/human-location.ts)
  already cover different behavior and must not be relabelled as missing.

  **Implementation plan:** extend the relevant profile/location journey and
  shared helpers using real browser permission controls. Preserve the strict
  guard; no monkey-patched navigator, fake provider response or invented GPS
  coordinate may substitute for the user-visible failure/recovery path.

  **Acceptance:** the control leaves loading state, existing data is not silently
  corrupted, manual correction works, and the saved fields/map match subsequent
  independent retrieval. Record unsupported browser permission controls honestly.

### 4. Interrupted jobs and dependency failures — recovery proof

- [ ] **Specify recovery outcomes for in-flight work.** Cover interruption/restart of owned API/worker processes, relevant database/storage/moderation transport failures and concurrent completion/repeated submissions, with durable data preserved.

  **Finding:** the original restart/capacity wording did not require proof of
  in-flight side effects. Real rollback/concurrent-completion methods already
  exist in [the PostgreSQL upload suite](tfpphotographers/apps/api/tests/modules/upload/upload-completion-concurrency.postgres.test.ts),
  and [the worker](tfpphotographers/apps/api/src/worker.ts) has a drain lifecycle.
  These implementations are not missing; final-artifact recovery remains a
  separately recorded operational test.

  **Implementation plan:** reuse those methods and existing controlled transport
  tooling, then perform bounded process interruption only on a new owned local
  fixture. Do not stop manual/developer services or repair data behind the UI.
  Extend shared recovery logic only after a confirmed failure.

  **Acceptance:** retained bytes/checksums and original attribution survive;
  retry/lease recovery produces the intended single asset/domain effect without
  duplicate moderation work; provider failures do not manufacture approval or a
  content violation; cleanup and evidence holds remain protective. Preserve both
  the original failed attempt and the subsequent recovery receipt.

### 5. Investigation-log lifecycle — separate from telemetry and backups

- [ ] **Commission and verify audit archival/retention explicitly.** Check approved retention settings, archive readback/hash verification, protection of held records, failure visibility, safe expiry and consistent host time.

  **Finding:** backup schedules and Axiom/Sentry ingestion were listed, but the
  separate [activity-evidence background job](tfpphotographers/apps/api/src/background/background-jobs.ts)
  and [archive/expiry owner](tfpphotographers/apps/api/src/modules/legal/activity-retention.ts)
  were not an explicit acceptance gate. These are implemented and have
  [integration tests](tfpphotographers/apps/api/tests/modules/legal/activity-evidence.integration.test.ts).

  **Implementation plan:** reuse the existing maintenance job, hold barriers,
  bounded verification/export tools and [investigation runbook](tfpphotographers/docs/operations/INVESTIGATION_EVIDENCE.md).
  Confirm the operator-approved policy instead of treating engineering defaults
  as legal approval. Prepare harmless isolated checks locally; verify actual
  maintenance progress and alert delivery on the eventual authorized host.

  **Acceptance:** an archive is read back and its hash matches before eligible
  expiry; active holds survive ordinary expiry/erasure; missing/corrupt archives
  and failed captures fail visibly; no duplicate retention service is introduced.
  Restricted exports/hold administration stay deferred with the admin journeys.

### 6. Test-evidence access and preservation — before hosted test publication

- [ ] **Define protection and retention for test artifacts.** Include screenshots, traces, console/email captures, logs and any database/media snapshots. Preserve private originals and make only approved redacted/synthetic evidence available to the intended reviewers.

  **Finding:** [hosted strict-human artifacts](tfpphotographers/.github/workflows/strict-human-e2e.yml)
  currently have 14-day retention. Failed traces can contain request/session or
  entered-field details; preserving original attempts does not itself establish
  safe access or durable release-evidence retention. This is a missing acceptance
  check, not a finding that a credential was exposed by those artifacts.

  **Implementation plan:** review the actual uploaded paths and representative
  artifacts, their access audience and expiry. Select a proportionate evidence
  recovery window using existing storage/account capabilities. Keep test-proof
  retention separate from legal evidence retention. Produce sanitized review
  copies without overwriting original receipts; do not buy storage or change
  external retention policies as part of documentation work.

  **Acceptance:** published artifacts contain no unapproved real credentials,
  private data or provider payloads; authorized reviewers can retrieve the
  required source-bound release/failure evidence after ordinary CI expiry.

### 7. Actual public indexing — target SEO acceptance

- [ ] **Check public indexing behavior on the deployed candidate.** Verify the intended domain/canonical URLs, redirects, locale links, robots directives, sitemap contents and the treatment of private, pending, renamed and deleted resources.

  **Finding:** the optional hosted SEO/health configuration task did not spell out
  these application outcomes. [Sitemap generation](tfpphotographers/apps/web/src/pages/sitemap.xml.ts)
  depends on dynamic API reads, so an HTTP 200/static-only sitemap is insufficient
  evidence. Existing [sitemap/robots tests](tfpphotographers/apps/web/tests/utils/sitemap-robots.test.ts)
  remain useful lower-level proof.

  **Implementation plan:** reuse the SEO sentinel, canonical URL helpers and
  existing content creation/deletion journeys. Test actual published entries and
  exclusions without adding duplicate URL generation. Local assertions can be
  prepared now; real domain/edge verification needs an authorized target.

  **Acceptance:** the exact approved public resource is discoverable at its
  canonical location; private/pending/deleted resources are excluded as required;
  redirects/status/indexing directives agree. Do not close this from a skipped
  workflow, a green badge or a nonempty XML response alone.

### 8. UAT and host network prerequisites — before remote target work

- [ ] **Make the workspace security prerequisites explicit before UAT/production commissioning.** Verify restricted key-only inbound SSH, no direct root login, private service listeners and default denial of unauthorized outbound SSH to public TCP port 22, with only reviewed narrow exceptions.

  **Finding:** the original firewall/TLS item was too broad to carry the explicit
  requirements in [workspace deployment rules](RULES.md#deployment-rules).
  Before reconnecting a suspended or potentially compromised UAT host, those
  rules additionally require evidence preservation, outbound denial, reviewed
  credential remediation and a trusted rebuild when compromise cannot be excluded.

  **Implementation plan:** inspect existing host/provider controls before any
  authorized target run. Record the target's trusted state and the operator's
  recovery decision. Keep the existing credential-change deferral: this checkbox
  does not authorize rotation, reconnection, rebuild or deployment. Report the
  dependency if the prerequisites cannot be met under current authorization.

  **Acceptance:** retain redacted ingress/egress/private-listener observations
  and the recovery disposition where applicable; no target certificate is issued
  from an untrusted/unadmitted host or by bypassing its access checks.

<a id="execution-plan"></a>

## 🧭 7. Execution plan

This plan now has an implemented local batch; the linked report and tracker own
its actual results. Continue only incomplete acceptance work. The operator owns
legal approvals, scoped repository access, retention acceptance and go-live
authority. No production deployment is authorized.

1. **Reconcile scope before adding tests.** Work through section 6 item 1 using actual UI behavior and existing canonical cases, including the concrete public-user scenarios in section 8. Classify coverage and existing proof, preserve the admin/email deferrals and native Phase 2 boundary, and identify only genuinely missing assertions/branches. Decide the final supported web browser scope explicitly.
2. **Repair prerequisites and add the missing checks.** Address section 1's confirmed CI/performance-tool issues and dependency review dates. Extend existing tests/helpers for section 6 items 2–7 and the section 8 scenarios where evidence is missing; follow section 8's risk order and reuse instructions. Keep security/adversarial/concurrency tests at their appropriate layer; no duplicate storage, logging, upload or coverage implementation. Account bindings/credential changes still follow their separate authorization boundaries.
3. **Run focused local proof once per meaningful change.** Use fresh owned TEST/shadow resources and unused ports, restore retained checkout dependencies if needed, and check disk/provider readiness. Execute affected API/PostgreSQL/contract checks and strict human journeys across the supported browsers. Inspect actual UI captures, exact DB receipts, negative outcomes and diagnostics. Fix confirmed defects; preserve failed attempts and stop unchanged automatic retry loops.
4. **Freeze the final local candidate.** Review the complete scoped diff and affected consumers; run the required types/lint/build/guard/inventory and compatible lower-level proof. Plan one complete final member-browser matrix as described in section 2. Record the exact source, selected declarations, environment, zero-retry leaf totals and original receipts. Prior source-specific successes remain historical; do not splice them into a new certificate.
5. **Commission and verify targets only when authorized.** Meet section 6 item 8 first, then complete section 4's host/network/provider/backup work and the target-dependent security, maintenance and SEO checks. Keep the strict production doctor, same-source deployed identity and release verifier fail-closed. No production deployment, public Worker activation, account purchase or schedule installation is authorized now.
6. **Publish an evidence-based handoff.** Update the existing journey tracker and canonical case owners before checking release tasks complete. Report exact tested scope, unresolved failures, deferred admin/email cases, operator/legal inputs and host/device gaps. Full declared web certification remains unavailable while its required slots are omitted; any later decision to resume deferred work must be explicit. Final go-live remains an operator decision.

<a id="public-user-e2e-gaps"></a>

## 🌐 8. Public-user E2E reconciliation and implemented additions

**Scope:** anonymous visitors and ordinary authenticated members. Administrator
workspaces and delivered-email verification remain deferred. All eight confirmed
scenario additions/refinements below are implemented in existing owners/shared
helpers. Their actual per-browser results are in the journey tracker and batch
record. The baseline descriptions below preserve why the checks were added;
they are not claims that the new implementation is still missing.

The canonical ledger owns the seven new case IDs and extended existing contracts.
The admitted TEST seed owns historical paging prerequisites; human journeys do
not insert or repair database rows. Runtime and current-revision certification
remain distinct from authored coverage.

### 1. Anonymous homepage hero search submission

- [x] **Exercise the homepage search form itself.**

  **Completed local acceptance:** WEB-E2E-PUB-019/020/021; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** `WEB-E2E-PUB-001/002` in
  [public surfaces](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)
  checks that `#home-discovery-query` is visible, then submits the separate
  `/search` page form. The domain consent test types into the hero input but
  does not submit it. The homepage submission path remains unexercised in those
  checks; the existing search-results journey remains covered.

  **Acceptance contract:** submit the real
  [hero form](tfpphotographers/apps/web/src/components/DiscoverySearchForm.astro)
  using its button and keyboard Enter, with a unique query and a genuinely
  selected location. Assert the resulting query/coordinates, visible selected
  fields and exact expected public result, then verify Back/reload behavior.
  Reuse the existing search and location helpers and extend the relevant public
  search case instead of copying the workflow.

### 2. Member homepage activity metrics and recommendation navigation

- [x] **Verify the signed-in homepage's actual data and destinations.**

  **Completed local acceptance:** WEB-E2E-PUB-033 + WEB-E2E-MSG-010; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** the older
  [public-surface domain suite](tfpphotographers/tests/e2e/domains/discovery/tests/public-surface-boundaries.spec.ts)
  verifies the guest/member layout transition, four activity links, reload and
  logout. It does not establish exact metric values or click the recommendation
  destinations. No corresponding strict-human homepage activity journey was
  found. [Loader unit tests](tfpphotographers/apps/web/tests/utils/home-activity-loader.test.ts)
  cover parsing, not a live member journey.

  **Acceptance contract:** use a new member and real visible applications/RSVP/message
  actions to establish known state; verify the resulting
  [activity metrics](tfpphotographers/apps/web/src/components/home/YourCreativeActivity.astro),
  summary-link destinations and exact
  [recommended-item links](tfpphotographers/apps/web/src/components/home/RecommendedForYou.astro).
  Check empty and populated member states, reload persistence and the logout
  return to the guest layout. Reuse the domain assertions through strict helpers;
  do not fabricate recommendations or assert values by echoing the same API
  response that rendered the UI. Add a separately mapped member case where the
  current anonymous-only case contract does not fit.

### 3. Public/member paths bundled with deferred admin declarations

- [x] **Separate the public proof from the still-deferred administrator phases.**

  **Completed local acceptance:** WEB-E2E-PUB-031 + WEB-E2E-REP-008; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** `WEB-E2E-PUB-016` combines anonymous member-route gates
  and member Create Hub controls with admin/QA route checks in
  [route access](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts).
  `WEB-E2E-REP-003` combines anonymous/authenticated standalone reporting with
  administrator queue readback in
  [collaboration workflows](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts).
  Both whole declarations are currently deferred. Other selected tests prove
  some individual gates and modal reporting, but not these complete public paths.
  An older [Create Hub domain journey](tfpphotographers/tests/e2e/domains/navigation/tests/create-hub-navigation.spec.ts)
  also exists; it is not a current strict-human result.

  **Acceptance contract:** review the case contracts and split/re-map the public and
  privileged requirements without dropping any existing admin assertion. Cover
  anonymous access to the enumerated member routes with safe return paths;
  ordinary-member Create Hub choices, close/reopen and keyboard focus; and the
  actual standalone `/report` form, its exact saved report and independent
  member-visible retrieval/duplicate behavior. Use the shared read-only report
  checkpoint in place of an admin visit only in the separately defined member
  contract. Keep the admin readback contract deferred and do not mark either
  original combined case fully proven from a public-only subset. Authentication
  may use the existing admitted TEST bridge; this proves no email delivery.

### 4. Anonymous language/region persistence and unavailable-region recovery

- [x] **Complete the public preference round trip and recovery navigation.**

  **Completed local acceptance:** WEB-E2E-PUB-032; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** `WEB-E2E-PUB-026` verifies an authenticated Arabic/IN
  picker change through event publication and search. The older
  [locale preference journey](tfpphotographers/tests/e2e/domains/localization/tests/locale-preference-persistence.spec.ts)
  covers public preference selection but later injects API-authenticated cookies;
  [routing hardening](tfpphotographers/tests/e2e/domains/localization/tests/locale-routing-hardening.spec.ts)
  uses request-level checks for invalid locales/regions. Strict-human
  `WEB-E2E-PUB-013` visits the region-unavailable document directly and checks its
  rendering rather than the complete incoming URL and recovery path.

  **Acceptance contract:** as a guest, use the real language/region picker to select a
  different supported pair, preserve the current search/detail query, reload
  and navigate to another page to verify persistence. Exercise Cancel without
  changing preferences. Visit an unsupported-region URL, observe its controlled
  redirect and click the actual recovery link to a supported public page.
  Reuse the locale form/router owners. Keep the already-covered Arabic draft
  preservation behavior and social-provider/email exclusions unchanged.

### 5. Disabled OAuth callback routes

- [x] **Visit each disabled callback path in the browser.**

  **Completed local acceptance:** WEB-E2E-PUB-015; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** `WEB-E2E-PUB-015` declares the Apple/Google/Meta entry
  and callback routes, but its actual loop visits only `/auth/apple`,
  `/auth/google` and `/auth/meta`. The three callback pages dispatch a different
  [completion path](tfpphotographers/apps/web/src/utils/oauth.ts).

  **Acceptance contract:** extend the existing disabled-provider case with the actual
  callback URLs, including missing-state and provider-error inputs. Assert the
  expected local login/error state, visible email control and absence of an
  authenticated or external-provider transition. Do not enable social login,
  exchange real provider credentials or request an OTP. Preserve historical
  entry-route passes at their original scope.

### 6. Generic error-page recovery controls and 500 indexing policy

- [x] **Activate the generic error document's recovery links.**

  **Completed local acceptance:** WEB-E2E-PUB-014; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** `WEB-E2E-PUB-014` checks a missing route's 404/noindex
  and the controlled 500 document's status/content/title. Its current contract
  does not require 500 indexing assertions or clicking the generic recovery
  controls. The separate non-existent-profile test already clicks its Search
  recovery link; that is covered and should not be duplicated as a new gap.

  **Acceptance contract:** extend the controlled-document journey to verify the
  [500 page](tfpphotographers/apps/web/src/pages/500.astro)'s noindex header/meta
  policy, activate its Retry link and verify the same intended path/query, then
  activate its Home link and confirm a healthy localized public page. Use the
  shared [ErrorCard](tfpphotographers/apps/web/src/components/ErrorCard.astro)
  and real links. The deliberately controlled `/500` page should remain a 500
  when retried; do not manufacture an HTTP 200 or confuse that with recovery of
  a transient upstream outage, which belongs to section 6 item 4.

### 7. Owner activity application/entry pagination

- [x] **Guarantee actual page-boundary coverage for owner Applications/Entries.**

  **Completed local acceptance:** WEB-E2E-PRO-014; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved. Paging uses the admitted canonical historical TEST seed (21 applications/entries), not DB writes or an admin visit inside the human journey; this does not prove 21 new moderations/uploads.

  **Original coverage:** `WEB-E2E-PRO-007` switches Applications/Entries and
  reloads the selected tab. The older
  [profile contract suite](tfpphotographers/tests/e2e/domains/profile/tests/profile-contract-boundaries.spec.ts)
  queries activity/pagination through APIs. The
  [profile renderer](tfpphotographers/apps/web/src/pages/profile/[username].astro)
  supplies separate per-tab page links. Existing creator/duplicate-submission
  journeys already traverse owner **Posts** pages to count exact saved records;
  Posts must not be described as untested.

  **Acceptance contract:** extend the relevant owner activity case/helper with
  reachable, UI-created data that spans a real page boundary for the remaining
  tab types. Click Next/Previous, verify the exact expected items are neither
  lost nor duplicated, preserve the selected tab through reload and keep guest
  owner-only visibility restrictions. Respect actual quotas and seeded-fixture
  ownership; record a concrete fixture/policy blocker instead of inserting DB
  rows or weakening quotas. Contest-entry fixture work must not reopen deferred
  administrator content-management journeys.

### 8. Filtered discovery pagination with a controlled multi-page result set

- [x] **Make the pagination outcome discriminating and independent of incidental data volume.**

  **Completed local acceptance:** WEB-E2E-PUB-034; all three web browser slots have actual passing evidence in the [readiness journey table](human-like-flow-pending.md#readiness-batch-20261120). Original failures/source identities are preserved.

  **Original coverage:** public search already verifies exact creator identity,
  actual role/sort results and browser Back. The helper in
  [public surfaces](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)
  can traverse listing pages while locating particular event/opportunity titles,
  but it can finish on page one. This is partial pagination coverage, not an
  absence of all paging code/tests. Explicit opportunity/event gallery paging
  and message-history paging also already have their own covered journeys.

  **Acceptance contract:** extend the existing discovery cases/shared traversal
  helper with a known, lawful public result set spanning at least two visible
  pages. Keep role/type/location/sort parameters through Next/Previous, assert
  exact disjoint page identities and the expected total/order, then return from
  a selected detail and reload. Derive fixture size from the actual page limit
  and use real UI setup or the admitted canonical seed; no DB writes inside
  the human journey and no fabricated search response.

### Reuse, execution order and existing exclusions

Implement the public-only access/report contracts and disabled callbacks first
(items 3 and 5), then the hero/locale round trips (1 and 4), member homepage (2),
controlled page-boundary scenarios (7 and 8), and generic error controls (6).
Use focused tests while changing each owner, then include completed additions
in the single planned frozen-source member matrix from section 7. Run the
supported Chromium, Firefox and responsive Chromium projects with zero retries;
attach actual leaf results, UI evidence and exact DB receipts where persistence
is part of the scenario. Actual source-specific passing leaves, retained original failures and zero-retry totals are recorded separately; no full release certificate is inferred.

The separately implemented device-location permission/fallback journey is recorded in
section 6 item 3; it is not counted again as a ninth new checkbox here. Existing
grievance/privacy submission, consent persistence, nearest-first autocomplete,
saved maps, public gallery identity/paging, profile reporting, message history,
stale-permission and upload recovery checks retain their recorded coverage.
Delivered OTP/quiet-hours email, administrator UI and native mobile remain
deferred. Do not expand them or add duplicate cases to increase a coverage count.

## 🛡️ Execution rules and checklist maintenance

- Use real visible controls, shared workflow helpers and the existing typed exact-value/read-only DB checks. No forced clicks, business API shortcuts, DB repair inside human tests, intercepted fake responses or manufactured moderation approvals.
- Preserve existing databases, media, holds, original failures and source-bound receipts. Use only newly provisioned owned TEST/shadow data for destructive local runners; snapshot each completed run before reusing its fixture.
- Complete a checkbox only with its actual command/source, runtime/target, passed/failed/skipped/retry totals and original receipt link. A scoped success closes only its scope. Keep unrelated work untouched.
- Native Expo/iOS/Android, store signing and native profiling remain Phase 2. Admin/email remain explicitly deferred until the user changes that decision. No purchases, credential changes, production deployment or public Worker activation follow from this checklist.

**Historical validation of the original checklist:** reconciled the ledger with all 121
parsed executable test blocks and the 93 + 8 + 20 tracker groups; checked the live
read-only production doctor and GitHub secret-name/job metadata; inspected the
affected workflow/auth/performance source. No app services were restarted, no
tests/deployments dispatched, and no provider/credential settings changed.

**Historical follow-up review:** the strict-human guard and generated
inventory check passed during the read-only review. That edit recorded the eight
findings and execution plan without changing application/test behavior or any
recorded pass/fail status. Local Markdown links, finding/task counts, source
references and scoped whitespace are checked before publication. No new browser
or API execution, deployment or provider change is claimed for this doc edit.

**Historical public-user review:** compared the named public/member source branches with
strict-human and relevant older domain/API test bodies, preserving the coverage
distinctions above. The strict-human guard and inventory check passed; the
canonical count at that review was 200 cases / 121 declarations / 28 specs. That plan added
eight initially unchecked scenario tasks without editing executable tests, the ledger,
existing run receipts or any provider configuration. No app service restart,
browser journey execution or deployment occurred for this documentation update.
