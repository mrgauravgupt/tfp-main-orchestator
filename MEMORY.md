# Workspace Memory for Future Agents

## Repository map

- `tfpphotographers/`: main Astro, Fastify, Prisma, PostgreSQL product monorepo.
- `tfp-ai-interface/`: active private FastAPI image/text/translation API and
  isolated PostgreSQL request worker; it does not own product domain state.
- `tfp-moderation-service/`: retained historical checkout; excluded from active
  deployment and runtime orchestration.
- `tfp-collage-service/`: Node image-processing worker service; the repository
  and unit retain the historical collage compatibility name.
- This root repository coordinates deployment scripts and records nested Git revisions.

## 2026 deployment-readiness baseline

- September 7 remediation and verification evidence is recorded in
  `docs/reviews/2026-09-07-remediation-and-verification.md`. API proxy trust now
  combines `TRUST_PROXY_HOPS` with `TRUST_PROXY_CIDRS`, defaulting to exact
  loopback addresses. Non-loopback proxies need an explicit reviewed allowlist;
  deployed environment values were not changed by this local remediation.
- The canonical moderation, worker-ownership, event-outbox, deployment, and
  rollback contract is
  `tfpphotographers/docs/architecture/EVENT_OUTBOX_AND_DEPLOYMENT_READINESS.md`.
  Historical audit snapshots are not current runtime evidence and are not
  retained as competing architecture documents.

## Real Code over Documentation & Anti-False-Confidence Baseline

- **Never rely on docs, comments, or markdown as proof**:
  Markdown documentation, docstrings, schema comments, and type definitions are pointers only. The sole sources of truth are current executable code, runtime AST branches, and active configuration defaults. Never assume runtime behavior or architectural enforcement from a comment or markdown file without verifying the actual executable code.
- **Audit tests against false confidence**:
  A passing test is meaningless if it passes trivially by bypassing the code under test. For example, testing SSR location fallback with `x-forwarded-for` or `x-real-ip` when `ENV.LOCATION_CLIENT_IP_HEADER_ORDER` defaults strictly to `['CF-Connecting-IP']` caused early return before fetch, creating false confidence that timeouts and fallbacks worked. Always test with active configuration and verify negative cases fail when assertions are inverted.
- **Cross-service schema symmetry**:
  When modifying cross-service events or outbox payloads (e.g., `tfp-ai-interface` $\to$ `apps/api`), ensure consumer validators accept new fields before producers emit them. Emitting unvalidated fields causes terminal outbox failure in strict consumer runtimes.
- **Privacy in validation and observability**:
  Tracing and correlation identifiers must be strictly bounded (`/^[A-Za-z0-9._:-]{1,128}$/`). Raw schema validation errors (such as Zod error messages) can stringify received values containing sensitive user input or PII; always sanitize or redact validation errors before writing to `event_outbox.last_error` or application logs.
- **Resilient resource lifecycle management**:
  Connection pool initializers must cleanly handle boot errors without orphaned state. Shutdown logic (`close()`, `aclose()`) must wrap each resource in `try/finally` so failure in one resource does not abort cleanup of remaining services.
- **Precision in engineering claims**:
  Distinguish structural patterns from empirical operational proofs:
  - An index is not proof of query latency under millions of rows without `EXPLAIN ANALYZE` evidence.
  - Rate-limiting cooldowns and exponential backoff are not a 3-state circuit breaker.
  - Serial batch processing limits concurrency but is not an absolute shield against memory exhaustion from oversized single inputs.
  - When domain events or outbox schemas change, run affected downstream consumers (e.g., notification event handlers) immediately.

## UI/UX and Visual Audit Discovery Baseline (Learnings from Full-Surface Audit)

- **Root cause consolidation with blast-radius mapping**:
  Multiple broken UI elements across different pages often stem from a single underlying configuration or layout source. For example, broken images across 6 major web routes (Home, Opportunities, Events, Contests, Feed, Profile) all stemmed from `apps/web/src/utils/middleware-support.ts` omitting `cdn-uat.tfpphotographers.com` from CSP `img-src`. Group related symptoms under their single root cause and document the blast radius rather than creating redundant defect tickets.
- **Contextual evaluation of responsive design patterns**:
  Evaluate whether responsive mechanisms (such as CSS `line-clamp`, horizontal chip scrolling, dismissible consent banners, and auth guards) are functioning as intended. Check whether clamped text preserves critical interactive actions, whether banners dismiss cleanly without blocking clicks, and whether unauthenticated routes redirect correctly.
- **Lifecycle and settled state awareness**:
  Visual captures at $T=0$ can capture transient in-flight states (such as React Query/Apollo refetching spinners or `<RefreshControl refreshing={true} />` in `Screen.tsx`). Inspect component lifecycles and wait for network settlement to accurately differentiate temporary loading animations from frozen or unresponsive interfaces.
- **Catalog and fixture ground truth**:
  Cross-reference suspected text truncation against translation catalogs (`packages/i18n/src/catalogs/languages/*.json`) and database fixtures. Differentiate content positioned below the initial viewport fold from genuine code truncation.
- **Native bottom navigation insets**:
  Native `FlatList` and `ScrollView` screens must account for the persistent safe-area bottom navigation bar (~65-80px). Specifying static `paddingBottom: 40` causes the final list item and action buttons to be occluded by the tab bar.

## UI Remediation & Code Quality Implementation Memory (34 Valid Fixes Baseline)

- **Centralized Tokens over Arbitrary Padding**:
  Solved bottom navigation clearance across all native lists (`opportunity-screen-shared`, `EventScreens`, `ContestScreens`, `AccountScreens`) via one unified token: `persistentNavigationContentInset = bottomNavigation.contentHeightPx + spacing.xl;` in `tokens.ts`. Verified in `tokens.test.ts`.
- **Reusable Component Encapsulation (`ManagedContentImage`)**:
  Rather than patching individual views, wrapped native media in `ManagedContentImage.tsx` handling `onError`, resetting state via `sourceIdentity`, and rendering accessible localized fallbacks (`fallbackLabel`). On web, extended `data-image-fallback` to avatars and admin panels via `ui-core.ts`.
- **Implicit Semantic Form Controls**:
  Wrapped unlabelled admin filter dropdowns in `<label class="admin-filter-field"><span>...</span><select>...</select></label>`, associating uppercase labels with controls for both visual clarity and screen readers.
- **Decoupled Positional Anchors & Full Grid Width**:
  Decoupled colliding badges by anchoring date badges to the bottom of media (`placement="bottom"`) while fee badges stay at the top. Expanded narrow mobile detail metadata from `flexBasis: '46%'` to `flexBasis: '100%'` with `flex: 1` to prevent text truncation and sibling collisions.
- **Contract Testing as Regression Armor**:
  Created sub-millisecond AST/source contract tests (`UiAuditRemediation.contract.test.ts`, `ParityStates.contract.test.ts`) that read component source files to assert that bad patterns (like duplicate headings or missing labels) are prevented without requiring heavy end-to-end browser suites.

- The PostgreSQL-backed `event_outbox` is intentional. It uses `FOR UPDATE SKIP LOCKED`, retry state, terminal `FAILED`, and stale-processing recovery. Do not propose Redis/BullMQ merely because an outbox exists.
- Domain transitions must use the transaction-scoped enqueue helper. Do not reintroduce post-commit event emission for moderation transitions.
- `tfp-ai-interface` is the only consumer of slow AI request events:
  `process_moderation` and `process_translation`. It claims with `FOR UPDATE SKIP LOCKED`,
  uses a dedicated least-privilege `tfp_ai_worker` role, and atomically completes each
  request while inserting a deterministic application-result event. The TFP worker owns
  only `apply_ai_moderation_result` and `apply_ai_translation_result`; it applies existing
  policy/domain/cache transitions and never waits for an AI provider.
- Approved opportunities/events/contests enqueue a reference-only `process_translation`
  job containing entity/revision and an immutable locale plan, but no authored content.
  V2 translates the exact approved revision; TFP persists revision-scoped
  `TranslationCache` and entity maps from the result event.
- Exactly one AI request consumer may be active: `tfp-ai-interface`.
- TypeScript worker shutdown drains active jobs with a bounded timeout; Python moderation worker handles SIGTERM/SIGINT by stopping new polling and finishing the active batch.
- Folder moderation is not part of the active product or OCI UAT deployment.
  All service ports remain private and loopback-only.
- Deployment defaults to `tfpdeploy`; `root` is a deliberate break-glass override only.

## 2026-08 pre-production hardening baseline

- Production object storage has three independent roles: private media,
  public immutable renditions, and database backups. Each role requires its
  own bucket-scoped Backblaze key; production configuration rejects generic
  credential fallback and rejects reuse of the private/public bucket or key.
- Backblaze CORS configuration is an operator-only action. Private media may
  use authenticated `GET`, `HEAD`, and `PUT`; public media is read-only from
  the browser. Production rejects localhost/non-HTTPS origins. CORS admin
  credentials must not be injected into an application process.
- PostgreSQL backup automation creates a custom-format dump, SHA-256 checksum,
  and manifest, uploads all three to the dedicated B2 backup bucket with
  server-side encryption, and supports Object Lock retention when the bucket
  was created with Object Lock enabled. The production gate checks backup
  freshness; restore verifies the checksum before SQL and runs database
  invariants afterwards.
- `tfp-collage-service` now has one durable background path only: the
  `image_processing_jobs` worker. The retired opportunity-row collage polling
  worker and its `COLLAGE_*WORKER*` compatibility configuration were removed.
  Keep storage behind its explicit private/public bindings instead of adding
  generic S3 fields back to the application config. The production application
  gate requires an explicit `COLLAGE_SERVICE_URL` and independent strong
  `COLLAGE_SERVICE_API_KEY`; the legacy environment names remain at this HTTP
  compatibility boundary only.
- UAT and production moderation processes must bind to loopback, keep internal
  API-key enforcement enabled, and use a non-placeholder key of at least 32
  characters. The moderation worker consumes `TFP_DATABASE_URL` and scoped
  `B2_PRIVATE_*` values; shared/generic B2 credential aliases are local-only.
- No static validation proves a production deployment. Before launch, procure
  the production hosts and role-scoped credentials, run the production env
  doctor, deploy through the private access/reverse-proxy boundary, create a
  real backup, restore it into a disposable database, and record runtime health
  and worker-drain evidence.

## Remaining runtime evidence

These cannot be proven by static code alone and must be recorded per deployment:

- effective production database host and Redis configuration;
- reverse-proxy/edge reachability and allowed origins;
- shared rate-limit behavior across more than one API process;
- backup checksum plus successful restore to a disposable database;
- worker-drain behavior against an isolated UAT job.

## 2026-08 OCI UAT migration and retired Contabo boundary

- OCI instance `tfp-a1-free-2ocpu-12gb` (`161.118.161.98`,
  `VM.Standard.A1.Flex`, `2 OCPU / 12 GB RAM`, `ap-mumbai-1`) is the current
  private UAT host. It runs fresh host-local PostgreSQL plus the main app,
  moderation worker/API, collage service, and `tfp-oci-uat` Cloudflare Tunnel.
- Contabo VPS `13.140.189.236` is retired from UAT and must not be used for
  deployments, database tunnels, folder moderation, or application traffic.
- The older OCI E2 micro `aip-mumbai-e2-micro-new` at `140.245.30.133` remains
  separate and is not the UAT target.
- No folder-moderation images, reports, reviewer artifacts, or workspace were
  migrated to OCI; `/srv/tfp-folder-moderation` must remain absent.
- All UAT service ports bind to loopback. The public tester path is only
  `https://uat.tfpphotographers.com` through Cloudflare Access and tunnel
  `tfp-oci-uat`; administrative SSH remains a separate key-only control.
- Historical Contabo incident evidence below is retained for audit context only.
- A provider complaint alleged outbound `SSH_BRUTE_FORCE` traffic from the VPS.
  The complaint identifies the source IP but does not prove the responsible
  process, account, or person; root cause requires preserved VPS and provider
  network evidence.
- Before any reactivation or migration, deny new outbound connections to public
  TCP port `22` by default at the provider or host firewall. Use HTTPS over
  `443`, or a narrow destination allowlist, for any legitimate outbound
  deployment dependency.
- Outbound TCP/22 containment is distinct from inbound administration. Inbound
  SSH must be key-only, limited to trusted operator sources or private access,
  use an unprivileged deployment account, and disable direct root login after
  break-glass recovery.
- Preserve the disk and logs before remediation; inspect `sshd`/auth journals,
  processes, containers, cron and systemd persistence, accounts, authorized
  keys, and outbound network evidence. Rotate credentials and secrets and
  rebuild from a trusted image whenever compromise cannot be excluded.

## Design System & Architecture Auditing Rules

- **Context-Aware Boundaries**: Do not blindly enforce a Single Source of Truth (SSOT) from the database (`schema.prisma`) to the frontend if a shared contract is intentionally used instead. For instance, moderation reasons and shared boundary validations (e.g., normalizers) correctly live in shared TypeScript contracts, not Prisma schemas or Zod.
- **Validating Layout Hardcodes**: Before flagging hardcoded CSS in base files (`base.scss`), verify if they are legitimate local component rules or base normalization rules, rather than true design token bypasses.
- **UI vs. Backend Constraints**: UI previews and data upload limits can intentionally differ (e.g., mood board slicing in UI versus max upload limit in backend). Do not automatically mark them as SSOT violations.
- **Transactional Emails**: The `packages/email` transactional templates are a major visual surface. When auditing design tokens, check if backend email literals (colors, typography) are bypassing `design-tokens.json`.
- **Token Generation Sync**: The token sync script (`scripts/design-tokens/sync.mjs`) is intentionally lossy or currently incomplete (e.g., misses `cardGeometry` and some colors). Consider this before flagging components for "bypassing" tokens they don't actually have access to.
- **Mobile vs. Web QA Gates**: Remember that `qa:design-tokens` for web tests different patterns than `mobile-design-token-audit.mjs`. The mobile audit currently misses layout drift (padding, margins, radii, letter-spacing), meaning mobile code could have hardcoded layouts without failing the build.

## Mandatory Live Visual Verification Rule

- **Always Run and Check Live**: Whenever making changes that impact web or mobile UI/pages/components/styles/flows, you MUST run the application (FE/BE or mobile Metro/simulator) and visually validate the impacted pages either by computer use or by taking and viewing screenshots.
- **Never Infer Visual State**: Do not rely solely on static checks or code inspection. Inspect live rendering, layout, fonts, badges, icons, and contrast in the running browser or mobile simulator before concluding work.

## E2E Testing & Audit Methodology

- **Test Layer Hierarchy**: The E2E suite is layered (strict-human, domain, journey, smoke, visual, a11y, uat). **Never assume a feature is uncovered** just because it is missing from one layer (e.g., domain). Many critical flows (opportunity application state transitions, RSVP lifecycles, contest submissions) are covered fully in the `strict-human` suite.
- **Architectural Isolation**: The `strict-human` suite intentionally isolates itself from Prisma and direct API helpers, relying strictly on the browser and OTP bridge. Do not flag this as a "missing integration safety net."
- **Do Not Invent Gaps**: Do not list unlaunched capabilities or disabled flows (e.g., OAuth, password reset, payment/subscriptions, WebSocket notifications) as E2E coverage gaps.
- Always Verify Source & CI: Before claiming a route/module is untested or un-gated, verify the module exists (`find`) and check CI gates (`.github/workflows/`). The SSOT for coverage numbers lies in the `coverage-matrix.json`, `route-coverage.json`, and `api-source-coverage.json` files.

## Cross-Platform Shell & Navigation Parity Auditing Rules (RCA Lessons)

- **Layout Container & Navigation Stack Tracing**: Never evaluate navigation bars in isolation from route hierarchy. Mobile often bifurcates navigation between root Tab Shells (`app/(tabs)/_layout.tsx`) and pushed stack screens (`Screen.tsx` with `UniversalBottomNav.tsx`). Always audit how bottom bars, headers, and tabs transition when navigating from root tabs to pushed stack routes.
- **Semantic Destination Glyph Continuity**: When auditing navigation, verify that the same conceptual target (e.g. Home) maintains the same icon glyph across all levels. Flag cases where tab roots use one glyph (e.g. `home` house) and pushed screens switch to another (e.g. `layout-grid`).
- **Registry Presentation vs Bundling Tracing**: When UI displays a dynamic list from a shared registry (e.g. `LanguageSelector` rendering 100+ locales from `locale-registry`), trace the runtime bundle loader (`packages/i18n/src/mobile.ts`). Verify if all catalog files are actually imported or if only a subset (e.g. 3 locales) is bundled, causing silent fallbacks.
- **Shell Action Parity (Modal vs Route Navigation)**: Inspect global header/footer interaction triggers (e.g. locale selector, search, notifications, help) to ensure both platforms execute consistent interaction models (e.g., in-place modal dialog vs full screen navigation).
- **Lightbox & Viewer Icon Geometry**: When auditing media viewers (galleries, lightboxes), inspect directional control glyphs (arrows vs chevrons) and close glyphs (`x` vs `close`).
- **5-State Screen Machine Auditing (State Hierarchy Rule)**: Never audit only the "happy path" (populated grid/feed). Every screen must be explicitly verified across all 5 discrete sub-states:
  1. `Populated State` (cards, badges, pagination, metadata)
  2. `Empty / Zero State` (icon, title key, body key, CTA action)
  3. `Loading / Skeleton State` (shimmer animation, layout skeleton geometry)
  4. `Error / Network Failure State` (error icon, retry handler, message key)
  5. `Unauthenticated Gate State` (in-place modal vs stack redirect)
- **Action Handler Invocation Tracing (Modal vs Push Rule)**: Do not stop at verifying button existence and styling. Always trace the `onClick` / `onPress` callback to determine if an action triggers an in-place non-destructive overlay (`<dialog>`, bottom sheet) or a destructive route navigation (`router.push`) that unmounts screen context.
- **Component Token Assignment Hierarchy Rule**: Verifying that a shared design token table matches is insufficient. Always verify which token tier component templates actually assign (e.g., whether cards consume `$raw-bg-surface` `#0d0713` or `$raw-bg-surface-elevated` `#151021`).
- **Exact Translation Key Call-Site Diffing**: Never assume semantic equivalence in English means i18n alignment. Compare the exact string passed into `t('...')` across templates to prevent duplicate namespaces (e.g. `listing.*` vs `mobile.opportunities.*`).

## Cross-Platform Visual & Parity Audit Calibration Rules (RCA & False-Positive Prevention)

- **Rendered Component Tree vs Static Route Declarations**: In Expo Router (`app/(tabs)/_layout.tsx`), `<Tabs>` accepts `tabBar={({ state }) => ...}` to completely replace the default tab bar with a custom renderer like `<UniversalBottomNav />`. Never infer the rendered UI tab bar from the list of `<Tabs.Screen>` declarations alone; always inspect the runtime `tabBar` render function.
- **Responsive Mobile Media Queries vs Desktop Base SCSS Tokens**: Never compare desktop base SCSS token declarations (e.g. `$space-4: 16px`, `$space-5: 20px`) against mobile viewports (e.g. 402px). Always evaluate cascading `@media (max-width: 640px)` and `@media (max-width: 480px)` overrides, where web gutters collapse to 12px and card padding drops to 8–12px.
- **Respect Checked-In Platform Specifications & Design Guides**: Always consult `docs/mobile/mobile-app-design-guide.md` before classifying platform UX differences as defects. Native full-screen stack pushes for auth, reports, and onboarding are intentionally mandated for mobile UX; attempting to convert them into Web-style popover modal dialogs violates the native platform contract.
- **Native Bundler Static Asset Context**: Never classify PNG, JPG, or SVG assets as "unused" based solely on ES6 `import` greps in `.tsx` files. Check Expo native build manifests (`app.config.ts`, `app.json`), iOS `Info.plist`, and Android manifests for static app icons, splash screens, and adaptive icon definitions.
- **Component Geometry & Wrapper Verification**: When auditing component decorations (e.g. 36×36 icon bubbles), verify computed CSS dimensions (`2.25rem = 36px`) in `.scss` files (`_detail-info.scss`) before asserting that Web lacks the container. Distinct border or subtle background opacities should be reported precisely as styling nuances, not missing containers.
- **Active Navigation Styling Alignment**: In `_base-layout.scss`, `.mobile-nav-link[aria-current="page"]` uses a cyan (`var(--accent-cyan)`) radial gradient and cyan glow. Native `UniversalBottomNav.tsx` uses the identical `colors.cyan` radial glow. Always check active pseudo-classes and CSS variables before flagging theme divergence.

## Semantic Token Hierarchy & Micro-UI Leaf Component Auditing Rules (RCA Lessons from 8fde90f5)

- **Full CSS Variable Cascade Resolution (No Raw Value Grep Assumptions)**: When auditing Web styling against Mobile React Native tokens, resolve all CSS custom properties (`var(--link-color)`, `var(--accent-gold)`, `var(--listing-advanced-search-color)`, etc.) across `_css-vars.scss` and `_tokens.scss` down to their computed hex values. Never assume an element is not styled with Gold simply because `color: #f2d28a` or `$color-gold` is not written literally in the component SCSS file.
- **Three-Tier Semantic Interactive Color Taxonomy**: Monorepo design system strictly separates interactive elements into three distinct semantic tiers:
  1. **Tier 1 (Primary CTAs / Solid Buttons / Primary Form Submits)**: Brand Pink / Magenta (`#d61f69` / `#ec4899` / `colors.primary`, `colors.primaryLight`).
  2. **Tier 2 (Inline Navigational Links, Chevrons, Dropdown Triggers, Section Action Links)**: Warm Gold (`#f2d28a` / `colors.gold` / `var(--link-color)`, `var(--accent-gold)`). This includes card footer links (`"View details >"` in `cards.tsx`), filter triggers (`"Advanced Search"` in `ListingFilterNav.tsx`), section headers (`"See all >"` in `SectionHeader.tsx`), and dropdown trigger/chevron icons (`PillDropdown.tsx`, `Dropdown.tsx`, `LanguageSelector.tsx`). Never apply Primary Pink (`#ec4899`) to Tier 2 inline links or chevrons.
  3. **Tier 3 (Live Notifications, Active Nav Radial Glows, Real-Time Status Dots)**: Cyan (`#5ee7ff` / `colors.cyan` / `var(--accent-cyan)`).
- **Bottom-Up Leaf Component Auditing**: In addition to top-down screen walkthroughs, systematically audit the core presentation component library primitives (`apps/mobile/src/presentation/components/*`) against web SCSS component tokens. Fixing a token in a shared leaf component (`PillDropdown.tsx`, `cards.tsx`, `SectionHeader.tsx`, etc.) automatically enforces DRY parity across dozens of screens.
- **Color Invariant Assertions in Presentation Contract Tests**: When writing component tests, assert semantic color invariants on icons and text links (e.g. `expect(icon.props.color).toBe(colors.gold)`) so token drift cannot silently regress without failing CI.

## Anti-Hallucination & System Audit Calibration Rules (RCA Lessons from 2026-09 Cross-Agent Audit Review)

- **AST & Runtime Branch Tracing Before Reporting Findings**:
  - Never conclude a service behavior from the existence of a helper function or an early middleware bypass.
  - In `tfp-collage-service`, the root route `/` branches on `['production', 'prod', 'uat'].includes(config.environment)` to return `{ status: 'ok' }`. The interactive HTML test GUI is served **only in development/local**.
  - `config.ts` enforces `IMAGE_PROCESSING_SERVICE_API_KEY` of $\ge 32$ characters in UAT/prod; startup throws if missing or weak. Do not claim auth is optional or test forms are exposed in production.
- **Threat Model & Attacker Ingress Verification Before P0/P1 Severity**:
  - Do not escalate a code pattern (such as DNS rebinding in `collageMaker.ts`) to P0 Critical without verifying whether an attacker-accessible entrypoint exists.
  - In `tfp-collage-service`, the durable background worker (`imageProcessingWorker.ts`) reads verified source objects directly as buffers from Backblaze B2/S3 storage via `storage.privateSources.read()`, completely bypassing `fetchImage()`.
  - The HTTP endpoint `/api/v1/generate-collage` binds strictly to loopback (`127.0.0.1`), is internal-only, and requires an internal API key. DNS rebinding hardening is a defense-in-depth improvement (P2), not an active P0 exploit.
- **Empirical Measurement vs. Synthetic Model Calculations**:
  - In `tfp-ai-interface`, `M2M100` is **already converted to and run in CTranslate2 int8 quantization** (`translation.py:117-130`). Never report it as unquantized FP32 consuming 1.7 GB RAM or recommend quantizing with ONNX/optimum.
  - In `tfp-collage-service`, `imageProcessingWorker.ts:204` processes jobs **serially** (`claimJobs(1)` per loop iteration). Do not hallucinate scenarios with 50 parallel image jobs crashing the 12 GB ARM64 host without verifying concurrency limits.
- **Transaction Scope & Caller Call-Site Verification**:
  - Before claiming a database helper leaks locks or has a race condition (e.g. `claimPendingOutboxRows` executing `SELECT ... FOR UPDATE` followed by `UPDATE`), trace every caller in the codebase.
  - All three outbox callers wrap invocations in `prisma.$transaction(async (tx) => ...)`. Under PostgreSQL's MVCC model, row locks are held until transaction commit/rollback. A single CTE update is an optimization, not a live lock-leak bug.
- **Probe Endpoint Naming Accuracy**:
  - The Fastify API exposes `/health` and `/ready` (`apps/api/src/plugins/health.ts`), not `/health/live` and `/health/ready`.
  - Do not assume Kubernetes/cloud conventions without inspecting actual route registrations.
- **Preserve Domain Invariants in Code Proposals**:
  - When proposing SQL query optimizations (e.g. CTE for outbox claims), preserve all existing domain exclusions (`event_name <> process_moderation`, `event_name <> process_translation`, etc.) and stale-processing recovery intervals (`INTERVAL '5 minutes'`).
  - When proposing fetch replacements, do not drop redirect rejections, byte streaming limits, or content-type checks, and verify imports exist in the module.
- **No Pseudo-Quantitative Maturity Scores**:
  - Never invent arbitrary numerical scores (e.g. "7.8/10") or blanket compliance certifications unless evaluating against a formally defined, mathematically reproducible evaluation rubric.

