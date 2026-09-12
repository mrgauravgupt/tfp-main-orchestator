# Workspace-Wide Agent Notes

## Fast Orientation

- Read `RULES.md` for non-negotiable deployment and event-outbox safety rules.
- Read `MEMORY.md` for the current cross-repository architecture and runtime-evidence baseline.
- For product work, then read `tfpphotographers/docs/agent-index.json` and the nested repository `AGENTS.md`.
- The durable-event and release-gate guide is `tfpphotographers/docs/architecture/EVENT_OUTBOX_AND_DEPLOYMENT_READINESS.md`.
- The required pre-commit checks and validation flow is in `tfpphotographers/docs/operations/AGENT_DUE_DILIGENCE.md`.

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-main-orchestator`.
- Main application workspace: `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers`.
- For domain-level routing in the app workspace, use `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/docs/agent-index.json` first.
- If both root and nested workspaces changed, update and commit in both repositories.
- For cross-repo operator work, prefer the checked-in menu and runbook paths first:
  - `tfpphotographers/scripts/manage-tfp.sh`
  - `tfpphotographers/scripts/manage-tfp-mobile.sh`
  - `tfpphotographers/scripts/start-app.sh`
  - `tfpphotographers/tests/create-data/README.md`
  - `tfpphotographers/docs/operations/AGENT_RUNTIME_AND_SEED_GUIDE.md`
  - `tfpphotographers/docs/mobile/mobile-app-design-guide.md`
  - `tfpphotographers/docs/mobile/mobile-app-implementation-todo.md`

## Commit Preference
- For this workspace, commit completed work by default unless the user explicitly says not to.
- When the user asks to "commit everything", stage and commit the full current working tree as-is, including untracked files, with a clear summary message.
- If a nested project has its own `AGENTS.md`, follow those instructions in addition to this file.

## Commit Message Conventions
- Use clear, scoped commit subjects (50-72 chars when possible).
- Prefer imperative style: `feat(...)`, `fix(...)`, `docs(...)`, `chore(...)`.
- Add a concise body for non-trivial changes: what changed, why, and any risk notes.

## Execution Defaults
- Before starting repository work, sync the latest remote changes for any repo that has a configured remote.
- If `git pull --rebase` is blocked by unrelated local changes, continue with scoped work, leave those changes untouched, and mention the skipped sync in the final report instead of stopping the task.
- After completing each meaningful fix in a repo with a configured remote, push the commit promptly unless the user explicitly says not to.
- If work happens on a branch, merge it back into `main` promptly after validation unless the user explicitly says not to. `main` should remain updated with completed work.
- For browser, UI, integration, or end-to-end work that depends on the running app, always restart both FE and BE first.
- **Mandatory Live Visual Verification**: Always run the application (web or mobile) and inspect impacted pages/screens either by computer use or by capturing and inspecting screenshots. Never guess, assume, or infer visual correctness from static checks or tests alone.
- Treat restart order as mandatory for any fresh UI verification pass: stop stale processes, restart services, confirm FE and BE health, then test.
- For destructive seed/reset work, use the checked-in launcher flow:
  - `bash ./scripts/start-app.sh reset <env>`
  - `pnpm qa:create-data:seed:real:quick`
  - `bash ./scripts/manage-tfp.sh` for menu-driven operator flows.
- Run fast validation before finalizing when applicable (`tsc`, build, and targeted tests).
- Do not revert user-authored unrelated changes unless explicitly requested.
- **Dirty Workspace Policy**: Unrelated pre-existing changes in the working tree are not blockers by themselves. Continue with the requested task. Make code changes very carefully to avoid overwriting anyone else's changes.
- **Selective Commits**: Stage, commit, and push only your specific changes. Avoid staging unrelated modified files.
- **Git Worktree Isolation Option**: Alternatively, if the working tree has complex dirty files, you may choose to execute your work inside a separate `git worktree` and merge back in the end, carefully committing and pushing only your changes.
- Keep changes minimal, traceable, and production-safe.
- API proxy trust requires both `TRUST_PROXY_HOPS` and the address allowlist
  `TRUST_PROXY_CIDRS` (defaults to exact IPv4/IPv6 loopback for OCI). Never
  restore numeric-only Fastify trust; see the app environment guide.

## Audit, Code Review & Counter-Verification Standards
- **Never Rely on Docs, Comments, or Markdown as Truth**: Markdown documents, docstrings, schema comments, and type definitions are pointers only. The sole sources of truth are current executable code, AST branches, and active configuration defaults. Always trace the actual code before drawing conclusions or proposing changes.
- **Audit Tests for False Confidence**: Never accept a passing test at face value. Verify that the test actually reaches the code under test (e.g., verifying that test request headers match active configuration like `LOCATION_CLIENT_IP_HEADER_ORDER` rather than getting discarded before fetch). Ensure tests fail when the tested behavior is broken. Avoid shallow mocks that bypass real HTTP/socket behavior.
- **Trace Full AST & Runtime Branching**: Never conclude a security weakness or behavioral defect from helper definitions or middleware bypasses alone. Always trace environment conditionals (`isProductionLike`, `config.environment`), router definitions, and startup secret assertions.
- **Threat Model Verification Before Severity Assignment**: Verify whether an attacker-accessible entrypoint exists before labeling an issue as P0/Critical. Distinguish internal defense-in-depth from active public exploit vectors.
- **Inspect Concrete Implementations, Not Assumptions**: Check actual model converters and runtime flags (e.g., CTranslate2 `int8` quantization in `translation.py`) and worker polling loops (serial vs concurrent) before calculating memory footprints or claiming OOM risks.
- **Verify Caller Call-Sites for Concurrency Invariants**: If a database helper accepts a generic client, inspect all callers. If all callers execute inside active transactions (e.g. `prisma.$transaction`), row locks are retained until commit under PostgreSQL MVCC.
- **Cross-Service Schema Synchronization**: When modifying cross-service events or jobs (e.g., `tfp-ai-interface` $\to$ `apps/api`), verify that new metadata is accepted by the consumer's canonical validator. Producer writes without consumer validator support cause terminal outbox job failures.
- **Privacy in Validation and Observability**: Audit that tracing identifiers are strictly bounded (`^[A-Za-z0-9._:-]{1,128}$`) and that raw schema errors (which can dump received user input/PII) are not logged or stored in `last_error` unredacted.
- **Resilient Resource Lifecycle**: Verify that connection pools and external clients handle boot errors without orphaned state and that shutdown sequences use `try/finally` across all resources.
- **Preserve Domain Invariants in Code Proposals**: When drafting proposed fixes, preserve all existing event exclusions, stale recovery intervals, redirect checks, and byte caps. Verify module exports before writing import statements.
- **Ground Route Names in Code**: Check actual route registrations (e.g. `/health` and `/ready` in `health.ts`) rather than assuming conventional framework defaults.
- **Precision in Engineering Claims**: Distinguish structural mechanisms from empirical operational guarantees (an index is not proven latency under millions of rows; rate-limit backoff/cooldown is not a 3-state circuit breaker; serial batch processing is not an absolute OOM shield). Run affected downstream consumer tests (e.g. notification event handlers) immediately when domain events change.
- **No Arbitrary Maturity Scores**: Avoid fabricated numerical scores (e.g. "7.8/10") unless evaluating against a formally defined, mathematically reproducible evaluation rubric.
- **UI/UX & Visual Audit Discovery Standards**:
  - **Triangulate Observations with AST/DOM**: Pair visual anomaly detection with code and DOM inspections to verify if an issue is a genuine defect, an unexpected collision, or an intended responsive pattern.
  - **Root Cause & Blast Radius Architecture**: When an anomaly spans multiple routes or components, trace the shared configuration, layout wrapper, or theme token. Report the root issue as the primary defect and list all affected screens as its blast radius to avoid redundant noise.
  - **Contextual Pattern Evaluation**: Assess whether responsive patterns (e.g. line-clamping, horizontal scrolling chip bars, dismissible consent banners, and auth-guard redirects) serve user intent or cause usability degradation in edge cases.
  - **Lifecycle & Settled State Awareness**: Capture and evaluate both transient states (refresh spinners, in-flight refetching) and settled states (network idle) to accurately distinguish expected loading lifecycles from frozen interfaces.
  - **Catalog & Fixture Ground Truth**: Cross-reference suspected text truncation against translation catalogs (`packages/i18n`) and database fixtures to differentiate strings flowing below the initial viewport fold from genuine code truncation.
  - **Native Viewport & Navigation Insets**: On mobile views, calibrate scroll view content padding to properly accommodate device safe-area insets and persistent navigation bars (~65–80px).

## UI Remediation & Code Quality Standards
- **Centralized Tokens Over Page-Local Magic Numbers**: When fixing layout insets or responsive spacing across multiple screens, introduce a single shared token (e.g., `persistentNavigationContentInset = bottomNavigation.contentHeightPx + spacing.xl;`) in design tokens and verify it in token tests. Never patch multiple screens with arbitrary one-off pixel values.
- **Shared Component Encapsulation Over Inline Patching**: Encapsulate recurring presentation logic (such as remote image fallback handling) into reusable components (e.g., `ManagedContentImage` on native, `data-image-fallback` on web). Reset state predictably on identity change (`sourceIdentity`), provide localized labels, and avoid repeating error-handling boilerplate across views.
- **Semantic & Accessible Control Association**: Wrap form inputs and dropdowns in semantic `<label>` containers (e.g., `<label class="admin-filter-field"><span>...</span><select>...</select></label>`). Never leave controls with identical placeholder options (e.g., consecutive "All" dropdowns) without visible, accessible parameter labels.
- **Decoupled Placement Over Space-Cramming**: When badges, tags, or metadata collide on narrow screens, decouple their positional anchors (e.g., move date badges to bottom of media container) or expand grid items to `flexBasis: '100%'` with `flex: 1` rather than forcing cramped multi-column flex-basis on narrow widths.
- **Contract Tests for Structural & Visual Invariants**: Guard against UI regressions by writing fast, deterministic contract tests (`*.contract.test.ts`) that read component source files to assert invariants (e.g., presence of semantic headers, absence of duplicate titles, correct inset bindings).
- **Preserve Environment-Driven Security Boundaries**: Never inject ad-hoc origin exceptions into CSP headers or network configs to bypass a local issue; always ensure policies derive dynamically from canonical environment variables (e.g., `IMAGE_DELIVERY_BASE_URL`).

## The Standard 7-Stage Remediation & Verification Lifecycle
1. **Discovery & Cross-Layer Dot-Connecting (5-Plane Pre-Edit Triangulation)**:
   - Use targeted shell inspections (`sed -n '<start>,<end>p'`, `rg -n`) to inspect actual configuration, scripts, and component code before modifying files.
   - Correlate across five planes simultaneously: (1) DOM/view layout, (2) runtime AST and environment conditionals (`NODE_ENV`, `TFP_ENV_TARGET`), (3) transaction and lock boundaries (e.g., `pg_advisory_xact_lock`), (4) host resources and port listeners (`lsof`, disk space, process tables), and (5) edge/network headers.
   - Trace design tokens and calculations directly via Node (e.g. `node -e "const d=require('./packages/shared/design-tokens.json'); console.log(...)"`).
   - Check if an apparent bug is caused by environment configuration (e.g. CSP resolving `IMAGE_DELIVERY_BASE_URL`) rather than hardcoding code-level exceptions.
2. **Incremental Batch Editing with Fast Pre-Flight Syntax & Typechecks (Fail-Fast)**:
   - Make edits in small, logically related batches (3–5 files).
   - Run zero-cost pre-flight syntax checks: `bash -n <scripts>` for shell scripts, `jq empty <json>` for JSON configs, and `git diff --check` for whitespace anomalies or unresolved merge conflict markers.
   - Run target app typechecks (`pnpm --filter <app> typecheck`) immediately after each batch to catch syntax/typing issues before expanding scope.
3. **Deterministic Contract Testing First**:
   - Write fast, lightweight AST/source contract tests (`*.contract.test.ts`) that read component source files directly to assert invariants (no duplicate headings, presence of required fallback props, correct inset bindings).
   - Execute them via Vitest (`vitest run <test-path>`) in milliseconds for instant regression feedback.
4. **Comprehensive Static & Build Gates**:
   - Run the complete package unit suites (`mobile test`, `web test`).
   - Run workspace linting (`pnpm lint`) and full production builds (`pnpm build`).
5. **Mandatory Live Web Runtime Verification**:
   - Restart the local FE+BE stack using the canonical launcher (`bash ./scripts/restart-app.sh local`).
   - Resolve local environment mismatches (e.g. PostgreSQL roles) using documented runtime overrides (`TFP_DB_ADMIN_ROLE=hexa TFP_DB_OWNER=hexa`) rather than destructive database resets or seeds.
   - Align E2E test timestamp generators with component timezone locality (`Asia/Kolkata` vs UTC) to prevent invisible HTML5 form validation `rangeUnderflow` rejections.
   - Run an automated Playwright probe across desktop (1440x900) and mobile (390x844) checking key routes for: HTTP 200, zero console errors, zero horizontal overflow, zero broken images, and correct tap targets.
6. **Live Native Device/Simulator Verification**:
   - Boot the target iOS simulator (`xcrun simctl bootstatus <device-id>`), launch the app, and open deep links.
   - Dismiss developer menus, Metro overlays, or tooling sheets before capturing screenshots to avoid visual artifact confusion.
   - Validate scroll clearance and bottom navigation insets using automated flows (e.g. Maestro).
7. **Exhaustive Caller Audit & Clean Two-Phase Commit**:
   - Search for all callers of modified shared components (`rg -n '<ComponentName'`) to ensure no consumers were missed before committing.
   - Stage only the scoped files in the nested repository (`git add -- <files>`), verify `git diff --cached --check`, commit, and push.
   - Verify unrelated dirty submodules remain untouched, stage only the submodule pointer in the root repository, commit, and push.

## Testing Conventions
- Prefer test roots over colocated source tests for new work:
  - app-local: `apps/<app>/tests/**`
  - workspace-level: `tests/**` for cross-app E2E/contract flows
- Keep API and web unit/integration tests in app-local test roots (`apps/api/tests/**`, `apps/web/tests/**`).
- Mobile currently keeps pure domain tests under `apps/mobile/src/**/__tests__` to keep Expo-facing rules close to the native implementation; if mobile component/E2E coverage expands, add app-local `apps/mobile/tests/**` and document the command here.
- When creating or updating test scripts/flows, update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/README.md` in the same change so script usage stays discoverable.
- When changing browser seed assets/configs/commands, also update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/create-data/README.md`.

## Reporting Expectations
- Final responses should include:
  - what was changed,
  - file paths affected,
  - commit hash(es),
  - verification commands run.

## Agent Capabilities & System Access
- **MCP Servers**: Equipped with `filesystem`, `github`, `prisma-mcp-server`, and `puppeteer`.
- **Advanced Skills**: Equipped with plugin-based developer skills (`chrome-devtools`, `firebase-*`, `a11y-debugging`, `debug-optimize-lcp`, `troubleshooting`, `modern-web-guidance`, `uv`, etc.).
- **System Access via Shell**:
  - Direct execution access via `run_command` on the host macOS system.
  - Silent desktop screen capture via `screencapture -x /Users/hexa/.gemini/antigravity/scratch/screen.png`.
  - Opening files or launching apps via macOS `open`.
- See the full directory of tools and workflows in [SKILLS.md](file:///Users/hexa/Desktop/tfp-main-orchestator/SKILLS.md).

## Multi-Agent Coordination & Context Sharing
- **Workspace Sharing**: When spawning subagents via `invoke_subagent`, always prefer `inherit` or `share` workspaces to ensure they share file states and db states.
- **Messaging Protocol**: Use `send_message` with recipient conversation IDs to pass data and completion flags. Do not poll peer agent statuses in a loop.
- **Persistent State**: Document all configuration drift, branch switches, or tool updates in `MEMORY.md` and `AGENTS.md` so parallel/future agents inherit the context on startup.
- **Transcript Audits**: If tracing peer actions is needed, read the local JSONL log at `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl`.

## Cross-Agent & Codex (Vibe Coding) Coexistence Rules
- **Branch Strategy**: Since Codex creates feature branches prefixed with `codex/`, always verify the current active branch and pull the latest changes before starting work.
- **Worktree Isolation**: Respect Codex's isolated worktrees (e.g., in `/Users/hexa/.codex/worktrees/`). Do not modify files in those paths unless explicitly instructed.
- **Database Consistency**: If schema or migration changes are made by Codex, regenerate the Prisma client using `pnpm db:generate` and run migrations with `pnpm db:migrate`.
- **State Synchronization**: Document all active changes, new ports, or configuration variables in `MEMORY.md` and `AGENTS.md` to ensure both Antigravity and Codex read the same single source of truth.

## OCI UAT Database Rule

- UAT for the TFP stack uses PostgreSQL installed on the OCI UAT host, bound to `127.0.0.1:5432`; it does not use Contabo or a developer-local fallback.
- Local operator scripts that need direct database access must SSH-forward to the OCI host-local PostgreSQL listener through `ubuntu@161.118.161.98`.
- Keep the app, collage worker, and image moderation worker pointed at the same OCI host-local PostgreSQL database so they share moderation and collage state.
- Use localhost only for local and development workflows unless a task explicitly asks for an isolated override.

## Queue And Background Worker Audit Rule

- Do not flag the current PostgreSQL-backed queue/outbox model as a BullMQ/Redis migration requirement by default.
- The app intentionally uses database-backed job state for domain workflows where queue state must stay close to moderation, upload, report, opportunity, event, contest, and collage records.
- `event_outbox`, worker polling, retry fields, stale-processing recovery, and `FOR UPDATE SKIP LOCKED` are valid architectural choices in this workspace, not audit findings on their own.
- BullMQ/Redis should be recommended only when there is measured operational pain: backlog/latency under load, expensive DB polling, missing dead-letter/operator visibility that cannot be solved simply, many worker pools, complex delayed retries, or a real need for Bull Board-style queue operations.
- Prefer first improving the existing DB-backed model with health checks, backlog/failure queries, terminal failed/dead-letter states, indexes, stale-job recovery, and operator docs before proposing a queue migration.
- When comparing queue options, treat PostgreSQL consistency and inspectability as strengths for this product, especially because UAT services share one OCI PostgreSQL state source.

## OCI vs Retired Contabo Rule

- OCI is the current and only UAT deployment target. Use root `scripts/oci/*` for full-stack UAT orchestration and service-local `scripts/deploy/*` for each deployable.
- The active host is the Always Free Ampere instance `tfp-a1-free-2ocpu-12gb` at `161.118.161.98`, shape `VM.Standard.A1.Flex`, with `2 OCPU / 12 GB RAM` in `ap-mumbai-1`.
- The older OCI E2 micro `aip-mumbai-e2-micro-new` at `140.245.30.133` is retained separately and is not the UAT deployment target.
- Contabo `13.140.189.236` is retired from UAT. Do not deploy, tunnel, seed, moderate, or run database operations against it unless the user explicitly authorizes a historical incident/recovery task.
- The acquisition helper `scripts/oci/acquire-a1-free.sh` remains available for capacity management; it is not the deployment entrypoint.

## UAT Deployment Target (OCI Always Free)

- **Environment boundary**: This host is for private UAT only. The TFP product
  has not been launched publicly from this instance; nevertheless, apply the same
  host-security baseline expected of an internet-reachable production host.
- **UAT Host Details**:
  - **Display Name**: `tfp-a1-free-2ocpu-12gb`
  - **Public IPv4**: `161.118.161.98`
  - **Private IPv4**: `10.0.1.114`
  - **Shape**: `VM.Standard.A1.Flex` (`2 OCPU / 12 GB RAM`, ARM64)
  - **Region / AD**: `ap-mumbai-1` / `lqoG:AP-MUMBAI-1-AD-1`
  - **OS / SSH user**: Ubuntu ARM64 / `ubuntu`
  - **Public tester URL**: `https://uat.tfpphotographers.com`
  - **Cloudflare tunnel**: `tfp-oci-uat` -> `http://localhost:8080`
- **Private service listeners**: PostgreSQL `5432`, API `4000`, web `8080`, AI inference `7011`, and collage `7003/7004` bind only to `127.0.0.1`. There is no V1 moderation runtime.
- **Public ingress**: application ports are closed at OCI and the host firewall. Only key-based administrative SSH is retained; tester traffic must pass Cloudflare Access and Tunnel.
- **SSH network boundary**:
  - Treat the August 2026 `SSH_BRUTE_FORCE` report as alleged outbound traffic
    from the retired Contabo VPS; the root cause remains unproven until host and
    provider logs can be correlated. It is historical context, not OCI evidence.
  - Deny new outbound connections to public TCP port `22` by default before
    restoring general network access. Allow only explicitly reviewed destination
    addresses when a real deployment dependency requires SSH; prefer HTTPS over
    port `443` where possible.
  - Do not implement this as a blanket two-way port-22 closure. Administrative
    inbound SSH remains a separate control and must be key-only, restricted to
    trusted operator sources or a private access path, use an unprivileged
    deployment account, and disable direct root login after recovery/bootstrap.
  - On reactivation or migration, preserve evidence first, inspect auth and
    process persistence, rotate credentials and application secrets, and rebuild
    from a trusted image if compromise cannot be excluded.

## Folder Moderation Boundary

- Folder moderation is not deployed to OCI UAT. `/srv/tfp-folder-moderation` must remain absent, and no images, raw reports, reviewer chunks, or generated folder-audit artifacts may be transferred by normal UAT deployment.
- No folder-moderation launcher exists in the active repositories. Reintroducing one requires explicit, separately scoped authorization.
- If folder moderation is reintroduced later, it needs a new private-storage design and a dedicated runbook; do not silently point the legacy wrapper at OCI.

## Strict-Human E2E Program Architecture & Use-Case Ledger Governance

- **Canonical Ledger (`tests/e2e/human/use-case-coverage.json`)**:
  - The business use-case ledger is the single source of truth for use-case execution, evidence, and release certification.
  - `coverage-matrix.json` is retained solely for feature inventory and compatibility projection; it must never compete for case status, actions, or evidence ownership.
- **Canonical Schema Requirement**:
  - Use schema-versioned JSON with explicit typed arrays: `id`, `featureIds`, `title`, `domain`, `actors`, `entryRoutes`, `apiRouteSources`, `preconditions`, `visibleActions`, `visiblePostconditions`, `persistedPostconditions`, `negativeStates`, `runtimeProfiles`, `browserProjects`, `specs`, `status`, `blocker`.
  - Singular scalar fields (`actor`, `entryRoute`, singular API aliases) are prohibited.
- **Strict Status Lifecycle**:
  - Static values and actors come from `VALID_STATIC_STATUSES` and `VALID_ACTORS` in the shared executable contract; do not duplicate enums in guidance or add unsupported schema values.
  - `planned`: Use case is cataloged with visible actions/postconditions, but automated test block is not yet complete.
  - `implemented`: Test block exists, is annotated with `// @use-case <id>`, and asserts every action/postcondition claimed.
  - Runtime proof is derived from every required test variant/browser/profile plus compatible original evidence for the exact revision/context. Never write `runtime-proven` into the static ledger.
  - `blocked`: Validated product behavior exists but a concrete external dependency prevents execution (must specify blocker reason).
  - API/native architectural dispositions are separate from static business-case statuses; source-file presence cannot become passed execution.
  - Never blanket-label use cases `implemented` or `runtime-proven` to achieve green totals.
- **Direct Test-Block Traceability (`// @use-case`)**:
  - Place `// @use-case WEB-E2E-*` directly inside or adjacent to the exact `test(...)` declaration block implementing the case.
  - Static guards must enforce bidirectional integrity: every implemented case has a matching test-block annotation, every annotation references an existing ledger case, and mapped specs contain the annotation.
- **Strict Pre-Flight Route & Browser Alignment**:
  - Every `entryRoutes` item must normalize and strictly match a route defined in `route-coverage.json`. Unknown or synthetic routes (e.g. `/onboarding`, `/settings/*`, `/messages/:conversationId`, `/dashboard`) fail the guard immediately.
  - `browserProjects` must strictly reflect executable projects defined in `playwright.shared.ts` (`chromium`, `firefox`, `mobile-chromium`). WebKit must be omitted until an executable WebKit launcher is implemented and verified.
- **Unified Pipeline & Hash Integrity**:
  - Evidence manifests (`human-evidence.ts`), aggregate reports (`generate-human-e2e-report.mjs`), and release verifiers (`verify-human-e2e-release.mjs`) must consume `use-case-coverage.json`.
  - Manifests must record SHA-256 hashes of all four registries (`use-case-coverage.json`, `coverage-matrix.json`, `route-coverage.json`, `api-source-coverage.json`) and the validated application git commit.
  - Partial or focused test runs must calculate status per test block, ensuring unexecuted sibling cases remain `not-run`.
- **Program Aggregate Integrity**:
  - A child run represents exactly one browser project and one runtime profile. It is partial diagnostic evidence even when every executed test passes; only a compatible aggregate containing every ledger-required browser/profile slot may certify.
  - Keep `applicationCommit` and `harnessCommit` separate. Derive aggregate identity from validated frozen child contexts, and bind each aggregate entry to its regular, non-symlink child manifest, context, Playwright project, evidence, release, registry hashes, and content hash.
  - Reject duplicate child paths, hashes, run IDs, and browser/profile slots. Generator, reporter, child, and verifier failures must remain non-zero even when per-child or aggregate release verification is explicitly skipped.
  - Positive verifier fixtures must execute the same representative use case across its real declared browser/profile Cartesian product. Each rejection fixture must assert the intended failure, not merely any non-zero exit.
  - Browser/transport limitations are certification blockers, not documentation exceptions. In particular, the current UAT private-tunnel CORS bypass supports Chromium projects only; do not claim UAT Firefox target proof until an executable compatible transport exists.
- **Certification workflow owner**: `tfpphotographers/tests/e2e/README.md#versioned-strict-human-certification-contract` documents versioned context, safe commands, and open work; code/tests remain authoritative. Require actual shell parsing, E2E typing, positive CLI/pipeline fixtures, and discriminating rejection tests. The operation guard is a focused AST static policy (`scripts/qa/support/human-e2e-operations.mjs`) with documented limits. Discovery is not download/CRUD/persistence proof, and no walkthrough can override failed or unexecuted gates.
