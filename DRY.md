# DRY Analysis & Reusable Component Recommendations

## Frontend

### 1. Split `ListingCard.astro` (245 lines, 3-way conditional)

The current `ListingCard.astro` uses a large `if/else` chain for `project`, `contest`, and `event` variants. Each branch has distinct media rendering, metadata, and badge logic.

**Extract:**

- `ProjectCard.astro` — project media grid, roles list, location
- `ContestCard.astro` — banner image, lifecycle badge, deadline
- `EventCard.astro` — image with date badge, RSVP chips, entry fees
- `CardActions.astro` — shared footer (view details + report link), identical across all 3

**Files affected:** `ListingCard.astro`, 3 listing index pages, `index.astro` (home), `search.astro`

---

### 2. Listing Index Pages — Near-Identical Structure

`contests/index.astro`, `events/index.astro`, `projects/index.astro` all repeat:

- Fetch data from API with pagination
- Check auth for CTA visibility
- Render filter chips (`<nav class="listing-filters">`)
- Render grouped or flat grid with empty state
- Render pagination

**Extract:**

- **`ListingFilters.astro`** — filter chip nav (identical markup across all 3 pages)
- **`ListingGrid.astro`** — grouped-or-flat grid + empty state pattern (repeated 3×)

**Files affected:** `contests/index.astro`, `events/index.astro`, `projects/index.astro`

---

### 3. Auth Pages — Duplicated Layout Shell

`login.astro`, `register.astro`, `forgot-password.astro`, `reset-password.astro` all wrap content in:

```html
<div class="auth-page">
  <div class="auth-container">
    <div class="auth-card">
      <h1 class="auth-title">...</h1>
      <p class="auth-subtitle">...</p>
      <!-- form content -->
    </div>
  </div>
</div>
```

**Extract:**

- **`AuthShell.astro`** — takes `title` and `subtitle` props with a `<slot />` (mirrors existing `ListingShell.astro` pattern)

**Files affected:** `login.astro`, `register.astro`, `forgot-password.astro`, `reset-password.astro`

---

### 4. Create Pages — Duplicated Auth Gate + Back Link

`contests/create.astro`, `events/create.astro`, `projects/create.astro` all share:

- Auth check + user role/tier fetch (~15 identical lines)
- Auth gate card for unauthenticated users
- Back link pattern
- Form shell using `_create-shell-shared.scss`

**Extract:**

- **`CreateShell.astro`** — wraps create form with auth gate, back link, title

**Files affected:** `contests/create.astro`, `events/create.astro`, `projects/create.astro`

---

### 5. Detail Pages — Huge Monoliths

| Page | Lines |
|------|-------|
| `contests/[id].astro` | 950 |
| `profile/[email].astro` | 890 |
| `projects/[id].astro` | 625 |
| `events/[id].astro` | 590 |

Common patterns repeated across detail pages:

- Auth check + `currentUser` fetch (identical across all)
- `resolveLegacyDetail` + 404 fallback pattern
- Delete action handling
- Owner vs visitor conditional rendering

**Extract:**

- **`DetailHero.astro`** — banner/image section with fallback
- **`DetailMeta.astro`** — metadata rows (location, date, status)
- **`OwnerActions.astro`** — edit/delete buttons shown only to owners
- **`DeleteConfirmation.astro`** — delete modal/form pattern (identical in project, event, contest)

**Files affected:** `contests/[id].astro`, `events/[id].astro`, `projects/[id].astro`

---

### 6. `getCurrentUser()` — Repeated in 6+ Places

The "fetch current user" pattern is duplicated across listing indexes, create pages, detail pages, and `BaseLayout.astro`. Each does its own `fetch('/auth/me')` with slightly different response parsing.

**Extract:**

- **`utils/current-user.ts`** — single `getCurrentUser(cookies)` function returning a typed user object

**Files affected:** `BaseLayout.astro`, 3 listing indexes, 3 create pages, 3+ detail pages

---

### 7. Social Auth Buttons — Inline SVG Duplication

The Google SVG icon is inlined in `login.astro`. GitHub uses `<Icon>`.

**Extract:**

- Add `google` to `Icon.astro`
- **`SocialAuthButtons.astro`** — reusable social login button group

**Files affected:** `login.astro`

---

## Backend

### 8. `toPublicUrl` + `moderationFailurePayload` — Duplicated in Every Route File

These identical functions are defined inside `registerEventRoutes`, `registerProjectRoutes`, and `registerContestRoutes`:

```ts
const toPublicUrl = (key, request) => {
  if (!key) return null;
  return request.server.storage.getUrl(key);
};

const moderationFailurePayload = (status) => ({
  success: false,
  error: {
    code: 'IMAGE_MODERATION_BLOCKED',
    message: status === 'REJECTED'
      ? 'Image was rejected by moderation policy'
      : 'Image requires manual review and cannot be published yet',
  },
});
```

**Extract:**

- Move `toPublicUrl` to `utils/storage-url.ts`
- Move `moderationFailurePayload` to `utils/http-errors.ts`

**Files affected:** `contest.routes.ts`, `event.routes.ts`, `project.routes.ts`

---

### 9. Inconsistent Module Structure

`contest/` uses CQRS folder structure (`commands/`, `queries/`). `event/` and `project/` use flat files (`event.commands.ts`, `event.queries.ts`).

**Recommendation:** Standardize on one pattern. The flat file approach is simpler and appropriate for the current scale.

**Files affected:** `modules/contest/`, `modules/event/`, `modules/project/`

---

## Priority Order

| # | What to Extract | Impact | Scope |
|---|----------------|--------|-------|
| 1 | `getCurrentUser()` utility | High | 6+ pages + BaseLayout |
| 2 | Split `ListingCard` into 3 cards + `CardActions` | High | 4 components, 3 listing pages, home, search |
| 3 | `AuthShell.astro` | Medium | 4 auth pages |
| 4 | `ListingFilters.astro` | Medium | 3 listing index pages |
| 5 | `CreateShell.astro` | Medium | 3 create pages |
| 6 | `toPublicUrl` + `moderationFailurePayload` to shared utils | Medium | 3 BE route files |
| 7 | `DeleteConfirmation.astro` + `OwnerActions.astro` | Low-Med | 3 detail pages |
| 8 | `SocialAuthButtons.astro` | Low | 1 page |
| 9 | Standardize BE module structure | Low | cosmetic |
