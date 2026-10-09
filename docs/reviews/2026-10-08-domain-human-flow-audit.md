# Opportunity, event, contest and profile human-flow audit

## Scope and acceptance

The user authorizes code-led investigation and fixes for all supported Web CRUD,
submissions, sharing, voting, workspace and profile operations. Contest creation
must be administrator-only. Current baseline is clean application `cda03ae3`.
Three GPT-6.1 SOL high domain reviewers trace real route/form/command/query paths;
the root agent reviews profile consumers and owns ledger/evidence publication.

Success means supported operations have accurate, discriminating assertions and
confirmed product defects are fixed with relevant lower-level and affected human
proof. Static mapping, API tests and focused browser children are distinct proof
tiers. No old completed matrix is rerun, historical evidence is preserved, and
no partial attempts become a clean certificate. Operations absent from the
product are classified explicitly rather than fabricated. Production/inbox/OTP
and OAuth gates retain their existing boundaries.

## Prioritized findings before modification

| Priority | Executable evidence / root cause | Minimal correction |
| --- | --- | --- |
| P1 data integrity | `opportunity.commands.ts` deletes every role on an edit; the actual migration FK cascades role deletion to applications. Web/native full edits always send roles. A title change can destroy applications and selected workspace eligibility. | Reconcile canonical roles in the existing locked transaction, retain IDs/statuses/applications, add new roles, and reject removal of referenced roles with a safe conflict. Real PostgreSQL/concurrency and new human discriminator. |
| P1 authorization | Contest create handler uses `requireAuth`; policy denies members only when configured quota is zero. A positive quota permits member creation and admin MFA is not enforced. | Existing `requireAdmin` at the write boundary plus unconditional central `ADMIN_ONLY` creation policy. Actual HTTP tests with positive member quota and missing/stale/valid admin MFA. |
| P2 edit correctness | Opportunity edit lacks category/experience/travel controls but shared client sends defaults, overwriting existing values. | Populate existing canonical controls and SSR payload; prove non-default values survive unchanged edits and can be intentionally changed. |
| P2 gallery read correctness | Opportunity/event queries take 12 rows before moderation filtering; the only full-gallery consumer has no pagination. New pending photos hide older approved photos and older items become unreachable. | Bound public-safe gallery pagination after visibility selection and expose real controls; preserve media/owner/attendee rules and verify mixed states and older photo reachability. |
| P2 reaction persistence | Contest submissions directory omits `shareCount` and caller reactions from gallery items, unlike detail preview. Reload loses active state. Directory sharing constructs current pathname plus hash and drops page identity. | Reuse complete canonical reaction fields and each trigger's canonical submission URL; real client-boundary and new directory interaction proof. |
| P2 test semantics | Contest winner test claims a non-owner permission readback but stays signed in as the administrator. Several ledger actor descriptions differ from executed roles. | Actual independent non-owner readback and precise actor/phase semantics; do not count locking as authorization proof. |
| P2 vote confirmation | Standalone contest submissions includes the shared lightbox but omits its vote-confirmation dialog; the current confirmation helper returns true when the dialog is absent. | Move the existing dialog into the shared lightbox, remove its main-page duplicate, and prove cancel causes no reaction request. |
| P2 write concurrency | Winner validation and edit lifecycle checks precede the final transaction; concurrent winner/edit changes can pass stale checks. | Recheck existing lifecycle/candidate/force semantics under the existing transaction's contest-row lock; discriminate concurrent and rollback paths. |
| P2 exact image selection | Public profile consumers replace image keys with rendition URLs. The report context returns canonical keys plus URLs, but the client matches only keys; with multiple photos the clicked image has no selected picker item. | Match the context's exact URL as well as key, then submit only its canonical key. Prove selection, deselection and exact payload using the actual compiled client. |
| P2 human coverage | Domain tests leave richer edits, independent public deletion, multi-role applications, workspace invalid/empty submissions and revocation, event gallery eligibility/lightbox/report/moderation and related permission boundaries partial. | New bounded journeys for unexecuted contracts, reusing existing UI helpers and canonical ledger. No synthetic API/DB pass conditions. |
| P2 profile coverage | Username rename/legacy redirect/conflict recovery; per-role services/request acceptance/removal; optional preference clearing and portfolio role-tag/lightbox/report paths lack complete strict-human assertions. Existing tests cover creation, metadata, role visibility, media deletion and account deletion separately. | Add focused current UI journeys and exact persistence/guest privacy checks, without adding absent profile features. |

## Change and ownership map

- Direct: API command/permission/query owners, existing Web forms and gallery
  consumers, strict-human specs and canonical ledger.
- Indirect: native callers share the same API; moderation/media readiness,
  transactional events, notification and workspace consumers must retain their
  current contracts.
- Persistence: preserve existing schema and outbox, prefer locks/reconciliation;
  no destructive reset, migration or queue replacement is planned.
- Shared contracts/configuration: reuse creation policy, role normalization,
  media visibility, pagination and design/i18n owners; avoid duplicate ledgers.
- Verification: disposable local schemas for real database checks; one owner of
  browsers/services and new/affected filtered flows only; live visual review.
- External: exact UAT deployment only after reviewed publication when product
  source changes; production access/provider/recovery and excluded auth flows
  are not closed by these tests.

Implementation begins with data integrity and explicit contest authorization,
then gallery and reaction reads, then remaining bounded human contracts. Findings
and proof will be updated from actual results, never inflated to 100 percent by
test-file presence.


## Reviewed corrections and executed lower-level checks

All product changes preserve the current schema, outbox and supported API fields.
Opportunity edits retain role IDs/statuses and all application states; referenced
role removal rolls back with409. Apply eligibility now reads under the same
parent/ordered-role locks. Web edit preserves category/experience/travel fields.
Contest creation requires administrator MFA independent of quota; winner/edit
checks run under row locks and durable winner title comes from the locked row.
Guest approved entry reads retain publication/READY/privacy gates. Both contest
gallery consumers render one existing vote dialog; directory reactions and exact
entry share URLs persist. Event/opportunity gallery selection uses one bounded
shared contract and visible pagination. Report-image URL matching selects the
canonical key without widening membership or authorization.

Executed evidence, distinct from business Web proof:

- Opportunity12 disposable real PostgreSQL cases passed, including actual FK
  cascade, concurrent lock waits, rollback, late apply and withdraw/reapply.
  Restored old role replacement failed the intended application-preservation test.
- Contest initial21 real HTTP/PostgreSQL cases passed; two final locked-title /
  rollback cases passed separately. Public-entry privacy five cases passed across
  disjoint corrected runs; original setup/fixture failures remain recorded.
- Gallery6 real PostgreSQL and6 actual read-route cases passed. An old pre-filter
  take12 mutation failed both exact EVENT/OPPORTUNITY page assertions. Approval
  totals are not promised to equal READY-delivery totals; short pages can occur
  while renditions become ready. Native default detail arrays remain compatible;
  native pagination navigation is not implemented or runtime-proven here.
- Actual compiled contest client8, report client4 and Astro pagination component2
  browser checks passed in their explicit synthetic seams. Old directory mapping/
  sharing, missing dialog and old report-selection code failed intended assertions.
  These checks do not establish provider delivery or business E2E.
- Consolidated affected API consumers83 passed and one stale workspace fixture
  failed. Only that failed block ran after repair and passed1; the original log
  is preserved. No product suppression was introduced.
- API/Web/mobile consumer typing, API/Web production builds, scoped ESLint44files,
  architecture37fixtures and actual boundary enforcement passed. Strict human
  policy88tests and180-case consistency guard passed. Playwright typing passed.
  An unsupported ESLint CLI option failed before analysis; corrected invocation
  passed and both original outputs remain retained.

Root gate logs: application `test-results/reports/diagnostic-review/domain-human-flow-audit-20261008/`.
Domain owners retained disposable mutation evidence without reverting tracked
source. No application DB reset, migration, production action or uncertain
provider mutation replay occurred.

## Supported-operation reconciliation

The following describes authored assertions; new business execution remains
pending until a separately recorded scoped original child completes.

| Domain | New human assertions | Genuine scope limits |
| --- | --- | --- |
| Opportunities | OPP023–032: role/application retention and conflict rollback; multi-role decisions and workspace credits; empty/invalid/note/file delivery; selected-participant revocation; exact public photo/report and five-photo quota; rich edits/media replacement/independent deletion; thirteen-photo paging; stale role/deadline/end denial; moderator-returned revision and search rediscovery | Owner quota20 not exhausted; autofix and delivery-status PATCH are API-only; no Web like/vote/share/cancel/review or photo edit/delete controls are invented. |
| Events | EVT014–020: thirteen-photo paging/oldest exact decoded identity/lightbox/report; rich edit and cover/fee clearing; independent canonical/legacy/search deletion; stale RSVP after closure; INTERESTED versus NOT_GOING uploads; moderator recovery; organizer contact and nonowner edit denial | Public date asserts month/year plus exact edit datetime readback, not an independently formatted public timestamp. No event cancellation/end-date/voting/comments/workspace UI exists. Owner quota20 not exhausted. |
| Contests | CON021–025: directory reaction persistence/confirmation cancellation; exact anonymous sharing target; forced winner replacement/clear and nonadmin denial; rich fields/dates/prizes/banner/reference replacement/download and public deletion. CON017 now uses an actual nonowner actor. | Invalid MIME/oversize and vote-removal denial retain backend proof tiers. No submission edit/withdraw, contest cancellation, payment or jury/scoring UI is invented. OS share-sheet cancellation is not claimed from the browser seam. |
| Profile | PRO009–011: rename/legacy redirect/conflict; role services/request acceptance/removal and optional fields/timezone clearing; role-tag priority, exact loaded image lightbox/hash/focus and authenticated canonical reporting | Profile report proof is loaded DOM identity plus canonical key, not decoded pixel equality. Existing media/account-deletion evidence remains separate and is not replayed. |

Only newly added or materially affected declarations will run, zero retries with
first-failure stop. Existing completed flows are not restarted. OAuth and six
delivered-email OTP cases remain excluded. Quiet-hour inbox delivery requires an
isolated inbox; the user accepted manual checking rather than fabricated proof.
No current six-compatible-complete-clean-child aggregate/verifier certificate or
production approval can be inferred from targeted runs. Nineteen external
production inputs, real host/DNS/TLS/provider/bucket policy and independent
DB/object recovery remain access-dependent launch gates.

## Domain operations — preserved first failure, 9 October 2026

Published product remains `0dac6128432ddd9687f57a2525dbca2fe6dc6975` at UAT
`20261008T170441Z-0dac6128`; the 1,181-file source archive and full stack health
were independently checked before launch. The original scoped child
`uat-domain-20261008T170824Z-0dac6128` terminated exit1 at 17:09:19 UTC on
8 October: zero passed, one failed, twenty-two unexecuted, zero retries.
Owner PID95377 is absent. `/tmp/tfp-domain-human-20261008T170543Z/status.json`
is authoritative; `/tmp/tfp-domain-human-state.json` retains immutable historical
launch state and must not be read as a current running owner.

The first helper assertion assumes UUIDs for submission links; executable
`ContestSubmission` uses CUIDs. The submitted entry and visible link existed.
Missing before/after evidence is a cascade of that helper failure, not an
established product failure. SOL high corrected only the helper and README;
root independently reviewed actual ID generation, routes and all three callers.
Harness `93e9300b5c6d1cf0ed5e57680e8181bc95144118` is published. Visible-link,
same-origin exact contest path and exact entry identity assertions remain.
Playwright typing, scoped lint, strict-human guard and diff checks passed.
Both revisions' deployable archives are byte-identical; all 1,181 live UAT blobs
match the original product, so no new deployment is required. Previous workspace
credit exhaustion made no edits; the resumed correction completed successfully.
The first focused recovery `uat-domain-contest-recovery-20261009T021350Z-93e9300b`
is also terminal exit1 at 02:15:21 UTC on9October: zero passed/one failed, zero
retries. Owner7196 is absent. The recorded first failure at spec498 is a global
Share selector matching both the visible direct-entry form and hidden lightbox
form; no click executed. Missing after-evidence is a cascade. Preserve its regular
context/manifest/results/trace/video/screenshots/cache. Atomic
`/tmp/tfp-domain-recovery-20261009T021119Z/focused-status.json` overrides historical
running/null state in `/tmp/tfp-domain-recovery-state.json`. The prior passive
completion watch did not report terminal status and is stopped.

Root accepted the actual source/trace correction: visible detail section, unique
reaction POST form for the exact submission ID, one visible exact Share button,
then unchanged feedback and independent fresh-GET reaction/count assertions.
Harness `22c6fb7f155a4fe22c3098c99a8f800b49cc209a` is published; typing/lint/guard88
and diff checks passed. No new browser execution has followed this correction.

The bounded SOL high same-class review of all22 remaining declarations found
only two additional confirmed selector mistakes, affecting EVT016/020/CON025.
Root independently accepted their three-file harness/README correction: actual
exact-title event articles and unique detail links, and a unique visible results
search field. Publication `2ac71bc27208d425151319a2d6073ec11aa61872` passed typing,
scoped lint, strict-human consistency and diff checks. Both archives and all1,181
live UAT files remain identical to product0dac. No product defect or new pass is
inferred from those test mistakes. Current inputs hash is `ea73fe211005dbcaaedf83554dccb22c36de5d0c63be5cea57eac081830bf963`;
four registries are unchanged. Fresh official discovery matched exactlyone
Chromium block/CON021–022 before its authorized proof. No browser is yet active.
Read any new `/tmp/tfp-domain-share-recovery-state.json`/atomic status before
acting; absence means not launched. Only a separately reviewed failed-block
proof may precede the original22 unexecuted blocks, never completed historical
flows or a full matrix.

The exact correction, scoped publication and deployable archive equivalence
are independently accepted. This uniquely discovered failed-block proof must
pass independent evidence review before only the original twenty-two unexecuted
blocks; completed historical flows/full matrices are never rerun. Every original
trace/result/context/manifest/cache remains untouched. Read any new
`/tmp/tfp-domain-recovery-state.json` and its atomic status before acting.
No partial or failed child may be spliced into strict six-child certification.
Preserve unrelated moderation/resume work and historical f19 evidence.

Product/database/client checks and operation scope remain documented in
`docs/reviews/2026-10-08-domain-human-flow-audit.md`. OAuth/six delivered-email
OTP/inbox, production host/provider/storage/legal and independent recovery gates
remain explicit. Production values were not invented and approval is not claimed.

## First new contest block: reviewed harness correction

| Source / failure | Root cause | Minimal correction | Status |
| --- | --- | --- | --- |
| Original app/harness `0dac6128`; helper `submitContestEntry` rejected the visible newly created entry at line424 | Actual command omits an ID, Prisma creates a CUID, Web/API routes accept that exact ID. The new anchored hexadecimal assertion assumed another identifier format. | Parse the visible URL, require same-origin exact contest prefix, no query/hash and one nonempty final segment; propagate its exact ID to directory/share/winner assertions. Two scoped files only. | Published harness `93e9300b`; fast checks passed. Original0/1/22 result remains preserved. Runtime recovery pending. |

Archive comparison evidence: `/tmp/tfp-domain-recovery-20261009T021119Z/archive-equivalence.json`.
Application identity remains `0dac6128432ddd9687f57a2525dbca2fe6dc6975`; harness
identity differs explicitly. Registry hashes are unchanged, while the run-input
hash must be freshly calculated from the corrected harness. No old contexts
or reports are rewritten and no passing totals/certificate are manufactured.

## Second preserved boundary and proactive selector review

| Source / failure | Root cause | Minimal correction | Status |
| --- | --- | --- | --- |
| Clean harness93e9300b, first focused block at498 | Actual DOM/source has a visible direct reaction form and a separate closed-dialog reaction form. Global SHARE query matches both, so strict mode prevents the click. | Scope the exact visible direct-entry section/form; require count1, exact submission ID, method POST and one visible Share button. Retain real reaction and independent GET checks. | Accepted/published22c6fb7f; fast checks passed, runtime still unexecuted. Both failed attempts retained. |
| EVT016/020 unexecuted declarations | Card component is an article with a nested listing-card__link; a.listing-card cannot reach it. | Bind exact-title event article and actual link; retain positive discovery, click and postdelete absence. | Accepted/published2ac71bc2; source correction only, runtime unexecuted. |
| CON025 unexecuted declaration | Header and results both render input[name=q]. | Scope unique visible query field to the actual results form; retain Enter/search readback. | Accepted/published2ac71bc2; source correction only, runtime unexecuted. |

First focused raw result SHA256 remains
`85dffc15f304f48fcee5eb944c117cc9197a528cea68c71995c2cd18e166822e`.
Its context is clean app0dac/harness93e/release20261008T170441Z-0dac6128 with
inputs9b5b5d23; it remains failed and cannot be certified or rewritten.

## Final selector counter-review and frozen recovery preflight

GPT-6.1 SOL high traced only the original22 unexecuted declarations and actual
rendered helpers/forms/routes. It found the two source mismatches above and no
additional confirmed finding within that bounded scope. This is neither an
executed business pass nor a universal zero-defect assertion. Root inspected
the exact diff: no action, deletion/authorization boundary or assertion was
weakened; no product source, dependency or runtime policy changed.

Scoped publication: Share22c6fb7f, then event/search2ac71bc2. Archive-equivalence
record under `/tmp/tfp-domain-share-recovery-20261009T024757Z/` binds product0dac,
current harness2ac71bc2 and the exact existing UAT release. The original23-child
and first focused93e child remain failed; neither is rewritten/spliced.

## Accepted focused proof and disjoint continuation — 9 October 2026

Corrected child `uat-domain-share-recovery-20261009T025018Z-2ac71bc2`
passed1/1, two CON021/022 IDs, zero retries/failures/flakes/skips, canonical and
wrapper exit0. Root and independent SOL high audited exact clean bindings,
canonical context hash8a0e623c, frozen inputs ea73fe21/four live registry hashes,
exact AST mapping, one attempt and matching attached/catalog/attempt evidence.
Two action pairs contain12 unique regular captures with fitting widths and
loaded images; root viewed all8desktop/mobile captures. Relevant diagnostics
are empty. Its partial coverage and five other unexecuted slots remain explicit.
Root audit: `/tmp/tfp-domain-share-recovery-20261009T024757Z/root-evidence-audit.json`.
Both prior failures remain unchanged and preserved.

Only the original22 unexecuted blocks (23IDs), independently reconciled against
original results and current AST, were selected. Fresh-cache official discovery
matched exactly22 before run `uat-domain-continuation-20261009T025709Z-2ac71bc2`,
owner13536, launched once with zero retries/maxfail1/action evidence. Current
operator state `/tmp/tfp-domain-continuation-state.json`; atomic completion
`/tmp/tfp-domain-continuation-20261009T025435Z/status.json`. Missing status is
unfinished. Selection SHA256482bd39c is immutable; accepted failed-block proof
is excluded. No completed historical flow or full matrix is repeated.
Do not mutate source/services/DB/cache while healthy; stop first actual failure
for evidence-led review. Canonical runner owns FE/BE restarts and isolated fixtures.
All evidence remains separate; no aggregate/certificate or production approval.

## Preserved continuation failure and CON025 form correction

Continuation `uat-domain-continuation-20261009T025709Z-2ac71bc2` ended exit1
at02:59:47UTC:1passed/1failed/20unexecuted/zeroRetries. Passed CON023/024
retains its complete2actionpairs/12regular captures; root viewed8desktop/mobile
images. It must not rerun. Original raw results SHA256
`def001b90ffcb48924532b3a4bea1cceafe5c2e9adff77af9bd637f0da43a64a`.
Canonical context hash3e4a9b6d binds originalclean2ac inputs ea73fe21, not the
new harness inputs. Operator launchstate remains immutable historical evidence.

| Source/failure | Root cause | Minimal correction | Status |
| --- | --- | --- | --- |
| CON025 fill at629; head SiteHead179 and edittextarea179 | Document-wide name query matches metadata and actual editable field; strict mode stops before submit. After-evidence failure is a cascade. | Unique visible POST form#contest-create-form[data-contest-create-form]; scope all edit/readback controls and require unique input/textarea fields; one initial resource instead of first(). | Two-file harness/README accepted and published7eab7deb. Public download pixels/legacycanonicalURL/delete/search/auth/evidence unchanged. Focused proof active, not yet accepted. |

Once-only Playwrighttyping/scopedlint/strict-humanconsistency/diff checks passed.
SOL high separately inspected20 still-unexecuted declarations/current components
and found no additional confirmed bare-name/meta/duplicate collision. No runtime
pass or zero-defect claim follows from that bounded review.

Both deployable archives and all1,181 live UAT files match product0dac exactly;
full8unit/6endpoint health passed. No product edit/redeployment. Archive proof
and immutable1failed+20unexecuted selections:
`/tmp/tfp-domain-edit-recovery-20261009T031154Z/`. Root audit retains old context
and results; new inputs d21dd6be/four unchanged registries are recorded separately.
Official fresh-cache discovery matched exactlyone CON025 declaration before
`uat-domain-edit-recovery-20261009T031339Z-7eab7deb`, detachedPID16229.
Read new state `/tmp/tfp-domain-edit-recovery-state.json` and bound atomic status.
One attempt/zeroRetries/maxfail1/action evidence; missing status unfinished.
After independent focused evidence/visual acceptance only20unexecuted may continue.
Never splice failed/partial contexts into certification or repeat completed flows.


## CON025 download failure preserved — 9 October 2026

Focused form recovery `uat-domain-edit-recovery-20261009T031339Z-7eab7deb`
terminated exit1 at03:15:32UTC:0passed/1failed/zeroRetries. Owner16229 is absent.
The atomic focused-status.json is authoritative; the immutable historical launch
snapshot remains running/null and must not be rewritten as current activity.

| Source/failure | Proved cause and limitation | Next scoped step | Status |
| --- | --- | --- | --- |
| Public CON025 resource download, spec672 | Thumbnail GET200 JPEG, native fetch CORS/ERR_FAILED, fallback navigation GET200 JPEG with no attachment disposition; download event times out30s. Signed expiry still854s. Actual current policy versus earlier no-CORS cache reuse remains unknown. | Read-only current provider GET policy and fresh-origin response evidence before choosing a minimal delivery/config correction. No CORS weakening or suppression. | SOL high diagnosis only; no new browser or product edit. |
| finally spec723 / secondary fixture738 | Secondary console guard replaces primary download timeout and prevents following exact-owned fixture cleanup. | Preserve primary error, attach secondary diagnostics, keep guard failure when no primary and guarantee cleanup ordering, with discriminating lifecycle checks. | Scoped harness owner authorized; root exact-diff review required. |

Original results/trace/video/captures/context/manifest/cache remain unchanged.
Earlier CON021/022 and CON023/024 passes are retained;20original blocks remain
unexecuted. No aggregate, verifier success or production approval is claimed.


## Accepted minimal download/cleanup correction — 9 October 2026

Published app/harness092a95ee contains nine scoped files. Current exact-origin
provider GET/HEAD returned200JPEG with ACAO/Vary, so no provider policy widening
is justified. Read-only source-scoped GetBucketCors denied403. A two-origin real
Chromium socket discriminator compiling the actual helper reproduced the old
thumbnail-cache/CORS/no-download pattern; no-store then saved exact bytes/name
with one fresh Origin GET. Original UAT initiating cache reuse remains unproved.
Signed identity, credentials omission, CORS enforcement and fallback are unchanged.

Shared supervised finalization retains primary errors, attaches sanitized secondary
failures and guarantees exact-owned cleanup attempts; strict diagnostic failure
still fails an otherwise-successful flow. Five new-domain consumers migrated.
SOL high independent read-only review found no concrete blocker. Tests: download
unit6, cleanup6, two separate lower-level browser checks passed. Original old-source
rejection, initial popup timing failure and optional-CDP-type failure are preserved;
only their failed/incomplete checks were recovered. Typing/lint/human180/diff passed.
Evidence: app test-results/reports/diagnostic-review/domain-download-cleanup-20261009/.
Deployment/full exact health and one CON025 proof are pending;20 original blocks
remain untouched. No strict certificate or production approval follows.


## Exact UAT deployment and focused download recovery active

Main UAT `20261009T071116Z-092a95ee` deployed successfully, including production
builds. All1,181 Git archive blobs match live files; only shared resource-download
runtime source changed versus0dac. Exact three app service cwd markers and full
eight-unit/six-endpoint health/loopback boundaries passed. No pending migrations;
prior releases were retained. Initial archive path discovery used root instead of
nested source; read-only setup failure and corrected archive proof remain distinct.

One fresh-cache official Chromium discovery exactly matched CON025 before
`uat-domain-download-20261009T071739Z-092a95ee`, owner32255, launched once. State
`/tmp/tfp-domain-download-recovery-state.json` binds the atomic status at
`/tmp/tfp-domain-download-recovery-20261009T071404Z/focused-status.json`; absent final status remains unfinished.
Inputs `98d2f4b9333d0e93954f4efd9cd4397e667eb060293cc0784b3bc136cc91c37e`, four registries unchanged, one scoped fresh-fixture
case/zeroRetries/maxfail1/action evidence. Low-cost monitor owns exact process exit
watch only. No old pass or remaining20 is repeated/launched. Independent evidence
and settled desktop/mobile acceptance is required before disjoint continuation.


## Focused download recovery — preserved later URL failure

`uat-domain-download-20261009T071739Z-092a95ee` terminated exit1 at07:19:32UTC,
0passed/1failed/zeroRetries; owner32255 absent. Exact file download/pixel assertions
at675–679 progressed before legacy canonical URL assertion694 failed because the
actual canonical route also carried default tab=about. Missing after evidence is
a cascade. The shared finalizer preserved that actual primary error and reached
cleanup instead of masking it. Source-led SOL high review must classify the
query-owner behavior before any minimal correction or new proof. All original
artifacts/state/caches remain immutable;20 remaining blocks never started.


## Domain operations — exact-tab recovery active, 9 October 2026

Product `092a95ee1a2c8dfc6db07b11d34de0c8c87475da` remains deployed at UAT
`20261009T071116Z-092a95ee`; clean published harness is `7d1e3e648f09a876f769d9922bb63af0b039549c`.
All1,181 deployable archive blobs are byte-identical and match live, exact three
service cwd markers and full-stack health passed. No redeployment was required.
Initial read-only archive setup used an incorrect marker name and unprivileged
proc-cwd access; corrected verified reads passed, with setup evidence preserved.

The prior CON025 proof `uat-domain-download-20261009T071739Z-092a95ee` remains
terminal exit1/0passed/1failed/zeroRetries. Actual download and normalized tolerant
pixel comparison passed before the later exact legacy-URL assertion failed.
The shared detail controller intentionally synchronizes initial About state as
`tab=about`; canonical origin/path/hash were correct. Root independently accepted
SOL high's four-file harness/README correction: full exact canonical URL plus
About state, selected-tab assertion, the same fix for only unexecuted OPP028/032,
and shared primary-preserving cleanup for OPP032. Product behavior is unchanged.
Playwright typing, scoped lint, human180 consistency, one changed consumer-contract
assertion and diff checks passed. Prior download cache/no-store and lifecycle
corrections retain their real-socket/consumer proof; original UAT cache reuse was
not conclusively captured and no provider CORS/security widening was made.

Exactly one focused CON025 recovery `uat-domain-tab-20261009T073958Z-7d1e3e64` is launched,
owner PID34497. `/tmp/tfp-domain-tab-recovery-state.json` binds atomic
`/tmp/tfp-domain-tab-recovery-20261009T073734Z/focused-status.json`; missing final status is unfinished.
Fresh isolated-cache official discovery exactly matched one canonical block,
zero retries/maxfail1/oneworker/action evidence. Inputs `e8793da075b4b2be9d8e3fdff3a48614d14680d494dbb0ec476026de8e931ec8`;
four registries unchanged. Low owner watches exact process exit only. Original
failed states/reports/caches are immutable. No current pass is claimed before
original context/manifest/evidence and desktop/mobile inspection. Accepted
CON021/022 and CON023/024 must not repeat;20 original blocks remain unexecuted
until independent focused acceptance. No overlapping owner or shared source,
service, DB or cache mutation during healthy work. Runner owns FE/BE setup and
scoped isolated fixtures. No full-suite/completed-flow replay or evidence splicing.

Evidence and historical attempts: `docs/reviews/2026-10-08-domain-human-flow-audit.md`.
Strict six-compatible-clean-child aggregate/verifier certification, OAuth/six
recipient-delivered OTP/inbox and19 external production inputs plus actual
host/provider/storage/legal/independent recovery remain gates. Never invent
values, approve/deploy production or delete QA evidence. Preserve unrelated
moderation-service/resume work and historicalf19.

## Domain operations — accepted CON025, remaining20 active, 9 October 2026

Product `092a95ee1a2c8dfc6db07b11d34de0c8c87475da` remains deployed at UAT
`20261009T071116Z-092a95ee`; clean published harness is `7d1e3e648f09a876f769d9922bb63af0b039549c`.
All1,181 deployable archive blobs are byte-identical and match live, exact three
service cwd markers and full-stack health passed. No redeployment was required.
Initial read-only archive marker/proc-permission setup mistakes are preserved;
corrected reads passed without source/service mutations or browser execution.

CON025 recovery `uat-domain-tab-20261009T073958Z-7d1e3e64` finished exit0 at07:41:46UTC,
1passed/zeroRetries/failures/flakes/skips. Root and independent GPT-6.1 SOL high
accepted regular original context/manifest/evidence, current four-registry/input
hashes, exact clean product/harness/release and canonical declaration. Context
hash `86e4516611f52c1593bfa076927b7d3d72a0ba88a991a2cbd003d3d713990035`; inputs `e8793da075b4b2be9d8e3fdff3a48614d14680d494dbb0ec476026de8e931ec8`.
Two action pairs/twelve unique regular captures complete; all widths fit and
recorded images loaded, relevant diagnostics empty. Root viewed all8desktop/mobile
captures; tablet metadata only. Proof covers rich edit/media replacement, awaited
normalized tolerant download pixels (mean RGB difference<=6, not binary identity),
exact legacy canonical URL plus declared tab=about/selected About, deletion cancel/
confirm and independent public canonical/legacy/directory404/list/search absence.
The four-file minimal harness correction changes no product behavior; typing,
scoped lint, human180 consistency, changed consumer contract and diff passed.
Shared no-store CORS/download correction retains real-socket/consumer evidence;
original UAT cache reuse was not conclusively captured, no provider policy weakened.

Exactly one continuation `uat-domain-remaining20-20261009T074551Z-7d1e3e64` launched, ownerPID35667,
ONLY20 original unexecuted blocks/20IDs. `/tmp/tfp-domain-remaining20-state.json`
binds authoritative `/tmp/tfp-domain-tab-recovery-20261009T073734Z/unexecuted-status.json`;
missing final status unfinished. Fresh isolated-cache official discovery exactly
matches canonical AST and immutable disjoint selection SHA256
`10c2ec36cf388d554c3e3820c23c0e2f943d2a2e7383daf1c8c5258bf4b346f5`. ZeroRetries/maxfail1/oneworker/action evidence;
resource gate4.87GiB free exceeded2GiB conservative report+256MiBvariance+512MiBreserve.
Root sole runner owner; low owner watches exact process exit only. Runner owns
FE/BE setup/scoped isolated fixtures. No overlapping launch, healthy restart or
shared source/service/DB/cache mutation. Accepted CON021/022,CON023/024,CON025 and
completed historical flows must never repeat. Original failed contexts/caches and
immutable historical running launch states remain separate; atomic status wins.
No current20 pass is claimed before original evidence/settled visual acceptance.

Evidence: `docs/reviews/2026-10-08-domain-human-flow-audit.md` and external immutable
preflight/reviews under `/tmp/tfp-domain-tab-recovery-20261009T073734Z`. Focused/resumed results are incomplete;
no strict six-compatible-clean-child aggregate/verifier certificate or production
approval follows. OAuth/six recipient-delivered OTP/inbox and19external production
inputs plus actual host/provider/storage/legal/independent recovery remain gates.
Never invent values, approve/deploy production or delete QA evidence. Preserve
unrelated moderation-service/resume work and historicalf19.
