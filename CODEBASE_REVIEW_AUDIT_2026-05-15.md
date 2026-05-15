# Full Codebase Review Audit

Date: 2026-05-15  
Workspace root: `/Users/hexa/Desktop/tfp-latest`  
Primary application workspace: `/Users/hexa/Desktop/tfp-latest/tfp-workspace`  
AI inference workspace: `/Users/hexa/Desktop/tfp-latest/ai-inference-platform`  
Scope: Documentation-only audit. No executable application source, test specs, config, or generated asset changes were made.

## Executive Verdict

This workspace is a multi-repository product surface, not a single flat app. The root repository is mostly a wrapper, documentation, audit artifacts, local tooling, and gitlinks. The real product code lives in:

| Area                  | Verdict                                                                                           | Reason                                                                                                                                                                                                       |
| --------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| TFP web/API monorepo  | Functional but not release-clean                                                                  | Architecture and typecheck pass, but dependency audit reports one critical advisory and multiple high advisories. There is also architecture drift around direct Prisma access outside the repository layer. |
| AI inference platform | Validation-clean in the current working tree, but not deployment-clean yet                        | `uv run ruff check .` and `uv run pytest -q` now pass in the re-audit snapshot. Production deploy defaults still need fail-closed playground/API hardening before public exposure.                           |
| UI/FE                 | Broad, mature, and heavily tested, but high-risk admin surfaces need tighter rendering discipline | Public/auth/admin routes are well covered, but admin/report JavaScript still has many HTML rendering sinks that deserve centralized rendering and regression coverage.                                       |
| Backend/API           | Strong domain split with real CSRF, auth, upload, moderation, and repository foundations          | The intended architecture is clear, but enforcement does not fully prevent command/service/middleware Prisma usage.                                                                                          |
| Tests/QA              | Very deep coverage and manual QA infrastructure                                                   | The test tree is unusually large and useful, but tracked fixtures and ignored local reports make the repo heavy and harder to operate.                                                                       |

Release posture: do not treat the current state as production-ready until the dependency audit and AI production exposure defaults are addressed. The previous AI lint/test failure is resolved in the current checkout snapshot, but the deployment-hardening concern remains.

## 2026-05-15 Reaudit Update

This update refreshed the previous audit against the current checkout without changing executable application source, test specs, configs, or generated assets.

| Area                       | Current result                                      | Reaudit note                                                                                                                                                                                                                               |
| -------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Detailed clutter audit     | Added                                               | See `tfp-workspace/docs/audit/2026-05-15-code-clutter-reaudit.md` for the focused code/test/artifact clutter register.                                                                                                                     |
| Root repo                  | Dirty wrapper state remains                         | Root still shows modified nested gitlinks plus untracked `.cline/` and `ingress-rules.json`; these were not touched.                                                                                                                       |
| TFP repo sync              | Rebase sync blocked; branch is `0 ahead / 0 behind` | `git pull --rebase` was blocked by unrelated unstaged files in the nested repo; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`.                                                                                     |
| AI repo sync               | Rebase sync blocked; branch is `0 ahead / 0 behind` | `git pull --rebase` was blocked by the pre-existing modified generated/static policy artifact `src/ai_inference_platform/static/policy/tfp-moderation-policy.json`; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`. |
| TFP architecture lint      | Passed                                              | `bash ./scripts/pnpm-node20.sh lint:architecture` reports `Architecture boundary check passed.`                                                                                                                                            |
| TFP typecheck              | Passed                                              | `bash ./scripts/pnpm-node20.sh typecheck` completed across workspace packages, Astro, and API TypeScript.                                                                                                                                  |
| TFP design-token audit     | Passed                                              | `bash ./scripts/pnpm-node20.sh qa:design-tokens` passed across 285 source files.                                                                                                                                                           |
| TFP SEO integrity          | Passed with warnings                                | Health score `80/100`, `0` errors, `20` warnings; all warnings are short opportunity/contest descriptions below 150 characters.                                                                                                            |
| TFP dependency audit       | Failed                                              | Still 18 advisories: 1 critical, 11 high, 5 moderate, 1 low.                                                                                                                                                                               |
| TFP moderation policy SSOT | Passed                                              | Only `policy_ai_inference_raw_envelope.yml` exists under `scripts/qa/test-folder-moderation/policies`; raw-envelope loader, playground, and tests point at that file.                                                                      |
| AI lint                    | Passed                                              | `uv run ruff check .` reports all checks passed.                                                                                                                                                                                           |
| AI tests                   | Passed                                              | `uv run pytest -q` reports 45 passed.                                                                                                                                                                                                      |

## Review Method

This was a source-driven audit, not a speculative summary. I used the workspace instructions, the nested application agent index, architecture docs, repository inventories, pattern scans, and fast validation commands.

Primary evidence sources:

| Evidence                                                                    | Status                                                                                                                                                         |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Root `AGENTS.md` and `tfp-workspace/AGENTS.md`                              | Reviewed                                                                                                                                                       |
| `tfp-workspace/docs/agent-index.json`                                       | Reviewed first for domain routing                                                                                                                              |
| `tfp-workspace/docs/architecture/ARCHITECTURE_RULEBOOK.md`                  | Reviewed for intended dependency boundaries                                                                                                                    |
| Root `git status --short --branch`                                          | Reviewed                                                                                                                                                       |
| Nested remote sync check for repos with remotes                             | `git pull --rebase` was attempted in both nested repos and blocked by pre-existing/concurrent unstaged artifacts; ahead/behind checks returned `0 0` for both. |
| `git ls-files` inventories                                                  | Run across root, TFP workspace, and AI service                                                                                                                 |
| Route, module, package, style, script, seed, test, and artifact inventories | Run                                                                                                                                                            |
| Security and architecture pattern scans                                     | Run                                                                                                                                                            |
| Fast validation commands                                                    | Run                                                                                                                                                            |

Important limitation: this report inventories and audits every tracked file family and every major code path by source scan and targeted evidence. It does not paste all 8,000+ TFP tracked filenames into the report body because that would make the document less useful. The authoritative per-file inventory for this audit is the current `git ls-files` output of each repository.

## Repository Boundary Map

| Repository                                             | Role                                                          | Git/remote state observed                                                                                                                 |
| ------------------------------------------------------ | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `/Users/hexa/Desktop/tfp-latest`                       | Root wrapper, documentation, local artifacts, nested gitlinks | On `main`. No remote configured. Dirty because nested gitlinks and unrelated root files were already present.                             |
| `/Users/hexa/Desktop/tfp-latest/tfp-workspace`         | Main TFP Photographers app monorepo                           | `main...origin/main`, `0 ahead / 0 behind`. `git pull --rebase` is blocked by unrelated unstaged files.                                   |
| `/Users/hexa/Desktop/tfp-latest/ai-inference-platform` | Python AI inference service                                   | `main...origin/main`, `0 ahead / 0 behind`. `git pull --rebase` is blocked by one pre-existing modified generated/static policy artifact. |

Nested repo note: root status showed modified gitlinks for both nested projects plus untracked `.cline/` and `ingress-rules.json`. Those were not touched.

Dirty-state note: the nested dirty files were pre-existing or concurrent changes from outside this documentation audit. They were not reverted, staged, or modified.

## Full Inventory Summary

### Root Workspace

| Metric        |                                                                                     Value |
| ------------- | ----------------------------------------------------------------------------------------: |
| Tracked files |                                                                                        80 |
| Role          | Wrapper repository, nested project pointers, docs, local orchestration, historical audits |
| Main risk     |            Artifact sprawl and ambiguous ownership between root docs and nested repo docs |

### TFP Workspace

| Metric                                         |                                            Value |
| ---------------------------------------------- | -----------------------------------------------: |
| Tracked files before this documentation update |                                            8,023 |
| Text/source/document lines scanned             |                                          518,513 |
| Largest tracked file family                    |                      Test fixtures and QA assets |
| Main application routes                        |      67 tracked files under `apps/web/src/pages` |
| API modules                                    |   206 tracked files under `apps/api/src/modules` |
| Packages                                       |               206 tracked files under `packages` |
| Styles                                         |    103 tracked files under `apps/web/src/styles` |
| Components                                     | 57 tracked files under `apps/web/src/components` |
| Web scripts                                    |     8 tracked files under `apps/web/src/scripts` |
| E2E specs                                      |                       61 specs under `tests/e2e` |
| Seed assets                                    |           5,675 tracked files under `tests/seed` |

Top tracked directory concentrations:

| Directory  | Count | Audit meaning                                                    |
| ---------- | ----: | ---------------------------------------------------------------- |
| `tests`    | 5,893 | Very high QA/fixture investment; also repository weight risk     |
| `apps`     |   654 | Main FE and BE application code                                  |
| `docs`     |   374 | Large architecture, audit, QA, and product documentation base    |
| `packages` |   206 | Shared config, database, i18n, moderation, uploads, UI contracts |
| `scripts`  |    95 | QA, seed, moderation, and operational tooling                    |

High-volume extensions:

| Extension | Count | Notes                                                            |
| --------- | ----: | ---------------------------------------------------------------- |
| `.jpg`    | 5,801 | Mostly moderation/test seed images                               |
| `.html`   |   646 | Mockups, reports, QA artifacts, generated/static review surfaces |
| `.ts`     |   561 | API, packages, tests, scripts                                    |
| `.md`     |   268 | Docs, audit artifacts, QA/manual logs                            |
| `.json`   |   163 | Config, route indexes, reports, locale/QA metadata               |
| `.mmd`    |   132 | Architecture/flow diagrams                                       |
| `.astro`  |   111 | Web routes/components                                            |
| `.scss`   |   102 | Design system and page styles                                    |

### AI Inference Platform

| Metric                    |                                                                                       Value |
| ------------------------- | ------------------------------------------------------------------------------------------: |
| Tracked files             |                                                                                          61 |
| Text/source lines scanned |                                                                                      11,798 |
| Python source/test files  |                                                                      24 tracked `.py` files |
| Largest source file       |                                 `src/ai_inference_platform/service.py` at about 3,840 lines |
| Main source areas         |                      service orchestration, adapters, policy, web server, static playground |
| Main risk                 | Production playground/API exposure defaults and the still-large service/orchestration files |

## Validation Log

### TFP Workspace

| Command                                                 | Result                                    | Notes                                                                                                                                          |
| ------------------------------------------------------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `git pull --rebase` + ahead/behind check                | Blocked by dirty files; branch is current | Rebase sync was blocked by unrelated unstaged files in the nested repo; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`. |
| `bash ./scripts/pnpm-node20.sh lint:architecture`       | Passed                                    | Reported `Architecture boundary check passed.`                                                                                                 |
| `bash ./scripts/pnpm-node20.sh typecheck`               | Passed                                    | Astro check reported 0 errors/warnings/hints for 212 files; API TypeScript build completed.                                                    |
| `bash ./scripts/pnpm-node20.sh qa:design-tokens`        | Passed                                    | Reported `Design token audit passed across 285 source files.`                                                                                  |
| `bash ./scripts/pnpm-node20.sh seo:integrity`           | Passed with warnings                      | Health score `80/100`, 0 errors, 20 short-description warnings, report at `tmp/seo-integrity-report.json`.                                     |
| `bash ./scripts/pnpm-node20.sh audit --audit-level low` | Failed                                    | 18 vulnerabilities: 1 critical, 11 high, 5 moderate, 1 low.                                                                                    |
| `pnpm audit --json`                                     | Failed with advisory metadata             | Confirmed dependency and advisory counts.                                                                                                      |

### AI Inference Platform

| Command                                  | Result                                       | Notes                                                                                                                                                   |
| ---------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `git pull --rebase` + ahead/behind check | Blocked by dirty artifact; branch is current | Rebase sync was blocked by the pre-existing static policy artifact modification; `git rev-list --left-right --count HEAD...origin/main` returned `0 0`. |
| `uv run ruff check .`                    | Passed                                       | Reaudit snapshot reports all checks passed.                                                                                                             |
| `uv run pytest -q`                       | Passed                                       | Reaudit snapshot reports 45 passed.                                                                                                                     |

No browser/manual UI execution was run because the user requested documentation-only audit work, not UI changes or end-to-end remediation.

## Severity Model

| Severity | Meaning                                                                                          |
| -------- | ------------------------------------------------------------------------------------------------ |
| P0       | Blocks safe release or can expose security/auth/runtime-critical failure.                        |
| P1       | High production risk, broken validation, major architecture drift, or likely user-facing defect. |
| P2       | Medium risk, maintainability issue, performance risk, or weak operational discipline.            |
| P3       | Cleanup, documentation, or long-term quality improvement.                                        |

## Findings Overview

| ID    | Severity                     | Area                   | Finding                                                                                                                                                   |
| ----- | ---------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| F-001 | P0                           | TFP dependencies       | `pnpm audit` reports one critical advisory and multiple high advisories across auth, Astro, OpenTelemetry, protobuf, XML parsing, and transitive tooling. |
| F-002 | P0                           | AI production security | Production/deploy defaults can expose playground/API behavior when `AIP_INTERNAL_API_KEY` is missing and `AIP_EXPOSE_PLAYGROUND_UI=true`.                 |
| F-003 | Resolved in current snapshot | AI validation          | Previous lint and test collection failures are no longer present; keep these gates required before deployment.                                            |
| F-004 | P1                           | Backend architecture   | TFP architecture rulebook requires Prisma behind repositories, but direct Prisma access exists in commands, services, and middleware.                     |
| F-005 | P1                           | Admin UI security      | Admin/report JavaScript contains many HTML rendering sinks. Many are escaped, but the surface is too sensitive to leave decentralized.                    |
| F-006 | P2                           | Search semantics       | Search parameterization prevents SQL injection, but unescaped `%` and `_` wildcard behavior can broaden result sets.                                      |
| F-007 | P2                           | Repo operations        | Huge seed fixtures and ignored QA reports make local operation and review harder.                                                                         |
| F-008 | P2                           | AI observability       | `/metrics` is exposed without auth in the AI service.                                                                                                     |
| F-009 | P2                           | Configuration          | Production templates rely on strict runtime config checks; deployment safety depends on the runtime actually supplying all required secrets.              |
| F-010 | P2                           | UI maintainability     | Admin UI scripts and some page styles are large enough to make behavior and visual regressions harder to review.                                          |

## Detailed Findings

### F-001 - TFP Dependency Audit Has Critical and High Advisories

Severity: P0  
Area: TFP dependency/security posture  
Evidence:

- `bash ./scripts/pnpm-node20.sh audit --audit-level low` failed.
- Audit summary: 18 vulnerabilities, including 1 critical, 11 high, 5 moderate, and 1 low.
- Dependency graph size from audit metadata: 1,264 dependencies.

Important advisories observed:

| Package/advisory area                   | Severity      | Path/risk                                                                                                                                     |
| --------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `fast-jwt <=6.2.3`                      | Critical      | Auth bypass through `apps__api > @fastify/jwt > fast-jwt`; patched in `>=6.2.4`.                                                              |
| `fast-uri`                              | High          | Path traversal and host confusion via Astro check tooling dependency chain.                                                                   |
| OpenTelemetry Prometheus exporter stack | High          | Malformed HTTP request crash in `@opentelemetry/auto-instrumentations-node`, `@opentelemetry/sdk-node`, `@opentelemetry/exporter-prometheus`. |
| `protobufjs <=7.5.5`                    | High/Moderate | Transitive through `@google-cloud/vision > google-gax`.                                                                                       |
| `fast-xml-builder`                      | High/Moderate | Transitive through `@aws-sdk/client-rekognition`.                                                                                             |
| `devalue >=5.6.3 <=5.8.0`               | High          | Transitive through `apps__web > astro`.                                                                                                       |
| `astro <6.1.10`                         | Low           | Server island encrypted params advisory.                                                                                                      |

Impact:

- Auth stack advisories should be treated as release blocking.
- Instrumentation and parsing advisories matter because this app handles user-generated content, uploads, admin workflows, and external provider responses.
- Even if some advisories are dev-only or low exploitability in this deployment, the current audit status fails the workspace's own validation bar.

Recommendation:

1. Upgrade the direct dependencies that pull vulnerable trees.
2. Regenerate the lockfile.
3. Re-run `pnpm audit --audit-level low`.
4. Add an explicit dependency-audit note to release readiness docs so this does not silently regress.

### F-002 - AI Production Playground/API Exposure Defaults Are Too Loose

Severity: P0  
Area: AI service production security  
Evidence:

- `config/environments/prod/settings.yaml` sets:
  - `host: 0.0.0.0`
  - `port: 7001`
  - `feature_flags.expose_playground_ui: true`
- `scripts/deploy-via-oci-cli.sh` defaults:
  - `AIP_REQUIRE_INTERNAL_API_KEY=auto`
  - `AIP_EXPOSE_PLAYGROUND_UI=true`
- The deploy script sets `AIP_REQUIRE_INTERNAL_API_KEY=false` if `AIP_INTERNAL_API_KEY` is absent.
- `src/ai_inference_platform/web.py` protects core API and cache-clear API endpoints with `_require_api_key`, but playground routes such as `/playground/image`, `/playground/text`, `/playground/translate`, and `/playground/cache/image-responses/clear` are not protected by that same check.

Impact:

- A production deploy without `AIP_INTERNAL_API_KEY` can unintentionally expose expensive inference capabilities and cache mutation behavior.
- Public playground endpoints can create cost, privacy, abuse, and availability risk.
- The current defaults favor manual testing over production hardening.

Recommendation:

1. Production should default to `AIP_EXPOSE_PLAYGROUND_UI=false`.
2. Production should fail closed if `AIP_INTERNAL_API_KEY` is missing.
3. Playground POST endpoints should require the same internal API key when exposed outside localhost.
4. Keep an explicit local/dev override for manual testing.

### F-003 - AI Service Validation Is Clean In The Current Snapshot

Severity: Resolved in current snapshot / keep as release gate
Area: AI service correctness/CI readiness  
Evidence:

- `uv run ruff check .` now passes.
- `uv run pytest -q` now passes with 45 tests.
- The AI repo still has a pre-existing modified generated/static policy artifact: `src/ai_inference_platform/static/policy/tfp-moderation-policy.json`.

Impact:

- The prior CI-readiness blocker is resolved in this snapshot.
- The validation gate should stay mandatory because this service has large model-adapter and response-contract surfaces.
- The remaining deployment risk is not local lint/test health; it is production playground/API exposure behavior.

Recommendation:

1. Keep `uv run ruff check .` and `uv run pytest -q` as required release gates.
2. Resolve the generated/static policy artifact ownership before deployment.
3. Validate live inference payloads after deployment, especially `models_used`, private-part axes, and cache behavior.

### F-004 - Prisma Boundary Drift Conflicts With Architecture Rulebook

Severity: P1  
Area: TFP backend architecture  
Evidence:

- `tfp-workspace/docs/architecture/ARCHITECTURE_RULEBOOK.md` defines the intended flow: route -> handler -> application service / command / query -> repository -> Prisma.
- The rulebook forbids Prisma access from routes, handlers, commands, generic services, web code, and scripts except explicitly allowed database/tooling boundaries.
- `lint:architecture` passed, but source scans still found broad direct Prisma usage:
  - 102 files in `apps/api/src`, `apps/web/src`, and `packages` reference `@prisma/client` or `prisma`.
  - 65 files under `apps/api/src/modules` contain direct Prisma references.

Concrete examples:

| File                                             | Evidence                                                            |
| ------------------------------------------------ | ------------------------------------------------------------------- |
| `apps/api/src/modules/report/report.commands.ts` | Imports and uses global `prisma` inside command logic.              |
| `apps/api/src/modules/auth/auth.middleware.ts`   | Imports global `prisma`; middleware calls `prisma.user.findUnique`. |
| `apps/api/src/modules/search/search.service.ts`  | Uses Prisma/raw SQL behavior directly in service code.              |

Impact:

- The documented architecture is stronger than actual enforcement.
- Commands and services become harder to test without DB coupling.
- Future migrations or repository contract changes will be more expensive.

Recommendation:

1. Decide whether the rulebook is strict law or aspirational guidance.
2. If strict, expand architecture lint to catch command/service/middleware Prisma imports.
3. Move repeated direct DB logic into repositories or query services with explicit interfaces.
4. Prioritize auth, reports, moderation, search, and admin modules because they are high-sensitivity areas.

### F-005 - Admin/Report UI Has Too Many Decentralized HTML Rendering Sinks

Severity: P1  
Area: TFP frontend/admin security and maintainability  
Evidence:

- Pattern scan found 50 occurrences of `innerHTML`, `insertAdjacentHTML`, `set:html`, or `dangerouslySetInnerHTML`.
- `apps/web/src/scripts/admin/index.js` renders AI review entries with `innerHTML`; many values are escaped through `escapeHtml`.
- `apps/web/src/scripts/admin/runtime-reports.js` has multiple `innerHTML` writes.
- `apps/web/src/components/SiteHead.astro` uses `set:html` for inline CSS, telemetry config JSON, and structured data JSON.

Impact:

- The app has escaping discipline in several places, but the admin/report surface mixes many dynamic fields and review payloads.
- Admin pages often render high-risk data: reports, moderation model output, user content, image metadata, and operational state.
- Decentralized escaping creates future regression risk.

Recommendation:

1. Centralize admin HTML rendering helpers and escaping policy.
2. Add targeted tests for report/moderation payloads containing HTML-like values.
3. Treat every future `innerHTML` addition as security-reviewed unless it renders static markup only.
4. Keep `set:html` for structured data only when JSON serialization is explicit and tested.

### F-006 - Search Wildcards Are Parameterized but Not Escaped

Severity: P2  
Area: Search correctness/performance  
Evidence:

- `apps/api/src/modules/search/search.service.ts` builds `likeQuery = "%${query}%"`.
- The service passes user search text into Prisma `contains` and raw `ILIKE` comparisons.
- The query is parameterized, so this is not SQL injection evidence.

Impact:

- Users can submit `%` or `_` and produce broad wildcard matches.
- Broad result sets can distort relevance, make abuse easier, and increase query cost.

Recommendation:

1. Escape SQL wildcard characters when using `ILIKE`.
2. Normalize search terms consistently between Prisma `contains` and raw SQL branches.
3. Add tests for literal `%`, `_`, and backslash queries.

### F-007 - Repo Fixture and Artifact Weight Is Operationally Expensive

Severity: P2  
Area: Repo hygiene and developer experience  
Evidence:

- TFP workspace local tree size was about 26G.
- `tests` alone was about 350M.
- `scripts/qa` local tree was about 5.4G, dominated by ignored report artifacts.
- `tests/seed` contains 5,675 tracked files, mostly image fixtures.
- Multiple historical UI mockup directories are tracked.

Impact:

- Clone, backup, indexing, grep, and IDE operations become slower.
- Local ignored artifacts can hide real source diffs and make audits noisy.
- Large fixture sets are useful, but they need lifecycle rules.

Recommendation:

1. Keep essential fixture samples tracked.
2. Move large generated reports and historical screenshots to ignored artifact storage.
3. Add a documented artifact cleanup command.
4. Consider a fixture manifest with externally stored large media if the seed corpus keeps growing.

### F-008 - AI `/metrics` Endpoint Is Public

Severity: P2  
Area: AI observability/security  
Evidence:

- `src/ai_inference_platform/web.py` exposes `/metrics` without the API key check used by protected API endpoints.

Impact:

- Metrics can reveal service health, runtime behavior, request volume, model timing, and cache behavior.
- Public metrics are often acceptable only behind an internal network, reverse proxy, or scrape allowlist.

Recommendation:

1. Protect `/metrics` by default in production.
2. Allow unauthenticated metrics only for localhost or explicitly configured internal networks.
3. Document the expected scrape path in deploy docs.

### F-009 - Production Config Depends on Runtime Secret Discipline

Severity: P2  
Area: Configuration and deploy safety  
Evidence:

- TFP tracked env templates do not include real secrets, which is correct.
- `packages/config/src/config-sections.ts` contains strict runtime config assertions for database, JWT, cookies, OAuth, storage, moderation, rate limit, Sentry/Axiom, and production CORS.
- AI deploy defaults can become permissive without a supplied internal key.

Impact:

- TFP config is safer because it validates many production requirements.
- AI config needs the same fail-closed posture for public deployments.

Recommendation:

1. Keep TFP strict production config as the standard.
2. Mirror that standard in AI deploy/runtime configuration.
3. Add release checklist rows for secret presence and fail-closed auth mode.

### F-010 - Admin UI and Style Surfaces Are Large

Severity: P2  
Area: UI maintainability/performance  
Evidence:

- `apps/web/src/scripts/admin/index.js` is about 2,857 lines.
- `apps/web/src/styles/pages/admin-unified/_overlays-responsive.scss` is about 3,775 lines.
- Several historical mockup directories are still tracked.

Impact:

- Large scripts and stylesheets make focused review harder.
- Admin behavior is business-critical: moderation, reports, approvals, queue state, and manual reruns.
- Responsive regressions are more likely when overlays are concentrated in one large stylesheet.

Recommendation:

1. Split admin runtime concerns by queue/report/moderation/overlay behavior.
2. Keep the existing public UI stable, but isolate future admin refactors behind browser coverage.
3. Reduce style file blast radius by moving repeated overlay patterns into tokens/mixins/components.

## UI and Frontend Audit

### Route Coverage

The web app has a broad Astro route surface under `apps/web/src/pages`, covering:

- Public routes: home, contests, events, opportunities, profiles, search, legal/contact pages, RSS/sitemap, health, 404.
- Auth routes: login, register, forgot/reset password, OAuth callbacks, auth debug/diagnostics.
- User workflows: messages, notifications, profile creation/editing, uploads, contest/event/opportunity create/edit flows.
- Admin workflows: unified admin entry, moderation, queue state, reports, approvals, and operational views.
- API proxy routes in the web app: upload, moderation, translation, search, reports, signed media, metrics/health proxies, and admin helper endpoints.

Strengths:

- Route families are recognizable and domain-oriented.
- Web middleware includes auth, locale, and request security behavior rather than leaving all checks to page code.
- There is a meaningful split between Astro pages, components, scripts, and SCSS.
- Site metadata and structured data are centralized in `SiteHead.astro`.
- Tests and manual QA docs exist for responsive and workflow coverage.

Risks:

- Admin pages carry high operational impact and should have the strictest rendering and browser regression coverage.
- Multiple UI mockup directories and historical HTML artifacts make it harder to distinguish source of truth from exploratory work.
- Some admin scripts and styles are large enough that future fixes may accidentally change unrelated behavior.

Recommended UI priorities:

1. Harden admin/report rendering sinks first.
2. Keep public/auth route visual consistency checks in the existing QA tooling.
3. Convert repeated admin interaction patterns into small modules before adding more moderation controls.
4. Mark historical mockups as archive/reference in docs so future agents do not treat them as active product code.

## Backend/API Audit

### Module Coverage

The API module tree has 205 tracked files under `apps/api/src/modules`, with the heaviest areas:

| Module        | Count | Audit note                                                                                         |
| ------------- | ----: | -------------------------------------------------------------------------------------------------- |
| `moderation`  |    57 | Central product risk area; queue state, reports, manual rerun, provider contracts, policy mapping. |
| `admin`       |    24 | Operational controls and approval/report surfaces.                                                 |
| `contest`     |    22 | Public participation, submission/voting workflows, ownership restrictions.                         |
| `translation` |    17 | Locale and content translation support.                                                            |
| `auth`        |    17 | Login/session/OAuth/security behavior.                                                             |
| `opportunity` |    11 | Marketplace/workflow domain.                                                                       |
| `event`       |    10 | Event listing, RSVP, submission workflow.                                                          |
| `user`        |     9 | Profile/account behavior.                                                                          |
| `report`      |     7 | Content reporting and moderation handoff.                                                          |
| `upload`      |     5 | Upload validation and storage integration.                                                         |

Strengths:

- Domain modules are visible and mostly aligned with product workflows.
- Request security has a real fail-closed CSRF model for cookie-authenticated state-changing requests.
- Upload validation is layered across web proxy, API module, and shared upload utilities.
- Moderation is treated as a domain, not a one-off helper.
- The database package has repositories for key domains.

Risks:

- Prisma access is still too widespread for the stated architecture.
- Search mixes raw SQL and Prisma filtering in service code.
- Admin/moderation/report domains are coupled to multiple UI and backend state concepts, increasing regression risk.

Recommended backend priorities:

1. Treat the architecture rulebook as executable policy and close lint gaps.
2. Create repository/query abstractions for remaining direct Prisma command/service use.
3. Expand contract tests around moderation queue state, report-triggered rechecks, upload status, and owner/public visibility.

## Database and Schema Audit

Tracked database code lives under `packages/database`, including:

- `packages/database/prisma/schema.prisma`
- 22 tracked migration directories/files plus `migration_lock.toml`
- `packages/database/prisma/seed.ts`
- Repository classes for users, contests, contest submissions, events, messages, moderation cases, OAuth accounts, opportunities, password reset tokens, portfolio images, reports, and user violations.
- Adapters for cache, job queue, outbox, and rate limiting.

Schema breadth:

- 37 Prisma models were observed, including user, portfolio, legacy slug, contest, opportunity, event, reports, moderation, upload intent, OAuth, translation cache, password reset, login lockout, idempotency, outbox, image moderation, audit logs, appeals, and user violations.
- 30+ enums were observed for roles, subscription tiers, workflow statuses, report state, moderation state, provider/strategy/source types, upload state, translation state, violation/account/appeal state, and auto-fix state.

Strengths:

- The schema is broad enough for real operational workflows.
- Migrations show performance/index work for admin reports, notifications, and search.
- Dedicated repositories exist for many core models.
- Outbox/idempotency models indicate attention to reliable async behavior.

Risks:

- The schema/repository layer is not the only database access path.
- Direct DB access from commands/middleware can bypass repository invariants.
- Large moderation state models require careful queue-state tests and migration discipline.

Recommendation:

1. Keep Prisma schema as the source of truth.
2. Move direct DB use behind repositories/query services.
3. Add migration review checklist rows for queue-state, visibility, and owner/public behavior.

## Moderation and AI Audit

### TFP Moderation Surface

TFP has a large moderation domain with backend modules, admin UI, reports, manual QA tools, policy documents, and seed image fixtures. This is a strength, but it also creates a high coordination burden.

Strengths:

- Moderation is not hidden in upload code; it has a real domain.
- Queue state, reports, audit logs, appeals, policy versions, and image moderation are represented in the database.
- QA tooling and seed fixtures exist for policy validation.
- Admin manual rerun and report workflows have dedicated surfaces.

Risks:

- Any divergence between TFP policy parsing and AI service response shape can create silent review mismatch.
- Report-triggered moderation must target the exact reported asset, not nearby user media.
- Admin-approved/pending/rejected queue state needs deterministic sorting and state classification.

Recommended moderation priorities:

1. Keep one shared policy/evaluator path for TFP admin/report surfaces.
2. Add tests for owner-visible rejected media and public-hidden rejected media.
3. Keep raw model scores separate from normalized/derived moderation decisions.
4. Test report-triggered recheck by `targetImageKey`.

### AI Inference Surface

AI service source is compact but dense:

- `src/ai_inference_platform/service.py` orchestrates analysis, response building, model selection, caching, and policy response fields.
- `src/ai_inference_platform/adapters.py` contains adapter logic, including strong remote-image safety controls.
- `src/ai_inference_platform/web.py` exposes health, metrics, API, playground, and cache routes.
- Static playground files provide manual testing UI.
- Tests cover unit, integration, and contract behavior, and the current re-audit snapshot passes the local suite.

Strengths:

- Remote image fetch protection is strong: remote fetch disabled by default, no redirects, no credentials, no localhost, global DNS resolution checks, and max byte limits.
- Response caching includes image hash, selected adapters, labels, versioning, and private-part axes context.
- Cache clear endpoints exist for operational control.

Risks:

- Playground exposure and missing internal key behavior are too permissive for production.
- The service remains dense enough that lint/test gates should stay mandatory before deployment.
- `/metrics` is unauthenticated.

Recommended AI priorities:

1. Keep lint and tests as mandatory release gates.
2. Make production fail closed on API key and playground exposure.
3. Validate live OCI payloads after each deploy.
4. Preserve raw model scores and expose normalized policy outcomes as separate derived fields.

## Security Review

### Strong Areas

| Area                  | Evidence                                                                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| TFP CSRF              | API server and web middleware enforce origin/referer/sec-fetch checks for cookie-authenticated state-changing requests.                     |
| TFP production config | Strict runtime config assertions exist for production secrets, CORS, OAuth, storage, rate limit, observability, and moderation credentials. |
| Upload validation     | Upload validation includes extension/mimetype checks and shared upload utilities for deeper inspection.                                     |
| AI remote image fetch | Adapter code blocks unsafe remote fetch behavior by default and validates DNS/address safety.                                               |

### High-Risk Areas

| Area                        | Risk                                                              |
| --------------------------- | ----------------------------------------------------------------- |
| TFP dependency tree         | Active critical/high advisories in auth and supporting libraries. |
| AI production auth defaults | Missing internal key can lead to permissive behavior.             |
| Admin HTML sinks            | Escaping exists but rendering policy is decentralized.            |
| Public metrics              | AI metrics endpoint is not protected.                             |

Security recommendation: prioritize dependency remediation and AI fail-closed defaults before UI polish or non-critical refactors.

## Testing and QA Audit

### TFP Test Surface

TFP has unusually broad QA infrastructure:

- Domain-first Playwright E2E layout under `tests/e2e`.
- 61 E2E specs across admin, auth, localization, moderation, SEO, uploads, public flows, opportunities, contests, and event workflows.
- Manual QA docs under `tests/manual`.
- Seed README and seed assets under `tests/seed`.
- QA scripts under `scripts/qa`, including moderation folder tooling, layout checks, browser capture, design-token checks, and audit/report generation.

Strengths:

- The repo has real browser-flow coverage, not just unit tests.
- There is documented manual QA practice.
- Seed data and fixtures make many flows reproducible.

Risks:

- The test fixture corpus is large and may slow day-to-day operation.
- Ignored local QA reports are huge and can obscure audit work.
- If architecture lint misses direct Prisma use, passing tests may still leave architectural drift.

Recommendation:

1. Keep domain-first test structure.
2. Add tests specifically for security-sensitive rendering and search wildcard behavior.
3. Keep `tests/README.md` and `tests/seed/README.md` updated when scripts or seed behavior change.
4. Add a cleanup/retention policy for large generated QA reports.

### AI Test Surface

AI has unit, integration, and contract tests, but current execution stops at collection.

Recommendation:

1. Fix adapter export/name mismatch.
2. Run the full test suite.
3. Add contract tests for every response field consumed by TFP moderation/report/admin surfaces.

## Performance and Operations Review

### TFP

Strengths:

- Search has dedicated migrations for trigram indexes.
- Notification/admin report performance indexes exist.
- Domain-specific scripts and QA tooling support operational testing.

Risks:

- Large local artifact directories can slow scans and tooling.
- Admin JS/CSS concentration increases performance and regression risk.
- Dependency vulnerabilities in telemetry/exporter stacks can affect runtime stability.

### AI

Strengths:

- Response caching is explicit and versioned.
- Cache clear routes exist for operational reset.
- Health endpoints and metrics exist.

Risks:

- Metrics exposure needs production access control.
- Playground exposure can create unnecessary inference load.
- Current failing tests make performance changes unsafe to trust.

## File-Family Coverage Ledger

This section maps every tracked file family into the audit so future work can target the right source of truth.

| Family                                  | Covered by                                     | Primary risk                                                     |
| --------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------------- |
| Root docs/audit files                   | Root inventory and audit-artifact review       | Historical docs may conflict or confuse current source of truth. |
| Root nested gitlinks                    | Git boundary review                            | Root can look dirty due nested repo pointer changes.             |
| `tfp-workspace/apps/web/src/pages`      | Route inventory and FE review                  | Route-specific auth/locale/proxy behavior must stay consistent.  |
| `tfp-workspace/apps/web/src/components` | Component/style/rendering scans                | Rendering sinks and structured data must remain safe.            |
| `tfp-workspace/apps/web/src/scripts`    | Admin/report script scan                       | High-sensitivity HTML rendering and large admin runtime files.   |
| `tfp-workspace/apps/web/src/styles`     | Style inventory and large-file scan            | Overlay/responsive concentration and visual regression risk.     |
| `tfp-workspace/apps/api/src/modules`    | Module inventory, Prisma scan, security review | Direct DB access and high-risk auth/report/moderation flows.     |
| `tfp-workspace/packages/database`       | Schema/repository/migration review             | Repository boundary bypass and migration complexity.             |
| `tfp-workspace/packages/config`         | Production config review                       | Runtime secret enforcement and deployment safety.                |
| `tfp-workspace/packages/shared`         | Shared request/security/locale review          | Shared contracts must remain source of truth.                    |
| `tfp-workspace/packages/uploads`        | Upload/security review                         | User-generated content safety.                                   |
| `tfp-workspace/tests/e2e`               | Test inventory                                 | Browser flow breadth is strong; keep scripts discoverable.       |
| `tfp-workspace/tests/seed`              | Fixture inventory                              | Large tracked image corpus needs lifecycle discipline.           |
| `tfp-workspace/scripts/qa`              | QA/artifact scan                               | Ignored generated reports are very large.                        |
| `tfp-workspace/docs`                    | Docs inventory and architecture source review  | Multiple old audit docs can conflict with current rulebook.      |
| `ai-inference-platform/src`             | Source scan, security review, validation       | Auth defaults, adapter contract, cache, metrics, playground.     |
| `ai-inference-platform/tests`           | Test validation                                | Current local suite passes; keep it as a deployment gate.        |
| `ai-inference-platform/config`          | Production config review                       | Playground enabled in prod config.                               |
| `ai-inference-platform/scripts`         | Deploy script review                           | API key auto-mode can fail open.                                 |

## Recommended Remediation Roadmap

### Phase 1 - Release Blockers

1. Fix TFP dependency audit, especially `fast-jwt`.
2. Make AI production auth/playground behavior fail closed.
3. Make AI lint/test gates mandatory in deployment handoff.
4. Confirm no unexpected dirty AI changes remain before deployment.

### Phase 2 - Architecture and Security Hardening

1. Extend architecture lint to enforce the documented Prisma boundary.
2. Move direct Prisma command/service/middleware usage into repositories or query services.
3. Centralize admin/report HTML rendering and add unsafe-payload tests.
4. Protect or network-restrict AI `/metrics`.

### Phase 3 - Product Workflow Confidence

1. Add report-triggered moderation tests for exact asset targeting.
2. Add owner/public rejected-media visibility tests.
3. Add search wildcard tests.
4. Add contract tests between AI response payloads and TFP moderation consumers.

### Phase 4 - Repository Hygiene

1. Document active versus archived UI mockup directories.
2. Add cleanup rules for ignored QA artifacts.
3. Reassess tracked fixture size and externalize anything not needed for deterministic test runs.
4. Keep audit docs consolidated so future agents do not follow stale guidance.

## Final Readiness Checklist

| Gate                          | Current result       |
| ----------------------------- | -------------------- |
| TFP architecture lint         | Pass                 |
| TFP typecheck                 | Pass                 |
| TFP dependency audit          | Fail                 |
| AI lint                       | Pass                 |
| AI tests                      | Pass                 |
| AI production auth defaults   | Needs hardening      |
| Admin rendering sinks         | Needs hardening      |
| Prisma boundary               | Needs enforcement    |
| Large artifact/fixture policy | Needs cleanup policy |

## Bottom Line

The TFP product codebase has substantial structure, meaningful tests, real architecture documentation, and a serious moderation/QA investment. The main problem is not lack of organization; it is that the documented standards are stronger than some current enforcement, and the workspace has grown enough that release discipline now depends on automated gates being stricter.

The AI inference platform is smaller and currently validation-clean, but it is still operationally sensitive because production exposure defaults are too permissive. Hardening those defaults should come before any public deployment or deeper product integration.

The highest-value next move is a focused release-hardening pass: dependency upgrades, AI fail-closed config, Prisma-boundary enforcement, and admin rendering tests.
