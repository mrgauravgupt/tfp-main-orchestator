# Manual Browser QA Report

Date: 2026-04-11
Base URL: `http://localhost:3000/en-in`
Scope: All user-facing and admin features outside auth flows
Roles used: `guest`, `photo@tfp.local`, `model@tfp.local`, `admin@tfp.local`
Credential baseline used in this run: seeded `@tfp.local` users with `Seed123!`

### 1. Executive Summary
- Total features tested: 43
- Pass count: 28
- Fail count: 2
- Partial count: 2
- Blocked count: 11
- Critical issues count: 0
- Highest-risk areas: contest submission detail flow, contest resource stability on contest pages, notification seen/read behavior, incomplete admin-action coverage after environment recovery

### 2. Feature-by-Feature Status Matrix
- Public Home: Pass
- Public Search Page Load: Pass
- Search Filters / Sorting / Pagination: Blocked
- Profile Directory: Pass
- Public Profile Layout: Pass
- Public Profile Portfolio Visibility: Pass
- Profile Edit Basic Fields: Pass
- Profile Avatar Upload: Pass
- Profile Cover Upload: Blocked
- Portfolio Upload: Pass
- Portfolio Delete: Blocked
- My Activity Summary Surface: Pass
- Projects Listing: Pass
- Project Detail Layout: Pass
- Project Detail CTA Visibility: Pass
- Project Create Page Load: Pass
- Project Create Submission: Blocked
- Project Application Create: Blocked
- Events Listing: Pass
- Event Detail Layout: Pass
- Event Create Page Load: Pass
- Event Create Submission: Blocked
- Event RSVP Action: Pass
- Contests Listing: Pass
- Contest Detail Layout: Partial
- Contest Create Page Load: Pass
- Contest Create Submission: Blocked
- Contest Submissions Listing: Partial
- Contest Submission Detail: Fail
- Contest Reaction / Vote Flow: Blocked
- Messages Conversation List: Pass
- Message Send: Pass
- Message Block / Unblock: Blocked
- Notifications List: Pass
- Notifications Read / Seen State: Fail
- Report Form Load: Pass
- Report Submission: Pass
- Admin Workspace Load: Pass
- Admin Users Tab: Pass
- Admin Reports Tab: Pass
- Admin Moderation Tab: Pass
- Admin Moderation Approve / Reject: Blocked
- Admin Appeals / Lifecycle Controls: Blocked

### 3. Detailed Issues
- Search Filters / Sorting / Pagination: Blocked
  Severity: Low
  Role used: guest
  Page/route: `/en-in/search`
  Reproduction steps: Open search page and verify base load; deeper filter/sort/pagination actions were not completed in this pass.
  Expected result: Filters, sorting, and pagination should be exercised and confirmed.
  Actual result: Only page-load coverage was completed.
  Persists after refresh: Yes
  Likely area impacted: Search QA coverage gap, not a confirmed product defect
  Screenshot reference: none

- Profile Cover Upload: Blocked
  Severity: Low
  Role used: generated browser QA users
  Page/route: `/en-in/profile/edit`
  Reproduction steps: Avatar and portfolio upload were exercised through the browser harness; cover upload was not separately executed in the restored environment.
  Expected result: Cover image upload should complete and persist.
  Actual result: Not executed in this pass.
  Persists after refresh: Yes
  Likely area impacted: Profile media coverage gap
  Screenshot reference: none

- Portfolio Delete: Blocked
  Severity: Low
  Role used: generated browser QA users
  Page/route: `/en-in/profile/edit`
  Reproduction steps: Upload portfolio assets, then try delete.
  Expected result: Image should be removable from edit view and public profile.
  Actual result: Delete was not executed in this pass.
  Persists after refresh: Yes
  Likely area impacted: Portfolio lifecycle coverage gap
  Screenshot reference: none

- Project Create Submission: Blocked
  Severity: Medium
  Role used: photographer
  Page/route: `/en-in/projects/create`
  Reproduction steps: Open create page; submit flow was deferred after the environment recovery.
  Expected result: Full create flow should publish or show validation/moderation feedback.
  Actual result: Only page-load and form-presence were confirmed.
  Persists after refresh: Yes
  Likely area impacted: Project creation coverage gap
  Screenshot reference: none

- Project Application Create: Blocked
  Severity: Medium
  Role used: model
  Page/route: `/en-in/projects/cmntyc90c00be9f942ghqe99d`
  Reproduction steps: Open seeded project detail while logged in as model.
  Expected result: Apply CTA should be available on an open/applicable project, then persist into applications surfaces.
  Actual result: The tested seeded project rendered completed-phase content and no safe application CTA was available in this pass.
  Persists after refresh: Yes
  Likely area impacted: Application flow coverage gap caused by fixture state
  Screenshot reference: none

- Event Create Submission: Blocked
  Severity: Medium
  Role used: photographer
  Page/route: `/en-in/events/create`
  Reproduction steps: Open create page; submit flow was not completed in this pass.
  Expected result: Full event creation should publish or show validation/moderation feedback.
  Actual result: Only page-load coverage was completed.
  Persists after refresh: Yes
  Likely area impacted: Event creation coverage gap
  Screenshot reference: none

- Contest Detail Layout: Partial
  Severity: Medium
  Role used: guest
  Page/route: `/en-in/contests/cmntyc9i502839f94r5s0gzkk`
  Reproduction steps: Open active contest detail as guest.
  Expected result: Contest detail should render with no failed resource/network behavior.
  Actual result: Page rendered and major CTAs were visible, but browser console captured repeated `429 Too Many Requests` resource failures on the page.
  Persists after refresh: Yes, seen on contest surfaces in the same pass
  Likely area impacted: Contest detail SSR/client resource loading, rate limiting, or contest page fetch fan-out
  Screenshot reference: none

- Contest Create Submission: Blocked
  Severity: Medium
  Role used: admin
  Page/route: `/en-in/contests/create`
  Reproduction steps: Open admin contest create page.
  Expected result: Admin should be able to submit a contest and land on list/detail successfully.
  Actual result: Page load was confirmed, but submit was not completed directly in this pass. A separate browser harness attempting full contest creation became unstable around admin create redirection and did not yield a clean end-to-end result.
  Persists after refresh: Yes
  Likely area impacted: Contest create coverage gap, potential session/redirect fragility
  Screenshot reference: none

- Contest Submissions Listing: Partial
  Severity: Medium
  Role used: guest
  Page/route: `/en-in/contests/cmntyc92500cw9f94otb9ycbh/submissions`
  Reproduction steps: Open seeded contest submissions listing for `Street Photography Challenge`.
  Expected result: Listing should load without network/resource failures and support drilldown to detail.
  Actual result: Listing rendered, but browser console again captured repeated `429 Too Many Requests` resource failures.
  Persists after refresh: Yes, observed in the same session
  Likely area impacted: Contest submissions page fetch/resource stability
  Screenshot reference: none

- Contest Submission Detail: Fail
  Severity: High
  Role used: model
  Page/route: `/en-in/contests/cmntyc92500cw9f94otb9ycbh/submissions/cmntyc92h00gg9f94pxvr6r9g`
  Reproduction steps: Log in as `model@tfp.local` -> open `/en-in/contests/cmntyc92500cw9f94otb9ycbh/submissions` -> click the first submission link.
  Expected result: Submission detail page should open with media, metadata, and reaction controls.
  Actual result: The route lands on an error state with copy starting `Error The requested item could n...`; no usable submission detail UI or reaction controls render.
  Persists after refresh: Yes
  Likely area impacted: Contest submission detail route resolution, submission lookup, or SSR detail data loading
  Screenshot reference: none

- Contest Reaction / Vote Flow: Blocked
  Severity: Medium
  Role used: model
  Page/route: contest submission detail under `/en-in/contests/.../submissions/...`
  Reproduction steps: Attempt to open seeded submission detail and interact with Like/Vote controls.
  Expected result: Logged-in users should be able to access the detail page and exercise reactions where lifecycle rules permit.
  Actual result: Reaction testing was blocked because the tested submission detail page failed before controls became usable.
  Persists after refresh: Yes
  Likely area impacted: Downstream effect of the submission detail failure
  Screenshot reference: none

- Message Block / Unblock: Blocked
  Severity: Low
  Role used: photographer
  Page/route: `/en-in/messages`
  Reproduction steps: Open messages and inspect conversation controls.
  Expected result: Block/unblock controls should be directly exercisable on a conversation/user.
  Actual result: Messaging load and send were verified, but block/unblock controls were not cleanly surfaced/executed in the time-bounded pass.
  Persists after refresh: Yes
  Likely area impacted: Messaging controls coverage gap
  Screenshot reference: none

- Notifications Read / Seen State: Fail
  Severity: Medium
  Role used: photographer
  Page/route: `/en-in/notifications`
  Reproduction steps: Log in as `photo@tfp.local` -> open `/en-in/notifications` -> reload the page.
  Expected result: Viewing notifications should clear seen state or expose an obvious mark-seen action that updates unread state.
  Actual result: The unread indicator remained at `1` and the `Messages 1` activity group persisted after reload; no visible seen-state transition was observed.
  Persists after refresh: Yes
  Likely area impacted: Notifications seen endpoint wiring, SSR state refresh, or unread badge derivation
  Screenshot reference: none

- Admin Moderation Approve / Reject: Blocked
  Severity: Medium
  Role used: admin
  Page/route: `/en-in/admin?tab=moderation`
  Reproduction steps: Open admin moderation workspace after login.
  Expected result: Safe, deterministic approve/reject should be executed against a pending item and reflected after reload.
  Actual result: Workspace load was confirmed, but a stable pending item was not executed in this pass after the environment recovery. Dialog/button markup was present, but action confirmation was not completed.
  Persists after refresh: Yes
  Likely area impacted: Admin moderation action coverage gap
  Screenshot reference: none

- Admin Appeals / Lifecycle Controls: Blocked
  Severity: Low
  Role used: admin
  Page/route: `/en-in/admin`
  Reproduction steps: Open admin workspace and inspect available controls.
  Expected result: Appeals and lifecycle controls should be exercised end to end.
  Actual result: The tabs/workspace loaded, but appeals/lifecycle actions were not executed in this pass.
  Persists after refresh: Yes
  Likely area impacted: Admin control coverage gap
  Screenshot reference: none

### 4. UX / Layout / Polish Findings
- Contest pages are visually usable, but repeated `429` failures during contest detail/submission browsing create confidence risk around media and secondary data hydration.
- The notifications page copy explains that activity clears after review, but the visible unread count did not clear during the pass; this makes the UX promise feel inaccurate.
- Profile edit renders a busy header state with activity and navigation elements competing with the edit form, which makes the page feel denser than it needs to be.
- Admin routes normalize into query-tab URLs correctly, but the workspace depends heavily on hidden dialogs and secondary controls; action affordances are not immediately obvious from the first screen.
- Messages page is functional, but the block/unblock affordance is not obvious from the primary conversation view.

### 5. Retest Notes
- Frontend and backend were restarted before the pass.
- During QA, the local database was unintentionally truncated by the repo Playwright global setup. The baseline was restored by syncing the DB schema with `prisma db push --accept-data-loss` and rerunning `packages/database/prisma/seed.ts`.
- After restore, public route checks, authenticated route checks, report submission, message send, and RSVP were re-run against the restored dataset.
- Contest submission detail was revalidated via direct list-to-detail navigation and remained broken.
- Notifications unread state was rechecked by refresh and remained stale.

### 6. Final Validation Statement
- The app is not production-ready outside auth yet.
- The primary release blockers from this pass are the broken contest submission detail flow and the stale notification seen/read behavior.
- Contest pages also show resource/rate-limit instability under normal browser navigation, which lowers confidence in contest reliability.
- Large parts of the UI do load correctly: home, search shell, profile directory/detail, profile edit, avatar upload, portfolio upload, messages, report submission, RSVP, and core admin tabs.
