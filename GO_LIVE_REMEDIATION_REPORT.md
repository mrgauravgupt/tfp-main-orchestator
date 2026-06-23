# Go-Live Remediation Report

Generated: 2026-06-23

## Scope

Closed-loop review, fix, and validation pass across the orchestrator and its three active services:

- `tfpphotographers`
- `tfp-collage-service`
- `tfp-image-moderation-service`

The pass focused on production safety, deployment/runtime SSOT drift, stale workspace paths, obvious code clutter, smoke readiness, and validation gates.

## Findings Fixed

### Main app: production environment safety

- Added a strict production env-doctor check that rejects localhost database URLs for `DATABASE_URL`, `DATABASE_DIRECT_URL`, and `SHADOW_DATABASE_URL` unless `TFP_ALLOW_LOCAL_PROD_PREVIEW=1` is explicitly set.
- Expanded `env:test` to run all environment tests under `scripts/env/*.test.mjs`.
- Added regression coverage for production localhost database blocking.
- Updated the smoke test homepage assertion to match the current launch homepage H1.

### Collage service: clutter and SSOT cleanup

- Removed stale root-level manual TypeScript harnesses that were outside the supported test/build flow.
- Removed an obsolete `tfp-workspace` storage fallback so runtime discovery points at the current `tfpphotographers` workspace.
- Updated the validation script to avoid nested `pnpm` resolution failures when invoked through the repo Node/Corepack wrapper.
- Updated local repo agent/memory notes from old `tfp-latest`/OCI assumptions to the current orchestrator/VPS paths.

### Image moderation service: production hardening and path cleanup

- Disabled the public playground UI by default in `uat` and `prod`.
- Stopped the VPS prod deploy wrapper from forcing `AIP_EXPOSE_PLAYGROUND_UI=true`.
- Made folder-ops report/image/workspace paths resolve from settings and env instead of hardcoded `/srv/tfp-folder-moderation` at app creation time.
- Updated folder moderation and policy snapshot defaults from stale `tfp-workspace` paths to `tfpphotographers`.
- Added contract tests for the deploy wrapper, UAT settings, and current app workspace path.
- Updated README and local repo agent/memory notes to current orchestrator/VPS paths.

## Validation Completed

### `tfpphotographers`

- `bash ./scripts/pnpm-node20.sh env:test` - passed
- `bash ./scripts/pnpm-node20.sh lint:architecture` - passed
- `bash ./scripts/pnpm-node20.sh typecheck` - passed
- `bash ./scripts/pnpm-node20.sh lint:eslint` - passed
- `bash ./scripts/pnpm-node20.sh build` - passed
- `bash ./scripts/pnpm-node20.sh test:vitest` - passed
- `bash ./scripts/stop-app.sh --quiet && bash ./scripts/pnpm-node20.sh test:e2e:smoke:ci` - passed, 3 tests

### `tfp-collage-service`

- `PATH=<node24-dir>:$PATH corepack pnpm validate` - passed, 20 tests
- Stale `/tfp-workspace` path scan - clean

### `tfp-image-moderation-service`

- `uv run ruff check .` - passed
- `uv run pytest` - passed, 92 tests
- Stale executable path scan - clean except intentional regression-test assertions

## Current Go-Live Blocker

The application code and local validation gates are green after this pass, but production environment readiness is not green yet.

`bash ./scripts/pnpm-node20.sh qa:env:doctor:prod` correctly fails because the current production env resolves database URLs to localhost and is missing required production observability/runtime values:

- `DATABASE_URL`
- `DATABASE_DIRECT_URL`
- `SHADOW_DATABASE_URL`
- `SENTRY_DSN`
- `PUBLIC_SENTRY_DSN`
- `AXIOM_TOKEN`
- `RATE_LIMIT_REDIS_URL`

This is an external configuration/secrets blocker. It should remain a hard blocker until the production runtime points at the deployed PostgreSQL target and required observability/rate-limit secrets are supplied.

## Final Verdict

The reviewed code paths are remediated and validated locally. The workspace is not fully go-live ready until the production env doctor gate passes with real non-local production database URLs and required production secrets.
