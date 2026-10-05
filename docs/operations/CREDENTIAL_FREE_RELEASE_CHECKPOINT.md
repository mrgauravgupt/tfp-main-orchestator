# Credential-free release checkpoint — 4 October 2026

## Deployment and completed work

Application/harness: `27045e137befb3be31c12a13abdcb60b0f7490e5`.
OCI UAT application release: `20261004T212219Z-27045e13`.
AI revision: `d40ec5809c556b56b12da5e540fa1a092a160a6a`;
collage revision: `d6fadf545c74d45282ab9af9f0de7d4d6bf38a92`, release
`20261004T211904Z-d6fadf54`.
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

The authorized sequence `web-certification-20261004T171252Z-7b910601` is now
terminal with status `1`. Fresh-cache discovery matched all 77 canonical blocks;
all three local browsers passed 77/77. UAT Chromium stopped after 50 passed,
one failed and 26 not run; UAT Firefox/mobile and aggregate did not start.
The first failure was `profile-portfolio.human.spec.ts:18`: browser diagnostics
recorded a signed private object GET blocked by `net::ERR_BLOCKED_BY_ORB`, with
no HTTP 5xx recorded. Its response/initiator/media lifecycle root cause remains
under scoped SOL high investigation. No automatic replacement is authorized.
Read-only review excluded signed-URL expiry and upload failure. The blocked GET
began before confirmed deletion, but its original response/status/completion
were not captured; an in-flight deletion race remains a hypothesis.
A separate defect is confirmed: deletion removed the portfolio row/source while
its media asset remained approved and active, allowing a later approval event
to schedule rendition processing for the deleted source. SOL high is authorized
for one test-bound, sanitized focused network diagnostic and then a minimal
atomic deletion/media-retirement correction with lifecycle regression tests.
That correction must not be described as an ORB fix without further evidence.
No full certification, publication or deployment occurs before root review.
Root has now independently accepted the scoped portfolio-retirement correction:
eight application files, five collage-worker files and the root worker-fixture
generator. The owner deletion transaction retires media, cancels pending work
and queues existing revocation; late moderation, approval and publication cannot
restore it. Rejected publication removes only fresh exact unregistered attempt
keys, preserving existing, referenced and held objects. API 31/31 and real
PostgreSQL/Sharp/local-file worker 19/19 tests passed, with discriminating
mutations restored; typing, guard and fixture checks passed. No migration was
added. Review evidence is
`tfpphotographers/test-results/reports/portfolio-retirement-review-20261004T205113Z/review.md`.
The original ORB remains unclassified: the single read-only CDP diagnostic passed
without reproducing it. The strengthened exact loaded-image precondition still
requires post-deployment browser proof.

Low-cost agent `/root/certification_recovery_monitor_low` is the sole owner for
remaining scoped lint/build checks, scoped app/worker publication and root
generator/gitlinks, exact UAT deployment/health/restart, then one zero-retry
focused Chromium portfolio proof. It must stop for independent evidence review
before any fresh six-child certification. Do not duplicate its work.
The accepted scope is published: app `27045e13`, collage `d6fadf54`, root
generator/gitlinks `9e5bbb7`. Scoped lint, API/worker production builds and
fixture drift checks passed. Exact UAT archive verification matched all 1,168
application files and 28 collage source files; stack checks passed with eight
active units, six endpoints, PostgreSQL ready, loopback-only listeners and Access
302. Deployment's PostgreSQL-specific tests were skipped because its test DB
variable was unset; the separately executed 19/19 worker result remains the
actual regression evidence.

Focused runner `uat-profile-portfolio-20261004T212620Z-27045e13` exited 1 before
browser execution: an anchored selector matched zero full Playwright titles.
Preserve its log/context as diagnostic, never positive proof. Root reviewed the
setup cause and authorized one corrected unique unanchored title selection,
after non-browser discovery proves exactly one Chromium block. The same
low-cost owner will run the focused proof once and stop; no source change,
deployment repeat or full certification is authorized by this selector fix.
Corrected non-browser discovery matched exactly one Chromium block and resolved
PRO-001/002/003. Launcher `uat-profile-media-20261005T002400Z-7fd1c3` then ended
abruptly before fixture preparation or browser execution: its PID and runner
were absent, no context/manifest/browser artifacts existed, and its status still
said `running`. Its final exit is unknown; never interpret that status as a pass.
The `nohup`/background launch did not survive the short tool invocation reliably.
Root authorized a new explicit focused recovery checkpoint using an independent
OS session (`subprocess.Popen(start_new_session=True)`), closed stdin and file
logging, with a new run ID/cache/status. Preserve the interrupted state/log. This
is a launcher recovery, not a product retry or full-suite replacement. The
low-cost owner remains responsible for one focused proof and stops for review.
Focused recovery `uat-profile-media-20261005T004000Z-93a2c1` completed with exit 0:
one Chromium test passed, zero retries/failures/flakes/skips. Root independently
checked regular context/manifest/evidence files, canonical PRO-001/002/003 source
mapping, the context content hash, live registry hashes and exact clean app/UAT
revision. The new loaded-image assertion executed successfully; all six
before/after breakpoint captures were complete, and desktop/mobile captures
were visually inspected. This is focused proof, not an ORB root-cause claim or
a six-child certificate.

Root authorized exactly one fresh canonical six-child sequence on frozen
`27045e13`, after fresh isolated-cache discovery confirms all 77 blocks. The
sole low-cost owner must use the successful independent OS-session launcher,
idle-sleep guard, zero retries/maxfail1, serial local three then UAT three and
mandatory aggregate/verifier. New operator state is
`/tmp/tfp-certification-portfolio-state.json`; until it exists, launch is pending.
The sequence is now active as `web-certification-20261004T231200Z-8b409da2`.
Fresh discovery matched 77 canonical blocks in all three projects, covering all
146 implemented IDs. Independent OS-session owner PID 65202 is alive; its
atomic status is still `running`, so no completion is claimed. State records
the isolated cache, logs, wrapper and status path. Local Chromium is first;
leave the healthy one-owner serial sequence uninterrupted.
The same sequence is now terminal with wrapper exit 1 and owner absent. Local
Chromium, Firefox and mobile plus UAT Chromium each passed 77/77; UAT Firefox
stopped after 42 passed, one failed and 34 not run. No UAT mobile or aggregate
started. First failure: messaging-notifications.human.spec.ts:148, block/unblock
partner safety case. At line 186, after the visible blocked-boundary compose
submission, waiting for `sent=1` timed out after 30 seconds. Missing action
evidence is a cascade; the initiating request/state cause is not established.
Preserve the entire run, all traces/screenshots/videos/context/manifests/logs,
cache and persisted state. SOL high is assigned read-only browser/network/log/
database/source correlation and a grounded cause/correction table before any
source change or probe. No automatic replacement or timeout increase.
Read-only SOL high review found the failure precedes any safety-control action:
Firefox acknowledged a 38-character fill, but resolved DOM snapshots retained
an empty textarea and `0/150` counter through the click. No message Web/API POST
or persisted message/block action occurred. Native required validation is the
likely submission barrier; the cause of insertion loss remains unclassified.
An earlier textarea fill in the same test worked. No product, block-logic or
transport fix is justified by this evidence.

Root authorized exactly one existing-case zero-retry focused UAT Firefox
diagnostic with temporary read-only focus/input/invalid/connectivity/value-length
observers and a fail-fast exact-value precondition before submit. No insertion
replay, typing-strategy change, product edit or permanent harness change is
authorized. Restore temporary instrumentation afterward and report observations
for review before any new fix or certification. Preserve original evidence and
never claim a passing diagnostic explains the earlier lost insertion.
Diagnostic `uat-firefox-compose-diag-20261005T023929Z-14ba6b` passed once with
zero retries: the connected, enabled and focused textarea received input events,
changed from length 0 to 38, and passed the exact-value precondition. The original
loss was not reproduced. Temporary source was restored byte-for-byte; its dirty
diagnostic context is not certification evidence. Review bundle is the run's
`diagnostic-review/summary.json`. No product fix is justified.

Root authorized SOL high to evaluate a minimal human-action precondition in the
affected case: visible click, verified focus, one original fill and exact-value
verification before submit. This strengthens action proof without insertion
replay or claiming the unclassified cause fixed. If appropriate, make only the
scoped harness/README change and fast checks, then stop for diff review; no
browser run, publication or full replacement is yet authorized.
Only about 1.1 GiB is free. A fresh six-child report needs more headroom; the
canonical runner has no resume facility, so do not splice existing passed
children or launch into avoidable disk exhaustion. The low-cost agent is doing
one read-only inventory of project-local stale reproducible build outputs;
all evidence, caches and unrelated data remain protected.

Pre-launch disk review authorized only stale ignored Android intermediate
compiled files: four named generated directories and eight `.so` files under
`intermediates/cxx`, last modified about 180 hours earlier with no native build
running. Cleanup reclaimed 546,553,156 bytes; APKs, source maps, native symbols,
lint reports/logs and all Web evidence/caches were preserved. Exact inventory:
`/tmp/tfp-certification-portfolio-cleanup-20261005.json`. Free space was 2.7 GiB
at launch; monitor it with the compact certification observation.
`/tmp/tfp-certification-storage-state.json` describes the old stopped run.
Never infer success from a missing final exit, overlap runs or change source.
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
