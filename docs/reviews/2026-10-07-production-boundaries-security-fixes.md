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
those three canonical blocks. Its results are pending. No full suite/browser
matrix replacement is authorized. It uses one worker, zero retries, complete
evidence and stop-on-first-failure behavior. The filtered result remains
incomplete and cannot produce a clean six-child certificate.

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
