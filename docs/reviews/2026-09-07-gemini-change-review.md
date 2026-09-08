# Gemini change review — 7 September 2026

> Historical review snapshot. For the current source-verified backlog, use [the 8 September audit and implementation plan](2026-09-08-deep-architecture-audit-and-implementation-plan.md). Revalidate these older findings before changing code.

## Reviewed scope

Reviewed the uncommitted application changes and the associated worker changes
in Gemini commits `8df3834` (collage) and `78964e3` (AI interface). The historical
`tfp-moderation-service` policy file is outside this active runtime change.
Follow-up changes were initially left uncommitted for review. The user then
authorized committing them, including the parent gitlinks. No deployment or
database reset was performed.

## Defects corrected

| Area | Finding and correction |
| --- | --- |
| Collage fetch | A separate DNS preflight ran outside the fetch deadline. Address validation now happens in the actual request socket lookup, within each attempt's deadline. Literal addresses are checked before request creation, including bracketed IPv6. Corrected the ORCHIDv2 prefix mask and rejected malformed IP strings. |
| Collage tests | The original rebinding and stream-size tests did not exercise their named HTTP paths. Replaced them with a controlled loopback transport fixture covering socket lookup, retry revalidation, streamed bytes, redirects, content types, and stalled DNS/headers/body. |
| Python pool | Open the pool before readiness, bound waiting borrowers and database operations, move readiness DB access off the event loop, and close the pool on startup failure and even when inference shutdown fails. Added actual PostgreSQL reuse, rollback, exhaustion and lifecycle checks. |
| Correlation privacy | Arbitrary values were coerced into correlation log fields. TypeScript and Python now accept only bounded opaque IDs and preserve legacy jobs without metadata. |
| Wire contract | The canonical result schema rejected the new top-level correlation field because additional properties are forbidden. Added optional bounded correlation fields to all relevant requests/results and executable AJV validation of actual TS producers plus representative result envelopes. |
| Domain events | Infer event types from the Zod schemas instead of maintaining a duplicate map. Reject inherited schema-map keys and avoid persisting Zod messages that can contain rejected payload values. |
| SSR location | Keep the timeout active through body consumption; reject malformed coordinates and cancel unsuccessful response bodies. Tests now use the configured client-IP header, proving the fetch is actually reached. Extracted the helper to keep middleware within the architecture size limit. |
| Consumer fixtures | Updated two rejection-notification fixtures with titles already required by the event contract. |

## Validation

Run from `tfpphotographers` unless otherwise specified:

```bash
bash scripts/pnpm-node20.sh lint
bash scripts/pnpm-node20.sh typecheck
bash scripts/pnpm-node20.sh build
bash scripts/pnpm-node20.sh --filter shared test
bash scripts/pnpm-node20.sh --filter web test
bash scripts/pnpm-node20.sh --filter api test tests/background/process-ai-result-jobs.test.ts tests/modules/moderation/ai-outbox-contract.test.ts tests/modules/moderation/application/complete-approved-image-upload.test.ts tests/modules/moderation/application/process-entity-moderation-job.test.ts tests/modules/notifications/register-event-handlers.test.ts
```

From the root:

```bash
bash tfpphotographers/scripts/run-node20.sh --test scripts/contracts/ai-outbox-payloads.test.mjs scripts/contracts/validate-ai-outbox-contract.test.mjs
```

From `tfp-ai-interface`, using the local virtualenv:

```bash
.venv/bin/ruff check src tests
TEST_DATABASE_URL=<disposable-local-PostgreSQL-URL> .venv/bin/python -B -m pytest -q -p no:cacheprovider
```

From `tfp-collage-service`:

```bash
TEST_DATABASE_URL=<disposable-local-PostgreSQL-URL> bash scripts/pnpm-node.sh validate
```

Shared: 127 tests passed. Web: 647 passed. Python: 86 passed. Collage: 53
passed, including PostgreSQL integration with no skips. Canonical root contract:
4 passed. Focused API: 27 passed across five files. Lint and full app build passed; Astro reported 26 existing hints and
no errors or warnings. Full typecheck passed before helper extraction; the final
lint/build also typechecked the extracted module and its consumers.

Restarted FE and BE against local TEST, confirmed API health, and inspected the
rendered homepage screenshot before and after dismissing the privacy banner.
No browser warning/error entries were returned for that page. This proves the
normal local page renders; deadline behavior is separately exercised with an
actual stalled HTTP response in tests. It is not UAT or provider E2E evidence.

## Claims that remain partial or unsupported

- Request IDs now traverse the implemented moderation request/result boundary.
  This is not complete distributed tracing: the normal approval notification
  path does not supply the original ID to `enqueueEntityTranslationJob`, and
  browser/SSR-to-API origin continuity has not been established. The translation
  builder accepting an optional field is not proof that its caller supplies it.
  Completing that path needs correlation carried through the media publication
  workflow as well, not only through the result logger.
- The existing outbox indexes are real, but index existence does not prove
  "zero query plan degradation". No representative EXPLAIN/load evidence was
  supplied. No index migration is justified by the pasted update alone.
- Provider concurrency limits, cooldown and backoff are real resilience
  mechanisms. They do not on their own establish a stateful circuit breaker
  with an open/half-open recovery policy.
- Serial collage processing limits per-process job concurrency. It does not
  prove absence of OOM from one large job or multiple worker processes.
- No database-backed queue replacement, quantization change, or production GUI
  change is justified by these findings.

## Review state

At review completion, no new commits or pushes had been made. Initial sibling
pull attempts stalled in SSH and were stopped without changing branches or
local files. Remote fetches succeeded on the subsequent user-authorized commit
pass. The service changes are published before the parent gitlink update.
The validation results above describe the reviewed implementation; committing
does not establish additional runtime or deployment evidence.
