# Credential-free release checkpoint — 4 October 2026

## Deployment and completed work

Application/harness: `b1a3941558d6f6c341bc8aee0a10787a90019080`.
OCI UAT application release: `20261004T104000Z-b1a39415`.
AI revision: `d40ec5809c556b56b12da5e540fa1a092a160a6a`;
collage revision: `6d324aeab49666af97b737c03b3221f17ff0c057`.
Exact app marker and stack verification passed: eight active units, six reachable
loopback endpoints, PostgreSQL ready, private listeners loopback-only and public
Access boundary HTTP 302. AI/collage deployed production source matched their Git
archives; authenticated readiness and API-to-service authentication bindings
were verified. This is UAT evidence, not a production deployment or certificate.

- Canonical private storage bindings propagate to the AI worker without public
  or account-administration credentials; selector tests passed 4/4.
- Missing app-owned secrets were prepared only in ignored mode-0600 overrides.
  Existing values were preserved; provider credentials/legal identity were not
  invented or committed.
- A private UAT database dump/checksum was restored to a disposable local DB,
  evidence migrations applied and seven restore checks passed. No live UAT
  restore occurred. Remote bucket retention/object recovery remains unproven.
- Focused UAT `uat-20261004T093705Z-2d24c2` passed CON-020, OPP-021, OPP-022:
  3/3 with complete action evidence and zero retries. These prove actual reference
  and PDF downloads plus the exact public opportunity gallery journey.
- Scoped config, restore, schema and download checks passed. Broader unchanged
  workspace typecheck/lint/build and Web checks were not repeatedly rerun; results
  are recorded in the application's production-preparation runbook.

## Preserved failure and reviewed correction

| Source/evidence | Failure/root cause | Correction and status |
| --- | --- | --- |
| Clean `58f5244a`; `web-certification-20261004T094230Z-0f9780e0` | Chromium 77/77; Firefox 16 passed then collaboration flow failed: notifications API 500, SSR 503. Original backend exception was absent because test-mode logging was silent. Original 500 remains unclassified. | Preserve run and private TEST DB snapshot. No mobile/UAT child started; diagnostic only. |
| Read-only persisted TEST state | Actual notification function and real-loopback route succeeded. This does not explain the original exception. | No unsupported claim that the original failure was fixed. |
| `88ca6fa0` / `b1a39415` | Silent defaults/transport thresholds could hide future errors. | Canonical validated LOG_LEVEL; human server ERROR; stdout respects producer level; Axiom INFO; Docker policy forwarding. Config 40/40, logger 7/7, wiring 1/1, synthetic Compose, API/config/Playwright typing, guard 88/88 and diff check passed. SOL high review accepted. |
| `local-20261004T102748Z-d4e382` | Anchored selector matched zero tests, exit 1. | Correct selector only; not positive proof. |
| `local-20261004T102907Z-9caadf` | Collaboration workflow ran with reviewed diagnostic logging. | Focused Firefox 1/1 passed. Working-tree diagnostic evidence, not certification; business assertions unchanged. |

Preserve all original reports, screenshots, videos, manifests and private
dump/checksum artifacts. Never log raw customer input, account identifiers,
credentials or signed URLs during recurrence diagnosis.

## Remaining gates

### Reviewed interruption recovery — 4 October 2026

The user confirmed accidentally closing the laptop. Certification
`web-certification-20261004T105142Z-225e59c8` lost its owner during local mobile
execution: last positive test marker 62, no finalized mobile result/manifest;
logs stopped at 12:11:58 UTC. No UAT child started. Partial reports and the private
TEST dump/checksum at
`tfpphotographers/tmp/db-backups/test-tfp_photographers_test-20261004T123855Z.dump`
are preserved. Canonical scoped cleanup stopped abandoned local services only.

SOL high review found a separate metadata defect in the two completed local
children. Both executed 77/77, but four CRUD declarations had compiled rather
than canonical source locations and empty evidence use-case IDs. The official
aggregate verifier rejects these children despite successful execution and
superficially complete artifact status. They are diagnostic only.

Playwright's transform cache retained JavaScript but lost its companion source
map; embedded source matched frozen TypeScript. Default non-browser discovery
reported lines 67/94/120/146; isolated-cache discovery reported canonical
85/110/134/158. All 77 blocks matched canonical annotations with fresh cache.
Why the old map disappeared is unknown; no business/source defect is established.

Reviewed recovery uses unchanged `b1a39415`, a new run-scoped `PWTEST_CACHE_DIR`
outside hashed source, and one fresh canonical six-child run. Original evidence
will not be rewritten or spliced; duplicate browser/profile slots cannot repair
the old children. No code, assertion, retry, security or registry change is
needed. A detached launcher and macOS idle-sleep assertion keep execution
independent of chat tool handles. Keep the laptop open and connected: this
cannot override lid-close sleep. Stop on the first actual failure.

After source freeze and exact deployment, run one fresh zero-retry sequence from
the application repository:
`bash scripts/pnpm-node20.sh test:e2e:human:certify`.
Its runners own FE/BE restarts and isolated TEST data. Six fresh serial local/UAT
browser children must pass, followed by a compatible aggregate and canonical
verifier exit 0. Stop on the first failure. Do not reuse earlier Chromium or
focused evidence. Historical `f19c7ab8` certification remains unchanged.

Strict production doctor still rejects 19 inputs: three production database
URLs; six operator/officer/address/law/forum values; three remote service URLs;
four private/public storage credential fields; three backup storage fields.
Canonical STORAGE/BACKUP bindings are supported; legacy names in doctor output
are compatibility aliases. Actual host/DNS/TLS/proxy deployment, bucket ACL/CORS,
provider delivery, retention and independent retained-object recovery need
production access and real operator/provider inputs. Do not relax launch gates.

OAuth and six delivered-email OTP cases remain excluded. QR-013 remains blocked
while no customer-facing operator moderation UI exists. Native mobile, folder
moderation and production mutations are outside this work.
