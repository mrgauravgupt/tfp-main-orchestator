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
