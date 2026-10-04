# Credential-free release checkpoint — 4 October 2026

## Deployment and completed work

Application/harness: `0717ef3e5ad89e7f1574a0ddf0141197003729f0`.
OCI UAT application release: `20261004T164812Z-0717ef3e`.
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

Recovery execution is `web-certification-20261004T124843Z-f5810577`, launched
detached with idle-sleep protection. Operator state is
`/tmp/tfp-certification-recovery-state.json`; private log/status files are
`tfpphotographers/tmp/certification-recovery-20261004T124842Z.log` and `.status`.
Cache is `tfpphotographers/tmp/human-certification-cache-qtfa4t29`.
Low-cost monitor: `/root/certification_recovery_monitor_low`.
At dispatch, one owner was active, local Chromium began 77 tests with one worker,
and the first test passed. No completion/certification is claimed yet. Do not
launch another run while this owner is active; a missing final status file means
unfinished execution, not success.

Recovery is now terminal: wrapper status `1`, owner absent, no replacement
started. Local Chromium, Firefox and mobile-chromium each passed 77/77 with
zero failures/flakes/skips and exit 0. UAT Chromium stopped on test 29 after
28 passed, one failed and 48 not run; UAT Firefox/mobile did not start.
Preserve the entire recovery report and first-failure artifacts.

The initiating failure occurred before CON-020's resource-download action,
during contest **banner upload completion**. Presign returned 200 at
14:27:19.543 UTC; completion returned 500 with `ETIMEDOUT`. The UAT Web error
at 14:27:26.029 identifies upstream `/contests/uploads/banner`; API request
`req-2ot` ended with 500 at 14:27:26.034. Navigation timeout and missing action
evidence are cascades. The timed-out operation remains unclassified; do not
attribute this to reference download or storage without further evidence.
SOL high's scoped read-only investigation was interrupted by model capacity
and resumed once. No product/harness edit, service restart, mutation or browser
rerun is authorized by an unproved timeout diagnosis.

### Reviewed storage transport correction

The API exception was recovered using `journalctl --all`: the SDK exhausted
three TCP connection attempts, with IPv4 `ETIMEDOUT` and IPv6 `ENETUNREACH`.
Logging worked; the precise S3 command remains untagged. Same-host real-socket
comparison found two destination addresses failing with Node's 250 ms family
attempt timeout and succeeding at 1,000 ms. No continuing provider outage is
claimed. Sanitized probe evidence is retained under
`tfpphotographers/test-results/reports/storage-transport-review-20261004/`.

Reviewed commit `0717ef3e` adds canonical
`STORAGE_CONNECT_ATTEMPT_TIMEOUT_MS` (default 1,000; valid 10–10,000 ms), scoped
to the application S3 adapter's HTTP/HTTPS agents. Compose forwards overrides;
templates leave them optional. TLS, SDK retries, upload checks, intent lifecycle
and private/public credentials are unchanged. Separate AI, collage and backup
clients are unaffected. Config 93/93, storage 18/18, affected API 25/25 and
executable runtime wiring 3/3 passed; socket/wiring mutation checks failed as
intended. Relevant typing/builds, Web/Playwright typing, lint, guard 88/88 and
diff checks passed. Parent gitlink publication is `e685003`.

Exact UAT release `20261004T164812Z-0717ef3e` passed stack/marker verification.
Focused `uat-storage-download-20261004T165204Z-0717ef3e` passed once with zero
retries/failures/flakes/skips: visible reference download, exact filename/content
and persistence after reload, plus complete before/after desktop/tablet/mobile
evidence. Root independently inspected context, manifest, catalog, assertions
and desktop/mobile captures. This is focused proof, not release certification.

One fresh canonical six-child run is authorized on frozen `0717ef3e`, after
fresh isolated-cache discovery matches all 77 annotated blocks. Low-cost agent
`/root/certification_recovery_monitor_low` owns launch/monitoring and saves new
operator state in `/tmp/tfp-certification-storage-state.json`. Previous run
state and evidence remain intact. Do not launch overlapping work or reuse any
older revision's children. Final aggregate/verifier success remains pending.

The authorized sequence is now active:
`web-certification-20261004T171252Z-7b910601`. Fresh-cache discovery matched all
77 canonical blocks; local Chromium completed 77/77 and Firefox is progressing.
Read `/tmp/tfp-certification-storage-state.json` for the detached owner, current
logs and atomic final status. No overlapping run or source change is permitted.
The user has authorized autonomous overnight scoped decisions and feasible fixes;
use low-cost monitoring every 30 minutes and SOL high for confirmed defects and
final independent evidence review. Production inputs remain external gates.

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
