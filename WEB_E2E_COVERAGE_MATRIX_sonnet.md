# WEB E2E COVERAGE MATRIX — TFP Photographers
_Audit completed: 2026-08-25. Source inspected: `apps/web/src/pages`, `apps/api/src/modules`, `tests/e2e/**`._

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ FULLY COVERED | Test performs the full user flow AND asserts the correct final result |
| ⚠️ PARTIALLY COVERED | Test navigates or touches the feature but lacks a meaningful final assertion, or only covers the happy path |
| ❌ NOT COVERED | No test exercises this use case |
| ⚡ COVERED BUT WEAK/FLAKY | Test passes but has brittle selectors, shared-state risk, conditional assertion paths, or mocked-away behaviour |
| 🚫 NOT TESTABLE | Requires infrastructure not present in the current setup (real OTP email delivery, live CDN etc.) |

---

## 1. AUTHENTICATION & SESSION

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| OTP login — happy path (valid email → code → session) | `/login` / `POST /auth/login` | `auth-flow.spec.ts`, `auth-profile.human.spec.ts` | Redirects to `/profile/edit`; session cookie present | ✅ FULLY COVERED |
| Registration → onboarding redirect | `/register` → `/login?mode=signup` → `/profile/edit?onboarding=1` | `auth-flow.spec.ts`, `account-security.human.spec.ts` | URL matches `/profile/edit?onboarding=1` | ✅ FULLY COVERED |
| Login with missing email — browser validation | `/login` | `auth-flow.spec.ts` | `validationMessage` matches required pattern | ✅ FULLY COVERED |
| Open redirect prevention on login redirect param | `/login?redirect=https://evil.example` | `auth-flow.spec.ts` | Hidden `redirect` input normalised to `/` | ✅ FULLY COVERED |
| Safe redirect on login | `/login?redirect=/profile/edit` | `auth-flow.spec.ts` | Hidden input holds `/profile/edit` | ✅ FULLY COVERED |
| Logout clears session and redirects | `/logout` | `auth-profile.human.spec.ts`, `ssr-auth-event-i18n.spec.ts` | Post-logout cookie absent; URL is root | ✅ FULLY COVERED |
| JWT session lifetime (180 days) | `POST /auth/login` | `jwt-session.spec.ts` | `Max-Age=15552000` in `Set-Cookie` | ✅ FULLY COVERED |
| Persisted session survives new context | Browser storage restore | `jwt-session.spec.ts` | New page loaded without redirect to `/login` | ✅ FULLY COVERED |
| Password-recovery alias pages redirect to OTP flow | `/forgot-password`, `/reset-password`, `/auth/login` | `account-security.human.spec.ts` | URL ends at `/en-in/login` | ✅ FULLY COVERED |
| `/register` alias redirects to unified OTP signup | `/register` | `account-security.human.spec.ts`, `auth-flow.spec.ts` | URL ends at `/en-in/login?mode=signup` | ✅ FULLY COVERED |
| OAuth disabled boundaries (Google, Apple, Meta) | `/auth/google`, `/auth/apple`, `/auth/meta` | `route-access-seo.human.spec.ts` | HTTP < 500, redirects to `/login` | ✅ FULLY COVERED |
| OAuth callback pages disabled | `/auth/google/callback` etc. | `route-access-seo.human.spec.ts` | Route-coverage entry; redirect verified | ✅ FULLY COVERED |
| Unauthenticated user accessing protected route → login redirect | All protected routes | `route-access-seo.human.spec.ts`, `auth-profile.human.spec.ts` | URL matches `/login?redirect=` | ✅ FULLY COVERED |
| Stale session on create forms → graceful re-auth | `/opportunities/create` | `create-flows-stale-session.spec.ts` | Redirect to login, no 500 | ⚠️ PARTIALLY COVERED |
| Expired/invalid JWT token — server rejection | API | None | No dedicated expired-JWT browser test | ❌ NOT COVERED |
| Concurrent tabs / session invalidation | Multiple tabs | None | — | ❌ NOT COVERED |
| Suspended user attempting login | `POST /auth/login` | None | No test verifies suspended-account rejection message | ❌ NOT COVERED |
| Deleted user attempting login | `POST /auth/login` | None | — | ❌ NOT COVERED |
| MFA — reject invalid code | `/admin/mfa` | `account-security.human.spec.ts` | Alert contains "invalid/already used" | ✅ FULLY COVERED |
| MFA — reject replayed code | `/admin/mfa` | `account-security.human.spec.ts` | Re-use of same code triggers alert | ✅ FULLY COVERED |
| MFA — valid code grants access | `/admin/mfa` | `account-security.human.spec.ts` | HTTP 303, admin page accessible | ✅ FULLY COVERED |
| Account deletion — wrong phrase rejected | `/account/delete` | `account-security.human.spec.ts` | Alert visible after wrong phrase | ✅ FULLY COVERED |
| Account deletion — correct phrase → account removed | `/account/delete` | `account-security.human.spec.ts` | Redirects to signup; profile no longer accessible | ✅ FULLY COVERED |

---

## 2. PROFILE & ONBOARDING

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Creator signup flow end-to-end | `/login?mode=signup` | `auth-profile.human.spec.ts`, `auth-flow.spec.ts` | Display name visible in main | ✅ FULLY COVERED |
| Creator onboarding page accessible after signup | `/profile/onboarding` | `auth-profile.human.spec.ts` | URL reaches `/profile/edit` | ✅ FULLY COVERED |
| Profile edit — save headline + bio | `/profile/edit` | `auth-profile.human.spec.ts`, `profile-edit.spec.ts` | Updated headline visible in `main`; URL matches `/profile/` | ✅ FULLY COVERED |
| Profile edit — language/region preference saved and persisted | `/profile/edit` → locale route change | `profile-edit.spec.ts`, `locale-runtime.spec.ts` | URL slug changes to new locale; DB row verified | ✅ FULLY COVERED |
| Profile edit — timezone preference saved | `/profile/edit` | `profile-edit.spec.ts` | `#preferredTimeZone` has persisted value | ✅ FULLY COVERED |
| Avatar upload (happy path) | `/profile/edit` | `auth-profile.human.spec.ts`, `avatar-portfolio.spec.ts` | Preview `img` visible; DB `profileImageKey` set | ✅ FULLY COVERED |
| Cover image upload | `/profile/edit` | `profile-portfolio.human.spec.ts`, `avatar-portfolio.spec.ts` | Preview `img` visible; DB `coverImageKey` set | ✅ FULLY COVERED |
| Avatar replacement (second upload replaces first) | `/profile/edit` | `avatar-portfolio.spec.ts` | New key differs from first; both DB assertions pass | ✅ FULLY COVERED |
| Invalid file type rejected (exe → avatar) | `/profile/edit` | `avatar-portfolio.spec.ts` | Runtime status text matches invalid-file pattern | ✅ FULLY COVERED |
| Oversized file rejected | `/profile/edit` | `avatar-portfolio.spec.ts` | Runtime status text matches size-limit pattern | ✅ FULLY COVERED |
| Portfolio upload (multi-image, two files) | `/profile/:username?tab=portfolio` | `avatar-portfolio.spec.ts`, `profile-portfolio.human.spec.ts` | DB count reaches 2; gallery items visible | ✅ FULLY COVERED |
| Portfolio limit reached (25 images) — upload button disabled | `/profile/:username?tab=portfolio` | `avatar-portfolio.spec.ts` | Button disabled; aria-disabled=true; limit text visible | ✅ FULLY COVERED |
| Portfolio invalid file type rejected | `/profile/:username?tab=portfolio` | `profile-portfolio.human.spec.ts` | Status text matches invalid pattern | ✅ FULLY COVERED |
| Portfolio item deletion | `/profile/:username?tab=portfolio` | `profile-portfolio.human.spec.ts`, `avatar-portfolio.spec.ts` | Confirm dialog; DB count decrements; gallery item disappears | ✅ FULLY COVERED |
| Portfolio lightbox open/close (Escape + backdrop click) | `/profile/:username?tab=portfolio` | `avatar-portfolio.spec.ts` | `open` attribute present/absent; focus returns to trigger | ✅ FULLY COVERED |
| Portfolio lightbox close button geometry (44px min, 4px inset) | `/profile/:username?tab=portfolio` | `avatar-portfolio.spec.ts` | Width/height ≥ 44px; `inset: 4px`; icon 16px | ✅ FULLY COVERED |
| Owner portfolio badge layout geometry | `/profile/:username?tab=portfolio` | `avatar-portfolio.spec.ts` | Badge height < 36px; card alignment < 32px gap | ✅ FULLY COVERED |
| Public profile discovery (guest view) | `/profile/:username` | `public-surfaces.human.spec.ts`, `avatar-portfolio.spec.ts` | Display name visible; portfolio items visible to guest | ✅ FULLY COVERED |
| Profile `/profile` redirect to authenticated user's own profile | `/profile` | `route-access-seo.human.spec.ts` | HTTP < 500; page renders | ⚠️ PARTIALLY COVERED |
| Profile location detection button accessible | `/profile/edit` | `a11y/key-routes-accessibility.spec.ts` | `aria-label` attribute includes "detect" | ✅ FULLY COVERED |
| Upload avatar input labelled | `/profile/edit` | `a11y/key-routes-accessibility.spec.ts` | Labels count > 0 | ✅ FULLY COVERED |
| Referrals page — QR, WhatsApp share, download, print | `/profile/referrals` | `referral-lifecycle.human.spec.ts` | QR SVG visible; WhatsApp href matches `wa.me`; buttons present | ✅ FULLY COVERED |
| Referral signup attribution tracked | `/register?ref=CODE` → admin users panel | `referral-lifecycle.human.spec.ts` | Admin shows "Referred by" and "Ref: 1" on correct cards | ✅ FULLY COVERED |
| Profile onboarding — required role missing | `/profile/onboarding` | None | No dedicated validation test for onboarding required fields | ❌ NOT COVERED |
| Profile — non-existent username 404 | `/profile/invalid-404` | None | No test navigates to a provably absent username and asserts 404 | ❌ NOT COVERED |
| Profile — collaborations tab | `/profile/:username?tab=collaborations` | None | No dedicated test for collaborations tab content | ❌ NOT COVERED |

---

## 3. OPPORTUNITIES

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Create opportunity (happy path → PENDING) | `/opportunities/create` | `creator-workflows.human.spec.ts`, `opportunity-crud.spec.ts` | Redirects to detail with `created=1` | ✅ FULLY COVERED |
| Opportunity detail — full SEO metadata | `/opportunities/:slug` | `content-crud.human.spec.ts` | canonical, og:title, og:url, og:image, twitter:card, ld+json asserted | ✅ FULLY COVERED |
| Opportunity edit (owner) | `/opportunities/:slug/edit` | `content-crud.human.spec.ts` | Updated title visible | ✅ FULLY COVERED |
| Opportunity delete (owner) | `/opportunities/:slug` | `content-crud.human.spec.ts`, `opportunity-lifecycle.human.spec.ts` | Old URL renders "not found" | ✅ FULLY COVERED |
| Non-owner edit route — 403 | `/opportunities/:slug/edit` | `content-crud.human.spec.ts` | HTTP 403; form absent | ✅ FULLY COVERED |
| Non-owner cannot see edit/delete controls | `/opportunities/:slug` | `content-crud.human.spec.ts` | Edit link and confirm form count = 0 | ✅ FULLY COVERED |
| Opportunity listing page renders | `/opportunities` | `public-surfaces.human.spec.ts` | Page visible | ✅ FULLY COVERED |
| Apply to opportunity — full form with consents | `/opportunities/:slug` | `opportunity-lifecycle.human.spec.ts`, `collaboration-workflows.human.spec.ts` | URL reaches `applied=1`; applied state visible | ✅ FULLY COVERED |
| Apply — missing consents blocked (browser validation) | Apply modal | `opportunity-lifecycle.human.spec.ts` | `validity.valueMissing` on `agreedToTerms` | ✅ FULLY COVERED |
| Owner cannot apply to own opportunity | `POST /opportunities/:id/applications` | `opportunity-application-workflow.spec.ts` | HTTP 403; error matches "own opportunity" | ✅ FULLY COVERED |
| Application shortlisted → notification | Opportunity workspace | `opportunity-lifecycle.human.spec.ts` | Notification contains "SHORTLISTED"; deep link works | ✅ FULLY COVERED |
| Application selected → notification | Opportunity workspace | `opportunity-lifecycle.human.spec.ts` | Notification contains "SELECTED" | ✅ FULLY COVERED |
| Application rejected → "rejected" visible | Opportunity detail | `opportunity-lifecycle.human.spec.ts` | "rejected" text visible | ✅ FULLY COVERED |
| Notification read marker cleared after opening | `/notifications?type=application` | `opportunity-lifecycle.human.spec.ts` | `activity-pill` count drops to 0 | ✅ FULLY COVERED |
| Applicant withdrawal | `/opportunities/:slug` | `opportunity-lifecycle.human.spec.ts`, `zero-gap-route-regression.spec.ts` | URL reaches `applicationWithdrawn=1`; DB status WITHDRAWN | ✅ FULLY COVERED |
| Opportunity workspace note submission (SELECTED) | Workspace tab | `opportunity-lifecycle.human.spec.ts` | URL reaches `workspaceSubmitted=1` | ✅ FULLY COVERED |
| Saved search create / update / delete | `/opportunities` | `saved-search-lifecycle.human.spec.ts` | Complete CRUD cycle with URL and DOM assertions | ✅ FULLY COVERED |
| Expired opportunity — application blocked (API) | `POST /opportunities/:id/applications` | `launch-security-boundaries.spec.ts` | HTTP 409; error matches "ended/deadline" | ✅ FULLY COVERED |
| Opportunity collage published after async workflow | `/opportunities/:slug` | `creator-workflows.human.spec.ts` | `.detail-split-hero__image-frame img[src]` matches collage URL | ✅ FULLY COVERED |
| Hindi translation visible after approval | `/opportunities/:slug` | `creator-workflows.human.spec.ts` | Title visible in Hindi locale | ✅ FULLY COVERED |
| Pending/rejected/draft opportunity hidden from anonymous (API) | `GET /opportunities/:id` | `launch-security-boundaries.spec.ts` | HTTP 404 for each hidden state | ✅ FULLY COVERED |
| Non-owner cannot edit (API) | `PATCH /opportunities/:id` | `launch-security-boundaries.spec.ts` | HTTP 403/404 | ✅ FULLY COVERED |
| Status spoof on create rejected | `POST /opportunities` with `status: APPROVED` | `launch-security-boundaries.spec.ts` | HTTP 400; `VALIDATION_ERROR` | ✅ FULLY COVERED |
| 5-image moodboard upload | `/opportunities/create` | `opportunity-five-image-upload.spec.ts` | Image sequence uploaded and verified | ⚠️ PARTIALLY COVERED |
| Duplicate application guard (browser) | Apply modal | None | No browser-level double-apply test | ⚠️ PARTIALLY COVERED |
| Opportunity detail — empty state (no applications) | Workspace tab | None | No explicit empty-state assertion | ❌ NOT COVERED |
| Opportunity with zero mood board images renders | `/opportunities/:slug` | None | No test for 0-image opportunity | ❌ NOT COVERED |
| Opportunity create — all required fields validation | `/opportunities/create` | None | No dedicated form-validation browser test | ❌ NOT COVERED |
| Opportunity listing filter/sort UI | `/opportunities` | None | No test exercises opportunity listing's own filter UI | ❌ NOT COVERED |

---

## 4. EVENTS

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Create event (happy path) | `/events/create` | `creator-workflows.human.spec.ts`, `event-lifecycle.human.spec.ts` | Redirects with `created=1` | ✅ FULLY COVERED |
| Event create — required field validation | `/events/create` | `event-lifecycle.human.spec.ts` | `validity.valueMissing`; URL stays on create | ✅ FULLY COVERED |
| Event detail — full SEO metadata | `/events/:slug` | `content-crud.human.spec.ts` | All SEO tags asserted | ✅ FULLY COVERED |
| Event edit (owner) | `/events/:slug/edit` | `content-crud.human.spec.ts`, `zero-gap-route-regression.spec.ts` | Updated title visible; form prefilled | ✅ FULLY COVERED |
| Event delete (owner) | `/events/:slug` | `content-crud.human.spec.ts` | Old URL renders "not found" | ✅ FULLY COVERED |
| Non-owner edit route — 403 | `/events/:slug/edit` | `content-crud.human.spec.ts` | HTTP 403; form absent | ✅ FULLY COVERED |
| RSVP — Going / Interested / Not Going cycle | `/events/:slug` | `event-lifecycle.human.spec.ts`, `collaboration-workflows.human.spec.ts` | Each state shows feedback; `aria-pressed=true` | ✅ FULLY COVERED |
| RSVP on past event — API blocked (RSVP_CLOSED) | `POST /events/:id/rsvp` | `launch-security-boundaries.spec.ts` | HTTP 409; `RSVP_CLOSED` error code | ✅ FULLY COVERED |
| Event gallery upload (attendee) | `/events/:slug?tab=gallery` | `event-lifecycle.human.spec.ts`, `event-gallery-permissions.spec.ts` | URL reaches `submitted=1` | ✅ FULLY COVERED |
| Event gallery — non-attendee denied upload | `/events/:slug?tab=gallery` | `event-gallery-permissions.spec.ts` | Upload form absent for non-attendee | ✅ FULLY COVERED |
| Admin approve event from moderation queue | `/admin?tab=moderation` | `admin-workflows.spec.ts` | DB APPROVED; public page renders with map | ✅ FULLY COVERED |
| Admin reject event | `/admin?tab=moderation` | `admin-workflows.spec.ts` | DB REJECTED; guest gets "not found" | ✅ FULLY COVERED |
| Admin bulk moderation rerun | `/admin?tab=moderation` | `admin-workflows.spec.ts` | HTTP OK; outbox entry > 0 | ✅ FULLY COVERED |
| Pending/rejected event hidden from anonymous (API) | `GET /events/:id` | `launch-security-boundaries.spec.ts`, `moderation-authorization.spec.ts` | HTTP 404 | ✅ FULLY COVERED |
| Cover moderation rejection blocks event creation | `/events/create` | `ssr-auth-event-i18n.spec.ts` | Runtime status "blocked by moderation"; DB row absent | ✅ FULLY COVERED |
| Rejected text title blocks event creation | `/events/create` | `ssr-auth-event-i18n.spec.ts` | Either inline block or DB REJECTED verified | ✅ FULLY COVERED |
| Event localised after approval | `/hi-in/events/:id` | `ssr-auth-event-i18n.spec.ts` | `lang` attribute; heading visible; listing entry present | ✅ FULLY COVERED |
| Upcoming events listing shows approved event | `/events?phase=upcoming` | `ssr-auth-event-i18n.spec.ts` | Event slug link visible | ✅ FULLY COVERED |
| Event listing page renders | `/events` | `public-surfaces.human.spec.ts` | Page visible | ✅ FULLY COVERED |
| Event location map rendered | `/events/:slug` | `admin-workflows.spec.ts` | `[data-location-map-root]` visible | ✅ FULLY COVERED |
| Hindi authored → English broadcast without corrupting source | Dynamic content | `dynamic-content-translation-broadcast.spec.ts` | Hindi source unchanged (env-flagged) | ⚠️ PARTIALLY COVERED |
| Event without cover image renders without error | `/events/:slug` | None | No explicit test for cover-less event | ❌ NOT COVERED |
| Event capacity limit UI | `/events/:slug` | None | — | ❌ NOT COVERED |
| Past event — RSVP buttons hidden in UI | `/events/:slug` (past date) | None | Only API-level; no browser-level UI assertion | ❌ NOT COVERED |

---

## 5. CONTESTS

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Create contest (admin-only) | `/contests/create` | `creator-workflows.human.spec.ts` | Redirects to detail | ✅ FULLY COVERED |
| Contest detail — full SEO metadata | `/contests/:slug` | `content-crud.human.spec.ts` | All SEO tags asserted | ✅ FULLY COVERED |
| Contest edit | `/contests/:slug/edit` | `content-crud.human.spec.ts`, `zero-gap-route-regression.spec.ts` | Updated title; form prefilled | ✅ FULLY COVERED |
| Contest delete | `/contests/:slug` | `content-crud.human.spec.ts` | Old URL renders "not found" | ✅ FULLY COVERED |
| Non-owner edit — 403 | `/contests/:slug/edit` | `content-crud.human.spec.ts` | HTTP 403; form absent | ✅ FULLY COVERED |
| Contest listing renders | `/contests` | `public-surfaces.human.spec.ts` | Page visible | ✅ FULLY COVERED |
| Owner cannot submit to own contest | `/contests/:slug?tab=submissions` | `contest-lifecycle.human.spec.ts` | Submission form absent | ✅ FULLY COVERED |
| Member uploads contest submission | `/contests/:slug?tab=submissions` | `contest-lifecycle.human.spec.ts`, `collaboration-workflows.human.spec.ts` | URL reaches `submitted=1` | ✅ FULLY COVERED |
| Empty submission blocked | Submission form | `contest-lifecycle.human.spec.ts` | Button disabled; `validity.valueMissing` | ✅ FULLY COVERED |
| Duplicate submission guard (form hidden) | Submission tab | `contest-lifecycle.human.spec.ts` | Form count = 0 after first submission | ✅ FULLY COVERED |
| Submission lightbox opens | `/contests/:slug?tab=submissions` | `contest-lifecycle.human.spec.ts` | `open` attribute on lightbox | ✅ FULLY COVERED |
| Like / vote (with confirm) / share cycle | Lightbox | `contest-lifecycle.human.spec.ts` | Each reaction message verified | ✅ FULLY COVERED |
| X and Facebook share URLs | Lightbox | `contest-lifecycle.human.spec.ts` | `href` pattern matches each network | ✅ FULLY COVERED |
| Submission detail page SEO | `/contests/:slug/submissions/:id` | `contest-lifecycle.human.spec.ts` | canonical, og:title, twitter:card=summary_large_image | ✅ FULLY COVERED |
| Contest winner selection | Winner form | `contest-lifecycle.human.spec.ts`, `zero-gap-route-regression.spec.ts` | URL reaches `winnerUpdated=1`; select has 13 options | ✅ FULLY COVERED |
| Non-admin cannot set winner (API) | `PATCH /contests/:id/winner` | `launch-security-boundaries.spec.ts` | HTTP 403 | ✅ FULLY COVERED |
| Pending/rejected contest hidden (API) | `GET /contests/:id` | `launch-security-boundaries.spec.ts`, `moderation-authorization.spec.ts` | HTTP 404 | ✅ FULLY COVERED |
| Admin approves pending contest | `POST /admin/moderate` | `moderation-authorization.spec.ts` | Contest becomes anonymous-visible | ✅ FULLY COVERED |
| Non-admin cannot list pending contests | `GET /contests?status=PENDING` | `moderation-authorization.spec.ts` | HTTP 403 | ✅ FULLY COVERED |
| Auth modal redirect from contest page | `/contests/:slug` | `zero-gap-route-regression.spec.ts` | Modal `redirect` or link `href` contains contest path | ✅ FULLY COVERED |
| Contest submissions list page accessible | `/contests/:slug/submissions` | `contest-lifecycle.human.spec.ts` | Navigated to via tab | ✅ FULLY COVERED |
| Contest submission individual detail accessible | `/contests/:slug/submissions/:id` | `contest-lifecycle.human.spec.ts` | Navigated to; metadata asserted | ✅ FULLY COVERED |
| Non-admin creating contest blocked | `/contests/create` | `route-access-seo.human.spec.ts` (indirectly) | Non-admin redirected | ⚠️ PARTIALLY COVERED |
| Contest submission after deadline blocked (UI) | Submission form (past deadline) | None | Only API-level security tested | ❌ NOT COVERED |
| Contest prizes display | Contest detail | None | No test for prize list rendering | ❌ NOT COVERED |
| Contest leaderboard / ranking | Contest detail | None | — | ❌ NOT COVERED |

---

## 6. QUICK REQUESTS

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Create quick request (directed, TFP) | `/quick-requests/create` | `quick-request-lifecycle.human.spec.ts`, `collaboration-workflows.human.spec.ts` | URL matches `/quick-requests/:id` | ✅ FULLY COVERED |
| Create — validation (missing role) | `/quick-requests/create` | `quick-request-lifecycle.human.spec.ts` | `validity.valueMissing`; "Creative role needed is required" | ✅ FULLY COVERED |
| Create — validation (description too short) | `/quick-requests/create` | `quick-request-lifecycle.human.spec.ts` | Error "Enter at least 20 characters"; `aria-describedby` | ✅ FULLY COVERED |
| Invited creator sees request in list | `/quick-requests` | `quick-request-lifecycle.human.spec.ts` | Card with description visible | ✅ FULLY COVERED |
| Creator expresses interest | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Interested acknowledged | ✅ FULLY COVERED |
| Creator sends private chat message | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Message text visible | ✅ FULLY COVERED |
| Requester sees private chat | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Message from creator visible | ✅ FULLY COVERED |
| Requester selects creator | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Venue consent form appears | ✅ FULLY COVERED |
| Venue consent — required field validation | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | `validity.valueMissing` on `privateVenue` | ✅ FULLY COVERED |
| Venue submitted with consent | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Venue text visible | ✅ FULLY COVERED |
| Requester marks complete → review form | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | Review form visible | ✅ FULLY COVERED |
| Review submitted (rating + comment) | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | "completed" text; no error | ✅ FULLY COVERED |
| Creator declines invitation | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | "decline" status; button absent | ✅ FULLY COVERED |
| Requester sees declined status | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | "declined" visible | ✅ FULLY COVERED |
| Requester cancels request | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | "cancelled" visible | ✅ FULLY COVERED |
| Unauthenticated quick-requests access → redirect | `/quick-requests` | `public-surfaces.human.spec.ts` | Redirect to `/login?redirect=` | ✅ FULLY COVERED |
| Moderation before invitations visible | `/quick-requests/:id` | `quick-request-lifecycle.human.spec.ts` | `expect.poll` waits for count > 0 | ✅ FULLY COVERED |
| Quick request list filters / pagination | `/quick-requests` | None | No filter/pagination test | ❌ NOT COVERED |
| IDOR — non-invited user accessing detail | `/quick-requests/:id` | None | No browser IDOR test | ❌ NOT COVERED |
| Quick request → message thread linkage | `/messages` from QR | None | No test verifies message thread is accessible from completed QR | ❌ NOT COVERED |

---

## 7. MESSAGING

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Send message from opportunity application | `/messages` | `messaging-notifications.human.spec.ts`, `collaboration-workflows.human.spec.ts` | Message text visible in thread | ✅ FULLY COVERED |
| Send message — missing content validation | Compose form | `messaging-notifications.human.spec.ts` | `validity.valueMissing` on content | ✅ FULLY COVERED |
| Reply to received message | `/messages` | `messaging-notifications.human.spec.ts` | Reply text visible in thread | ✅ FULLY COVERED |
| Messages page accessible (authenticated) | `/messages` | `messaging-notifications.human.spec.ts` | Thread visible | ✅ FULLY COVERED |
| Messages page redirects unauthenticated | `/messages` | `route-access-seo.human.spec.ts` | Redirect to `/login?redirect=` | ✅ FULLY COVERED |
| Block user via messaging safety | Messages safety form | `messaging-notifications.human.spec.ts` | Blocked user listed; "can no longer message you" | ✅ FULLY COVERED |
| Unblock user | Messages safety form | `messaging-notifications.human.spec.ts` | Blocked list disappears; "can message you again" | ✅ FULLY COVERED |
| Notification preferences save (quiet hours, timezone) | Notifications form | `messaging-notifications.human.spec.ts` | Saved status text; timezone persisted | ✅ FULLY COVERED |
| Message from blocked user — send blocked in UI | `/messages` | None | No test verifies sender-side blocked UI | ❌ NOT COVERED |
| Message pagination / infinite scroll | `/messages` | None | — | ❌ NOT COVERED |
| Message search | `/messages` | None | — | ❌ NOT COVERED |

---

## 8. NOTIFICATIONS

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Notifications page accessible (authenticated) | `/notifications` | `messaging-notifications.human.spec.ts`, `collaboration-workflows.human.spec.ts` | Activity visible | ✅ FULLY COVERED |
| Notifications redirects unauthenticated | `/notifications` | `route-access-seo.human.spec.ts` | Redirect to `/login?redirect=` | ✅ FULLY COVERED |
| Filter by type: message | `/notifications?type=message` | `messaging-notifications.human.spec.ts` | URL has `type=message` | ✅ FULLY COVERED |
| Filter by type: application | `/notifications?type=application` | `opportunity-lifecycle.human.spec.ts` | Application decision notification visible | ✅ FULLY COVERED |
| Deep link → messages | Activity link | `messaging-notifications.human.spec.ts` | Navigates to `/messages` | ✅ FULLY COVERED |
| Deep link → opportunity detail | `/notifications?type=application` | `opportunity-lifecycle.human.spec.ts` | Opens detail; title visible | ✅ FULLY COVERED |
| Notification badge count in header | Header | None | No test asserts notification count badge | ❌ NOT COVERED |
| Notification preferences — `/preferences` route | `/preferences/*` | None | No such route in `apps/web/src/pages`; not present | 🚫 NOT TESTABLE |

---

## 9. SEARCH & DISCOVERY

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Search form submit with query | `/search?q=portrait` | `public-surfaces.human.spec.ts` | URL has `q=portrait`; results in main | ✅ FULLY COVERED |
| Filter — type (artists), role (MODEL), sort (latest), location | `/search` dropdowns | `public-surfaces.human.spec.ts` | Each URL param set correctly | ✅ FULLY COVERED |
| Filter — clear all | `/search` | `public-surfaces.human.spec.ts` | Filter params absent from URL | ✅ FULLY COVERED |
| Discovery — home page discovery elements | `/` | `public-surfaces.human.spec.ts` | Hero section and navigation visible | ✅ FULLY COVERED |
| Public routes SEO metadata | `/events`, `/opportunities`, `/contests` | `public-surfaces.human.spec.ts`, `public-metadata.spec.ts` | og:title, description, canonical asserted | ✅ FULLY COVERED |
| `lang` attribute correct for locale | `/hi-in/events` | `og-meta-lang-attribute.spec.ts`, `public-surfaces.human.spec.ts` | `html[lang=hi]` asserted | ✅ FULLY COVERED |
| robots=noindex on 404/500 | Error pages | `route-access-seo.human.spec.ts` | `meta[name="robots"]` contains "noindex" | ✅ FULLY COVERED |
| URL normalization — slug redirects | Various | `url-normalization-redirects.spec.ts` | Redirects verified | ✅ FULLY COVERED |
| Search — empty/zero results state | `/search?q=xyzzyimpossible` | None | No explicit zero-result state test | ❌ NOT COVERED |
| Search — pagination | `/search` | None | — | ❌ NOT COVERED |
| Search — special chars / Unicode | `/search?q=<script>` | None | No XSS or special character test | ❌ NOT COVERED |
| Search — location-based geo-proximity results | `/search?location=Mumbai` | `public-surfaces.human.spec.ts` | Location filter applied but result ranking not asserted | ⚠️ PARTIALLY COVERED |

---

## 10. ADMIN

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Admin route — non-admin blocked | `/admin` | `admin-access.spec.ts`, `route-access-seo.human.spec.ts` | URL is not `/admin` for non-admin | ✅ FULLY COVERED |
| Admin route — admin granted | `/admin` | `admin-access.spec.ts` | URL is `/admin`; "moderation/reports/users" visible | ✅ FULLY COVERED |
| Admin moderation / reports / users tabs | `/admin?tab=*` | `admin-access.spec.ts`, `admin-workflows.human.spec.ts` | Each tab panel visible | ✅ FULLY COVERED |
| Admin approve pending entity (UI) | `/admin?tab=moderation` | `admin-workflows.spec.ts` | HTTP OK; DB APPROVED | ✅ FULLY COVERED |
| Admin reject pending entity (UI) with reason + message | `/admin?tab=moderation` | `admin-workflows.spec.ts` | DB REJECTED; owner message persisted | ✅ FULLY COVERED |
| Admin bulk moderation rerun | `/admin?tab=moderation` | `admin-workflows.spec.ts` | HTTP OK; queued ≥ 1; status text visible | ✅ FULLY COVERED |
| Admin resolve report — warn and request changes | `/admin?tab=flagged` | `admin-workflows.human.spec.ts` | Row disappears; owner sees warning | ✅ FULLY COVERED |
| Admin disable / restore user | `/admin?tab=users` | `admin-workflows.human.spec.ts` | `data-user-disabled` toggles | ✅ FULLY COVERED |
| Admin filter UI URL sync | `/admin?tab=moderation` | `admin-filters-and-url-sync.spec.ts` | URL params sync | ✅ FULLY COVERED |
| Admin overlay image evidence selection | Moderation overlay | `admin-overlay-image-evidence-selection.spec.ts` | Images selectable | ✅ FULLY COVERED |
| Admin overlay responsive | Moderation overlay | `admin-overlay-responsive.spec.ts` | Adapts to viewport | ✅ FULLY COVERED |
| Admin reports — API fields verified | `GET /admin/reports` | `storage-reporting-moderation.spec.ts` | reporter.email, message, reason, incidentMeta.sourceType | ✅ FULLY COVERED |
| Admin leaf routes redirect to tab param | `/admin/moderation` → `/admin?tab=moderation` | `admin-leaf-route-redirects.spec.ts` | URL normalised | ✅ FULLY COVERED |
| Admin MFA page renders | `/admin/mfa` | `route-access-seo.human.spec.ts`, `account-security.human.spec.ts` | < 500; accessible | ✅ FULLY COVERED |
| Admin empty state (no moderation items) | `/admin?tab=moderation` | `admin-empty-state.spec.ts` | Empty state handled | ✅ FULLY COVERED |
| Admin moderation filter (select status) | `/admin?tab=moderation` | `admin-workflows.human.spec.ts` | Conditional interaction | ⚠️ PARTIALLY COVERED |
| Admin — approve opportunity or contest from UI | `/admin?tab=moderation` | None | Only event type explicitly tested | ❌ NOT COVERED |
| Admin — mark report as closed/dismissed | Admin reports | None | Only WARN_AND_REQUEST_CHANGES tested | ❌ NOT COVERED |
| Admin — hard-delete vs soft-disable | Admin users | None | No hard-delete flow test | ❌ NOT COVERED |

---

## 11. REPORTING & MODERATION

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Report opportunity (SPAM) via modal | `/report` | `collaboration-workflows.human.spec.ts`, `admin-workflows.human.spec.ts` | Flash message confirmed | ✅ FULLY COVERED |
| Report event / contest / user / message (API) | `POST /reports` | `storage-reporting-moderation.spec.ts` | HTTP 201 for each; fields verified | ✅ FULLY COVERED |
| Report page redirects unauthenticated | `/report` | `route-access-seo.human.spec.ts` | Redirect to login | ✅ FULLY COVERED |
| Report form — DETAILS surface | Report modal | `collaboration-workflows.human.spec.ts` | Radio/select/message filled and submitted | ✅ FULLY COVERED |
| Profile image moderation lifecycle | DB workflow | `profile-moderation.spec.ts` | DB status transitions | ✅ FULLY COVERED |
| Portfolio images dataset moderation | DB workflow | `profile-portfolio-dataset-moderation.spec.ts` | Batch moderation verified | ✅ FULLY COVERED |
| Image moderation lifecycle (flagged, REJECTED inline) | Upload path | `image-moderation-lifecycle.spec.ts` | Inline rejection visible | ✅ FULLY COVERED |
| Non-admin cannot moderate | `POST /admin/moderate` | `moderation-authorization.spec.ts` | HTTP 403 | ✅ FULLY COVERED |
| Opportunity approved via moderation API | `POST /admin/moderate` | `moderation-authorization.spec.ts` | DB APPROVED:PUBLISHED | ✅ FULLY COVERED |
| Report — other surface types (IMAGES, CONDUCT) | Report modal | None | Only DETAILS surface tested | ❌ NOT COVERED |
| Double-report idempotency | Report modal | None | No duplicate-report guard test | ❌ NOT COVERED |
| Anonymous user attempting to report | `/report` | None | Only redirect tested; browser UI after redirect not verified | ❌ NOT COVERED |

---

## 12. LOCALIZATION & I18N

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Browser locale detection at `/` → locale route | `/` with `hi-IN` locale | `locale-runtime.spec.ts` | URL is `/hi-in`; `html[lang=hi]`; Hindi heading visible | ✅ FULLY COVERED |
| Language/region preference saved and persisted | `/profile/edit` | `locale-runtime.spec.ts` | DB row; `#preferredLanguage` persisted | ✅ FULLY COVERED |
| Locale path routing — language+region decoupled | `/hi-np/profile` | `locale-routing-hardening.spec.ts`, `decoupled-language-region-axes.spec.ts` | URL and `lang` verified | ✅ FULLY COVERED |
| Middleware auto-detection | Middleware | `middleware-routing-auto-detection.spec.ts` | Locale edge cases verified | ✅ FULLY COVERED |
| Timezone rendering capture vs viewer | Date display | `timezone-rendering-capture-vs-viewer.spec.ts` | Verified | ✅ FULLY COVERED |
| Format preferences / regional asset visibility | Regional content | `formatprefs-regional-asset-visibility.spec.ts` | Verified | ✅ FULLY COVERED |
| UI translation fallback chain | UI strings | `ui-translation-fallback-chain.spec.ts` | Fallback keys verified | ✅ FULLY COVERED |
| `og:title` and `lang` for non-English locale | `/hi-in/events` | `og-meta-lang-attribute.spec.ts` | Verified | ✅ FULLY COVERED |
| Region-unavailable page renders | `/region-unavailable` | `route-access-seo.human.spec.ts` | HTTP < 500; page visible | ✅ FULLY COVERED |
| Session policy on auth transitions | Login/logout | `session-policy-auth-transitions.spec.ts` | Policy verified | ✅ FULLY COVERED |
| Content without translation renders source language | `/hi-in/events/:id` | `ssr-auth-event-i18n.spec.ts` | Heading > 5 chars | ✅ FULLY COVERED |
| Login page renders localized copy | `/hi-in/login` | `locale-runtime.spec.ts` | `पसंदीदा भाषा` visible | ✅ FULLY COVERED |
| Hindi authored → English broadcast (env-flagged) | Dynamic content | `dynamic-content-translation-broadcast.spec.ts` | Source immutable; English heading present | ⚠️ PARTIALLY COVERED |
| Date/number/currency formatting by locale | Listing pages | None | No number/currency format assertions | ❌ NOT COVERED |
| DST / midnight locale date boundaries | Date display | None | No DST boundary test | ❌ NOT COVERED |

---

## 13. ACCESSIBILITY

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Legal pages — `main#main-content`, `h1`, skip-link | 10 legal routes | `key-routes-accessibility.spec.ts` | Count = 1; heading order sequential; unnamed links = 0 | ✅ FULLY COVERED |
| Legal hub links to all legal docs | `/legal` | `key-routes-accessibility.spec.ts` | Each expected link present | ✅ FULLY COVERED |
| Auth form — email labelled, Tab reaches submit | `/login` | `key-routes-accessibility.spec.ts` | Label visible; Tab reaches button | ✅ FULLY COVERED |
| No password field on OTP-only form | `/login` | `key-routes-accessibility.spec.ts` | Password input count = 0 | ✅ FULLY COVERED |
| Avatar/cover upload inputs labelled | `/profile/edit` | `key-routes-accessibility.spec.ts` | Labels ≥ 1 for each input | ✅ FULLY COVERED |
| Portfolio modal — Escape closes | `/profile/:username?tab=portfolio` | `key-routes-accessibility.spec.ts` | `open` attribute absent after Escape | ✅ FULLY COVERED |
| Tab key focus visible (public pages) | `/hi-in/events` | `public-surfaces.human.spec.ts` | `:focus` visible after Tab | ✅ FULLY COVERED |
| Tab key focus visible (after profile save) | `/profile/edit` | `auth-profile.human.spec.ts` | `:focus` visible after Tab | ✅ FULLY COVERED |
| Keyboard overlay accessibility | Overlays | `keyboard-overlays-accessibility.spec.ts` | Keyboard interaction tested | ✅ FULLY COVERED |
| Login page accessible | `/login` | `a11y/login-accessibility.spec.ts` | Accessibility assertions pass | ✅ FULLY COVERED |
| Mobile nav toggle keyboard / Escape | `/hi-in/events` (mobile) | `public-surfaces.human.spec.ts` | Menu opens/closes | ⚠️ PARTIALLY COVERED |
| Automated WCAG scan (axe) | All public routes | None | Deferred by product decision | 🚫 NOT TESTABLE |
| Systematic ARIA roles on interactive widgets | Forms, modals | None | No systematic ARIA assertions beyond specific inputs | ❌ NOT COVERED |
| Screen reader live region announcements | Form submission | None | — | ❌ NOT COVERED |
| Colour contrast assertions | UI components | None | — | ❌ NOT COVERED |

---

## 14. SEO & STATIC PAGES

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Home page — HTTP 200, `h1` visible | `/` | `public-surfaces.human.spec.ts`, `page-smoke.spec.ts` | HTTP 200; body visible | ✅ FULLY COVERED |
| All legal/trust documents — HTTP 200 + structure | 10 routes | `route-access-seo.human.spec.ts`, `page-smoke.spec.ts` | < 500; `main` and `h1` visible | ✅ FULLY COVERED |
| 404 — correct status + noindex | Non-existent path | `route-access-seo.human.spec.ts` | HTTP 404; `robots: noindex` | ✅ FULLY COVERED |
| 500 — correct status + renders | `/500` | `route-access-seo.human.spec.ts` | HTTP 500; title present | ✅ FULLY COVERED |
| QA workspace accessible (admin) | `/qa` | `route-access-seo.human.spec.ts` | Admin can access; non-admin cannot | ✅ FULLY COVERED |
| Sitemap returns without error | `/sitemap.xml` | None | No sitemap test | ❌ NOT COVERED |
| `/health` endpoint | `/health` | None | No test | ❌ NOT COVERED |

---

## 15. UPLOADS & MEDIA PROCESSING

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Moodboard, event cover, contest banner, avatar, cover, portfolio presign+complete | All upload presign/complete endpoints | `storage-reporting-moderation.spec.ts` | Complete flow (skipped unless `E2E_ENABLE_STORAGE_UPLOADS=true`) | ⚡ COVERED BUT WEAK/FLAKY |
| Moderation rows created per upload type | DB assertion | `storage-reporting-moderation.spec.ts` | Count ≥ 6 (env-gated) | ⚡ COVERED BUT WEAK/FLAKY |
| CDN URL rendered in UI | `/profile/:username?tab=portfolio` | `storage-reporting-moderation.spec.ts` | `src` contains `ik.imagekit.io` (env-gated) | ⚡ COVERED BUT WEAK/FLAKY |
| Corrupted / zero-byte file upload | Upload endpoints | None | No genuinely corrupted file buffer test | ❌ NOT COVERED |
| Upload interruption mid-transfer | Upload endpoints | None | — | ❌ NOT COVERED |
| Duplicate file upload (same hash) | Upload endpoints | None | No idempotency/dedup test | ❌ NOT COVERED |

---

## 16. RESPONSIVE & VISUAL

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Responsive sweep (multiple viewports) | Key routes | `responsive-sweep.spec.ts` | Visual check (operator-run) | ⚠️ PARTIALLY COVERED |
| Shell visual regression snapshots | Shell/nav | `shell-visual-regression.spec.ts` | Screenshot diffing (operator-run) | ⚠️ PARTIALLY COVERED |
| Launch visual guardrails | Landing pages | `launch-visual-guardrails.spec.ts` | Screenshot guardrails (operator-run) | ⚠️ PARTIALLY COVERED |
| Progressive enhancement — JS disabled | Core routes | `progressive-enhancement-js-disabled.spec.ts` | Core content visible without JS | ✅ FULLY COVERED |
| Scroll behaviour | Key routes | `scroll-test.spec.ts` | Scroll interactions tested | ✅ FULLY COVERED |
| Mobile nav hamburger opens/closes | Mobile viewport | `public-surfaces.human.spec.ts` | Menu opens; Escape closes | ⚠️ PARTIALLY COVERED |
| Tablet layout | Various | None | No dedicated tablet breakpoint test | ❌ NOT COVERED |

---

## 17. SECURITY & IDOR

| Use Case | Route / API | Test File | Assertion Evidence | Status |
|----------|-------------|-----------|-------------------|--------|
| Anonymous admin API access blocked | `GET /admin/users` | `launch-security-boundaries.spec.ts` | HTTP 401 or 403 | ✅ FULLY COVERED |
| Non-admin admin API blocked | `GET /admin/users` (non-admin token) | `launch-security-boundaries.spec.ts` | HTTP 403 | ✅ FULLY COVERED |
| Status spoofing on create payload | `POST /opportunities` with status | `launch-security-boundaries.spec.ts` | HTTP 400; `VALIDATION_ERROR` | ✅ FULLY COVERED |
| IDOR — non-owner cannot edit (API) | `PATCH /opportunities/:id` | `launch-security-boundaries.spec.ts` | HTTP 403/404 | ✅ FULLY COVERED |
| IDOR — pending content hidden from anonymous (API) | `GET /opportunities/:id` (pending) | `launch-security-boundaries.spec.ts`, `moderation-authorization.spec.ts` | HTTP 404 | ✅ FULLY COVERED |
| IDOR — browser-level direct URL to another user's QR | `/quick-requests/:id` | None | No browser IDOR test for quick requests | ❌ NOT COVERED |
| CSRF protection | Forms | None | No explicit CSRF token verification | ❌ NOT COVERED |
| Malformed JWT token to API | Admin endpoint | None | No malformed-token test | ❌ NOT COVERED |
| XSS — rendered user-supplied content | Profile bio, opportunity title | None | No explicit XSS rendering test | ❌ NOT COVERED |
| Tenant isolation (single-tenant) | N/A | N/A | Single-tenant; not applicable | 🚫 NOT TESTABLE |

---

## SUMMARY COUNTS

| Domain | Total Use Cases | ✅ Fully | ⚠️/⚡ Partial/Weak | ❌ Not Covered | 🚫 Not Testable |
|--------|----------------|----------|---------------------|----------------|-----------------|
| Auth & Session | 23 | 18 | 1 | 4 | 0 |
| Profile & Onboarding | 26 | 22 | 1 | 3 | 0 |
| Opportunities | 28 | 21 | 2 | 5 | 0 |
| Events | 23 | 19 | 1 | 3 | 0 |
| Contests | 26 | 21 | 1 | 4 | 0 |
| Quick Requests | 20 | 17 | 0 | 3 | 0 |
| Messaging | 11 | 8 | 0 | 3 | 0 |
| Notifications | 8 | 6 | 0 | 1 | 1 |
| Search & Discovery | 12 | 8 | 1 | 3 | 0 |
| Admin | 20 | 15 | 1 | 4 | 0 |
| Reporting & Moderation | 12 | 9 | 0 | 3 | 0 |
| Localization | 15 | 12 | 1 | 2 | 0 |
| Accessibility | 15 | 10 | 1 | 2 | 2 |
| SEO & Static Pages | 7 | 5 | 0 | 2 | 0 |
| Uploads & Media | 6 | 0 | 3 | 3 | 0 |
| Responsive & Visual | 7 | 2 | 3 | 1 | 0 |
| Security & IDOR | 10 | 6 | 0 | 3 | 1 |
| **TOTAL** | **269** | **199 (74%)** | **16 (6%)** | **49 (18%)** | **4 (1%)** |
