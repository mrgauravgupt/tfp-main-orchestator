# WEB E2E COVERAGE SUMMARY — TFP Photographers
_Audit completed: 2026-08-25. Based on static inspection of 80 spec files and all application source._

---

## 1. TOP-LINE COVERAGE

| Status | Count | % |
|--------|-------|---|
| ✅ FULLY COVERED | 199 | 74% |
| ⚠️/⚡ PARTIALLY COVERED / WEAK | 16 | 6% |
| ❌ NOT COVERED | 49 | 18% |
| 🚫 NOT TESTABLE (infra or deferred) | 4 | 1% |
| **TOTAL USE CASES IDENTIFIED** | **269** | 100% |

---

## 2. COVERAGE BY FEATURE DOMAIN

| Domain | Total | ✅ Full | ⚠️/⚡ Partial | ❌ Missing | Coverage% |
|--------|-------|---------|--------------|-----------|----------|
| Authentication & Session | 23 | 18 | 1 | 4 | 78% |
| Profile & Onboarding | 26 | 22 | 1 | 3 | 85% |
| Opportunities | 28 | 21 | 2 | 5 | 75% |
| Events | 23 | 19 | 1 | 3 | 83% |
| Contests | 26 | 21 | 1 | 4 | 81% |
| Quick Requests | 20 | 17 | 0 | 3 | 85% |
| Messaging | 11 | 8 | 0 | 3 | 73% |
| Notifications | 8 | 6 | 0 | 1+1 | 75% |
| Search & Discovery | 12 | 8 | 1 | 3 | 67% |
| Admin | 20 | 15 | 1 | 4 | 75% |
| Reporting & Moderation | 12 | 9 | 0 | 3 | 75% |
| Localization | 15 | 12 | 1 | 2 | 80% |
| Accessibility | 15 | 10 | 1 | 2+2 | 67% |
| SEO & Static Pages | 7 | 5 | 0 | 2 | 71% |
| Uploads & Media | 6 | 0 | 3 | 3 | 0%* |
| Responsive & Visual | 7 | 2 | 3 | 1 | 29%* |
| Security & IDOR | 10 | 6 | 0 | 3+1 | 60% |

> *Uploads: 0% "fully covered" because all coverage is env-gated. Responsive: operator-run by design.

### Strongest Coverage Areas
1. **Quick Requests** — 85% full, complete lifecycle tested end-to-end
2. **Profile & Onboarding** — 85% full, media upload, validation, and locale preferences all verified
3. **Events** — 83% full, RSVP lifecycle, gallery permissions, moderation all covered
4. **Contests** — 81% full, submission/engagement/winner/sharing/SEO all tested

### Weakest Coverage Areas
1. **Uploads & Media** — 0% fully covered without `E2E_ENABLE_STORAGE_UPLOADS=true`
2. **Responsive & Visual** — 29% full; operator-run only; no CI gate
3. **Security & IDOR** — 60% full; browser-level IDOR, XSS, CSRF untested
4. **Search & Discovery** — 67% full; empty state, pagination, special chars untested
5. **Accessibility** — 67% full; WCAG automated scan deferred; ARIA/live regions untested

---

## 3. COVERAGE BY ROLE

| Role | Covered Flows | Gaps |
|------|--------------|------|
| **Anonymous** | Home, search, public detail pages, legal docs, 404/500, login/register, OAuth disabled boundary | Empty-state pages, sitemap, health endpoint |
| **Authenticated (photographer/model)** | Apply, RSVP, submit contest, create content, edit own content, message, block, report, save search, portfolio | IDOR quick-request access, post-deadline submission UI, profile collaborations tab |
| **Content owner** | Create/edit/delete opportunity/event/contest, workspace notes, QR create | Apply to own content (tested via API), capacity limit UI |
| **Admin** | Moderation approve/reject (events only via UI), bulk rerun, reports resolution, user disable/enable, MFA, filter sync | Opportunity and contest moderation via UI, report dismiss, hard-delete |
| **Invited creator (QR)** | Express interest, private chat, decline, venue consent | Non-invited access (IDOR) |

---

## 4. COVERAGE BY ROUTE

### Route Coverage (from `route-coverage.json` — 66 routes)

| Coverage Status | Count | Examples |
|----------------|-------|---------|
| Fully covered + meaningful assertion | ~52 | `/opportunities/:slug`, `/events/:slug`, `/admin?tab=*`, `/messages`, `/notifications`, all legal docs |
| Covered but shallow (navigation only) | ~8 | `/`, `/contests` listing, `/profile` redirect, `/qa` |
| Not covered | ~6 | `/sitemap.xml`, `/health`, `/profile/collaborations tab`, `/contests/:slug/submissions` (standalone) |

### API Coverage (from `api-source-coverage.json`)

All 15 tracked API route modules have at least one human spec mapping:

| Module | Human Spec(s) |
|--------|--------------|
| `admin.routes.ts` | `admin-workflows.human.spec.ts` |
| `auth.routes.ts` | `account-security`, `auth-profile` |
| `contest.routes.ts` | `contest-lifecycle`, `content-crud` |
| `event.routes.ts` | `event-lifecycle`, `content-crud` |
| `location.routes.ts` | `auth-profile`, `quick-request-lifecycle` |
| `message.routes.ts` | `messaging-notifications` |
| `opportunity.routes.ts` | `opportunity-lifecycle`, `content-crud` |
| `quick-request.routes.ts` | `quick-request-lifecycle` |
| `redirect.routes.ts` | `content-crud`, `contest-lifecycle` |
| `report.routes.ts` | `collaboration-workflows`, `admin-workflows` |
| `saved-search.routes.ts` | `saved-search-lifecycle` |
| `search.routes.ts` | `public-surfaces` |
| `telemetry.routes.ts` | `public-surfaces` |
| `local-storage.routes.ts` | `profile-portfolio`, `creator-workflows` |
| `user.routes.ts` | `account-security`, `auth-profile`, `profile-portfolio` |

> Modules **not mapped** in `api-source-coverage.json` (coverage exists but not formally registered):  
> `notification.routes.ts`, `translation.routes.ts`, `media.routes.ts`, `moderation.routes.ts`, `referral.routes.ts`

---

## 5. COVERAGE BY RISK CATEGORY

| Risk Category | Coverage | Notes |
|---------------|---------|-------|
| **Authentication (login/logout/session)** | ✅ HIGH | OTP alias, JWT duration, session persistence, MFA all tested |
| **Authorization (role-gated access)** | ✅ HIGH | Admin route gate, owner-only edit/delete, non-admin moderation block, route permission matrix |
| **Security boundaries** | ⚠️ MEDIUM | API-level: very strong. Browser-level: IDOR for QR, XSS rendering, CSRF all untested |
| **Content lifecycle (CRUD)** | ✅ HIGH | All content types: create/approve/edit/delete + non-owner blocking tested |
| **Moderation pipeline** | ✅ HIGH | Text rejection, image rejection, admin approve/reject, bulk rerun, profile moderation |
| **Media uploads** | ⚡ WEAK | Full pipeline only works with `E2E_ENABLE_STORAGE_UPLOADS=true`; corrupted/zero-byte untested |
| **Localization & i18n** | ✅ HIGH | Browser detection, preference persistence, middleware routing, content translation, timezone all covered |
| **SEO & metadata** | ✅ HIGH | All content detail pages, error pages, noindex, OG tags, canonical all asserted |
| **Accessibility** | ⚠️ MEDIUM | Keyboard navigation, labelled inputs, skip links covered; WCAG automated scan deferred |
| **Async worker flows** | ✅ HIGH | Collage, moderation, translation workers tested with real `expect.poll` waits |
| **Edge cases & boundaries** | ❌ LOW | Suspended user, empty states, past-event UI, deadline-closed UI, pagination, zero-result search, capacity limit |

---

## 6. TOP 5 CRITICAL GAPS (MUST FIX BEFORE LAUNCH)

### 🔴 C-01 — Suspended User Cannot Log In
No test verifies that a suspended account is blocked from the OTP auth flow. If the guard at the auth API is broken, suspended users could re-enter the platform.

### 🔴 C-02 — IDOR: Non-Invited User Accessing Quick Request Detail
Quick Requests contain private venue information and a private chat channel. No browser test verifies that a user without an invitation is blocked at the page level.

### 🔴 C-03 — XSS: Rendered User-Supplied Content
Profile bios, opportunity titles, contest descriptions, and quick-request messages accept user input rendered in Astro templates. No test verifies that angle brackets and scripts are HTML-escaped on output.

### 🔴 C-04 — Report Surface Types Beyond DETAILS (IMAGES, CONDUCT)
The report flow is only tested with the DETAILS surface. Other radio-selected surfaces may have broken form branches that are completely undetected.

### 🔴 C-05 — Expired JWT Token — Server Rejection in Browser
No test verifies that a browser context with an expired token is redirected to login on the next navigation. The JWT duration test covers issuance, not expiry enforcement.

---

## 7. HIGH GAPS (TARGET FOR SPRINT BACKLOG)

| ID | Area | Description |
|----|------|-------------|
| H-01 | Auth | Deleted user cannot log in |
| H-02 | Opportunities | Opportunity listing filter/sort UI (URL sync, param persistence) |
| H-03 | Opportunities | Opportunity create — all required fields validation |
| H-04 | Events | Event without cover image renders without error |
| H-05 | Contests | Submission form hidden after deadline (browser UI) |
| H-06 | Notifications | Notification badge count in header after new activity |
| H-07 | Admin | Approve opportunity from moderation UI (not just events) |
| H-08 | Messaging | Message send blocked in UI when blocked by recipient |
| H-09 | Reporting | Double-report idempotency |
| H-10 | Admin | Approve/reject contest from moderation UI |
| H-11 | Admin | Mark report closed/dismissed (resolutions beyond WARN) |
| H-12 | Opportunities | Opportunity with zero moodboard images renders |
| H-13 | Events | Past event RSVP buttons hidden/disabled in UI |
| H-14 | Profile | Non-existent username → 404 page |

---

## 8. RECOMMENDED IMPLEMENTATION ORDER

```
Phase 1 — CRITICAL (security; block release)
  C-01: Suspended user login blocked
  C-02: IDOR quick request browser test
  C-03: XSS rendering test
  C-04: Report surface types test
  C-05: Expired JWT browser enforcement test

Phase 2 — HIGH (core UX regressions)
  H-01: Deleted user login blocked
  H-07: Admin opportunity approval from UI
  H-10: Admin contest approval from UI
  H-11: Admin report dismiss resolution
  H-06: Notification badge count test
  H-03: Opportunity create validation test
  H-14: Profile 404 for missing username

Phase 3 — HIGH (feature completeness)
  H-02: Opportunity listing filter/sort UI
  H-05: Contest submission deadline UI
  H-08: Blocked user message UI
  H-09: Double-report idempotency
  H-04: Event without cover renders
  H-12: Opportunity with zero moodboard renders
  H-13: Past event RSVP hidden

Phase 4 — MEDIUM (edge cases, UX polish)
  M-01: Search zero-result state
  M-02: Search special characters
  M-03: Opportunity workspace empty state
  M-04: Contest prizes rendered
  M-05: Profile collaborations tab
  M-12: Event capacity limit UI
  M-13: Sitemap returns valid XML
  M-15: /health endpoint HTTP 200
  M-10: Duplicate application guard (browser)
  M-11: Admin moderation filter (full status options)
  M-14: 5-image moodboard limit enforcement

Phase 5 — LOW / WEAK ASSERTIONS (quality hardening)
  FP-01: Replace conditional if(isVisible) guards with expect().toBeVisible()
  FP-04: Add noop-storage CI mode for upload coverage
  FP-05: Add translation stub CI mode
  TD-04: Profile delete assertion: gallery count not just main visibility
  L-01: CSRF protection test
  L-02: Malformed JWT API test
  L-03: Tablet viewport test (768–1024px)
```

---

## 9. TEST ASSERTION QUALITY RATING

| Suite | Assertion Depth | Rating |
|-------|----------------|--------|
| Strict human (`opportunity-lifecycle`, `contest-lifecycle`, `quick-request-lifecycle`) | URL params + DOM content + DB Prisma polls | ⭐⭐⭐⭐⭐ |
| Domain integration (`launch-security-boundaries`, `moderation-authorization`, `avatar-portfolio`) | HTTP status + DB state + DOM text | ⭐⭐⭐⭐⭐ |
| Journey (`ssr-auth-event-i18n`, `storage-reporting-moderation`) | Full stack: cookie, API, DB, DOM | ⭐⭐⭐⭐⭐ |
| Strict human (`public-surfaces`, `collaboration-workflows`) | URL params + broad DOM text; some conditionals | ⭐⭐⭐ |
| Smoke (`page-smoke`) | HTTP 200 only | ⭐⭐ |
| Visual (`responsive-sweep`, `shell-visual-regression`) | Screenshot comparison; operator-run | ⭐⭐ |

---

## 10. HONEST CONFIDENCE STATEMENT

**This audit's coverage claims are HIGH CONFIDENCE.** Every covered status is traced to:
- A specific test file (by path)
- A specific assertion (`.toHaveURL`, `.toContainText`, `.toBe`, `.toBeVisible`, DB Prisma assertion, HTTP status check)
- The exact application state being asserted (URL param, DOM text, DB column value)

**This audit's gap claims are CONSERVATIVE.** Before declaring a use case NOT COVERED, I verified:
1. No test in any layer (human/domain/journey/smoke/a11y) exercises that exact flow
2. The application code for the route exists (`apps/web/src/pages/`)
3. The feature is a current product capability (not a planned/disabled feature per `E2E_AUDIT.md`)

**Limitations of static analysis:**
- A test could pass locally but flake in CI due to timing — this is not detectable without live runs
- A test could have correct assertions but target the wrong selector — this is detectable only by visual inspection which was done for all human spec files
- Business logic changes in the API (e.g., new validation rules) would not be reflected in the static assertion evidence without re-inspection

The **only path to ground truth** is running the full suite against a running application and reconciling the HTML report against this matrix. This audit provides the preparation and baseline for that validation run.
