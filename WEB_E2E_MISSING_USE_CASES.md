# Missing & Partially Covered E2E Use Cases Catalog

**Date**: 2026-08-25  
**Workspace**: `tfp-main-orchestator` / `tfpphotographers`  
**Total Identified Gaps & Deficiencies**: 51 Scenarios (12 Critical, 19 High, 14 Medium, 6 Low)  
**Classification Baseline**: 28 Partially Covered, 17 Not Covered, 6 Covered Weak/Flaky

---

## 1. Summary by Severity & Business Impact

| Priority Level | Description & Risk Area | Count | Core Domain Affected |
| :--- | :--- | :---: | :--- |
| **CRITICAL** | User lockout, security bypass, trust/safety failure, data corruption, or untracked compliance breach | **12** | Moderation, Auth Gating, Permissions (IDOR), Race Conditions |
| **HIGH** | Core user journey breakages, failed submission recovery, broken error states, unverified visual workflows | **19** | Upload Limits, Stale Sessions, Application Workflows, Messaging |
| **MEDIUM** | Secondary flows, filter edge cases, subtle UX regressions, missing validation feedback banners | **14** | Search Boundaries, Pagination, Quiet Hours, Localization |
| **LOW** | Minor layout quirks, deep-tail empty states, edge-case social links validation | **6** | SEO Schema Parsers, Social URL Regex, Boundary Page Queries |
| **TOTAL** | | **51** | |

---

## 2. Critical Priority Scenarios (12 Scenarios)

### `GAP-CRIT-001` (Auth / Security): Suspended Creator Direct Login & Active Session Eviction
- **Use Case ID**: `AUTH-011`
- **Business Impact**: A bad actor suspended by trust & safety can continue interacting if session eviction or login gating is broken.
- **Preconditions**: User `bad-actor@example.com` has active session; administrator sets `status = 'SUSPENDED'` via `/admin/users`.
- **Exact Steps**:
  1. Admin opens `/admin`, searches `bad-actor`, clicks "Disable User".
  2. Suspended user in second browser context attempts to reload `/opportunities/create` or submit an application.
  3. Suspended user logs out and attempts to request OTP at `/login`.
- **Expected Results**:
  - Active session on protected routes is immediately terminated (redirected to `/login?reason=account_disabled`).
  - OTP request or verification for suspended email displays accessible error banner: *"Your account has been suspended. Please contact grievance support."*
- **Recommended Test Location**: `tests/e2e/human/account-security.human.spec.ts`

### `GAP-CRIT-002` (Trust & Safety): AI Image Moderation Auto-Rejection on Avatar / Portfolio
- **Use Case ID**: `PRF-012`
- **Business Impact**: If AI moderation worker fails or UI doesn't handle rejection, illegal or explicit images remain publicly visible.
- **Preconditions**: Authenticated creator on `/profile/edit`.
- **Exact Steps**:
  1. Creator selects explicit image fixture (`fixtures/explicit-sample.jpg`).
  2. Clicks "Save Profile".
  3. AI Worker (Port 7011) evaluates image and returns `REJECTED` (`flags: ['NSFW', 'EXPLICIT']`).
  4. Web application polls or reloads public profile `/profile/:username`.
- **Expected Results**:
  - Profile edit page displays clear rejection warning: *"Image rejected due to community safety standards."*
  - Public profile renders placeholder fallback avatar, never the rejected image URL.
- **Recommended Test Location**: `tests/e2e/human/profile-portfolio.human.spec.ts`

### `GAP-CRIT-003` (Security / IDOR): Direct URL Conversation Thread Hijacking
- **Use Case ID**: `MSG-007`
- **Business Impact**: Unauthorized creator accessing another creator's private direct messages violates privacy laws and user trust.
- **Preconditions**: Conversation thread `thread-abc` exists between User A and User B. User C is logged in.
- **Exact Steps**:
  1. User C navigates directly to `/messages/thread-abc` or executes `GET /api/v1/messages/threads/thread-abc`.
- **Expected Results**:
  - Server returns 403 Forbidden or 404 Not Found.
  - Browser renders safe empty state without leaking message snippets, partner names, or attached media.
- **Recommended Test Location**: `tests/e2e/human/messaging-notifications.human.spec.ts`

### `GAP-CRIT-004` (Security / IDOR): Non-Selected Applicant Attempting Workspace Delivery
- **Use Case ID**: `OPP-013`
- **Business Impact**: Rejected or pending applicants viewing client brief details or submitting unapproved work.
- **Preconditions**: Opportunity exists with Applicant 1 (`SELECTED`) and Applicant 2 (`REJECTED`).
- **Exact Steps**:
  1. Applicant 2 navigates to `/opportunities/:slug?tab=workspace`.
  2. Applicant 2 attempts POST to `/api/v1/opportunities/:id/workspace`.
- **Expected Results**:
  - Tab displays locked state: *"The collaboration workspace is only accessible to selected participants."*
  - API call returns 403 `NOT_COLLABORATION_PARTICIPANT`.
- **Recommended Test Location**: `tests/e2e/human/opportunity-lifecycle.human.spec.ts`

### `GAP-CRIT-005` (Data Integrity): Double-Click Rapid Multi-Submission on Opportunity Applications
- **Use Case ID**: `OPP-007` (Boundary)
- **Business Impact**: Network latency causing duplicate applications, double notifications, and corrupt candidate counts.
- **Preconditions**: Applicant on `/opportunities/:slug` with application modal open and valid inputs.
- **Exact Steps**:
  1. Applicant double-clicks or rapidly fires 3 submit clicks on "Submit Application" button.
- **Expected Results**:
  - First click disables submit button, shows loading spinner (`aria-busy="true"`).
  - Database contains exactly 1 `OpportunityApplication` row.
  - Success banner rendered once.
- **Recommended Test Location**: `tests/e2e/human/opportunity-lifecycle.human.spec.ts`

### `GAP-CRIT-006` (Contests / Security): Expired Contest Window Submission Rejection
- **Use Case ID**: `CON-003` (Boundary)
- **Business Impact**: Entries submitted after deadline compromise contest fairness and prize integrity.
- **Preconditions**: Contest where `submissionDeadline` has elapsed (`new Date() > submissionDeadline`).
- **Exact Steps**:
  1. Creator navigates to `/contests/:slug`.
  2. Attempts to trigger upload form or submit entry.
- **Expected Results**:
  - Browser UI shows "Submissions Closed — Judging in Progress".
  - Upload form is disabled/hidden.
  - Direct API submission returns 409 `CONTEST_SUBMISSION_WINDOW_CLOSED`.
- **Recommended Test Location**: `tests/e2e/human/contest-lifecycle.human.spec.ts`

### `GAP-CRIT-007` (Admin / Safety): Malicious Report Spam Rate Limiting
- **Use Case ID**: `ADM-011`
- **Business Impact**: Bad actor spamming reports can overwhelm admin moderation queues and deny service.
- **Preconditions**: Authenticated creator on any opportunity or profile.
- **Exact Steps**:
  1. Creator opens report dialog, submits 25 reports in rapid succession (< 30 seconds).
- **Expected Results**:
  - 21st request receives HTTP 429 Too Many Requests.
  - UI displays rate limit banner: *"Too many reports submitted. Please wait a few minutes before trying again."*
- **Recommended Test Location**: `tests/e2e/human/admin-workflows.human.spec.ts`

### `GAP-CRIT-008` (Security): Cross-Tenant Event Photo Gallery Deletion (IDOR)
- **Use Case ID**: `EVT-010`
- **Business Impact**: Attendee deleting photos uploaded by other attendees or non-attendee deleting event media.
- **Preconditions**: Event with Photo A (uploaded by Attendee 1) and Photo B (uploaded by Attendee 2).
- **Exact Steps**:
  1. Attendee 2 navigates to `/events/:slug?tab=gallery`.
  2. Attempts to delete Photo A via UI or API `DELETE /api/v1/events/:id/submissions/photo-a`.
- **Expected Results**:
  - No delete icon is rendered for Photo A in Attendee 2's browser.
  - API returns 403 `UNAUTHORIZED_SUBMISSION_DELETION`.
  - Photo A remains visible in gallery.
- **Recommended Test Location**: `tests/e2e/human/event-lifecycle.human.spec.ts`

### `GAP-CRIT-009` (Security / Auth): Admin MFA Brute Force Lockout
- **Use Case ID**: `AUTH-010` (Boundary)
- **Business Impact**: Attackers attempting automated TOTP brute force against admin accounts.
- **Preconditions**: Admin user at `/admin/mfa`.
- **Exact Steps**:
  1. Submits 5 consecutive incorrect 6-digit TOTP codes (`111111`, `222222`, etc.).
- **Expected Results**:
  - After 5th failure, MFA verification is temporarily locked for 15 minutes.
  - UI displays lockout warning: *"Too many failed attempts. Account temporarily locked."*
- **Recommended Test Location**: `tests/e2e/human/account-security.human.spec.ts`

### `GAP-CRIT-010` (Data Integrity): Concurrent Opportunity Application Withdraw & Owner Selection Race
- **Use Case ID**: `OPP-014` (Boundary)
- **Business Impact**: Owner selects applicant at the exact instant applicant withdraws; creates inconsistent state.
- **Preconditions**: Applicant `app-123` with status `APPLIED`.
- **Exact Steps**:
  1. Thread 1: Applicant executes withdrawal (`POST /api/v1/opportunities/:id/applications/:appId/withdraw`).
  2. Thread 2: Owner simultaneously clicks "Select" in dashboard.
- **Expected Results**:
  - PostgreSQL transaction locks row (`FOR UPDATE`); withdrawal completes first or selection fails with 409 conflict.
  - UI informs owner: *"Applicant has withdrawn their application."*
- **Recommended Test Location**: `tests/e2e/human/opportunity-lifecycle.human.spec.ts`

### `GAP-CRIT-011` (Legal / Compliance): Account Deletion Media Cleanup Verification
- **Use Case ID**: `AUTH-009` (Boundary)
- **Business Impact**: GDPR / DPDP compliance violation if user media (avatar, portfolio, mood boards) is permanently retained and publicly accessible post-deletion.
- **Preconditions**: Creator with avatar, 3 portfolio items, and 1 opportunity deletes account via `/account/delete`.
- **Exact Steps**:
  1. Creator completes `"DELETE MY ACCOUNT"` flow.
  2. Direct URL request is made to previously published portfolio image URLs and profile route `/profile/:username`.
- **Expected Results**:
  - Public profile returns 404.
  - Presigned image keys are invalidated or unlinked; opportunities created by user marked `DELETED`.
- **Recommended Test Location**: `tests/e2e/human/account-security.human.spec.ts`

### `GAP-CRIT-012` (Reliability / Architecture): Durable Outbox Job Failure & Worker Retry Limit
- **Use Case ID**: `ADM-004` (Boundary)
- **Business Impact**: Crashing worker job causes infinite retry loops, saturating database and queue.
- **Preconditions**: Corrupt image payload placed in moderation outbox queue.
- **Exact Steps**:
  1. Outbox worker processes job; image inference fails.
  2. Worker increments `retryCount`.
- **Expected Results**:
  - After 5 retries, job status transitions to `DEAD_LETTER` / `FAILED`.
  - Admin moderation workspace shows job in "Failed Processing" tab with retry button.
- **Recommended Test Location**: `tests/e2e/domains/admin/tests/admin-workflows.spec.ts`

---

## 3. High Priority Scenarios (19 Scenarios)

| Gap ID | Domain | Scenario Name | Missing Verification & User Flow Details |
| :--- | :--- | :--- | :--- |
| `GAP-HIGH-001` | Opportunities | Owner Self-Application UI Guard | Verify Apply button is completely hidden/disabled when viewing owned opportunity in browser. |
| `GAP-HIGH-002` | Opportunities | Closed Opportunity Application Disable State | Verify Apply button is disabled with "Applications Closed" badge when `deadline` is in past. |
| `GAP-HIGH-003` | Opportunities | Stale Session During File Upload | Verify graceful prompt to re-authenticate when session expires mid-upload without losing form state. |
| `GAP-HIGH-004` | Events | Past Event RSVP Disable State | Verify RSVP buttons ("Going", "Interested") are disabled on past event pages in UI. |
| `GAP-HIGH-005` | Events | Non-Attendee Gallery Photo Upload Guard | Verify upload button is hidden and "RSVP Going to add photos" banner is shown in gallery tab. |
| `GAP-HIGH-006` | Profiles | Max 25 Portfolio Photos Quota Enforcement | Verify user attempting to upload 26th photo via UI sees disabled button and clear limit banner. |
| `GAP-HIGH-007` | Profiles | Oversized File Upload (>10MB) Warning | Verify file picker selecting 15MB photo immediately displays "Exceeds 10MB limit" before upload. |
| `GAP-HIGH-008` | Profiles | Corrupt / Zero-Byte Image Upload Rejection | Verify selecting 0-byte file displays "Corrupted image file" warning without crashing client. |
| `GAP-HIGH-009` | Messaging | Quiet Hours Notification Suppression | Verify notifications sent during configured quiet hours do not play sound or trigger push. |
| `GAP-HIGH-010` | Messaging | Message Input Exceeding Character Limit | Verify entering message > 2000 characters displays accessible character counter and blocks submit. |
| `GAP-HIGH-011` | Quick Requests | Rate Limit Exhaustion Feedback | Verify submitting 6th quick request in 1 hour displays user-friendly rate limit cooldown message. |
| `GAP-HIGH-012` | Quick Requests | Dashboard Status Tab Filtering | Verify switching between "Active", "Pending", and "Archived" tabs filters quick request cards. |
| `GAP-HIGH-013` | Admin | Dismiss False Report UI Transition | Verify clicking "Dismiss Report" animates report card out and decrements pending report count. |
| `GAP-HIGH-014` | Discovery | Public Search Pagination Next/Prev Controls | Verify clicking "Next Page" on `/search` loads page 2, scrolls to top, and updates URL `?page=2`. |
| `GAP-HIGH-015` | Discovery | Search Sorting Result Order Validation | Verify choosing "Deadline: Soonest" orders opportunities chronologically by deadline in DOM. |
| `GAP-HIGH-016` | Discovery | Live Geolocation / City Autocomplete Click | Verify typing "Mumbai", clicking dropdown suggestion fills coordinates and filters listings. |
| `GAP-HIGH-017` | Localization | Multi-Language Form Validation Messages | Verify submitting invalid form on `/hi-in` displays localized Hindi validation errors. |
| `GAP-HIGH-018` | Error Handling | Network Drop During AJAX Form Submit | Verify client displays persistent "Network error. Please check your connection" retry toast. |
| `GAP-HIGH-019` | SEO / Assets | Dynamic OG Image Endpoint Health (`/api/og/*`) | Verify requesting OpenGraph preview image URL returns HTTP 200 with valid `image/png` buffer. |

---

## 4. Medium Priority Scenarios (14 Scenarios)

| Gap ID | Domain | Scenario Name | Missing Verification & User Flow Details |
| :--- | :--- | :--- | :--- |
| `GAP-MED-001` | Auth | Malformed Email Domain Error Feedback | Verify typing `user@invalid` displays server-side domain verification error banner. |
| `GAP-MED-002` | Contests | Contest Winner Selection Candidate Search | Verify admin can filter candidates in winner selection dialog by applicant name. |
| `GAP-MED-003` | Contests | Multiple Reaction Rapid Toggle | Verify clicking like/unlike rapidly does not result in negative reaction counts. |
| `GAP-MED-004` | Profiles | Social Profile Link Format Validation | Verify entering invalid Instagram handle displays format hint without failing form. |
| `GAP-MED-005` | Messaging | Real-Time Notification Bell Increment | Verify notification bell increments without requiring full page refresh when new message arrives. |
| `GAP-MED-006` | Messaging | Blocked User Thread Restoration | Verify unblocking a user restores chat thread and enables message composition. |
| `GAP-MED-007` | Discovery | Browser Back/Forward History Popstate | Verify clicking browser Back button restores previous search filter state and results. |
| `GAP-MED-008` | Discovery | Out-of-Bounds Page Handling (`?page=9999`) | Verify requesting non-existent page number displays clean empty state without 500 error. |
| `GAP-MED-009` | Localization | Browser Accept-Language Root Negotiation | Verify browser with `Accept-Language: hi-IN` visiting `/` automatically redirects to `/hi-in`. |
| `GAP-MED-010` | Localization | Cross-Timezone Event Date Formatter | Verify event scheduled for 18:00 IST renders as 12:30 UTC for UK viewer context. |
| `GAP-MED-011` | Legal / Docs | Legal Document Body Integrity Check | Verify terms, privacy, dmca, guidelines pages render full policy text (> 200 words). |
| `GAP-MED-012` | Error Handling | Controlled 404 Return to Home CTA Click | Verify clicking "Return Home" on 404 error page successfully navigates back to `/en-in`. |
| `GAP-MED-013` | SEO | XML Sitemap Slugs Freshness | Verify newly created opportunity slug is immediately included in next `/sitemap.xml` build. |
| `GAP-MED-014` | SEO | JSON-LD Schema Strict Parser Validation | Verify JSON-LD script on detail pages parses into valid Schema.org object with all required properties. |

---

## 5. Low Priority Scenarios (6 Scenarios)

| Gap ID | Domain | Scenario Name | Details |
| :--- | :--- | :--- | :--- |
| `GAP-LOW-001` | Auth | Legacy Route Query Param Preservation | Verify `/forgot-password?ref=abc` preserves query params when redirecting to `/login`. |
| `GAP-LOW-002` | Contests | Social Share URL Clipboard Fallback | Verify clicking copy share link on contest entry writes correct URL to navigator clipboard. |
| `GAP-LOW-003` | Profiles | Bio Textarea Max Length Counter | Verify typing in profile bio updates visible remaining character count. |
| `GAP-LOW-004` | Discovery | Filter Accordion Expand/Collapse State | Verify mobile filter drawer opens, collapses sections, and remembers toggle state. |
| `GAP-LOW-005` | SEO | Breadcrumb Schema Validation | Verify breadcrumb navigation contains valid `BreadcrumbList` schema markup. |
| `GAP-LOW-006` | System | Browser Print Stylesheet Integrity | Verify print media stylesheet hides navigation bar and renders clean printable layout. |

---

## 6. Implementation Blueprint for New E2E Tests

To close all 12 Critical and 19 High Priority gaps safely without violating human test principles, implement the following spec files under `tfpphotographers/tests/e2e/human/`:

1. `tests/e2e/human/security-boundaries.human.spec.ts`:
   - `GAP-CRIT-001`: Suspended user login rejection and active session eviction.
   - `GAP-CRIT-003`: IDOR conversation thread access denial.
   - `GAP-CRIT-004`: Non-selected applicant workspace isolation.
   - `GAP-CRIT-008`: Cross-tenant event gallery deletion protection.
   - `GAP-CRIT-009`: Admin MFA brute force lockout.

2. `tests/e2e/human/safety-moderation.human.spec.ts`:
   - `GAP-CRIT-002`: AI image moderation rejection on avatar/portfolio.
   - `GAP-CRIT-007`: Report spam rate limiting feedback.
   - `GAP-CRIT-011`: Account deletion media purging verification.

3. `tests/e2e/human/concurrency-boundaries.human.spec.ts`:
   - `GAP-CRIT-005`: Multi-click application double-submission protection.
   - `GAP-CRIT-006`: Expired contest submission boundary.
   - `GAP-CRIT-010`: Application withdrawal vs owner selection race condition.
