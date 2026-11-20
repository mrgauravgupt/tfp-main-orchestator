# ✅ TFP Web — readiness and pending verification checklist

**Reviewed: 20 November 2026 (IST). Phase 1: web. Phase 2: native mobile.**

This is the work checklist for a defensible web release, not a promise of zero
future bugs. It separates confirmed tooling/configuration problems, uncompleted
verification, operator-deferred work and host commissioning. An unchecked item
does not automatically mean the corresponding product feature is broken.

## 📍 Ownership and current evidence

- **Business requirements and implementation status:** the [canonical use-case ledger](tfpphotographers/tests/e2e/human/use-case-coverage.json).
- **Per-journey execution status, deferred titles and original attempts:** [human-like-flow-pending.md](human-like-flow-pending.md).
- **Providers, secure configuration and operator inputs:** the [provider inventory](tfpphotographers/docs/operations/PROVIDER_AND_SERVICE_INVENTORY.md).
- **This file:** remaining release tasks and acceptance evidence. It does not replace those owners or maintain another set of per-case pass/fail results. Update the journey tracker first when a flow completes, then link its actual receipt here.

The source inspected was product `73c4267d697219a07f2099e140d6bb0ae0272ac0`;
the latest application/test change is `b2894753b642f95e1dd61ddc073416e84f81e1cf`.
The intervening product commit changes documentation only.

| Current fact | Verified boundary |
| --- | --- |
| 200 canonical cases | 193 marked implemented; 7 delivered-email cases blocked. Implementation status is not a runtime pass. |
| 121 executable journey groups in 28 specs | All reconcile to the existing tracker: 93 remaining groups, 8 previously covered groups and 20 operator-deferred admin/mixed-admin groups. No unclassified declaration was found in this reconciliation. |
| Earlier member journeys | The 93-group matrix has passing source-specific evidence per browser; 8 earlier groups retain their prior evidence. This is not a single complete current-revision run. |
| Latest reporting fix | 12/12 selected executions passed on the same application candidate: four each in Chromium, Firefox and responsive Chromium, zero retries; six exact DB receipts and 144 retained captures. See the [reporting record](tfpphotographers/docs/operations/MOBILE_REPORT_CLICK_FIX_2026_11_20.md). |
| Latest affected local validation | 919 web tests, 9 PostgreSQL persistence methods, 202 safe harness checks, types, lint and build passed at their recorded scopes. |
| Production configuration | The local read-only strict doctor was rerun for this checklist: exit 1, exactly 12 unresolved settings, listed below. This is not an observation of a deployed host. |

**Do not reopen completed work as missing:** B2 media roles/private backup bucket,
backup completion/pruning/restore fixtures, Cloudflare operator access, Axiom UAT
repair, monitoring ingestion and shared upload/storage URL ownership already have
documented proof. Their future host activation remains separate. Existing email
is Resend; no SES adapter, new paid plan or replacement provider is required here.

## 🔧 1. Confirmed work we can address before buying a host

- [ ] **Repair moderation/autofix CI database setup.** The [retained CI run](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/44353597837) stopped before regression tests because the database bootstrap tried admin role `postgres`, while its service is configured with `tfp_user`. Align the existing canonical admin/owner/password bindings in [the workflow](tfpphotographers/.github/workflows/moderation-autofix-regression.yml) with [database provisioning](tfpphotographers/scripts/db/ensure-env-database.sh). Acceptance: an isolated CI database is provisioned and actual regression methods execute; a typecheck/catalog-only pass does not close this.
- [ ] **Bind existing CI access securely.** Repository-level Actions secret-name metadata currently lists only `TFP_CI_OPENROUTER_API_KEY`. The current [strict-human workflow](tfpphotographers/.github/workflows/strict-human-e2e.yml) also requires `GEOAPIFY_API_KEY` and `TFP_CROSS_REPO_READ_TOKEN`. Reuse the existing provider key and approved private-repository access; inspect organization/environment scope before requesting any new credential. Also verify secret visibility for the admitted PR/workflow context: the older [CI run](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/44353597786) failed its secret preflight before browser execution. Acceptance: real auxiliary checkouts and browser methods execute, with the guard intact.
- [ ] **Resolve the unsupported Dependency Review CI action without buying a plan.** The [job in the retained security run](https://github.com/mrgauravgupt/tfpphotographers.com/actions/runs/44353597780) reported that dependency review was unsupported for this repository. Confirm available account features and select a supported free check or documented equivalent using existing audits. Keep dependency/security enforcement; do not silently remove it or purchase GitHub security features.
- [ ] **Update authenticated performance measurement to the existing OTP flow.** [The measurement helper](tfpphotographers/scripts/qa/page-performance-report.mjs) still posts email/password to `/auth/login`; [the API](tfpphotographers/apps/api/src/modules/auth/auth.routes.ts) registers that legacy endpoint only under `NODE_ENV === 'test'`. Public anonymous measurements remain usable; authenticated production-like measurement needs the existing supported session/OTP path, bounded redacted failures and a regression check. Do not add a production password endpoint or bypass authentication.
- [ ] **Review the dated dependency safeguards before launch or expiry.** [The checked-in policy](tfpphotographers/scripts/security/local-patch-policy.json) expires Deepmerge review on **24 November 2026** and Picomatch review on **2 December 2026**. Review upstream fixes and rerun installed-byte safeguards plus the production audit on the final candidate. Do not extend dates or add blanket advisory exceptions just to pass.

These are verification/tooling/configuration tasks, not evidence of a newly found
member-facing production outage. The referenced hosted runs are from 18 November
on older source `221cd70d4c11783b2424e48b6f4c2cd1af664772`; they are not runs of the
latest reporting candidate. Current workflow/source inspection confirms the
remaining setup paths described above.

## 🧪 2. Pending human-like E2E and final-source proof

### Member web journeys and exact persistence

- [ ] **Define the final Phase 1 acceptance scope explicitly.** Chromium, Firefox and responsive Chromium are the current executable projects. `mobile-chromium` is web emulation, not an Expo/iOS/Android result. Keep the admin/email exclusions visible; do not describe this excluded scope as every web case tested.
- [ ] **Freeze the intended release source and assemble compatible lower-level/API proof.** The latest nine-method PostgreSQL receipt is a selected prerequisite, not the full required-PostgreSQL/API certificate. Use the existing source-bound proof owner; no restamping old results.
- [ ] **When final sign-off is requested, obtain the missing complete current-source member matrix.** Earlier successful member journeys span several sources and scoped reruns. Use one planned final pass on a clean isolated TEST target, with zero retries and exact selected titles. Do not repeatedly replay completed suites during ordinary fixes. Any later failed-only result must retain the original failure and its actual source.
- [ ] **Reconcile persisted postconditions with the right evidence.** Reuse [the typed read-only verification port](tfpphotographers/scripts/qa/support/persistence-contract.ts) and visible reload/independent readback. It already covers profiles/location, content, messages, applications, saved searches, reviews, media, holds, erasure and reports. Audit important saved fields against their test assertions and add checks only for confirmed gaps; do not assume every DB column or every form field already has an exact-value checkpoint.
- [ ] **Investigate a recurrence of the remaining location/SRI watch items before changing code.** The [original Firefox failures and separate passes](tfpphotographers/docs/operations/REMAINING_HUMAN_E2E_2026_11_19.md) remain preserved. They are observations, not diagnosed open product bugs. Keep genuine location results and script integrity checks; no manufactured coordinates, error suppression or automatic retry loop.

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

- [ ] **After an explicitly authorized UAT release, verify the declared deployed-target slots.** Match source, registry hashes, actual deployed identity, API prerequisites and original child manifests. The current ledger declares 193 implemented local cases and 161 implemented target cases; use its per-case profiles rather than inventing an identical cross-product for every case.
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

## 🛡️ Execution rules and checklist maintenance

- Use real visible controls, shared workflow helpers and the existing typed exact-value/read-only DB checks. No forced clicks, business API shortcuts, DB repair inside human tests, intercepted fake responses or manufactured moderation approvals.
- Preserve existing databases, media, holds, original failures and source-bound receipts. Use only newly provisioned owned TEST/shadow data for destructive local runners; snapshot each completed run before reusing its fixture.
- Complete a checkbox only with its actual command/source, runtime/target, passed/failed/skipped/retry totals and original receipt link. A scoped success closes only its scope. Keep unrelated work untouched.
- Native Expo/iOS/Android, store signing and native profiling remain Phase 2. Admin/email remain explicitly deferred until the user changes that decision. No purchases, credential changes, production deployment or public Worker activation follow from this checklist.

**Validation of this documentation update:** reconciled the ledger with all 121
parsed executable test blocks and the 93 + 8 + 20 tracker groups; checked the live
read-only production doctor and GitHub secret-name/job metadata; inspected the
affected workflow/auth/performance source. No app services were restarted, no
tests/deployments dispatched, and no provider/credential settings changed.
