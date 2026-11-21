# Human-like E2E flow tracker

Updated: 21 November 2026. The original matrix was reconciled on 19 November 2026 at 23:55:58 IST.

For pending release tasks, CI/tooling fixes, the twelve production settings and
host commissioning, use the [web readiness checklist](web-readiness-checklist.md).
This file continues to own the source-specific journey execution record; the
canonical use-case ledger continues to own requirements and implementation status.

<!-- local-policy-timezones:start -->
<a id="local-policy-timezones-20261121"></a>
## ✅ Event venue dates, exact zones and shared controls — 21 November

Only the expanded existing `WEB-E2E-EVT-015` journey was selected. Frozen source
`a93f26f7a7039fb0a03e85d12206062857b16f5f` passed **3/3 browser leaves**, with
**six exact read-only DB receipts and 54 captures**, zero failures/skips/retries.

| Existing journey | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| Rich event edit, exact UTC/venue-zone readback, replacement image pixels, fee removal, independent US-market detail/search date and shared button/modal focus | ✅ Passed | ✅ Passed | ✅ Passed |

The selected reader has an explicit New York browser timezone. The midnight
Mumbai fixture exposes the previous calendar-day error. Initial source
`f085ae3fb` failed in all three browsers because the provider/form path dropped
the zone; original results and post-run snapshots remain intact. The correction
retains the existing provider field and event interpretation zone rather than
weakening assertions or changing moderation. No admin page/action was tested;
the seeded admin identity is only the content owner in the existing helper.

Evidence: `/private/tmp/tfp-web-local-gates-20261121-_hqvzbpi`.
`local-gates-browser-reconciliation.json` binds actual children, frozen contexts,
hashes, captures, DB receipts and `api-proof-local-gates-a2/executed-api.json`
(55 selected API/PostgreSQL methods). Passing diagnostic arrays are empty; all
captures fit their recorded widths. Unselected lower-level admin sources remain
`not-run`. Original harness/type attempts and the failed-source API proof remain
separate; no full suite or release certificate is inferred.

The [implementation/results record](tfpphotographers/docs/operations/WEB_LOCAL_POLICY_AND_TIMEZONES_2026_11_21.md)
documents shared Origin/calendar fixes, DST instant preservation, location
metadata and token cleanup. Owned services/PG15565 are stopped; six browser
snapshots, three final DB dumps, cluster data and all evidence remain. Only the
owned checkout's rebuildable root dependencies were removed after reconciliation;
restore them before replay. Manual 3000/4000 retain their listeners and HTTP 200.
Admin/email, native Phase 2, broader acceptance and host/operator gates remain
deferred. No deployment, provider account change or purchase occurred.
<!-- local-policy-timezones:end -->

<!-- storage-url-safety:start -->
## Storage URL privacy follow-up — 21 November 2026

Only these two affected existing journeys were selected on frozen product
`0230bf24c`. All six leaves passed with zero failures, skips or retries. The
actual total is **15 exact read-only DB receipts and 54 captures**. The canonical
context/API-proof checks passed for each child; admin lower-level sources remain
`not-run` under the exclusion, so this is not a full release certificate.

| Existing journey | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| WEB-E2E-CON-020 — exact saved resource key and identical reference download before/after visible logout | ✅ Passed | ✅ Passed | ✅ Passed |
| WEB-E2E-OPP-028 — rich edit, exact replacement moodboard key/pixels, public URL privacy and retained deletion readback | ✅ Passed | ✅ Passed | ✅ Passed |

Evidence root: `/private/tmp/tfp-storage-url-safety-20261121-o4p48ogt`.
`storage-browser-reconciliation.json` binds actual children, source/context hashes,
DB checkpoints and captures. The selected 42-method upload/persistence/evidence
proof is `api-proof-url-safety-a2/executed-api.json`. The preceding source-specific
proof and all original setup/typing attempts remain preserved.

The later sign-in style cleanup at `5e50c465b` has **three separate compiled-app
UI checks** for palette, hover, keyboard/modal focus and overflow. It removed
duplicate CSS and reused Button/design tokens; it did not replay these business
journeys or turn their older source into a new full-source certificate. See
[the source/results record](tfpphotographers/docs/operations/STORAGE_URL_PRIVACY_REVIEW_2026_11_21.md).
Admin/email stay deferred, native remains Phase 2, existing data/evidence and
manual 3000/4000 are preserved, and no deployment occurred.
Owned previews and PostgreSQL 15564 are stopped. Three browser DB/media snapshots,
two final DB dumps and the cluster data directory remain retained; manual health
checks returned HTTP 200. `owned-final-cleanup.json` records the exact scope.
<!-- storage-url-safety:end -->

<!-- affected-final-selection:start -->
## ✅ Final affected selection — 57 passing source-specific slots

**Completed:** 19 existing journey groups in Chromium, Firefox and mobile Chromium; **87 exact read-only DB receipts, 540 captures and zero Playwright retries**. No console/page/request/server errors or missing expected responses occur in the selected passing leaves. The operator requested implementation first and affected checks only; the full suite remains cancelled.

**Sources:** 54 selected slots use `ae7bf606d`; the three avatar/cover/portfolio slots use the one-file test-only correction `4f6504962`. These are compatible source-specific results, not a same-source full-release certificate. The 60 actual affected executions comprise 59 passes and one retained original Firefox failure; older successful profile leaves are not counted twice.

| Browser | Passing selected slots | Exact DB receipts | Captures |
| --- | ---: | ---: | ---: |
| Chromium | 19 | 29 | 180 |
| Firefox | 19 | 29 | 180 |
| Mobile Chromium | 19 | 29 | 180 |

| Journey / canonical cases | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| [validates budget and deadline constraints and prevents duplicate opportunity creation](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts)<br>WEB-E2E-OPP-019 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [creates, edits, verifies and deletes an opportunity through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-OPP-004, WEB-E2E-OPP-018, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [creates, edits, verifies and deletes an event through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-EVT-004, WEB-E2E-EVT-010, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [creates, edits, verifies and deletes a contest through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-CON-004, WEB-E2E-CON-015, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [persists richer opportunity edits and moodboard replacement then removes old and new public discovery from an independent visitor](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-028 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [rejects stale applications after naturally elapsed legal dates or closure of all roles and persists zero applications](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-031 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [moves an RSVP through Going, Interested and Not Going states](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-005, WEB-E2E-EVT-009 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [pages thirteen owner photos to the exact oldest image, lightbox and image report](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-014 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [persists a rich event revision and clears fees through edit and independent public readback](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-015 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [removes a renamed event from anonymous details and exact public search after visible deletion](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-016 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [persists rich contest edits and confirms deletion across public canonical and legacy URLs](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-025 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [uploads avatar, cover and portfolio media, validates files and deletes a portfolio item](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-001, WEB-E2E-PRO-002, WEB-E2E-PRO-003 | ✅ Passed (`4f6504962`) | ✅ Passed (`4f6504962`) | ✅ Passed (`4f6504962`) |
| [creates, updates and deletes an opportunity saved search through visible controls](tfpphotographers/tests/e2e/human/saved-search-lifecycle.human.spec.ts)<br>WEB-E2E-SRCH-001 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [uploads role-tagged portfolio photos and verifies public lightbox navigation and exact image reporting](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts)<br>WEB-E2E-PRO-011 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [pages exactly thirteen approved opportunity owner photos with independent public identity readback](tfpphotographers/tests/e2e/human/gallery-pagination.human.spec.ts)<br>WEB-E2E-OPP-029 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [saved-search plain HTML forms persist create edit and delete without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts)<br>WEB-E2E-SRCH-003 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [crosses real owner applications and entries page boundaries without missing or repeated records](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-014 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [preserves real location role and sort filters across two guaranteed discovery pages](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-034 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |
| [updates exact member homepage counters through real applications entries and RSVPs and follows recommendations](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-033 | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) | ✅ Passed (`ae7bf606d`) |

Evidence: `selected-context-verification.json` and `selected-affected-evidence-reconciliation.json` under `/private/tmp/tfp-web-full-member-20261121-ce12sbpp`. Sources, original failures, commands and limits are in the [exact-readback record](tfpphotographers/docs/operations/WEB_MEMBER_EXACT_READBACK_2026_11_21.md). Owned app services/PostgreSQL are stopped; seven DB dumps and seven media snapshots are retained. Manual FE3000/API4000 remain healthy. Admin/email, native Phase 2 and broader release/host gates remain deferred. No deployment.
<!-- affected-final-selection:end -->

<!-- avatar-readiness-recovery:start -->
## One-journey readiness recovery — completed

**Frozen test-only correction:** `4f65049628d6a7bc762bc14b51a6f08b841fca06`. Only `profile-portfolio.human.spec.ts` changed from the 19-journey candidate. The same bounded wait now requires actual avatar and cover content to match, so a processing placeholder cannot satisfy readiness. Pixel tolerance, moderation and application code are unchanged.

| Browser | Actual recovery result |
| --- | --- |
| Chromium | ✅ One passed; zero retries |
| Firefox | ✅ One passed; zero retries |
| Mobile Chromium | ✅ One passed; zero retries |

Only this journey was rerun. Original Firefox failure and all prior child reports remain unchanged. API/build suites were not replayed for this test-only correction; the 65-method API proof retains its original source. All six affected/recovery contexts and the selected evidence have reconciled.
<!-- avatar-readiness-recovery:end -->

<!-- exact-member-run:start -->
## Superseded full run — 21 November 2026

**Original candidate:** `ca03551d73bf0acdb84f75ba9774e13a6b806117`. The operator subsequently requested **implement first, then affected checks only; no complete-suite rerun**. The owned Chromium run was gracefully interrupted and further full-browser runs were cancelled.

**Actual original results:** 96 passed, 10 failed (including three timed-out leaves), one interrupted and one not run. Firefox/mobile Chromium were not started. The original report, failures, source contexts, DB dump and media snapshot are preserved; no final-source full matrix is claimed.

| Browser | Passed | Failed / timed out | Interrupted | Not run |
| --- | ---: | ---: | ---: | ---: |
| chromium | 96 | 10 | 1 | 1 |
| firefox | 0 | 0 | 0 | 108 |
| mobile-chromium | 0 | 0 | 0 | 108 |

| Journey / canonical cases | Original Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| [submits and retrieves a grievance case through visible controls](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts)<br>WEB-E2E-LEG-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [rejects another legal receipt token and retrieves each case after reload](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts)<br>WEB-E2E-LEG-002 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [submits and retrieves a privacy case through visible controls](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts)<br>WEB-E2E-LEG-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists optional analytics consent and lets the visitor change it through the privacy page](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts)<br>WEB-E2E-LEG-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [searches isolated creators and verifies role filtering, actual sort order and return navigation](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-019, WEB-E2E-PUB-020, WEB-E2E-PUB-021 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [discovers the platform, searches, and follows primary navigation](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-001, WEB-E2E-PUB-002, WEB-E2E-PUB-004 | ❌ Timed out | ⏳ Not run | ⏳ Not run |
| [applies and clears discovery type, role, location and sort filters through visible controls](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [renders legal, localized, responsive, accessible and SEO surfaces](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-005, WEB-E2E-PUB-006, WEB-E2E-PUB-007, WEB-E2E-PUB-008, WEB-E2E-PUB-009 | ❌ Timed out | ⏳ Not run | ⏳ Not run |
| [renders dedicated empty state and quick searches for zero-result query](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-018 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [activates empty-state quick searches and opens the advertised filtered discovery](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-025 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [filters creators by multiple facets on directory and verifies facet tags](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-022 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [executes coordinate geo search with radius expansion link and malformed coordinate fallback](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-023 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [filters opportunity and event listings by work mode](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-024 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [creates opportunity, event, and contest content and opens their edit forms](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts)<br>WEB-E2E-OPP-002, WEB-E2E-EVT-002, WEB-E2E-CON-002, WEB-E2E-OPP-001, WEB-E2E-EVT-001, WEB-E2E-CON-001, WEB-E2E-MOD-001, WEB-E2E-MED-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [validates budget and deadline constraints and prevents duplicate opportunity creation](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts)<br>WEB-E2E-OPP-019 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [completes a directed quick request from invitation through review](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-001, WEB-E2E-QR-002, WEB-E2E-QR-003, WEB-E2E-QR-004, WEB-E2E-QR-005, WEB-E2E-QR-011, WEB-E2E-QR-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists invitation decline and requester cancellation states](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-006 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [shows precise browser validation for an invalid quick request](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-007 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists invitation decline state when creative declines request](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-009 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [pre-fills recipient creative context when navigating from creator profile CTA](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-010 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [validates inverted budget range and creates paid quick request with explicit currency terms](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-012 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [expands creative invitations from quick request detail view](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts)<br>WEB-E2E-QR-014 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [redirects an existing authenticated session away from login](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-AUTH-013 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [protects private routes and uses only the OTP bridge for authentication](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-AUTH-004, WEB-E2E-AUTH-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [completes new creator onboarding through the visible signup form](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-AUTH-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [edits profile details and persists contact links, location and availability settings](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-AUTH-005 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [edits a profile, uploads real media, and revokes both browser sessions through visible logout](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-AUTH-006, WEB-E2E-AUTH-007 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists professional metadata, secondary roles, specialties, experience and service area](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-PRO-005 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [edits per-role preferences and verifies role visibility filtering for guest viewers](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts)<br>WEB-E2E-PRO-006 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [completes collaboration, participation, messaging, notification and reporting flows](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts)<br>WEB-E2E-OPP-003, WEB-E2E-EVT-003, WEB-E2E-CON-003, WEB-E2E-MSG-001, WEB-E2E-NOTIF-001, WEB-E2E-REP-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [shows duplicate report warning when member reports already-reported content](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts)<br>WEB-E2E-REP-002 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [submits customer report across entities and verifies moderation submission feedback](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts)<br>WEB-E2E-REP-004 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [creates, edits, verifies and deletes an opportunity through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-OPP-004, WEB-E2E-OPP-018, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [creates, edits, verifies and deletes an event through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-EVT-004, WEB-E2E-EVT-010, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [creates, edits, verifies and deletes a contest through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-CON-004, WEB-E2E-CON-015, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [validates event text length and creates in-person event with entry fee](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-EVT-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [completes the opportunity application, owner decision, workspace and withdrawal lifecycle](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-005, WEB-E2E-OPP-006, WEB-E2E-OPP-007, WEB-E2E-OPP-009, WEB-E2E-OPP-012, WEB-E2E-OPP-013, WEB-E2E-OPP-014, WEB-E2E-OPP-015 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [allows an owner to reject an application and persists that decision for the applicant](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [enforces application consent, reapplication and a stale withdrawal after selection](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-010, WEB-E2E-OPP-011, WEB-E2E-OPP-016, WEB-E2E-OPP-017 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [toggles opportunity role status and dynamically updates applicant eligibility](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-020 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [downloads an exact persisted opportunity workspace attachment for owner and selected participant](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-021 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [uploads and opens an exact persisted opportunity public gallery photo with eligibility gates](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-022 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [preserves selected applications, closed roles, metadata and exact workspace delivery through owner edits](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-023 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [keeps multi-role applications, withdrawals and owner decisions independent with selected team credits](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-024 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [rejects empty and invalid workspace submissions then persists note-only and exact file-only delivery](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-025 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [revokes workspace and public-upload access after selection is rejected and denies the stale delivery form](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-026 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [allows a selected participant public photo and persists exact public pixels and image-report dismissal and duplicate fencing](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-027 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists richer opportunity edits and moodboard replacement then removes old and new public discovery from an independent visitor](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-028 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [rejects the exact stale role application after an independent owner closes it without affecting another open role](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-030 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [rejects stale applications after naturally elapsed legal dates or closure of all roles and persists zero applications](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-031 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [moves an RSVP through Going, Interested and Not Going states](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-005, WEB-E2E-EVT-009 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [validates required title and selected entry fee amounts in event creation](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-006 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [rejects event creation when the event date is set in the past](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-007 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [uploads an owner photo through the event gallery after the event starts](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [prevents event organizer self-RSVP and denies participation to closed events](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-012 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [enforces event photo gallery attendance prerequisites and pre-start submission locks](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-013 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [pages thirteen owner photos to the exact oldest image, lightbox and image report](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-014 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists a rich event revision and clears fees through edit and independent public readback](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-015 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [removes a renamed event from anonymous details and exact public search after visible deletion](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-016 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [rejects stale RSVP change and removal after the owner closes the event without altering attendance](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-017 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [allows an Interested attendee photo and denies a Not Going attendee after start](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-018 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [discovers the exact event and contacts its organizer while protecting editing from nonowners](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-020 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [rejects an empty contest submission at the browser boundary](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [prevents participant self-reaction and enforces single vote per contest](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-018 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [enforces contest lifecycle submission locks during judging phase](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-019 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [downloads the exact contest reference image through its visible resource control](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-020 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists directory reactions, cancels voting and shares the exact public entry](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-021, WEB-E2E-CON-022 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists rich contest edits and confirms deletion across public canonical and legacy URLs](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-025 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [uploads avatar, cover and portfolio media, validates files and deletes a portfolio item](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-001, WEB-E2E-PRO-002, WEB-E2E-PRO-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [handles non-existent user profile requests with a controlled 404 response](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-004 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [traverses owner profile activity tabs and verifies persisted tab selection](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-007 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [displays portfolio upload capacity quota and enforces required file selection](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [delivers a two-party message, marks it read, replies and persists notification preferences](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts)<br>WEB-E2E-MSG-002, WEB-E2E-MSG-003, WEB-E2E-MSG-004, WEB-E2E-MSG-009, WEB-E2E-NOTIF-002, WEB-E2E-NOTIF-003, WEB-E2E-NOTIF-004 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [blocks and unblocks a conversation partner through messaging safety controls](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts)<br>WEB-E2E-MSG-005, WEB-E2E-MSG-006, WEB-E2E-MSG-007, WEB-E2E-MSG-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [filters notification feed by category and navigates to target deep link](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts)<br>WEB-E2E-NOTIF-005 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [creates, updates and deletes an opportunity saved search through visible controls](tfpphotographers/tests/e2e/human/saved-search-lifecycle.human.spec.ts)<br>WEB-E2E-SRCH-001 | ⏳ Not run | ⏳ Not run | ⏳ Not run |
| [verifies observable referral code copy, print poster preview, and WhatsApp sharing format](tfpphotographers/tests/e2e/human/referral-lifecycle.human.spec.ts)<br>WEB-E2E-REF-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [keeps password-recovery aliases on the OTP-only authentication flow](tfpphotographers/tests/e2e/human/account-security.human.spec.ts)<br>WEB-E2E-SEC-001 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [cancels deletion, rejects an incorrect phrase and then deletes the account visibly](tfpphotographers/tests/e2e/human/account-security.human.spec.ts)<br>WEB-E2E-SEC-002 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [requires a fresh sign-in after the real account-deletion authentication window expires](tfpphotographers/tests/e2e/human/account-security.human.spec.ts)<br>WEB-E2E-SEC-007 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [blocks authenticated non-admin creator from contest creation by policy gate](tfpphotographers/tests/e2e/human/account-security.human.spec.ts)<br>WEB-E2E-SEC-006 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [renders every standalone trust document and system surface without a server failure](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-013 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [renders controlled 404 and 500 documents with non-indexable metadata](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-014 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [keeps disabled OAuth provider routes inside the controlled sign-in experience](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-015 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [gates member-only routes and reopens the member create hub](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-031 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [renames a profile with legacy navigation and recovers from a conflicting username](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts)<br>WEB-E2E-PRO-009 | ❌ Failed | ⏳ Not run | ⏳ Not run |
| [persists role services and request preferences then removes a role and clears optional profile fields](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts)<br>WEB-E2E-PRO-010 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [uploads role-tagged portfolio photos and verifies public lightbox navigation and exact image reporting](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts)<br>WEB-E2E-PRO-011 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [pages exactly thirteen approved opportunity owner photos with independent public identity readback](tfpphotographers/tests/e2e/human/gallery-pagination.human.spec.ts)<br>WEB-E2E-OPP-029 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [publishing a matching opportunity generates one real saved-search alert and opens its exact target](tfpphotographers/tests/e2e/human/saved-search-alerts.human.spec.ts)<br>WEB-E2E-SRCH-002 | ⏸ Interrupted | ⏳ Not run | ⏳ Not run |
| [event controls enforce active and monthly quotas and recover only a freed active slot](tfpphotographers/tests/e2e/human/creation-quotas.human.spec.ts)<br>WEB-E2E-EVT-021 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [opportunity controls enforce active and monthly quotas and deny a stale creation form](tfpphotographers/tests/e2e/human/creation-quotas.human.spec.ts)<br>WEB-E2E-OPP-033 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [an offline event upload preserves its draft and creates once after reconnection](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts)<br>WEB-E2E-EVT-022 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [revoking an event author session preserves the draft through sign-in and safe resubmission](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts)<br>WEB-E2E-EVT-023 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [recovers a lost upload completion acknowledgement and publishes exactly one event](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts)<br>WEB-E2E-EVT-024 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [the language picker preserves Arabic RTL through search and event publication](tfpphotographers/tests/e2e/human/rtl-business.human.spec.ts)<br>WEB-E2E-PUB-026 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [event validation and final submission remain keyboard reachable and expose labelled feedback](tfpphotographers/tests/e2e/human/keyboard-business.human.spec.ts)<br>WEB-E2E-PUB-027 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [an applicant uses keyboard controls to apply and report with modal focus containment and recovery](tfpphotographers/tests/e2e/human/keyboard-business.human.spec.ts)<br>WEB-E2E-PUB-028 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [public search and legal navigation work without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts)<br>WEB-E2E-PUB-029 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [saved-search plain HTML forms persist create edit and delete without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts)<br>WEB-E2E-SRCH-003 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [upload-dependent creation exposes its intentional JavaScript requirement without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts)<br>WEB-E2E-PUB-030 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [preserves exact message history across visible pages and persists delivered read and unread states](tfpphotographers/tests/e2e/human/message-history.human.spec.ts)<br>WEB-E2E-MSG-010 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [persists anonymous language and region choices and recovers from an unavailable region](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-032 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [preserves a selected location after denied or unavailable detection and saves a manual replacement](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-013 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [gates anonymous standalone reporting and preserves the exact member report without administrator UI](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-REP-008 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [updates exact member homepage counters through real applications entries and RSVPs and follows recommendations](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-033 | ✅ Passed | ⏳ Not run | ⏳ Not run |
| [crosses real owner applications and entries page boundaries without missing or repeated records](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-014 | ❌ Timed out | ⏳ Not run | ⏳ Not run |
| [preserves real location role and sort filters across two guaranteed discovery pages](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-034 | ✅ Passed | ⏳ Not run | ⏳ Not run |

The [exact-readback record](tfpphotographers/docs/operations/WEB_MEMBER_EXACT_READBACK_2026_11_21.md) owns confirmed fixes, failure classifications and affected follow-up evidence. The canonical use-case ledger owns requirements. Admin/email remain deferred; no deployment.
<!-- exact-member-run:end -->





<!-- affected-member-run:start -->
## Original affected attempt — 21 November 2026

**Updated:** 21 November 2026 13:38:12 IST. Frozen candidate `ae7bf606debf8cf6837bfd6f55a3f203899596c9`.
**Scope:** 19 public/member journeys × 3 browsers = 57 slots; 20 admin declarations and seven delivered-email cases remain deferred.

**Original attempt completed:** these are the immutable initial child outcomes before the one-journey correction above. The failed Firefox leaf is preserved; it is not the final selected-slot status.

| Browser | Passed | Failed | Pending |
| --- | ---: | ---: | ---: |
| chromium | 19 | 0 | 0 |
| firefox | 18 | 1 | 0 |
| mobile-chromium | 19 | 0 | 0 |

| Journey / canonical cases | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| [validates budget and deadline constraints and prevents duplicate opportunity creation](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts)<br>WEB-E2E-OPP-019 | ✅ Passed | ✅ Passed | ✅ Passed |
| [creates, edits, verifies and deletes an opportunity through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-OPP-004, WEB-E2E-OPP-018, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ✅ Passed | ✅ Passed |
| [creates, edits, verifies and deletes an event through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-EVT-004, WEB-E2E-EVT-010, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ✅ Passed | ✅ Passed |
| [creates, edits, verifies and deletes a contest through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts)<br>WEB-E2E-CON-004, WEB-E2E-CON-015, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed | ✅ Passed | ✅ Passed |
| [persists richer opportunity edits and moodboard replacement then removes old and new public discovery from an independent visitor](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-028 | ✅ Passed | ✅ Passed | ✅ Passed |
| [rejects stale applications after naturally elapsed legal dates or closure of all roles and persists zero applications](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts)<br>WEB-E2E-OPP-031 | ✅ Passed | ✅ Passed | ✅ Passed |
| [moves an RSVP through Going, Interested and Not Going states](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-005, WEB-E2E-EVT-009 | ✅ Passed | ✅ Passed | ✅ Passed |
| [pages thirteen owner photos to the exact oldest image, lightbox and image report](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-014 | ✅ Passed | ✅ Passed | ✅ Passed |
| [persists a rich event revision and clears fees through edit and independent public readback](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-015 | ✅ Passed | ✅ Passed | ✅ Passed |
| [removes a renamed event from anonymous details and exact public search after visible deletion](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts)<br>WEB-E2E-EVT-016 | ✅ Passed | ✅ Passed | ✅ Passed |
| [persists rich contest edits and confirms deletion across public canonical and legacy URLs](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts)<br>WEB-E2E-CON-025 | ✅ Passed | ✅ Passed | ✅ Passed |
| [uploads avatar, cover and portfolio media, validates files and deletes a portfolio item](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts)<br>WEB-E2E-PRO-001, WEB-E2E-PRO-002, WEB-E2E-PRO-003 | ✅ Passed | ❌ failed | ✅ Passed |
| [creates, updates and deletes an opportunity saved search through visible controls](tfpphotographers/tests/e2e/human/saved-search-lifecycle.human.spec.ts)<br>WEB-E2E-SRCH-001 | ✅ Passed | ✅ Passed | ✅ Passed |
| [uploads role-tagged portfolio photos and verifies public lightbox navigation and exact image reporting](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts)<br>WEB-E2E-PRO-011 | ✅ Passed | ✅ Passed | ✅ Passed |
| [pages exactly thirteen approved opportunity owner photos with independent public identity readback](tfpphotographers/tests/e2e/human/gallery-pagination.human.spec.ts)<br>WEB-E2E-OPP-029 | ✅ Passed | ✅ Passed | ✅ Passed |
| [saved-search plain HTML forms persist create edit and delete without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts)<br>WEB-E2E-SRCH-003 | ✅ Passed | ✅ Passed | ✅ Passed |
| [crosses real owner applications and entries page boundaries without missing or repeated records](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-014 | ✅ Passed | ✅ Passed | ✅ Passed |
| [preserves real location role and sort filters across two guaranteed discovery pages](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-034 | ✅ Passed | ✅ Passed | ✅ Passed |
| [updates exact member homepage counters through real applications entries and RSVPs and follows recommendations](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-033 | ✅ Passed | ✅ Passed | ✅ Passed |

The [exact-readback runbook](tfpphotographers/docs/operations/WEB_MEMBER_EXACT_READBACK_2026_11_21.md) owns source changes, commands, original failures and proof limits. The canonical use-case ledger owns requirements; this table is derived execution status. All original data, DB/media snapshots and evidence remain retained. No deployment.
<!-- affected-member-run:end -->

<a id="readiness-batch-20261120"></a>

## Readiness batch — completed 20–21 November 2026

All **12 affected journey groups × 3 web browsers = 36 slots** have actual
source-specific passing evidence. The [batch record](tfpphotographers/docs/operations/WEB_READINESS_BATCH_2026_11_20.md)
owns fixes, original failures, full source identities, commands and validation
limits. These additions extend the canonical ledger to 207 cases / 128 declarations
in 29 specs: 108 public/member declarations and 20 deferred admin declarations.
The original matrix below remains unchanged; no full current-source certificate
is inferred from the scoped table.

| Executed journey / canonical cases | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| [preserves exact message history across visible pages and persists delivered read and unread states](tfpphotographers/tests/e2e/human/message-history.human.spec.ts)<br>WEB-E2E-MSG-010 | ✅ a2 / `70c1925d3` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [searches isolated creators and verifies role filtering, actual sort order and return navigation](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-019, WEB-E2E-PUB-020, WEB-E2E-PUB-021 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [applies and clears discovery type, role, location and sort filters through visible controls](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts)<br>WEB-E2E-PUB-003 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [persists anonymous language and region choices and recovers from an unavailable region](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-032 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [preserves a selected location after denied or unavailable detection and saves a manual replacement](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-013 | ✅ a4 / `cbda2bc71` | ✅ a4 / `cbda2bc71` | ✅ a5 / `1e1476e19` |
| [gates anonymous standalone reporting and preserves the exact member report without administrator UI](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-REP-008 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [updates exact member homepage counters through real applications entries and RSVPs and follows recommendations](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-033 | ✅ a3 / `3b5f5f841` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [crosses real owner applications and entries page boundaries without missing or repeated records](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PRO-014 | ✅ a5 / `1e1476e19` | ✅ a5 / `1e1476e19` | ✅ a5 / `1e1476e19` |
| [preserves real location role and sort filters across two guaranteed discovery pages](tfpphotographers/tests/e2e/human/readiness-public-member.human.spec.ts)<br>WEB-E2E-PUB-034 | ✅ a2 / `70c1925d3` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [renders controlled 404 and 500 documents with non-indexable metadata](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-014 | ✅ a2 / `70c1925d3` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [keeps disabled OAuth provider routes inside the controlled sign-in experience](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-015 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |
| [gates member-only routes and reopens the member create hub](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts)<br>WEB-E2E-PUB-031 | ✅ a1 / `b06a6fd89` | ✅ a3 / `3b5f5f841` | ✅ a5 / `1e1476e19` |

**Evidence:** 252 retained captures, 39 exact typed read-only DB receipts and zero
unexpected diagnostics in the selected passing leaves. Zero retries/skips in
these completed runs. All nine original attempts (including failed children)
retain their terminal reports, clean source contexts, DB dumps and media snapshots
under `/private/tmp/tfp-web-readiness-batch-20261120-sgx59qvi`. The private
`browser-readiness-reconciliation-final.json` validates leaf identities/hashes.

Location recovery now bounds pending native permission and protects saved/map
coordinates; missing gallery URLs no longer request page HTML during retries.
Homepage activity freshness and localized error Retry are fixed. Real business
creation, upload/moderation, RSVP and report flows keep their existing owners.

Owned services/cluster are stopped with data retained. FE3000/API4000 remain
healthy and were not restarted. Cleanup retired 42 verified rebuildable TFP/
PulseTrade caches; trading data, active runtimes, releases and evidence remain.
The [cleanup details](tfpphotographers/docs/operations/WEB_READINESS_BATCH_2026_11_20.md#performance-tool-and-safe-cleanup)
do not authorize deleting retained runtime/evidence trees.

Still separate: approved scoped CI repository access, full final-source member/
release proof, host commissioning and the twelve production values, actual alerts,
Safari/assistive-technology/priority-language/timezone review where promised. Admin/
email remain deferred; native is Phase 2. No purchases or production deployment.

## Responsive web report follow-up — 20 November 2026

The original 93-journey matrix below retains its recorded sources and attempts.
This focused follow-up tests the shared gallery entrance fix from
`b2894753b642f95e1dd61ddc073416e84f81e1cf`; it does not restamp the old matrix.
The [cause, SSOT owners and actual validation record](tfpphotographers/docs/operations/MOBILE_REPORT_CLICK_FIX_2026_11_20.md)
retain the original missed click and every failed diagnostic attempt.

| Journey | Chromium | Firefox | Mobile Chromium |
| --- | --- | --- | --- |
| WEB-E2E-OPP-027 — participant image report, reopen, duplicate and exact saved DB values | ✅ Passed | ✅ Passed | ✅ Passed |
| WEB-E2E-EVT-014 — 13-photo paging, exact lightbox and image report | ✅ Passed | ✅ Passed | ✅ Passed |
| WEB-E2E-PRO-011 — role portfolio, public lightbox and exact image report | ✅ Passed | ✅ Passed | ✅ Passed |
| WEB-E2E-PUB-028 — keyboard application/report and focus recovery | ✅ Passed | ✅ Passed | ✅ Passed |

Zero retries; only completed leaves change these statuses. Admin/email stay
deferred. Data, held evidence and prior attempts remain preserved. No deployment.
Phase 1 covers web, including responsive browser layouts. Native iOS/Android
work is reserved for Phase 2; `mobile-chromium` is browser emulation only.

## Original 93-journey scope and rules

- **93 remaining journeys × 3 browser projects = 279 execution slots.**
- **Admin journeys are deferred:** 20 admin/mixed-admin declarations, including winner-management flows.
- **Email-delivery checks are deferred:** 7 canonical cases; no inbox checks or real test emails.
- Eight previously tested user-facing journeys remain covered by their original evidence and are excluded from this remaining-flow run.
- Use visible product controls, shared workflow helpers and existing exact read-only DB checks. Preserve data, held evidence and every original failed attempt. **Do not deploy.**
- **UI fixes are included:** inspect actual desktop/tablet/mobile evidence during these journeys, fix confirmed layout/interaction problems through existing shared components, design tokens and i18n, then verify the affected screen and flow. Admin UI stays deferred.
- This file tracks actual execution. The [canonical case ledger](tfpphotographers/tests/e2e/human/use-case-coverage.json) owns requirements and implementation status; this tracker does not replace it.
- Original runtime source: `42d46dadc182d3c0871f7bdc4b2f987c2e4e1557`; the corrected application candidate is `2683743efc48afe8ea69155901de924466c3b073`. Every attempt below retains its actual source; later publication changes documentation only.
- Status starts at **Pending** and changes only after the actual test finishes. A failed run remains linked when a corrected attempt passes.
- During execution, the task updater read actual completed Playwright leaves every two seconds. The updater is now stopped after terminal reconciliation. Discovery, startup, screenshots and an active browser never count as a pass.
- The fresh-sign-in security journey naturally waits the canonical ten-minute window; it stays Pending during that wait. No shortened timer or authentication bypass certifies that behavior.

## Original 93-journey progress

| Browser | Passed | Failed | Pending |
| --- | ---: | ---: | ---: |
| Chromium | 93 | 0 | 0 |
| Firefox | 93 | 0 | 0 |
| Mobile Chromium | 93 | 0 | 0 |

## Original 93-journey matrix

**Legend:** ⬜ Pending · ✅ Passed · ❌ Failed · ⏸ Blocked. A journey is complete after all three browser slots pass.

| # | Journey and executable owner | Chromium | Firefox | Mobile Chromium |
| ---: | --- | --- | --- | --- |
| 1 | [submits and retrieves a grievance case through visible controls](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts:15)<br>WEB-E2E-LEG-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 2 | [rejects another legal receipt token and retrieves each case after reload](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts:56)<br>WEB-E2E-LEG-002 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 3 | [submits and retrieves a privacy case through visible controls](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts:104)<br>WEB-E2E-LEG-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 4 | [persists optional analytics consent and lets the visitor change it through the privacy page](tfpphotographers/tests/e2e/human/legal-request-lifecycle.human.spec.ts:144)<br>WEB-E2E-LEG-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 5 | [searches isolated creators and verifies role filtering, actual sort order and return navigation](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:87)<br>WEB-E2E-PUB-019, WEB-E2E-PUB-020, WEB-E2E-PUB-021 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 6 | [discovers the platform, searches, and follows primary navigation](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:147)<br>WEB-E2E-PUB-001, WEB-E2E-PUB-002, WEB-E2E-PUB-004 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 7 | [applies and clears discovery type, role, location and sort filters through visible controls](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:193)<br>WEB-E2E-PUB-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 8 | [renders legal, localized, responsive, accessible and SEO surfaces](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:240)<br>WEB-E2E-PUB-005, WEB-E2E-PUB-006, WEB-E2E-PUB-007, WEB-E2E-PUB-008, WEB-E2E-PUB-009 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 9 | [renders dedicated empty state and quick searches for zero-result query](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:297)<br>WEB-E2E-PUB-018 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 10 | [activates empty-state quick searches and opens the advertised filtered discovery](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:310)<br>WEB-E2E-PUB-025 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 11 | [filters creators by multiple facets on directory and verifies facet tags](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:386)<br>WEB-E2E-PUB-022 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 12 | [executes coordinate geo search with radius expansion link and malformed coordinate fallback](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:490)<br>WEB-E2E-PUB-023 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 13 | [filters opportunity and event listings by work mode](tfpphotographers/tests/e2e/human/public-surfaces.human.spec.ts:564)<br>WEB-E2E-PUB-024 | ✅ Passed (a2) | ✅ Passed (a2); earlier failure retained | ✅ Passed (a1) |
| 14 | [creates opportunity, event, and contest content and opens their edit forms](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts:65)<br>WEB-E2E-OPP-002, WEB-E2E-EVT-002, WEB-E2E-CON-002, WEB-E2E-OPP-001, WEB-E2E-EVT-001, WEB-E2E-CON-001, WEB-E2E-MOD-001, WEB-E2E-MED-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 15 | [validates budget and deadline constraints and prevents duplicate opportunity creation](tfpphotographers/tests/e2e/human/creator-workflows.human.spec.ts:271)<br>WEB-E2E-OPP-019 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 16 | [persists invitation decline and requester cancellation states](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:142)<br>WEB-E2E-QR-006 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 17 | [shows precise browser validation for an invalid quick request](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:174)<br>WEB-E2E-QR-007 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 18 | [persists invitation decline state when creative declines request](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:201)<br>WEB-E2E-QR-009 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 19 | [pre-fills recipient creative context when navigating from creator profile CTA](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:227)<br>WEB-E2E-QR-010 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 20 | [validates inverted budget range and creates paid quick request with explicit currency terms](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:261)<br>WEB-E2E-QR-012 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 21 | [expands creative invitations from quick request detail view](tfpphotographers/tests/e2e/human/quick-request-lifecycle.human.spec.ts:351)<br>WEB-E2E-QR-014 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 22 | [redirects an existing authenticated session away from login](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:20)<br>WEB-E2E-AUTH-013 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 23 | [protects private routes and uses only the OTP bridge for authentication](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:33)<br>WEB-E2E-AUTH-004, WEB-E2E-AUTH-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 24 | [completes new creator onboarding through the visible signup form](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:47)<br>WEB-E2E-AUTH-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 25 | [edits a profile, uploads real media, and revokes both browser sessions through visible logout](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:145)<br>WEB-E2E-AUTH-006, WEB-E2E-AUTH-007 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a1) | ✅ Passed (a1) |
| 26 | [persists professional metadata, secondary roles, specialties, experience and service area](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:196)<br>WEB-E2E-PRO-005 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 27 | [edits per-role preferences and verifies role visibility filtering for guest viewers](tfpphotographers/tests/e2e/human/auth-profile.human.spec.ts:276)<br>WEB-E2E-PRO-006 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 28 | [completes collaboration, participation, messaging, notification and reporting flows](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts:30)<br>WEB-E2E-OPP-003, WEB-E2E-EVT-003, WEB-E2E-CON-003, WEB-E2E-MSG-001, WEB-E2E-NOTIF-001, WEB-E2E-REP-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 29 | [shows duplicate report warning when member reports already-reported content](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts:127)<br>WEB-E2E-REP-002 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 30 | [submits customer report across entities and verifies moderation submission feedback](tfpphotographers/tests/e2e/human/collaboration-workflows.human.spec.ts:226)<br>WEB-E2E-REP-004 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 31 | [creates, edits, verifies and deletes an opportunity through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts:88)<br>WEB-E2E-OPP-004, WEB-E2E-OPP-018, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 32 | [creates, edits, verifies and deletes an event through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts:113)<br>WEB-E2E-EVT-004, WEB-E2E-EVT-010, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 33 | [creates, edits, verifies and deletes a contest through visible controls](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts:137)<br>WEB-E2E-CON-004, WEB-E2E-CON-015, WEB-E2E-PUB-010, WEB-E2E-PUB-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 34 | [validates event text length and creates in-person event with entry fee](tfpphotographers/tests/e2e/human/content-crud.human.spec.ts:161)<br>WEB-E2E-EVT-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 35 | [completes the opportunity application, owner decision, workspace and withdrawal lifecycle](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:61)<br>WEB-E2E-OPP-005, WEB-E2E-OPP-006, WEB-E2E-OPP-007, WEB-E2E-OPP-009, WEB-E2E-OPP-012, WEB-E2E-OPP-013, WEB-E2E-OPP-014, WEB-E2E-OPP-015 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 36 | [allows an owner to reject an application and persists that decision for the applicant](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:170)<br>WEB-E2E-OPP-008 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 37 | [enforces application consent, reapplication and a stale withdrawal after selection](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:208)<br>WEB-E2E-OPP-010, WEB-E2E-OPP-011, WEB-E2E-OPP-016, WEB-E2E-OPP-017 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 38 | [toggles opportunity role status and dynamically updates applicant eligibility](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:288)<br>WEB-E2E-OPP-020 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 39 | [downloads an exact persisted opportunity workspace attachment for owner and selected participant](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:372)<br>WEB-E2E-OPP-021 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 40 | [uploads and opens an exact persisted opportunity public gallery photo with eligibility gates](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:457)<br>WEB-E2E-OPP-022 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 41 | [preserves selected applications, closed roles, metadata and exact workspace delivery through owner edits](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:578)<br>WEB-E2E-OPP-023 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 42 | [keeps multi-role applications, withdrawals and owner decisions independent with selected team credits](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:677)<br>WEB-E2E-OPP-024 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 43 | [rejects empty and invalid workspace submissions then persists note-only and exact file-only delivery](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:724)<br>WEB-E2E-OPP-025 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 44 | [revokes workspace and public-upload access after selection is rejected and denies the stale delivery form](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:777)<br>WEB-E2E-OPP-026 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 45 | [allows a selected participant public photo and persists exact public pixels and image-report dismissal and duplicate fencing](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:823)<br>WEB-E2E-OPP-027 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a2); earlier failure retained |
| 46 | [rejects the exact stale role application after an independent owner closes it without affecting another open role](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:1081)<br>WEB-E2E-OPP-030 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 47 | [rejects stale applications after naturally elapsed legal dates or closure of all roles and persists zero applications](tfpphotographers/tests/e2e/human/opportunity-lifecycle.human.spec.ts:1111)<br>WEB-E2E-OPP-031 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 48 | [moves an RSVP through Going, Interested and Not Going states](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:25)<br>WEB-E2E-EVT-005, WEB-E2E-EVT-009 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 49 | [validates required title and selected entry fee amounts in event creation](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:67)<br>WEB-E2E-EVT-006 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a1) | ✅ Passed (a1) |
| 50 | [rejects event creation when the event date is set in the past](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:109)<br>WEB-E2E-EVT-007 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 51 | [uploads an owner photo through the event gallery after the event starts](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:137)<br>WEB-E2E-EVT-008 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 52 | [prevents event organizer self-RSVP and denies participation to closed events](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:195)<br>WEB-E2E-EVT-012 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 53 | [enforces event photo gallery attendance prerequisites and pre-start submission locks](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:251)<br>WEB-E2E-EVT-013 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 54 | [pages thirteen owner photos to the exact oldest image, lightbox and image report](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:350)<br>WEB-E2E-EVT-014 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 55 | [removes a renamed event from anonymous details and exact public search after visible deletion](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:556)<br>WEB-E2E-EVT-016 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 56 | [rejects stale RSVP change and removal after the owner closes the event without altering attendance](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:596)<br>WEB-E2E-EVT-017 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 57 | [allows an Interested attendee photo and denies a Not Going attendee after start](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:628)<br>WEB-E2E-EVT-018 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 58 | [discovers the exact event and contacts its organizer while protecting editing from nonowners](tfpphotographers/tests/e2e/human/event-lifecycle.human.spec.ts:708)<br>WEB-E2E-EVT-020 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 59 | [rejects an empty contest submission at the browser boundary](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts:200)<br>WEB-E2E-CON-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 60 | [prevents participant self-reaction and enforces single vote per contest](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts:217)<br>WEB-E2E-CON-018 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 61 | [enforces contest lifecycle submission locks during judging phase](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts:312)<br>WEB-E2E-CON-019 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 62 | [downloads the exact contest reference image through its visible resource control](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts:372)<br>WEB-E2E-CON-020 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 63 | [persists directory reactions, cancels voting and shares the exact public entry](tfpphotographers/tests/e2e/human/contest-lifecycle.human.spec.ts:445)<br>WEB-E2E-CON-021, WEB-E2E-CON-022 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 64 | [uploads avatar, cover and portfolio media, validates files and deletes a portfolio item](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts:18)<br>WEB-E2E-PRO-001, WEB-E2E-PRO-002, WEB-E2E-PRO-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 65 | [handles non-existent user profile requests with a controlled 404 response](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts:193)<br>WEB-E2E-PRO-004 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 66 | [traverses owner profile activity tabs and verifies persisted tab selection](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts:209)<br>WEB-E2E-PRO-007 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 67 | [displays portfolio upload capacity quota and enforces required file selection](tfpphotographers/tests/e2e/human/profile-portfolio.human.spec.ts:255)<br>WEB-E2E-PRO-008 | ✅ Passed (a5); earlier failure retained | ✅ Passed (a2) | ✅ Passed (a1) |
| 68 | [delivers a two-party message, marks it read, replies and persists notification preferences](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts:16)<br>WEB-E2E-MSG-002, WEB-E2E-MSG-003, WEB-E2E-MSG-004, WEB-E2E-MSG-009, WEB-E2E-NOTIF-002, WEB-E2E-NOTIF-003, WEB-E2E-NOTIF-004 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 69 | [blocks and unblocks a conversation partner through messaging safety controls](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts:238)<br>WEB-E2E-MSG-005, WEB-E2E-MSG-006, WEB-E2E-MSG-007, WEB-E2E-MSG-008 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 70 | [filters notification feed by category and navigates to target deep link](tfpphotographers/tests/e2e/human/messaging-notifications.human.spec.ts:355)<br>WEB-E2E-NOTIF-005 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 71 | [verifies observable referral code copy, print poster preview, and WhatsApp sharing format](tfpphotographers/tests/e2e/human/referral-lifecycle.human.spec.ts:88)<br>WEB-E2E-REF-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 72 | [keeps password-recovery aliases on the OTP-only authentication flow](tfpphotographers/tests/e2e/human/account-security.human.spec.ts:18)<br>WEB-E2E-SEC-001 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 73 | [requires a fresh sign-in after the real account-deletion authentication window expires](tfpphotographers/tests/e2e/human/account-security.human.spec.ts:135)<br>WEB-E2E-SEC-007 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 74 | [blocks authenticated non-admin creator from contest creation by policy gate](tfpphotographers/tests/e2e/human/account-security.human.spec.ts:256)<br>WEB-E2E-SEC-006 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 75 | [renders every standalone trust document and system surface without a server failure](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts:4)<br>WEB-E2E-PUB-013 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 76 | [renders controlled 404 and 500 documents with non-indexable metadata](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts:55)<br>WEB-E2E-PUB-014 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 77 | [keeps disabled OAuth provider routes inside the controlled sign-in experience](tfpphotographers/tests/e2e/human/route-access-seo.human.spec.ts:73)<br>WEB-E2E-PUB-015 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 78 | [renames a profile with legacy navigation and recovers from a conflicting username](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts:34)<br>WEB-E2E-PRO-009 | ✅ Passed (a2) | ✅ Passed (a2); earlier failure retained | ✅ Passed (a1) |
| 79 | [persists role services and request preferences then removes a role and clears optional profile fields](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts:95)<br>WEB-E2E-PRO-010 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 80 | [uploads role-tagged portfolio photos and verifies public lightbox navigation and exact image reporting](tfpphotographers/tests/e2e/human/profile-operations.human.spec.ts:179)<br>WEB-E2E-PRO-011 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 81 | [pages exactly thirteen approved opportunity owner photos with independent public identity readback](tfpphotographers/tests/e2e/human/gallery-pagination.human.spec.ts:10)<br>WEB-E2E-OPP-029 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 82 | [publishing a matching opportunity generates one real saved-search alert and opens its exact target](tfpphotographers/tests/e2e/human/saved-search-alerts.human.spec.ts:7)<br>WEB-E2E-SRCH-002 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a2); earlier failure retained | ✅ Passed (a1) |
| 83 | [event controls enforce active and monthly quotas and recover only a freed active slot](tfpphotographers/tests/e2e/human/creation-quotas.human.spec.ts:55)<br>WEB-E2E-EVT-021 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a1) | ✅ Passed (a1) |
| 84 | [opportunity controls enforce active and monthly quotas and deny a stale creation form](tfpphotographers/tests/e2e/human/creation-quotas.human.spec.ts:61)<br>WEB-E2E-OPP-033 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a1) | ✅ Passed (a1) |
| 85 | [an offline event upload preserves its draft and creates once after reconnection](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts:25)<br>WEB-E2E-EVT-022 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 86 | [revoking an event author session preserves the draft through sign-in and safe resubmission](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts:52)<br>WEB-E2E-EVT-023 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 87 | [recovers a lost upload completion acknowledgement and publishes exactly one event](tfpphotographers/tests/e2e/human/creation-recovery.human.spec.ts:78)<br>WEB-E2E-EVT-024 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 88 | [the language picker preserves Arabic RTL through search and event publication](tfpphotographers/tests/e2e/human/rtl-business.human.spec.ts:6)<br>WEB-E2E-PUB-026 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a2); earlier failure retained | ✅ Passed (a1) |
| 89 | [event validation and final submission remain keyboard reachable and expose labelled feedback](tfpphotographers/tests/e2e/human/keyboard-business.human.spec.ts:19)<br>WEB-E2E-PUB-027 | ✅ Passed (a4); earlier failure retained | ✅ Passed (a2); earlier failure retained | ✅ Passed (a1) |
| 90 | [an applicant uses keyboard controls to apply and report with modal focus containment and recovery](tfpphotographers/tests/e2e/human/keyboard-business.human.spec.ts:47)<br>WEB-E2E-PUB-028 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a1) | ✅ Passed (a1) |
| 91 | [public search and legal navigation work without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts:8)<br>WEB-E2E-PUB-029 | ✅ Passed (a3); earlier failure retained | ✅ Passed (a2) | ✅ Passed (a1) |
| 92 | [saved-search plain HTML forms persist create edit and delete without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts:25)<br>WEB-E2E-SRCH-003 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |
| 93 | [upload-dependent creation exposes its intentional JavaScript requirement without JavaScript](tfpphotographers/tests/e2e/human/progressive-non-auth.human.spec.ts:50)<br>WEB-E2E-PUB-030 | ✅ Passed (a2) | ✅ Passed (a1) | ✅ Passed (a1) |

## Previously covered; no replay requested

- completes a directed quick request from invitation through review — original source-specific browser evidence is retained.
- edits profile details and persists contact links, location and availability settings — original source-specific browser evidence is retained.
- persists richer opportunity edits and moodboard replacement then removes old and new public discovery from an independent visitor — original source-specific browser evidence is retained.
- persists a rich event revision and clears fees through edit and independent public readback — original source-specific browser evidence is retained.
- persists rich contest edits and confirms deletion across public canonical and legacy URLs — original source-specific browser evidence is retained.
- creates, updates and deletes an opportunity saved search through visible controls — original source-specific browser evidence is retained.
- cancels deletion, rejects an incorrect phrase and then deletes the account visibly — original source-specific browser evidence is retained.
- preserves exact message history across visible pages and persists delivered read and unread states — original source-specific browser evidence is retained.

## Deferred admin journeys

- recovers an operator-returned quick request through owner revision and resubmission — deferred by operator; not selected.
- gates anonymous reporting and persists an authenticated standalone report — deferred by operator; not selected.
- reviews moderation, reports, and users through the admin workspace — deferred by operator; not selected.
- resolves a member report through the admin review dialog — deferred by operator; not selected.
- disables and restores a user through admin account controls — deferred by operator; not selected.
- restores a moderator-returned opportunity through an owner revision and exact public rediscovery — deferred by operator; not selected.
- recovers an actual event moderator request for changes through an owner revision and public restoration — deferred by operator; not selected.
- submits, publishes, likes, votes, shares and selects a contest winner through visible UI — deferred by operator; not selected.
- replaces and clears winners only with force and denies nonadmin management — deferred by operator; not selected.
- shares a referral and attributes the referred creator through visible signup and admin UI — deferred by operator; not selected.
- rejects an invalid and replayed authenticator code around a valid admin MFA check — deferred by operator; not selected.
- rejects login for a disabled user — deferred by operator; not selected.
- redirects authenticated non-admin member attempting direct admin workspace access — deferred by operator; not selected.
- denies privileged admin and QA routes to an ordinary member — deferred by operator; not selected. This is the current WEB-E2E-PUB-016 owner; public member-route/Create Hub assertions moved to independently executed WEB-E2E-PUB-031.
- opens every administrator and QA workspace with an MFA-verified administrator session — deferred by operator; not selected.
- removes reported content and refuses account erasure while preserving the exact held original — deferred by operator; not selected.
- keeps a reported opportunity image hidden and retains exact private evidence — deferred by operator; not selected.
- disables a reported owner and revokes their visible access without destroying evidence — deferred by operator; not selected.
- rejects a returned moderation item and persists exact owner feedback and held original bytes — deferred by operator; not selected.
- recovers a real failed image moderation transport through the administrator rerun control — deferred by operator; not selected.

## Deferred delivered-email cases

- WEB-E2E-AUTH-002: User requests email OTP on login page and completes interactive verification through visible UI — deferred by operator.
- WEB-E2E-AUTH-008: Delivered OTP form is bound to the browser challenge that requested it — deferred by operator.
- WEB-E2E-AUTH-009: Delivered OTP challenge form is removed after successful verification and visible logout — deferred by operator.
- WEB-E2E-AUTH-010: OTP change-email path enforces resend cooldown without consuming the active code — deferred by operator.
- WEB-E2E-AUTH-011: OTP challenge locks after the allowed incorrect-code attempts — deferred by operator.
- WEB-E2E-AUTH-012: Unknown email verifies a delivered OTP and completes creator onboarding — deferred by operator.
- WEB-E2E-NOTIF-006: Quiet hours delay real email receipt and deliver the exact notification after the window ends — deferred by operator.

## Execution records and retained evidence

- Original 93-journey private run root: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6`.
- Derived, frozen selection: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/selection.json`.
- Isolation/implementation plan: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/implementation-plan.json`.
- Fresh owned TEST clusters used ports 15559 and 15560. Both are now stopped normally with data retained. Existing databases and earlier evidence remain untouched.
- Reports, source contexts, failed screenshots, DB dumps and local storage snapshots stay under their original attempts.
- The earlier API proof was validated against the exact frozen source and reused; no admin API tests were replayed.
- All selected slots now have passing evidence. The [canonical completion and fix record](tfpphotographers/docs/operations/REMAINING_HUMAN_E2E_2026_11_19.md) owns implementation details, validation limits, transient observations and cleanup.

## Actual execution attempts

<!-- actual-flow-results:start -->
- **chromium-api-a1** — setup failed before journey execution; source `42d46dadc`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/chromium-api-a1`.
- **chromium-api-a2** — 83 passed / 10 failed / 0 skipped; source `42d46dadc`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/chromium-api-a2`.
- **chromium-api-a3** — 9 passed / 1 failed / 0 skipped; source `174582e79`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/chromium-api-a3`.
- **chromium-api-a4** — 1 passed / 1 failed / 0 skipped; source `9157eb1c2`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/chromium-api-a4`.
- **firefox-api-a1** — 86 passed / 5 failed / 0 skipped; source `a8fe54e82`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/firefox-api-a1`.
- **chromium-api-a5** — 1 passed / 0 failed / 0 skipped; source `2683743ef`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/chromium-api-a5`.
- **firefox-api-a2** — 7 passed / 0 failed / 0 skipped; source `2683743ef`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/firefox-api-a2`.
- **mobile-chromium-api-a1** — 92 passed / 1 failed / 0 skipped; source `2683743ef`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/mobile-chromium-api-a1`.
- **mobile-chromium-api-a2** — 1 passed / 0 failed / 0 skipped; source `2683743ef`; original report: `/private/tmp/tfp-remaining-human-20261119-ij86rdi6/mobile-chromium-api-a2`.
<!-- actual-flow-results:end -->

## UI issues discovered during testing

| Affected journey/screen | Confirmed UI issue | Fix/status | Actual verification evidence |
| --- | --- | --- | --- |
| Profile edit / shared location maps | Marker icons can resolve to malformed `distmarker-icon.png` / `distmarker-shadow.png` URLs and fail with a browser ORB block. | Shared loader derives the icon directory from the existing pinned Leaflet URL. Corrected profile journey passed across all three selected browsers. | Controlled component checks: 12/12 Chromium/Firefox passed, including broken-path counterfactual; original a2 trace retained. |
| Opportunity creation | An active-limit 403 sent a signed-in author through login recovery. | Existing inline feedback remains visible; only 401 triggers sign-in recovery. | Both quota journeys passed across all three browsers with exact DB counts. |
| Creation after owner deletion | Cached active-limit denial remained after a slot was freed. | Shared API invalidation and frontend delete helper refresh policy immediately. | Event/opportunity quota journeys passed across all three browsers. |
| Portfolio uploads | A permitted full batch stopped at the request/anonymous transfer limits. | One bounded session-bound JSON retry; verified capability transfer budgets retain issuance/global limits. | Full-capacity upload, exact DB counts and reload passed in Chromium a5, Firefox a2 and mobile a1. |
| Mobile footer | A wrapped legal-links row could start with a decorative separator. | Hide decorative separators at the existing mobile breakpoint. | Actual Chromium a3 mobile profile capture visually inspected. |

## Completion and evidence boundaries

- **93 / 93 selected journeys have passing actual evidence per browser: 279 unique slots.** Results span the original batches and source-specific scoped reruns; this is not a single full current-revision certificate.
- Mobile's full batch remains **92 passed / 1 failed**. Its sole photo-report failure passed separately on unchanged source with strict assertions intact. The intermittent click's deterministic root cause is unconfirmed. Original failures, traces and screenshots remain retained; no automatic test retries or suppressed errors were introduced.
- **18 exact read-only DB checkpoints** cover event/opportunity created and undeleted totals and portfolio initial/full-capacity totals. Other journeys retain their actual visible retrieval, status and exact media/attachment checks. This does not claim an independent DB assertion for every field in every journey. The earlier persistence record owns its separate rich-value checks.
- Terminal reconciliation matched all selected identities and actual DB receipts. Passing-leaf source/project/status and nonempty before/after captures were checked separately; the changed keyboard recheck is an execution, not an extra unique slot.
- The final scan reviewed 281 manifests and 2,580 raw captures. Two width candidates belong to a blank pre-navigation page, not an application layout. Inspected quota, portfolio, RTL, location and footer screens have no confirmed horizontal-overflow defect; physical-device and full accessibility proof remain separate.
- Owned application services, both fresh PostgreSQL clusters and the live tracker are stopped. Database directories, per-attempt dumps, storage originals and all failed evidence remain retained. Existing FE3000/API4000 returned HTTP 200 and were not restarted.
- User-authorized space cleanup retired six completed temporary dependency copies in total and about 636 MiB of npm download cache. Source, lockfiles, runtime contexts, DBs, media and all test evidence remain. Available space recovered to more than 5 GiB. Restore the listed private dependencies before replay; the [cleanup record](tfpphotographers/docs/operations/LOCAL_TEMP_CLEANUP_2026_11_20.md) owns paths, verification and capacity limits.
- **Still deferred:** the 20 admin/mixed-admin groups and seven delivered-email cases above. No native/deployed-target, production-host or go-live certificate follows from this local browser work. **No production deployment, purchase, credential change or scheduled automation occurred.**

Implementation owners, actual lower-level checks, preserved original failures and replay/cleanup instructions are maintained in the [canonical completion record](tfpphotographers/docs/operations/REMAINING_HUMAN_E2E_2026_11_19.md).
