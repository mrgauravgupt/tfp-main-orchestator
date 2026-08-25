# WEB E2E MISSING USE CASES — TFP Photographers
_Audit completed: 2026-08-25. 49 NOT COVERED + 16 PARTIAL/WEAK scenarios._

---

## Priority Definitions

| Priority | Criteria |
|----------|----------|
| **CRITICAL** | Security boundary, data integrity, or flow-breaking failure with direct user/business impact |
| **HIGH** | Core feature path untested; regression would cause visible user-facing failures |
| **MEDIUM** | Edge case or non-primary path with moderate business exposure |
| **LOW** | Visual polish, performance, or cosmetic behaviour; low regression risk |

---

## CRITICAL GAPS

### C-01 — Suspended User Cannot Log In
**Priority:** CRITICAL  
**Business Impact:** Suspended users must be blocked from all authenticated surfaces. Regression would allow suspended accounts to access content creation, messaging, and reporting.  
**Domain:** Auth  
**Route:** `POST /api/auth/login`  
**Test Scenario:** A user whose `accountStatus = SUSPENDED` attempts to log in and sees a specific rejection message.  
**Preconditions:** Seed a user and update `accountStatus` to `SUSPENDED` via Prisma.  
**Steps:**
1. Navigate to `/en-in/login`.
2. Enter the suspended user's email and submit.
3. Complete OTP step (or use test bridge with suspended seed account).
4. Assert login is rejected with a specific error message (e.g., "suspended").
5. Assert no session cookie is set.  
**Expected Result:** Error message visible; no session cookie; redirected to login.  
**Test Data:** Seeded user with `accountStatus: 'SUSPENDED'`.

---

### C-02 — IDOR: Non-Invited User Accessing Quick Request Detail
**Priority:** CRITICAL  
**Business Impact:** Quick Requests contain private venue information and chat. An uninvited user loading the detail URL must receive a 403/404 at the browser level.  
**Domain:** Quick Requests / Security  
**Route:** `/quick-requests/:id`  
**Test Scenario:** A logged-in user who was NOT invited to a quick request navigates directly to its URL.  
**Preconditions:** Create a QR owned by User A, invite User B. Log in as User C (no invitation).  
**Steps:**
1. Sign in as User C.
2. Navigate directly to `/en-in/quick-requests/:id` for a QR owned by User A.
3. Assert the page renders "not found" or "access denied" — no detail content visible.  
**Expected Result:** HTTP 403/404; no venue, no chat content visible.  
**Test Data:** Seeded QR with a different owner and invitee.

---

### C-03 — Expired/Invalid JWT Token — Server Rejection in Browser
**Priority:** CRITICAL  
**Business Impact:** An expired token in the browser cookie must be rejected by the server, not silently ignored. Regression could allow stale sessions to access protected content.  
**Domain:** Auth  
**Route:** Any authenticated page  
**Test Scenario:** A browser context is given a syntactically valid but expired/tampered JWT. Navigating to a protected page must redirect to login.  
**Preconditions:** Construct a JWT with `exp` in the past.  
**Steps:**
1. Set a `token` cookie with an expired JWT.
2. Navigate to `/en-in/messages`.
3. Assert redirect to `/en-in/login`.  
**Expected Result:** Redirect to login; no authenticated content visible.  
**Test Data:** Crafted expired JWT payload.

---

### C-04 — XSS: Rendered User-Supplied Content
**Priority:** CRITICAL  
**Business Impact:** User-supplied text (bio, opportunity title, contest description) rendered in Astro pages must be HTML-escaped to prevent XSS.  
**Domain:** Security  
**Route:** `/profile/:username`, `/opportunities/:slug`, `/contests/:slug`  
**Test Scenario:** A user creates content with an XSS payload in a text field and verifies it is rendered as plain text, not executed.  
**Preconditions:** Authenticated user with content creation permission.  
**Steps:**
1. Create an opportunity with title `<img src=x onerror=alert(1)>`.
2. Navigate to the detail page.
3. Assert the title is displayed as literal text.
4. Assert no alert dialog fires.
5. Check `document.title` does not contain raw HTML.  
**Expected Result:** XSS payload rendered as escaped text; no script execution.  
**Test Data:** Standard XSS payload strings.

---

### C-05 — Report Surface Types Beyond DETAILS (IMAGES, CONDUCT)
**Priority:** CRITICAL  
**Business Impact:** Users can select different report surfaces (e.g., `IMAGES`, `CONDUCT`) to target specific content. If these radio buttons or form branches are broken, reporters cannot accurately categorise violations.  
**Domain:** Reporting  
**Route:** `/report` modal  
**Test Scenario:** User selects `IMAGES` surface and `IMAGES` in the report form, submits, and verifies the report is received by the admin.  
**Preconditions:** Authenticated user; public content to report.  
**Steps:**
1. Open report modal from an opportunity detail page.
2. Select `IMAGES` radio button.
3. Select reason `INAPPROPRIATE_CONTENT`.
4. Fill message and submit.
5. Assert flash message confirms submission.  
**Expected Result:** Report submitted; flash message visible; admin sees `surfaceChoice: IMAGES`.  
**Test Data:** Approved opportunity with images.

---

## HIGH GAPS

### H-01 — Deleted User Cannot Log In
**Priority:** HIGH  
**Business Impact:** Accounts that have been deleted must be fully blocked from login. Regression would allow ghost sessions.  
**Domain:** Auth  
**Route:** `POST /api/auth/login`  
**Test Scenario:** A user whose account has been soft-deleted attempts to sign in.  
**Preconditions:** User completes account deletion flow. Account's `deletedAt` is set.  
**Steps:**
1. Navigate to `/en-in/login`.
2. Enter the deleted account's email.
3. Assert login is rejected with an appropriate message.  
**Expected Result:** Rejected; no session; error visible.  
**Test Data:** User with `deletedAt` set via Prisma.

---

### H-02 — Opportunity Listing Filter/Sort UI
**Priority:** HIGH  
**Business Impact:** Creators rely on opportunity filters (by role, type, date, location) to discover relevant listings. Broken filter state or URL sync is high-visibility.  
**Domain:** Opportunities  
**Route:** `/opportunities`  
**Test Scenario:** User applies role and type filters on the opportunities listing and verifies URL and content update correctly.  
**Preconditions:** Approved opportunities in DB.  
**Steps:**
1. Navigate to `/en-in/opportunities`.
2. Select role filter "MODEL".
3. Assert URL contains `role=MODEL`.
4. Select sort "Latest".
5. Assert URL contains `sort=latest` or equivalent.
6. Clear all filters.
7. Assert filter params absent from URL.  
**Expected Result:** URL sync correct; filter controls respond; no full-page reload.  
**Test Data:** Multiple seeded opportunities with different roles.

---

### H-03 — Opportunity Create — Required Field Validation
**Priority:** HIGH  
**Business Impact:** If the opportunity creation form has broken validation, users get server errors instead of inline guidance.  
**Domain:** Opportunities  
**Route:** `/opportunities/create`  
**Test Scenario:** User submits opportunity form with required fields empty.  
**Preconditions:** Authenticated user.  
**Steps:**
1. Navigate to `/en-in/opportunities/create`.
2. Submit the form without filling required fields (title, roles, dates).
3. Assert browser or server validation messages appear for each required field.
4. Assert URL stays on `/opportunities/create`.  
**Expected Result:** Inline validation messages; form not submitted.  
**Test Data:** None.

---

### H-04 — Event Without Cover Image Renders Without Error
**Priority:** HIGH  
**Business Impact:** Events created without a cover image must display a placeholder or gracefully omit the hero section.  
**Domain:** Events  
**Route:** `/events/:slug` (event with `imageKey: null`)  
**Test Scenario:** An approved event with no cover image is visible at its detail page without layout errors.  
**Preconditions:** Seeded event with `imageKey: null`.  
**Steps:**
1. Create an event without uploading a cover.
2. Approve the event.
3. Navigate to the event detail page as a guest.
4. Assert heading visible; no broken layout or console errors.  
**Expected Result:** Event detail renders; placeholder or no-image state shown.  
**Test Data:** Prisma-seeded event without `imageKey`.

---

### H-05 — Contest Submission After Deadline Blocked in UI
**Priority:** HIGH  
**Business Impact:** The contest page after the deadline should hide or disable the submission form. If the UI is not gated, users submit and get confusing API errors.  
**Domain:** Contests  
**Route:** `/contests/:slug?tab=submissions` (deadline past)  
**Test Scenario:** A user navigates to a contest whose deadline has passed and verifies the submission form is absent or disabled.  
**Preconditions:** Contest with `deadline` in the past.  
**Steps:**
1. Create a contest with past deadline.
2. Approve it.
3. Navigate to the contest page as a logged-in user (not the creator).
4. Open the submissions tab.
5. Assert submission form or upload input is absent.  
**Expected Result:** Submission form absent or disabled; user sees "deadline passed" message.  
**Test Data:** Contest with `deadline: new Date(Date.now() - 86400000)`.

---

### H-06 — Notification Badge Count in Header
**Priority:** HIGH  
**Business Impact:** Users depend on the notification bell badge to know when they have unread activity. A broken badge counter is immediately visible.  
**Domain:** Notifications  
**Route:** Header component (all authenticated pages)  
**Test Scenario:** After receiving a new application decision notification, the header badge count is non-zero.  
**Preconditions:** Authenticated user; opportunity application shortlisted.  
**Steps:**
1. Sign in as applicant.
2. Have the admin shortlist the application (via API).
3. Reload the page.
4. Locate the notification bell in the header.
5. Assert an unread count badge is visible with count ≥ 1.  
**Expected Result:** Badge visible with ≥ 1 unread notification.  
**Test Data:** SEEDED_HUMANS with an active application.

---

### H-07 — Admin: Approve Opportunity from Moderation UI
**Priority:** HIGH  
**Business Impact:** The admin-workflows domain spec only tests event approval/rejection from the UI. Opportunity moderation via the same UI workflow is uncovered at the browser level.  
**Domain:** Admin  
**Route:** `/admin?tab=moderation`  
**Test Scenario:** Admin opens a PENDING opportunity in the moderation dialog and clicks Approve.  
**Preconditions:** Pending opportunity in DB.  
**Steps:**
1. Sign in as admin.
2. Navigate to `/en-in/admin?tab=moderation`.
3. Find the pending opportunity row.
4. Click the row to open the review dialog.
5. Click Approve.
6. Assert DB `status = APPROVED`.
7. Assert public detail page renders.  
**Expected Result:** Opportunity approved; HTTP OK; detail accessible to guest.  
**Test Data:** Seeded pending opportunity.

---

### H-08 — Message From Blocked User — Send Blocked in UI
**Priority:** HIGH  
**Business Impact:** After being blocked, the blocked user must not be able to send messages to the blocker. If the UI doesn't reflect this, the user gets a confusing API error.  
**Domain:** Messaging  
**Route:** `/messages` (blocked sender's compose form)  
**Test Scenario:** User A blocks User B. User B navigates to their message thread with User A and verifies the compose form is disabled or absent.  
**Preconditions:** Block applied via messaging safety flow.  
**Steps:**
1. Sign in as User A and block User B.
2. Sign in as User B.
3. Navigate to `/en-in/messages` and open the thread with User A.
4. Assert compose input is disabled or hidden.  
**Expected Result:** Compose form absent or disabled for blocked sender.  
**Test Data:** SEEDED_HUMANS photographer and model.

---

### H-09 — Double-Report Idempotency
**Priority:** HIGH  
**Business Impact:** Submitting the same report twice should either be silently ignored or show "already reported". Regression allows spam reporting.  
**Domain:** Reporting  
**Route:** Report modal  
**Test Scenario:** User reports the same opportunity twice and verifies the second report shows "already reported".  
**Preconditions:** Authenticated user; approved opportunity.  
**Steps:**
1. Open report modal from opportunity detail.
2. Fill and submit a SPAM report.
3. Assert flash message confirms submission.
4. Open report modal again for the same opportunity.
5. Assert "already reported" or equivalent message is shown without resubmitting.  
**Expected Result:** Second report attempt shows idempotency message or form is pre-filled/disabled.  
**Test Data:** Approved opportunity; signed-in user.

---

### H-10 — Admin: Approve/Reject Contest from Moderation UI
**Priority:** HIGH  
**Business Impact:** Contests currently have API-level moderation tested but not browser-level UI. All content types should be testable through the admin moderation UI.  
**Domain:** Admin  
**Route:** `/admin?tab=moderation`  
**Test Scenario:** Admin finds a PENDING contest in the moderation queue and approves it via the visible UI.  
**Preconditions:** Pending contest in DB.  
**Steps:**
1. Sign in as admin and navigate to `/en-in/admin?tab=moderation`.
2. Find pending contest row.
3. Click to open review dialog.
4. Click Approve.
5. Assert DB `status = APPROVED`; public detail accessible.  
**Expected Result:** Contest approved; visible to guest.  
**Test Data:** Seeded pending contest.

---

### H-11 — Admin: Mark Report Closed/Dismissed
**Priority:** HIGH  
**Business Impact:** The admin report resolution only tests WARN_AND_REQUEST_CHANGES. Other resolutions (CLOSE/DISMISS, NO_ACTION) are untested and could be broken.  
**Domain:** Admin  
**Route:** `/admin?tab=flagged`  
**Test Scenario:** Admin opens a report and selects "Dismiss" or "No Action" resolution, then verifies the report is removed from the open queue.  
**Preconditions:** Open report in DB.  
**Steps:**
1. Sign in as admin; navigate to `/en-in/admin?tab=flagged`.
2. Find the report row.
3. Select "Dismiss" resolution.
4. Submit.
5. Assert report no longer appears in the open reports list.  
**Expected Result:** Report closed; removed from list; no server error.  
**Test Data:** Seeded open report.

---

### H-12 — Opportunity with Zero Mood Board Images Renders
**Priority:** HIGH  
**Business Impact:** An opportunity with an empty `moodBoardImages: []` must display without a broken hero or layout error.  
**Domain:** Opportunities  
**Route:** `/opportunities/:slug`  
**Test Scenario:** An approved opportunity with `moodBoardImages: []` renders its detail page without errors.  
**Preconditions:** Seeded APPROVED opportunity with empty `moodBoardImages`.  
**Steps:**
1. Create opportunity with no moodboard images.
2. Approve it.
3. Navigate to detail page as guest.
4. Assert heading visible; no broken image element or layout error.  
**Expected Result:** Detail renders; hero section gracefully absent or shows placeholder.  
**Test Data:** Prisma-seeded opportunity with `moodBoardImages: []`.

---

### H-13 — Past Event — RSVP Buttons Hidden/Disabled in UI
**Priority:** HIGH  
**Business Impact:** After an event date has passed, the RSVP buttons should not be actionable in the browser. The API already rejects with 409, but a broken UI state leaves users clicking non-functional buttons.  
**Domain:** Events  
**Route:** `/events/:slug` (event date in the past)  
**Test Scenario:** A past event shows its RSVP section with buttons disabled or absent.  
**Preconditions:** Seeded APPROVED event with `date` in the past.  
**Steps:**
1. Navigate to past event detail as authenticated user.
2. Assert RSVP buttons are absent, disabled, or show "event has ended".  
**Expected Result:** RSVP controls not actionable; no server call made on click.  
**Test Data:** Seeded past-date APPROVED event.

---

### H-14 — Profile: Non-Existent Username → 404
**Priority:** HIGH  
**Business Impact:** Profile pages for invalid usernames must render a 404, not a blank/broken page.  
**Domain:** Profile  
**Route:** `/profile/non-existent-username-12345`  
**Test Scenario:** Navigate to a profile URL for a username that does not exist.  
**Preconditions:** None.  
**Steps:**
1. Navigate to `/en-in/profile/definitely-does-not-exist-12345abc`.
2. Assert HTTP 404 status.
3. Assert "not found" text in body.  
**Expected Result:** 404 page rendered; "not found" text visible.  
**Test Data:** None.

---

## MEDIUM GAPS

### M-01 — Search: Empty / Zero Results State
**Priority:** MEDIUM  
**Business Impact:** Users who search for a term with no results should see an empty state, not a broken layout.  
**Domain:** Search  
**Route:** `/search?q=xyzzy-no-results`  
**Test Scenario:** Search for an impossible query and verify the zero-results state.  
**Steps:**
1. Navigate to `/en-in/search?q=xyzzyimpossibleterm9999`.
2. Assert "no results" or equivalent empty-state element visible.  
**Expected Result:** Zero-result empty state rendered; no layout errors.

---

### M-02 — Search: Special Characters / Unicode
**Priority:** MEDIUM  
**Business Impact:** Search queries containing special chars, angle brackets, or Unicode must not produce server errors or unescaped output.  
**Domain:** Search  
**Route:** `/search`  
**Test Scenario:** User searches for `<script>alert(1)</script>` and verifies the query appears escaped in results.  
**Steps:**
1. Navigate to `/en-in/search`.
2. Enter `<script>alert(1)</script>` in the search box.
3. Submit.
4. Assert no alert fires; query renders as escaped text in the page.  
**Expected Result:** Encoded output; no script execution; no server error.

---

### M-03 — Opportunity: Empty Application State on Workspace Tab
**Priority:** MEDIUM  
**Business Impact:** When no one has applied, the workspace tab should show an empty state, not nothing.  
**Domain:** Opportunities  
**Route:** `/opportunities/:slug?tab=workspace`  
**Test Scenario:** Navigate to an opportunity workspace tab with zero applications.  
**Steps:**
1. Create an opportunity.
2. Navigate to workspace tab as owner.
3. Assert empty state message is visible.  
**Expected Result:** "No applications yet" or similar message.

---

### M-04 — Contest Prizes Rendered Correctly
**Priority:** MEDIUM  
**Business Impact:** Prizes (position, description) are a core contest feature that entices submission. Broken rendering reduces participation.  
**Domain:** Contests  
**Route:** `/contests/:slug`  
**Test Scenario:** A contest with multiple prizes renders each prize's position and description.  
**Preconditions:** APPROVED contest with `prizes: [{position:1, prizeName:'Grand Prize'},{position:2, prizeName:'Runner Up'}]`.  
**Steps:**
1. Navigate to contest detail.
2. Assert "Grand Prize" and "Runner Up" visible in the page.  
**Expected Result:** All prize entries rendered.

---

### M-05 — Profile: Collaborations Tab
**Priority:** MEDIUM  
**Business Impact:** The collaborations tab on a public profile aggregates a user's opportunities/events. Broken rendering is user-visible.  
**Domain:** Profile  
**Route:** `/profile/:username?tab=collaborations`  
**Test Scenario:** Navigate to the collaborations tab on a public profile with at least one approved opportunity.  
**Steps:**
1. Sign in as photographer and create an approved opportunity.
2. Navigate to their public profile `?tab=collaborations`.
3. Assert the opportunity title visible.  
**Expected Result:** Collaborations tab renders with opportunity listed.

---

### M-06 — Admin: Moderation Filter (Full Test — All Status Options)
**Priority:** MEDIUM  
**Business Impact:** The existing partial coverage touches the moderation filter conditionally. Full coverage requires asserting each status filter option (PENDING, REJECTED, APPROVED) updates the list.  
**Domain:** Admin  
**Route:** `/admin?tab=moderation`  
**Test Scenario:** Admin selects each status filter and asserts the list updates.  
**Steps:**
1. Sign in as admin.
2. Select "PENDING" filter → assert only pending items visible.
3. Select "REJECTED" → assert rejected items visible.
4. Clear filter → assert all items visible.  
**Expected Result:** List responds to each filter; URL sync correct.

---

### M-07 — Quick Requests: List Filters
**Priority:** MEDIUM  
**Business Impact:** The quick requests listing may have filters (status, role type). Broken filter state hides relevant requests.  
**Domain:** Quick Requests  
**Route:** `/quick-requests`  
**Test Scenario:** Authenticated user navigates to `/en-in/quick-requests` and applies any available filter.  
**Steps:**
1. Sign in and navigate to quick-requests listing.
2. Apply any visible filter (e.g., status=OPEN).
3. Assert URL updates; list changes.  
**Expected Result:** Filter applied; URL updated; no error.

---

### M-08 — Message Pagination / Infinite Scroll
**Priority:** MEDIUM  
**Business Impact:** Long message threads must paginate. A broken scroll-trigger causes users to miss messages.  
**Domain:** Messaging  
**Route:** `/messages`  
**Test Scenario:** A thread with >20 messages shows an "older messages" trigger that loads more.  
**Steps:**
1. Seed a thread with 30+ messages.
2. Navigate to `/en-in/messages`.
3. Scroll to the top of the thread.
4. Assert older messages are loaded (more items appear).  
**Expected Result:** Pagination works; no duplicate messages; no scroll jump.

---

### M-09 — Stale Session on Create Forms (Full Verification)
**Priority:** MEDIUM  
**Business Impact:** Partial coverage: redirect to login confirmed, but no assertion that the form rehydrates correctly after re-auth.  
**Domain:** Auth  
**Route:** `/opportunities/create`, `/events/create`, `/contests/create`  
**Improvement:** After redirect to login, verify re-auth redirects back to the create form URL.  
**Steps:**
1. Navigate to `/en-in/opportunities/create` without session.
2. Assert redirect to `/login?redirect=%2F...%2Fopportunities%2Fcreate`.
3. Complete login.
4. Assert redirected back to `/en-in/opportunities/create`.
5. Assert form is visible.  
**Expected Result:** Full redirect chain works; create form accessible after login.

---

### M-10 — Duplicate Application Guard (Browser)
**Priority:** MEDIUM  
**Business Impact:** A user who has already applied should see an "already applied" state, not the apply button. Current test only checks API-level.  
**Domain:** Opportunities  
**Route:** `/opportunities/:slug`  
**Test Scenario:** User who has already applied revisits the detail page.  
**Preconditions:** User has submitted an application.  
**Steps:**
1. Apply to an opportunity.
2. Reload the detail page.
3. Assert the apply button is absent or replaced with "already applied".  
**Expected Result:** No duplicate apply affordance visible.

---

### M-11 — Date/Number/Currency Formatting by Locale
**Priority:** MEDIUM  
**Business Impact:** Dates displayed in wrong format (US MM/DD vs IN DD/MM) are user-facing bugs in a multi-locale app.  
**Domain:** Localization  
**Route:** `/hi-in/events`, `/en-us/events`  
**Test Scenario:** Navigate to the same event detail in US English and Indian Hindi and verify date formatting differs.  
**Steps:**
1. Approve an event with a known date.
2. Navigate in `en-us` locale and capture the date string.
3. Navigate in `hi-in` locale and capture the date string.
4. Assert they differ in format (e.g., `August 25` vs `25 अगस्त`).  
**Expected Result:** Locale-appropriate date format rendered.

---

### M-12 — Event Max Attendees / Capacity Limit UI
**Priority:** MEDIUM  
**Business Impact:** If a capacity-limited event is full, the RSVP button should be disabled.  
**Domain:** Events  
**Route:** `/events/:slug` (event at capacity)  
**Test Scenario:** Navigate to a capacity-limited event that is full.  
**Steps:**
1. Create event with `maxAttendees: 1`.
2. Have one user RSVP as GOING.
3. Navigate as a second user.
4. Assert RSVP button is disabled or shows "Full".  
**Expected Result:** RSVP button disabled; "capacity reached" message.

---

### M-13 — Sitemap Returns Without Error
**Priority:** MEDIUM  
**Business Impact:** Sitemap is crawled by search engines. A broken sitemap route causes index failures.  
**Domain:** SEO  
**Route:** `/sitemap.xml`  
**Test Scenario:** GET `/sitemap.xml` returns HTTP 200 and a valid XML body.  
**Steps:**
1. GET `/en-in/sitemap.xml` or `/sitemap.xml`.
2. Assert HTTP 200.
3. Assert `Content-Type` contains `xml`.
4. Assert `<urlset` element present.  
**Expected Result:** Valid XML sitemap.

---

### M-14 — 5-Image Moodboard Upload Limit (Full Verification)
**Priority:** MEDIUM  
**Business Impact:** Partial coverage — only ensures images upload. No explicit assertion that a 6th image is blocked.  
**Domain:** Uploads  
**Route:** `/opportunities/create`  
**Improvement:** After uploading 5 images, assert the upload control is disabled or hidden.  
**Steps:**
1. Navigate to opportunity create.
2. Upload 5 moodboard images.
3. Assert the image upload area is disabled or shows "limit reached".  
**Expected Result:** Upload button disabled after 5th image.

---

### M-15 — `/health` Endpoint
**Priority:** MEDIUM  
**Business Impact:** The `/health` endpoint is used by infrastructure probes. A broken health endpoint causes false alerts.  
**Domain:** SEO / System  
**Route:** `/health`  
**Test Scenario:** GET `/health` returns HTTP 200 with a healthy status body.  
**Steps:**
1. GET `/health`.
2. Assert HTTP 200.
3. Assert body contains `ok` or `healthy`.  
**Expected Result:** HTTP 200; healthy response body.

---

### M-16 — Referral Code Case Insensitive Lookup
**Priority:** MEDIUM  
**Business Impact:** The referral lifecycle test passes the code in lowercase to the URL. If the backend treats codes as case-sensitive, wrong-cased codes would silently fail attribution.  
**Domain:** Profile / Auth  
**Route:** `/register?ref=CODE` (uppercase)  
**Test Scenario:** Navigate with the referral code in uppercase and verify attribution still works.  
**Steps:**
1. Get a referral code (8 uppercase chars).
2. Navigate to `/en-in/register?ref=<CODE>` (uppercase).
3. Complete signup.
4. Verify admin shows attribution.  
**Expected Result:** Attribution recorded regardless of case.

---

## LOW GAPS

### L-01 — CSRF Protection on Form Submissions
**Priority:** LOW  
**Business Impact:** Astro/SSR form submissions include a CSRF token (if used). Explicitly verifying it blocks cross-origin form replay reduces attack surface.  
**Domain:** Security  
**Route:** Any form POST  
**Test Scenario:** Attempt to submit a form without the CSRF token or with a mismatched token.  
**Expected Result:** HTTP 403 or form validation error.

---

### L-02 — Malformed JWT Token to API
**Priority:** LOW  
**Business Impact:** API endpoints must explicitly reject malformed (non-JWT) strings in the Authorization header.  
**Domain:** Security  
**Route:** `GET /api/admin/users` with `Authorization: Bearer NOTAJWT`  
**Test Scenario:** Send API request with a random non-JWT string in the auth header.  
**Expected Result:** HTTP 401 or 403.

---

### L-03 — Tablet Layout (768px–1024px Viewport)
**Priority:** LOW  
**Business Impact:** The visual sweep covers mobile (<768px) and desktop (>1280px). The 768–1024px range (iPad landscape/portrait) is unasserted.  
**Domain:** Responsive  
**Route:** Key routes  
**Test Scenario:** Set viewport to 900×1024 and verify navigation, forms, and content cards render without overflow.  
**Expected Result:** No horizontal scroll; nav renders correctly; grid not broken.

---

### L-04 — Screen Reader Live Region Announcements
**Priority:** LOW  
**Business Impact:** After form submission (e.g., RSVP click), sighted users see visual feedback. Screen reader users depend on `aria-live` regions. Without a live region, they get no feedback.  
**Domain:** Accessibility  
**Route:** `/events/:slug` (RSVP button), `/opportunities/:slug` (apply)  
**Test Scenario:** After clicking RSVP, verify an `aria-live` region updates with a success message.  
**Expected Result:** `aria-live` region contains confirmation text after action.

---

### L-05 — Colour Contrast Assertions
**Priority:** LOW  
**Business Impact:** Deferred by product decision. Low priority compared to functional gaps but important for WCAG AA compliance.  
**Domain:** Accessibility  
**Expected Result:** All text/background pairs meet WCAG AA contrast ratio.

---

### L-06 — Concurrent Tab Session Invalidation
**Priority:** LOW  
**Business Impact:** If a user is logged out in Tab A, Tab B (still authenticated) should ideally reflect the session change. This is hard to test but important for security.  
**Domain:** Auth  
**Route:** Multiple pages  
**Test Scenario:** Open two browser contexts with the same session cookie. Log out in Context A. Attempt an authenticated action in Context B.  
**Expected Result:** Context B receives a 401/redirect on the next request.

---

### L-07 — Profile Onboarding Required Role Field Validation
**Priority:** LOW  
**Business Impact:** If the onboarding form role selector is unvalidated, a user could submit without selecting a role.  
**Domain:** Profile  
**Route:** `/profile/onboarding` (or within `/login?mode=signup` flow)  
**Test Scenario:** Submit the onboarding form without selecting a primary role.  
**Expected Result:** Inline error "Primary role is required"; form not submitted.

---

### L-08 — Search Pagination
**Priority:** LOW  
**Domain:** Search  
**Route:** `/search`  
**Test Scenario:** Navigate to page 2 of search results.  
**Expected Result:** Page 2 results visible; URL contains `page=2`.

---

### L-09 — Sitemap Structure Validates
**Priority:** LOW  
**Domain:** SEO  
**Route:** `/sitemap.xml`  
**Test Scenario:** Parse the sitemap XML and verify required routes (home, opportunities, events, contests) are present as `<url>` entries.  
**Expected Result:** Verified URL entries in sitemap.

---

### L-10 — Upload Interruption / Corrupted File
**Priority:** LOW  
**Business Impact:** Edge case that only affects real storage. Local storage mock can simulate but may not reflect real CDN failures.  
**Domain:** Uploads  
**Route:** Upload endpoints  
**Test Scenario:** Supply a buffer that has valid JPEG headers but corrupted body data; verify the API returns a meaningful error.  
**Expected Result:** Error response; no partial DB record.

---

## FALSE POSITIVE / WEAK ASSERTION RISKS

### FP-01 — Conditional `if (await element.isVisible())` Guards
**Risk:** MEDIUM  
**Files:** `collaboration-workflows.human.spec.ts` (L69 `submissionsTab`), `public-surfaces.human.spec.ts`, `messaging-notifications.human.spec.ts`  
**Issue:** `if (await element.isVisible()) await element.click()` silently skips clicks when the element is absent. If the element is always supposed to be present, this turns a missing-element failure into a false pass.  
**Recommendation:** Replace with `await expect(element).toBeVisible()` before the conditional click, or accept that the `if` is intentional (element may legitimately be absent) and add a comment explaining the invariant.

---

### FP-02 — URL-Based Success Indicators Without State Verification
**Risk:** MEDIUM  
**Files:** `opportunity-lifecycle.human.spec.ts`, `event-lifecycle.human.spec.ts`, `contest-lifecycle.human.spec.ts`  
**Issue:** Many tests assert `expect(page).toHaveURL(/applied=1/)` as the primary success check. A server redirect to that URL could occur even if the backend recorded an error. The redirect convention is by design in this codebase, but the DB or API state is not always re-verified after the redirect.  
**Recommendation:** For the highest-risk flows (apply, RSVP, workspace submit), add a Prisma DB assertion or a follow-up page content assertion to confirm the server recorded the action.

---

### FP-03 — `expect.poll()` with `isVisible()` Instead of `toBeVisible()`
**Risk:** LOW  
**Files:** `collaboration-workflows.human.spec.ts` (L20–L24 `waitForVisibleDetail`)  
**Issue:** The helper polls `page.getByText(title).first().isVisible()` and expects `toBeTruthy()`. A detached-element state could briefly return `false` rather than throwing, causing a longer poll but eventually passing. This is not strictly a false positive but could hide timing issues.  
**Recommendation:** Poll for `toBeVisible()` directly or for a stable selector count > 0.

---

### FP-04 — Storage Upload Tests Skipped by Default
**Risk:** HIGH  
**Files:** `storage-reporting-moderation.spec.ts`  
**Issue:** The entire test is skipped unless `E2E_ENABLE_STORAGE_UPLOADS=true`. In CI without that env var, the upload presign/complete/CDN URL flow is never exercised. The audit marks this as ⚡ WEAK/FLAKY because the coverage claim depends on a manual env flag.  
**Recommendation:** Document the required env var prominently in the E2E README. Consider a noop-storage mode that exercises the presign/complete cycle without real CDN calls for CI.

---

### FP-05 — Translation Broadcast Test Env-Flagged
**Risk:** MEDIUM  
**Files:** `dynamic-content-translation-broadcast.spec.ts`  
**Issue:** Test is skipped unless `FEATURE_TRANSLATION_CACHE=true`. Translation fan-out is a core localisation feature. Skipping it silently in most environments means the translation pipeline is not continuously validated.  
**Recommendation:** Document env requirement. Consider a stub-translation mode that exercises the fan-out path without real API calls for CI.
