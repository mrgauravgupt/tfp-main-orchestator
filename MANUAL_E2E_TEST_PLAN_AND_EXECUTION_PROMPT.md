# Manual-Only E2E Test Plan and Non-Stop Execution Prompt

## Objective
Run a fully manual, end-to-end quality cycle across UI, FE, BE, and DB using only interactive browser/computer usage (no scripts, no automated test runners, no seeded automation flows), then fix issues and retest in continuous loops until no significant issues remain.

## Strict Operating Constraints
- Use only manual interaction through browser/computer use.
- Do not use test scripts, automation scripts, CI test jobs, or scripted seed flows.
- Do not use scripted browser automation, Playwright flows, or capture scripts for execution decisions.
- Do not mark a testcase complete unless a human-like manual UI path was performed end-to-end.
- Default to TEST environment unless explicitly changed.
- Do not pause between phases.
- Do not stop at recommendations.
- Do not commit in the middle of the cycle.
- Commit only after the final comprehensive validation pass is complete.

## Execution Baseline (Required Before Phase 1)
- Begin immediately. Start at Phase 1 and continue without interruption until final report publication.
- Use deterministic starting state before test execution:
  - Preferred: run `pnpm qa:test:reset`
  - Fallback: run `pnpm db:reset`
- Confirm service URLs:
  - Web: `http://localhost:3000`
  - API health: `http://localhost:4000/health`
- Use explicit role accounts for role-matrix testing:
  - Admin: `admin@tfp.local` / `Admin123!`
  - Creator/Photo role: `photo@tfp.local` / `Photo123!`
  - User/Model role: `model@tfp.local` / `Model123!`
- Save all evidence in one run folder:
  - `test-results/manual-qa-run/<YYYYMMDD-HHMM>/`

## App-Specific Mandatory Coverage (Completion Gate)
The cycle is not complete unless all domains below are manually validated:
- Messaging/DMs (`/{locale}/messages`): conversation start, send, receive, unread/read state, empty inbox.
- Notifications (`/{locale}/notifications` + bell): trigger, delivery, unread badge, mark-as-read.
- Reports/Moderation UX: report profile/opportunity/event/contest, duplicate report prevention, reporter feedback, admin triage.
- Media Upload Pipeline: presign, upload, finalize, moderation state, publish visibility.
- Contest Invariants: one-submission-per-user, one-vote-per-user, admin winner selection and visibility.
- Locale Routing: `/{language}/{region}/...` switching, URL correctness, canonical/alternate behavior, localized content rendering.
- Auth Modal Suppression: auth/legal/static pages should follow suppression rules and not show incorrect modal prompts.
- Role Access Matrix: guest, user/creator, owner, admin route/action access boundaries.
- Events RSVP: RSVP create/update/cancel with reflected state changes.
- Redirect Preservation: protected route access as guest should preserve target after login.
- Search Correctness: only publicly approved content appears in public search/discovery.
- Admin Workspace: moderation, reports triage, users/management tabs and actions.
- Legal/Static Pages: privacy, terms, guidelines, disclaimer load and render at all breakpoints.

## End-to-End Manual Coverage Plan

### 1. Environment and Baseline
- Restart FE and BE for a fresh verification pass.
- Confirm app loads and key entry pages render.
- Confirm authentication entry points and core navigation are reachable.
- Capture baseline screenshots of primary pages.

### 2. Authentication and Session Flows
- Login with valid credentials.
- Login with invalid credentials.
- Logout and session invalidation behavior.
- Session persistence across refresh and navigation.
- Unauthorized route access behavior.

### 3. Global UI and Navigation
- Header, sidebar, menus, breadcrumbs.
- All visible buttons, links, icon actions.
- Search, sort, filter, pagination where available.
- Modal open/close behavior (button, outside click, Esc).
- Toasts, alerts, inline errors, empty states, loading states.

### 4. Per-Module Functional Coverage (Manual CRUD + Validations)
For each module/screen in the application:
- Create: fill every field via UI and submit.
- Read: verify list and details display.
- Update: edit key fields and save.
- Delete/archive/restore (if supported).
- Field validation: required, format, boundaries, duplicate values, special chars.
- Cancel/back/unsaved-changes behavior.
- Error handling on failed actions.

### 5. FE ↔ BE ↔ DB Consistency Checks (Manual)
For each critical business flow:
- Verify UI result.
- Verify backend-visible outcomes through available admin/data views.
- Verify persisted data consistency from application-visible records.
- Validate relationships, status transitions, timestamps/audit values if exposed.
- Validate no user-facing raw stack traces or broken states.

### 6. Responsive and Breakpoint Coverage
- Desktop wide, laptop, tablet, mobile widths.
- Required viewport widths:
  - 1440px (desktop wide)
  - 1280px (laptop)
  - 768px (tablet)
  - 375px (mobile)
- Check overflow, clipping, misalignment, overlap, sticky/fixed behavior.
- Verify all actions remain usable at each breakpoint.
- Capture screenshots for each major page per breakpoint.

### 7. Theme and Visual Quality
- Test all supported themes on major screens.
- Detect hardcoded color issues and contrast failures.
- Verify spacing rhythm and visual hierarchy.
- Check form controls, tables, badges, chips, and alerts in each theme.

### 8. Negative and Resilience Scenarios
- Invalid inputs and edge-case payload-like values through UI.
- Duplicate click/rapid submit behavior.
- Recoverability from failed operations.
- Reopen and retry behavior without stale UI corruption.

### 9. Accessibility Manual Procedure (Required)
- For each major modal/dialog (auth, report, country picker, confirm dialog):
  - Verify Tab traversal stays inside modal while open (focus trap).
  - Verify `Esc` closes modal when expected by UX.
  - Verify focus returns to triggering control after close.
  - Verify visible focus indicator is present on all keyboard-focusable controls.
- Verify keyboard-only navigation for top navigation, forms, and primary CTA paths.

### 10. Defect Handling Workflow
For each issue:
- Reproduce and document.
- Capture screenshot evidence.
- Classify severity and impact.
- Fix code with minimal, safe scope.
- Retest the exact failing path.
- Run nearby regression checks on impacted flows.

### 11. Iterative Completion Rule
- Repeat the full cycle until no significant issues remain.
- Significant issues include broken functionality, data inconsistency, severe UX defects, accessibility blockers, security/privacy risk, or major responsiveness/theme regressions.
- Do not exit the cycle while any App-Specific Mandatory Coverage domain remains partially tested.

## Manual QA Checklist (TODO)
- [ ] FE/BE restarted and baseline verified.
- [ ] Auth/session flows fully tested.
- [ ] Every screen opened and exercised.
- [ ] Every visible CTA/button/link/icon clicked.
- [ ] Every form field tested with valid + invalid + boundary values.
- [ ] CRUD completed for each entity/module.
- [ ] Sorting/filtering/search/pagination tested where present.
- [ ] Error states validated for all major flows.
- [ ] Role/permission behavior verified.
- [ ] Breakpoint coverage completed (desktop/tablet/mobile).
- [ ] Theme coverage completed (all supported themes).
- [ ] FE-BE-DB consistency validated for critical flows.
- [ ] Defects logged with screenshots and fixed.
- [ ] Regression completed for all fixed areas.
- [ ] Final smoke pass completed with no significant issues.
- [ ] Final report prepared after comprehensive cleanup/refactor/validation.
- [ ] Messaging/DM domain fully validated.
- [ ] Notifications domain fully validated.
- [ ] Reports/moderation reporting + triage validated.
- [ ] Media upload pipeline fully validated end-to-end.
- [ ] Contest invariants validated (1 submission/user, 1 vote/user, winner flow).
- [ ] Locale switch and localized routing validated.
- [ ] Auth modal suppression rules validated on auth/legal pages.
- [ ] Role-based access matrix validated (guest/user/owner/admin).
- [ ] RSVP workflow validated.
- [ ] Protected-route redirect preservation validated.
- [ ] Public search correctness validated (public/approved-only).
- [ ] Admin workspace tabs/actions validated.
- [ ] Legal/static pages validated across breakpoints.
- [ ] Keyboard navigation, focus order, and modal focus trap validated.
- [ ] Guest vs logged-in UI deltas validated.
- [ ] Rapid-submit idempotency validated at persisted data level.

## Defect Log Template
- ID:
- Title:
- Module/Screen:
- Severity:
- Preconditions:
- Repro Steps:
- Expected:
- Actual:
- Screenshot Path:
- Suspected Layer (UI/FE/BE/DB):
- Fix Summary:
- Retest Status:

## Non-Stop Execution Prompt (Enhanced)
Use the following prompt verbatim when you want an agent/operator to execute this process continuously without interruption:

```text
Execute a complete manual-only end-to-end application quality cycle using browser/computer interaction only.

Hard constraints:
1) No scripts or automation for testing, seeding, or execution.
2) Perform real manual UI interaction for every feature and screen.
3) Cover UI, FE behavior, BE outcomes, and DB-consistency checks through application-visible flows.
4) Validate all breakpoints (desktop/tablet/mobile), themes, and major user journeys.
5) Capture screenshots for baseline, defects, and post-fix verification.
6) For each issue: reproduce -> document -> fix -> retest -> run adjacent regression.
7) Repeat until no significant issues remain.
8) Produce the final report only after the repo is comprehensively cleaned, refactored, and validated.
9) Mandatory domains must all pass: messaging, notifications, reports/moderation, media upload pipeline, contest invariants, locale routing, role matrix, RSVP, redirect preservation, admin workspace, legal/static pages, search correctness.
10) Begin immediately at environment baseline, then Phase 1, and continue without waiting for additional prompts.
11) Use baseline URLs `http://localhost:3000` and `http://localhost:4000/health`.
12) Save all screenshots/evidence under `test-results/manual-qa-run/<timestamp>/`.

Mandatory execution behavior:
- Do not stop at recommendations.
- Do not stop after one pass.
- Do not leave obvious clutter behind.
- Do not commit in the middle.
- Do not pause between phases.
- As soon as one phase completes, immediately begin the next.
- Execute continuously in a loop: review -> document -> fix -> validate -> repeat.
- Keep iterating until all obvious issues, clutter, and incomplete work are resolved and the result is fully validated.
- Do not mark completion if any required domain was skipped, partially covered, or not retested after fixes.
- Do not mark completion if deterministic baseline reset, role-account coverage, breakpoint width checks, and accessibility modal checks were not completed.

Output requirements:
- Maintain a running defect log with severity and screenshot evidence.
- Maintain a pass/fail checklist for each module and breakpoint.
- Maintain retest evidence for every fix.
- Publish final report only at the very end with:
  - what was tested,
  - issues found,
  - fixes applied,
  - regression outcomes,
  - residual risks (if any),
  - final readiness status.
```
