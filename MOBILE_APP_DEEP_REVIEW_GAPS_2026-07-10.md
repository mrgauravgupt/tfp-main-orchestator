# Mobile App Deep Review Gap Report

Date: 2026-07-10
Workspace: `/Users/hexa/Desktop/tfp-main-orchestator`
Mobile app: `tfpphotographers/apps/mobile`
Web app: `tfpphotographers/apps/web`

## Executive verdict

The mobile app is partially implemented and has a reasonable architectural skeleton, but it is not yet web-parity or go-live ready.

The strongest parts are:

- Native Expo route structure is in place.
- Bottom tabs match the intended product shell: Home, Search, Create, Inbox, Profile.
- Pushed screens use native stack headers instead of a custom JavaScript overlay.
- Public list/search reads mostly use real `/api/v1` endpoints with `auth: false`, which avoids cache bypass on public data.
- The mobile color palette is broadly aligned with the web dark/pink/gold brand family.

The main blockers are:

- Mobile covers only a simplified subset of the web product.
- Several mobile screens still synthesize, simplify, or fallback data in ways that should not be considered production-real data.
- Role/account metadata from the web product is not represented in mobile profile editing or opportunity flows.
- Shared DTO/config usage is incomplete; mobile defines its own entity layer and does not meaningfully consume `@tfp/shared` contracts yet.
- Create/upload flows are placeholders or simplified forms instead of matching the web use cases.
- Current screenshot evidence is not reliable enough for release signoff because several captured screenshots are not the intended screens.

This report is document-only. No app source files were changed.

---

## Scope checked

Reviewed areas:

- Mobile route coverage under `apps/mobile/app/**`.
- Mobile presentation screens under `apps/mobile/src/presentation/screens/**`.
- Mobile API mapping under `apps/mobile/src/infra/api-content-repository.ts`.
- Mobile theme tokens under `apps/mobile/src/presentation/theme/tokens.ts`.
- Mobile shared import setup under `apps/mobile/tsconfig.json`.
- Web route and feature coverage under `apps/web/src/pages/**`.
- Web visual tokens under `apps/web/src/styles/foundation/_tokens.scss`.
- Mobile design and implementation guidance:
  - `docs/mobile/mobile-app-design-guide.md`
  - `docs/mobile/mobile-app-implementation-todo.md`

Not checked in this pass:

- Live device runtime after a clean rebuild.
- Real auth/login flows on Android/iOS.
- Backend API correctness beyond static contract usage.
- App Store / Play Store packaging.
- Secrets and production credential hygiene, per user instruction.

---

## Priority legend

- `P0`: Blocks go-live or creates product correctness risk.
- `P1`: Important parity, UX, architecture, or reliability gap.
- `P2`: Polish, scale, or maintainability improvement.

---

## 1. Visual and brand parity

### 1.1 Color foundation is close, but not governed by one source

Status: `P1`

Evidence:

- Web theme tokens define the dark base and primary pink family in `apps/web/src/styles/foundation/_tokens.scss:3-17`.
- Web text colors are defined in `apps/web/src/styles/foundation/_tokens.scss:79-82`.
- Mobile tokens mirror the same broad palette in `apps/mobile/src/presentation/theme/tokens.ts:1-24`.

Findings:

- Mobile uses the same core dark background, elevated surfaces, pink primary color, gold/mint accents, and near-white text family as web.
- The palette match is intentional enough for a first release baseline.
- However, web and mobile tokens are duplicated manually.
- Accent naming is inconsistent: mobile has a true cyan token (`#5ee7ff`) while the web `raw-accent-cyan` value is gold-like (`#f2d28a`) and web also uses mint/gold gradients.

Required fix:

- Create a shared brand-token source or generated token artifact consumed by both web and mobile.
- Decide whether `cyan` is a real brand color or a legacy semantic name.
- Add a small token parity check so future web/mobile color drift is caught.

Suggested implementation:

- Add a shared token package or generated JSON under `packages/config` or `packages/shared`.
- Import that token output in mobile.
- Keep platform-specific derived values local, but keep brand primitives shared.

---

### 1.2 Mobile shell follows the intended navigation, with small sizing drift

Status: `P2`

Evidence:

- Mobile root stack exists in `apps/mobile/app/_layout.tsx:26-71`.
- Mobile bottom tabs exist in `apps/mobile/app/(tabs)/_layout.tsx:13-85`.
- Mobile design guide requires Home, Search, Create, Inbox, Profile tabs in `docs/mobile/mobile-app-design-guide.md:314-322`.
- Mobile design guide expects native stack headers for pushed screens in `docs/mobile/mobile-app-design-guide.md:324-348`.

Findings:

- Route structure generally matches the mobile design guide.
- Pushed routes correctly use native stack headers.
- The tab bar height is `72`, while the design guide target is `74-84`.
- The center create button is `56`, while the design guide target is `58-64`.

Required fix:

- Adjust tab bar and create-button sizing to the documented ranges.
- Keep native stack headers. Do not add a second custom bottom overlay to pushed screens.

---

### 1.3 Current screenshot evidence is not release-grade

Status: `P0`

Evidence:

- Checked-in Android screenshots are under `docs/mobile-screenshots/android/`.
- Existing captures include mismatches such as Android launcher/recent-apps screens instead of the intended mobile app screens.

Findings:

- Current screenshots cannot be used as go-live proof.
- Some captured states do not correspond to the requested tabs/screens.
- The visual audit should be repeated after route navigation and screenshot capture are stabilized.

Required fix:

- Regenerate screenshots after a clean Android/iOS app start.
- Capture at minimum:
  - Home feed
  - Search
  - Create hub
  - Inbox
  - Profile
  - Opportunity list/detail/apply
  - Event list/detail/RSVP
  - Contest list/detail/submission
  - Auth login/register
  - Profile edit
- Add a screenshot checklist to the mobile QA flow.

---

## 2. Web use-case parity matrix

### Summary

Mobile has routes for the main public domains, but most domains are simplified compared with web. The missing pieces are not just UI polish; many are product semantics such as role-specific applications, filters, profile role metadata, upload workflows, submission workflows, activity notifications, and report/block flows.

| Product area | Web capability | Mobile status | Gap priority |
|---|---|---:|---:|
| Home / discover | Rich feed and discovery surfaces | Basic feed from multiple public lists | `P1` |
| Search | Query, location, mode/type/sort filters | Query-only search | `P1` |
| Saved searches | Web save-search panel on opportunities | Repository method exists, no mobile UX | `P1` |
| Opportunities list | Filters by category, role, compensation, phase | Simple list | `P1` |
| Opportunity detail | Role states, apply, contact/workspace/final upload | Basic detail + apply | `P0` |
| Opportunity create | Full post creation fields and role requirements | Upload-gated placeholder | `P0` |
| Events list/detail | RSVP states, attendee/gallery behavior | Basic list/detail, RSVP always Going | `P0` |
| Event create | Full event metadata | Simplified title/description/date/location | `P1` |
| Contests list/detail | Submit, vote, share, winner/judging states | Detail exists, submission/upload disabled | `P0` |
| Contest create | Full contest setup | Simplified title/description/deadline/prize | `P1` |
| Contest submission detail | Entry detail, reactions/votes/winner state | Static empty state | `P0` |
| Messages | Conversation list/thread, compose, block/report semantics | List plus thin thread | `P0` |
| Notifications/activity | Activity/notifications surfaces | Static empty state | `P1` |
| Profile view | Portfolio, skills, owner/public variants | Basic profile and portfolio | `P1` |
| Profile edit | Role/account/work-preference/avatar/cover fields | Basic identity/bio/location/language | `P0` |
| Auth | Email plus provider/deep-link flows | Email/password and forgot password | `P1` |
| Report/safety | Contextual reporting/appeal | Not present | `P0` |
| Admin/operator | Admin routes and tools | Not present | `P2`, unless mobile admin is required |
| Legal/info pages | Legal/about/contact/AI transparency | Not present | `P2`, unless app-store review requires them in-app |

---

## 3. Opportunity gaps

### 3.1 Opportunity list lacks web filtering and discovery controls

Status: `P1`

Evidence:

- Mobile opportunity list screen starts at `apps/mobile/src/presentation/screens/OpportunityScreens.tsx:20-43`.
- Web opportunity filtering/search panel exists in `apps/web/src/pages/opportunities/index.astro:260-281`.
- Web saved-search UI appears around `apps/web/src/pages/opportunities/index.astro:311-320`.

Findings:

- Mobile opportunity list is a simple list.
- It does not expose category, role, compensation, phase, location, saved-search, or sort controls.
- `closingSoon` is derived locally from a label instead of coming from API semantics.

Required fix:

- Add mobile filter sheet for opportunity category, role, compensation, location, phase/status, and sort.
- Wire saved searches to the real API.
- Stop deriving business state from display labels.

---

### 3.2 Opportunity detail/apply flow is not role-complete

Status: `P0`

Evidence:

- Mobile opportunity detail/apply logic is in `apps/mobile/src/presentation/screens/OpportunityScreens.tsx:46-153`.
- Mobile apply mutation posts to `/opportunities/:id/applications` in `apps/mobile/src/presentation/screens/OpportunityScreens.tsx:74`.
- Web opportunity detail has richer role/application/workspace behavior around `apps/web/src/pages/opportunities/[slug].astro`.

Findings:

- Mobile does not expose role-specific application selection.
- Mobile does not clearly represent open/closed role slots.
- Mobile can show apply UI even when opportunity status/deadline should prevent applying.
- Mobile lacks withdraw, creator contact/workspace, and final-upload flows.
- Mobile status mapping converts some API states into internal display states such as `reviewing`, which can leak incorrect semantics to users.

Required fix:

- Fetch and display role slots from the API.
- Require role selection when applying if the opportunity has multiple roles.
- Hide or disable apply when opportunity/role state is closed.
- Add withdraw and application-status UI.
- Add creator contact/workspace/final-upload entry points if web supports them for that state.
- Align mobile status labels with web/API semantics.

---

### 3.3 Opportunity create is still placeholder-level

Status: `P0`

Evidence:

- Mobile create opportunity screen is in `apps/mobile/src/presentation/screens/CreateHubScreen.tsx:74-90`.
- Mobile implementation TODO marks opportunity creation as upload-gated in `docs/mobile/mobile-app-implementation-todo.md:86`.
- Mobile design guide expects title, description, location, category, compensation, roles, budget, and moodboard in `docs/mobile/mobile-app-design-guide.md:397-419`.

Findings:

- Mobile does not yet provide the full opportunity creation flow.
- Required role, compensation, budget, category, moodboard/media, and collaboration constraints are missing.

Required fix:

- Implement native opportunity create/edit forms from the same field model as web.
- Add native media upload/presign/finalize before enabling opportunity create.
- Use shared role/category/compensation config instead of local hardcoded options.

---

## 4. Event gaps

### 4.1 Event RSVP only supports one action

Status: `P0`

Evidence:

- Mobile event detail screen is in `apps/mobile/src/presentation/screens/EventScreens.tsx:37-88`.
- Mobile RSVP sends only `GOING` from `apps/mobile/src/presentation/screens/EventScreens.tsx:46`.
- Mobile design guide expects RSVP states Going, Interested, and Not going in `docs/mobile/mobile-app-design-guide.md:397-419`.

Findings:

- Mobile has a one-button RSVP flow.
- Web-level event semantics require multiple attendee states.
- Mobile lacks organizer contact and attendee upload entry points.

Required fix:

- Implement RSVP state selector: Going, Interested, Not going.
- Show current RSVP state and let users change/cancel.
- Add organizer contact and attendee upload/gallery behavior if enabled by API state.

---

### 4.2 Event create is simplified

Status: `P1`

Evidence:

- Mobile event create screen is in `apps/mobile/src/presentation/screens/CreateHubScreen.tsx:93-139`.

Findings:

- Mobile event creation only captures title, description, date, and location.
- It does not capture cover image, mode/virtual URL, event category, pricing/fee rules, attendee caps, host metadata, or publication state.

Required fix:

- Align event create/edit fields with web and API contracts.
- Add media upload support before release if event cover images are required.

---

## 5. Contest gaps

### 5.1 Contest detail does not support submission/vote/share/winner flows

Status: `P0`

Evidence:

- Mobile contest detail screen is in `apps/mobile/src/presentation/screens/ContestScreens.tsx:32-69`.
- Mobile implementation TODO marks submit/vote state as upload-gated in `docs/mobile/mobile-app-implementation-todo.md:91`.
- Mobile design guide expects submit image, vote, share, and winner/judging states in `docs/mobile/mobile-app-design-guide.md:397-419`.

Findings:

- Contest detail can render basic detail content.
- Submission/upload is disabled.
- Vote, share, judging, and winner states are not implemented as web-equivalent flows.

Required fix:

- Implement native contest image submission using real upload API.
- Add vote/reaction states using API-backed data.
- Add share and winner/judging display states.
- Disable actions based on contest phase and user eligibility.

---

### 5.2 Contest submission detail is a static empty state

Status: `P0`

Evidence:

- Mobile contest submission route exists at `apps/mobile/app/contests/[id]/submissions/[submissionId].tsx`.
- The screen implementation is in `apps/mobile/src/presentation/screens/ContestScreens.tsx:71-79`.

Findings:

- The route exists but does not load submission data.
- It ignores the route params for API-backed submission detail.
- This is route coverage without use-case coverage.

Required fix:

- Add repository method for contest submission detail.
- Load by contest ID and submission ID.
- Show image, entrant, caption, reactions/votes, moderation/status state, and winner/judging state.

---

### 5.3 Contest create is simplified

Status: `P1`

Evidence:

- Mobile contest create screen is in `apps/mobile/src/presentation/screens/CreateHubScreen.tsx:141-189`.

Findings:

- Mobile contest creation captures title, description, deadline, criteria, and prize.
- It does not cover banner/resource uploads, format, judging timeline, submission window, eligibility, voting mode, or rules in a web-parity way.

Required fix:

- Align contest create/edit forms with web/API fields.
- Add upload support for banner/resources/submissions.
- Add validation from shared schema or API-generated form contract.

---

## 6. Profile, roles, and account metadata gaps

### 6.1 Mobile profile edit misses key web role/account fields

Status: `P0`

Evidence:

- Mobile profile edit is in `apps/mobile/src/presentation/screens/ProfileScreen.tsx:70-144`.
- Web profile edit includes system role around `apps/web/src/pages/profile/edit.astro:394-402`.
- Web profile edit includes primary role and account type around `apps/web/src/pages/profile/edit.astro:519-535`.
- Web profile edit includes organization fields around `apps/web/src/pages/profile/edit.astro:538-561`.
- Web profile edit includes open-to-work and interested categories around `apps/web/src/pages/profile/edit.astro:564-587`.
- Web profile edit includes role notes around `apps/web/src/pages/profile/edit.astro:590-598`.

Findings:

- Mobile profile edit currently covers basic identity fields:
  - display name
  - username
  - bio
  - location
  - language
  - permissions
- It does not cover:
  - system role
  - primary industry role
  - account type
  - organization name/type
  - open-to-work compensation preferences
  - interested categories
  - role notes
  - avatar upload
  - cover upload

Required fix:

- Add role/account/work-preference sections to mobile profile edit.
- Use shared role/account/category/compensation configuration.
- Add avatar and cover upload once native upload is ready.

---

### 6.2 Mobile role model is narrower than platform roles

Status: `P0`

Evidence:

- Mobile access control role type is in `apps/mobile/src/domain/access-control.ts:1`.
- Shared/environment role options include broader role/category sets in `packages/config/src/env-core.ts:272-277`, `packages/config/src/env-core.ts:323-328`, and `packages/config/src/env-core.ts:350-357`.
- Shared config sections include role/category/compensation/account options in `packages/config/src/config-sections.ts:352-384`.

Findings:

- Mobile role typing includes only a limited set.
- Web/config supports more roles such as video, hair, wardrobe, studio/vendor, and other account categories.
- This creates product mismatch for discovery, profiles, opportunity applications, and future authorization checks.

Required fix:

- Replace local role option definitions with shared config imports.
- Add mobile UI support for all platform-supported roles/account types.
- Keep permission/authorization checks separate from industry role metadata.

---

### 6.3 Profile owner experience is incomplete

Status: `P1`

Evidence:

- Mobile profile view is in `apps/mobile/src/presentation/screens/ProfileScreen.tsx:146-214`.
- Mobile design guide expects owner profile sections for portfolio, applications, contest entries, posts, referrals, and settings in `docs/mobile/mobile-app-design-guide.md:397-419`.

Findings:

- Mobile profile view has useful basics: cover, avatar, stats, skills, portfolio, edit/message CTA.
- Owner-only profile surfaces are not complete.

Required fix:

- Add owner tabs or sections for:
  - applications
  - RSVPs
  - contest entries
  - portfolio uploads
  - referrals
  - account/settings entry points

---

## 7. Search, saved search, and discovery gaps

### 7.1 Search is query-only

Status: `P1`

Evidence:

- Mobile search screen is in `apps/mobile/src/presentation/screens/SearchScreen.tsx:14-84`.
- Web search supports query, location, mode, type, and sort around `apps/web/src/pages/search.astro:192-221`.

Findings:

- Mobile search uses a single query field.
- It does not expose location, mode, type, or sort filters.
- Saved search pills can render but do not provide a complete save/manage UX.

Required fix:

- Add filter sheet and result-type tabs.
- Add save/update/delete saved search UX backed by API.
- Keep query, location, mode, type, sort, and saved-search state shareable through deep links where possible.

---

## 8. Messages, notifications, and activity gaps

### 8.1 Message thread is not a real conversation view

Status: `P0`

Evidence:

- Mobile inbox screen is in `apps/mobile/src/presentation/screens/InboxScreen.tsx:11-40`.
- Mobile message thread screen is in `apps/mobile/src/presentation/screens/MessageScreens.tsx:14-66`.
- Mobile repository message list method is in `apps/mobile/src/infra/api-content-repository.ts:349-363`.
- Mobile send message method is in `apps/mobile/src/infra/api-content-repository.ts:493-500`.

Findings:

- Inbox can list conversations.
- Thread view loads conversations and finds one by ID rather than loading a real thread message timeline.
- Thread display is effectively last-message focused.
- Block/report/read-status behavior is missing.
- Optional authenticated message calls are not guarded as cleanly as public list/search calls, so signed-out state can create masked API errors.

Required fix:

- Add API-backed conversation detail/thread endpoint.
- Render message timeline, send status, read state, and pagination.
- Add block/report affordances.
- Skip optional authenticated calls until a bearer token exists.

---

### 8.2 Activity/notifications are static

Status: `P1`

Evidence:

- Mobile inbox activity empty state is in `apps/mobile/src/presentation/screens/InboxScreen.tsx:37-38`.
- Mobile permission center requests notification permission in `apps/mobile/src/presentation/components/PermissionCenter.tsx:12-50`.

Findings:

- Notification permission UI exists.
- There is no complete push token registration/subscription strategy.
- Activity is not backed by real notification/activity API data.

Required fix:

- Implement notification registration and token sync.
- Add activity feed API integration.
- Include messages, applications, RSVPs, contest updates, reports, and suggestions in the activity model.

---

## 9. Auth and safety gaps

### 9.1 Auth is basic email/password only

Status: `P1`

Evidence:

- Mobile auth screens are in `apps/mobile/src/presentation/screens/AuthScreens.tsx`.
- Web has auth provider routes under `apps/web/src/pages/api/auth/**`.

Findings:

- Mobile supports login, register, and forgot password.
- Mobile does not yet represent OAuth/provider flows.
- Mobile does not have a complete reset-password deep-link flow.
- Register flow does not capture full role/account/referral context.

Required fix:

- Decide which provider auth flows are required for native go-live.
- Implement native deep-link handling for password reset and provider callbacks.
- Align registration fields with web onboarding and marketplace role needs.

---

### 9.2 Contextual report/block flows are missing

Status: `P0`

Evidence:

- Mobile design guide expects contextual report/appeal flows in `docs/mobile/mobile-app-design-guide.md:397-419`.

Findings:

- Mobile does not currently expose report/block actions in profiles, messages, submissions, opportunities, events, or contests.
- This is a safety and app-store readiness gap.

Required fix:

- Add a shared mobile report action component.
- Wire reports to real API endpoints.
- Add block/report actions to:
  - profile
  - message thread
  - opportunity detail
  - event detail
  - contest detail
  - contest submission detail

---

## 10. Real data, hardcoding, and API integrity

### 10.1 No separate mock adapter was found, but synthesized/fallback data remains

Status: `P0`

Evidence:

- Mobile repository is in `apps/mobile/src/infra/api-content-repository.ts`.
- Mobile design guide requires real API data and no mock/fake/sample/hardcoded content in `docs/mobile/mobile-app-design-guide.md:474-508`.

Findings:

- No obvious `EXPO_PUBLIC_TFP_USE_MOCKS` mock mode or separate fake repository is present.
- Public list/search methods mostly call real `/api/v1` APIs with `auth: false`.
- However, the repository still synthesizes or falls back in ways that are not go-live acceptable:
  - Home/search feed buckets use derived arrays instead of backend-provided feed semantics.
  - Missing media falls back to local logo imagery.
  - Some display labels are built locally in English/India formatting.
  - `safeCall` can swallow API failures and convert regressions into empty UI.
  - Generic draft creation has hardcoded future dates.

Required fix:

- Separate harmless presentational fallback from fake product data.
- Do not fabricate feed sections, status labels, dates, compensation, or media as if they came from API.
- Prefer explicit empty states when API data is missing.
- Make API failures visible in development/QA.
- Remove or harden generic `createDraft`.

---

### 10.2 Media fallback hides backend/content gaps

Status: `P1`

Evidence:

- Opportunity/event/contest/profile mappers in `apps/mobile/src/infra/api-content-repository.ts` use local fallback image semantics.

Findings:

- Fallback logo-heavy UI makes the mobile app look less like the web app.
- It also hides whether API media resolution is working.
- If screenshots are logo-dominated, the app appears visually unfinished even when data is technically present.

Required fix:

- Use API-resolved thumbnails/media URLs where available.
- Show clear empty media states only when content truly has no media.
- Track media-missing cases in QA rather than silently replacing them with logo art.

---

### 10.3 Local label formatting should move to shared or API-backed semantics

Status: `P1`

Evidence:

- Mobile repository formats deadline/date/compensation/status labels in `apps/mobile/src/infra/api-content-repository.ts`.

Findings:

- Label creation is mixed into the API repository.
- Some formatting is locale-sensitive but currently hardcoded.
- Business state should not be derived from display text.

Required fix:

- Keep raw status/date/amount fields in domain entities.
- Move display formatting into presentation/i18n helpers.
- Use shared constants for status/compensation labels.

---

## 11. Architecture and shared-code gaps

### 11.1 Hexagonal shape is present, but the boundary is too large and too local

Status: `P1`

Evidence:

- Mobile domain entities are in `apps/mobile/src/domain/entities.ts`.
- Mobile content port/repository is in `apps/mobile/src/application/ports`.
- Mobile API implementation is concentrated in `apps/mobile/src/infra/api-content-repository.ts`.

Findings:

- The broad layering is good:
  - routes
  - presentation screens/components
  - application hooks
  - domain entities
  - infra repository/client
- The problem is not folder structure.
- The problem is that the infra repository is doing too much mapping, fallback, business labeling, and recovery.
- Domain types are local rather than generated/shared from web/API contracts.

Required fix:

- Split the large API repository by domain:
  - opportunities
  - events
  - contests
  - profiles
  - messages
  - search/feed
- Keep mapping pure and explicit.
- Move display formatting out of infra.
- Add contract tests between API responses and mobile mappers.

---

### 11.2 Shared DTO/config usage is incomplete

Status: `P0`

Evidence:

- Mobile TypeScript aliases include `@tfp/shared` and `i18n/mobile` in `apps/mobile/tsconfig.json:9-11`.
- Shared contracts exist in `packages/shared/src/contracts.ts`.
- Mobile implementation TODO keeps shared DTO imports as a follow-up in `docs/mobile/mobile-app-implementation-todo.md:49`.

Findings:

- Mobile imports shared i18n through a thin domain re-export.
- Mobile does not materially use `@tfp/shared` contracts for API/domain typing.
- This creates drift risk between API, web, and mobile.

Required fix:

- Import shared DTOs/contracts where possible.
- If contracts are insufficient, extend `packages/shared` instead of duplicating mobile-only shapes.
- Add type-level checks for mapped API data.
- Keep mobile-specific view models separate from API DTOs, but derive them from shared contract types.

---

### 11.3 i18n coverage is incomplete

Status: `P1`

Evidence:

- Mobile uses shared mobile i18n through `apps/mobile/src/domain/i18n.ts`.
- Mobile screens/components still contain hardcoded English labels in several places.

Findings:

- English coverage is much richer than Hindi/Nepali coverage.
- Some accessibility labels and UI copy remain hardcoded.
- Local label formatting in the repository bypasses i18n.

Required fix:

- Move remaining mobile UI strings into shared mobile i18n.
- Expand Hindi/Nepali mobile translations.
- Add a key-coverage check for mobile locales.
- Do not generate user-visible labels in infra code.

---

## 12. Performance and release-readiness gaps

### 12.1 List rendering is not optimized for growth

Status: `P1`

Evidence:

- Shared `Screen` component uses `ScrollView` in `apps/mobile/src/presentation/components/Screen.tsx`.
- Mobile list screens render card lists inside generic scroll containers.

Findings:

- ScrollView is acceptable for short lists, but it does not scale for production feeds.
- Home/search/opportunity/event/contest/profile portfolio lists should use virtualized lists where data can grow.

Required fix:

- Use `FlatList`, `SectionList`, or FlashList for large feeds/lists.
- Add paging/infinite-load behavior where API supports it.
- Avoid rendering all cards at once on home/search.

---

### 12.2 Auth-aware caching is partly correct but must stay guarded

Status: `P1`

Evidence:

- Public list/search methods in `apps/mobile/src/infra/api-content-repository.ts` use unauthenticated public reads.
- Prior mobile performance work focused on avoiding authenticated cache bypass for public reads.

Findings:

- The major public list/search path is healthier than earlier versions.
- Remaining authenticated optional paths such as messages/activity/profile-private data need stricter token guards.

Required fix:

- Keep all public data reads `auth: false` unless user-specific state is required.
- Skip optional authenticated calls until token exists.
- Split public content queries from viewer-specific state queries.

---

### 12.3 Release-readiness TODOs remain open

Status: `P0/P1`

Evidence:

- Remaining production hardening items are listed in `docs/mobile/mobile-app-implementation-todo.md:123-134`.

Open items:

- Deep links.
- Push notification strategy.
- Native upload/presign/finalize flows.
- Offline/retry policy.
- App store configuration.
- Dynamic type/accessibility audit.
- E2E plan.
- Release/versioning policy.

Required fix:

- Treat these as pre-launch checklist items, not post-launch polish.

---

## 13. Implementation plan for another AI agent

### Phase 0: Guardrails

- Do not modify unrelated dirty files.
- Do not add mock/fake/sample data.
- Keep all public list/search reads real API-backed.
- Preserve native stack header behavior.
- Preserve mobile shared i18n re-export pattern.
- Use repo wrappers:
  - `bash ./scripts/manage-tfp-mobile.sh <command>`
  - `bash ./scripts/pnpm-node20.sh <command>` where applicable in `tfpphotographers`.

### Phase 1: Contract and shared model cleanup

- [ ] Add or extend shared DTOs/contracts in `packages/shared`.
- [ ] Replace local mobile DTO assumptions with shared contract imports.
- [ ] Import shared role/category/compensation/account type config.
- [ ] Add mapper tests for opportunity/event/contest/profile/message API responses.
- [ ] Split `api-content-repository.ts` into domain-specific repositories or mapper modules.
- [ ] Remove business label generation from infra.
- [ ] Make API errors visible in QA/dev instead of silently emptying UI.

### Phase 2: Real mobile parity for core marketplace flows

- [ ] Opportunity list filters and saved searches.
- [ ] Opportunity role-specific detail/apply/withdraw/status.
- [ ] Opportunity create/edit with roles, compensation, budget, media/moodboard.
- [ ] Event RSVP states: Going, Interested, Not going.
- [ ] Event create/edit full field parity.
- [ ] Contest submit/vote/share/winner/judging states.
- [ ] Contest submission detail backed by API.
- [ ] Search filter sheet for location/mode/type/sort.

### Phase 3: Profile, account, and role parity

- [ ] Add system role selection where appropriate.
- [ ] Add primary industry role.
- [ ] Add account type.
- [ ] Add organization name/type.
- [ ] Add open-to-work compensation preferences.
- [ ] Add interested categories.
- [ ] Add role notes.
- [ ] Add avatar and cover upload.
- [ ] Add owner profile sections for applications, RSVPs, contest entries, referrals, and uploads.

### Phase 4: Safety, messaging, and notifications

- [ ] Replace thin thread view with real paginated message timeline.
- [ ] Add read state/send status.
- [ ] Add block/report actions.
- [ ] Add contextual report component across content types.
- [ ] Add real activity/notification feed.
- [ ] Add push token registration and backend subscription flow.

### Phase 5: Visual QA and performance

- [ ] Create shared/generated brand token source.
- [ ] Align tab bar/create button dimensions with design guide.
- [ ] Replace large ScrollView feeds with virtualized lists.
- [ ] Add pagination/infinite loading.
- [ ] Regenerate Android and iOS screenshot sets.
- [ ] Add screenshot verification checklist.
- [ ] Run dynamic type and accessibility pass.

### Phase 6: Release readiness

- [ ] Implement native deep links.
- [ ] Implement reset-password/provider callback flow.
- [ ] Implement upload/presign/finalize end to end.
- [ ] Define offline/retry policy.
- [ ] Configure app store metadata and platform permissions.
- [ ] Add mobile E2E smoke coverage.
- [ ] Add versioning/release checklist.

---

## 14. Suggested validation commands after fixes

Run from `tfpphotographers`:

```bash
bash ./scripts/manage-tfp-mobile.sh doctor
bash ./scripts/manage-tfp-mobile.sh typecheck
bash ./scripts/manage-tfp-mobile.sh lint
bash ./scripts/manage-tfp-mobile.sh test
bash ./scripts/manage-tfp-mobile.sh android
```

If a fix touches shared packages or API contracts:

```bash
bash ./scripts/pnpm-node20.sh typecheck
bash ./scripts/pnpm-node20.sh test
```

For visual signoff:

```bash
bash ./scripts/manage-tfp-mobile.sh screenshots
```

If the screenshot command is not currently stable, first fix the wrapper/navigation/capture target and then rerun the visual checklist in this document.

---

## 15. Go-live decision

Do not treat the current mobile app as go-live ready.

Recommended release gate:

- No mock/fake/synthesized business data in production UI.
- Shared role/account/config parity with web.
- Real upload flows for any feature that requires media.
- Real opportunity apply/withdraw/status behavior.
- Real contest submission/vote/detail behavior.
- Real event RSVP states.
- Real message thread and report/block flows.
- Stable Android and iOS screenshot evidence.
- Passing mobile typecheck, tests, and smoke run.
