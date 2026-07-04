# Go-Live Enterprise Audit - 2026-07-04

Scope: `/Users/hexa/Desktop/tfp-main-orchestator`, including `tfpphotographers`, `tfp-image-moderation-service`, and `tfp-collage-service`.

Secrets committed in git were intentionally ignored per request. Runtime secret readiness was still checked through the production env doctor because those values are launch gates.

## Executive Status

Current status: not ready for production traffic until the launch blockers below are closed.

The application has strong baseline controls in the main app and sibling services: authenticated API boundaries, admin-only routes, cookie flags, CSRF origin checks, CSP/security headers, upload validation, SSRF defenses for collage image fetching, production config assertions, masked 5xx errors, structured logging hooks, and documented worker/deployment gates.

Two issues were fixed during this audit:

- `tfpphotographers/apps/web/src/utils/referral-share.ts` now imports referral helpers through the `shared` package entrypoint instead of a deep package-internal path.
- `tfpphotographers/package.json` moved dependency override pins from ignored `pnpm.overrides` to top-level `overrides`, removing the pnpm 10 warning and restoring supply-chain override enforcement.

## Launch Blockers

### 1. Production env doctor currently fails

Evidence:

- Command: `bash ./scripts/pnpm-node20.sh qa:env:doctor:prod`
- Result: failed.
- Current production env resolution loads `.env.production`, `apps/api/.env`, and `.env.production.local`.
- It resolves all production DB URLs to localhost:
  - `DATABASE_URL=postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers_prod`
  - `DATABASE_DIRECT_URL=postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers_prod`
  - `SHADOW_DATABASE_URL=postgresql://tfp_user:tfp_user@localhost:5432/tfp_photographers_prod_shadow`
- It also reports missing or invalid launch infrastructure:
  - `SENTRY_DSN`
  - `PUBLIC_SENTRY_DSN`
  - `AXIOM_TOKEN`
  - `RATE_LIMIT_REDIS_URL`

Risk:

- Production can accidentally run against a developer-local DB target.
- API rate limiting will not use a shared production store.
- Browser/server error monitoring and log shipping are not launch-ready.

Required before go-live:

- Point production DB variables at the deployed database target.
- Provision `RATE_LIMIT_REDIS_URL`.
- Configure real Sentry server/browser DSNs and Axiom token.
- Re-run `qa:env:doctor:prod` until it passes.

### 2. Moderation service operator UI must stay non-public unless hardened

Evidence:

- `tfp-image-moderation-service/src/tfp_image_moderation_service/web.py` globally registers CORS with `allow_origins=["*"]` and `allow_credentials=False`.
- OpenAPI/docs and the playground UI are config-gated with `feature_flags.expose_openapi` and `feature_flags.expose_playground_ui`.
- When `expose_playground_ui` is enabled, `/folder-ops/*` POST routes are protected by `FOLDER_OPS_PASSWORD` but do not implement CSRF tokens or origin checks.
- Folder moderation reports are mounted from `folder_ops_paths.reports_dir` under `/folder-moderation`.

Risk:

- Safe if this service remains an internal authenticated API and playground/folder-ops stay disabled in production.
- Unsafe if exposed publicly with `expose_playground_ui=true`, because password-only form POSTs plus wildcard CORS create unnecessary operator surface.

Required before go-live:

- Keep `expose_playground_ui=false` and `expose_openapi=false` in production.
- If folder-ops must be public, add CSRF/origin checks, edge allowlisting/VPN, rate limiting, and restricted static report exposure first.

## Resolved During Follow-Up

### Collage service test/runtime path now uses Node 24 harness

Previous evidence:

- `tfp-collage-service/package.json` required `node >=24`, but `pnpm test` previously failed on this host with `node: bad option: --test` because `/usr/local/bin/node` was v16.13.1.
- The suite passed only when manually run with a Node 24 binary.

Resolution:

- Added `tfp-collage-service/scripts/ensure-node-runtime.sh`, `scripts/run-node.sh`, and `scripts/pnpm-node.sh`.
- Updated collage service `dev`, `build`, `start`, `test`, `validate`, local start, README commands, VPS deploy build/prune, and systemd `ExecStart` to route through those wrappers.
- Verified direct `pnpm test` and `bash ./scripts/pnpm-node.sh validate` now pass from the normal shell.

## Security Review Summary

### Auth, Sessions, CSRF

Main app controls are present:

- Auth token middleware validates JWTs, active user state, account status, and session version.
- Route handlers use `requireAuth` and `requireAdmin`.
- Auth cookies are `HttpOnly`, `SameSite=Lax`, and `Secure` in production.
- API and web middleware block cookie-authenticated state-changing requests from untrusted origins.
- Login lockout tests and CSRF middleware/integration tests pass.

Residual requirement:

- Keep API CSRF integration tests in CI with a migrated TEST DB.

### XSS and Browser Data Leakage

Main app controls are present:

- Astro escapes template values by default.
- Admin runtime code uses `escapeHtml` for dynamic `innerHTML` content reviewed in the audit.
- Production CSP uses nonces/hashes for scripts and no longer allows production `unsafe-eval`.
- Error telemetry scrubs query values and records query keys only.

Residual requirement:

- Continue treating any new `set:html` or `innerHTML` as security-reviewed code.

### Uploads and File Serving

Main app controls are present:

- Upload intents are ownership-scoped.
- File size, MIME, checksum, and magic-byte checks exist.
- Local storage keys are normalized and traversal-protected.
- Production should use object storage rather than local filesystem storage.

Residual requirement:

- Production env doctor must remain the gate against local production storage.

### SSRF and Outbound Fetch

Main app and services show good controls:

- Collage service rejects credentials in URLs, localhost/private/link-local IPs, non-http protocols, redirects, non-image responses, and oversize responses.
- Production-like collage config disables data and file URLs by default.
- Image moderation remote/provider URLs are env-driven and internal API-key protected.

Residual requirement:

- Keep collage URL-fetch tests in CI and avoid adding generic URL preview/import endpoints without allowlists.

### Errors, Logs, Observability

Main app controls are present:

- API masks production 5xx messages and exposes client 4xx messages.
- Sentry capture is wired for 5xx and startup failures.
- Structured log fields sanitize request paths/query values.
- Production runbook requires worker health, API readiness, and diagnostics.

Residual requirement:

- Launch is blocked until Sentry/Axiom production settings pass the env doctor.

### Dependency and Supply Chain

Current state:

- `pnpm audit --prod --audit-level high` reports no known high vulnerabilities.
- The ignored pnpm override warning was fixed by moving overrides to top-level `overrides`.
- Python moderation dependency ranges include patched modern FastAPI/Starlette-related packages through FastAPI/uvicorn pins.

Residual requirement:

- Keep `pnpm audit` and Python dependency review in CI/release checklist.

## Validation Run

Passed:

- `bash ./scripts/pnpm-node20.sh lint:architecture`
- `bash ./scripts/pnpm-node20.sh env:test`
- `pnpm audit --prod --audit-level high`
- `bash ./scripts/pnpm-node20.sh --filter web typecheck`
- `bash ./scripts/pnpm-node20.sh --filter web exec vitest run tests/middleware/web-csrf-middleware.test.ts tests/utils/redirect.test.ts tests/utils/web-csrf.test.ts`
- `bash ./scripts/with-target-env-shell.sh test --destructive 'bash ./scripts/db/ensure-env-database.sh test && bash ./scripts/db/migrate.sh reset' && ACTIVE_MODERATION_PROVIDER=noop bash ./scripts/with-test-env.sh bash ./scripts/pnpm-node20.sh --filter api exec vitest run tests/utils/csrf.integration.test.ts tests/modules/upload/direct-upload.test.ts tests/modules/auth/login-lockout.test.ts`
- `./.venv/bin/python -m pytest tests/contract/test_settings.py tests/integration/test_web.py -q`
- `NODE_ENV=test /Users/hexa/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node --test dist/tests/*.test.js`

Failed / intentionally blocking:

- `bash ./scripts/pnpm-node20.sh qa:env:doctor:prod` failed for localhost production DB URLs, missing Redis rate-limit store, and missing observability settings.

Not run in this pass:

- Full Playwright domain/a11y/smoke/release UI coverage.
- Full `pnpm build` after the audit cleanup.
- Live UAT/VPS manual browser sweep.
- External penetration test or DAST scan.

## Go-Live Checklist

Before production launch:

1. Make `qa:env:doctor:prod` pass.
2. Ensure production runs `web`, `api`, `worker`, and migration job; do not deploy web/API without worker.
3. Lock production moderation service to internal access with `expose_playground_ui=false` and `expose_openapi=false`.
4. Run full release gates from `docs/operations/DEPLOYMENT_RUNBOOK.md`.
5. Restart FE/BE/worker with production-like env and run browser smoke, a11y, and release UI coverage.
6. Verify public headers, CSP, cookies, HTTPS/HSTS, API CORS, uploads, moderation, reports, auth, admin workflows, and worker queues from the deployed origin.
