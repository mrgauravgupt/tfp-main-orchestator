# Production boundary and security remediation — 7 October 2026

This handoff covers the confirmed findings from the executable-code Prisma/MVC,
dependency and trace-privacy audit. It does not claim absence of all defects or
production launch approval. Historical browser evidence is retained separately.

## Scoped implementation

| Boundary | Final change | Preserved behavior |
| --- | --- | --- |
| HTTP/database | Authentication reads a plain active identity through its existing query owner; profile updates read the exact prior snapshot through the user query owner; event/contest approval uses the existing media gate; message commands call plain repository operations | Session revocation, live roles/MFA, cookie cleanup, dependency-error 503, exact projections/predicates, approval/outbox arguments and transaction ownership |
| Enforcement | Existing architecture gate now runs AST fixtures and checks decorated Prisma use in HTTP callbacks, registered handlers and request hooks, including local aliases/destructuring and Fastify `this` | Composition, lifecycle hooks, subscribers and existing persistence/transaction owners remain valid; analysis is bounded within a file |
| Trace privacy | API and Web exporters share the canonical sanitizer; API Sentry transactions use the same privacy boundary; exported attributes/events/links/resources are sanitized and bounded | Trace/span/parent/link identity, flags, unknown-error classification, SDK failure propagation and original runtime contexts; opaque traceState is omitted only from exported snapshots |
| Dependencies | Sharp 0.35.5 and the affected shell/TOML/compression/source-map/DB-instrumentation packages are patched in frozen application/worker graphs | Existing parent framework/SDK versions, TLS, provider credentials, SDK retry policy and media lifecycle |

No schema migration, queue replacement, product-specific test mode, security
exception expansion or browser-test weakening was introduced. Large existing
transaction-capability stores remain intentionally unchanged; wrapping every
Prisma call in a new generic repository would not establish a security benefit.

Primary application owners are `apps/api/src/modules/auth/auth.queries.ts`,
`apps/api/src/modules/user/user.queries.ts`,
`apps/api/src/modules/message/message.repository.ts`, the event/contest HTTP
handlers, `scripts/architecture/http-persistence-boundary.mjs`,
`packages/shared/src/observability-redaction.ts`,
`apps/api/src/observability/bootstrap.ts` and
`apps/web/src/scripts/telemetry.client.ts`. Their affected callers/tests,
`tests/README.md`, `package.json` and `pnpm-lock.yaml` complete the 29-file
application commit. Worker changes contain only its package manifest and lock.

## Executed evidence

GPT-6.1 SOL high implemented each batch. Independent SOL high reviews traced the
final consumers and inspected discriminating mutation evidence. Exact source
hashes, logs and commands are retained under the application's ignored
`test-results/reports/diagnostic-review/architecture-security-audit-20261007/`
and `architecture-security-fixes-20261007/` directories.

- Database/MVC: 82 API tests and 32 AST guard fixtures passed. Four disposable
  mutations failed the intended media-gate, profile-owner, session-revocation
  and message-recipient assertions. Tracked source was not reverted.
- Privacy: 15 API, 10 shared and 4 Web telemetry checks passed. The actual API
  bootstrap exported real PostgreSQL/HTTP spans to an isolated local collector,
  preserved correlation and excluded synthetic sensitive tokens. Enabled,
  disabled and HTTP-400 exporter behavior executed. PostgreSQL used a synthetic
  read only. Removing the exporter wrapper failed the intended privacy assertion.
- Dependencies: 19 storage and 63 affected worker checks passed, plus real native
  image outcomes and resolved-graph/tooling probes. Strict application audit has
  no unapproved advisory; worker production audit reports zero advisories.
- Workspace typing, full lint, Playwright typing, strict-human guard 88/88 and
  full production build passed. Existing Astro unused-declaration hints are not
  test failures. The deployed production build also completed with exit 0.

The application still has five pre-existing, narrow advisory exceptions expiring
3 November 2026 (mobile/build dependencies). They were not widened. A passing
strict audit is not a statement that the complete dependency tree has zero advisories.

## Reproducible commands

```bash
# application workspace
bash scripts/pnpm-node20.sh -r typecheck
bash scripts/pnpm-node20.sh lint
bash scripts/with-test-env.sh bash scripts/pnpm-node20.sh build
bash scripts/pnpm-node20.sh test:e2e:human:guard
bash scripts/pnpm-node20.sh exec tsc -p tsconfig.playwright.json --noEmit
bash scripts/run-node20.sh scripts/security/audit-production.mjs
# exact target tests and real collector command: application tests/README.md
UAT_PRUNE_OLD_RELEASES=false bash scripts/deploy/deploy-main-uat.sh
# worker workspace
bash scripts/deploy/deploy.sh uat
# parent workspace
bash scripts/oci/verify-uat-stack.sh
```

## Publication and affected runtime proof

Application commit `50c0f1d2529acaf5d23021040d9682ec74f217d0` is published on
main and deployed as UAT `20261007T110654Z-50c0f1d2`. Worker commit
`c0b61ec6cedebc2c5ddde176717a26824a5ea503` is published and deployed as
`20261007T110914Z-c0b61ec6`. AI is unchanged. Exact Git-archive audits match all
1,174 application and 29 worker source blobs; full stack health passed (eight
active units, six reachable loopback endpoints, ready PostgreSQL, private-only
listeners and public Access 302). Both deployed ARM64 runtimes report Sharp
0.35.5, librsvg 2.63.2 and libvips 8.18.7.

One filtered UAT Chromium child covering profile edits, portfolio media and
two-party messaging is authorized after official discovery selected exactly
those three canonical blocks. The first launcher attempt stopped before browser
execution: discovery-only `PLAYWRIGHT_API_ORIGIN=http://127.0.0.1:4000` was
inherited into runtime while the canonical runner selected a different owned
tunnel port. Auth preflight reported ECONNREFUSED; zero tests executed. The
failed setup report/state and its three isolated QA identities are preserved.
The second launcher failed the existing 64-character run-ID contract before
preparing data; it also ran zero browser tests and remains preserved. Root then
validated a 38-character ID against the actual executable regex, clean revision,
absence of old owners, Python syntax and canonical owned-port derivation before
launching `uat-boundary-20261007T112011Z-50c0f1d2` once. It completed at
11:22:17 UTC with 3/3 passed, zero failures/flakes/skips/retries and exit 0.
All three blocks were previously unexecuted during the failed setup attempts.
No product/source correction or service redeployment is justified by these
operator mistakes. No full suite/browser
matrix replacement is authorized. It uses one worker, zero retries, complete
evidence and stop-on-first-failure behavior. Root used the canonical context loader to recompute the live registry/input
bindings and inspected all twelve desktop/mobile before/after captures. All
18 desktop/tablet/mobile files are regular and each document width matches its
viewport; relevant browser/page/request/server diagnostic arrays are empty.
The exact mappings are AUTH-005; PRO-001/002/003; MSG-002/003/004/009 and
NOTIF-002/003/004 (eleven IDs across three executed blocks). The final context hash
is `c7f16a2136a0a6484624ebd3a50481cc61a483d1e9c91ae5df2d85b9a44eab13`;
inputs hash is `2e7d841e2a408afc904665dc7d3c40084e9e6f5295237859c98b75e2500d7b2a`.
The filtered result remains incomplete and cannot produce a clean six-child
certificate. No owner remains and no further browser launch is required.

Independent final SOL high review accepted the scoped release with no blockers,
while retaining the strict certification/external launch limits. Root visually
inspected twelve desktop/mobile before/after captures; tablet geometry and
image dimensions were audited without claiming additional browser interactions.

Final evidence: `supervisor-uat-proof-audit.json`, `uat-source-audit.json`,
`uat-native-versions.jsonl`, `uat-final-health.log` and the source-bound independent
reviews under `architecture-security-fixes-20261007/`. Current operator state is
`/tmp/tfp-production-boundaries-reviewed-state.json`; the original two states
remain immutable failed setup evidence. Manual full certification is still
available through `test:e2e:human:certify`, but was not authorized or executed.

## Remaining production gates

The fresh strict production doctor exits 1 with nineteen external input gaps:
three database bindings, six legal/operator fields, three service URLs, four
scoped storage credentials and three backup bindings. Production host/DNS/TLS,
provider delivery, bucket ACL/CORS/retention and independent off-host database
and object restoration still need actual production access and evidence.

The unchanged strict certification contract requires six compatible complete
clean children and aggregate/verifier exit 0. Scoped checks cannot satisfy it;
historical, failed, dirty or partial evidence must not be spliced. The user's
no-full-rerun policy remains in force. Original provider/telemetry and earlier
unclassified observations are not explained by these unrelated corrections.
Production values were not fabricated and production was not deployed.


## Workspace safety

Only the 29 application files, two worker manifest/lock files, their parent
Git links and scoped root notes were committed. The root's initial rebase was
skipped because unrelated moderation-service/resume changes were present;
origin was fetched, nested repositories were already up to date, and scoped
main publications were pushed successfully. Unrelated changes, historical
f19 evidence, original failures and their caches were preserved. No production
mutation, broad reset/delete, provider fault injection or uncertain mutation
replay was performed.
