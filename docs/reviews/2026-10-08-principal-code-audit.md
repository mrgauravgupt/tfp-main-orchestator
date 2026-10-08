# Principal code audit and remediation — 8 October 2026

## Scope and baseline

The user requested a code-first workspace audit followed by the smallest justified
fixes. Findings below were published before source modification. Current executable
branches, callers, package/framework roots and active configuration are evidence;
previous reports are orientation only.

Baseline: app `5c732cb24059ece0778a7aa58169b2d628258a41`, collage
`c0b61ec6cedebc2c5ddde176717a26824a5ea503`, AI
`96fef1a18cd3cfeffba28f3d170fe451b7985e58`, parent
`930ca788d23f7181d43e463bb634e502005f6c51`. Remote heads matched at inspection.
Unrelated moderation changes and the executive resume are excluded.

## Prioritized pre-edit findings

| ID / severity | Evidence and root cause | Affected files / minimal fix |
| --- | --- | --- |
| A01 / P1 | Device-global durable mobile upload records lack account/origin ownership; startup uses current credentials. A different account can receive a previous account's retained upload. | `apps/mobile/src/infrastructure/uploads/{upload-queue,direct-upload}.ts`, HTTP/auth repository consumers. Bind to canonical user/origin and fence the session at each mutation; no persisted tokens. |
| A02 / P1-P2 | Mobile recovery always presigns a new key after a lost completion response; queue updates are unsynchronized read/modify/write. | Same upload owners and tests. Mark attempt durably before mutation, hold unknown attempts, serialize mutations, validate records and contain background rejection. |
| A03 / P1 conditional | Google signed identity claims are accepted without email assurance; a new subject is linked to an existing email user. A third-party email without hosted-domain assurance is not current authoritative ownership. | `apps/api/src/modules/auth/oauth-{types,provider-adapters,user-service}.ts`, exchange consumers/tests. Require explicit verified authoritative email for new email-based linking; retain existing subject bindings and accurate identity metadata. No observed exploit claimed. |
| A04 / P2 | Saved notification quiet-hours preference is never read by ordinary alert delivery. | API `notifications/{quiet-hours,notification-delivery}.ts`, event outbox, shared event bus, database outbox adapter. Defer through existing durable scheduling after immediate recipients/in-app dispatch; conserve claims and preserve delivery ambiguity/lease rules. Security/auth mail stays immediate. |
| A05 / P2 | API HTTP retry waits escape the timeout and overwrite caller cancellation. | `apps/api/src/utils/http-client.ts`. Bound the entire operation including backoff; preserve safe-method/idempotency restrictions and caller abort. |
| A06 / P2 | Fallback in-memory cache retains unvisited expired keys and has no capacity. | `packages/database/src/adapters/cache.adapter.ts`, canonical config/API composition. Bound capacity and sweep expiry without another cache framework. Production Redis guard limits exposure. |
| A07 / P2 | AI caller budget excludes provider Retry-After waits, so the provider can continue after its caller abandons the response. | AI `worker_adapters.py`, `provider.py`, canonical settings and tests. Share a bounded budget and return retry guidance when no attempt fits. Not a classification of historical provider failures. |
| A08 / P2 | API, AI and collage request logging includes caller-controlled raw paths/queries; Fastify default unmatched-route messages are a separate sink. | API `observability/logger.ts` and `server.ts`, AI `api.py`, collage `server.ts`. Use route templates/fixed unmatched labels and safe request serializers while retaining correlation/classification. Private loopback deployment narrows exposure. |
| A09 / P2 | UAT verifier rejects wildcard bindings but misses a second listener on a specific public/private address. | Root `scripts/oci/verify-uat-stack.sh` and fixtures. Check every listener for required ports. No live exposure claimed. |
| A10 / P2 | Optional UI worker reserves jobs after thread start; force bypasses active ownership; daemon/restart leaves stale lock/status. | `services/ui-review-worker/app/{job_manager,main}.py`. Reserve before admission, release only owned work, reconcile abandoned local jobs and bounded shutdown. Preserve supported terminal reruns. |
| A11 / P2 | Archive metadata screenshot references and capture/run IDs escape path confinement despite safe tar extraction. | UI worker `review.py`, `schemas.py`. Confine references, validate IDs and use internal crop names; retain explicitly supported operator archive/output paths. Authenticated-tool defense in depth. |
| A12 / P2 | UI reviewer resizes screenshots without transforming regions; crop-local boxes are treated as original-image boxes. | UI worker `review.py`, producer coordinate contract and tests. Explicit scale/origin mapping and crop identities; retain report shape. |
| A13 / P2 | Readonly Web date inputs use an unnamed calendar dialog, English controls and incomplete Escape/focus behavior. | Web `scripts/client/form-helpers.ts`, `FormHelpersScript.astro`, translation catalog/tests. Reuse localized labels and complete keyboard/dialog behavior without changing serialized dates/limits. |
| A14 / P3 | Additional private test-only facades/helpers, unreachable mode/style/component branches and a duplicated discovery radius bound have no runtime consumers. | API auth/upload/translation/moderation/report/user owners; mobile presentation/domain; Web private locale/resource helpers; UI-worker unused preprocess/fields. Remove proven dead branches, move meaningful tests onto active owners, use shared radius policy. Retain public exports, registered assets, migrations/operator tools/history. |
| A15 / P3 | Final complete mobile unit run reaches the production guard and finds three Web feature IDs absent from the native compatibility ledger. Core runtime source is unchanged at this boundary; this is stale cross-platform inventory, not native business proof. | Native coverage matrix, exact guard consumer and README. Trace the actual native paths, record honest planned dispositions and keep the guard strict; rerun only the failed guard block. |

## Architecture and validation boundaries

Baseline architecture gate and 37 AST fixtures passed. A resolved runtime import
graph inspected 998 files / 4,084 imports with no cycles or unknown dynamic imports
in its selected application/shared roots. These are bounded checks, not a guarantee
of arbitrary runtime behavior. Repository/query/transaction composition is valid;
the PostgreSQL durable outbox remains the intentional architecture.

Baseline production dependency audit passed with five approved exceptions expiring
3 November 2026; exceptions are retained rather than bypassed. Offline release
preparation passed 36 checks. Secret scans are redacted; current fixture/default
findings and historical credentials must be classified before reporting results.

Each batch must trace direct/indirect consumers, persistence/events, configuration,
platform boundaries, compatibility and rollback. Tests must reach real boundaries
and discriminate broken behavior. Use scoped lint/types/unit/integration/builds;
coordinate shared package builds and disposable database ownership. Browser/native
proof is separate and requires owned restarted FE/BE services. No full matrix rerun,
production deployment, broad reset/deletion or evidence rewriting is authorized.

OAuth and delivered-email OTP business journeys remain excluded. Lower-level policy
tests cannot be called those business passes. Historical failures stay preserved;
observability or a passing focused proof does not establish their initiating cause.
External production host/provider/legal/storage/recovery inputs and strict fresh
six-child certification remain separate gates; values or approval cannot be invented.

## Implemented and independently reviewed

The fourteen initial confirmed findings were addressed in bounded batches. Final
unit validation also identified A15, a stale native compatibility inventory. Final SOL high
reviews found and closed two additional branches of A01/A08: successful account
deletion followed by SecureStore cleanup rejection, and the collage default 404
log's raw URL. An actual Pino-sink mutation discriminates the latter. No product
or test suppression, migration, queue replacement, hidden retry or full browser
matrix was introduced.

Web and native clients already share the same backend. API query/repository and
transaction owners remain the persistence boundary; platform HTTP cookies and
SecureStore bearer credentials remain separate adapters. Shared account-deletion
confirmation, discovery radius, API prefix and location-provider policy now have
one executable owner. The environment doctor consumes the same policies as runtime.
No common UI framework or artificial MVC layer was added.

- Mobile upload/session work freezes account, API origin, bearer and session
  revision; fences mutations; serializes local state; holds uncertain attempts
  instead of replaying them; and preserves a later account on delayed logout/401/
  deletion. Legacy unowned records are unreplayable. Completed server deletion is
  distinguished from device cleanup failure, including actual SecureStore rejection.
- New OAuth email-based linking requires verified authoritative mailbox claims;
  existing provider-subject bindings remain supported. Meta does not supply the
  required mailbox assurance. Denial advises email sign-in without pretending
  seed-login tests are OAuth/OTP business proof. Unexpected errors have safe copy.
- Ordinary email quiet hours defer through the existing outbox after immediate
  handlers/recipients. Sent ledger, replay/hash/lease ambiguity and security mail
  remain intact. Exact claim CAS uses one monotonic database timestamp owner and
  conserves attempts; real PostgreSQL tests discriminate same-millisecond reuse.
- Whole HTTP-operation deadlines cover fetch, body, Retry-After and caller abort;
  cache capacity/expiry are bounded via canonical configuration and runtime wiring.
  AI image attempts/caller share a budget instead of increasing arbitrary timeouts.
- API/AI/worker logs retain route/status/request/error correlation without raw
  paths. UAT verification checks every listener on required ports, not only a
  wildcard listener. Optional UI worker admission, abandoned-job recovery, confined
  screenshot paths and original/crop/CSS coordinate transforms are corrected.
- Localized date calendars have field-derived dialog labels, selected-date focus,
  keyboard/Escape return and native required/min/max validity. Real browser proof
  exposed the readonly validity bypass and focus selector before their corrections.
- Removed 18 private backend exports/helpers, eight unused frontend helpers/
  component functions, eleven dead styles, edit-only mode branches, obsolete
  translation/auth/upload facades and orphan-only tests. Meaningful security tests
  now target active owners. Public exports/assets, migrations, operator tools and
  historical evidence remain. Retained cleanup statements were checked for
  byte-identical behavior.
- Thirty-nine ignored generated source-adjacent JS companions were isolated with
  original bytes/hashes under QA evidence; they had shadowed current TypeScript.
  The build-export guard now rejects this condition. A disposable mutation failed
  for the intended reason; source imports and real EventBus behavior then passed.

## Verification and evidence tiers

Commands are discoverable in application `tests/README.md` under Principal audit
regressions. Final logs and captures live under application
`test-results/reports/diagnostic-review/principal-audit-20261008/`.

| Boundary | Executed evidence |
| --- | --- |
| Build/export/architecture | Full shared/config/storage/i18n/database/moderation/email/uploads/API/Web production build exit 0; 30 export targets aligned; architecture gate and 37 fixtures passed. Bounded graph: 998 files / 4,084 imports, no detected cycles. |
| Auth/HTTP/notification/privacy | Earlier affected API 42 passed; final four actual API suites 19 passed (PostgreSQL, socket deadlines, OAuth policy, Pino sink). Quiet PostgreSQL 4, DB helper 3 and EventBus 14 passed. Relevant cleanup tests retained 85 passes with the two corrected adaptations then passing four focused cases. |
| Mobile | Scoped upload/queue/session/account policy suites passed; final deletion/session three files 32 passed and mobile typing passed. Race tests exercise the actual SecureStore owner with controlled device errors, not just a repository stub. |
| AI / optional UI reviewer | AI 45 passed (including real loopback budget checks), Ruff passed; UI worker 28 passed plus two producer coordinate contracts. Existing two websockets deprecation warnings remain. |
| Image worker / listener verifier | Real Fastify sink checks passed; removing the custom 404 handler failed the intended private-path assertion. Worker compilation passed. Offline all-listener verifier three fixtures and shell syntax passed. Deploy validation is recorded separately below. |
| Locale / date | 129 i18n tests and 95 language / five region catalog validation passed. Each language file adds exactly four keys and preserves all pre-existing values. Actual compiled helper Hindi browser check passed once. |
| Release/config policy | Offline release preparation 38/38 passed, including executable Compose environment forwarding and disposable canonical-policy mutations. Strict-human static policy 88/88 passed; this is not browser certification. |
| Local runtime | Owned FE+BE restarted. Four real desktop/mobile captures of localized calendar and email-assurance message passed HTTP 200/width/error checks; inspected visually. Native iPhone15/iOS18.6 home/menu/sign-in navigation inspected with no developer overlay; no email, OAuth, upload or deletion business journey submitted. |

The required complete Web unit suite passed 771/771 and workspace lint passed.
The complete mobile unit suite recorded 369 passes and one failure out of 370;
the failure is the A15 native ledger guard above. That original result remains
failed. The reviewed QA-only follow-up adds the three missing entries as planned,
updates the census to 114 and conserves every existing row, test case and runtime
claim. Six focused guard contracts passed, including one direct execution of the
unchanged production CLI. The complete suite was not repeated.

Actual native consumers support these dispositions: contest references open
through the platform URL handler without exact saved-file proof; opportunity
gallery selection/upload exists without a registered complete native journey;
the opportunity workspace displays a typed attachment key and lacks a picker or
download control. Reserved CON014/OPP014/OPP015 IDs are not implemented cases.
This census repair does not close those native capability or device-proof gaps.

Preserved setup failures include a wrong worker Vitest invocation (zero tests),
wrong guard command name (zero tests), earlier translation fallback failures,
source-shadowed tests and the isolated browser's first focus/readonly failures.
They were corrected at their actual boundary, not relabelled or suppressed.

## Remaining risks and external launch gates

The strict production doctor still exits 1 with nineteen real inputs: three
production DB bindings, six legal/operator values, three service URLs, four
role-scoped storage credentials and three backup bindings. Actual production
host/DNS/TLS, delivery providers, bucket ACL/CORS/retention and independent off-host
DB/object restoration require production access. None was fabricated or deployed.

Redacted history scanning found credentials in previously committed environment
files. Some historical values still match ignored local/UAT bindings, which is
not proof of present provider validity or revocation. Provider-side revocation/
rotation and operator confirmation remain a launch gate; history was not rewritten
and active secrets were not printed. Current tracked findings are synthetic
fixtures/setup placeholders. Five approved application dependency exceptions
expire 3 November 2026; worker production audit has no advisory.

New language copy is machine-assisted. Structural/semantic tests do not establish
human linguistic quality; low-resource translations need human review. Authenticated
native upload/deletion UI faults were tested at their actual HTTP/session/storage
boundaries, not through a signed-in device business run. Ordinary quiet preference
changes are reread at scheduled wake, not a new immediate outbox wake command.
Native opportunity workspace attachment selection/download remains an explicit
product gap; exact contest download and opportunity gallery journeys remain
planned native validation work. Sharing the backend does not establish complete
platform feature parity.

No new strict six-compatible-clean-child aggregate/verifier certificate exists.
The user's no-full-rerun policy remains binding. Existing historical failed/dirty/
partial evidence is preserved and cannot certify these source changes. Historical
provider timeout, telemetry rejection, ORB and insertion-loss observations are not
claimed explained by unrelated corrections. No universal zero-defect or production
approval claim is made.

## Publication and UAT handoff

Published main/origin revisions and exact UAT releases:

| Deployable | Commit | UAT release |
| --- | --- | --- |
| Application runtime | `8c6a10f4eb24c3132b20fd937285c0b4caff9b1d` | `20261008T084603Z-8c6a10f4` |
| Application QA-only follow-up (published HEAD) | `5f0985554f2f87c2219bd05f69330ab507724ab8` | No redeployment; runtime archive unchanged |
| AI interface | `4e46c6f935e782f3172f7f25c12985e104d3b672` | `20261008T084146Z-4e46c6f9` |
| Image worker | `15b48392e46df7bfcfbbb6c7f12adc3d1b0af279` | `20261008T084438Z-15b48392` |

Git archives match all 1,173 application / 23 AI / 29 worker regular source
blobs, with zero mismatches. The actual cwd of all six running application/AI/
worker processes binds to these releases. Full UAT verifier exits 0: eight units,
six private loopback service endpoints/listeners, ready PostgreSQL and public
Cloudflare Access boundary. Mandatory worker deploy validation executes 67 tests
and explicitly skips four PostgreSQL tests; production dependency audit is clean.
Normal migration deployment applies the existing schema; no new migration/reset.
Application release pruning and QA JSON deletion were disabled.

The QA-only follow-up changes just the native coverage matrix and test README.
`qa-runtime-archive-equivalence.json` proves all 1,173 deployable app archive blobs
are byte-identical between published HEAD and deployed runtime commit. Neither
runtime nor browser proof was repeated for that follow-up. This does not make the
new QA revision eligible for a historical strict certificate.

One read-only public UAT inspection passed four English/Hindi desktop/mobile
captures with HTTP 200, exact localized denial message, no browser/request/server
errors or width overflow. Root visually reviewed every image. It uses the existing
canonical private TLS proxy with only the exact disposable certificate SPKI pinned;
CORS/CSP are unchanged. No account/OTP/OAuth/upload/deletion business action was
submitted. The first transport setup failed before any browser launch because the
macOS temporary-directory socket path was too long; the short private `/tmp`
transport corrected only that setup. Its diagnostic record is retained.

`deployed-source-audit.json` and `uat-public-review.json` bind exact revisions,
releases, running processes and capture geometry under the final evidence directory.
These technical checks are not a six-child certificate. Optional UI reviewer is
an operator tool and was not deployed as an OCI service. No production deployment
or credential rotation occurred. Unrelated moderation/resume changes are preserved.
Root-owned local Web/API/Metro processes and the inspected simulator were stopped
after verification; UAT services remain deployed. No continuing runner or monitor
is required for this completed scoped audit.
