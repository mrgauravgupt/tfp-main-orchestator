# Production Readiness Remediation Report

Generated: 2026-06-28

## Scope

Closed-loop review, cleanup, remediation, and validation across the orchestrator and three active apps:

- `tfpphotographers`
- `tfp-collage-service`
- `tfp-image-moderation-service`

Secrets were treated as external inputs. Code, runtime scripts, package metadata, env templates, stale references, DRY/duplicate-code signals, and deployment entrypoints were remediated where defects were found.

## Remediation Completed

### Main app

- Fixed internal workspace package export maps so NodeNext TypeScript resolves source types without relying on stale `dist` artifacts.
- Made Prisma client generation part of `typecheck` and the `database` package build/typecheck path.
- Reordered root package build flow so `database` builds before packages that import its generated types.
- Patched production dependency audit findings with overrides and Astro upgrade:
  - `astro >= 6.4.6`
  - `vite >= 7.3.5`
  - `@grpc/grpc-js >= 1.14.4`
  - `protobufjs >= 7.6.3`
  - `js-yaml >= 4.2.0`
  - `@opentelemetry/core >= 2.8.0`
  - `@babel/core >= 7.29.6`
- Aligned translation SSOT to bulk pretranslation with approval-only provider triggers.
- Updated tracked env templates to the current Contabo UAT endpoints:
  - moderation/translation: `http://13.140.189.236:7001`
  - collage: `http://13.140.189.236:7003`
- Replaced stale developer-local absolute paths in QA and moderation helper scripts with repo-relative resolution.
- Removed obsolete one-off AI Horde and layer-B moderation audit scripts.
- Hardened client-side DOM rendering in contest and form helpers by replacing avoidable `innerHTML` construction with DOM APIs.
- Updated tests for translation fallback behavior and legacy truncated-id resolution.

### Image moderation service

- Replaced policy expression `eval` with an AST allowlist evaluator.
- Added unit coverage proving expression comparison still works and executable syntax does not run.
- Fixed local `scripts/service-control.sh` and Docker CMD to start the real app factory.
- Made local smoke images self-contained and configurable through `AIP_SMOKE_IMAGE_DIR`.
- Updated deployment contract tests for the real app factory entrypoint.
- Replaced stale workspace paths in generated/reference docs.

### Collage service

- No code changes were required.
- Build, tests, security audit, and duplicate-code scan passed.

### Root orchestrator

- Fixed `.gitmodules` to point at the actual `tfpphotographers` submodule path.
- Updated submodule pointers after nested repo remediation.

## Validation

### `tfpphotographers`

- `bash ./scripts/pnpm-node20.sh install --frozen-lockfile=false` - passed
- `bash ./scripts/pnpm-node20.sh audit --prod` - passed, no known vulnerabilities
- `bash ./scripts/pnpm-node20.sh env:test` - passed, 10 tests
- `bash ./scripts/pnpm-node20.sh lint:architecture` - passed
- `bash ./scripts/pnpm-node20.sh lint:eslint` - passed
- `bash ./scripts/pnpm-node20.sh typecheck` - passed
- `bash ./scripts/pnpm-node20.sh build` - passed
- `bash ./scripts/pnpm-node20.sh test:vitest` - passed, API 139 files / 840 tests and web 22 files / 91 tests
- `jscpd apps packages scripts tests qa --min-lines 80 --min-tokens 120 ...` - passed, 0 clones

### `tfp-collage-service`

- `corepack pnpm validate` - passed, 21 tests
- `corepack pnpm audit --prod` - passed, no known vulnerabilities
- `jscpd src tests scripts --min-lines 60 --min-tokens 100 ...` - passed, 0 clones

### `tfp-image-moderation-service`

- `uv run ruff check .` - passed
- `uv run pytest -q` - passed, 97 tests
- `uv pip check` - passed
- `jscpd src tests scripts --min-lines 60 --min-tokens 100 ...` - passed, 0 clones

### Root

- Shell syntax checks passed for root, main app, collage service, and image moderation service deploy/runtime scripts.
- Stale reference scan is clean for old workspace paths and old service entrypoints, except intentional regression-test assertions.

## Remaining External Blocker

`bash ./scripts/pnpm-node20.sh qa:env:doctor:prod` correctly fails strict mode because production secrets and production runtime endpoints are placeholders or unset:

- `JWT_SECRET`
- `SENTRY_DSN`
- `PUBLIC_SENTRY_DSN`
- `AXIOM_TOKEN`
- `RATE_LIMIT_REDIS_URL`

This is expected under the requested "other than secrets" boundary. The code and deploy scripts are ready for real secret injection, but production should not be declared live until this doctor gate passes with real values.

## Verdict

The three-app codebase is substantially cleaned, hardened, and deploy-ready apart from external production secrets. The current branch should be merged to `main` after nested repo commits are recorded and root submodule pointers are updated.
