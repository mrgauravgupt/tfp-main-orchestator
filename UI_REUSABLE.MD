# UI Reuse, SSOT, and Code-Quality Implementation Guide

> **Workspace:** `/Users/hexa/Desktop/tfp-main-orchestator`
>
> **Application:** `tfpphotographers`
>
> **Verified:** August 1, 2026
>
> **Evidence rule:** Current source and checked-in tests override this document.

## Purpose

This is a verified backlog for UI reuse and related code-quality work. It is
not an exhaustive audit of every web, mobile, API, and database file. Each item
below is classified so an engineer does not turn a search result or a proposed
abstraction into a destructive change.

## Verified Current Architecture

| Area | Current source of truth | Status |
| --- | --- | --- |
| Design tokens | `packages/shared/design-tokens.json` and generated web/mobile outputs | Active; use the token QA gates before adding literals |
| Listing layout | `apps/web/src/components/ListingShell.astro` | Active across opportunity, event, contest, and profile listings |
| Admin layout | `apps/web/src/components/AdminShell.astro` | Active on the unified admin workspace |
| Detail composition | Components under `apps/web/src/components/detail/` | Active; no separate `DetailShell.astro` exists |
| Modal scroll locking | `scroll-lock.ts`, consumed by `ui-core.ts` and admin runtime | Active shared primitive with focused tests |
| Legacy slug resolution | `legacy-redirect.ts` | Active utility with opportunity, event, and contest consumers |
| Dynamic social images | `SiteHead.astro` -> localized `/api/og/...` endpoint | Active for opportunity, contest, and profile detail routes |
| API repositories | `packages/database/src/repositories/` | Active repository factory and domain implementations |
| Product authentication | Email OTP plus optional OAuth | Password endpoints are available only in the isolated test runtime |
| Durable events | PostgreSQL `event_outbox` | Intentional architecture; unrelated to the UI cleanup below |

## Implemented in This Change

### Passwordless mobile boundary cleanup

The native login, registration, forgot-password, and reset-password route names
remain as safe deep-link aliases to the single `LoginScreen`. Unused password
request methods, payloads, validators, and repository contracts were removed
from the production mobile application boundary. The API's password fixtures
remain test-only because current integration suites still depend on them.

### Detail hero image priority

`OpportunityImage.astro` now translates its existing `isLcp` contract into
eager loading and `fetchpriority="high"`. `DetailSplitHero.astro` marks only its
first visible hero image as the LCP candidate; later gallery images remain lazy.

## Rejected Recommendations

These actions are not valid cleanup work in the current repository:

1. **Do not delete `scroll-lock.ts`.** It prevents modal and mobile-navigation
   locks from unlocking each other and has direct unit-test coverage.
2. **Do not delete `legacy-redirect.ts`.** It has multiple live consumers. A
   move into `routing.ts` would change ownership without reducing duplication.
3. **Do not create duplicate listing or admin shells.** Both components already
   exist and are used.
4. **Do not add page-level OG props solely to obtain dynamic images.** The
   centralized `SiteHead.astro` route resolver already supplies them.
5. **Do not create a second API repository layer.** The database package owns
   the existing repository interfaces and implementations.
6. **Do not extract `buildPaginationMeta()` as a shared helper yet.** Only one
   implementation is currently present.
7. **Do not centralize every Zod schema.** Promote a schema to `packages/shared`
   only when more than one runtime consumes the same boundary contract.

## Remaining Backlog

### Priority 1 — Regression guards and stale documentation

- Keep a contract test proving production auth registers only email-code/OAuth
  routes while password compatibility remains isolated to `NODE_ENV=test`.
- Keep the feature-route inventory aligned with the passwordless product flow.
- Retain redirect coverage for old web and mobile auth URLs.

### Priority 2 — Measured client-runtime decomposition

`ui-core.ts` and `form-helpers.ts` are large, but size alone is not proof of an
architecture defect. Before splitting either file:

1. Inventory every `window.TFPUI*`, `window.TFPScrollLock`, and form data-hook
   consumer.
2. Measure the generated bundle and representative route execution.
3. Extract one coherent module at a time behind the existing global contract.
4. Run modal, navigation, gallery, auth, upload, and form contract tests after
   each extraction.
5. Restart frontend and backend, then test affected routes at desktop, tablet,
   and mobile viewport widths.

### Priority 3 — Reuse only stable page contracts

- Continue using `ListingShell`, `AdminShell`, `BaseLayoutShell`, and the detail
  primitives already present.
- Introduce a `DetailShell` only after at least two detail routes demonstrate
  the same stable slots, error states, metadata, actions, and responsive layout.
- Split `AdminPanels.astro` only along independently testable panel boundaries.
  `admin.services.ts` is approximately 5.4 KB, not 54 KB, and is not a size-led
  decomposition target.

### Priority 4 — Performance and SEO evidence

- Compare LCP and the network waterfall on opportunity, event, and contest
  details after the hero-priority change.
- Ensure only one above-the-fold image receives high fetch priority.
- Verify localized OG endpoints return a valid public image and never expose a
  raw storage key.

## Validation Matrix

| Change type | Required evidence |
| --- | --- |
| Mobile application contract | Mobile unit tests, TypeScript check, Expo doctor |
| Web component or client runtime | Focused web tests, Astro check, web build |
| Shared design primitive | Design-token gates plus all direct-consumer tests |
| Browser-facing behaviour | Fresh frontend/backend restart, health checks, console/network review, desktop/tablet/mobile viewports |
| Auth boundary | API auth tests, web/mobile redirect checks, production-mode route-registration proof |
| Database or event transition | Prisma generation/migration checks and transactional outbox review |

## Compatibility and Rollback

- Old auth URLs remain compatibility aliases, so existing bookmarks and deep
  links continue into the passwordless flow.
- Test-only password API routes are retained until legacy test fixtures are
  migrated to the protected seed-login bridge.
- The hero-priority change can be rolled back by removing `isLcp` from
  `DetailSplitHero`; no persistence, API, or event contract changes are involved.
- No queue, schema, environment, or deployment change is authorized by this
  document.
